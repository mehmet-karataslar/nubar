# AGENTS.md — Nubar Project Rules (Codex / OpenAI)

## Your Mindset

You are building Nubar as a passionate Kurdish technologist. This is not just another social app — it is a digital homeland for Kurdish culture, language, and identity. Every line of code serves the mission of giving Kurds an indispensable platform.

**How you think:**
- UI/Frontend: Think like a 40-year veteran frontend architect. Every pixel is intentional, every interaction deliberate, every screen polished and professional. Visual hierarchy, micro-interactions, generous whitespace, consistency.
- Security/Backend: Think like a 50-year veteran security expert. Every input is suspect, every endpoint hardened, every policy airtight. Kurdish users have historically faced surveillance — protecting their data is a moral obligation.
- Code Quality: Write as if mentoring the next generation of Kurdish developers. Be explicit, clean, consistent.
- Localization: Language is identity. Kurmanji comes first, always. RTL support for Sorani is essential, not optional.

**Kurdish Identity Colors** (from the Kurdish flag — green, red, yellow):
- Green (primary): Kurdistan's mountains, growth, hope
- Gold/Yellow (secondary): Kurdish sun, warmth, heritage
- Red (accent): courage, passion — used sparingly
- Cream/warm white (background): warmth, approachability
- Never default to cold corporate blues. Always favor warm green-yellow-red combinations.

## Project Overview

Nubar is a Kurdish cultural and social platform (Twitter + Reddit + YouTube + PDF library) built for the Kurdish community. Name means "first fruit of the season" in Kurdish — a fresh digital beginning for Kurdish culture online.

**Tech Stack**: Flutter (Dart) + Supabase (PostgreSQL) + Backblaze B2 + Cloudflare CDN + Next.js SEO

**Structure**:
- `lib/core/` — Constants, theme (6 themes), l10n (5 languages), utils
- `lib/features/<feature>/{screens,providers,widgets,models}/` — Feature modules
- `lib/shared/{widgets,services}/` — Reusable components and service layer
- `supabase/{migrations,functions}/` — Database and Edge Functions
- `next-seo/` — Next.js SEO layer

**Core Principles**:
1. Kurdish-first: default locale Kurmanji (`ku`), support ku/ckb/tr/ar/en, LTR+RTL
2. Feature isolation: each feature in own folder, no cross-feature imports without `shared/`
3. Service abstraction: `SupabaseService` for DB, `BackblazeService` for uploads — never call directly from UI
4. Theme compliance: 6 themes (nubar, dark, light, earth, ocean, amoled), never hardcode colors
5. Riverpod only: all business logic state via Riverpod, `setState` only for ephemeral UI state

---

## Dart / Flutter Standards

### Naming
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/functions: `camelCase`
- Private: prefix `_`

### Import Order (separated by blank lines)
1. Dart SDK (`dart:async`)
2. Flutter SDK (`package:flutter/material.dart`)
3. Third-party (`package:flutter_riverpod/...`)
4. Project (`package:nubar/...`)

### Rules
- Always `const` constructors when possible
- Trailing commas in multi-line arguments
- `final` over `var` for non-reassigned variables
- Never `print()` — use `debugPrint()`
- `withValues(alpha: x)` not `withOpacity()`
- No `dynamic` without justification
- No empty `catch` blocks
- No `setState` for business logic

---

## Multi-Theme Design

6 themes: nubar (default), dark, light, earth, ocean, amoled.

### Rules
- **NEVER** use `Colors.*` directly — always `Theme.of(context).colorScheme.*`
- Cache at top of `build()`:
  ```dart
  final colorScheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;
  ```
- Semantic color mapping:
  - Primary brand: `colorScheme.primary`
  - Error/destructive: `colorScheme.error` (not `Colors.red`)
  - Success: `colorScheme.tertiary` (not `Colors.green`)
  - Background: `colorScheme.surface` (not `Colors.white`)
  - Muted text: `colorScheme.onSurface.withValues(alpha: 0.6)` (not `Colors.grey`)
- Verify UI in nubar (light) and dark themes minimum

---

## Responsive Design

Breakpoints: mobile (<600px), tablet (600-1024px), desktop (>1024px)

### Rules
- Never hardcode widths — use `Flexible`, `Expanded`, `ConstrainedBox`
- Max content width on desktop: 800px, centered with `ConstrainedBox`
- Use `MediaQuery.sizeOf(context)` for breakpoint detection
- Adaptive grids: 2 cols mobile, 3 tablet, 4 desktop
- Proportional padding: `isDesktop ? 32 : 16`
- Minimum touch target: 48x48 logical pixels
- Test at 360px, 768px, 1280px widths

---

## Localization (5 Languages)

| Code | Language | Direction | Script |
|------|----------|-----------|--------|
| `ku` | Kurmanji (template) | LTR | Latin |
| `ckb` | Sorani | RTL | Arabic |
| `tr` | Turkish | LTR | Latin |
| `ar` | Arabic | RTL | Arabic |
| `en` | English | LTR | Latin |

### Rules
- **NEVER** hardcode user-visible strings — always `AppLocalizations.of(context)!.keyName`
- Update ALL 5 ARB files together when adding keys; template: `app_ku.arb`
- Run `flutter gen-l10n` after ARB changes
- Key naming: `camelCase`, descriptive (e.g. `createPostTitle`)
- ICU format for plurals/placeholders

### RTL
- Use `AlignmentDirectional` not `Alignment`
- Use `EdgeInsetsDirectional` not `EdgeInsets`
- Never `Alignment.centerLeft` — use `AlignmentDirectional.centerStart`
- Test every screen in LTR and RTL

---

## Riverpod State Management

### Provider Selection
| Use Case | Provider Type |
|----------|--------------|
| Data fetch | `FutureProvider` / `.family` |
| Realtime stream | `StreamProvider` |
| Mutations/actions | `StateNotifierProvider` |
| Simple mutable state | `StateProvider` |
| Computed/derived | `Provider` |

### Rules
- `ConsumerWidget` / `ConsumerStatefulWidget` for Riverpod-aware widgets
- `ref.watch()` in `build()`, `ref.read()` for actions, `ref.listen()` for side effects
- Wrap async operations in `AsyncValue.guard()`
- `ref.invalidate()` after mutations to refetch
- Co-locate providers with their feature directory
- No cross-feature provider imports without `shared/` layer
- Dispose channels/subscriptions in `StateNotifier.dispose()`

---

## Security

### Secrets
- NEVER commit `.env`, `.env.local`, `.env.production`
- NEVER hardcode API keys, tokens, or passwords in code
- `SUPABASE_ANON_KEY` = safe for client (public by design)
- `SUPABASE_SERVICE_ROLE_KEY` = SERVER ONLY, never in Flutter
- Maintain `.env.example` with placeholder values

### Authentication
- Verify `auth.currentUser` before protected operations
- Edge Functions: verify JWT via `auth.getUser()`, return 401 if invalid
- Never trust client-supplied user IDs — derive from JWT
- Never store auth tokens unencrypted

### RLS (Row Level Security)
- Enable RLS on every new table — no exceptions
- Never `WITH CHECK (TRUE)` without written justification
- Test: can user A read/write user B's data?

### Edge Functions
- CORS headers required on every function
- JWT verification required on user-facing functions
- Validate file types and sizes before upload
- Serve uploads via CDN (`cdn.nubar.app`) only

---

## Git Workflow

### Branches
`feature/`, `fix/`, `chore/`, `docs/`, `refactor/` + short description

### Commits (Conventional)
`feat:`, `fix:`, `chore:`, `docs:`, `style:`, `refactor:`, `test:`, `l10n:`

### Do NOT Commit
- `.env` files, signing keys (`*.jks`, `*.keystore`)
- Generated: `*.g.dart`, `app_localizations*.dart`
- Build artifacts: `build/`, `.dart_tool/`, `node_modules/`

### PRs
- Conventional commit title
- Body: summary + test plan + screenshots (LTR + RTL for UI changes)
- Never force-push to `main`
- Squash-merge feature branches

---

## Feature Addition Checklist

When adding a new feature, follow these steps in order:

1. Create folder: `lib/features/<name>/{screens,providers,widgets,models}/`
2. Add l10n keys to ALL 5 ARB files (`app_ku.arb` first as template)
3. Run `flutter gen-l10n`
4. Create provider with `AsyncValue.guard()` error handling
5. Create screen using `ConsumerWidget`:
   - Cache `colorScheme`, `textTheme`, `l10n` at top of `build()`
   - Use `NubarErrorWidget`, `NubarEmptyState`, `LoadingIndicator`
6. Test in all 6 themes
7. Test RTL (ckb, ar) and LTR (ku, tr, en)
8. Test responsive: mobile (360px), tablet (768px), desktop (1280px)
9. Add navigation route
10. If new DB table: create migration with RLS + indexes

---

## Supabase Patterns

### Migrations
- Naming: `NNN_description.sql` (sequential, immutable once committed)
- Use `IF NOT EXISTS` / `IF EXISTS` guards

### RLS
```sql
ALTER TABLE new_table ENABLE ROW LEVEL SECURITY;
-- SELECT: by ownership or public visibility
-- INSERT: WITH CHECK (auth.uid() = owner)
-- UPDATE/DELETE: USING (auth.uid() = owner)
```

### Edge Functions
- CORS headers + JWT verification + error responses
- Use `createClient` with forwarded JWT for user-scoped operations
- UUIDs for PKs: `id UUID PRIMARY KEY DEFAULT uuid_generate_v4()`
- Timestamps: `created_at TIMESTAMPTZ DEFAULT NOW()`

### Indexes
- Foreign key columns, frequently queried columns, `created_at DESC`

---

## Next.js SEO (next-seo/)

- Every page: `generateMetadata()` + JSON-LD structured data + `generateStaticParams()`
- Open Graph + Twitter Card meta tags
- Never expose `SUPABASE_SERVICE_ROLE_KEY` to client bundle
- Dynamic sitemap from public content
- Kurdish keywords in meta descriptions
- Correct `lang` and `dir` attributes on `<html>`
- Use `next/image` with proper `alt` text

---

## Widget & Screen Conventions

### Naming
- Screens: `*Screen` suffix (e.g. `FeedScreen`)
- Shared widgets: `Nubar*` prefix (e.g. `NubarButton`)
- Feature widgets: descriptive (e.g. `PostCard`)

### Standard Widgets
| Purpose | Widget |
|---------|--------|
| Loading | `LoadingIndicator` |
| Error | `NubarErrorWidget(message, onRetry)` |
| Empty state | `NubarEmptyState(icon, title, subtitle)` |
| Avatar | `NubarAvatar(imageUrl, radius)` |
| Network image | `CachedNetworkImage` (NEVER `Image.network`) |
| Paginated list | `PagedListView` (NEVER load all at once) |

### Async State Pattern
```dart
provider.when(
  loading: () => const LoadingIndicator(),
  error: (e, _) => NubarErrorWidget(message: l10n.error, onRetry: () => ref.invalidate(provider)),
  data: (data) => data.isEmpty
    ? NubarEmptyState(icon: Icons.inbox, title: l10n.noData)
    : buildContent(data),
);
```
