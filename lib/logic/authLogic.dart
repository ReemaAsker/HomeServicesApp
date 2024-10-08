import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:home_services_app/cores/models/user.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential?> signUp(String email, String pass) async {
    try {
      final UserCredential creditional = await _auth
          .createUserWithEmailAndPassword(email: email, password: pass);

      return creditional;
    } catch (e) {}
    return null;
  }

  Future<bool?> login(String email, String pass) async {
    try {
      // Sign in the user with email and password
      final credential =
          await _auth.signInWithEmailAndPassword(email: email, password: pass);
      final User? user = credential.user;

      if (user != null) {
        // Get the user's Firestore document
        final userDoc = await FirebaseFirestore.instance
            .collection('User')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          // Check if the user is a provider based on the 'isProvider' field
          bool isProvider = userDoc.get('isProvider');

          return !isProvider;
        } else {
          print("User document not found");
        }
      }

      return false;
    } catch (e) {
      print("Login failed: $e");
      return null;
    }
  }

  Future<void> SignOut() async {
    try {
      await _auth.signOut();
    } catch (e) {}
  }

  Future<dynamic> CreateUser(AppUser newUser) async {
    try {
      // Create a user with Firebase Authentication
      UserCredential? userCredential =
          await signUp(newUser.email, newUser.password);
      if (userCredential == null) {
        return userCredential;
      }
      // Get the user's UID
      String uid = userCredential.user!.uid;

      // Store additional user data in Firestore
      await _firestore.collection('User').doc(uid).set({
        'name': newUser.username,
        'age': newUser.age,
        'email': newUser.email,
        'area': newUser.area,
        'isProvider': newUser.isProvider,
        'serviceDesc': newUser.serviceDescription ?? "",
        'servicePrice': newUser.servicePrice ?? 0,
        'gender': newUser.gender,
        'isYearSubscriber': newUser.isYearSubscriber,
        // 'ratingReview': newUser.ratingReview,
        'userId': uid,
        'providers': []
      });
    } catch (e) {
      return "failed";
    }
    return "success";
  }

// Method to fetch current user data from Firestore as AppUser object
  Stream<AppUser> getUserDataStream() {
    User? user = FirebaseAuth.instance.currentUser; // Get the current user

    if (user != null) {
      // Return the user's Firestore document as a stream mapped to AppUser
      return FirebaseFirestore.instance
          .collection('User')
          .doc(user.uid)
          .snapshots()
          .map((snapshot) {
        final data = snapshot.data(); // Fetch the data map
        if (data != null) {
          // Convert the data map to AppUser using fromMap
          return AppUser.fromMap(data);
        } else {
          throw Exception('User data is null');
        }
      });
    } else {
      throw Exception('No user is logged in');
    }
  }

  Future<bool> addRequest(String providerID) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      await _firestore
          .collection('Request')
          .doc(userId) // Using userId as the document ID
          .set({
        // 'userId': userId,
        'providerId': FieldValue.arrayUnion([providerID])
      }, SetOptions(merge: true));
    } catch (e) {
      return false;
    }
    return true;
  }

  Stream<List<String>> getProvidersForCurrentUser() {
    return _firestore
        .collection('Request')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .map((snapshot) {
      // Check if the snapshot exists
      if (snapshot.exists) {
        // Access the document data
        Map<String, dynamic>? data = snapshot.data();
        if (data != null) {
          // Assuming 'providerId' field contains the list of strings
          List<dynamic> providerIds = data['providerId'] ?? [];

          // Convert the dynamic list to a List<String>
          return List<String>.from(providerIds);
        }
      }
      // Return an empty list if the document doesn't exist or no data is found
      return [];
    });
  }

  Stream<List<String>> getRequestForCurrentprovider() {
    return FirebaseFirestore.instance
        .collection('Request')
        .where('providerId',
            arrayContains: FirebaseAuth.instance.currentUser!
                .uid) // Query where array contains currentUserId
        .snapshots() // Get a stream of document snapshots
        .map((querySnapshot) {
      // Extract document IDs from the query snapshot
      return querySnapshot.docs.map((doc) => doc.id).toList();
    });
  }

  Future<void> evaluatedProvider(String providerId, double newRating) async {
    print("fdssssssssssssssss");
    print(newRating);
    final _firestore = FirebaseFirestore.instance;
    final docRef = _firestore.collection('Rating').doc(providerId);

    // Get the current document
    DocumentSnapshot doc = await docRef.get();

    if (doc.exists) {
      // Get the current rating, userId array, and noOfRatingUser
      double currentRating = doc['rating'].toDouble() ?? 0;
      List<dynamic> userIds = doc['userId'] ?? [];
      int numberOfRatingUsers = doc['noOfRatingUser'] ?? 0;
// Round the value to two decimal places
      currentRating = double.parse(currentRating.toStringAsFixed(2));
      // If the current user hasn't rated yet, update the array and rating
      if (!userIds.contains(FirebaseAuth.instance.currentUser!.uid)) {
        userIds.add(FirebaseAuth.instance.currentUser!.uid);

        // Add new rating and calculate the new average rating
        double newAverageRating =
            (currentRating + newRating) / (numberOfRatingUsers + 1);
        newAverageRating = double.parse(newAverageRating.toStringAsFixed(2));
        // Update Firestore with the new rating, userId array, and increment noOfRatingUser
        await docRef.set({
          'rating': newAverageRating,
          'userId':
              FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid]),
          'noOfRatingUser': FieldValue.increment(1), // Increment the count by 1
        }, SetOptions(merge: true));
      }
    } else {
      // If the document doesn't exist, create it with the new rating, userId, and noOfRatingUser set to 1
      await docRef.set({
        'rating': newRating,
        'userId': [FirebaseAuth.instance.currentUser!.uid],
        'noOfRatingUser': 1, // Initialize the number of rating users to 1
      });
    }
  }

  // Method to get the rating for a specific provider
  Future<double?> getRatingForProvider(String providerId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('Rating').doc(providerId).get();

      if (doc.exists) {
        // Assuming the rating is stored in a field named 'rating'
        return doc['rating']?.toDouble();
      } else {
        print('Provider not found');
        return null; // Provider does not exist
      }
    } catch (e) {
      print('Error getting rating: $e');
      return null; // Handle error accordingly
    }
  }

  Stream<double> ratingOfCurrentProvider(String userId) {
    final docRef = _firestore.collection('Rating').doc(userId);

    return docRef.snapshots().map((doc) {
      if (doc.exists) {
        // Ensure the rating is a double and round to 2 decimal places
        return double.parse(
            (doc['rating']?.toDouble() ?? 0.0).toStringAsFixed(2));
      } else {
        return 0.0; // Default rating if the document does not exist
      }
    });
  }

  Stream<bool> hasUserRated(String providerId) {
    final docRef = _firestore.collection('Rating').doc(providerId);

    // Listen for changes to the document
    return docRef.snapshots().map((doc) {
      if (doc.exists) {
        // Get the userId array from the document
        List<dynamic> userIds = doc['userId'] ?? [];
        // Check if the current user's uid is in the array
        return userIds.contains(FirebaseAuth.instance.currentUser!.uid);
      } else {
        // If the document doesn't exist, the user hasn't rated yet
        return false;
      }
    });
  }

  Future<List<String>> getAllUsersForCurrentProvider(String providerID) async {
// Query Firestore for documents where 'providerIds' contains the specificProviderId
    QuerySnapshot querySnapshot = await _firestore
        .collection('Request')
        .where('providerId', arrayContains: providerID)
        .get();

// Extract the user IDs (document IDs) from the query result
    List<String> usersForCurrentProvidersIds =
        querySnapshot.docs.map((doc) => doc.id).toList();

    return usersForCurrentProvidersIds;
  }

// Method to fetch current user data from Firestore as AppUser object
  Stream<AppUser> getUserData() {
    User? user = FirebaseAuth.instance.currentUser; // Get the current user

    if (user != null) {
      // Return the user's Firestore document as a stream mapped to AppUser
      return FirebaseFirestore.instance
          .collection('User')
          .doc(user.uid)
          .snapshots()
          .map((snapshot) {
        final data = snapshot.data(); // Fetch the data map
        if (data != null) {
          // Convert the data map to AppUser using fromMap
          return AppUser.fromMap(data);
        } else {
          throw Exception('User data is null');
        }
      });
    } else {
      throw Exception('No user is logged in');
    }
  }

  Future<List<AppUser>> fetchFilteredUsers(String area) async {
    // Reference to the Firestore collection
    CollectionReference users = FirebaseFirestore.instance.collection('User');

    // Query to filter users
    QuerySnapshot querySnapshot = await users
        .where('isProvider', isEqualTo: true)
        .where('area', isEqualTo: area)
        .get();

    // Convert the fetched documents to User objects
    List<AppUser> userList = querySnapshot.docs.map((doc) {
      return AppUser.fromFirestore(doc);
    }).toList();
    return userList;
  }

// Update user data in Firestore when the button is clicked
  Future<bool> updateUserData(AppUser user) async {
    try {
      // Update user data in Firebase Firestore
      await FirebaseFirestore.instance
          .collection('User')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'name': user.username,
        'email': user.email,
        'age': int.parse(user.age.toString()),
        'isYearSubscriber': user.isYearSubscriber,
        'area': user.area,
      });
      return true;
    } catch (e, st) {
      print("eeeeeeeeeeeeror");
      print(e);
      print(st);
      return false;
    }
  }

  Future<void> removeProviderFromCurrentUser(String providerId) async {
    try {
      // Get the current user's ID
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Reference to the Request document for the current user
      DocumentReference requestDocRef =
          FirebaseFirestore.instance.collection('Request').doc(userId);

      // Reference to the Rating document for the provider
      DocumentReference ratingDocRef =
          FirebaseFirestore.instance.collection('Rating').doc(providerId);

      // Update the document by removing the specified providerId
      await requestDocRef.update({
        'providerId': FieldValue.arrayRemove([providerId]),
      });

      // Update the document by removing the current userId
      await ratingDocRef.update({
        'userId': FieldValue.arrayRemove([userId]),
      });

      print('Provider ID $providerId removed successfully from user $userId.');
    } catch (e) {
      print('Error removing provider ID: $e');
    }
  }
}
