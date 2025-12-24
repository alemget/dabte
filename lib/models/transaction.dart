class DebtTransaction {
  final int? id;
  final int clientId;
  final double amount;
  final String details;
  final DateTime date;
  final String currency;
  final bool isLocal;
  final bool isForMe; // true => له (أنا أطلب), false => عليه (هو يطلب)
  final DateTime? reminderDate; // وقت التذكير

  const DebtTransaction({
    this.id,
    required this.clientId,
    required this.amount,
    required this.details,
    required this.date,
    required this.currency,
    required this.isLocal,
    required this.isForMe,
    this.reminderDate,
  });

  DebtTransaction copyWith({
    int? id,
    int? clientId,
    double? amount,
    String? details,
    DateTime? date,
    String? currency,
    bool? isLocal,
    bool? isForMe,
    DateTime? reminderDate,
  }) {
    return DebtTransaction(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      amount: amount ?? this.amount,
      details: details ?? this.details,
      date: date ?? this.date,
      currency: currency ?? this.currency,
      isLocal: isLocal ?? this.isLocal,
      isForMe: isForMe ?? this.isForMe,
      reminderDate: reminderDate ?? this.reminderDate,
    );
  }

  factory DebtTransaction.fromMap(Map<String, dynamic> map) {
    return DebtTransaction(
      id: map['id'] as int?,
      clientId: map['clientId'] as int,
      amount: (map['amount'] as num).toDouble(),
      details: (map['details'] as String?) ?? '',
      date: DateTime.parse(map['date'] as String),
      currency: map['currency'] as String,
      isLocal: (map['isLocal'] as int) == 1,
      isForMe: (map['isForMe'] as int) == 1,
      reminderDate: map['reminderDate'] != null ? DateTime.parse(map['reminderDate'] as String) : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'clientId': clientId,
        'amount': amount,
        'details': details,
        'date': date.toIso8601String(),
        'currency': currency,
        'isLocal': isLocal ? 1 : 0,
        'isForMe': isForMe ? 1 : 0,
        'reminderDate': reminderDate?.toIso8601String(),
      };
}
