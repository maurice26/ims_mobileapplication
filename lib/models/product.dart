class Product {
  final int id;
  final String name;
  final double price;

  Product({required this.id, required this.name, required this.price});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: int.parse(json['productId'].toString()),
      name: json['name'] ?? '',
      price: double.parse(json['price'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {'productId': id.toString(), 'name': name, 'price': price};
  }
}
