import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:home_services_app/cores/logic/firebaseLogic.dart';
import '../../../cores/custom_widgets/custom_app_bar.dart';
import '../../../cores/custom_widgets/custom_button.dart';
import '../../../cores/custom_widgets/custom_snackbar.dart';
import '../../../cores/custom_widgets/custom_text_feild.dart';
import '../../../cores/logic/firebaseLogic.dart';
import '../../../cores/models/user.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final  _auth = FirebaseServices();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // TextEditingControllers for the form fields
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool? _isYearSubscriber;
  String? _selectedArea;

  // Areas list for dropdown
  static const List<String> _areas = [
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

  @override
  void initState() {
    super.initState();
  }

  void _toggleYearSubscriber(bool value) {
    setState(() {
      _isYearSubscriber = value;
    });
  }

  void _updateUserInfo(AppUser user) {
    if (_formKey.currentState!.validate()) {
      _auth.updateUserData(user).then((success) {
        final message = success ? "!تم تحديث البيانات بنجاح" : "حدث خطأ";
        My_snackBar.showSnackBar(
            context, message, success ? Colors.green : Colors.red);
      });
    }
  }

  Widget _buildUserImage(AppUser user) {
    final imagePath = user.gender
        ? (user.isProvider ? "assets/man_service.png" : "assets/man_all.png")
        : (user.isProvider ? "assets/housekeeper.png" : "assets/women_all.png");

    return Image.asset(imagePath, height: 200, width: 200);
  }

  Widget _buildUsernameField() {
    return CustomTextField(
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      controller: _usernameController,
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
    );
  }

  Widget _buildEmailField() {
    return CustomTextField(
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      controller: _emailController,
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
    );
  }

  Widget _buildAgeField() {
    return CustomTextField(
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      controller: _ageController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'لا يمكن ترك حقل العمر فارغا';
        } else if (int.tryParse(value) == null || int.tryParse(value)! <= 0) {
          return 'الادخال خاطئ';
        } else if (int.tryParse(value)! <= 18) {
          return 'يجب ان يكون العمر اكبر من 18 سنة';
        }
        return null;
      },
      labelText: "العمر",
    );
  }

  Widget _buildAreaDropdown() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DropdownButtonFormField<String>(
        style: const TextStyle(
            color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.grey, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.grey, width: 1.0),
          ),
        ),
        isExpanded: true,
        alignment: Alignment.centerRight,
        value: _selectedArea,
        items: _areas.map((String area) {
          return DropdownMenuItem<String>(
            alignment: Alignment.centerRight,
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
    );
  }

  Widget _buildYearSubscriberToggle(bool isProvider) {
    return !isProvider
        ? Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FlutterSwitch(
                width: 100.0,
                height: 35.0,
                valueFontSize: 12.0,
                toggleSize: 20.0,
                value: _isYearSubscriber ?? false,
                borderRadius: 10.0,
                padding: 8.0,
                activeText: "مفعل",
                inactiveText: "غير مفعل",
                activeTextColor: Colors.white,
                activeColor: Colors.green,
                inactiveColor: Colors.grey,
                showOnOff: true,
                onToggle: _toggleYearSubscriber,
              ),
              const SizedBox(width: 16),
              const Text('الاشتراك السنوي', style: TextStyle(fontSize: 14)),
            ],
          )
        : const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size(30, 80),
        child: CustomAppBar(title: "الحساب"),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
            child: StreamBuilder<AppUser>(
              stream: _auth.getUserDataStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(
                      child: Icon(Icons.error, color: Colors.red));
                } else if (snapshot.hasData) {
                  final AppUser user = snapshot.data!;
                  _usernameController.text = user.username;
                  _emailController.text = user.email;
                  _ageController.text = user.age.toString();
                  _isYearSubscriber ??= user.isYearSubscriber;
                  _selectedArea ??= user.area;

                  return Column(
                    children: [
                      _buildUserImage(user),
                      const SizedBox(height: 10),
                      _buildUsernameField(),
                      const SizedBox(height: 10),
                      _buildEmailField(),
                      const SizedBox(height: 10),
                      _buildAgeField(),
                      const SizedBox(height: 10),
                      _buildAreaDropdown(),
                      const SizedBox(height: 20),
                      _buildYearSubscriberToggle(user.isProvider),
                      const SizedBox(height: 30),
                      CustomButton(
                        padding: 14.0,
                        text: 'تعديل البيانات',
                        onTap: () => _updateUserInfo(AppUser(
                          username: _usernameController.text.trim(),
                          email: _emailController.text.trim(),
                          age: int.parse(_ageController.text.trim()),
                          password: user.password,
                          isProvider: user.isProvider,
                          area: _selectedArea!,
                          isYearSubscriber: _isYearSubscriber!,
                          gender: user.gender,
                        )),
                      ),
                    ],
                  );
                } else {
                  return const Center(
                    child: Text("No data found."),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
