class Invoice {
  final int id;
  final String? invoiceNumber;
  final double? totalAmount;
  final double? balanceAmount;
  final String? status;
  final String? description;
  final DateTime? transDate;
  final DateTime? createdAt;
  final int clientMatterId;

  Invoice({
    required this.id,
    this.invoiceNumber,
    this.totalAmount,
    this.balanceAmount,
    this.status,
    this.description,
    this.transDate,
    this.createdAt,
    required this.clientMatterId,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['receipt_id'],
      invoiceNumber: json['trans_no'],
      totalAmount: (json['balance_amount'] ?? 0).toDouble(),
      balanceAmount: (json['balance_amount'] ?? 0).toDouble(),
      status: json['status']?.toLowerCase(),
      description: json['description'],
      transDate: json['trans_date'] != null
          ? DateTime.tryParse(
        _convertDateFormat(json['trans_date']),
      )
          : null,
      createdAt: json['client_application_sent_at'] != null
          ? DateTime.tryParse(json['client_application_sent_at'])
          : null,
      clientMatterId: json['client_matter_id'],
    );
  }

  static String _convertDateFormat(String date) {
    // Converts dd/MM/yyyy → yyyy-MM-dd
    final parts = date.split('/');
    return '${parts[2]}-${parts[1]}-${parts[0]}';
  }
}
