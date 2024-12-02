import 'package:flutter/material.dart';

import 'package:home_services_app/cores/logic/firebaseLogic.dart';

import '../../feature/auth/login_screen.dart';
import '../app_colors.dart';
import '../models/user.dart';

class CustomAppBar extends StatefulWidget {
  final String? title;
  final bool withReturnArrow;

  CustomAppBar({
    Key? key,
    this.title,
    this.withReturnArrow = false,
  }) : super(key: key);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  final _auth = FirebaseServices();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUser>(
      stream: _auth.getUserDataStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingAppBar();
        } else if (snapshot.hasError) {
          return _buildErrorAppBar(snapshot.error);
        } else if (snapshot.hasData) {
          AppUser user = snapshot.data!;
          return _buildMainAppBar(user);
        } else {
          return _buildNotLoggedInAppBar();
        }
      },
    );
  }

  AppBar _buildLoadingAppBar() {
    return AppBar(
      title: const CircularProgressIndicator(),
      toolbarHeight: 80,
    );
  }

  AppBar _buildErrorAppBar(dynamic error) {
    return AppBar(
      title: const Icon(Icons.error, color: Colors.red),
      actions: [Center(child: Text('Error: $error'))],
    );
  }

  AppBar _buildMainAppBar(AppUser user) {
    return AppBar(
      actions: [
        widget.withReturnArrow
            ? IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.keyboard_arrow_right_outlined,
                  size: 30,
                ),
                color: Colors.white,
              )
            : Text('')
      ],
      centerTitle: true,
      toolbarHeight: 80,
      backgroundColor:
          user.isYearSubscriber ? Colors.amber : AppColors.primaryColor,
      leading: _buildLogoutButton(user),
      title:
          widget.title == null ? _buildUserGreeting(user) : _buildTitle(user),
    );
  }

  InkWell _buildLogoutButton(AppUser user) {
    return InkWell(
      onTap: () {
        _auth.signOut();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LogInScreen()),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0),
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
                    : Colors.white,
                size: 20,
              ),
            ),
            Text(
              "تسجيل الخروج",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: user.isYearSubscriber
                    ? AppColors.secoundaryColor
                    : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Row _buildUserGreeting(AppUser user) {
    return Row(
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
                        : Colors.amber,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(' ! أُهلاً بك',
                    style: TextStyle(color: Colors.white)),
              ],
            ),
          ],
        ),
        const SizedBox(width: 10),
        Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: _buildUserImage(user),
        ),
      ],
    );
  }

  Image _buildUserImage(AppUser user) {
    String imagePath = user.gender
        ? (user.isProvider ? "assets/man_service.png" : "assets/man.png")
        : (user.isProvider ? "assets/housekeeper.png" : "assets/women.png");
    return Image.asset(imagePath,
        height: user.gender ? 80 : 60, width: user.gender ? 80 : 60);
  }

  Text _buildTitle(AppUser user) {
    return Text(
      widget.title!,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: user.isYearSubscriber ? AppColors.secoundaryColor : Colors.white,
      ),
    );
  }

  AppBar _buildNotLoggedInAppBar() {
    return AppBar(
      title: const Text('لم يتم تسجيل الدخول',
          style: TextStyle(color: Colors.white)),
    );
  }
}
