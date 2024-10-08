// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  String? id;
  String username;
  String email;
  int age;
  String password; // You may not want to store this in plain text in production
  bool isProvider; // Role can be either(false)'عميل' or (true)'مزود خدمة'
  String area; // User area
  String? serviceDescription; // , for service providers
  double? servicePrice; // , for service providers
  bool isYearSubscriber;
  bool gender; // true:male , false:female
  List<AppUser>? myProviders;
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
    this.myProviders,
    this.id,
  });
  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;

    AppUser? appUser;
    try {
      appUser = AppUser(
          id: doc.id ?? '',
          username: data['name'] ?? '',
          isProvider: data['isProvider'] ?? false,
          area: data['area'] ?? '',
          age: data['age'] ?? 0,
          serviceDescription: data['serviceDesc'] ?? '',
          servicePrice: double.parse(data['servicePrice'].toString()) ?? 0,
          gender: data['gender'] ?? false,
          email: data['email'] ?? '',
          password: data['password'] ?? '',
          isYearSubscriber: data['isYearSubscriber'] ?? false,
          myProviders: []);
    } catch (e, stackTrace) {
      print("hereeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee");
      print(e.toString());
      print(stackTrace);
    }
    return appUser!;
  }
  // Factory method to create AppUser from a map
  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
        id: map['id'] ?? '',
        username: map['name'] ?? '',
        isProvider: map['isProvider'] ?? false,
        area: map['area'] ?? '',
        age: map['age'] ?? 0,
        serviceDescription: map['serviceDesc'] ?? '',
        servicePrice: double.parse(map['servicePrice'].toString()) ?? 0,
        gender: map['gender'] ?? false,
        email: map['email'] ?? '',
        password: map['password'] ?? '',
        isYearSubscriber: map['isYearSubscriber'],
        myProviders: map['myProviders'] ?? []);
  }
}
