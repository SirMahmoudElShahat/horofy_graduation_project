import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:horofy/app_router.dart';
import 'package:horofy/core/cache/cache_helper.dart';
import 'package:horofy/core/constants/strings.dart';
import 'package:horofy/core/style/app_colors.dart';
import 'package:horofy/horofy/data/datasources/auth_remote_datasource.dart';
import 'package:horofy/horofy/data/datasources/chat_remote_datasource.dart';
import 'package:horofy/horofy/data/datasources/child_remote_datasource.dart';
import 'package:horofy/horofy/data/datasources/letters_local_data_source.dart';
import 'package:horofy/horofy/data/datasources/local_data_source.dart';
import 'package:horofy/horofy/data/datasources/submission_remote_datasource.dart';
import 'package:horofy/horofy/data/repositories/auth_repository_impl.dart';
import 'package:horofy/horofy/data/repositories/child_repository_impl.dart';
import 'package:horofy/horofy/data/repositories/letters_repository_impl.dart';
import 'package:horofy/horofy/data/repositories/onboarding_repository_impl.dart';
import 'package:horofy/horofy/data/repositories/submission_repository_impl.dart';
import 'package:horofy/horofy/domain/usecases/add_child_usecase.dart';
import 'package:horofy/horofy/domain/usecases/auth_usecases.dart';
import 'package:horofy/horofy/domain/usecases/letters_usecase.dart';
import 'package:horofy/horofy/domain/usecases/submission_usecases.dart';
import 'package:horofy/horofy/presentation/cubit/auth_cubit.dart';
import 'package:horofy/horofy/presentation/cubit/chat_cubit.dart';
import 'package:horofy/horofy/presentation/cubit/child_cubit.dart';
import 'package:horofy/horofy/presentation/cubit/letters_cubit.dart';
import 'package:horofy/horofy/presentation/cubit/onboarding_cubit.dart';
import 'package:horofy/horofy/data/datasources/mad_letters_datasource.dart';
import 'package:horofy/horofy/data/repositories/mad_letters_repository_impl.dart';
import 'package:horofy/horofy/domain/usecases/mad_letters_usecase.dart';
import 'package:horofy/horofy/presentation/cubit/level2_cubit.dart';
import 'package:horofy/horofy/presentation/cubit/submission_cubit.dart';

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

        /// Auth
        BlocProvider(
          create: (context) {
            final dataSource = AuthRemoteDataSourceImpl(dio: Dio());
            final repository = AuthRepositoryImpl(dataSource);
            return AuthCubit(
              loginUseCase: LoginUseCase(repository),
              registerUseCase: RegisterUseCase(repository),
              forgotPasswordUseCase: ForgotPasswordUseCase(repository),
              verifyOtpUseCase: VerifyOtpUseCase(repository),
              resetPasswordUseCase: ResetPasswordUseCase(repository),
            );
          },
        ),

        /// chat
        BlocProvider(
          create: (context) =>
              ChatCubit(dataSource: ChatRemoteDataSourceImpl(dio: Dio())),
        ),

        /// children
        BlocProvider(
          create: (context) {
            final remoteDataSource = ChildRemoteDataSourceImpl(dio: Dio());

            final repository = ChildRepositoryImpl(
              remoteDataSource: remoteDataSource,
            );

            return ChildCubit(
              addChild: AddChildUseCase(repository),
              getChildrenUseCase: GetChildrenUseCase(repository),
              deleteChildUseCase: DeleteChildUseCase(repository),
              updateChildUseCase: UpdateChildUseCase(repository),
            );
          },
        ),

        /// Submissions — replaces ProgressCubit
        BlocProvider(
          create: (context) {
            final dataSource = SubmissionRemoteDataSourceImpl(dio: Dio());
            final repository = SubmissionRepositoryImpl(dataSource);
            return SubmissionCubit(
              submitExerciseUseCase: SubmitExerciseUseCase(repository),
              getChildSubmissionsUseCase: GetChildSubmissionsUseCase(repository),
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

       /// Level 2 — Mad Letters
        BlocProvider(
          create: (context) {
            final dataSource = MadLettersDataSourceImpl();
            final repository = MadLettersRepositoryImpl(dataSource);
            return Level2Cubit(
              getMadLettersUseCase: GetMadLettersUseCase(repository),
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
