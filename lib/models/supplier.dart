class Supplier {
  final String id;
  final String name;
  final String contact;
  final List<String> products;

  Supplier({
    required this.id,
    required this.name,
    required this.contact,
    required this.products,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['supplierId'].toString(),
      name: json['name'] ?? '',
      contact: json['contact'] ?? '',
      products: List<String>.from(json['products'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supplierId': id,
      'name': name,
      'contact': contact,
      'products': products,
    };
  }
}
