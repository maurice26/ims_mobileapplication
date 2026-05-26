class Sale {
  final String id;
  final String productId;
  final int quantity;
  final double total;
  final String date;
  final String userId;

  Sale({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.total,
    required this.date,
    required this.userId,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['saleId'].toString(),
      productId: json['productId']?.toString() ?? '',
      quantity: int.parse(json['quantity'].toString()),
      total: double.parse((json['totalPrice'] ?? json['total']).toString()),
      date: (json['saleDate'] ?? json['date'] ?? '').toString(),
      userId: json['userId']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'saleId': id,
      'productId': productId,
      'quantity': quantity,
      'total': total,
      'date': date,
      'userId': userId,
    };
  }
}
