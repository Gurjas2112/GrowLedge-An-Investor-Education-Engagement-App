enum TradeType { buy, sell }

class Trade {
  final String id;
  final String userId;
  final String symbol;
  final TradeType type;
  final int quantity;
  final double price;
  final double totalAmount;
  final DateTime timestamp;

  Trade({
    required this.id,
    required this.userId,
    required this.symbol,
    required this.type,
    required this.quantity,
    required this.price,
    required this.totalAmount,
    required this.timestamp,
  });

  factory Trade.fromJson(Map<String, dynamic> json) {
    return Trade(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['user_id'] ?? '',
      symbol: json['symbol'] ?? '',
      type: json['type'] == 'SELL' || json['type'] == 'sell'
          ? TradeType.sell
          : TradeType.buy,
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0.0).toDouble(),
      totalAmount: (json['total_amount'] ?? 0.0).toDouble(),
      timestamp: DateTime.parse(
        json['timestamp'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'symbol': symbol,
      'type': type == TradeType.sell ? 'SELL' : 'BUY',
      'quantity': quantity,
      'price': price,
      'total_amount': totalAmount,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class Portfolio {
  final String id;
  final String userId;
  final double cashBalance;
  final Map<String, int> holdings;
  final double totalValue;
  final DateTime createdAt;
  final DateTime updatedAt;

  Portfolio({
    required this.id,
    required this.userId,
    required this.cashBalance,
    required this.holdings,
    required this.totalValue,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Portfolio.fromJson(Map<String, dynamic> json) {
    return Portfolio(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['user_id'] ?? '',
      cashBalance: (json['cash_balance'] ?? 500000.0).toDouble(),
      holdings: Map<String, int>.from(json['holdings'] ?? {}),
      totalValue: (json['total_value'] ?? 500000.0).toDouble(),
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'cash_balance': cashBalance,
      'holdings': holdings,
      'total_value': totalValue,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
