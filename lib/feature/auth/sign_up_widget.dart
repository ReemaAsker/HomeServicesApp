import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:home_services_app/cores/models/user.dart';
import 'package:home_services_app/feature/auth/login_screen.dart';

import '../../cores/custom_widgets/custom_button.dart';
import '../../cores/custom_widgets/custom_snackbar.dart';
import '../../cores/custom_widgets/custom_text_feild.dart';
import '../../cores/logic/authLogic.dart';

class SignUpWidget extends StatefulWidget {
  @override
  _MyFormWidgetState createState() => _MyFormWidgetState();
}

class _MyFormWidgetState extends State<SignUpWidget> {
  final _auth = AuthService();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpasswordController =
      TextEditingController();
  final TextEditingController serviceDescriptionController =
      TextEditingController();
  final TextEditingController servicePriceController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String _selectedRole = 'عميل';
  String _selectedGender = 'ذكر';
  String? _selectedArea;
  List<String> _areas = [
    'الرياض',
    'مكة المكرمة',
    'المدينة المنورة',
    'المنطقة الشرقية',
    'عسير',
    'الباحة',
    'حائل',
    'الجوف',
    'تبوك',
    'نجران',
    'جازان',
    'القصيم',
    'الحدود الشمالية'
  ]; // Sample area list

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    });
  }

  void signup() async {
    if (_formKey.currentState!.validate()) {
      if (passwordController.value.toString() ==
          confirmpasswordController.value.toString()) {
        final user = await _auth.createUser(AppUser(
            username: usernameController.text.trim(),
            email: emailController.text.trim(),
            age: int.parse(ageController.text.trim()),
            password: passwordController.text.trim(),
            isProvider: _selectedRole == 'مزود خدمة',
            gender: _selectedGender == 'ذكر',
            isYearSubscriber: false,
            // ratingReview: 0,
            serviceDescription: serviceDescriptionController.text.trim(),
            servicePrice: servicePriceController.text.trim().isEmpty
                ? -1
                : double.parse(servicePriceController.text.trim()),
            area: _selectedArea!));
        if (user == null) {
          My_snackBar.showSnackBar(
              context, "هذا الحساب موجود مسبقا", Colors.red);
        } else if (user == "success") {
          My_snackBar.showSnackBar(
              context, "تم انشاء الحساب بنجاح", Colors.green);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LogInScreen()),
          );
        } else if (user == "failed") {
          My_snackBar.showSnackBar(
              context, "حدثت مشكلة اثناء انشاء الحساب", Colors.red);
        }
      } else {
        My_snackBar.showSnackBar(
            context, "تأكد من تطابق كلمة المرور ", Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
              child: Column(
                children: [
                  _selectedRole == 'مزود خدمة'
                      ? Image.asset(
                          "assets/appIcon.png",
                          height: 150,
                          width: 150,
                        )
                      : Image.asset(
                          "assets/client.png",
                          width: 200,
                          height: 200,
                        ),

                  // Username Field
                  CustomTextField(
                    controller: usernameController,
                    autofillHints: const [AutofillHints.name],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'لا يمكن ترك حقل اسم المستخدم فارغا';
                      } else if (value.length < 3) {
                        return "اسم المستخدم يجب الا يقل عن 3 حروف";
                      }
                      return null;
                    },
                    labelText: "اسم المستخدم",
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  // Email Field
                  CustomTextField(
                    controller: emailController,
                    autofillHints: const [AutofillHints.email],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يجب ان لا يكون حقل الايميل فارغا';
                      } else if (!EmailValidator.validate(value)) {
                        return 'ادخل ايميل صحيح';
                      }
                      return null;
                    },
                    labelText: "الايميل",
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  // Age Field
                  CustomTextField(
                    controller: ageController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'لا يمكن ترك حقل العمر فارغا';
                      } else if (int.tryParse(value) == null ||
                          int.tryParse(value)! <= 0) {
                        return 'الادخال خاطئ';
                      } else if (int.tryParse(value)! <= 18) {
                        return 'يجب ان يكون العمر اكبر من 18 سنة';
                      }
                      return null;
                    },
                    labelText: "العمر",
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  // Password Field
                  CustomTextField(
                    controller: passwordController,
                    autofillHints: const [AutofillHints.password],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'لا يمكن ترك حقل كلمة المرور فارغا';
                      } else if (value.length < 6) {
                        return 'يحب ان تكون كلمة المرور مكونة عالاقل من 6 خانات';
                      }
                      return null;
                    },
                    labelText: "كلمة المرور",
                    obscureText: !_isPasswordVisible,
                    suffixIcon: GestureDetector(
                      onTap: _togglePasswordVisibility,
                      child: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  // Confirm Password Field
                  CustomTextField(
                    controller: confirmpasswordController,
                    autofillHints: const [AutofillHints.password],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'لا يمكن ترك حقل كلمة المرور فارغا';
                      } else if (value.length < 6) {
                        return 'يحب ان تكون كلمة المرور مكونة عالاقل من 6 خانات';
                      }
                      return null;
                    },
                    labelText: "تأكيد كلمة المرور",
                    obscureText: !_isConfirmPasswordVisible,
                    suffixIcon: GestureDetector(
                      onTap: _toggleConfirmPasswordVisibility,
                      child: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 10,
                  ),
                  // gender Selection ( ذكر / انثى)
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('أنثى'),
                            Radio<String>(
                              value: 'أنثى',
                              groupValue: _selectedGender,
                              onChanged: (value) {
                                setState(() {
                                  _selectedGender = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('ذكر'),
                            Radio<String>(
                              value: 'ذكر',
                              groupValue: _selectedGender,
                              onChanged: (value) {
                                setState(() {
                                  _selectedGender = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '      الجنس',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  // Role Selection (مزود خدمة / عميل)
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('عميل'),
                            Radio<String>(
                              value: 'عميل',
                              groupValue: _selectedRole,
                              onChanged: (value) {
                                setState(() {
                                  _selectedRole = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('مزود خدمة'),
                            Radio<String>(
                              value: 'مزود خدمة',
                              groupValue: _selectedRole,
                              onChanged: (value) {
                                setState(() {
                                  _selectedRole = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'نوع المستخدم',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  // Area Dropdown
                  Row(
                    children: [
                      Expanded(
                        child: Directionality(
                          textDirection: TextDirection
                              .rtl, // This will make the arrow appear on the left
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 25.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    10.0), // Rounded corners
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    10.0), // Rounded corners when not focused
                                borderSide: BorderSide(
                                  color: Colors.grey, // Default border color
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    10.0), // Rounded corners when focused
                                borderSide: BorderSide(
                                  color:
                                      Colors.grey, // Border color when focused
                                  width: 1.0,
                                ),
                              ),
                            ),
                            isExpanded:
                                true, // Ensures the value text doesn't get clipped
                            alignment: Alignment
                                .centerRight, // Align the selected value text to the right
                            value: _selectedArea,
                            items: _areas.map((String area) {
                              return DropdownMenuItem<String>(
                                alignment: Alignment
                                    .centerRight, // Align items to the right
                                value: area,
                                child: Text(area),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _selectedArea = newValue;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'الرجاء اختيار منطقة';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 40),
                      Text(
                        'المنطقة',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  // Conditionally show service fields if 'مزود خدمة' is selected
                  if (_selectedRole == 'مزود خدمة') ...[
                    CustomTextField(
                        controller: serviceDescriptionController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'يجب إدخال نوع الخدمة';
                          }
                          return null;
                        },
                        labelText: ' نوع الخدمة' + '(ميكانيكي , سباك ,..) '),
                    SizedBox(
                      height: 10,
                    ),
                    CustomTextField(
                      controller: servicePriceController,
                      labelText: 'سعر الخدمة بالريال السعودي',
                      // keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يجب إدخال سعر الخدمة';
                        } else if (double.tryParse(value) == null) {
                          return 'الرجاء إدخال رقم صحيح';
                        } else if (double.tryParse(value)! <= 0) {
                          return 'السعر المدخل غير مسموح به';
                        }
                        return null;
                      },
                    ),
                  ],
                  SizedBox(
                    height: 20,
                  ),
                  // Submit Button
                  CustomButton(
                    padding: 14.0,
                    text: 'انشاء حساب جديد',
                    onTap: signup,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
