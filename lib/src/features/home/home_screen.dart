import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/wallet_store.dart';
import '../../models/wallet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletProvider);
    final currency = ref.watch(selectedCurrencyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sweeps Casino'),
        actions: [
          IconButton(icon: const Icon(Icons.verified_user), onPressed: () => context.push('/kyc')),
          IconButton(icon: const Icon(Icons.account_balance_wallet), onPressed: () => context.push('/wallet')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _BalanceCard(wallet: wallet, selected: currency, onToggle: (c) => ref.read(selectedCurrencyProvider.notifier).state = c),
          const SizedBox(height: 8),
          const _Disclaimer(),
          const SizedBox(height: 16),
          const Text('Games', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: const [
              _GameTile(label: 'Crash', route: '/crash', color: Color(0xFFEF4444), icon: Icons.trending_up),
              _GameTile(label: 'Dice', route: '/dice', color: Color(0xFF8B5CF6), icon: Icons.casino),
              _GameTile(label: 'Mines', route: '/mines', color: Color(0xFFF59E0B), icon: Icons.grid_on),
              _GameTile(label: 'Plinko', route: '/plinko', color: Color(0xFF10B981), icon: Icons.bubble_chart),
              _GameTile(label: 'Slots', route: '/slots', color: Color(0xFF3B82F6), icon: Icons.local_play),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final Wallet wallet;
  final Currency selected;
  final ValueChanged<Currency> onToggle;
  const _BalanceCard({required this.wallet, required this.selected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _Balance(
                label: 'Gold Coins',
                value: wallet.gc.toString(),
                color: const Color(0xFFFBBF24),
                selected: selected == Currency.gc,
                onTap: () => onToggle(Currency.gc),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Balance(
                label: 'Sweeps Coins',
                value: wallet.sc.toString(),
                color: const Color(0xFF10B981),
                selected: selected == Currency.sc,
                onTap: () => onToggle(Currency.sc),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Balance extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const _Balance({
    required this.label,
    required this.value,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? color : Colors.white12, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class _GameTile extends StatelessWidget {
  final String label;
  final String route;
  final Color color;
  final IconData icon;
  const _GameTile({required this.label, required this.route, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(route),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _Disclaimer extends StatelessWidget {
  const _Disclaimer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white10,
      ),
      child: const Text(
        'No purchase necessary. SC are free promotional currency obtainable via mail-in alternative. GC are entertainment only and have no cash value.',
        style: TextStyle(fontSize: 12, color: Colors.white60),
      ),
    );
  }
}
