class Trade {
  final String id;
  final String userId;
  final String symbol;
  final String side; // "BUY" or "SELL"
  final double qty;
  final double price;
  final DateTime timestamp;

  Trade({
    required this.id,
    required this.userId,
    required this.symbol,
    required this.side,
    required this.qty,
    required this.price,
    required this.timestamp,
  });

  factory Trade.fromJson(Map<String, dynamic> json) {
    return Trade(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['user_id'] ?? '',
      symbol: json['symbol'] ?? '',
      side: json['side'] ?? 'BUY',
      qty: (json['qty'] ?? 0).toDouble(),
      price: (json['price'] ?? 0).toDouble(),
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
      'side': side,
      'qty': qty,
      'price': price,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  double get totalValue => qty * price;
}

class Portfolio {
  final String id;
  final String userId;
  final double cashBalance;
  final Map<String, double> holdings;
  final DateTime createdAt;
  final DateTime updatedAt;

  Portfolio({
    required this.id,
    required this.userId,
    required this.cashBalance,
    required this.holdings,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Portfolio.fromJson(Map<String, dynamic> json) {
    return Portfolio(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['user_id'] ?? '',
      cashBalance: (json['cash_balance'] ?? 0).toDouble(),
      holdings: Map<String, double>.from(json['holdings'] ?? {}),
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
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  double getTotalHoldingsValue(Map<String, double> currentPrices) {
    double total = 0;
    holdings.forEach((symbol, quantity) {
      final price = currentPrices[symbol] ?? 0;
      total += quantity * price;
    });
    return total;
  }

  double getTotalPortfolioValue(Map<String, double> currentPrices) {
    return cashBalance + getTotalHoldingsValue(currentPrices);
  }
}

class StockQuote {
  final String symbol;
  final String name;
  final double price;
  final double change;
  final String changePercent;
  final double high;
  final double low;
  final int volume;

  StockQuote({
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.high,
    required this.low,
    required this.volume,
  });

  factory StockQuote.fromJson(Map<String, dynamic> json) {
    return StockQuote(
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      change: (json['change'] ?? 0).toDouble(),
      changePercent: json['change_percent'] ?? '0%',
      high: (json['high'] ?? 0).toDouble(),
      low: (json['low'] ?? 0).toDouble(),
      volume: json['volume'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'name': name,
      'price': price,
      'change': change,
      'change_percent': changePercent,
      'high': high,
      'low': low,
      'volume': volume,
    };
  }

  bool get isPositive => change >= 0;
}
