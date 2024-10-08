// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:home_services_app/feature/auth/authLogic.dart';

// import '../../cores/custom_widgets/custom_app_bar.dart';
// import '../../cores/custom_widgets/providerCard.dart';
// import '../../cores/models/user.dart';

// class ProviderHomePage extends StatefulWidget {
//   const ProviderHomePage({super.key});

//   @override
//   State<ProviderHomePage> createState() => _ProviderHomePageState();
// }

// class _ProviderHomePageState extends State<ProviderHomePage> {
//   final _auth = AuthService();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(80),
//         child: CustomAppBar(title: null),
//       ),
//       body: Center(
//         child: StreamBuilder<AppUser>(
//           stream: _auth.getUserDataStream(), // Get user data stream
//           builder: (context, userSnapshot) {
//             if (userSnapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             if (userSnapshot.hasError) {
//               return Center(child: Text('Error: ${userSnapshot.error}'));
//             }

//             if (userSnapshot.hasData && userSnapshot.data != null) {
//               AppUser user = userSnapshot.data!;
//               String userArea = user.area ?? ""; // Get user area

//               // Get the providers that the current user has
//               return StreamBuilder<List<String>>(
//                 stream: _auth
//                     .getProvidersForCurrentUser(), // Get the current user's provider IDs
//                 builder: (context, providerIdsSnapshot) {
//                   if (providerIdsSnapshot.connectionState ==
//                       ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//                   if (providerIdsSnapshot.hasError) {
//                     return Center(
//                         child: Text('Error: ${providerIdsSnapshot.error}'));
//                   }

//                   // Fetch providers based on user area
//                   return StreamBuilder<QuerySnapshot>(
//                     stream: FirebaseFirestore.instance
//                         .collection('User')
//                         .where('isProvider', isEqualTo: true)
//                         .where('area',
//                             isEqualTo: userArea) // Use the fetched area
//                         .snapshots(),
//                     builder: (context, providersSnapshot) {
//                       if (providersSnapshot.connectionState ==
//                           ConnectionState.waiting) {
//                         return const Center(child: CircularProgressIndicator());
//                       }
//                       if (providersSnapshot.hasError) {
//                         return Center(
//                             child: Text('Error: ${providersSnapshot.error}'));
//                       }

//                       // Get all providers
//                       final allProviders = providersSnapshot.data?.docs
//                           .map((doc) => AppUser.fromFirestore(doc))
//                           .toList();

//                       // Exclude the providers that the current user already has
//                       final providerIds = providerIdsSnapshot.data ?? [];
//                       final filteredProviders = allProviders?.where((provider) {
//                         return !providerIds.contains(provider
//                             .id); // Adjust `provider.id` if your ID field is named differently
//                       }).toList();

//                       // Check if there are any providers left
//                       if (filteredProviders == null ||
//                           filteredProviders.isEmpty) {
//                         return const Center(
//                             child: Text('لا يوجد فنين صيانة في منطقتك'));
//                       }

//                       return ListView.builder(
//                         itemCount: filteredProviders.length,
//                         itemBuilder: (context, index) {
//                           return ProviderCard(
//                             provider: filteredProviders[index],
//                             currentUserEmail: user.email,
//                           );
//                         },
//                       );
//                     },
//                   );
//                 },
//               );
//             } else {
//               return const Center(child: Text('User not logged in'));
//             }
//           },
//         ),
//       ),
//     );
//   }
// }
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:home_services_app/cores/app_colors.dart';
// import 'package:home_services_app/cores/custom_widgets/custom_app_bar.dart';
// import 'package:home_services_app/cores/models/user.dart';
// import 'package:home_services_app/feature/mainUi/account_screen.dart';
// import 'package:home_services_app/feature/mainUi/own_providers_screen.dart';

// import '../../cores/custom_widgets/providerCard.dart';
// import '../auth/authLogic.dart';
// import '../auth/login_screen.dart';

// class HomePage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   int _currentIndex = 2;
//   final _auth = AuthService();
//   String? userArea = ""; // Initialize userArea

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _currentIndex == 2
//           ? mainPageContent()
//           : _currentIndex == 0
//               ? AccountScreen()
//               : ownProvidersScreen(), // Call the method to build the body content
//       bottomNavigationBar: BottomNavigationBar(
//         selectedItemColor: AppColors.primaryColor,
//         currentIndex: _currentIndex,
//         onTap: (int index) {
//           setState(() {
//             print(_currentIndex);
//             _currentIndex = index;
//           });
//         },
//         items: [
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: 'الحساب'),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.business), label: 'مزودو خدماتك'),
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
//         ],
//       ),
//     );
//   }

//   Widget mainPageContent() {
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: Size(30, 80),
//         child: CustomAppBar(
//           title: null,
//         ),
//       ),
//       body: Center(
//         child: StreamBuilder<AppUser>(
//           stream: _auth.getUserDataStream(), // Get user data stream
//           builder: (context, userSnapshot) {
//             if (userSnapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             if (userSnapshot.hasError) {
//               return Center(child: Text('Error: ${userSnapshot.error}'));
//             }

//             if (userSnapshot.hasData && userSnapshot.data != null) {
//               AppUser user = userSnapshot.data!;
//               String userArea = user.area ?? ""; // Get user area

//               return StreamBuilder<QuerySnapshot>(
//                 stream: FirebaseFirestore.instance
//                     .collection('User')
//                     .where('isProvider', isEqualTo: true)
//                     .where('area', isEqualTo: userArea) // Use the fetched area
//                     .snapshots(),
//                 builder: (context, providersSnapshot) {
//                   if (providersSnapshot.connectionState ==
//                       ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//                   if (providersSnapshot.hasError) {
//                     return Center(
//                         child: Text('Error: ${providersSnapshot.error}'));
//                   }

//                   final providers = providersSnapshot.data?.docs
//                       .map((doc) => AppUser.fromFirestore(doc))
//                       .toList();

//                   if (providers == null || providers.isEmpty) {
//                     return const Center(
//                         child: Text('لا يوجد فنين صيانة في منطقتك'));
//                   }

//                   return ListView.builder(
//                     itemCount: providers.length,
//                     itemBuilder: (context, index) {
//                       return ProviderCard(
//                         provider: providers[index],
//                         currentUserEmail: user.email,
//                       );
//                     },
//                   );
//                 },
//               );
//             } else {
//               return const Center(child: Text('User not logged in'));
//             }
//           },
//         ),
//       ),
//     );
//   }

//   Widget ownProvidersScreen() {
//     return OwnProvidersScreen();

//     //  Center(
//     //   child: Text("صفحة"),
//     // );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:home_services_app/cores/app_colors.dart';
import 'package:home_services_app/cores/custom_widgets/custom_app_bar.dart';
import 'package:home_services_app/cores/models/user.dart';
import 'package:home_services_app/feature/mainUi/account_screen.dart';

import '../../cores/custom_widgets/providerCard.dart';
import '../../cores/custom_widgets/rating_widget.dart';
import '../../logic/authLogic.dart';

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
                    .getRequestForCurrentprovider(), // Get the current user's User IDs
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
                      print("11111111111111111111111111111111111111111111111");

                      // print(currentProviderUsersIds);
                      // final currentUsersProvider = allUsers!.contains(user);
                      // print(allProviders);
                      // print("11111111111111111111111111111111111111111111111");

                      // Exclude the providers that the current user already has
                      // final providerIds = providerIdsSnapshot.data ?? [];
                      // final filteredProviders = allUsers?.where((provider) {
                      //   return !providerIds.contains(provider
                      //       .id); // Adjust `provider.id` if your ID field is named differently
                      // }).toList();

                      // Check if there are any providers left
                      // if (filteredProviders == null ||
                      //     filteredProviders.isEmpty) {
                      //   return const Center(
                      //       child: Text('لا يوجد فنين صيانة في منطقتك'));
                      // }

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
                                    // isSubscriber: allUsers[index].isYearSubscriber,
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
