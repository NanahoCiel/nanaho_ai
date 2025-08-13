// lib/screens/trade_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../providers/user_provider.dart';
import '../services/trade_service.dart';
import '../theme.dart';

class TradeScreen extends StatefulWidget {
  const TradeScreen({super.key});
  @override
  State<TradeScreen> createState() => _TradeScreenState();
}

class _TradeScreenState extends State<TradeScreen> {
  final _symbolCtrl = TextEditingController(text: 'AAPL');
  final _priceCtrl = TextEditingController(text: '250000'); // KRW
  final _qtyCtrl = TextEditingController(text: '1');
  AssetType _type = AssetType.stock;
  bool _isBuy = true;
  bool _busy = false;
  final List<String> _recent = [];

  void _addRecent(String s) {
    _recent.remove(s);
    _recent.insert(0, s);
    if (_recent.length > 10) _recent.removeLast();
  }

  @override
  void dispose() {
    _symbolCtrl.dispose();
    _priceCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final symbol = _symbolCtrl.text.trim().toUpperCase();
    final price = double.tryParse(_priceCtrl.text.replaceAll(',', '')) ?? 0;
    final qty = double.tryParse(_qtyCtrl.text) ?? 0;
    if (symbol.isEmpty || price <= 0 || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('심볼/가격/수량을 확인해주세요')),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      await TradeService.executeTrade(
        context: context,
        symbol: symbol,
        type: _type,
        price: price, // TradeService가 KRW 계산을 해줌
        quantity: qty,
        isBuy: _isBuy,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('거래')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<AssetType>(
                          value: _type,
                          decoration: const InputDecoration(labelText: '자산 종류'),
                          items: const [
                            DropdownMenuItem(value: AssetType.stock, child: Text('주식')),
                            DropdownMenuItem(value: AssetType.coin, child: Text('코인')),
                          ],
                          onChanged: (v) => setState(() => _type = v ?? AssetType.stock),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<bool>(
                          value: _isBuy,
                          decoration: const InputDecoration(labelText: '매수/매도'),
                          items: const [
                            DropdownMenuItem(value: true, child: Text('매수')),
                            DropdownMenuItem(value: false, child: Text('매도')),
                          ],
                          onChanged: (v) => setState(() => _isBuy = v ?? true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _symbolCtrl,
                    decoration: InputDecoration(
                      labelText: '심볼 (예: AAPL, BTCUSDT)',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () async {
                          final result = await showSearch<String>(
                            context: context,
                            delegate: SymbolSearchDelegate(
                              type: _type,
                              recent: _recent,
                              onSelected: _addRecent,
                            ),
                          );
                          if (result != null) _symbolCtrl.text = result;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '가격 (KRW)'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _qtyCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: '수량'),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('보유 현금: ' + krw(user.cashKRW),
                        style: const TextStyle(color: Colors.white70)),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _busy ? null : _submit,
                      icon: Icon(_isBuy ? Icons.call_made : Icons.call_received),
                      label: Text(_isBuy ? '매수 실행' : '매도 실행'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SymbolSearchDelegate extends SearchDelegate<String> {
  final AssetType type;
  final List<String> recent;
  final ValueChanged<String> onSelected;
  SymbolSearchDelegate({required this.type, required this.recent, required this.onSelected});

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return ListView(
        children: [
          for (final s in recent)
            ListTile(
              leading: const Icon(Icons.history),
              title: Text(s),
              onTap: () {
                query = s;
                showResults(context);
              },
            )
        ],
      );
    }
    return FutureBuilder<List<String>>(
      future: _search(query, type),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final results = snapshot.data!;
        return ListView(
          children: [
            for (final s in results)
              ListTile(
                title: Text(s),
                onTap: () {
                  onSelected(s);
                  close(context, s);
                },
              )
          ],
        );
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) => const SizedBox.shrink();

  @override
  List<Widget>? buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => query = '',
          )
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  Future<List<String>> _search(String q, AssetType type) async {
    try {
      if (type == AssetType.stock) {
        final uri = Uri.parse('https://query1.finance.yahoo.com/v1/finance/search?q=$q');
        final res = await http.get(uri);
        if (res.statusCode != 200) return [];
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final quotes = data['quotes'] as List<dynamic>? ?? [];
        return quotes.map((e) => e['symbol'].toString()).toList();
      } else {
        final uri = Uri.parse('https://api.coingecko.com/api/v3/search?query=$q');
        final res = await http.get(uri);
        if (res.statusCode != 200) return [];
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final coins = data['coins'] as List<dynamic>? ?? [];
        return coins.take(100).map((e) => e['symbol'].toString().toUpperCase()).toList();
      }
    } catch (_) {
      return [];
    }
  }
}

