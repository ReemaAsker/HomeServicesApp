import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  String? id;
  String username;
  String email;
  int age;
  String password; // Avoid storing in plain text in production
  bool isProvider; // Role can be either (false) 'عميل' or (true) 'مزود خدمة'
  String area; // User area
  String? serviceDescription; // For service providers
  double? servicePrice; // For service providers
  bool isYearSubscriber;
  bool gender; // true: male, false: female

  AppUser({
    required this.username,
    required this.email,
    required this.age,
    required this.password,
    required this.isProvider,
    required this.area,
    this.serviceDescription,
    this.servicePrice,
    required this.isYearSubscriber,
    required this.gender,
    this.id,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    try {
      return AppUser(
        id: doc.id,
        username: data['name'] ?? '',
        email: data['email'] ?? '',
        age: data['age'] ?? 0,
        password: data['password'] ?? '', // Consider removing in production
        isProvider: data['isProvider'] ?? false,
        area: data['area'] ?? '',
        serviceDescription: data['serviceDesc'],
        servicePrice: _parseServicePrice(data['servicePrice']),
        isYearSubscriber: data['isYearSubscriber'] ?? false,
        gender: data['gender'] ?? false,
      );
    } catch (e, stackTrace) {
      print("Error creating AppUser from Firestore: $e");
      print(stackTrace);
      return AppUser(
        id: doc.id,
        username: '',
        email: '',
        age: 0,
        password: '',
        isProvider: false,
        area: '',
        isYearSubscriber: false,
        gender: false,
      );
    }
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] ?? '',
      username: map['name'] ?? '',
      email: map['email'] ?? '',
      age: map['age'] ?? 0,
      password: map['password'] ?? '', // Consider removing in production
      isProvider: map['isProvider'] ?? false,
      area: map['area'] ?? '',
      serviceDescription: map['serviceDesc'],
      servicePrice: _parseServicePrice(map['servicePrice']),
      isYearSubscriber: map['isYearSubscriber'] ?? false,
      gender: map['gender'] ?? false,
    );
  }

  static double? _parseServicePrice(dynamic price) {
    if (price == null) return null;
    return double.tryParse(price.toString());
  }
}
