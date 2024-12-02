import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:home_services_app/cores/app_colors.dart';
import 'package:home_services_app/cores/custom_widgets/custom_app_bar.dart';
import 'package:home_services_app/cores/logic/firebaseLogic.dart';
import 'package:home_services_app/cores/models/user.dart';
import 'package:home_services_app/feature/mainUi/UserScreens/account_screen.dart';
import 'package:home_services_app/feature/mainUi/UserScreens/own_providers_screen.dart';

import '../../../cores/custom_widgets/providerCard.dart';
import '../../../cores/static_info.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 2;
  final _auth = FirebaseServices();
  String? _selectedCity; // Holds the currently selected city

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getSelectedPage(_currentIndex),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // Method to switch between the selected pages
  Widget _getSelectedPage(int index) {
    switch (index) {
      case 0:
        return AccountScreen();
      case 1:
        return OwnProvidersScreen();
      case 2:
      default:
        return _buildMainPageContent();
    }
  }

  // Build the bottom navigation bar
  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      selectedItemColor: AppColors.primaryColor,
      currentIndex: _currentIndex,
      onTap: (int index) => setState(() => _currentIndex = index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'الحساب'),
        BottomNavigationBarItem(
            icon: Icon(Icons.business), label: 'مزودو خدماتك'),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
      ],
    );
  }

  Widget _buildMainPageContent() {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: CustomAppBar(title: null),
      ),
      body: Column(
        children: [
          _buildCityFilter(), // Add city filter dropdown
          Expanded(child: _buildUserStream()),
        ],
      ),
    );
  }

  // Build the dropdown for city selection
  Widget _buildCityFilter() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: DropdownButton<String>(
                value: _selectedCity,
                hint: const Text("اختر المدينة"),
                isExpanded: true,
                items: areas
                    .map((city) => DropdownMenuItem(
                          value: city,
                          child: Text(city),
                        ))
                    .toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedCity = newValue;
                  });
                },
              ),
            ),
          ),
          Icon(Icons.filter_alt_outlined),
        ],
      ),
    );
  }

  // Stream to get user data
  Widget _buildUserStream() {
    return StreamBuilder<AppUser>(
      stream: _auth.getUserDataStream(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (userSnapshot.hasError) {
          return _buildErrorText(userSnapshot.error);
        }

        if (userSnapshot.hasData) {
          AppUser user = userSnapshot.data!;
          return _buildProviderStream(user.area ?? "");
        } else {
          return const Center(child: Text('User not logged in'));
        }
      },
    );
  }

  // Build stream for filtered providers
  Widget _buildProviderStream(String userArea) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('User')
          .where('isProvider', isEqualTo: true)
          .where('area',
              isEqualTo:
                  _selectedCity ?? userArea) // Use selected city if available
          .snapshots(),
      builder: (context, providersSnapshot) {
        if (providersSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (providersSnapshot.hasError) {
          return _buildErrorText(providersSnapshot.error);
        }

        final allProviders = providersSnapshot.data?.docs
            .map((doc) => AppUser.fromFirestore(doc))
            .toList();

        final filteredProviders = allProviders ?? [];

        if (filteredProviders.isEmpty) {
          return const Center(
              child: Text('لا يوجد فنيون صيانة في المنطقة المختارة'));
        }

        return _buildProviderList(filteredProviders);
      },
    );
  }

  // Build a list of provider cards
  Widget _buildProviderList(List<AppUser> providers) {
    return ListView.builder(
      itemCount: providers.length,
      itemBuilder: (context, index) {
        return ProviderCard(
          user: providers[index],
          currentUserEmail: providers[index].email,
        );
      },
    );
  }

  // Build error text widget
  Widget _buildErrorText(dynamic error) {
    return Center(child: Text('Error: $error'));
  }
}

// Build stream for filtered providers based on user area
Widget _buildFilteredProvidersStream(
    String userArea, List<String> providerIds) {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('User')
        .where('isProvider', isEqualTo: true)
        .where('area', isEqualTo: userArea)
        .snapshots(),
    builder: (context, providersSnapshot) {
      if (providersSnapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (providersSnapshot.hasError) {
        return _buildErrorText(providersSnapshot.error);
      }

      final allProviders = providersSnapshot.data?.docs
          .map((doc) => AppUser.fromFirestore(doc))
          .toList();

      final filteredProviders = _filterProviders(allProviders, providerIds);

      if (filteredProviders.isEmpty) {
        return const Center(child: Text('لا يوجد فنين صيانة في منطقتك'));
      }

      return _buildProviderList(filteredProviders);
    },
  );
}

// Filter out providers the user already has
List<AppUser> _filterProviders(
    List<AppUser>? allProviders, List<String> providerIds) {
  return allProviders
          ?.where((provider) => !providerIds.contains(provider.id))
          .toList() ??
      [];
}

// Build a list of provider cards
Widget _buildProviderList(List<AppUser> filteredProviders) {
  return ListView.builder(
    itemCount: filteredProviders.length,
    itemBuilder: (context, index) {
      return ProviderCard(
        user: filteredProviders[index],
        currentUserEmail: filteredProviders[index].email,
      );
    },
  );
}

// Build error text widget
Widget _buildErrorText(dynamic error) {
  return Center(child: Text('Error: $error'));
}
