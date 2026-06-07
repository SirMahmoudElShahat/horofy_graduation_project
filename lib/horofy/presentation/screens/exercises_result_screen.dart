import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horofy/core/style/app_colors.dart';
import 'package:horofy/core/widgets/loading_overlay.dart';
import 'package:horofy/horofy/presentation/cubit/child_cubit.dart';
import 'package:horofy/horofy/presentation/cubit/child_state.dart';
import 'package:horofy/horofy/presentation/widgets/exercises_button.dart';

class ExercisesResultScreen extends StatefulWidget {
  const ExercisesResultScreen({super.key});

  @override
  State<ExercisesResultScreen> createState() => _ExercisesResultScreenState();
}

class _ExercisesResultScreenState extends State<ExercisesResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _celebrationController;
  late Animation<double> _celebrationAnim;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _celebrationAnim = CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.elasticOut,
    );
    _celebrationController.forward();
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final VoidCallback onPressed =
        ModalRoute.of(context)!.settings.arguments as VoidCallback;

    return BlocBuilder<ChildCubit, ChildState>(
      builder: (context, childState) {
        return LoadingOverlay(
          isLoading: childState is ChildUpdateLoading,
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: Stack(
              children: [
                Positioned(
                  top: 35,
                  right: 25,
                  child: ExercisesButton(
                    onPressed: () {
                      onPressed();
                    },
                    buttonIcon: Icons.arrow_forward_sharp,
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/pass.png',
                        height: 230,
                        width: 230,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 32),
                      AnimatedBuilder(
                        animation: _celebrationAnim,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _celebrationAnim.value,
                            child: child,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF774019),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, color: Colors.yellow, size: 28),
                              SizedBox(width: 8),
                              Text(
                                '🎉 !أحسنت',
                                style: TextStyle(
                                  fontFamily: 'Cairo-ExtraBold',
                                  fontSize: 22,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.star, color: Colors.yellow, size: 28),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
