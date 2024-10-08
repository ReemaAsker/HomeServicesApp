import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:home_services_app/cores/app_colors.dart';
import 'package:home_services_app/cores/models/user.dart';
import '../../logic/authLogic.dart';
import 'package:flutter_switch/flutter_switch.dart';

import '../../cores/custom_widgets/custom_app_bar.dart';
import '../../cores/custom_widgets/custom_button.dart';
import '../../cores/custom_widgets/custom_snackbar.dart';
import '../../cores/custom_widgets/custom_text_feild.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({
    super.key,
  });
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
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
  bool? yearScubscriber;
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
  ];

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

  @override
  void initState() {
    super.initState();
    // You can also initialize any other data if necessary here.
  }

  void updateUserInfo(AppUser user) {
    if (_formKey.currentState!.validate()) {
      _auth.updateUserData(user).then(
        (value) {
          value
              ? My_snackBar.showSnackBar(
                  context, "!تم تحديث البيانات بنجاح", Colors.green)
              : My_snackBar.showSnackBar(context, "حدث خطأ", Colors.red);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(30, 80),
        child: CustomAppBar(
          title: "الحساب",
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
            child: StreamBuilder<AppUser>(
                stream: _auth.getUserData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Icon(Icons.error, color: Colors.red);
                  } else if (snapshot.hasData) {
                    AppUser user = snapshot.data!;
                    // Initialize yearScubscriber only if it's null to avoid overwriting it every build.
                    if (yearScubscriber == null) {
                      yearScubscriber = user.isYearSubscriber;
                    }
                    usernameController.text = user.username;
                    ageController.text = user.age.toString();
                    emailController.text = user.email;
                    // If _selectedArea is null, initialize it with the user's area
                    if (_selectedArea == null) {
                      _selectedArea = user.area;
                    }

                    return Column(children: [
                      user.gender
                          ? user.isProvider
                              ? Image.asset(
                                  "assets/man_service.png",
                                  height: 200,
                                  width: 200,
                                )
                              : Image.asset(
                                  "assets/man_all.png",
                                  height: 200,
                                  width: 200,
                                )
                          : user.isProvider
                              ? Image.asset(
                                  "assets/housekeeper.png",
                                  height: 200,
                                  width: 200,
                                )
                              : Image.asset(
                                  "assets/women_all.png",
                                  height: 220,
                                  width: 220,
                                ),

                      Row(
                        children: [
                          Expanded(
                            child: // Username Field
                                Center(
                              child: CustomTextField(
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
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
                                labelText: "الاسم",
                              ),
                            ),
                          ),
                          // SizedBox(width: 75),
                          // Text('الاسم', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
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
                          ),
                          // SizedBox(width: 65),
                          // Text('الايميل', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                      SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
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
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      // Area Dropdown
                      Row(
                        children: [
                          Expanded(
                            child: Directionality(
                              textDirection: TextDirection
                                  .rtl, // This will make the arrow appear on the left
                              child: DropdownButtonFormField<String>(
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
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
                                      color:
                                          Colors.grey, // Default border color
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        10.0), // Rounded corners when focused
                                    borderSide: BorderSide(
                                      color: Colors
                                          .grey, // Border color when focused
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
                                    _selectedArea =
                                        newValue; // Update the selected area value
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
                          SizedBox(width: 60),
                          Text('المنطقة', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                      // Toggle switch for isYearSubscriber
                      SizedBox(height: 20),
                      !user.isProvider
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                FlutterSwitch(
                                  width: 100.0,
                                  height: 35.0,
                                  valueFontSize: 12.0,
                                  toggleSize: 20.0,
                                  value: yearScubscriber!,
                                  borderRadius: 10.0,
                                  padding: 8.0,
                                  activeText: "مفعل",
                                  inactiveText: "غير مفعل",
                                  activeTextColor: Colors.white,
                                  activeColor: Colors.green,
                                  inactiveColor: Colors.grey,
                                  showOnOff: true,
                                  onToggle: (val) {
                                    setState(() {
                                      yearScubscriber = val;
                                    });
                                  },
                                ),
                                SizedBox(width: 16),
                                Text('الاشتراك السنوي',
                                    style: TextStyle(fontSize: 14)),
                              ],
                            )
                          : Text(""),
                      SizedBox(height: 30),
                      CustomButton(
                        padding: 14.0,
                        text: 'تعديل البيانات',
                        onTap: () => updateUserInfo(AppUser(
                            username: usernameController.text.trim(),
                            email: emailController.text.trim(),
                            age: int.parse(ageController.text.trim()),
                            password: user.password,
                            isProvider: user.isProvider,
                            area: _selectedArea!,
                            isYearSubscriber: yearScubscriber!,
                            gender: user.gender)),
                      ),
                    ]);
                  } else {
                    return const Text('لم يتم تسجيل الدخول',
                        style: TextStyle(color: Colors.white));
                  }
                }),
          ),
        ),
      ),
    );
  }
}
