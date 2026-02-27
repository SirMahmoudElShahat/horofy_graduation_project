import 'package:flutter/material.dart';
import 'package:horofy/core/style/app_colors.dart';
import 'package:horofy/core/style/font_style.dart';
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
  int selectedGender = -1; // 0 for girl, 1 for boy
  int selectedAvatar = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              Center(child: Image.asset('assets/images/login.png')),
              const SizedBox(height: 80),
              Text(
                'ٳضافة طفل جديد',
                style: AppTextStyles.blackFont.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 40),
              //child name field
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: TextField(
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: 'محمود',
                    hintStyle: AppTextStyles.greyFont,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                  ),
                ),
              ),
              //child birth date field
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
                    suffixIcon: const Icon(
                      Icons.calendar_today,
                      color: Colors.grey,
                    ),
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
              //child gender field
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
                          selectedGender = 1;
                        });
                      },
                      child: Row(
                        children: [
                          Text(
                            'ولد',
                            style: AppTextStyles.blackFont.copyWith(
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Image.asset(
                            'assets/images/child/boy.png',
                            fit: BoxFit.cover,
                            width: 40,
                            height: 40,
                          ),
                        ],
                      ),
                    ),
                  ),
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
                          selectedGender = 0;
                        });
                      },
                      child: Row(
                        children: [
                          Text(
                            'بنت',
                            style: AppTextStyles.blackFont.copyWith(
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Image.asset(
                            'assets/images/child/girl.png',
                            fit: BoxFit.contain,
                            width: 40,
                            height: 40,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              //child image field
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'ٳختار صورة',
                  style: AppTextStyles.blackFont,
                  textAlign: TextAlign.right,
                ),
              ),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: List.generate(_images.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedAvatar = index;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selectedAvatar == index
                              ? Colors.black
                              : Colors.grey.shade400,
                          width: selectedAvatar == index ? 4 : 1,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(_images[index], fit: BoxFit.cover),
                      ),
                    ),
                  );
                }),
              ),
              //submit button
              const SizedBox(height: 40),
              CustomButton(text: 'ٳضافة', onPressed: () {}),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
