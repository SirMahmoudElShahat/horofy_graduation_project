import 'package:horofy/core/cache/cache_helper.dart';

abstract class LocalDataSource {
  Future<void> saveOnboardingSeen();
  bool isOnboardingSeen();
}

class LocalDataSourceImpl implements LocalDataSource {
  static const String onboardingKey = 'onboarding_seen';

  @override
  Future<void> saveOnboardingSeen() async {
    await CacheHelper.saveBool(onboardingKey, true);
  }

  @override
  bool isOnboardingSeen() {
    return CacheHelper.getBool(onboardingKey);
  }
}
