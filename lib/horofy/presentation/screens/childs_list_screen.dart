import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horofy/core/constants/strings.dart';
import 'package:horofy/core/constants/levels.dart';
import 'package:horofy/core/style/app_colors.dart';
import 'package:horofy/core/style/font_style.dart';
import 'package:horofy/core/widgets/loading_widget.dart';
import 'package:horofy/horofy/domain/entities/child_entity.dart';
import 'package:horofy/horofy/presentation/cubit/child_cubit.dart';
import 'package:horofy/horofy/presentation/cubit/child_state.dart';

class ChildsListScreen extends StatefulWidget {
  const ChildsListScreen({super.key});

  @override
  State<ChildsListScreen> createState() => _ChildsListScreenState();
}

class _ChildsListScreenState extends State<ChildsListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ChildCubit>().loadChildren();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'قائمة الأطفال',
          style: AppTextStyles.blackFont.copyWith(fontSize: 24),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, childInformationScreen).then((_) {
            if (mounted) {
              context.read<ChildCubit>().loadChildren();
            }
          });
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocConsumer<ChildCubit, ChildState>(
        listener: (context, state) {
          if (state is ChildDeleteSuccess) {
            _showSnackBar(context, 'تم', 'تم حذف الطفل بنجاح', isError: false);
          } else if (state is ChildDeleteError) {
            _showSnackBar(context, 'خطأ', state.message, isError: true);
          }
        },
        builder: (context, state) {
          if (state is ChildLoading || state is ChildDeleteLoading) {
            return const LoadingWidget(fullScreen: true);
          } else if (state is ChildLoaded) {
            if (state.children.isEmpty) {
              return _buildEmptyState();
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: state.children.length,
              itemBuilder: (context, index) {
                return _buildChildCard(state.children[index]);
              },
            );
          } else if (state is ChildAddError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/login.png', height: 150),
          const SizedBox(height: 20),
          Text(
            'لا يوجد أطفال مضافين حاليا',
            style: AppTextStyles.blackFont.copyWith(fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildChildCard(ChildEntity child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            children: [
              Icon(
                child.gender == 1 ? Icons.male : Icons.female,
                color: child.gender == 1 ? Colors.blue : Colors.pink,
                size: 28,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  InkWell(
                    onTap: () => _confirmDelete(child),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.delete, color: Colors.red, size: 20),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () async {
                      await Navigator.pushNamed(
                        context,
                        childInformationScreen,
                        arguments: child,
                      );
                      if (mounted) {
                        context.read<ChildCubit>().loadChildren();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.edit, color: Colors.orange, size: 20),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  child.name,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.blackFont.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  levelEnToArabic(child.level),
                  style: AppTextStyles.greyFont.copyWith(
                    fontSize: 14,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      child.birthDate,
                      style: AppTextStyles.greyFont.copyWith(fontSize: 14),
                    ),
                    const SizedBox(width: 5),
                    Icon(Icons.cake_outlined, size: 18, color: Colors.grey.shade600),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Theme.of(context).primaryColor, width: 2),
            ),
            child: CircleAvatar(
              radius: 35,
              backgroundImage: AssetImage(child.avatar),
              backgroundColor: Colors.grey.shade100,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(ChildEntity child) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'حذف الطفل',
            style: TextStyle(color: Color(0xFFE57373), fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Text(
            'هل أنت متأكد من حذف ${child.name}؟',
            style: const TextStyle(color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBF8FFE),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: const Text('إلغاء', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (child.id != null) {
                      context.read<ChildCubit>().deleteChild(child.id!);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE57373),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: const Text('حذف', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(BuildContext context, String title, String message, {bool isError = true}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError
          ? Colors.redAccent.withOpacity(0.9)
          : Colors.green.withOpacity(0.9),
      colorText: Theme.of(context).cardColor,
      icon: Icon(
        isError ? Icons.warning_amber_rounded : Icons.check_circle_outline,
        color: Theme.of(context).cardColor,
      ),
    );
  }
}