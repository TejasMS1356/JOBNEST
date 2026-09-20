---
name: testing-jobfinder
description: Run JobFinder's Android demo UI checks and capture README screenshots on the emulator.
---

# Android UI testing

## Environment
- SDK paths on this box: Flutter `~/flutter/bin`, Android `~/Android`.
- Set `PATH="$HOME/flutter/bin:$PATH"` and `ANDROID_HOME="$HOME/Android"`.
- Check `~/Android/platform-tools/adb devices` before starting an emulator;
  reuse an existing `emulator-5554` rather than launching another.
- If KVM membership was granted after login, an emulator may need to start via
  `sg kvm -c 'emulator -avd pixel ...'`.
- Preserve `~/.gradle/init.gradle.kts`: it may route rate-limited Maven Central
  requests to a working mirror.
- Build: `flutter build apk --release`.
- Install preserving state:
  `~/Android/platform-tools/adb install -r build/app/outputs/flutter-apk/app-release.apk`.
- Launch: `adb shell am start -n com.nanditha.job_finder/.MainActivity`.
- Persistence test: `adb shell am force-stop com.nanditha.job_finder`, then launch;
  do not clear package data.

## Devin Secrets Needed
None for bundled demo-mode UI testing. Real Adzuna calls require compile-time
`ADZUNA_APP_ID` and `ADZUNA_APP_KEY`; do not confuse demo tests with live API tests.

## UI checks and evidence
- Demo dataset contains 8 jobs. Filter counts: Full time 6, Part time 2,
  Contract 3, Permanent 5, Internship 2. `flutter` matches one job.
- Search must stay consistent after Jobs → Favorites → Jobs. Verify query and X
  survive both matching and empty-result searches, then clear back to 8 jobs.
- Favorites removal swipes right-to-left. Tap snackbar Undo promptly.
- Emulator input may not accept clipboard-based desktop typing. Focus the search
  field, then use `adb shell input text flutter` and `adb shell input keyevent 66`.
- Apply opens external Chrome; its first-run prompt counts as a launch attempt.
  Return with `adb shell input keyevent 4`; no browser sign-in needed.
- Use `adb exec-out screencap -p > docs/screenshots/<name>.png` for full-resolution
  device images, not desktop screenshots. Inspect PNGs for clipped system icons;
  rotating the emulator out of and back into portrait may repair stale insets.
- README filenames: home_light.png, search.png, details.png, favorites.png,
  home_dark.png. Hide keyboard/snackbars before capture.
- Capture logcat and inspect RenderFlex/overflow/flutter exceptions. Release mode
  omits debug assertions, so a clean release log alone cannot prove no overflow.
- Nested virtualization can skip animation frames. Inspect video frames for
  skeleton/Hero transitions and report inconclusive animation evidence honestly.
