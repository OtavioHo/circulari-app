import 'package:circulari/core/models/plan_tier.dart';
import 'package:circulari/features/subscription/data/sources/subscription_remote_source.dart';
import 'package:circulari/features/subscription/domain/entities/subscription_option.dart';
import 'package:circulari/features/subscription/domain/repositories/subscription_repository.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionRemoteSource _source;

  const SubscriptionRepositoryImpl(this._source);

  @override
  Future<List<SubscriptionOption>> getOptions() => _source.getOptions();

  @override
  Future<PlanTier> purchase(String packageId) => _source.purchase(packageId);

  @override
  Future<PlanTier> restore() => _source.restore();
}
