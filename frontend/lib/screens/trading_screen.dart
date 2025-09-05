import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/trading_provider.dart';
import '../models/trade.dart';

class TradingScreen extends ConsumerStatefulWidget {
  const TradingScreen({super.key});

  @override
  ConsumerState<TradingScreen> createState() => _TradingScreenState();
}

class _TradingScreenState extends ConsumerState<TradingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  final _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    Future.microtask(() {
      ref.read(tradingProvider.notifier).loadPortfolio();
      // Load stock prices for popular stocks
      _loadStockPrices();
    });
  }

  void _loadStockPrices() {
    final popularSymbols = ['AAPL', 'GOOGL', 'MSFT', 'TSLA', 'AMZN'];
    for (String symbol in popularSymbols) {
      ref.read(tradingProvider.notifier).updateStockPrice(symbol);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tradingState = ref.watch(tradingProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Virtual Trading'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              _loadUserData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Refreshing data...'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Data',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Portfolio'),
            Tab(text: 'Trade'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPortfolioTab(tradingState),
          _buildTradeTab(),
          _buildHistoryTab(tradingState),
        ],
      ),
    );
  }

  Widget _buildPortfolioTab(TradingState tradingState) {
    if (tradingState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (tradingState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error: ${tradingState.error}',
              style: const TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(tradingProvider.notifier).clearError();
                _loadUserData();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (tradingState.portfolio == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No portfolio data available',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final portfolio = tradingState.portfolio!;
    final totalValue = ref.watch(portfolioValueProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Portfolio Summary
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Portfolio Value',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${totalValue.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cash Balance',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '₹${portfolio.cashBalance.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Invested',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '₹${(totalValue - portfolio.cashBalance).toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Holdings
          const Text(
            'Holdings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 16),

          if (portfolio.holdings.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No holdings yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  Text(
                    'Start trading to build your portfolio',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          else
            ...portfolio.holdings.entries.map((entry) {
              final symbol = entry.key;
              final quantity = entry.value;
              final price = tradingState.stockPrices[symbol] ?? 0.0;
              final value = price * quantity;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        symbol.substring(0, 2).toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                  ),
                  title: Text(symbol),
                  subtitle: Text(
                    '$quantity shares × ₹${price.toStringAsFixed(2)}',
                  ),
                  trailing: Text(
                    '₹${value.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildTradeTab() {
    final tradingState = ref.watch(tradingProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Stocks
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search stocks (e.g., AAPL, GOOGL)',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSubmitted: _searchStocks,
          ),
          const SizedBox(height: 24),

          // Popular Stocks
          const Text(
            'Popular Stocks',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 16),

          _buildStockCard(
            'AAPL',
            'Apple Inc.',
            tradingState.stockPrices['AAPL'] ?? 150.50,
            2.5,
          ),
          _buildStockCard(
            'GOOGL',
            'Alphabet Inc.',
            tradingState.stockPrices['GOOGL'] ?? 2800.75,
            -1.2,
          ),
          _buildStockCard(
            'MSFT',
            'Microsoft Corp.',
            tradingState.stockPrices['MSFT'] ?? 350.25,
            1.8,
          ),
          _buildStockCard(
            'TSLA',
            'Tesla Inc.',
            tradingState.stockPrices['TSLA'] ?? 800.90,
            -3.5,
          ),
          _buildStockCard(
            'AMZN',
            'Amazon.com Inc.',
            tradingState.stockPrices['AMZN'] ?? 3200.45,
            0.8,
          ),
        ],
      ),
    );
  }

  Widget _buildStockCard(
    String symbol,
    String name,
    double price,
    double change,
  ) {
    final isPositive = change >= 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showTradeDialog(symbol, name, price),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    symbol.substring(0, 2),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      symbol,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      name,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${isPositive ? '+' : ''}${change.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: isPositive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryTab(TradingState tradingState) {
    if (tradingState.trades.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No trading history',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tradingState.trades.length,
      itemBuilder: (context, index) {
        final trade = tradingState.trades[index];
        return _buildTradeHistoryCard(trade);
      },
    );
  }

  Widget _buildTradeHistoryCard(Trade trade) {
    final isBuy = trade.type == TradeType.buy;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (isBuy ? Colors.green : Colors.red).withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isBuy ? Icons.arrow_upward : Icons.arrow_downward,
                color: isBuy ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${isBuy ? 'BUY' : 'SELL'} ${trade.symbol}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${trade.quantity} shares × ₹${trade.price.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${trade.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  _formatDate(trade.timestamp),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _searchStocks(String query) async {
    if (query.trim().isEmpty) return;

    try {
      final results = await ref
          .read(tradingProvider.notifier)
          .searchStocks(query);

      if (results.isNotEmpty && mounted) {
        _showSearchResults(results);
      } else if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('No results found for: $query')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Search failed: $e')));
      }
    }
  }

  void _showSearchResults(List<Map<String, dynamic>> results) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Search Results',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final stock = results[index];
                  return ListTile(
                    title: Text(stock['1. symbol'] ?? 'Unknown'),
                    subtitle: Text(stock['2. name'] ?? 'Unknown Company'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.pop(context);
                      // You can add navigation to stock detail or trade dialog here
                      _showTradeDialog(
                        stock['1. symbol'] ?? 'UNKNOWN',
                        stock['2. name'] ?? 'Unknown Company',
                        100.0, // Default price, should fetch real price
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTradeDialog(String symbol, String name, double price) async {
    // Update stock price before showing dialog
    await ref.read(tradingProvider.notifier).updateStockPrice(symbol);
    final currentPrice = ref.read(tradingProvider).stockPrices[symbol] ?? price;

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Trade $symbol'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              '₹${currentPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
                helperText: 'Number of shares to trade',
              ),
            ),
            const SizedBox(height: 16),
            Consumer(
              builder: (context, ref, child) {
                final quantity = int.tryParse(_quantityController.text) ?? 0;
                final totalCost = quantity * currentPrice;
                return Text(
                  'Total: ₹${totalCost.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _executeTrade(symbol, TradeType.buy, currentPrice),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Buy'),
          ),
          ElevatedButton(
            onPressed: () =>
                _executeTrade(symbol, TradeType.sell, currentPrice),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sell'),
          ),
        ],
      ),
    );
  }

  void _executeTrade(String symbol, TradeType type, double price) {
    final quantity = int.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid quantity')),
      );
      return;
    }

    ref
        .read(tradingProvider.notifier)
        .placeTrade(
          symbol: symbol,
          type: type,
          qty: quantity.toDouble(),
          price: price,
        )
        .then((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Successfully ${type == TradeType.buy ? 'bought' : 'sold'} $quantity shares of $symbol',
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        })
        .catchError((error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Trade failed: $error'),
                backgroundColor: Colors.red,
              ),
            );
          }
        });

    Navigator.pop(context);
    _quantityController.clear();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
