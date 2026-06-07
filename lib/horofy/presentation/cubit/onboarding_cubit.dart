import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horofy/horofy/domain/repositories/onboarding_repository.dart';
import 'package:horofy/horofy/presentation/cubit/onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final OnboardingRepository repository;

  OnboardingCubit(this.repository) : super(OnboardingInitial());

  Future<bool> isOnboardingSeen() async {
    return repository.isOnboardingSeen();
  }

  void checkOnboarding() {
    final seen = repository.isOnboardingSeen();
    emit(seen ? OnboardingSeen() : OnboardingNotSeen());
  }

  Future<void> completeOnboarding() async {
    await repository.saveOnboardingSeen();
    emit(OnboardingSeen());
  }
}
