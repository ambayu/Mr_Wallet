class AIParsedTransaction {
  final String walletName;
  final String type; // EXPENSE, INCOME, TRANSFER, ADJUSTMENT
  final double amount;
  final String category;
  final String notes;
  final double? targetActualBalance;

  AIParsedTransaction({
    required this.walletName,
    required this.type,
    required this.amount,
    required this.category,
    this.notes = '',
    this.targetActualBalance,
  });

  factory AIParsedTransaction.fromJson(Map<String, dynamic> json) {
    return AIParsedTransaction(
      walletName: json['wallet_name'] as String? ?? 'Dompet Tunai',
      type: (json['type'] as String? ?? 'EXPENSE').toUpperCase(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] as String? ?? 'Lain-lain',
      notes: json['notes'] as String? ?? '',
      targetActualBalance:
          (json['target_actual_balance'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wallet_name': walletName,
      'type': type,
      'amount': amount,
      'category': category,
      'notes': notes,
      'target_actual_balance': targetActualBalance,
    };
  }
}

class AIParsedTask {
  final String title;
  final DateTime dueDate;
  final String priority; // LOW, MEDIUM, HIGH
  final double? estimatedAmount;
  final String? walletName;

  AIParsedTask({
    required this.title,
    required this.dueDate,
    this.priority = 'MEDIUM',
    this.estimatedAmount,
    this.walletName,
  });

  factory AIParsedTask.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    if (json['due_date'] != null) {
      parsedDate =
          DateTime.tryParse(json['due_date'] as String) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now().add(const Duration(hours: 2));
    }

    return AIParsedTask(
      title: json['title'] as String? ?? 'Tugas Baru',
      dueDate: parsedDate,
      priority: (json['priority'] as String? ?? 'MEDIUM').toUpperCase(),
      estimatedAmount: (json['estimated_amount'] as num?)?.toDouble(),
      walletName: json['wallet_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'due_date': dueDate.toIso8601String(),
      'priority': priority,
      'estimated_amount': estimatedAmount,
      'wallet_name': walletName,
    };
  }
}

class AIParsedSummaryRequest {
  final bool isRequested;
  final String? queryTarget;

  AIParsedSummaryRequest({
    required this.isRequested,
    this.queryTarget,
  });

  factory AIParsedSummaryRequest.fromJson(Map<String, dynamic> json) {
    return AIParsedSummaryRequest(
      isRequested: json['is_requested'] as bool? ?? false,
      queryTarget: json['query_target'] as String?,
    );
  }
}

class AIParsedResult {
  final String intent; // TRANSACTION_ENTRY, TASK_ENTRY, MULTI_ACTION, BALANCE_ADJUSTMENT, SUMMARY_QUERY
  final List<AIParsedTransaction> transactions;
  final List<AIParsedTask> tasks;
  final AIParsedSummaryRequest? summaryRequest;
  final String naturalResponse;

  AIParsedResult({
    required this.intent,
    this.transactions = const [],
    this.tasks = const [],
    this.summaryRequest,
    required this.naturalResponse,
  });

  factory AIParsedResult.fromJson(Map<String, dynamic> json) {
    final transList = (json['transactions'] as List<dynamic>?)
            ?.map((e) => AIParsedTransaction.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final tasksList = (json['tasks'] as List<dynamic>?)
            ?.map((e) => AIParsedTask.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final summary = json['summary_request'] != null
        ? AIParsedSummaryRequest.fromJson(
            json['summary_request'] as Map<String, dynamic>)
        : null;

    return AIParsedResult(
      intent: json['intent'] as String? ?? 'UNKNOWN',
      transactions: transList,
      tasks: tasksList,
      summaryRequest: summary,
      naturalResponse: json['natural_response'] as String? ?? 'Permintaan berhasil diproses.',
    );
  }
}

class OCRBillItem {
  final String name;
  final double price;
  final int quantity;

  OCRBillItem({
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  factory OCRBillItem.fromJson(Map<String, dynamic> json) {
    return OCRBillItem(
      name: json['name'] as String? ?? 'Item',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }
}

class OCRBillResult {
  final String merchantName;
  final DateTime date;
  final double totalAmount;
  final double? tax;
  final String category;
  final List<OCRBillItem> items;
  final String rawText;

  OCRBillResult({
    required this.merchantName,
    required this.date,
    required this.totalAmount,
    this.tax,
    this.category = 'Belanja',
    this.items = const [],
    this.rawText = '',
  });

  factory OCRBillResult.fromJson(Map<String, dynamic> json, {String rawText = ''}) {
    final itemsList = (json['items'] as List<dynamic>?)
            ?.map((e) => OCRBillItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    DateTime parsedDate;
    if (json['date'] != null) {
      parsedDate = DateTime.tryParse(json['date'] as String) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return OCRBillResult(
      merchantName: json['merchant_name'] as String? ?? 'Merchant',
      date: parsedDate,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble(),
      category: json['category'] as String? ?? 'Belanja',
      items: itemsList,
      rawText: rawText,
    );
  }
}
