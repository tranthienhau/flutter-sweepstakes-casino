import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/wallet_store.dart';
import '../../../models/wallet.dart';

class BetBar extends ConsumerStatefulWidget {
  final void Function(int bet, Currency currency) onBet;
  final bool disabled;
  const BetBar({super.key, required this.onBet, this.disabled = false});

  @override
  ConsumerState<BetBar> createState() => _BetBarState();
}

class _BetBarState extends ConsumerState<BetBar> {
  int _bet = 100;

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletProvider);
    final currency = ref.watch(selectedCurrencyProvider);
    final balance = currency == Currency.gc ? wallet.gc : wallet.sc;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Balance: $balance ${currency.name.toUpperCase()}'),
              Row(children: Currency.values.map((c) => Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: ChoiceChip(
                      label: Text(c.name.toUpperCase()),
                      selected: currency == c,
                      onSelected: (_) =>
                          ref.read(selectedCurrencyProvider.notifier).state = c,
                    ),
                  )).toList()),
            ],
          ),
          Row(
            children: [
              const Text('Bet'),
              Expanded(
                child: Slider(
                  value: _bet.toDouble(),
                  min: 10,
                  max: 1000,
                  divisions: 99,
                  label: '$_bet',
                  onChanged: (v) => setState(() => _bet = v.round()),
                ),
              ),
              Text('$_bet'),
            ],
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.disabled || _bet > balance
                  ? null
                  : () => widget.onBet(_bet, currency),
              child: Text(_bet > balance ? 'Insufficient' : 'Place bet'),
            ),
          ),
        ],
      ),
    );
  }
}
