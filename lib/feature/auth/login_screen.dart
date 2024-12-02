import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:home_services_app/cores/logic/firebaseLogic.dart';
import 'package:home_services_app/feature/auth/sign_up_widget.dart';

import '../../cores/app_colors.dart';
import '../../cores/custom_widgets/custom_button.dart';
import '../../cores/custom_widgets/custom_snackbar.dart';
import '../../cores/custom_widgets/custom_text_feild.dart';
import '../mainUi/UserScreens/homePage.dart';
import '../mainUi/providerScreens/provider_home_page.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final _auth = FirebaseServices();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void login() async {
    if (_formKey.currentState!.validate()) {
      final user =
          await _auth.login(emailController.text, passwordController.text);
      if (user != null) {
        if (user) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ProviderHomePage()),
          );
        }
      } else if (user == null) {
        My_snackBar.showSnackBar(
            context,
            "(تأكد من معلومات التسجيل) حدث خطأ (هذا الحساب غير موجود) أو ",
            Colors.red);
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
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 65),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset("assets/appIcon.png"),
                  SizedBox(height: 50),
                  CustomTextField(
                    controller: emailController,
                    labelText: "الايميل",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'لا يمكن ترك الحقل فارغا';
                      } else if (!EmailValidator.validate(value)) {
                        return 'من فضلك , ادخل ايميل صحيح';
                      }
                      return null;
                    },
                    suffixIcon: Icon(Icons.email),
                  ),
                  SizedBox(height: 20),
                  CustomTextField(
                    controller: passwordController,
                    labelText: "كلمة المرور",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'لا يمكن ترك الحقل فارغا';
                      } else if (value.length < 6) {
                        return 'يجب ان لاتقل كلمة المرور عن 5 خانات';
                      }
                      return null;
                    },
                    suffixIcon: Icon(Icons.password),
                  ),
                  SizedBox(height: 70),
                  CustomButton(
                    padding: 14.0,
                    text: 'تسجيل الدخول',
                    onTap: () => login(),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignUpWidget()),
                            );
                          },
                          child: Text(
                            " انشاء حساب جديد",
                            style: TextStyle(color: AppColors.primaryColor),
                          ),
                        ),
                        Text(" :ليس لديك حساب  "),
                      ],
                    ),
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
