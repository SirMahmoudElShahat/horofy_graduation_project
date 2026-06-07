import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horofy/core/constants/strings.dart';
import 'package:horofy/core/helper/orientation_helper.dart';
import 'package:horofy/core/style/app_colors.dart';
import 'package:horofy/core/style/font_style.dart';
import 'package:horofy/horofy/presentation/cubit/child_cubit.dart';
import 'package:horofy/horofy/presentation/cubit/child_state.dart';
import 'package:horofy/horofy/domain/entities/child_entity.dart';

class ChildHomeScreen extends StatefulWidget {
  const ChildHomeScreen({super.key});

  @override
  State<ChildHomeScreen> createState() => _ChildHomeScreenState();
}

class _ChildHomeScreenState extends State<ChildHomeScreen> {
  // final double _progress = 0.1; // Commented out to use computed progress

  @override
  void initState() {
    super.initState();
    OrientationHelper.landscape();
  }

  @override
  void dispose() {
    OrientationHelper.portrait();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments;
    ChildEntity? child = arg is ChildEntity ? arg : null;

    return BlocBuilder<ChildCubit, ChildState>(
      builder: (context, state) {
        if (state is ChildLoaded && child != null) {
          try {
            child = state.children.firstWhere((c) => c.id == child!.id);
          } catch (_) {}
        }

        // compute progress from child's level (level1..level7)
        double progress = 0.0;
        if (child != null) {
          final lvl = child!.level;
          int num = 1;
          if (lvl.startsWith('level')) {
            final parsed = int.tryParse(lvl.replaceFirst('level', ''));
            if (parsed != null && parsed >= 1 && parsed <= 7) num = parsed;
          }
          progress = (num / 7).clamp(0.0, 1.0);
        }

        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/child_background.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              //child info (show avatar + name when passed as argument)
              Builder(
                builder: (context) {
                  return child != null
                      ? Positioned(
                          top: 40,
                          right: 20,
                          child: Material(
                            type: MaterialType.transparency,
                            child: Row(
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      "🌟! مرحبًا ${child!.name}",
                                      style: AppTextStyles.blackFont.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      "💪🔥 هيا نبدأ يا بطل",
                                      style: AppTextStyles.blackFont.copyWith(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.grey.shade400,
                                      width: 2,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.white,
                                    backgroundImage: AssetImage(child!.avatar),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox.shrink();
                },
              ),
              //child progress
              Positioned(
                top: MediaQuery.of(context).size.height * 0.25,
                left: 230,
                right: 230,
                child: Container(
                  height: 45,
                  padding: const EdgeInsets.all(4), // المسافة بين الإطار والمحتوى
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppColors.primary, width: 4),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final barWidth = constraints.maxWidth;
                      final filledWidth = (barWidth * progress).clamp(
                        0.0,
                        barWidth,
                      );
                      const double imageSize = 90.0;

                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // الجزء المملوء من المؤشر (موقعه و اتساعه يعتمد على _progress)
                          Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            width: filledWidth,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                          ),

                          // الصورة توضع بدقة في نهاية الشريط المملوء
                          Positioned(
                            left: filledWidth - imageSize / 2,
                            top: (-imageSize - 15) / 2, // container height is 45
                            child: SizedBox(
                              width: imageSize,
                              height: imageSize,
                              child: Image.asset(
                                "assets/images/progress.png",
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              //button to start the game
              Positioned(
                top: MediaQuery.of(context).size.height * 0.5,
                left: MediaQuery.of(context).size.width * 0.5 - 50,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      childLevelsScreen,
                      arguments: child,
                    );
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.8),
                          AppColors.primary,
                          AppColors.primary.withOpacity(1.0),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        /// اضاءة بيضا فوق اليمين
                        BoxShadow(
                          color: Colors.white.withOpacity(0.9),
                          blurRadius: 15,
                          offset: const Offset(5, -5),
                        ),

                        /// ظل تحت اليسار
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(-5, 5),
                        ),

                        /// Glow عام
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        /// نقطة لمعان 1
                        Positioned(
                          top: 20,
                          right: 20,
                          child: Container(
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.5),
                                  blurRadius: 5,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),

                        /// نقطة لمعان 2
                        Positioned(
                          top: 35,
                          right: 15,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),

                        /// نقطة لمعان 3
                        Positioned(
                          bottom: 20,
                          left: 20,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),

                        /// علامة التشغيل
                        const Center(
                          child: Icon(
                            Icons.play_arrow_rounded,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
