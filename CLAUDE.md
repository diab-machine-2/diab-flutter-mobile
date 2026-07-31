# CLAUDE.md

Guidance for Claude Code (and any dev) working in this repo. This file documents conventions actually found in the codebase, not generic Flutter advice — if something here looks wrong, check the cited file before assuming the doc is right.

## Project overview

`medical` — a diabetes-care Flutter app. Flutter SDK pinned to **3.27.4 via FVM** (`.fvmrc`). Dart constraint `>=3.0.0 <4.0.0`. Key integrations: Firebase (Crashlytics, Analytics, Remote Config, Messaging), Supabase, Zalo SDK, Zoom SDK, Mixpanel, Bluetooth/health data (`flutter_blue_plus`, `health`).

## Build & environment (FVM)

This machine has **two Flutter SDKs on PATH** — a global `3.19.6` ahead of FVM's pinned `3.27.4`. A bare `flutter`/`dart` command can silently resolve to the wrong one.

**Always prefix commands with `fvm`:**
```
fvm flutter pub get
fvm flutter run
fvm dart run build_runner build --delete-conflicting-outputs
```

### Known issue: `build_runner` fails with "Could not find a command named ...frontend_server.dart.snapshot"

Root cause: the pinned SDK's cache (`<fvm>\versions\3.27.4\bin\cache\dart-sdk\bin\snapshots\`) is missing `frontend_server.dart.snapshot` (the JIT snapshot `build_runner`'s build script needs) — only `frontend_server_aot.dart.snapshot` is present.

Fix, in order:
1. `fvm flutter precache --force` (redownloads/regenerates engine artifacts for the pinned SDK).
2. Retry `fvm dart run build_runner build --delete-conflicting-outputs`.
3. If still missing, delete `<fvm>\versions\3.27.4\bin\cache` entirely and run `fvm flutter --version` once to let it repopulate, then retry step 2.

### Codegen stack
`build_runner` 2.4.8 + `retrofit_generator` 8.2.1 + `json_serializable` 6.8.0. Regenerate after touching anything under `lib/src/model/**`.

**Caveat:** `freezed_annotation` is a dependency but `freezed` (the actual generator) is commented out in `pubspec.yaml`. Don't add `@freezed` classes — they won't generate until someone re-enables the `freezed` dev_dependency.

## Project structure map

| Path | Contents |
|---|---|
| `lib/res/` | Static resources: `colors.dart`, `dimens.dart`, `styles.dart`, `R.dart` (resource locator), `translations/langs.csv`, `generated/*.g.dart` |
| `lib/src/model/` | Retrofit **API layer**: `app_api.dart` (+ generated `app_api.g.dart`), `request/`, `response/` DTOs |
| `lib/src/modal/` | The actual **data-model layer** (historical typo for "model" — not dialog/modal UI). Distinct from `lib/src/model/` above. Don't "fix" this naming — it's load-bearing across the codebase. |
| `lib/src/bloc/` | Legacy event-based Bloc classes, per-feature `_bloc.dart`/`_bloc_event.dart`/`_bloc_state.dart`. **Legacy only — do not extend for new work.** |
| `lib/src/widget/` (singular) | Per-feature screens/pages, each colocated with its Cubit, e.g. `lib/src/widget/benefit/`. New feature work goes here. |
| `lib/src/widgets/` (plural) | Generic reusable components (buttons, dialogs, pickers, calendars). |
| `lib/src/repo/` | Dio/Retrofit client wrappers per feature domain. |
| `lib/src/service/`, `app_setting/`, `utils/`, `theme/` | Singletons and cross-cutting helpers. |
| `lib/src/config/` | Empty/vestigial — ignore. |

No `analysis_options.yaml` exists in this repo — no enforced lint rules currently.

## State management: Cubit (mandated for new code)

**Use Cubit, not Bloc**, for all new state management. Cubit already dominates the codebase (~59 Cubit files vs ~20 legacy Bloc files confined to `lib/src/bloc/`). Bloc's event-sourcing/replay advantage isn't exploited anywhere here, so it's pure boilerplate overhead (`mapEventToState`/`yield`) for no benefit — Cubit is more readable for this codebase's needs.

**Pattern** (see `lib/src/widget/benefit/benefit_service_request_cubit.dart` + `benefit_service_request_state.dart`):
- Cubit file + a `<feature>_state.dart` file linked via `part` / `part of`.
- States are a `sealed class` with plain `const` subclasses: `Initial`, `Loading`, `<X>Success`, `<X>Error`. No `copyWith`/`Equatable` needed for this style.
- No DI container (no `get_it`/`injectable` in this project). Cubits take repositories as constructor params; wiring happens inline at the page level:
  ```dart
  BlocProvider(create: (_) => XCubit(XRepository()), child: XPage())
  ```
- UI consumes state via `BlocBuilder` / `BlocConsumer` / `BlocListener`.

An older, more generic base state exists at `lib/src/widget/base/cubit_base_state.dart` (`CubitBaseState extends Equatable`, with `InitialState`/`LoadingState`/`ErrorState(Failure)`/`DataLoadedState<T>`) — fine to reuse for simple cubits that don't need bespoke success variants, but prefer the sealed-class-per-feature pattern above for anything with multiple distinct success shapes.

## API layer

All backend endpoints live in `lib/src/model/app_api.dart` — a single `@RestApi()` abstract class `AppApi`, grouped by `// SectionName` comments. To add an endpoint:
1. Add the method to `AppApi` in `app_api.dart`.
2. Regenerate: `fvm dart run build_runner build --delete-conflicting-outputs`.
3. Never hand-edit `app_api.g.dart` — it's fully generated.

Request/response DTOs live in `lib/src/model/request/` / `lib/src/model/response/`, `json_serializable`-annotated.

## Strings — never hardcode UI text

- Source of truth: `lib/res/translations/langs.csv` — columns `str,vi,en` (key, Vietnamese, English), one row per key.
- `lib/res/generated/strings.g.dart` defines `class Strings` with one `String get <key> => '<key>';` getter per CSV key. The getter just echoes the key name — actual translation happens at runtime via `easy_localization` + the custom loader `lib/src/model/localization/csv_loader/csv_asset_loader.dart`, which reads `langs.csv` for the active locale.
- Usage in widgets: `R.string.<key>.tr()` (e.g. `R.string.cancel.tr()`).

**Procedure for any new UI text:**
1. Search `langs.csv` for an existing key with the same/similar meaning — reuse it if found.
2. If none exists, append a new row to `langs.csv` with **both** a `vi` and an `en` value.
3. Add the matching getter to `strings.g.dart`: `String get <key> => '<key>';`
4. Reference it via `R.string.<key>.tr()`.

**Caveat:** no automated generator command exists for `strings.g.dart` or `colors.g.dart` (no `slang.yaml`/`l10n.yaml`/README script found) — these appear to be produced by an external IDE "R.dart generator" extension run manually, not by `build_runner`. Until that's set up as a repeatable command, edit both files by hand and keep them in sync. There's also no lint rule currently catching hardcoded strings (no `analysis_options.yaml`) — review manually.

## Colors — never hardcode hex values

Same two-file pattern as strings:
- `lib/res/colors.dart` — raw `AppColors` definitions (source of truth).
- `lib/res/generated/colors.g.dart` — `class Colors` with a matching getter per color, consumed via `R.color.<name>`.

`R.color.<name>` is the dominant convention (7300+ usages across 548 files) — direct `AppColors.` usage (69 occurrences) is legacy/pre-`R.color` code; don't add new direct `AppColors.` references.

**Procedure for any new color:**
1. Check `colors.dart` / `colors.g.dart` for an existing semantically-close color — reuse it if found.
2. If none exists, add a `static const` to `AppColors` in `colors.dart` **and** a matching getter with the same name to `Colors` in `colors.g.dart`.
3. Reference it via `R.color.<name>`.
4. Prefer a semantic name (`benefitTextColor`) over a `color0xffXXXXXX`-style literal name for new colors.

## Figma-to-code workflow

No Figma MCP server is connected in this environment, and its rate limits (6 calls/month on Starter or View/Collab seats; 10/min on Professional; 20/min on Org/Enterprise Dev seats) make it impractical without an existing paid Dev/Full seat.

**Primary method: screenshot + Dev Mode export as text.** When starting a UI task from a Figma design, request both from the user:
1. A **screenshot** of the frame/component — for layout, hierarchy, and visual proportions.
2. The Dev Mode **inspect panel's exported values** (CSS/spacing/font sizes/hex colors/border radii) pasted as text — for pixel-accurate measurements.

Then map every extracted value onto existing resources instead of inlining literals:
- Colors → `R.color.*` (add new ones per the Colors procedure above).
- Text styles → `lib/res/styles.dart` / `lib/res/text_styles_extension.dart`.
- Spacing → `lib/res/dimens.dart`.

If the user later gets a Figma Dev/Full seat on Professional+, the Figma Dev Mode MCP Server becomes a viable alternative/supplement — revisit this section then.

## Misc

- Networking: `dio` + `retrofit`.
- State: `flutter_bloc` (Cubit) + `equatable`.
- i18n: `easy_localization` + custom CSV loader (see Strings section).
- No `analysis_options.yaml` — no enforced lint rules currently.
