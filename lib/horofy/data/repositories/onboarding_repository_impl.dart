import 'package:horofy/horofy/domain/repositories/onboarding_repository.dart';
import '../datasources/local_data_source.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final LocalDataSource localDataSource;

  OnboardingRepositoryImpl(this.localDataSource);

  @override
  Future<void> saveOnboardingSeen() {
    return localDataSource.saveOnboardingSeen();
  }

  @override
  bool isOnboardingSeen() {
    return localDataSource.isOnboardingSeen();
  }
}
