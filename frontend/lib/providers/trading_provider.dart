import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trade.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

// Trading State
class TradingState {
  final Portfolio? portfolio;
  final List<Trade> trades;
  final bool isLoading;
  final String? error;
  final Map<String, double> stockPrices;

  TradingState({
    this.portfolio,
    this.trades = const [],
    this.isLoading = false,
    this.error,
    this.stockPrices = const {},
  });

  TradingState copyWith({
    Portfolio? portfolio,
    List<Trade>? trades,
    bool? isLoading,
    String? error,
    Map<String, double>? stockPrices,
  }) {
    return TradingState(
      portfolio: portfolio ?? this.portfolio,
      trades: trades ?? this.trades,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      stockPrices: stockPrices ?? this.stockPrices,
    );
  }
}

// Trading Notifier
class TradingNotifier extends StateNotifier<TradingState> {
  final ApiService _apiService;

  TradingNotifier(this._apiService) : super(TradingState());

  Future<void> loadPortfolio() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final portfolioData = await _apiService.getPortfolio();
      final portfolio = Portfolio.fromJson(portfolioData);

      state = state.copyWith(portfolio: portfolio, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> placeTrade({
    required String symbol,
    required TradeType type,
    required double qty,
    required double price,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _apiService.placeTrade(
        symbol: symbol,
        side: type == TradeType.buy ? 'BUY' : 'SELL',
        qty: qty,
        price: price,
      );

      // Update portfolio with the response
      if (result['portfolio'] != null) {
        final portfolio = Portfolio.fromJson(result['portfolio']);
        state = state.copyWith(portfolio: portfolio);
      }

      // Add the new trade to the list
      if (result['trade'] != null) {
        final trade = Trade.fromJson(result['trade']);
        state = state.copyWith(trades: [trade, ...state.trades]);
      }

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateStockPrice(String symbol) async {
    try {
      final stockData = await _apiService.getStockQuote(symbol);
      final price = stockData['price']?.toDouble() ?? 0.0;

      state = state.copyWith(
        stockPrices: {...state.stockPrices, symbol: price},
      );
    } catch (e) {
      // Handle error silently for stock price updates
      // Error logging could be added here for debugging
    }
  }

  Future<List<Map<String, dynamic>>> searchStocks(String query) async {
    try {
      return await _apiService.searchStocks(query);
    } catch (e) {
      throw Exception('Failed to search stocks: $e');
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Trading Providers
final tradingProvider = StateNotifierProvider<TradingNotifier, TradingState>((
  ref,
) {
  final apiService = ref.read(apiServiceProvider);
  return TradingNotifier(apiService);
});

// Portfolio Provider (Separate for auto-refresh)
final portfolioProvider = FutureProvider<Portfolio?>((ref) async {
  final apiService = ref.read(apiServiceProvider);

  try {
    final portfolioData = await apiService.getPortfolio();
    return Portfolio.fromJson(portfolioData);
  } catch (e) {
    return null;
  }
});

// Stock Search Provider
final stockSearchProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      query,
    ) async {
      if (query.isEmpty) return [];

      final tradingNotifier = ref.read(tradingProvider.notifier);
      return await tradingNotifier.searchStocks(query);
    });

// Portfolio Value Provider
final portfolioValueProvider = Provider<double>((ref) {
  final tradingState = ref.watch(tradingProvider);

  if (tradingState.portfolio == null) return 0.0;

  double totalValue = tradingState.portfolio!.cashBalance;

  tradingState.portfolio!.holdings.forEach((symbol, quantity) {
    final price = tradingState.stockPrices[symbol] ?? 0.0;
    totalValue += price * quantity;
  });

  return totalValue;
});

// Trading Service Provider
final tradingServiceProvider = Provider<TradingService>(
  (ref) => TradingService(ref.read(apiServiceProvider)),
);

class TradingService {
  final ApiService _apiService;

  TradingService(this._apiService);

  Future<Portfolio> getPortfolio() async {
    final portfolioData = await _apiService.getPortfolio();
    return Portfolio.fromJson(portfolioData);
  }

  Future<Map<String, dynamic>> placeTrade({
    required String symbol,
    required TradeType type,
    required double qty,
    required double price,
  }) async {
    return await _apiService.placeTrade(
      symbol: symbol,
      side: type == TradeType.buy ? 'BUY' : 'SELL',
      qty: qty,
      price: price,
    );
  }

  Future<Map<String, dynamic>> getStockQuote(String symbol) async {
    return await _apiService.getStockQuote(symbol);
  }

  Future<List<Map<String, dynamic>>> searchStocks(String query) async {
    return await _apiService.searchStocks(query);
  }
}
