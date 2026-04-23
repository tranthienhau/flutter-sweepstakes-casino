import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/wallet_store.dart';
import '../common/bet_bar.dart';

class DiceGame extends ConsumerStatefulWidget {
  const DiceGame({super.key});

  @override
  ConsumerState<DiceGame> createState() => _DiceGameState();
}

class _DiceGameState extends ConsumerState<DiceGame> {
  double _target = 50;
  int _roll = 0;
  bool _won = false;
  String _status = 'Roll under the target to win.';

  double get _multiplier => 99 / _target;

  void _play(int bet, c) {
    final ok = ref.read(walletProvider.notifier).debit(c, bet, 'Dice bet');
    if (!ok) return;
    final r = Random().nextInt(101);
    final won = r < _target;
    setState(() {
      _roll = r;
      _won = won;
      if (won) {
        final payout = (bet * _multiplier).round();
        ref.read(walletProvider.notifier).credit(c, payout, 'Dice win');
        _status = 'Rolled $r - won $payout';
      } else {
        _status = 'Rolled $r - lost';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dice')),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('$_roll',
                      style: TextStyle(
                        fontSize: 96,
                        fontWeight: FontWeight.w900,
                        color: _won ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      )),
                  Text(_status),
                  const SizedBox(height: 24),
                  Text('Roll under: ${_target.round()} (${_multiplier.toStringAsFixed(2)}x)'),
                  Slider(
                    value: _target,
                    min: 5,
                    max: 95,
                    divisions: 90,
                    onChanged: (v) => setState(() => _target = v),
                  ),
                ],
              ),
            ),
          ),
          BetBar(onBet: _play),
        ],
      ),
    );
  }
}
