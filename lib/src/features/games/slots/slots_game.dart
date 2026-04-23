import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/wallet_store.dart';
import '../common/bet_bar.dart';

class SlotsGame extends ConsumerStatefulWidget {
  const SlotsGame({super.key});

  @override
  ConsumerState<SlotsGame> createState() => _SlotsGameState();
}

class _SlotsGameState extends ConsumerState<SlotsGame> {
  static const _symbols = ['🍒', '🍋', '🔔', '⭐', '💎'];
  List<String> _reels = ['🍒', '🍋', '🔔'];
  String _status = 'Spin to play.';

  void _spin(int bet, c) {
    final ok = ref.read(walletProvider.notifier).debit(c, bet, 'Slots bet');
    if (!ok) return;
    final rng = Random();
    setState(() {
      _reels = [for (var i = 0; i < 3; i++) _symbols[rng.nextInt(_symbols.length)]];
      int win = 0;
      if (_reels.toSet().length == 1) {
        win = bet * 10;
      } else if (_reels[0] == _reels[1] || _reels[1] == _reels[2]) {
        win = bet * 2;
      }
      if (win > 0) {
        ref.read(walletProvider.notifier).credit(c, win, 'Slots win');
        _status = 'Won $win';
      } else {
        _status = 'Lost';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Slots')),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _reels
                        .map((s) => Container(
                              margin: const EdgeInsets.all(6),
                              width: 80,
                              height: 100,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1F2937),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                  child: Text(s, style: const TextStyle(fontSize: 48))),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  Text(_status),
                ],
              ),
            ),
          ),
          BetBar(onBet: _spin),
        ],
      ),
    );
  }
}
