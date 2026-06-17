import 'package:circulari/core/models/plan_tier.dart';
import 'package:circulari/features/subscription/domain/repositories/subscription_repository.dart';

class PurchasePackageUsecase {
  final SubscriptionRepository _repository;

  const PurchasePackageUsecase(this._repository);

  Future<PlanTier> call(String packageId) => _repository.purchase(packageId);
}
