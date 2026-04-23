import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/wallet_store.dart';
import '../../../models/wallet.dart';
import '../common/bet_bar.dart';

class CrashGame extends ConsumerStatefulWidget {
  const CrashGame({super.key});

  @override
  ConsumerState<CrashGame> createState() => _CrashGameState();
}

class _CrashGameState extends ConsumerState<CrashGame> {
  double _mult = 1.0;
  double _crashPoint = 2.0;
  Timer? _timer;
  bool _playing = false;
  bool _cashedOut = false;
  int _bet = 0;
  Currency _currency = Currency.gc;
  String _status = 'Place a bet to play.';

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start(int bet, Currency c) {
    final ok = ref.read(walletProvider.notifier).debit(c, bet, 'Crash bet');
    if (!ok) return;
    _bet = bet;
    _currency = c;
    _mult = 1.0;
    _cashedOut = false;
    _playing = true;
    _status = 'Cash out before the crash.';
    // Exponential crash point with 1% house edge.
    final r = Random().nextDouble();
    _crashPoint = max(1.0, (0.99 / (1.0 - r)));
    _timer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      setState(() {
        _mult += 0.04 * _mult;
        if (_mult >= _crashPoint) {
          _playing = false;
          _status = _cashedOut
              ? _status
              : 'CRASHED at ${_crashPoint.toStringAsFixed(2)}x';
          _timer?.cancel();
        }
      });
    });
  }

  void _cashOut() {
    if (!_playing || _cashedOut) return;
    _cashedOut = true;
    final win = (_bet * _mult).round();
    ref.read(walletProvider.notifier).credit(_currency, win, 'Crash cashout ${_mult.toStringAsFixed(2)}x');
    _status = 'Cashed out at ${_mult.toStringAsFixed(2)}x - won $win';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crash')),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${_mult.toStringAsFixed(2)}x',
                    style: TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.w900,
                      color: _playing
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(_status, style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 16),
                  if (_playing && !_cashedOut)
                    ElevatedButton(
                      onPressed: _cashOut,
                      child: Text('Cash out (${(_bet * _mult).round()})'),
                    ),
                ],
              ),
            ),
          ),
          BetBar(disabled: _playing, onBet: _start),
        ],
      ),
    );
  }
}
