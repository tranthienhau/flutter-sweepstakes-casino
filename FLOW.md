# Screenshot capture flow

Real captures from the iOS Simulator via an integration-test driver (no mockups).

## Steps

1. Boot the simulator:
   ```bash
   xcrun simctl boot "iPhone 16e"
   open -a Simulator
   ```
2. Scaffold the iOS platform folder (lib-only project) and get dependencies:
   ```bash
   flutter create . --platforms=ios --project-name flutter_sweepstakes_casino
   flutter pub get
   ```
3. Drive the screenshot test:
   ```bash
   flutter drive \
     --driver test_driver/integration_test.dart \
     --target integration_test/screenshot_test.dart \
     -d "iPhone 16e"
   ```
4. Build the demo GIF from the PNGs:
   ```bash
   cd screenshots
   ffmpeg -y -framerate 1 -pattern_type glob -i '*.png' \
     -vf "scale=320:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
     -loop 0 demo.gif
   ```

PNGs + `demo.gif` are written to `screenshots/` and embedded in `README.md`.

## How it works

- `test_driver/integration_test.dart` - `integrationDriver(onScreenshot:)` writes each PNG to `screenshots/<name>.png`.
- `integration_test/screenshot_test.dart` - pumps each key screen directly under a `ProviderScope` + themed `MaterialApp` (no Firebase/network init needed), then calls `binding.convertFlutterSurfaceToImage()` + `binding.takeScreenshot('NN-name')`:
  - `01-home` - `HomeScreen`: dual-currency wallet card (50000 GC / 100 SC) and the Crash/Dice/Mines/Plinko/Slots game grid.
  - `02-mines` - `MinesGame`: taps "Place bet" then reveals several grid cells so the board shows a live round with multiplier and cashout.
  - `03-kyc` - `KycScreen`: identity-verification status machine, geo-eligibility state chips, responsible-gaming controls.
  - `04-wallet` - `WalletScreen`: Gold Coin purchase packs, Sweeps Coin redemption gating, and the no-purchase-necessary mail-in flow.

Note: if the simulator has a leftover system permission dialog from another app in the foreground, the GPU surface read-back can come back blank. Dismiss any modal alert on the device before driving.
