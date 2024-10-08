import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../cores/custom_widgets/custom_app_bar.dart';
import '../../../cores/custom_widgets/providerCard.dart';
import '../../../cores/models/user.dart';
import '../../../cores/logic/authLogic.dart';

class OwnProvidersScreen extends StatefulWidget {
  const OwnProvidersScreen({super.key});

  @override
  State<OwnProvidersScreen> createState() => _OwnProvidersScreenState();
}

class _OwnProvidersScreenState extends State<OwnProvidersScreen> {
  final _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(30, 80),
        child: CustomAppBar(
          title: "مزودو خدماتك",
        ),
      ),
      body: StreamBuilder<List<String>>(
        stream:
            _auth.getProvidersForCurrentUser(), // Use the stream method here
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final providers = snapshot.data;

          if (providers == null || providers.isEmpty) {
            return const Center(
                child: Text('لا يوجد اي فني تواصلت معه حتى الان '));
          }

          return ListView.builder(
            itemCount: providers.length,
            itemBuilder: (context, index) {
              // Use Column instead of ListView.builder inside another ListView.builder
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('User')
                    .where('isProvider', isEqualTo: true)
                    .where('userId',
                        isEqualTo: providers[index]) // Filter by provider ID
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

                  final providerInfo = providersSnapshot.data?.docs
                      .map((doc) => AppUser.fromFirestore(doc))
                      .toList();

                  if (providerInfo == null || providerInfo.isEmpty) {
                    return const Center(
                        child: Text('لا يوجد فنيين صيانة متاحين'));
                  }

                  // Ensure correct provider list is checked here
                  return Column(
                    children: providerInfo.map((provider) {
                      return ProviderCard(
                        evaluated: true,
                        user: provider,
                        currentUserEmail: provider.email,
                      );
                    }).toList(),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
