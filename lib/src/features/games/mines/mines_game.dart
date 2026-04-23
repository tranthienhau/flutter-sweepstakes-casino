import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/wallet_store.dart';
import '../../../models/wallet.dart';
import '../common/bet_bar.dart';

class MinesGame extends ConsumerStatefulWidget {
  const MinesGame({super.key});

  @override
  ConsumerState<MinesGame> createState() => _MinesGameState();
}

class _MinesGameState extends ConsumerState<MinesGame> {
  static const _size = 5;
  final _mines = <int>{};
  final _revealed = <int>{};
  bool _playing = false;
  bool _busted = false;
  int _bet = 0;
  Currency _currency = Currency.gc;
  int _mineCount = 5;

  double get _multiplier {
    final safe = _size * _size - _mineCount;
    final picks = _revealed.length;
    if (picks == 0) return 1.0;
    var m = 1.0;
    for (var i = 0; i < picks; i++) {
      m *= (safe - i) / (safe - i - _mineCount * (i + 1) / safe);
    }
    return max(1.0, m);
  }

  void _start(int bet, Currency c) {
    final ok = ref.read(walletProvider.notifier).debit(c, bet, 'Mines bet');
    if (!ok) return;
    setState(() {
      _bet = bet;
      _currency = c;
      _mines.clear();
      _revealed.clear();
      _busted = false;
      _playing = true;
      final rng = Random();
      while (_mines.length < _mineCount) {
        _mines.add(rng.nextInt(_size * _size));
      }
    });
  }

  void _reveal(int i) {
    if (!_playing || _busted || _revealed.contains(i)) return;
    setState(() {
      _revealed.add(i);
      if (_mines.contains(i)) {
        _busted = true;
        _playing = false;
      }
    });
  }

  void _cashout() {
    if (!_playing || _revealed.isEmpty) return;
    final win = (_bet * _multiplier).round();
    ref.read(walletProvider.notifier).credit(_currency, win, 'Mines cashout');
    setState(() => _playing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mines')),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Text('Mines: $_mineCount - Multiplier: ${_multiplier.toStringAsFixed(2)}x'),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _size * _size,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _size,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemBuilder: (_, i) {
                final isMine = _mines.contains(i);
                final revealed = _revealed.contains(i);
                Color bg = const Color(0xFF1F2937);
                String label = '';
                if (revealed) {
                  bg = isMine ? const Color(0xFFEF4444) : const Color(0xFF10B981);
                  label = isMine ? '💣' : '💎';
                } else if (_busted && isMine) {
                  bg = const Color(0xFFEF4444);
                  label = '💣';
                }
                return GestureDetector(
                  onTap: () => _reveal(i),
                  child: Container(
                    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
                    child: Center(child: Text(label, style: const TextStyle(fontSize: 24))),
                  ),
                );
              },
            ),
          ),
          if (_playing && _revealed.isNotEmpty)
            ElevatedButton(
              onPressed: _cashout,
              child: Text('Cash out (${(_bet * _multiplier).round()})'),
            ),
          const Spacer(),
          BetBar(disabled: _playing, onBet: _start),
        ],
      ),
    );
  }
}
