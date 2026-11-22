# Homio Essentials — mobile app (Flutter)

Bilingual (English / বাংলা) homeopathic medicine archive for Android and iOS.
716 remedies with Boericke's Materia Medica and Allen's Keynotes, reviewed uses
and doses by age, offline search (Latin, Bangla, Banglish, voice), and source
references checked against the printed books.

## Run
```
# from the backend repo root: writes env.json (Supabase URL + public anon key, git-ignored)
node --env-file=.env scripts/app-env.mjs

flutter pub get
flutter run --dart-define-from-file=env.json
flutter analyze && flutter test
```
`env.example.json` shows the expected keys. The anon key is public by design —
row-level security decides what the app can read and write.

## Architecture — Clean architecture + MVVM, feature-first (same structure as FocusFlow)
```
lib/
  main.dart · bootstrap.dart · app.dart
  core/      constants/ config/ network/ (Dio + PostgREST) storage/ theme/ widgets/ (Hm* design system)
             router/ (AppRoutes, AppRouter, AppShell) ads/ (AdMob) platform/ (voice) l10n/ utils/
             archive/  shared kernel: domain (entities, repository contract) + data (Dio datasources, impl)
  shared/    providers/ (core singletons, settings, repositories, archive store, library) widgets/
  features/<feature>/
    data/          datasource/ repository/ (implementations)
    domain/        entities/ repository/ (contracts) services/ — pure Dart
    presentation/  providers/ notifiers/ screens/ widgets/ + <feature>_routes.dart
```
Features: onboarding, home, explore, search, remedy, condition, saved, settings, requests, promotions.

- State: flutter_riverpod 3 (`Provider`, `FutureProvider`, `Notifier`, `AsyncNotifier`, `.family`, `.autoDispose`). Screens read view-model
  providers (`XUiState` + `XController`); no business logic in widgets; presentation never sees Dio.
- Network: Dio → Supabase REST (`core/network/dio_client.dart`): auth headers, retry on network errors, typed `ApiException`.
- Offline: the archive (≈1 MB) is downloaded once and re-downloaded only when `sync_manifest()` changes; book text is cached per remedy.
- Routing: go_router 18, `StatefulShellRoute.indexedStack` for the 4 tabs; paths in `core/router/app_routes.dart`.
- Material comes from the `material_ui` package (Flutter 3.47 moved it out of the SDK) — import `package:material_ui/material_ui.dart`.
- Strings: ARB files in `lib/l10n` (`flutter gen-l10n` → class `L`), English + বাংলা.

## UI notes (design system `Hm*`, motion and layout rules)
- **Fonts are bundled** (`assets/fonts`, no runtime download): Lexend Deca headings + Nunito Sans body/italic Latin names (as FocusFlow), Hind Siliguri for Bangla
  (from mgi_recruitment). The earlier google_fonts setup fetched every weight over the network on first use, so text swapped font after the first frame.
- **Type scale** follows FocusFlow: semibold titles, 14–15 body, 12 captions, no extra-bold. Text size composes on top of the OS scaler
  (`AppTextScaler`, Settings › Text size, 6 stops 85–130 %, default 100 %).
- **Pinned headers**: tab screens use `HmTabPage` — the header (title, search, segmented control) stays put and a hairline appears under it
  only once the content scrolls. Tab lists end with a small `context.barClearance` gap (the body stops above the bar).
- **Bottom bar** (`core/widgets/hm_bottom_nav.dart`, `core/router/app_shell.dart`) is ALWAYS visible: flat bar with one sliding top indicator and an
  outline → solid icon swap (the look of the mgi_recruitment bar), the anchored ad directly above it. A hide-on-scroll mode and its Settings switch were removed.
- **Ads**: anchored banner = standard adaptive (≈ 50–60 dp, capped at 64), inline banners ≤ 60 dp and kept alive inside lists (no reload while scrolling).
- **Remedy details** are one page of collapsible sections (Overview · Indications · Dosage & administration · Keynotes · Safety & precautions ·
  Relationships · Available brands · Materia Medica · Sources & review) with a sticky scroll-spy index — modelled on MedEx's brand pages, plus
  what MedEx lacks (jump index, sources, "archive updated", report-an-error). `?tab=study` etc. still deep-link to a section.
- **Motion**: slide + parallax page transitions (`core/router/page_transitions.dart`, iOS keeps Cupertino for swipe-back), cross-fading tabs that keep
  their state, press-scale on cards/chips (`HmPressable`), sliding segmented thumb, once-only reveal (`HmReveal(once:)`). Everything respects reduce motion.

## Search
Instant offline index (`features/search/domain/services/search_index.dart`): exact › prefix › phonetic (Banglish) › word › substring ›
typo. Category chips with counts, filters (kingdom, reviewed only, has Bangla), sort, recent searches with undo, popular remedies,
"did you mean", voice search (speech_to_text, bn-BD / en), and online full-text search inside Boericke / Allen.

## Ads (AdMob)
Debug builds use Google's **test** units and always show banners (anchored above the tab bar, inline on detail pages).
Release builds follow the remote switch `app_config.admob.enabled` (editable from the admin app). For release, pass real ids:
`--dart-define=ADMOB_APP_ID_ANDROID=… --dart-define=ADMOB_BANNER_ANDROID=… --dart-define=ADMOB_BANNER_IOS=…`
and set `GADApplicationIdentifier` in `ios/Runner/Info.plist`.

## Icon & splash
Rendered from the same painter as the in-app logo: `flutter test tool/icon/render_icon_test.dart`,
then `dart run flutter_launcher_icons` and `dart run flutter_native_splash:create`.

## Build notes
- Android: `kotlin.incremental=false` in `android/gradle.properties` (project and Pub cache on different drives).
- Application id: `com.homio.essentials`.
- Release builds are minified by R8. `android/app/proguard-rules.pro` (wired in `app/build.gradle.kts`) keeps WorkManager's reflective Room
  database, which the AdMob plugin pulls in. Without it the release APK dies at launch, before Flutter starts, with
  "Failed to create an instance of androidx.work.impl.WorkDatabase". Debug the phone with `adb logcat -d | findstr "FATAL Caused"`.
- Build the installable APK: `flutter build apk --release --dart-define-from-file=env.json` → `build/app/outputs/flutter-apk/app-release.apk`
  (signed with the debug key until a release keystore exists).
