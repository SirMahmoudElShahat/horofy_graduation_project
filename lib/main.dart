import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horofy/app_router.dart';
import 'package:horofy/core/cache/cache_helper.dart';
import 'package:horofy/core/constants/strings.dart';
import 'package:horofy/core/style/app_colors.dart';
import 'package:horofy/horofy/data/datasources/local_data_source.dart';
import 'package:horofy/horofy/data/repositories/onboarding_repository_impl.dart';
import 'package:horofy/horofy/presentation/cubit/onboarding_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CacheHelper.init();
  runApp(
    BlocProvider(
      create: (context) =>
          OnboardingCubit(OnboardingRepositoryImpl(LocalDataSourceImpl())),
      child: Horofy(appRouter: AppRouter()),
    ),
  );
}

class Horofy extends StatelessWidget {
  const Horofy({super.key, required this.appRouter});

  final AppRouter appRouter;

  @override
  Widget build(BuildContext context) {
    precacheImage(const AssetImage('assets/images/splash.gif'), context);
    return MaterialApp(
      title: 'Horoofy حروفى',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: AppColors.primary),
      initialRoute: splashScreen,
      onGenerateRoute: appRouter.generateRoute,
    );
  }
}
