import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wallet.dart';

/// States prohibited for real-money sweepstakes under common legal
/// interpretation. Enforced at account + geo level. Placeholder list -
/// production impl should pull from compliance service.
const kProhibitedStates = {'WA', 'ID', 'MT', 'NV', 'MI'};

class ProfileController extends StateNotifier<UserProfile> {
  ProfileController()
      : super(const UserProfile(
          state: 'CA',
          kyc: KycStatus.none,
          selfExcluded: false,
          dailyDepositLimitCents: 50000,
        ));

  void setState(String s) => state = state.copyWith(state: s);
  void setKyc(KycStatus s) => state = state.copyWith(kyc: s);
  void setSelfExcluded(bool v) => state = state.copyWith(selfExcluded: v);
  void setDailyLimitCents(int cents) =>
      state = state.copyWith(dailyDepositLimitCents: cents);
}

final profileProvider = StateNotifierProvider<ProfileController, UserProfile>(
  (ref) => ProfileController(),
);

bool isEligibleForRealMoney(UserProfile p) =>
    p.kyc == KycStatus.verified &&
    !p.selfExcluded &&
    !kProhibitedStates.contains(p.state.toUpperCase());
