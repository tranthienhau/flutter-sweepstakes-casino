import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wallet.dart';

class WalletController extends StateNotifier<Wallet> {
  WalletController() : super(const Wallet(gc: 50000, sc: 100));

  final List<WalletTxn> history = [];

  void credit(Currency c, int amount, String reason) {
    history.add(WalletTxn(at: DateTime.now(), currency: c, delta: amount, reason: reason));
    state = c == Currency.gc
        ? state.copyWith(gc: state.gc + amount)
        : state.copyWith(sc: state.sc + amount);
  }

  bool debit(Currency c, int amount, String reason) {
    final balance = c == Currency.gc ? state.gc : state.sc;
    if (balance < amount) return false;
    history.add(WalletTxn(at: DateTime.now(), currency: c, delta: -amount, reason: reason));
    state = c == Currency.gc
        ? state.copyWith(gc: state.gc - amount)
        : state.copyWith(sc: state.sc - amount);
    return true;
  }
}

final walletProvider = StateNotifierProvider<WalletController, Wallet>(
  (ref) => WalletController(),
);

final selectedCurrencyProvider = StateProvider<Currency>((ref) => Currency.gc);
