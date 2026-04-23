import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/wallet_store.dart';
import '../../data/profile_store.dart';
import '../../models/wallet.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletProvider);
    final profile = ref.watch(profileProvider);
    final eligible = isEligibleForRealMoney(profile);

    return Scaffold(
      appBar: AppBar(title: const Text('Wallet')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Section(title: 'Buy Gold Coins', child: Column(children: [
            _PackRow(coins: 10000, priceCents: 999, onTap: () => _purchaseGc(ref, 10000, '\$9.99')),
            _PackRow(coins: 50000, priceCents: 4999, onTap: () => _purchaseGc(ref, 50000, '\$49.99')),
            _PackRow(coins: 120000, priceCents: 9999, onTap: () => _purchaseGc(ref, 120000, '\$99.99')),
          ])),
          const SizedBox(height: 16),
          _Section(
            title: 'Redeem Sweeps Coins',
            child: Column(children: [
              const Text('1 SC = \$1 redemption. KYC + eligible state required.', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: (eligible && wallet.sc >= 50)
                    ? () => _redeem(ref, 50)
                    : null,
                child: Text(eligible ? 'Redeem 50 SC (\$50)' : 'KYC + eligible state required'),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'No Purchase Necessary',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Request free SC by mailing a 3x5 card with your name, address, and email to:',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                const Text('Sweeps Casino Promotions\n123 Any Street\nAny City, XX 00000',
                    style: TextStyle(color: Colors.white)),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => ref.read(walletProvider.notifier).credit(Currency.sc, 5, 'NPN free grant'),
                  child: const Text('Simulate approved mail-in'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _purchaseGc(WidgetRef ref, int coins, String label) {
    ref.read(walletProvider.notifier).credit(Currency.gc, coins, 'Purchase $label');
    ref.read(walletProvider.notifier).credit(Currency.sc, (coins / 1000).round(), 'Bonus SC with purchase');
  }

  void _redeem(WidgetRef ref, int sc) {
    ref.read(walletProvider.notifier).debit(Currency.sc, sc, 'Redemption (pending payout)');
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _PackRow extends StatelessWidget {
  final int coins;
  final int priceCents;
  final VoidCallback onTap;
  const _PackRow({required this.coins, required this.priceCents, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text('$coins GC'),
      subtitle: Text('+${(coins / 1000).round()} bonus SC'),
      trailing: ElevatedButton(
        onPressed: onTap,
        child: Text('\$${(priceCents / 100).toStringAsFixed(2)}'),
      ),
    );
  }
}
