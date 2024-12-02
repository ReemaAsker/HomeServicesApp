class Equipment {
  String? id;
  final String name;
  final double price;
  final bool isPrimary;

  Equipment(
      {required this.name,
      required this.price,
      required this.isPrimary,
      this.id});
  // Convert Equipment object to a Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'isPrimary': isPrimary,
    };
  }

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      isPrimary: json['isPrimary'],
    );
  }
}
