import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:horofy/app_router.dart';
import 'package:horofy/core/cache/cache_helper.dart';
import 'package:horofy/core/constants/strings.dart';
import 'package:horofy/core/style/app_colors.dart';
import 'package:horofy/horofy/data/datasources/child_local_datasource.dart';
import 'package:horofy/horofy/data/datasources/letters_local_data_source.dart';
import 'package:horofy/horofy/data/datasources/local_data_source.dart';
import 'package:horofy/horofy/data/datasources/progress_local_datasource.dart';
import 'package:horofy/horofy/data/repositories/child_repository_impl.dart';
import 'package:horofy/horofy/data/repositories/letters_repository_impl.dart';
import 'package:horofy/horofy/data/repositories/onboarding_repository_impl.dart';
import 'package:horofy/horofy/data/repositories/progress_repository_impl.dart';
import 'package:horofy/horofy/domain/usecases/add_child_usecase.dart';
import 'package:horofy/horofy/domain/usecases/letters_usecase.dart';
import 'package:horofy/horofy/domain/usecases/progress_usecases.dart';
import 'package:horofy/horofy/presentation/cubit/child_cubit.dart';
import 'package:horofy/horofy/presentation/cubit/letters_cubit.dart';
import 'package:horofy/horofy/presentation/cubit/onboarding_cubit.dart';
import 'package:horofy/horofy/presentation/cubit/progress_cubit.dart';
import 'package:horofy/horofy/data/datasources/mad_letters_datasource.dart';
import 'package:horofy/horofy/data/repositories/mad_letters_repository_impl.dart';
import 'package:horofy/horofy/domain/usecases/mad_letters_usecase.dart';
import 'package:horofy/horofy/presentation/cubit/level2_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CacheHelper.init();
  runApp(
    MultiBlocProvider(
      providers: [
        /// onboarding
        BlocProvider(
          create: (context) =>
              OnboardingCubit(OnboardingRepositoryImpl(LocalDataSourceImpl())),
        ),

        /// children
        BlocProvider(
          create: (context) {
            final repository = ChildRepositoryImpl(ChildLocalDataSourceImpl());
            return ChildCubit(
              AddChildUseCase(repository),
              addChild: AddChildUseCase(repository),
              getChildrenUseCase: GetChildrenUseCase(repository),
              deleteChildUseCase: DeleteChildUseCase(repository),
              updateChildUseCase: UpdateChildUseCase(repository),
            );
          },
        ),

        /// Progress Feature
        BlocProvider(
          create: (context) {
            final dataSource = ProgressLocalDataSourceImpl();
            final repository = ProgressRepositoryImpl(dataSource);
            return ProgressCubit(
              saveProgressUseCase: SaveProgressUseCase(repository),
              getProgressForChildUseCase: GetProgressForChildUseCase(
                repository,
              ),
              getProgressForLetterUseCase: GetProgressForLetterUseCase(
                repository,
              ),
              updateProgressUseCase: UpdateProgressUseCase(repository),
            );
          },
        ),

        /// Letters Feature
        BlocProvider(
          create: (context) {
            final dataSource = LettersLocalDataSourceImpl();

            final repository = LettersRepositoryImpl(dataSource);

            final getLetters = GetLettersUseCase(repository);

            return LettersCubit(getLetters)..loadLetters();
          },
        ),

        /// Mad Letters Feature
        BlocProvider(
          create: (context) {
            final dataSource = MadLettersDataSourceImpl();
            final repository = MadLettersRepositoryImpl(dataSource);
            final progressRepo = ProgressRepositoryImpl(
              ProgressLocalDataSourceImpl(),
            );

            return Level2Cubit(
              getMadLettersUseCase: GetMadLettersUseCase(repository),
              saveProgressUseCase: SaveProgressUseCase(progressRepo),
              getProgressForChildUseCase: GetProgressForChildUseCase(
                progressRepo,
              ),
              getProgressForLetterUseCase: GetProgressForLetterUseCase(
                progressRepo,
              ),
              updateProgressUseCase: UpdateProgressUseCase(progressRepo),
            )..loadMadLetters();
          },
        ),
      ],
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
    return GetMaterialApp(
      title: 'Horoofy حروفى',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: AppColors.primary),
      initialRoute: splashScreen,
      onGenerateRoute: appRouter.generateRoute,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ar')],
    );
  }
}
