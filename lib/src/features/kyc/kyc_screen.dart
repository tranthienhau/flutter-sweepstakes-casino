import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/profile_store.dart';
import '../../models/wallet.dart';

class KycScreen extends ConsumerWidget {
  const KycScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final ctl = ref.read(profileProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('KYC & Eligibility')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Identity verification', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text('Status: ${profile.kyc.name.toUpperCase()}'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => ctl.setKyc(KycStatus.pending),
                        child: const Text('Start (Persona)'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => ctl.setKyc(KycStatus.verified),
                        child: const Text('Simulate verified'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Geo-eligibility', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text('State: ${profile.state}'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['CA', 'TX', 'NY', 'WA', 'MT', 'ID', 'NV']
                        .map((st) => ChoiceChip(
                              label: Text(st),
                              selected: profile.state == st,
                              onSelected: (_) => ctl.setState(st),
                            ))
                        .toList(),
                  ),
                  if (kProhibitedStates.contains(profile.state.toUpperCase()))
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text('Blocked in your state.', style: TextStyle(color: Color(0xFFEF4444))),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Responsible gaming', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: profile.selfExcluded,
                    onChanged: ctl.setSelfExcluded,
                    title: const Text('Self-exclude'),
                  ),
                  Text('Daily deposit limit: \$${(profile.dailyDepositLimitCents / 100).toStringAsFixed(0)}'),
                  Slider(
                    value: (profile.dailyDepositLimitCents / 100).toDouble(),
                    min: 0,
                    max: 2000,
                    divisions: 20,
                    onChanged: (v) => ctl.setDailyLimitCents((v * 100).round()),
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
