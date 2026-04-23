enum Currency {
  /// Gold Coins - entertainment-only, no cash value, purchased with real money.
  gc,

  /// Sweepstakes Coins - free promotional currency, redeemable for prizes.
  /// Obtainable without purchase (mail-in alternative required by law).
  sc,
}

class Wallet {
  final int gc;
  final int sc;
  const Wallet({required this.gc, required this.sc});

  Wallet copyWith({int? gc, int? sc}) =>
      Wallet(gc: gc ?? this.gc, sc: sc ?? this.sc);
}

class WalletTxn {
  final DateTime at;
  final Currency currency;
  final int delta;
  final String reason;
  const WalletTxn({
    required this.at,
    required this.currency,
    required this.delta,
    required this.reason,
  });
}

enum KycStatus { none, pending, verified, rejected }

class UserProfile {
  final String state;
  final KycStatus kyc;
  final bool selfExcluded;
  final int dailyDepositLimitCents;

  const UserProfile({
    required this.state,
    required this.kyc,
    required this.selfExcluded,
    required this.dailyDepositLimitCents,
  });

  UserProfile copyWith({String? state, KycStatus? kyc, bool? selfExcluded, int? dailyDepositLimitCents}) =>
      UserProfile(
        state: state ?? this.state,
        kyc: kyc ?? this.kyc,
        selfExcluded: selfExcluded ?? this.selfExcluded,
        dailyDepositLimitCents: dailyDepositLimitCents ?? this.dailyDepositLimitCents,
      );
}
