import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horofy/core/constants/levels.dart';
import 'package:horofy/core/constants/strings.dart';
import 'package:horofy/core/style/font_style.dart';
import 'package:horofy/horofy/presentation/widgets/custom_button.dart';
import 'package:horofy/horofy/presentation/cubit/child_cubit.dart';
import 'package:horofy/horofy/domain/entities/child_entity.dart';

class ChildLevelsScreen extends StatefulWidget {
  const ChildLevelsScreen({super.key});

  @override
  State<ChildLevelsScreen> createState() => _ChildLevelsScreenState();
}

class _ChildLevelsScreenState extends State<ChildLevelsScreen> {
  ChildEntity? child;
  String currentLevelEn = 'level1';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    final c = arg is ChildEntity ? arg : null;
    if (c != null) {
      child = c;
      currentLevelEn = c.level;
    }
  }

  Future<void> _skipLevel() async {
    if (child == null || child!.id == null) return;
    final lvl = currentLevelEn;
    int num = 1;
    if (lvl.startsWith('level')) {
      final parsed = int.tryParse(lvl.replaceFirst('level', ''));
      if (parsed != null) num = parsed;
    }
    if (num >= 7) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('لا يوجد مستوى أعلى')));
      return;
    }

    final next = num + 1;
    final nextEn = 'level$next';

    try {
      await context.read<ChildCubit>().updateLevel(child!.id!, nextEn);
      setState(() {
        currentLevelEn = nextEn;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم الترقية إلى ${levelEnToArabic(nextEn)}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في التحديث')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = levelEnToArabic(currentLevelEn);

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/child_background.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 25,
            right: 10,
            child: TextButton(
              onPressed: _skipLevel,
              child: const Text("تخطى", style: AppTextStyles.greyFont),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 250),
            child: Center(
              child: CustomButton(
                text: displayName,
                onPressed: () {
                  Navigator.pushNamed(context, level1ListenScreen);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
