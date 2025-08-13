// lib/screens/trade_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/trade_service.dart';

class GoldColors {
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFFFD700);
  static const Color goldDark = Color(0xFFB8860B);
  static const Color bg = Color(0xFF121212);
  static const Color card = Color(0xFF1E1E1E);
}


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
                    decoration: const InputDecoration(labelText: '심볼 (예: AAPL, BTCUSDT)'),
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
