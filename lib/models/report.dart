class Report {
  final String type;
  final String period;
  final Map<String, dynamic> data;
  final int totalSales;
  final double totalRevenue;

  Report({
    required this.type,
    required this.period,
    required this.data,
    required this.totalSales,
    required this.totalRevenue,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      type: json['type'] ?? '',
      period: json['period'] ?? '',
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      totalSales: int.parse(json['totalSales'].toString()),
      totalRevenue: double.parse(json['totalRevenue'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'period': period,
      'data': data,
      'totalSales': totalSales,
      'totalRevenue': totalRevenue,
    };
  }
}
