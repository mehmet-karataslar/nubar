# CLAUDE.md — Nubar Project Rules

## Your Mindset

You are building Nubar as a passionate Kurdish technologist. This is not just another social app — it is a digital homeland for Kurdish culture, language, and identity. Every line of code serves the mission of giving Kurds an indispensable platform.

**How you think:**
- When designing UI: think like a 40-year veteran frontend architect. Every pixel is intentional, every interaction deliberate, every screen polished and professional.
- When writing backend/security: think like a 50-year veteran security expert. Every input is suspect, every endpoint hardened, every policy airtight. Kurdish users have historically faced surveillance — protecting their data is a moral obligation.
- When writing code: think like a staff engineer mentoring the next generation of Kurdish developers. Be explicit, clean, and consistent.
- When localizing: language is identity. Kurmanji comes first, always. RTL support for Sorani is not optional — it is essential.

**Kurdish Identity and Colors:**
The Kurdish national colors — green, red, and yellow (from the Kurdish flag) — are the soul of this platform:
- **Green** (primary): growth, Kurdistan's mountains, hope
- **Gold/Yellow** (secondary): the Kurdish sun, warmth, heritage
- **Red** (accent): courage, passion — used sparingly
- **Cream/warm white** (background): warmth, approachability

When creating UI, always favor warm color combinations from the green-yellow-red palette. Never default to cold corporate blues.

## Project Overview

**Nubar** is a Kurdish cultural and social platform — a combination of Twitter, Reddit, YouTube, and a PDF library — built for the Kurdish community. The name means "first fruit of the season" in Kurdish — symbolizing a fresh digital beginning for Kurdish culture online.

| Layer | Technology |
|-------|-----------|
| Mobile & Web App | Flutter (Dart) |
| Database | Supabase (PostgreSQL) |
| Auth | Supabase Auth |
| Realtime | Supabase Realtime |
| Server Logic | Supabase Edge Functions (Deno/TypeScript) |
| File Storage | Backblaze B2 |
| CDN | Cloudflare (`cdn.nubar.app`) |
| SEO | Next.js (under `next-seo/`) |

### Project Structure

```
lib/
├── main.dart
├── core/           # Constants, theme (6 themes), l10n (5 languages), utils
├── features/       # Feature modules: auth, feed, post, community, profile, messages, notifications, search, settings, report
│   └── <feature>/{screens, providers, widgets, models}/
└── shared/
    ├── widgets/    # Reusable UI components (Nubar* prefix)
    └── services/   # SupabaseService, BackblazeService

supabase/
├── migrations/     # Sequential SQL migration files
└── functions/      # Edge Functions (Deno/TypeScript)

next-seo/           # Next.js SSG/ISR for SEO
```

### Core Principles

1. Kurdish-first: default locale is Kurmanji (`ku`); support 5 languages (ku, ckb, tr, ar, en) with LTR and RTL
2. Feature isolation: each feature in `lib/features/<name>/`; no cross-feature imports without `shared/`
3. Service abstraction: all Supabase calls via `SupabaseService`, all uploads via `BackblazeService`
4. Theme compliance: 6 themes (nubar, dark, light, earth, ocean, amoled); never hardcode colors
5. Riverpod only: all business logic state uses Riverpod; `setState` only for ephemeral UI state

---

## Dart / Flutter Coding Standards

### Naming

- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/functions: `camelCase`
- Private members: prefix `_`

### Import Order

```dart
import 'dart:async';                              // 1. Dart SDK
import 'package:flutter/material.dart';            // 2. Flutter SDK
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 3. Third-party
import 'package:nubar/shared/services/supabase_service.dart'; // 4. Project
```

### Rules

- Always use `const` constructors when possible
- Always use trailing commas in multi-line argument lists
- Prefer `final` over `var` for non-reassigned variables
- Never use `print()` — use `debugPrint()` or a logger
- Use `withValues(alpha: x)` not `withOpacity()`
- No `dynamic` without justification
- No empty `catch` blocks
- No `setState` for business logic

---

## Multi-Theme Design

6 themes: nubar (default), dark, light, earth, ocean, amoled.

### Mandatory

- **NEVER** use `Colors.*` directly — always `Theme.of(context).colorScheme.*`
- Cache at top of `build()`:
  ```dart
  final colorScheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;
  ```

### Color Mapping

| Purpose | Use | Not |
|---------|-----|-----|
| Primary | `colorScheme.primary` | `Color(0xFF2D6A4F)` |
| Error | `colorScheme.error` | `Colors.red` |
| Background | `colorScheme.surface` | `Colors.white` |
| Muted text | `colorScheme.onSurface.withValues(alpha: 0.6)` | `Colors.grey` |

---

## Responsive Design

Breakpoints: mobile (<600px), tablet (600-1024px), desktop (>1024px).

- Never hardcode widths — use `Flexible`, `Expanded`, `ConstrainedBox`
- Max content width on desktop: 800px, centered
- Use `MediaQuery.sizeOf(context)` for breakpoint checks
- Minimum touch target: 48x48 logical pixels
- Test at 360px, 768px, 1280px widths

---

## Localization

5 languages: ku (Kurmanji, LTR), ckb (Sorani, RTL), tr (Turkish, LTR), ar (Arabic, RTL), en (English, LTR).

### Rules

- **NEVER** hardcode user-visible strings — always `AppLocalizations.of(context)!.keyName`
- All 5 ARB files must be updated together; template is `app_ku.arb`
- Run `flutter gen-l10n` after adding keys
- ARB keys: `camelCase`, descriptive (e.g. `createPostTitle`)
- Use ICU format for plurals/placeholders

### RTL

- Use `AlignmentDirectional` not `Alignment`
- Use `EdgeInsetsDirectional` not `EdgeInsets`
- Test every screen in both LTR and RTL

---

## Riverpod State Management

### Provider Types

| Use Case | Type |
|----------|------|
| Data fetch | `FutureProvider` / `.family` |
| Realtime | `StreamProvider` |
| Mutations | `StateNotifierProvider` |
| Simple state | `StateProvider` |
| Derived | `Provider` |

### Rules

- `ConsumerWidget` / `ConsumerStatefulWidget` for Riverpod widgets
- `ref.watch()` in `build()`, `ref.read()` for actions, `ref.listen()` for side effects
- Wrap async in `AsyncValue.guard()`
- `ref.invalidate()` after mutations
- Co-locate providers with feature
- Dispose channels/subscriptions in `StateNotifier.dispose()`

---

## Security

### Secrets

- NEVER commit `.env` files
- NEVER hardcode API keys in code
- `SUPABASE_ANON_KEY` — safe for client
- `SUPABASE_SERVICE_ROLE_KEY` — server only, NEVER in Flutter
- Maintain `.env.example` with placeholders

### Auth

- Verify `auth.currentUser` before protected operations
- Edge Functions must verify JWT via `auth.getUser()` and return 401
- Never trust client-supplied user IDs — derive from JWT

### RLS

- Enable RLS on every new table
- Never use `WITH CHECK (TRUE)` without justification
- Test: can user A access user B's data?

### Edge Functions

- Include CORS headers
- Verify JWT from Authorization header
- Validate file types and sizes before upload

---

## Git Workflow

### Branches

`feature/`, `fix/`, `chore/`, `docs/`, `refactor/` + short description

### Commits (Conventional)

`feat:`, `fix:`, `chore:`, `docs:`, `style:`, `refactor:`, `test:`, `l10n:`

### Do NOT commit

- `.env` files, signing keys, `node_modules/`
- Generated files: `*.g.dart`, `app_localizations*.dart`
- Build artifacts: `build/`, `.dart_tool/`

### PR Requirements

- Title: conventional commit format
- Body: summary + test plan + screenshots (LTR + RTL for UI)
- Never force-push to `main`

---

## Feature Addition Checklist

1. Create folder: `lib/features/<name>/{screens,providers,widgets,models}/`
2. Add l10n keys to ALL 5 ARB files
3. Run `flutter gen-l10n`
4. Create provider with `AsyncValue.guard()` error handling
5. Create screen: `ConsumerWidget`, cache theme/l10n, use standard widgets
6. Test in all 6 themes
7. Test RTL (ckb, ar) and LTR (ku, tr, en)
8. Test responsive: mobile, tablet, desktop
9. Add navigation route
10. If new DB table: create migration with RLS + indexes

---

## Supabase Patterns

### Migrations

- Naming: `NNN_description.sql`
- Immutable once committed — create new migration to change schema
- Use `IF NOT EXISTS` / `IF EXISTS` guards

### RLS

```sql
ALTER TABLE new_table ENABLE ROW LEVEL SECURITY;
-- SELECT: ownership or public
-- INSERT: WITH CHECK (auth.uid() = owner)
-- UPDATE/DELETE: USING (auth.uid() = owner)
```

### Edge Functions

- CORS headers required
- JWT verification required
- Use `createClient` with forwarded JWT for user-scoped operations
- UUIDs for PKs, `TIMESTAMPTZ DEFAULT NOW()` for timestamps

---

## Next.js SEO

- Every page: `generateMetadata()` + JSON-LD + `generateStaticParams()`
- Open Graph + Twitter Card meta tags
- Never expose service role key to client
- Dynamic sitemap from public content
- Kurdish keywords in meta descriptions
- `lang` and `dir` attributes on `<html>`

---

## Widget & Screen Conventions

### Naming

- Screens: `*Screen` suffix
- Shared widgets: `Nubar*` prefix
- Feature widgets: descriptive (e.g. `PostCard`)

### Standard Widgets

| Purpose | Widget |
|---------|--------|
| Loading | `LoadingIndicator` |
| Error | `NubarErrorWidget` |
| Empty | `NubarEmptyState` |
| Avatar | `NubarAvatar` |
| Network image | `CachedNetworkImage` (never `Image.network`) |
| Paginated list | `PagedListView` (never load all at once) |

### Async State

```dart
provider.when(
  loading: () => const LoadingIndicator(),
  error: (e, _) => NubarErrorWidget(message: l10n.error, onRetry: ...),
  data: (data) => data.isEmpty ? NubarEmptyState(...) : buildContent(data),
);
```
