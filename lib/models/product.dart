class Product {
  final int id;
  final String name;
  final double price;
  final int stockQuantity;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.stockQuantity = 0,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: int.parse(json['productId'].toString()),
      name: json['name'] ?? '',
      price: double.parse(json['price'].toString()),
      stockQuantity: int.tryParse(json['stockQuantity']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': id,
      'name': name,
      'price': price,
      'stockQuantity': stockQuantity,
    };
  }
}
