import 'package:circulari/features/subscription/domain/entities/subscription_option.dart';
import 'package:circulari/features/subscription/domain/repositories/subscription_repository.dart';

class GetOfferingsUsecase {
  final SubscriptionRepository _repository;

  const GetOfferingsUsecase(this._repository);

  Future<List<SubscriptionOption>> call() => _repository.getOptions();
}
