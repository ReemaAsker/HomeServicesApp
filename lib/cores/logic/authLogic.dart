import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:home_services_app/cores/models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Signs up a new user with the given email and password.
  Future<UserCredential?> signUp(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      print("Sign up failed: $e");
      return null;
    }
  }

  /// Logs in a user with the given email and password.
  Future<bool?> login(String email, String password) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      final User? user = credential.user;

      if (user != null) {
        final userDoc = await _firestore.collection('User').doc(user.uid).get();

        if (userDoc.exists) {
          return !userDoc.get('isProvider');
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

  /// Signs out the current user.
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("Sign out failed: $e");
    }
  }

  /// Creates a new user with additional data in Firestore.
  Future<String> createUser(AppUser newUser) async {
    try {
      final UserCredential? userCredential =
          await signUp(newUser.email, newUser.password);
      if (userCredential == null) return "failed";

      String uid = userCredential.user!.uid;

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
        'userId': uid,
      });

      return "success";
    } catch (e) {
      print("User creation failed: $e");
      return "failed";
    }
  }

  /// Streams the current user's data as an AppUser object.
  Stream<AppUser> getUserDataStream() {
    User? user = _auth.currentUser;

    if (user != null) {
      return _firestore
          .collection('User')
          .doc(user.uid)
          .snapshots()
          .map((snapshot) {
        final data = snapshot.data();
        if (data != null) {
          return AppUser.fromMap(data);
        } else {
          throw Exception('User data is null');
        }
      });
    } else {
      throw Exception('No user is logged in');
    }
  }

  /// Adds a provider request for the current user.
  Future<bool> addRequest(String providerID) async {
    try {
      String userId = _auth.currentUser!.uid;
      await _firestore.collection('Request').doc(userId).set({
        'providerId': FieldValue.arrayUnion([providerID])
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      print("Failed to add request: $e");
      return false;
    }
  }

  /// Streams the provider IDs associated with the current user.
  Stream<List<String>> getProvidersForCurrentUser() {
    String userId = _auth.currentUser!.uid;
    return _firestore
        .collection('Request')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        List<dynamic> providerIds = snapshot.data()?['providerId'] ?? [];
        return List<String>.from(providerIds);
      }
      return [];
    });
  }

  /// Streams the requests associated with the current provider.
  Stream<List<String>> getRequestsForCurrentProvider() {
    String userId = _auth.currentUser!.uid;
    return _firestore
        .collection('Request')
        .where('providerId', arrayContains: userId)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) => doc.id).toList();
    });
  }

  /// Evaluates the provider by updating the rating.
  Future<void> evaluateProvider(String providerId, double newRating) async {
    final docRef = _firestore.collection('Rating').doc(providerId);
    DocumentSnapshot doc = await docRef.get();

    if (doc.exists) {
      double currentRating = doc['rating']?.toDouble() ?? 0.0;
      List<dynamic> userIds = doc['userId'] ?? [];
      int numberOfRatingUsers = doc['noOfRatingUser'] ?? 0;

      if (!userIds.contains(_auth.currentUser!.uid)) {
        userIds.add(_auth.currentUser!.uid);
        double newAverageRating =
            (currentRating * numberOfRatingUsers + newRating) /
                (numberOfRatingUsers + 1);
        await docRef.set({
          'rating': double.parse(newAverageRating.toStringAsFixed(2)),
          'userId': FieldValue.arrayUnion([_auth.currentUser!.uid]),
          'noOfRatingUser': FieldValue.increment(1),
        }, SetOptions(merge: true));
      }
    } else {
      await docRef.set({
        'rating': newRating,
        'userId': [_auth.currentUser!.uid],
        'noOfRatingUser': 1,
      });
    }
  }

  /// Gets the rating for a specific provider.
  Future<double?> getRatingForProvider(String providerId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('Rating').doc(providerId).get();
      if (doc.exists) {
        return doc['rating']?.toDouble();
      } else {
        print('Provider not found');
        return null;
      }
    } catch (e) {
      print('Error getting rating: $e');
      return null;
    }
  }

  /// Streams the rating for the current provider.
  Stream<double> ratingOfCurrentProvider(String userId) {
    final docRef = _firestore.collection('Rating').doc(userId);
    return docRef.snapshots().map((doc) {
      if (doc.exists) {
        return double.parse(
            (doc['rating']?.toDouble() ?? 0.0).toStringAsFixed(2));
      }
      return 0.0;
    });
  }

  /// Gets all users associated with the current provider.
  Future<List<String>> getAllUsersForCurrentProvider(String providerID) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('Request')
        .where('providerId', arrayContains: providerID)
        .get();

    return querySnapshot.docs.map((doc) => doc.id).toList();
  }

  /// Updates user data in Firestore.
  Future<bool> updateUserData(AppUser user) async {
    try {
      await _firestore.collection('User').doc(_auth.currentUser!.uid).update({
        'name': user.username,
        'email': user.email,
        'age': user.age,
        'isYearSubscriber': user.isYearSubscriber,
        'area': user.area,
      });
      return true;
    } catch (e) {
      print("User update failed: $e");
      return false;
    }
  }

  /// Removes a provider from the current user.
  Future<void> removeProviderFromCurrentUser(String providerId) async {
    try {
      String userId = _auth.currentUser!.uid;
      DocumentReference requestDocRef =
          _firestore.collection('Request').doc(userId);
      DocumentReference ratingDocRef =
          _firestore.collection('Rating').doc(providerId);

      await requestDocRef.update({
        'providerId': FieldValue.arrayRemove([providerId]),
      });

      await ratingDocRef.update({
        'userId': FieldValue.arrayRemove([userId]),
      });

      print('Provider ID $providerId removed successfully from user $userId.');
    } catch (e) {
      print('Error removing provider ID: $e');
    }
  }
}
