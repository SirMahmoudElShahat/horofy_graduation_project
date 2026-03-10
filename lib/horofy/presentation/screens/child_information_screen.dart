import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horofy/core/style/app_colors.dart';
import 'package:horofy/core/style/font_style.dart';
import 'package:horofy/horofy/domain/entities/child_entity.dart';
import 'package:horofy/horofy/presentation/cubit/child_cubit.dart';
import 'package:horofy/horofy/presentation/cubit/child_state.dart';
import 'package:horofy/horofy/presentation/widgets/custom_button.dart';

class ChildInformationScreen extends StatefulWidget {
  const ChildInformationScreen({super.key});

  @override
  State<ChildInformationScreen> createState() => _ChildInformationScreenState();
}

class _ChildInformationScreenState extends State<ChildInformationScreen> {
  final _images = [
    'assets/images/child/avater1.jpg',
    'assets/images/child/avater2.jpg',
    'assets/images/child/avater3.jpg',
    'assets/images/child/avater4.jpg',
    'assets/images/child/avater5.jpg',
    'assets/images/child/avater6.jpg',
    'assets/images/child/avater7.jpg',
    'assets/images/child/avater8.jpg',
  ];
  DateTime? selectedDate;
  final TextEditingController dateController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  int selectedGender = -1; // 0 for girl, 1 for boy
  int selectedAvatar = -1;
  ChildEntity? editingChild;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (editingChild == null) {
      final arg = ModalRoute.of(context)?.settings.arguments;
      if (arg is ChildEntity) {
        editingChild = arg;
        nameController.text = editingChild!.name;
        dateController.text = editingChild!.birthDate;
        // try parse birth date formatted as dd/MM/yyyy
        try {
          final parts = editingChild!.birthDate.split('/');
          if (parts.length == 3) {
            final day = int.tryParse(parts[0]);
            final month = int.tryParse(parts[1]);
            final year = int.tryParse(parts[2]);
            if (day != null && month != null && year != null) {
              selectedDate = DateTime(year, month, day);
            }
          }
        } catch (_) {}
        selectedGender = editingChild!.gender;
        selectedAvatar = _images.indexOf(editingChild!.avatar);
        setState(() {});
      }
    }
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const SizedBox(height: 80),
        Center(child: Image.asset('assets/images/login.png')),
        const SizedBox(height: 80),
        Text(
          editingChild == null ? 'ٳضافة طفل جديد' : 'تعديل الطفل',
          style: AppTextStyles.blackFont.copyWith(fontSize: 24),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'ٳسم الطفل',
            style: AppTextStyles.blackFont,
            textAlign: TextAlign.right,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 10, bottom: 20),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(25),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: TextField(
            controller: nameController,
            keyboardType: TextInputType.emailAddress,
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              hintText: 'محمود',
              hintStyle: AppTextStyles.greyFont,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'تاريخ الميلاد',
            style: AppTextStyles.blackFont,
            textAlign: TextAlign.right,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 10, bottom: 20),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(25),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: TextField(
            controller: dateController,
            readOnly: true,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: '01/01/2000',
              hintStyle: AppTextStyles.greyFont,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
              prefixIcon: const Icon(Icons.calendar_today, color: Colors.black),
            ),
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                locale: const Locale('ar'),
                initialDate: selectedDate ?? DateTime(2000),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );

              if (pickedDate != null) {
                setState(() {
                  selectedDate = pickedDate;
                  dateController.text =
                      "${pickedDate.day.toString().padLeft(2, '0')}/"
                      "${pickedDate.month.toString().padLeft(2, '0')}/"
                      "${pickedDate.year}";
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'الجنس',
            style: AppTextStyles.blackFont,
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: selectedGender == 0
                    ? Border.all(color: Colors.black, width: 2)
                    : null,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: AppColors.background,
                  overlayColor: Colors.transparent,
                  minimumSize: const Size(150, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    if (selectedGender != 0) {
                      selectedAvatar = -1;
                    }
                    selectedGender = 0;
                  });
                },
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/child/girl.png',
                      fit: BoxFit.contain,
                      width: 40,
                      height: 40,
                    ),
                    const SizedBox(width: 40),
                    Text(
                      'بنت',
                      style: AppTextStyles.blackFont.copyWith(fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: selectedGender == 1
                    ? Border.all(color: Colors.black, width: 2)
                    : null,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: AppColors.background,
                  overlayColor: Colors.transparent,
                  minimumSize: const Size(150, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    if (selectedGender != 1) {
                      selectedAvatar = -1;
                    }
                    selectedGender = 1;
                  });
                },
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/child/boy.png',
                      fit: BoxFit.cover,
                      width: 40,
                      height: 40,
                    ),
                    const SizedBox(width: 40),
                    Text(
                      'ولد',
                      style: AppTextStyles.blackFont.copyWith(fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAvatarGrid() {
    if (selectedGender == -1) return const SizedBox.shrink();

    final List<String> genderSpecificImages;
    final int avatarIndexOffset;

    if (selectedGender == 0) {
      // Girl avatars (first 4)
      genderSpecificImages = _images.sublist(0, 4);
      avatarIndexOffset = 0;
    } else {
      // Boy avatars (last 4)
      genderSpecificImages = _images.sublist(4);
      avatarIndexOffset = 4;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerRight,
          child: const Text(
            'ٳختار صورة',
            style: AppTextStyles.blackFont,
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(height: 10),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: List.generate(genderSpecificImages.length, (index) {
            final globalIndex = index + avatarIndexOffset;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedAvatar = globalIndex;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selectedAvatar == globalIndex
                        ? Colors.black
                        : Colors.grey.shade400,
                    width: selectedAvatar == globalIndex ? 4 : 1,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(genderSpecificImages[index], fit: BoxFit.cover),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return CustomButton(
      text: editingChild == null ? 'ٳضافة' : 'تعديل',
      onPressed: () {
        // basic checks
        if (nameController.text.isEmpty ||
            dateController.text.isEmpty ||
            selectedGender == -1 ||
            selectedAvatar == -1) {
          _showSnackBar(
            context,
            'تنبيه',
            'يرجى إكمال جميع البيانات',
            isError: true,
          );
          return;
        }

        // name must be a single Arabic word (no spaces, Arabic letters only)
        final name = nameController.text.trim();
        final arabicSingleWord = RegExp(r'^[\u0600-\u06FF]+$');
        if (!arabicSingleWord.hasMatch(name)) {
          _showSnackBar(
            context,
            'تنبيه',
            'الاسم يجب أن يكون كلمة واحدة',
            isError: true,
          );
          return;
        }

        // date must be selected
        if (selectedDate == null) {
          _showSnackBar(
            context,
            'تنبيه',
            'يرجى اختيار تاريخ الميلاد',
            isError: true,
          );
          return;
        }

        // compute age from account creation date (using now())
        final now = DateTime.now();
        int age = now.year - selectedDate!.year;
        if (now.month < selectedDate!.month ||
            (now.month == selectedDate!.month && now.day < selectedDate!.day)) {
          age -= 1;
        }

        if (age < 4 || age > 12) {
          _showSnackBar(
            context,
            'تنبيه',
            'يجب أن يكون عمر الطفل بين 4 و 12 سنة',
            isError: true,
          );
          return;
        }

        final child = ChildEntity(
          id: editingChild?.id,
          name: name,
          birthDate: dateController.text,
          gender: selectedGender,
          avatar: _images[selectedAvatar],
          level: editingChild?.level ?? 'level1',
        );

        if (editingChild == null) {
          context.read<ChildCubit>().addNewChild(child);
        } else {
          context.read<ChildCubit>().updateChild(child);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // UI builds; editingChild is populated in didChangeDependencies

    return BlocListener<ChildCubit, ChildState>(
      listener: (context, state) {
        if (state is ChildAddSuccess) {
          _showSnackBar(context, 'تم', 'تم إضافة الطفل بنجاح', isError: false);
          Navigator.pop(context);
        } else if (state is ChildAddError) {
          _showSnackBar(context, 'خطأ', state.message);
        } else if (state is ChildUpdateSuccess) {
          _showSnackBar(
            context,
            'تم',
            'تم تعديل بيانات الطفل بنجاح',
            isError: false,
          );
          Navigator.pop(context);
        } else if (state is ChildUpdateError) {
          _showSnackBar(context, 'خطأ', state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildHeader(),
                _buildNameField(),
                _buildDateField(),
                _buildGenderSelector(),
                _buildAvatarGrid(),
                const SizedBox(height: 40),
                _buildSubmitButton(),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(
    BuildContext context,
    String title,
    String message, {
    bool isError = true,
  }) {
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
