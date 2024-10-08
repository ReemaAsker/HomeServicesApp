import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../feature/auth/login_screen.dart';
import '../../logic/authLogic.dart';
import '../app_colors.dart';
import '../models/user.dart';

class CustomAppBar extends StatefulWidget {
  final String? title;
  const CustomAppBar({super.key, required this.title});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  final _auth = AuthService();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUser>(
      stream: _auth.getUserDataStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(80),
              child: AppBar(
                title: CircularProgressIndicator(),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Icon(Icons.error, color: Colors.red),
            ),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else if (snapshot.hasData) {
          AppUser user = snapshot.data!;

          return AppBar(
            centerTitle: true,
            toolbarHeight: 80,
            backgroundColor: user.isYearSubscriber
                ? Colors.amber // Golden color for year subscribers
                : AppColors.primaryColor, // Default color
            leading: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: InkWell(
                onTap: () {
                  _auth.SignOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LogInScreen()),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(3.1416),
                      child: Icon(
                        Icons.logout,
                        color: user.isYearSubscriber
                            ? AppColors.secoundaryColor
                            : Colors.amber,
                        size: 20,
                      ),
                    ),
                    Text(
                      "تسجيل الخروج",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: user.isYearSubscriber
                              ? AppColors.secoundaryColor
                              : Colors.amber),
                    )
                  ],
                ),
              ),
            ),
            title: widget.title == null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                ' ${user.username}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: user.isYearSubscriber
                                        ? AppColors.secoundaryColor
                                        : Colors.amber),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                ' ! أُهلاً بك',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: user.gender
                            ? user.isProvider
                                ? Image.asset(
                                    "assets/man_service.png",
                                    height: 80,
                                    width: 80,
                                  )
                                : Image.asset("assets/man.png",
                                    height: 60, width: 60)
                            : user.isProvider
                                ? Image.asset(
                                    "assets/housekeeper.png",
                                    height: 60,
                                    width: 60,
                                  )
                                : Image.asset("assets/women.png",
                                    height: 80, width: 80),
                      ),
                    ],
                  )
                : Text(
                    widget.title!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: user.isYearSubscriber
                          ? AppColors.secoundaryColor
                          : Colors.amber,
                    ),
                  ),
          );
        } else {
          return AppBar(
            title: Text('لم يتم تسجيل الدخول',
                style: TextStyle(color: Colors.white)),
          );
        }
      },
    );
  }
}
