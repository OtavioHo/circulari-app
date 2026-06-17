import 'package:circulari/core/models/plan_tier.dart';
import 'package:circulari/features/subscription/domain/repositories/subscription_repository.dart';

class RestorePurchasesUsecase {
  final SubscriptionRepository _repository;

  const RestorePurchasesUsecase(this._repository);

  Future<PlanTier> call() => _repository.restore();
}
