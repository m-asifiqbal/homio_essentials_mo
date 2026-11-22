# Homiopedia — mobile app (Flutter)

> Formerly "Homio Essentials" (renamed 2026-11-22). The application id is now `com.iqballabs.homiopedia` (it was `com.homio.essentials`,
> changed before the first release — it can't change once the app is published). The Dart package `homio_essentials` and the `Homio*` class
> names are kept on purpose: they are internal names, not what people or the stores see.

Bilingual (English / বাংলা) homeopathic medicine archive for Android and iOS.
716 remedies with Boericke's Materia Medica and Allen's Keynotes, reviewed uses
and doses by age, instant search (Latin, Bangla, Banglish, voice), and source
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
- Network (Dio + MVVM + Riverpod): `core/network/dio_client.dart` builds the one Dio (`buildDio`: auth headers, retry on network errors, a
  `NetworkErrorInterceptor`, typed `ApiException`); `PostgrestApi` is the data source on top; repositories implement domain contracts; ViewModels are
  Riverpod `Notifier`s with an immutable UiState; widgets only watch them.
- **Online-only gate**: `ConnectionController` (`shared/providers/connection_provider.dart`, the ViewModel) over `ConnectionRepository`
  (`core/connection`: connectivity_plus + a ~20-byte probe through its own impatient Dio). `ConnectionGate` (View, wraps the router in `app.dart`)
  replaces the WHOLE app — every page and dialog — with the no-internet page when the phone has no network (at once), or our server fails two
  probes in a row (Wi-Fi without internet), or a failed request is confirmed by a failing probe. Pages stay mounted underneath, so the person
  returns to the same screen; Android back is swallowed while it shows. It re-checks every 3 s while offline, every 20 s while online (foreground
  only), on network changes and on resume; coming back online refreshes the archive. Timing: `ConnectionTiming` (tests use `ConnectionTiming.off`).
- **Online only** (nothing is saved on the phone): the archive (≈1.2 MB, ≈240 KB over the wire) is downloaded at every launch into memory,
  so browsing and search stay instant after one short load. `sync_manifest` and the first page of every table start together, extra pages
  of a big table are fetched in parallel, and the first failure cancels the rest. Later it re-checks the server (one tiny request) when the
  app returns after 10 minutes, on pull-to-refresh and from the banner / Settings › Data & updates. Book text is fetched per remedy and
  remembered in memory only (24 most recent). Riverpod's automatic retry is off (`noAutoRetry`): Dio retries transient failures twice,
  then the screen shows a typed error (no internet / too slow / server problem / other) with Try again. Saved remedies, history and
  settings are small local preferences, not archive data. The first launch after updating deletes the old on-phone copy
  (`core/storage/legacy_cache*.dart`).
- Routing: go_router 18, `StatefulShellRoute.indexedStack` for the 4 tabs; paths in `core/router/app_routes.dart`.
- Material comes from the `material_ui` package (Flutter 3.47 moved it out of the SDK) — import `package:material_ui/material_ui.dart`.
- Strings: ARB files in `lib/l10n` (`flutter gen-l10n` → class `L`), English + বাংলা.

## UI notes (design system `Hm*`, motion and layout rules)
- **Fonts are bundled** (`assets/fonts`, no runtime download): Lexend Deca headings + Nunito Sans body / italic Latin names (as FocusFlow), and **Noto Sans Bengali**
  (Google's standard Bengali font: every conjunct and the Bangla digits) for Bangla. Bangla text runs with zero letter-spacing (`buildTheme(bangla: true)`).
- **Type scale** follows FocusFlow: semibold titles, 14–15 body, 12 captions, no extra-bold. Text size composes on top of the OS scaler
  (`AppTextScaler`, Settings › Text size, 6 stops 85–130 %, default 100 %).
- **Pinned headers**: tab screens use `HmTabPage` — the header (title, search, segmented control) stays put and a hairline appears under it
  only once the content scrolls. Tab lists end with a small `context.barClearance` gap (the body stops above the bar).
- **Bottom bar** (`core/widgets/hm_bottom_nav.dart`, `core/router/app_shell.dart`) is ALWAYS visible: flat bar with one sliding top indicator and an
  outline → solid icon swap (the look of the mgi_recruitment bar), the anchored ad directly above it. A hide-on-scroll mode and its Settings switch were removed.
- **Ads**: anchored banner = standard adaptive (≈ 50–60 dp, capped at 64), inline banners ≤ 60 dp and kept alive inside lists (no reload while scrolling).
- **Back-to-top pill** (`HmScrollTopPill` / `HmScrollTopHost`): bottom of the list, 6 dp above the bar, shown after 15 items, hidden while scrolling down.
- **Learn the basics** (Home): a swipeable `LearnSlider` of six topics with an animated page indicator; cards open a page or a bottom-sheet lesson.
- **Details toolbar** is a native Material one: plain icon buttons, back arrow 16 dp from the edge (no frosted rounded squares).
- **Remedy details** are one page of collapsible sections (Overview · Indications · Dosage & administration · Keynotes · Safety & precautions ·
  Relationships · Available brands · Materia Medica · Sources & review) with a sticky scroll-spy index — modelled on MedEx's brand pages, plus
  what MedEx lacks (jump index, sources, "archive updated", report-an-error). `?tab=study` etc. still deep-link to a section. Every section is always listed; one with no data shows an empty state (`SectionEmpty`: icon + message + optional action).
- **Tests**: `flutter test`. `test/helpers/app_harness.dart` runs the REAL app (theme, router, l10n) over an archive in memory and records every framework error with its source line.
  `test/screens_smoke_real_data_test.dart` opens every remedy / condition page of the live archive (`node tool/fetch_test_fixture.mjs`, then `HOMIO_FIXTURE_DIR=build/fixtures flutter test ...`). `test/remedy_page_test.dart` covers the index chips, scroll-spy and empty states.
- **Motion**: slide + parallax page transitions (`core/router/page_transitions.dart`, iOS keeps Cupertino for swipe-back), cross-fading tabs that keep
  their state, press-scale on cards/chips (`HmPressable`), sliding segmented thumb, once-only reveal (`HmReveal(once:)`). Everything respects reduce motion.

## Search
Instant in-memory index (`features/search/domain/services/search_index.dart`): exact › prefix › phonetic (Banglish) › word › substring ›
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
- Application id / bundle id: `com.iqballabs.homiopedia` (Android `namespace` + `applicationId` in `android/app/build.gradle.kts`, `MainActivity` in
  `android/app/src/main/kotlin/com/iqballabs/homiopedia/`, iOS `PRODUCT_BUNDLE_IDENTIFIER`, `AppInfo.applicationId`).
- Release builds are minified by R8. `android/app/proguard-rules.pro` (wired in `app/build.gradle.kts`) keeps WorkManager's reflective Room
  database, which the AdMob plugin pulls in. Without it the release APK dies at launch, before Flutter starts, with
  "Failed to create an instance of androidx.work.impl.WorkDatabase". Debug the phone with `adb logcat -d | findstr "FATAL Caused"`.
- Build the installable APK: `flutter build apk --release --dart-define-from-file=env.json` → `build/app/outputs/flutter-apk/app-release.apk`
  (signed with the debug key until a release keystore exists).
