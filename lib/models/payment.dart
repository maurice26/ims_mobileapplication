class Payment {
  final String id;
  final String saleId;
  final double amount;
  final String method;
  final String status;
  final String date;

  Payment({
    required this.id,
    required this.saleId,
    required this.amount,
    required this.method,
    required this.status,
    required this.date,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['paymentId'].toString(),
      saleId: json['saleId']?.toString() ?? '',
      amount: double.parse(json['amount'].toString()),
      method: (json['paymentMethod'] ?? json['method'] ?? '').toString(),
      status: (json['paymentStatus'] ?? json['status'] ?? '').toString(),
      date: (json['paymentDate'] ?? json['date'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentId': id,
      'saleId': saleId,
      'amount': amount,
      'method': method,
      'status': status,
      'date': date,
    };
  }
}
