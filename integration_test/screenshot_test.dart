import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_sweepstakes_casino/src/features/home/home_screen.dart';
import 'package:flutter_sweepstakes_casino/src/features/kyc/kyc_screen.dart';
import 'package:flutter_sweepstakes_casino/src/features/wallet/wallet_screen.dart';
import 'package:flutter_sweepstakes_casino/src/features/games/mines/mines_game.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final theme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0A0E1A),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFFBBF24),
      secondary: Color(0xFF10B981),
      surface: Color(0xFF111827),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF111827),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF0A0E1A), elevation: 0),
  );

  Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme,
          home: screen,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> shoot(WidgetTester tester, String name) async {
    await tester.pumpAndSettle();
    await binding.convertFlutterSurfaceToImage();
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    await binding.takeScreenshot(name);
  }

  testWidgets('capture sweepstakes casino flow', (tester) async {
    // 01 - Home: dual-currency wallet + game suite grid.
    await pumpScreen(tester, const HomeScreen());
    await shoot(tester, '01-home');

    // 02 - Mines: place a bet, reveal tiles to show a live board.
    await pumpScreen(tester, const MinesGame());
    final placeBet = find.widgetWithText(ElevatedButton, 'Place bet');
    if (placeBet.evaluate().isNotEmpty) {
      await tester.tap(placeBet);
      await tester.pumpAndSettle();
    }
    final cells = find.byType(GestureDetector);
    final count = cells.evaluate().length;
    for (var i = 0; i < count && i < 6; i++) {
      await tester.tap(cells.at(i));
      await tester.pump(const Duration(milliseconds: 120));
    }
    await shoot(tester, '02-mines');

    // 03 - KYC & eligibility: status machine, geo gating, responsible gaming.
    await pumpScreen(tester, const KycScreen());
    await shoot(tester, '03-kyc');

    // 04 - Wallet: GC packs, SC redemption, no-purchase-necessary flow.
    await pumpScreen(tester, const WalletScreen());
    await shoot(tester, '04-wallet');
  });
}
