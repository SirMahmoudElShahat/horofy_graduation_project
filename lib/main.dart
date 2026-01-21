import 'package:flutter/material.dart';
import 'package:horofy/app_router.dart';

void main() {
  runApp(Horofy(appRouter: AppRouter()));
}

class Horofy extends StatelessWidget {
  const Horofy({super.key, required this.appRouter});

  final AppRouter appRouter;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Horoofy حروفى',
      debugShowCheckedModeBanner: false,
      onGenerateRoute: appRouter.generateRoute,
    );
  }
}
