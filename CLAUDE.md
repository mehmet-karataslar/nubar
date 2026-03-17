# CLAUDE.md — Nûbar Project

## Project Overview

**Nûbar** is a Kurdish cultural and social platform — a combination of Twitter, Reddit, YouTube, and a PDF library — built specifically for the Kurdish community. The name means "first fruit of the season" in Kurdish, symbolizing a fresh digital beginning for Kurdish culture online.

Users can share text, images, videos, and PDFs; create communities; discuss topics; follow each other; and engage with content in multiple Kurdish dialects and languages.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile & Web App | Flutter (Dart) |
| Database | Supabase (PostgreSQL) |
| Authentication | Supabase Auth |
| Realtime | Supabase Realtime |
| Server Logic | Supabase Edge Functions |
| File Storage | Backblaze B2 |
| CDN | Cloudflare |
| SEO Layer | Next.js |

---

## Project Structure

> ⚠️ **Current repository status note**
>
> - Flutter application currently lives directly at the repository root (`/lib`, `/pubspec.yaml`), not under `/flutter_app/`.
> - Implemented Supabase Edge Functions are currently: `generate-upload-url`, `delete-file`, `send-notification`.
> - `generate-thumbnail`, `moderate-content`, and `next-seo/` are planned structures (Phase 2/5) and are not yet present in this repository.

```
nubar/
├── flutter_app/          ← Main Flutter application
│   ├── lib/
│   │   ├── core/
│   │   │   ├── constants/
│   │   │   │   ├── app_constants.dart
│   │   │   │   ├── supabase_constants.dart
│   │   │   │   └── backblaze_constants.dart
│   │   │   ├── theme/
│   │   │   │   ├── app_theme.dart
│   │   │   │   ├── theme_provider.dart
│   │   │   │   └── themes/
│   │   │   │       ├── nubar_theme.dart
│   │   │   │       ├── dark_theme.dart
│   │   │   │       ├── light_theme.dart
│   │   │   │       ├── earth_theme.dart
│   │   │   │       ├── ocean_theme.dart
│   │   │   │       └── amoled_theme.dart
│   │   │   ├── l10n/
│   │   │   │   ├── app_ku.arb
│   │   │   │   ├── app_ckb.arb
│   │   │   │   ├── app_tr.arb
│   │   │   │   ├── app_ar.arb
│   │   │   │   └── app_en.arb
│   │   │   └── utils/
│   │   │       ├── file_utils.dart
│   │   │       ├── date_utils.dart
│   │   │       └── validators.dart
│   │   ├── features/
│   │   │   ├── auth/
│   │   │   │   ├── screens/
│   │   │   │   │   ├── login_screen.dart
│   │   │   │   │   ├── register_screen.dart
│   │   │   │   │   └── onboarding_screen.dart
│   │   │   │   ├── providers/
│   │   │   │   │   └── auth_provider.dart
│   │   │   │   └── models/
│   │   │   │       └── auth_model.dart
│   │   │   ├── feed/
│   │   │   │   ├── screens/
│   │   │   │   │   └── feed_screen.dart
│   │   │   │   ├── widgets/
│   │   │   │   │   ├── post_card.dart
│   │   │   │   │   ├── post_actions.dart
│   │   │   │   │   └── story_bar.dart
│   │   │   │   └── providers/
│   │   │   │       └── feed_provider.dart
│   │   │   ├── post/
│   │   │   │   ├── create/
│   │   │   │   │   ├── create_post_screen.dart
│   │   │   │   │   └── create_post_provider.dart
│   │   │   │   ├── detail/
│   │   │   │   │   └── post_detail_screen.dart
│   │   │   │   ├── pdf_viewer/
│   │   │   │   │   └── pdf_viewer_screen.dart
│   │   │   │   └── video_player/
│   │   │   │       └── video_player_screen.dart
│   │   │   ├── community/
│   │   │   │   ├── screens/
│   │   │   │   │   ├── community_feed_screen.dart
│   │   │   │   │   ├── create_community_screen.dart
│   │   │   │   │   └── community_settings_screen.dart
│   │   │   │   └── providers/
│   │   │   │       └── community_provider.dart
│   │   │   ├── profile/
│   │   │   │   ├── screens/
│   │   │   │   │   ├── profile_screen.dart
│   │   │   │   │   └── edit_profile_screen.dart
│   │   │   │   └── providers/
│   │   │   │       └── profile_provider.dart
│   │   │   ├── notifications/
│   │   │   │   ├── screens/
│   │   │   │   │   └── notifications_screen.dart
│   │   │   │   └── providers/
│   │   │   │       └── notifications_provider.dart
│   │   │   ├── messages/
│   │   │   │   ├── screens/
│   │   │   │   │   ├── messages_list_screen.dart
│   │   │   │   │   └── chat_screen.dart
│   │   │   │   └── providers/
│   │   │   │       └── messages_provider.dart
│   │   │   └── search/
│   │   │       ├── screens/
│   │   │       │   └── search_screen.dart
│   │   │       └── providers/
│   │   │           └── search_provider.dart
│   │   ├── shared/
│   │   │   ├── widgets/
│   │   │   │   ├── nubar_button.dart
│   │   │   │   ├── nubar_avatar.dart
│   │   │   │   ├── nubar_text_field.dart
│   │   │   │   └── loading_indicator.dart
│   │   │   └── services/
│   │   │       ├── supabase_service.dart
│   │   │       └── backblaze_service.dart
│   │   └── main.dart
│   └── pubspec.yaml
│
├── supabase/
│   ├── migrations/
│   │   └── 001_initial_schema.sql
│   └── functions/
│       ├── generate-upload-url/
│       ├── generate-thumbnail/
│       ├── send-notification/
│       ├── moderate-content/
│       └── delete-file/
│
└── next-seo/                ← SEO layer
    ├── app/
    │   ├── page.tsx
    │   ├── post/[id]/page.tsx
    │   ├── community/[slug]/page.tsx
    │   └── user/[username]/page.tsx
    └── lib/
        └── supabase.ts
```

---

## Environment Variables

### Flutter (.env)
```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
BACKBLAZE_BUCKET_NAME=nubar-bucket
BACKBLAZE_CDN_URL=https://cdn.nubar.app
```

### Supabase Edge Functions
```
BACKBLAZE_KEY_ID=your_backblaze_key_id
BACKBLAZE_APPLICATION_KEY=your_backblaze_app_key
BACKBLAZE_BUCKET_ID=your_bucket_id
FCM_SERVER_KEY=your_fcm_server_key
```

---

## Database Schema (Supabase PostgreSQL)

### Enable Extensions
```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- for search
```

### Enums
```sql
CREATE TYPE post_type AS ENUM ('text', 'image', 'video', 'pdf', 'mixed');
CREATE TYPE notification_type AS ENUM ('like', 'comment', 'follow', 'repost', 'mention', 'message');
CREATE TYPE community_role AS ENUM ('admin', 'moderator', 'member');
CREATE TYPE report_status AS ENUM ('pending', 'reviewed', 'resolved');
CREATE TYPE app_language AS ENUM ('ku', 'ckb', 'tr', 'ar', 'en');
CREATE TYPE app_theme AS ENUM ('nubar', 'dark', 'light', 'earth', 'ocean', 'amoled');
```

### Tables

```sql
-- USERS
CREATE TABLE users (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  auth_id         UUID UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  username        TEXT UNIQUE NOT NULL,
  full_name       TEXT NOT NULL,
  avatar_url      TEXT,
  bio             TEXT,
  website         TEXT,
  location        TEXT,
  verified        BOOLEAN DEFAULT FALSE,
  follower_count  INTEGER DEFAULT 0,
  following_count INTEGER DEFAULT 0,
  post_count      INTEGER DEFAULT 0,
  preferred_lang  app_language DEFAULT 'ku',
  preferred_theme app_theme DEFAULT 'nubar',
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- POSTS
CREATE TABLE posts (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id          UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  content          TEXT,
  type             post_type NOT NULL DEFAULT 'text',
  media_urls       TEXT[],
  thumbnail_url    TEXT,
  community_id     UUID REFERENCES communities(id) ON DELETE SET NULL,
  original_post_id UUID REFERENCES posts(id) ON DELETE SET NULL,
  is_repost        BOOLEAN DEFAULT FALSE,
  view_count       INTEGER DEFAULT 0,
  like_count       INTEGER DEFAULT 0,
  comment_count    INTEGER DEFAULT 0,
  repost_count     INTEGER DEFAULT 0,
  bookmark_count   INTEGER DEFAULT 0,
  language         app_language DEFAULT 'ku',
  is_deleted       BOOLEAN DEFAULT FALSE,
  created_at       TIMESTAMPTZ DEFAULT NOW()
);

-- COMMENTS
CREATE TABLE comments (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  post_id     UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  parent_id   UUID REFERENCES comments(id) ON DELETE CASCADE,
  content     TEXT NOT NULL,
  like_count  INTEGER DEFAULT 0,
  is_deleted  BOOLEAN DEFAULT FALSE,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- LIKES
CREATE TABLE likes (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  post_id    UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, post_id)
);

-- COMMENT LIKES
CREATE TABLE comment_likes (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  comment_id UUID NOT NULL REFERENCES comments(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, comment_id)
);

-- REPOSTS
CREATE TABLE reposts (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  post_id    UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, post_id)
);

-- BOOKMARKS
CREATE TABLE bookmarks (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  post_id    UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, post_id)
);

-- FOLLOWS
CREATE TABLE follows (
  follower_id  UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  following_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at   TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (follower_id, following_id)
);

-- COMMUNITIES
CREATE TABLE communities (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name          TEXT NOT NULL,
  slug          TEXT UNIQUE NOT NULL,
  description   TEXT,
  avatar_url    TEXT,
  banner_url    TEXT,
  is_private    BOOLEAN DEFAULT FALSE,
  member_count  INTEGER DEFAULT 0,
  post_count    INTEGER DEFAULT 0,
  created_by    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- COMMUNITY MEMBERS
CREATE TABLE community_members (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  community_id UUID NOT NULL REFERENCES communities(id) ON DELETE CASCADE,
  user_id      UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role         community_role DEFAULT 'member',
  joined_at    TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(community_id, user_id)
);

-- NOTIFICATIONS
CREATE TABLE notifications (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type       notification_type NOT NULL,
  actor_id   UUID REFERENCES users(id) ON DELETE CASCADE,
  post_id    UUID REFERENCES posts(id) ON DELETE CASCADE,
  comment_id UUID REFERENCES comments(id) ON DELETE CASCADE,
  is_read    BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- MESSAGES
CREATE TABLE messages (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sender_id   UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  receiver_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  content     TEXT,
  media_url   TEXT,
  is_read     BOOLEAN DEFAULT FALSE,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- POLLS
CREATE TABLE polls (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  post_id    UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  question   TEXT NOT NULL,
  options    JSONB NOT NULL,
  ends_at    TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- POLL VOTES
CREATE TABLE poll_votes (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  poll_id    UUID NOT NULL REFERENCES polls(id) ON DELETE CASCADE,
  user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  option_key TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(poll_id, user_id)
);

-- REPORTS
CREATE TABLE reports (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  reporter_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  post_id     UUID REFERENCES posts(id) ON DELETE CASCADE,
  comment_id  UUID REFERENCES comments(id) ON DELETE CASCADE,
  reason      TEXT NOT NULL,
  status      report_status DEFAULT 'pending',
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- HASHTAGS
CREATE TABLE hashtags (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name       TEXT UNIQUE NOT NULL,
  post_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- POST HASHTAGS
CREATE TABLE post_hashtags (
  post_id    UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  hashtag_id UUID NOT NULL REFERENCES hashtags(id) ON DELETE CASCADE,
  PRIMARY KEY (post_id, hashtag_id)
);
```

### Indexes
```sql
CREATE INDEX idx_posts_user_id ON posts(user_id);
CREATE INDEX idx_posts_community_id ON posts(community_id);
CREATE INDEX idx_posts_created_at ON posts(created_at DESC);
CREATE INDEX idx_comments_post_id ON comments(post_id);
CREATE INDEX idx_notifications_user_id ON notifications(user_id, is_read);
CREATE INDEX idx_messages_sender ON messages(sender_id);
CREATE INDEX idx_messages_receiver ON messages(receiver_id);
CREATE INDEX idx_posts_search ON posts USING gin(to_tsvector('simple', content));
```

### Row Level Security (RLS)
```sql
-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE reposts ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookmarks ENABLE ROW LEVEL SECURITY;
ALTER TABLE follows ENABLE ROW LEVEL SECURITY;
ALTER TABLE communities ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- USERS policies
CREATE POLICY "Users are viewable by everyone" ON users FOR SELECT USING (TRUE);
CREATE POLICY "Users can update own profile" ON users FOR UPDATE USING (auth.uid() = auth_id);

-- POSTS policies
CREATE POLICY "Public posts are viewable by everyone" ON posts FOR SELECT USING (is_deleted = FALSE);
CREATE POLICY "Users can create posts" ON posts FOR INSERT WITH CHECK (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));
CREATE POLICY "Users can update own posts" ON posts FOR UPDATE USING (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));
CREATE POLICY "Users can delete own posts" ON posts FOR DELETE USING (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));

-- NOTIFICATIONS policies
CREATE POLICY "Users see own notifications" ON notifications FOR SELECT USING (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));

-- MESSAGES policies
CREATE POLICY "Users see own messages" ON messages FOR SELECT USING (
  auth.uid() = (SELECT auth_id FROM users WHERE id = sender_id) OR
  auth.uid() = (SELECT auth_id FROM users WHERE id = receiver_id)
);
```

---

## Backblaze B2 Integration

### Bucket Structure
```
nubar-bucket/
├── avatars/{user_id}/profile.jpg
├── posts/
│   ├── images/{post_id}/{filename}.jpg
│   ├── videos/{post_id}/{filename}.mp4
│   └── pdfs/{post_id}/{filename}.pdf
├── communities/
│   ├── avatars/{community_id}/avatar.jpg
│   └── banners/{community_id}/banner.jpg
└── thumbnails/
    ├── videos/{post_id}/thumb.jpg
    └── pdfs/{post_id}/cover.jpg
```

### File Upload Flow
```
1. Flutter calls Supabase Edge Function: generate-upload-url
2. Edge Function calls Backblaze API for a signed upload URL
3. Flutter uploads file directly to Backblaze (no server middleman)
4. Upload complete → Flutter calls another Edge Function or directly inserts URL into Supabase DB
5. Cloudflare CDN serves the file: https://cdn.nubar.app/{path}
```

### BackblazeService (Flutter)
```dart
// lib/shared/services/backblaze_service.dart
class BackblazeService {
  final String cdnUrl = 'https://cdn.nubar.app';

  Future<String> uploadFile({
    required File file,
    required String path,
  }) async {
    // 1. Get signed URL from Edge Function
    final signedUrl = await _getSignedUploadUrl(path);
    // 2. Upload directly to Backblaze
    await _uploadToBackblaze(signedUrl, file);
    // 3. Return CDN URL
    return '$cdnUrl/$path';
  }

  String getFileUrl(String path) => '$cdnUrl/$path';

  Future<void> deleteFile(String path) async {
    // Call Edge Function to delete
  }
}
```

---

## Supabase Edge Functions

### generate-upload-url
```typescript
// supabase/functions/generate-upload-url/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

serve(async (req) => {
  const { path, contentType } = await req.json()

  // Authenticate with Backblaze B2
  const authResponse = await fetch('https://api.backblazeb2.com/b2api/v2/b2_authorize_account', {
    headers: {
      Authorization: `Basic ${btoa(`${Deno.env.get('BACKBLAZE_KEY_ID')}:${Deno.env.get('BACKBLAZE_APPLICATION_KEY')}`)}`
    }
  })
  const auth = await authResponse.json()

  // Get upload URL
  const uploadUrlResponse = await fetch(`${auth.apiUrl}/b2api/v2/b2_get_upload_url`, {
    method: 'POST',
    headers: {
      Authorization: auth.authorizationToken,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ bucketId: Deno.env.get('BACKBLAZE_BUCKET_ID') })
  })
  const uploadData = await uploadUrlResponse.json()

  return new Response(JSON.stringify({
    uploadUrl: uploadData.uploadUrl,
    authorizationToken: uploadData.authorizationToken,
    fileName: path
  }), { headers: { 'Content-Type': 'application/json' } })
})
```

---

## Theme System (Flutter)

### Theme Colors Reference
```dart
// nubar_theme.dart (Default)
primary:    Color(0xFF2D6A4F)  // Dark green
secondary:  Color(0xFFB7921A)  // Gold
background: Color(0xFFFAF7F0)  // Cream
surface:    Color(0xFFFFFFFF)
accent:     Color(0xFF40916C)

// dark_theme.dart
primary:    Color(0xFF40916C)
secondary:  Color(0xFFE9C46A)
background: Color(0xFF0D1117)
surface:    Color(0xFF161B22)
accent:     Color(0xFF2D6A4F)

// amoled_theme.dart
primary:    Color(0xFF40916C)
secondary:  Color(0xFFE9C46A)
background: Color(0xFF000000)
surface:    Color(0xFF0A0A0A)

// earth_theme.dart
primary:    Color(0xFF8B4513)
secondary:  Color(0xFFD2691E)
background: Color(0xFFFDF5E6)
surface:    Color(0xFFFFFFFF)

// ocean_theme.dart
primary:    Color(0xFF1A6B8A)
secondary:  Color(0xFF48CAE4)
background: Color(0xFFF0F8FF)
surface:    Color(0xFFFFFFFF)
```

---

## Multilingual Support

### Supported Languages
| Code | Language | Direction | Script |
|------|----------|-----------|--------|
| ku   | Kurmanji | LTR | Latin |
| ckb  | Sorani   | RTL | Arabic |
| tr   | Turkish  | LTR | Latin |
| ar   | Arabic   | RTL | Arabic |
| en   | English  | LTR | Latin |

### RTL Handling
```dart
// In MaterialApp
locale: _currentLocale,
supportedLocales: const [
  Locale('ku'),
  Locale('ckb'),
  Locale('tr'),
  Locale('ar'),
  Locale('en'),
],
localizationsDelegates: const [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
],
```

---

## Flutter pubspec.yaml

```yaml
name: nubar
description: Kurdish cultural and social platform

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # Supabase
  supabase_flutter: ^2.0.0

  # State Management
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0

  # PDF
  syncfusion_flutter_pdfviewer: ^23.1.0
  file_picker: ^6.1.0

  # Video
  video_player: ^2.8.0
  chewie: ^1.7.0

  # Image
  cached_network_image: ^3.3.0
  image_picker: ^1.0.4

  # HTTP (Backblaze)
  http: ^1.1.0
  dio: ^5.3.0

  # UI & UX
  infinite_scroll_pagination: ^4.0.0
  timeago: ^3.6.0
  share_plus: ^7.2.0
  shimmer: ^3.0.0
  flutter_animate: ^4.3.0

  # Utils
  intl: ^0.18.0
  path_provider: ^2.1.0
  url_launcher: ^6.2.0
  flutter_dotenv: ^5.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.0
  riverpod_generator: ^2.3.0
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
  generate: true
  assets:
    - .env
    - assets/images/
    - assets/icons/
```

---

## Development Phases

### Phase 1 — Core MVP (Weeks 1-8)
- [ ] Supabase project setup + all tables
- [ ] Flutter project setup with Riverpod
- [ ] Theme system (all 6 themes)
- [ ] Language system (all 5 languages + RTL)
- [ ] Auth screens (login, register, onboarding)
- [ ] User profile (view + edit)
- [ ] Create post (text + image)
- [ ] Feed screen with pagination
- [ ] Like, comment, follow system
- [ ] Basic notifications

### Phase 2 — Media (Weeks 9-14)
- [ ] Backblaze B2 integration
- [ ] Cloudflare CDN setup
- [ ] PDF upload + in-app viewer
- [ ] Video upload + player
- [ ] Repost (RT) functionality
- [ ] Bookmarks / Collections
- [ ] generate-upload-url Edge Function
- [ ] generate-thumbnail Edge Function

### Phase 3 — Community (Weeks 15-19)
- [ ] Create community
- [ ] Community feed
- [ ] Join / leave community
- [ ] Moderator tools
- [ ] Forum / discussion threads
- [ ] Poll system
- [ ] Hashtag system
- [ ] Trending topics

### Phase 4 — Social (Weeks 20-23)
- [ ] Direct messages (Realtime)
- [ ] Real-time notifications (Realtime)
- [ ] Badge / level system
- [ ] User blocking
- [ ] Content reporting
- [ ] Search (full-text Kurdish)

### Phase 5 — SEO & Growth
- [ ] Next.js SEO layer setup
- [ ] Post detail pages (SSG)
- [ ] Community pages (SSG)
- [ ] Profile pages (SSG)
- [ ] Kurdish SEO optimization
- [ ] Google Search Console setup
- [ ] Open Graph meta tags

---

## Coding Standards

- Use Riverpod for all state management — no setState in business logic
- Every feature is isolated in its own folder under `features/`
- All Supabase calls go through `SupabaseService`
- All Backblaze calls go through `BackblazeService`
- Use `AsyncValue` for loading/error/data states
- All strings must use l10n — no hardcoded text
- RTL support must be tested for every new widget
- File naming: snake_case for files, PascalCase for classes

---

## Important Notes for Claude Code

1. **Always use Riverpod** — never use Provider or setState for app state
2. **Theme colors** — always use `Theme.of(context).colorScheme` — never hardcode colors
3. **Text** — always use `AppLocalizations.of(context)` — never hardcode strings
4. **File uploads** — always go through BackblazeService, never directly to Supabase Storage
5. **Auth** — always check `supabase.auth.currentUser` before protected operations
6. **RLS** — Supabase RLS handles authorization — do not duplicate security checks in Flutter
7. **Pagination** — always use `infinite_scroll_pagination` for lists — never load all data at once
8. **Images** — always use `CachedNetworkImage` — never use `Image.network` directly
9. **Errors** — always handle errors with `AsyncValue.error` — never silently fail
10. **RTL** — test every new screen in both LTR and RTL before committing
