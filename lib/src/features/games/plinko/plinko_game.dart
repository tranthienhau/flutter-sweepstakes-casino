import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/wallet_store.dart';
import '../common/bet_bar.dart';

class PlinkoGame extends ConsumerStatefulWidget {
  const PlinkoGame({super.key});

  @override
  ConsumerState<PlinkoGame> createState() => _PlinkoGameState();
}

class _PlinkoGameState extends ConsumerState<PlinkoGame> {
  static const _multipliers = [10.0, 3.0, 1.4, 1.0, 0.5, 1.0, 1.4, 3.0, 10.0];
  int _landedIndex = -1;
  String _status = 'Drop the ball.';

  void _play(int bet, c) {
    final ok = ref.read(walletProvider.notifier).debit(c, bet, 'Plinko bet');
    if (!ok) return;
    // 8-row binomial walk lands in one of 9 buckets.
    final rng = Random();
    var right = 0;
    for (var i = 0; i < 8; i++) {
      if (rng.nextBool()) right++;
    }
    final idx = right;
    final mult = _multipliers[idx];
    final payout = (bet * mult).round();
    if (payout > 0) {
      ref.read(walletProvider.notifier).credit(c, payout, 'Plinko ${mult}x');
    }
    setState(() {
      _landedIndex = idx;
      _status = 'Landed ${mult}x - won $payout';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plinko')),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bubble_chart, size: 80, color: Color(0xFF10B981)),
                  const SizedBox(height: 12),
                  Text(_status),
                ],
              ),
            ),
          ),
          Row(
            children: List.generate(_multipliers.length, (i) {
              final m = _multipliers[i];
              final landed = i == _landedIndex;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.all(2),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: landed ? const Color(0xFFFBBF24) : const Color(0xFF1F2937),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('${m}x',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: landed ? Colors.black : Colors.white70)),
                ),
              );
            }),
          ),
          BetBar(onBet: _play),
        ],
      ),
    );
  }
}
