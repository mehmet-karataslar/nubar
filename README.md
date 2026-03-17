# Nûbar — Kurdish Cultural & Social Platform

**Nûbar** (Kürtçe: "mevsimin ilk meyvesi") — Kürt topluluğu için özel olarak tasarlanmış bir dijital sosyal platform. Twitter, Reddit, YouTube ve PDF kütüphanesinin birleşimi.

---

## Proje Vizyonu

Kürt kültürünün dijital alanda yaşatılması ve güçlendirilmesi. Kullanıcılar metin, görsel, video ve PDF paylaşabilir; topluluklar oluşturabilir; birden fazla Kürtçe lehçede içerik üretebilir.

---

## Teknik Mimari

| Katman | Teknoloji | Rol |
|--------|-----------|-----|
| **Mobil & Web** | Flutter (Dart) | Cross-platform uygulama |
| **Veritabanı** | Supabase (PostgreSQL) | Tüm veri depolama |
| **Auth** | Supabase Auth | Kayıt, giriş, şifre sıfırlama |
| **Realtime** | Supabase Realtime | Mesajlar ve bildirimler |
| **Server Logic** | Supabase Edge Functions (Deno) | Dosya yükleme, bildirim gönderme |
| **Dosya Depolama** | Backblaze B2 | Medya dosyaları (görsel, video, PDF) |
| **CDN** | Cloudflare | Dosya dağıtımı (`cdn.nubar.app`) |
| **SEO** | Next.js | SSG ile arama motoru optimizasyonu |

---

## State Management: Riverpod

Tüm uygulama **flutter_riverpod** ile yönetiliyor. `setState` sadece UI-local state için kullanılıyor (form input, seçili dosya vs.), iş mantığı tamamen provider'larda.

**Provider türleri:**

- `StateNotifierProvider` — Auth, feed actions, profile actions, create post
- `FutureProvider` — Feed, post detail, comments, user profile
- `FutureProvider.family` — Parametre alan sorgular (postId, userId, communityId)
- `StateProvider` — Tema, dil, onboarding durumu
- `StreamProvider` — Auth state değişiklikleri

---

## Proje Yapısı (Detaylı)

```
nubar/
├── lib/
│   ├── main.dart                          ← Uygulama giriş noktası
│   │                                        Supabase init, ProviderScope,
│   │                                        tema, l10n, AuthGate (giriş/feed yönlendirme)
│   │
│   ├── core/                              ← Çekirdek altyapı
│   │   ├── constants/
│   │   │   ├── app_constants.dart         ← Sayfalama (20), max görsel (4),
│   │   │   │                                max post (500), max bio (160)
│   │   │   ├── supabase_constants.dart    ← 17 tablo adı + 5 edge function adı
│   │   │   └── backblaze_constants.dart   ← Dosya yolu helper'ları
│   │   │                                    (avatar, post image/video/pdf,
│   │   │                                     community avatar/banner, thumbnail)
│   │   │
│   │   ├── theme/
│   │   │   ├── app_theme.dart             ← AppThemeMode enum + ThemeData seçici
│   │   │   ├── theme_provider.dart        ← Riverpod StateNotifier ile tema değiştirme
│   │   │   └── themes/
│   │   │       ├── nubar_theme.dart       ← Varsayılan: Koyu yeşil (#2D6A4F) + Altın (#B7921A)
│   │   │       ├── dark_theme.dart        ← Karanlık: #0D1117 zemin
│   │   │       ├── light_theme.dart       ← Açık tema
│   │   │       ├── earth_theme.dart       ← Toprak: Kahverengi (#8B4513)
│   │   │       ├── ocean_theme.dart       ← Okyanus: Mavi (#1A6B8A)
│   │   │       └── amoled_theme.dart      ← Saf siyah (#000000) zemin
│   │   │
│   │   ├── l10n/                          ← Çoklu dil desteği (125+ string)
│   │   │   ├── app_ku.arb                ← Kurmancî (ana şablon, LTR)
│   │   │   ├── app_ckb.arb               ← Soranî (RTL, Arap alfabesi)
│   │   │   ├── app_tr.arb                ← Türkçe (LTR)
│   │   │   ├── app_ar.arb                ← Arapça (RTL)
│   │   │   └── app_en.arb                ← İngilizce (LTR)
│   │   │
│   │   └── utils/
│   │       ├── validators.dart            ← Email, şifre (min 8, büyük/küçük/rakam),
│   │       │                                username (3-20, alfanumerik), bio, post, yorum
│   │       ├── date_utils.dart            ← timeAgo (Kürtçe destekli), formatDateTime
│   │       └── file_utils.dart            ← Dosya uzantı kontrolü, boyut doğrulama,
│   │                                        okunabilir boyut formatı
│   │
│   ├── features/                          ← Her özellik kendi klasöründe izole
│   │   │
│   │   ├── navigation/
│   │   │   └── main_navigation_screen.dart ← Bottom NavigationBar
│   │   │                                     5 sekme: Feed, Search, Notifications,
│   │   │                                     Messages, Profile
│   │   │                                     IndexedStack ile state korunuyor
│   │   │
│   │   ├── auth/                          ← Kimlik doğrulama
│   │   │   ├── models/
│   │   │   │   └── auth_model.dart        ← UserModel: id, authId, username, fullName,
│   │   │   │                                avatarUrl, bio, website, location, verified,
│   │   │   │                                followerCount, followingCount, postCount,
│   │   │   │                                preferredLang, preferredTheme, createdAt
│   │   │   │                                + fromJson/toJson/copyWith
│   │   │   │
│   │   │   ├── providers/
│   │   │   │   └── auth_provider.dart     ← authStateProvider (Stream — auth değişiklikleri)
│   │   │   │                                currentUserProvider (kullanıcı profili çekme)
│   │   │   │                                authNotifierProvider (signIn, signUp, signOut,
│   │   │   │                                resetPassword)
│   │   │   │                                SignUp: auth.users'a kayıt + users tablosuna
│   │   │   │                                profil oluşturma (username, fullName, lang)
│   │   │   │
│   │   │   └── screens/
│   │   │       ├── login_screen.dart      ← E-posta/şifre formu, validasyon,
│   │   │       │                            şifre sıfırlama dialog'u,
│   │   │       │                            kayıt sayfasına yönlendirme
│   │   │       │
│   │   │       ├── register_screen.dart   ← Username, ad, e-posta, şifre,
│   │   │       │                            dil seçimi (5 dil), tüm validasyonlar
│   │   │       │
│   │   │       └── onboarding_screen.dart ← 3 sayfalık tanıtım (PageView):
│   │   │                                    1. Paylaş (metin/görsel/video/PDF)
│   │   │                                    2. Topluluk (oluştur/katıl)
│   │   │                                    3. Bağlan (Kürtlerle iletişim)
│   │   │                                    Sayfa göstergeleri, atla/ileri/başla
│   │   │
│   │   ├── feed/                          ← Ana akış
│   │   │   ├── providers/
│   │   │   │   └── feed_provider.dart     ← PostModel (26 alan: id, userId, content,
│   │   │   │                                type, mediaUrls, thumbnailUrl, communityId,
│   │   │   │                                originalPostId, isRepost, viewCount,
│   │   │   │                                likeCount, commentCount, repostCount,
│   │   │   │                                bookmarkCount, language, isDeleted, createdAt
│   │   │   │                                + joined author data)
│   │   │   │
│   │   │   │                                CommentModel (11 alan + joined author)
│   │   │   │
│   │   │   │                                feedProvider — sayfalanmış post sorgusu
│   │   │   │                                  (users join, is_deleted=false, created_at DESC)
│   │   │   │                                postDetailProvider — tekil post
│   │   │   │                                commentsProvider — post yorumları
│   │   │   │                                isLikedProvider — beğeni durumu
│   │   │   │                                isBookmarkedProvider — kayıt durumu
│   │   │   │                                isRepostedProvider — repost durumu
│   │   │   │
│   │   │   │                                FeedActionsNotifier:
│   │   │   │                                  likePost, unlikePost,
│   │   │   │                                  bookmarkPost, unbookmarkPost,
│   │   │   │                                  addComment, repost, undoRepost,
│   │   │   │                                  deletePost
│   │   │   │                                  (her action sonrası ilgili provider invalidate)
│   │   │   │
│   │   │   ├── screens/
│   │   │   │   └── feed_screen.dart       ← infinite_scroll_pagination ile
│   │   │   │                                sonsuz kaydırma, RefreshIndicator,
│   │   │   │                                StoryBar üstte, FAB ile yeni post,
│   │   │   │                                bildirim ikonu (NotificationsScreen'e)
│   │   │   │
│   │   │   └── widgets/
│   │   │       ├── post_card.dart         ← Yazar avatarı, isim, @username, timeAgo,
│   │   │       │                            içerik metni, medya grid (1 görsel: tam,
│   │   │       │                            2-4 görsel: 2x2 grid), PostActions,
│   │   │       │                            seçenekler menüsü (sil/raporla),
│   │   │       │                            dokunma → PostDetailScreen,
│   │   │       │                            avatar dokunma → ProfileScreen
│   │   │       │
│   │   │       ├── post_actions.dart      ← 5 eylem butonu:
│   │   │       │                            Yorum (→ PostDetailScreen)
│   │   │       │                            Repost (toggle, renk değişimi)
│   │   │       │                            Beğeni (kalp, kırmızı toggle)
│   │   │       │                            Kaydet (bookmark toggle)
│   │   │       │                            Paylaş (share_plus)
│   │   │       │                            Her biri sayaçlı
│   │   │       │
│   │   │       └── story_bar.dart         ← Yatay kaydırmalı hikaye çubuğu
│   │   │                                    (şu an placeholder data)
│   │   │
│   │   ├── post/                          ← Post oluşturma ve detay
│   │   │   ├── create/
│   │   │   │   ├── create_post_provider.dart ← CreatePostNotifier:
│   │   │   │   │                               1. Auth kontrolü + userId çekme
│   │   │   │   │                               2. Görseller varsa: post oluştur → postId al
│   │   │   │   │                                  → Backblaze'e yükle → mediaUrls güncelle
│   │   │   │   │                               3. Sadece metin: direkt insert
│   │   │   │   │                               communityId desteği
│   │   │   │   │
│   │   │   │   └── create_post_screen.dart ← Yazar avatarı + metin alanı (max 500),
│   │   │   │                                 çoklu görsel seçici (max 4, yatay liste),
│   │   │   │                                 video seçici (ImagePicker.pickVideo),
│   │   │   │                                 PDF seçici (FilePicker),
│   │   │   │                                 seçili medya önizlemesi + kaldırma,
│   │   │   │                                 karakter sayacı, loading state,
│   │   │   │                                 hata SnackBar
│   │   │   │
│   │   │   ├── detail/
│   │   │   │   └── post_detail_screen.dart ← Tam post görünümü: yazar bilgisi,
│   │   │   │                                 içerik, tarih, istatistikler
│   │   │   │                                 (beğeni/yorum sayısı), PostActions,
│   │   │   │                                 yorumlar listesi (avatar, isim, timeAgo),
│   │   │   │                                 yorum giriş alanı + gönder butonu
│   │   │   │
│   │   │   ├── pdf_viewer/
│   │   │   │   └── pdf_viewer_screen.dart ← Syncfusion SfPdfViewer.network:
│   │   │   │                                sayfa sayacı (X/Y), bookmark görünümü,
│   │   │   │                                ilk/son sayfa navigasyonu,
│   │   │   │                                onPageChanged + onDocumentLoaded
│   │   │   │
│   │   │   ├── video_player/
│   │   │   │   └── video_player_screen.dart ← Chewie + VideoPlayerController:
│   │   │   │                                  autoPlay, fullscreen desteği,
│   │   │   │                                  thumbnail placeholder,
│   │   │   │                                  hata durumu gösterimi,
│   │   │   │                                  siyah arka plan
│   │   │   │
│   │   │   └── poll/                      ← Anket sistemi
│   │   │       ├── poll_model.dart        ← PollModel: id, postId, question,
│   │   │       │                            options (PollOption list), endsAt,
│   │   │       │                            totalVotes, userVote, isExpired, hasVoted
│   │   │       │                            PollOption: key, text, voteCount, percentage()
│   │   │       │
│   │   │       ├── poll_provider.dart     ← pollProvider (poll çekme + kullanıcı oyu)
│   │   │       │                            PollActions: vote (insert + options count
│   │   │       │                            güncelleme), createPoll
│   │   │       │
│   │   │       └── poll_widget.dart       ← PollWidget: Oy verilmemişse butonlar,
│   │   │                                    oy verilmişse/süresi dolmuşsa
│   │   │                                    sonuç bar'ları (yüzde, renk, seçili işareti),
│   │   │                                    toplam oy + süre bilgisi
│   │   │
│   │   ├── community/                     ← Topluluk sistemi
│   │   │   ├── models/
│   │   │   │   └── community_model.dart   ← CommunityModel: id, name, slug, description,
│   │   │   │                                avatarUrl, bannerUrl, isPrivate, memberCount,
│   │   │   │                                postCount, createdBy, createdAt
│   │   │   │                                + fromJson/toJson/copyWith
│   │   │   │                                CommunityMemberModel: id, communityId,
│   │   │   │                                userId, role, joinedAt
│   │   │   │
│   │   │   ├── providers/
│   │   │   │   └── community_provider.dart ← communitiesProvider (tüm topluluklar)
│   │   │   │                                communityDetailProvider(id)
│   │   │   │                                communityMembersProvider(id)
│   │   │   │                                isCommunityMemberProvider(id)
│   │   │   │                                userCommunitiesProvider (kullanıcının toplulukları)
│   │   │   │                                CommunityActions: createCommunity (oluştur +
│   │   │   │                                  admin olarak ekle), joinCommunity,
│   │   │   │                                  leaveCommunity, updateCommunity
│   │   │   │
│   │   │   └── screens/
│   │   │       ├── community_feed_screen.dart ← SliverAppBar (banner + isim),
│   │   │       │                                avatar, üye/post sayısı,
│   │   │       │                                katıl/ayrıl butonu, açıklama,
│   │   │       │                                private rozeti, ayarlar ikonu,
│   │   │       │                                FAB ile topluluk postu oluşturma
│   │   │       │
│   │   │       ├── create_community_screen.dart ← İsim (auto-slug oluşturma),
│   │   │       │                                  slug, açıklama, private toggle,
│   │   │       │                                  validasyonlar, başarıda feed'e yönlendirme
│   │   │       │
│   │   │       └── community_settings_screen.dart ← İsim/açıklama düzenleme,
│   │   │                                            private toggle, üye sayısı,
│   │   │                                            topluluktan ayrıl butonu
│   │   │
│   │   ├── profile/                       ← Kullanıcı profili
│   │   │   ├── providers/
│   │   │   │   └── profile_provider.dart  ← userProfileProvider(userId) — profil çekme
│   │   │   │                                isFollowingProvider(userId) — takip durumu
│   │   │   │                                ProfileActionsNotifier: follow, unfollow,
│   │   │   │                                updateProfile (name, bio, website, location,
│   │   │   │                                avatarUrl)
│   │   │   │
│   │   │   └── screens/
│   │   │       ├── profile_screen.dart    ← Avatar, isim, @username, verified rozeti,
│   │   │       │                            bio, konum, website, post/takipçi/takip
│   │   │       │                            istatistikleri, takip et/bırak veya
│   │   │       │                            düzenle butonu
│   │   │       │
│   │   │       └── edit_profile_screen.dart ← Avatar seçici (kamera ikonu overlay,
│   │   │                                      Backblaze'e yükleme, yükleme göstergesi),
│   │   │                                      ad, bio (max 160), website, konum alanları
│   │   │
│   │   ├── notifications/                 ← Bildirim sistemi
│   │   │   ├── providers/
│   │   │   │   └── notifications_provider.dart ← NotificationModel (id, userId, type,
│   │   │   │                                     actorId, postId, commentId, isRead)
│   │   │   │                                     notificationsProvider — tüm bildirimler
│   │   │   │                                     unreadCountProvider — okunmamış sayısı
│   │   │   │                                     NotificationActions: markAsRead,
│   │   │   │                                     markAllAsRead
│   │   │   │
│   │   │   └── screens/
│   │   │       └── notifications_screen.dart ← Tipe göre ikon (beğeni=kalp,
│   │   │                                       yorum=balon, takip=kişi,
│   │   │                                       repost=tekrar, mesaj=mail),
│   │   │                                       okunmamış vurgulama, avatar,
│   │   │                                       zaman, tümünü okundu işaretle
│   │   │
│   │   ├── messages/                      ← Mesajlaşma sistemi
│   │   │   ├── providers/
│   │   │   │   └── messages_provider.dart ← MessageModel, ConversationModel
│   │   │   │                                conversationsProvider — konuşma listesi
│   │   │   │                                chatMessagesProvider(userId) — mesajlar
│   │   │   │                                MessageActions: sendMessage
│   │   │   │
│   │   │   └── screens/
│   │   │       ├── messages_list_screen.dart ← Konuşma listesi: avatar, son mesaj
│   │   │       │                               önizlemesi, zaman, okunmamış rozeti
│   │   │       │
│   │   │       └── chat_screen.dart       ← Mesaj balonları (sol/sağ hizalama),
│   │   │                                    zaman damgası, mesaj girişi + gönder
│   │   │
│   │   └── search/                        ← Arama sistemi
│   │       ├── providers/
│   │       │   └── search_provider.dart   ← searchQueryProvider — arama metni
│   │       │                                postSearchProvider — full-text search (tsvector)
│   │       │                                userSearchProvider — ilike ile kullanıcı arama
│   │       │                                trendingHashtagsProvider — popüler hashtagler
│   │       │
│   │       └── screens/
│   │           └── search_screen.dart     ← Sekmeli arayüz (Postlar/Kullanıcılar),
│   │                                        boşken trending hashtagler,
│   │                                        post sonuçları, kullanıcı sonuçları
│   │                                        (avatar + username ile navigasyon)
│   │
│   └── shared/                            ← Paylaşılan bileşenler
│       ├── widgets/
│       │   ├── nubar_button.dart          ← Elevated/Outlined buton, loading state,
│       │   │                                isteğe bağlı ikon, genişlik parametresi
│       │   │
│       │   ├── nubar_text_field.dart      ← TextFormField wrapper: label, hint,
│       │   │                                validasyon, obscure, maxLines, maxLength,
│       │   │                                prefix/suffix ikonları, onChanged, enabled
│       │   │
│       │   ├── nubar_avatar.dart          ← CachedNetworkImage ile daire avatar,
│       │   │                                null URL'de baş harf fallback,
│       │   │                                radius ve onTap parametreleri
│       │   │
│       │   └── loading_indicator.dart     ← Ortalanmış CircularProgressIndicator
│       │                                    + isteğe bağlı mesaj
│       │
│       └── services/
│           ├── supabase_service.dart      ← Singleton Supabase client:
│           │                                initialize (dotenv), auth helper'ları
│           │                                (signUp, signIn, signOut, resetPassword),
│           │                                from(table), invokeFunction, channel
│           │
│           └── backblaze_service.dart     ← uploadFile (Edge Function ile signed URL al
│                                            → Backblaze'e direkt yükle → CDN URL dön),
│                                            getFileUrl, deleteFile
│
├── supabase/
│   ├── migrations/
│   │   └── 001_initial_schema.sql         ← TAM veritabanı şeması:
│   │                                        2 extension, 6 enum, 17 tablo,
│   │                                        12 index, 17 tablo RLS aktif,
│   │                                        30+ RLS politikası,
│   │                                        8 trigger fonksiyonu (like/comment/repost/
│   │                                        bookmark/follow/post/member/comment_like
│   │                                        counter güncellemeleri),
│   │                                        realtime (messages + notifications)
│   │
│   └── functions/
│       ├── generate-upload-url/
│       │   └── index.ts                   ← Auth doğrulama → Backblaze B2 auth
│       │                                    → b2_get_upload_url → signed URL dönme
│       │
│       ├── delete-file/
│       │   └── index.ts                   ← Auth doğrulama → Backblaze auth
│       │                                    → b2_list_file_names → b2_delete_file_version
│       │
│       └── send-notification/
│           └── index.ts                   ← notifications tablosuna insert
│                                            + FCM push notification placeholder
│
└── next-seo/                              ← SEO katmanı için başlangıç scaffold (Phase 5)
    ├── app/
    │   ├── page.tsx
    │   ├── post/[id]/page.tsx
    │   ├── community/[slug]/page.tsx
    │   └── user/[username]/page.tsx
    └── lib/
        └── supabase.ts
```

---

## Veritabanı Şeması

**17 tablo**, aralarında foreign key ilişkileri:

```
users ──────┬── posts ──────┬── comments ──── comment_likes
            │               ├── likes
            │               ├── reposts
            │               ├── bookmarks
            │               ├── polls ──── poll_votes
            │               └── post_hashtags ──── hashtags
            │
            ├── follows (follower_id ↔ following_id)
            ├── messages (sender_id ↔ receiver_id)
            ├── notifications
            ├── reports
            └── community_members ──── communities
```

**Counter trigger'lar** (otomatik güncelleme):

- `likes` insert/delete → `posts.like_count` ±1
- `comments` insert/delete → `posts.comment_count` ±1
- `reposts` insert/delete → `posts.repost_count` ±1
- `bookmarks` insert/delete → `posts.bookmark_count` ±1
- `follows` insert/delete → `users.follower_count` / `following_count` ±1
- `posts` insert/delete → `users.post_count` ±1
- `community_members` insert/delete → `communities.member_count` ±1
- `comment_likes` insert/delete → `comments.like_count` ±1

---

## Dosya Yükleme Akışı

```
Flutter App                    Edge Function                Backblaze B2
    │                              │                            │
    ├── POST /generate-upload-url ─┤                            │
    │   {path, contentType}        ├── B2 Auth ─────────────────┤
    │                              ├── b2_get_upload_url ───────┤
    │   ← {uploadUrl, authToken}   │                            │
    │                              │                            │
    ├── PUT upload directly ───────┼────────────────────────────┤
    │   (signed URL ile)           │                            │
    │                              │                            │
    ├── CDN URL = cdn.nubar.app/path                            │
    ├── Supabase'e URL kaydet      │                            │
```

**Dosya yapısı (Backblaze B2):**

```
nubar-bucket/
├── avatars/{user_id}/profile.jpg
├── posts/images/{post_id}/{filename}.jpg
├── posts/videos/{post_id}/{filename}.mp4
├── posts/pdfs/{post_id}/{filename}.pdf
├── communities/avatars/{community_id}/avatar.jpg
├── communities/banners/{community_id}/banner.jpg
└── thumbnails/videos|pdfs/{post_id}/thumb.jpg
```

---

## Tema Sistemi

6 tema, tümü **Material 3** tabanlı:

| Tema | Primary | Background | Karakter |
|------|---------|------------|----------|
| **Nûbar** (varsayılan) | `#2D6A4F` koyu yeşil | `#FAF7F0` krem | Doğal, sıcak |
| **Dark** | `#40916C` yeşil | `#0D1117` koyu | GitHub Dark benzeri |
| **Light** | Standart açık | `#FFFFFF` beyaz | Temiz, minimal |
| **Earth** | `#8B4513` kahve | `#FDF5E6` kum | Toprak tonları |
| **Ocean** | `#1A6B8A` deniz | `#F0F8FF` açık mavi | Sakin, ferah |
| **AMOLED** | `#40916C` yeşil | `#000000` saf siyah | OLED ekranlar için |

---

## Dil Desteği

| Kod | Dil | Yön | Alfabe |
|-----|-----|-----|--------|
| `ku` | Kurmancî (şablon) | LTR | Latin |
| `ckb` | Soranî | **RTL** | Arap |
| `tr` | Türkçe | LTR | Latin |
| `ar` | Arapça | **RTL** | Arap |
| `en` | İngilizce | LTR | Latin |

RTL otomatik olarak `MaterialApp.supportedLocales` ve `GlobalWidgetsLocalizations` ile yönetiliyor.

---

## Uygulama Akışı

```
App başlangıç
    │
    ├── dotenv yükle
    ├── Supabase init
    ├── ProviderScope (Riverpod)
    │
    └── AuthGate
         ├── session var → MainNavigationScreen (5 sekmeli)
         ├── onboarding tamamlanmamış → OnboardingScreen
         └── session yok → LoginScreen → RegisterScreen
```

---

## Tamamlanan Fazlar

### Phase 1 — Core MVP ✅

- Supabase + Flutter + Riverpod kurulumu
- 6 tema sistemi
- 5 dil + RTL desteği
- Auth (giriş, kayıt, onboarding, şifre sıfırlama)
- Profil (görüntüle, düzenle, avatar yükleme)
- Post oluşturma (metin + görsel)
- Feed (sonsuz kaydırma, yenile)
- Beğeni, yorum, takip sistemi
- Bildirimler
- Bottom navigation

### Phase 2 — Medya ✅

- Backblaze B2 entegrasyonu
- PDF görüntüleyici (Syncfusion)
- Video oynatıcı (Chewie)
- Repost işlevselliği
- Kaydetme (bookmark)
- Video/PDF seçici
- Edge Functions (generate-upload-url, delete-file, send-notification)

### Phase 3 — Community ✅

- Topluluk oluşturma/düzenleme
- Topluluk feed'i
- Katıl/ayrıl
- Topluluk ayarları
- Anket sistemi (oluştur, oy ver, sonuçlar)
- Arama (full-text + trending hashtagler)

### Phase 4-5 — Bekleyen

- [ ] Realtime mesajlar (Supabase Realtime)
- [ ] Realtime bildirimler
- [ ] Rozet/seviye sistemi
- [ ] Kullanıcı engelleme
- [ ] İçerik raporlama (UI tamamlandı, backend kısmen)
- [ ] Next.js SEO katmanı

---

## Bağımlılıklar (pubspec.yaml)

| Paket | Kullanım |
|-------|----------|
| `supabase_flutter` | Veritabanı, auth, realtime |
| `flutter_riverpod` | State management |
| `syncfusion_flutter_pdfviewer` | PDF görüntüleme |
| `video_player` + `chewie` | Video oynatma |
| `cached_network_image` | Görsel önbellekleme |
| `image_picker` | Kamera/galeri görsel seçimi |
| `file_picker` | PDF dosya seçimi |
| `infinite_scroll_pagination` | Sonsuz kaydırma listeleri |
| `share_plus` | Sistem paylaşım dialog'u |
| `timeago` | "5 dk önce" formatı |
| `flutter_dotenv` | .env değişkenleri |
| `http` / `dio` | HTTP istekleri (Backblaze) |
| `shimmer` | Yükleme animasyonları |
| `flutter_animate` | UI animasyonları |
| `url_launcher` | Harici URL açma |
| `intl` | Uluslararasılaştırma |

---

## Kodlama Kuralları

1. **Riverpod** — `setState` sadece widget-local UI state için
2. **Tema** — `Theme.of(context).colorScheme` kullan, renk hardcode etme
3. **Metin** — `AppLocalizations.of(context)` kullan, string hardcode etme
4. **Dosya** — Her zaman `BackblazeService` üzerinden, asla Supabase Storage'a direkt
5. **Auth** — Korumalı işlemlerden önce `currentUser` kontrol et
6. **RLS** — Supabase RLS yetkilendirmeyi yönetiyor, Flutter'da tekrarlama
7. **Sayfalama** — Her zaman `infinite_scroll_pagination`, asla tüm veriyi çekme
8. **Görseller** — Her zaman `CachedNetworkImage`, asla `Image.network`
9. **Hatalar** — `AsyncValue.error` ile yönet, sessizce başarısız olma
10. **RTL** — Her widget'ı LTR ve RTL'de test et

---

**Toplam: 44 Dart dosyası, 3 Edge Function, 1 SQL migration, ~4000+ satır kod**
