import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:home_services_app/cores/app_colors.dart';
import 'package:home_services_app/cores/custom_widgets/custom_app_bar.dart';
import 'package:home_services_app/cores/models/user.dart';
import 'package:home_services_app/feature/mainUi/UserScreens/account_screen.dart';

import '../../../cores/custom_widgets/providerCard.dart';
import '../../../cores/custom_widgets/rating_widget.dart';
import '../../../cores/logic/authLogic.dart';

class ProviderHomePage extends StatefulWidget {
  @override
  _ProviderHomePageState createState() => _ProviderHomePageState();
}

class _ProviderHomePageState extends State<ProviderHomePage> {
  int _currentIndex = 0;
  final _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getSelectedPage(_currentIndex), // Select the appropriate page
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: AppColors.primaryColor,
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index; // Update the current index
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'الحساب'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
        ],
      ),
    );
  }

  // Method to switch between the selected pages
  Widget _getSelectedPage(int index) {
    switch (index) {
      case 0:
        return AccountScreen();
      case 1:
        return mainPageContent();
      default:
        return mainPageContent(); // Main page is the default
    }
  }

// Main page content (index 2)
  Widget mainPageContent() {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: CustomAppBar(title: null),
      ),
      body: Center(
        child: StreamBuilder<AppUser>(
          stream: _auth.getUserDataStream(), // Get user data stream
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (userSnapshot.hasError) {
              return Center(child: Text('Error: ${userSnapshot.error}'));
            }

            if (userSnapshot.hasData && userSnapshot.data != null) {
              AppUser user = userSnapshot.data!;

              // Get the providers that the current user has
              return StreamBuilder<List<String>>(
                stream: _auth
                    .getRequestsForCurrentProvider(), // Get the current user's User IDs
                builder: (context, providerIdsSnapshot) {
                  if (providerIdsSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (providerIdsSnapshot.hasError) {
                    return Center(
                        child: Text('Error: ${providerIdsSnapshot.error}'));
                  }
                  final currentProviderUsersIds = providerIdsSnapshot.data;
                  // Fetch providers based on user area
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('User')
                        .where('isProvider', isEqualTo: false)
                        .snapshots(),
                    builder: (context, providersSnapshot) {
                      if (providersSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (providersSnapshot.hasError) {
                        return Center(
                            child: Text('Error: ${providersSnapshot.error}'));
                      }

                      // Get all Users and filter based on currentProviderUsersIds
                      final allUsers = providersSnapshot.data?.docs
                          .map((doc) => AppUser.fromFirestore(doc))
                          .toList()
                          .where((user) =>
                              currentProviderUsersIds!.contains(user.id))
                          .toList();

                      return Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                DisplayRating(
                                  userId:
                                      FirebaseAuth.instance.currentUser!.uid,
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  " :تقييمك ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: AppColors.primaryColor),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Divider(),
                            Expanded(
                              child: ListView.builder(
                                itemCount: allUsers!.length,
                                itemBuilder: (context, index) {
                                  return ProviderCard(
                                    user: allUsers[index],
                                    currentUserEmail: user.email,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            } else {
              return const Center(child: Text('User not logged in'));
            }
          },
        ),
      ),
    );
  }
}
