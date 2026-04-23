import 'package:go_router/go_router.dart';
import 'features/home/home_screen.dart';
import 'features/games/crash/crash_game.dart';
import 'features/games/dice/dice_game.dart';
import 'features/games/mines/mines_game.dart';
import 'features/games/plinko/plinko_game.dart';
import 'features/games/slots/slots_game.dart';
import 'features/wallet/wallet_screen.dart';
import 'features/kyc/kyc_screen.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/wallet', builder: (_, __) => const WalletScreen()),
    GoRoute(path: '/kyc', builder: (_, __) => const KycScreen()),
    GoRoute(path: '/crash', builder: (_, __) => const CrashGame()),
    GoRoute(path: '/dice', builder: (_, __) => const DiceGame()),
    GoRoute(path: '/mines', builder: (_, __) => const MinesGame()),
    GoRoute(path: '/plinko', builder: (_, __) => const PlinkoGame()),
    GoRoute(path: '/slots', builder: (_, __) => const SlotsGame()),
  ],
);
