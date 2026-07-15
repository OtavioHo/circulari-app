import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:circulari/core/error/app_exception.dart';
import 'package:circulari/core/models/plan_tier.dart';
import 'package:circulari/features/profile/domain/usecases/reconcile_plan_usecase.dart';
import 'package:circulari/features/subscription/domain/usecases/get_offerings_usecase.dart';
import 'package:circulari/features/subscription/domain/usecases/purchase_package_usecase.dart';
import 'package:circulari/features/subscription/domain/usecases/restore_purchases_usecase.dart';
import 'package:circulari/features/subscription/presentation/bloc/paywall_event.dart';
import 'package:circulari/features/subscription/presentation/bloc/paywall_state.dart';

class PaywallBloc extends Bloc<PaywallEvent, PaywallState> {
  final GetOfferingsUsecase _getOfferings;
  final PurchasePackageUsecase _purchase;
  final RestorePurchasesUsecase _restore;
  final ReconcilePlanUsecase _reconcilePlan;

  PaywallBloc({
    required GetOfferingsUsecase getOfferings,
    required PurchasePackageUsecase purchase,
    required RestorePurchasesUsecase restore,
    required ReconcilePlanUsecase reconcilePlan,
  })  : _getOfferings = getOfferings,
        _purchase = purchase,
        _restore = restore,
        _reconcilePlan = reconcilePlan,
        super(const PaywallInitial()) {
    on<PaywallLoadRequested>(_onLoad);
    on<PaywallPurchaseRequested>(_onPurchase);
    on<PaywallRestoreRequested>(_onRestore);
  }

  Future<void> _onLoad(PaywallLoadRequested event, Emitter<PaywallState> emit) async {
    emit(const PaywallLoading());
    try {
      final options = await _getOfferings();
      if (options.isEmpty) {
        debugPrint('[Paywall] Load failed: no purchasable plans returned from '
            'the store. Paywall shows the error state. See [Paywall] logs from '
            'SubscriptionRemoteSource above for the root cause.');
        emit(const PaywallFailure('Nenhum plano disponível no momento.'));
        return;
      }
      debugPrint('[Paywall] Loaded ${options.length} plan option(s).');
      emit(PaywallReady(options));
    } on AppException catch (e) {
      debugPrint('[Paywall] Load failed with exception: ${e.message}');
      emit(PaywallFailure(e.message));
    }
  }

  Future<void> _onPurchase(PaywallPurchaseRequested event, Emitter<PaywallState> emit) async {
    final ready = _ready;
    if (ready == null || ready.busy) return;
    emit(ready.copyWith(busy: true, clearError: true, clearPurchased: true));
    try {
      final tier = await _purchase(event.packageId);
      await _settle(emit, ready, tier, emptyMessage: 'A compra não ativou nenhum plano.');
    } on PurchaseCancelledException {
      emit(ready.copyWith(busy: false));
    } on AppException catch (e) {
      emit(ready.copyWith(busy: false, error: e.message));
    }
  }

  Future<void> _onRestore(PaywallRestoreRequested event, Emitter<PaywallState> emit) async {
    final ready = _ready;
    if (ready == null || ready.busy) return;
    emit(ready.copyWith(busy: true, clearError: true, clearPurchased: true));
    try {
      final tier = await _restore();
      await _settle(emit, ready, tier, emptyMessage: 'Nenhuma assinatura para restaurar.');
    } on AppException catch (e) {
      emit(ready.copyWith(busy: false, error: e.message));
    }
  }

  /// On a paid result, reconcile the backend (best-effort) so the tier is
  /// authoritative regardless of where the paywall was opened, then signal the
  /// purchased tier. A free result means nothing was activated/restored.
  Future<void> _settle(
    Emitter<PaywallState> emit,
    PaywallReady ready,
    PlanTier tier, {
    required String emptyMessage,
  }) async {
    if (!tier.isPaid) {
      emit(ready.copyWith(busy: false, error: emptyMessage));
      return;
    }
    try {
      await _reconcilePlan();
    } catch (e) {
      // The webhook is the durable fallback; surfacing nothing here is fine.
      debugPrint('PaywallBloc: post-purchase reconcile failed: $e');
    }
    emit(ready.copyWith(busy: false, purchasedTier: tier));
  }

  PaywallReady? get _ready => state is PaywallReady ? state as PaywallReady : null;
}
