# Nûbar — Profesyonel Proje Yol Haritası (Roadmap)

## 📋 Proje Durum Analizi

**Nûbar**: Kürt topluluğu için Twitter + Reddit + YouTube + PDF kütüphanesi birleşimi dijital sosyal platform.

| Özellik | Detay |
|---------|-------|
| **Teknoloji** | Flutter (Dart) + Supabase (PostgreSQL) + Backblaze B2 + Cloudflare CDN + Next.js SEO |
| **State Management** | Riverpod (StateNotifier, FutureProvider, StreamProvider) |
| **Mevcut Kod** | ~66 Dart dosyası, 3 Edge Function, 2 SQL migration, 11 Next.js dosyası |
| **Tamamlanan Fazlar** | Phase 1 (Core MVP) ✅, Phase 2 (Medya) ✅, Phase 3 (Community) ✅ |
| **Kısmen Başlanmış** | Badge/Level sistemi, Block sistemi, Realtime mesajlar (provider'lar hazır) |
| **Bekleyen** | Realtime bildirimler, SEO katmanı, test altyapısı, production hazırlığı |

---

## 🏗️ İdeal Klasör Yapısı (Hedef)

```
nubar/
├── lib/
│   ├── main.dart
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_constants.dart
│   │   │   ├── supabase_constants.dart
│   │   │   └── backblaze_constants.dart
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   ├── theme_provider.dart
│   │   │   └── themes/
│   │   │       ├── nubar_theme.dart
│   │   │       ├── dark_theme.dart
│   │   │       ├── light_theme.dart
│   │   │       ├── earth_theme.dart
│   │   │       ├── ocean_theme.dart
│   │   │       └── amoled_theme.dart
│   │   ├── l10n/
│   │   │   ├── app_ku.arb
│   │   │   ├── app_ckb.arb
│   │   │   ├── app_tr.arb
│   │   │   ├── app_ar.arb
│   │   │   └── app_en.arb
│   │   ├── utils/
│   │   │   ├── validators.dart
│   │   │   ├── date_utils.dart
│   │   │   └── file_utils.dart
│   │   ├── router/                          ← [NEW] Navigasyon yönetimi
│   │   │   └── app_router.dart              ← GoRouter + deeplink desteği
│   │   └── error/                           ← [NEW] Global hata yönetimi
│   │       └── error_handler.dart           ← Hata raporlama, fallback UI
│   │
│   ├── features/
│   │   ├── navigation/
│   │   │   └── main_navigation_screen.dart
│   │   │
│   │   ├── auth/
│   │   │   ├── models/
│   │   │   │   └── auth_model.dart
│   │   │   ├── providers/
│   │   │   │   └── auth_provider.dart
│   │   │   └── screens/
│   │   │       ├── login_screen.dart
│   │   │       ├── register_screen.dart
│   │   │       └── onboarding_screen.dart
│   │   │
│   │   ├── feed/
│   │   │   ├── providers/
│   │   │   │   └── feed_provider.dart
│   │   │   ├── screens/
│   │   │   │   └── feed_screen.dart
│   │   │   └── widgets/
│   │   │       ├── post_card.dart
│   │   │       ├── post_actions.dart
│   │   │       └── story_bar.dart
│   │   │
│   │   ├── post/
│   │   │   ├── create/
│   │   │   │   ├── create_post_provider.dart
│   │   │   │   └── create_post_screen.dart
│   │   │   ├── detail/
│   │   │   │   └── post_detail_screen.dart
│   │   │   ├── pdf_viewer/
│   │   │   │   └── pdf_viewer_screen.dart
│   │   │   ├── video_player/
│   │   │   │   └── video_player_screen.dart
│   │   │   └── poll/
│   │   │       ├── poll_model.dart
│   │   │       ├── poll_provider.dart
│   │   │       └── poll_widget.dart
│   │   │
│   │   ├── community/
│   │   │   ├── models/
│   │   │   │   └── community_model.dart
│   │   │   ├── providers/
│   │   │   │   └── community_provider.dart
│   │   │   └── screens/
│   │   │       ├── community_feed_screen.dart
│   │   │       ├── create_community_screen.dart
│   │   │       └── community_settings_screen.dart
│   │   │
│   │   ├── profile/
│   │   │   ├── providers/
│   │   │   │   ├── profile_provider.dart
│   │   │   │   ├── badge_provider.dart       ← Mevcut (kısmen tamamlanmış)
│   │   │   │   └── block_provider.dart       ← Mevcut (kısmen tamamlanmış)
│   │   │   ├── screens/
│   │   │   │   ├── profile_screen.dart
│   │   │   │   ├── edit_profile_screen.dart
│   │   │   │   ├── followers_screen.dart     ← [NEW] Takipçi listesi
│   │   │   │   └── blocked_users_screen.dart ← [NEW] Engellenen kullanıcılar
│   │   │   └── widgets/
│   │   │       ├── badge_display.dart        ← Mevcut
│   │   │       └── level_progress.dart       ← [NEW] Seviye ilerleme çubuğu
│   │   │
│   │   ├── notifications/
│   │   │   ├── providers/
│   │   │   │   └── notifications_provider.dart  ← MODIFY (realtime ekle)
│   │   │   └── screens/
│   │   │       └── notifications_screen.dart
│   │   │
│   │   ├── messages/
│   │   │   ├── providers/
│   │   │   │   └── messages_provider.dart    ← Mevcut (realtime hazır)
│   │   │   └── screens/
│   │   │       ├── messages_list_screen.dart
│   │   │       └── chat_screen.dart
│   │   │
│   │   ├── search/
│   │   │   ├── providers/
│   │   │   │   └── search_provider.dart
│   │   │   └── screens/
│   │   │       └── search_screen.dart
│   │   │
│   │   ├── report/
│   │   │   └── report_dialog.dart           ← Mevcut
│   │   │
│   │   └── settings/                        ← [NEW] Uygulama ayarları
│   │       ├── providers/
│   │       │   └── settings_provider.dart
│   │       └── screens/
│   │           └── settings_screen.dart      ← Tema, dil, hesap, engeller
│   │
│   └── shared/
│       ├── widgets/
│       │   ├── nubar_button.dart
│       │   ├── nubar_text_field.dart
│       │   ├── nubar_avatar.dart
│       │   ├── loading_indicator.dart
│       │   ├── error_widget.dart             ← [NEW] Hata gösterim widgetı
│       │   └── empty_state.dart              ← [NEW] Boş sayfa widgetı
│       └── services/
│           ├── supabase_service.dart
│           ├── backblaze_service.dart
│           └── notification_service.dart     ← [NEW] Push notification (FCM)
│
├── supabase/
│   ├── migrations/
│   │   ├── 001_initial_schema.sql           ← Mevcut (17 tablo)
│   │   ├── 002_phase4_schema.sql            ← Mevcut (blocks, badges, levels)
│   │   └── 003_phase5_optimizations.sql     ← [NEW] İndeksler, görünümler, fonksiyonlar
│   └── functions/
│       ├── generate-upload-url/index.ts
│       ├── delete-file/index.ts
│       ├── send-notification/index.ts
│       ├── check-badges/index.ts            ← [NEW] Badge otomatik kazanma
│       └── moderate-content/index.ts        ← [NEW] İçerik moderasyonu
│
├── next-seo/
│   ├── app/
│   │   ├── layout.tsx
│   │   ├── page.tsx                         ← MODIFY (ana sayfa SEO)
│   │   ├── post/[id]/page.tsx               ← MODIFY (post detay SEO)
│   │   ├── community/[slug]/page.tsx        ← MODIFY (topluluk SEO)
│   │   ├── user/[username]/page.tsx         ← MODIFY (profil SEO)
│   │   ├── robots.ts                        ← Mevcut
│   │   └── sitemap.ts                       ← Mevcut
│   ├── lib/
│   │   └── supabase.ts
│   ├── next.config.js
│   ├── package.json
│   └── tsconfig.json
│
├── test/                                    ← [NEW] Test altyapısı
│   ├── unit/
│   │   ├── validators_test.dart
│   │   ├── date_utils_test.dart
│   │   ├── auth_provider_test.dart
│   │   └── feed_provider_test.dart
│   ├── widget/
│   │   ├── post_card_test.dart
│   │   └── poll_widget_test.dart
│   └── integration/
│       └── auth_flow_test.dart
│
├── assets/
│   ├── images/
│   └── icons/
│
├── .env
├── .env.local
├── .gitignore
├── pubspec.yaml
├── analysis_options.yaml
├── l10n.yaml
└── README.md
```

---

## 🗺️ Geliştirme Fazları

---

### Faz 4: Sosyal Özellikler & Realtime (Phase 4 — Tamamlama)

**Hedef:** Kısmen başlanmış Phase 4 özelliklerini tamamlayıp tam işlevsel hale getirmek.

**Durum:** Badge/Block provider'ları ve Realtime mesaj altyapısı mevcut, ancak UI entegrasyonu ve bazı eksikler var.

---

#### 4A. Realtime Bildirimler

**Durum:** Mesajlar realtime çalışıyor ✅, bildirimler henüz realtime değil ❌

##### İlgili Dosyalar

| İşlem | Dosya | Açıklama |
|-------|-------|----------|
| MODIFY | [notifications_provider.dart](file:///c:/Users/mehme/Desktop/nubar/lib/features/notifications/providers/notifications_provider.dart) | Supabase Realtime subscription ekle |
| MODIFY | [notifications_screen.dart](file:///c:/Users/mehme/Desktop/nubar/lib/features/notifications/screens/notifications_screen.dart) | Gerçek zamanlı güncelleme UI |
| MODIFY | [main_navigation_screen.dart](file:///c:/Users/mehme/Desktop/nubar/lib/features/navigation/main_navigation_screen.dart) | Realtime unread badge |

##### Yapılacak İşlemler

1. [notifications_provider.dart](file:///c:/Users/mehme/Desktop/nubar/lib/features/notifications/providers/notifications_provider.dart):
   - `NotificationsNotifier` → `StateNotifierProvider` olarak yeniden yaz (mesajlardaki [RealtimeChatNotifier](file:///c:/Users/mehme/Desktop/nubar/lib/features/messages/providers/messages_provider.dart#105-226) benzeri)
   - `RealtimeChannel` ile `notifications` tablosunu dinle
   - `PostgresChangeEvent.insert` filtresi: `receiver_id == currentUserId`
   - Yeni bildirimde listeye `prepend` et (optimistic)
   - `unreadCountProvider` → realtime state'ten hesapla
2. [notifications_screen.dart](file:///c:/Users/mehme/Desktop/nubar/lib/features/notifications/screens/notifications_screen.dart):
   - `FutureProvider` yerine `StateNotifierProvider` kullan
   - Animasyonlu yeni bildirim girişi (`flutter_animate`)
3. [main_navigation_screen.dart](file:///c:/Users/mehme/Desktop/nubar/lib/features/navigation/main_navigation_screen.dart):
   - Badge sayacını realtime state'e bağla

> [!IMPORTANT]
> Mesajlar provider'ı ([messages_provider.dart](file:///c:/Users/mehme/Desktop/nubar/lib/features/messages/providers/messages_provider.dart)) zaten doğru Realtime pattern'ı uyguluyor. Bildirimler aynı kalıbı takip etmeli.

---

#### 4B. Badge/Seviye Sistemi Tamamlama

**Durum:** Provider'lar ve DB hazır ✅, UI entegrasyonu eksik ❌

##### İlgili Dosyalar

| İşlem | Dosya | Açıklama |
|-------|-------|----------|
| MODIFY | [profile_screen.dart](file:///c:/Users/mehme/Desktop/nubar/lib/features/profile/screens/profile_screen.dart) | Badge ve seviye gösterimi |
| Mevcut | [badge_provider.dart](file:///c:/Users/mehme/Desktop/nubar/lib/features/profile/providers/badge_provider.dart) | Badge sorgulama (✅ tamamlanmış) |
| Mevcut | [badge_display.dart](file:///c:/Users/mehme/Desktop/nubar/lib/features/profile/widgets/badge_display.dart) | Badge widget (✅ tamamlanmış) |
| NEW | [level_progress.dart](file:///c:/Users/mehme/Desktop/nubar/lib/features/profile/widgets/level_progress.dart) | Seviye ilerleme çubuğu |
| NEW | [check-badges/index.ts](file:///c:/Users/mehme/Desktop/nubar/supabase/functions/check-badges/index.ts) | Otomatik badge verme Edge Function |

##### Yapılacak İşlemler

1. [profile_screen.dart](file:///c:/Users/mehme/Desktop/nubar/lib/features/profile/screens/profile_screen.dart):
   - Profil header altına badge grid ekle (`userBadgesProvider`)
   - Seviye göstergesi: yıldız ikonu + seviye numarası + ilerleme çubuğu
   - Badge'e tıklayınca detay dialog (isim, açıklama, kazanma tarihi)
2. `level_progress.dart`:
   - LinearProgressIndicator ile sonraki seviyeye ilerleme
   - Mevcut seviye (1-5) ve hedef post/takipçi sayıları
3. `check-badges/index.ts` (Edge Function):
   - Trigger: post/comment/follow eklendikten sonra çağır
   - Badge kriterleri kontrol et → kazanılmamışsa `user_badges`'e insert
   - Bildirim oluştur ("Yeni rozet kazandınız!")

---

#### 4C. Kullanıcı Engelleme UI'ı

**Durum:** Provider tamam ✅, UI eksik ❌

##### İlgili Dosyalar

| İşlem | Dosya | Açıklama |
|-------|-------|----------|
| Mevcut | [block_provider.dart](file:///c:/Users/mehme/Desktop/nubar/lib/features/profile/providers/block_provider.dart) | Block/unblock logic (✅ tamamlanmış) |
| MODIFY | [profile_screen.dart](file:///c:/Users/mehme/Desktop/nubar/lib/features/profile/screens/profile_screen.dart) | Engelle butonu ekle |
| MODIFY | [feed_provider.dart](file:///c:/Users/mehme/Desktop/nubar/lib/features/feed/providers/feed_provider.dart) | Engellenen kullanıcı postlarını filtrele |
| MODIFY | [post_card.dart](file:///c:/Users/mehme/Desktop/nubar/lib/features/feed/widgets/post_card.dart) | 3-nokta menüsüne "Engelle" ekle |
| NEW | [blocked_users_screen.dart](file:///c:/Users/mehme/Desktop/nubar/lib/features/profile/screens/blocked_users_screen.dart) | Engellenen kullanıcılar listesi |

##### Yapılacak İşlemler

1. [profile_screen.dart](file:///c:/Users/mehme/Desktop/nubar/lib/features/profile/screens/profile_screen.dart):
   - Başkasının profilinde: PopupMenuButton içinde "Engelle/Engeli Kaldır" seçeneği
   - `isBlockedProvider` ile dinamik buton durumu
   - Onay dialog'u göster ("Bu kullanıcıyı engellemek istediğinize emin misiniz?")
2. [feed_provider.dart](file:///c:/Users/mehme/Desktop/nubar/lib/features/feed/providers/feed_provider.dart):
   - Feed sorgusuna `blockedUserIdsProvider` entegrasyonu
   - `feedProvider` → engellenen kullanıcıların postlarını client-side veya SQL `NOT IN` ile filtrele
3. `blocked_users_screen.dart`:
   - `blockedUserIdsProvider` ile liste
   - Her kullanıcı satırında avatar, isim ve "Engeli Kaldır" butonu
4. [post_card.dart](file:///c:/Users/mehme/Desktop/nubar/lib/features/feed/widgets/post_card.dart):
   - Seçenekler menüsüne "Engelle" ekle (kendi postun değilse)

---

#### 4D. İçerik Raporlama Tamamlama

**Durum:** UI (report_dialog.dart) var ✅, backend kısmen ❌

##### İlgili Dosyalar

| İşlem | Dosya | Açıklama |
|-------|-------|----------|
| Mevcut | [report_dialog.dart](file:///c:/Users/mehme/Desktop/nubar/lib/features/report/report_dialog.dart) | Raporlama UI (✅ tamamlanmış) |
| MODIFY | [post_card.dart](file:///c:/Users/mehme/Desktop/nubar/lib/features/feed/widgets/post_card.dart) | Raporla butonunun entegrasyonu doğrula |
| NEW | [moderate-content/index.ts](file:///c:/Users/mehme/Desktop/nubar/supabase/functions/moderate-content/index.ts) | Rapor eşik kontrolü (ör. 3+ rapor → auto-hide) |

##### Yapılacak İşlemler

1. `moderate-content/index.ts`:
   - Rapor sayısı eşiğini kontrol eden Edge Function
   - 3+ rapor → `posts.is_deleted = true` (soft delete)
   - Admin'e bildirim gönder
2. Report dialog entegrasyonu doğrula:
   - [post_card.dart](file:///c:/Users/mehme/Desktop/nubar/lib/features/feed/widgets/post_card.dart) ve [post_detail_screen.dart](file:///c:/Users/mehme/Desktop/nubar/lib/features/post/detail/post_detail_screen.dart) menülerinden çağrılıyor mu kontrol et

---

### Faz 5: Ayarlar, Navigasyon & UX İyileştirmeleri

**Hedef:** Uygulama kullanılabilirliğini profesyonel seviyeye çıkarmak.

---

#### 5A. Ayarlar Modülü

##### İlgili Dosyalar

| İşlem | Dosya | Açıklama |
|-------|-------|----------|
| NEW | [settings_screen.dart](file:///c:/Users/mehme/Desktop/nubar/lib/features/settings/screens/settings_screen.dart) | Ana ayarlar ekranı |
| NEW | [settings_provider.dart](file:///c:/Users/mehme/Desktop/nubar/lib/features/settings/providers/settings_provider.dart) | Ayar tercihleri state |
| MODIFY | [main_navigation_screen.dart](file:///c:/Users/mehme/Desktop/nubar/lib/features/navigation/main_navigation_screen.dart) | Ayarlar sayfasına erişim |

##### Yapılacak İşlemler

1. [settings_screen.dart](file:///c:/Users/mehme/Desktop/nubar/lib/features/community/screens/community_settings_screen.dart):
   - **Görünüm**: Tema seçimi (6 tema), Dil seçimi (5 dil)
   - **Hesap**: Şifre değiştir, E-posta güncelle, Hesabı sil
   - **Gizlilik**: Engellenen kullanıcılar, Profili gizle
   - **Bildirimler**: Push notification on/off, e-posta bildirimleri
   - **Hakkında**: Sürüm, lisanslar, gizlilik politikası
2. `settings_provider.dart`:
   - Tema ve dil değişimini `SharedPreferences` + Supabase'e senkronize et

---

#### 5B. Gelişmiş Navigasyon (GoRouter)

##### İlgili Dosyalar

| İşlem | Dosya | Açıklama |
|-------|-------|----------|
| NEW | [app_router.dart](file:///c:/Users/mehme/Desktop/nubar/lib/core/router/app_router.dart) | Merkezi rota tanımları |
| MODIFY | [main.dart](file:///c:/Users/mehme/Desktop/nubar/lib/main.dart) | GoRouter entegrasyonu |

##### Yapılacak İşlemler

1. `go_router` paketini [pubspec.yaml](file:///c:/Users/mehme/Desktop/nubar/pubspec.yaml)'a ekle
2. Tüm rotaları merkezi olarak tanımla:
   - `/` → Feed, `/post/:id` → PostDetail, `/profile/:userId` → Profile
   - `/community/:slug` → CommunityFeed, `/settings` → Settings
   - `/chat/:userId` → Chat, `/search` → Search
3. Deep linking desteği (URL ile doğrudan erişim)
4. Auth guard: giriş yapmamışsa → `/login`
5. `Navigator.push` çağrılarını `context.go()` / `context.push()` ile değiştir

---

#### 5C. Paylaşılan Widget'lar & UX

##### İlgili Dosyalar

| İşlem | Dosya | Açıklama |
|-------|-------|----------|
| NEW | [error_widget.dart](file:///c:/Users/mehme/Desktop/nubar/lib/shared/widgets/error_widget.dart) | Global hata widgetı |
| NEW | [empty_state.dart](file:///c:/Users/mehme/Desktop/nubar/lib/shared/widgets/empty_state.dart) | Boş durum widgetı |
| MODIFY | Feed, Search, Notifications ekranları | Error/empty widget kullanımı |

##### Yapılacak İşlemler

1. `error_widget.dart`:
   - İkon + mesaj + "Tekrar Dene" butonu
   - Tema renkleri ile uyumlu
2. `empty_state.dart`:
   - İkon + başlık + açıklama + CTA butonu
   - Örn: feed boşsa "Henüz post yok, takip etmeye başlayın!"
3. Tüm ekranlarda tutarlı error/empty state kullanımı

---

#### 5D. Takipçi/Takip Listesi Ekranı

##### İlgili Dosyalar

| İşlem | Dosya | Açıklama |
|-------|-------|----------|
| NEW | [followers_screen.dart](file:///c:/Users/mehme/Desktop/nubar/lib/features/profile/screens/followers_screen.dart) | Takipçiler ve takip edilenler |
| MODIFY | [profile_screen.dart](file:///c:/Users/mehme/Desktop/nubar/lib/features/profile/screens/profile_screen.dart) | Sayılara tıklayınca liste aç |
| MODIFY | [profile_provider.dart](file:///c:/Users/mehme/Desktop/nubar/lib/features/profile/providers/profile_provider.dart) | followersProvider, followingProvider ekle |

##### Yapılacak İşlemler

1. [profile_provider.dart](file:///c:/Users/mehme/Desktop/nubar/lib/features/profile/providers/profile_provider.dart):
   - `followersProvider(userId)` → takipçi listesi (users join)
   - `followingProvider(userId)` → takip edilenler listesi
2. `followers_screen.dart`:
   - TabBar: "Takipçiler" / "Takip Edilenler"
   - Her satırda avatar, isim, @username, takip et/bırak butonu
3. [profile_screen.dart](file:///c:/Users/mehme/Desktop/nubar/lib/features/profile/screens/profile_screen.dart):
   - Takipçi/takip sayısına `GestureDetector` ekle → `followers_screen` aç

---

### Faz 6: SEO Katmanı (Next.js)

**Hedef:** Arama motoru optimizasyonu ile organik kullanıcı kazanımı.

##### İlgili Dosyalar

| İşlem | Dosya | Açıklama |
|-------|-------|----------|
| MODIFY | [page.tsx (ana)](file:///c:/Users/mehme/Desktop/nubar/next-seo/app/page.tsx) | Ana sayfa SEO: popular postlar, meta tags |
| MODIFY | [post/[id]/page.tsx](file:///c:/Users/mehme/Desktop/nubar/next-seo/app/post/[id]/page.tsx) | Post detay: Open Graph, Twitter Card |
| MODIFY | [user/[username]/page.tsx](file:///c:/Users/mehme/Desktop/nubar/next-seo/app/user/[username]/page.tsx) | Profil: structured data |
| MODIFY | [community/[slug]/page.tsx](file:///c:/Users/mehme/Desktop/nubar/next-seo/app/community/[slug]/page.tsx) | Topluluk: meta, açıklama |
| MODIFY | [robots.ts](file:///c:/Users/mehme/Desktop/nubar/next-seo/app/robots.ts) | Robots.txt kuralları |
| MODIFY | [sitemap.ts](file:///c:/Users/mehme/Desktop/nubar/next-seo/app/sitemap.ts) | Dinamik sitemap |
| MODIFY | [supabase.ts](file:///c:/Users/mehme/Desktop/nubar/next-seo/lib/supabase.ts) | SSG veri çekme |
| MODIFY | [next.config.js](file:///c:/Users/mehme/Desktop/nubar/next-seo/next.config.js) | CDN headers, rewrite kuralları |

##### Yapılacak İşlemler

1. **Temel SEO Setup:**
   - `next install` → bağımlılıkları kur
   - `@supabase/supabase-js` ile SSG veri çekme
   - `generateStaticParams` ile popüler postlar/topluluklar/profiller
2. **Post Detay Sayfası (`/post/[id]`):**
   - `generateMetadata`: başlık, açıklama, yazar, Open Graph image
   - Twitter Card meta tags
   - JSON-LD structured data (Article schema)
3. **Profil Sayfası (`/user/[username]`):**
   - `generateMetadata`: kullanıcı adı, bio, avatar
   - JSON-LD: Person schema
4. **Topluluk Sayfası (`/community/[slug]`):**
   - `generateMetadata`: topluluk adı, açıklama, üye sayısı
   - JSON-LD: Organization schema
5. **Sitemap & Robots:**
   - Dinamik sitemap: tüm public postlar, profiller, topluluklar
   - [robots.ts](file:///c:/Users/mehme/Desktop/nubar/next-seo/app/robots.ts): crawl kuralları, sitemap referansı
6. **Deploy:**
   - Vercel'e deploy (veya Cloudflare Pages)
   - `cdn.nubar.app` altına subdomain

---

### Faz 7: Test & Kalite Güvencesi

**Hedef:** Kod güvenilirliğini garanti altına almak.

##### İlgili Dosyalar

| İşlem | Dosya | Açıklama |
|-------|-------|----------|
| NEW | [test/unit/validators_test.dart](file:///c:/Users/mehme/Desktop/nubar/test/unit/validators_test.dart) | Validasyon testleri |
| NEW | [test/unit/date_utils_test.dart](file:///c:/Users/mehme/Desktop/nubar/test/unit/date_utils_test.dart) | Tarih format testleri |
| NEW | [test/unit/auth_provider_test.dart](file:///c:/Users/mehme/Desktop/nubar/test/unit/auth_provider_test.dart) | Auth logic testleri |
| NEW | [test/widget/post_card_test.dart](file:///c:/Users/mehme/Desktop/nubar/test/widget/post_card_test.dart) | PostCard widget testi |
| NEW | [test/widget/poll_widget_test.dart](file:///c:/Users/mehme/Desktop/nubar/test/widget/poll_widget_test.dart) | PollWidget testi |
| NEW | [test/integration/auth_flow_test.dart](file:///c:/Users/mehme/Desktop/nubar/test/integration/auth_flow_test.dart) | Auth akış entegrasyon testi |

##### Yapılacak İşlemler

1. **Unit Testler:**
   - `validators_test.dart`: Email, şifre, username validasyonları
   - `date_utils_test.dart`: timeAgo, formatDateTime çıktıları
   - Model `fromJson` / `toJson` round-trip testleri
2. **Widget Testler:**
   - `post_card_test.dart`: Render, eylem butonları, medya grid
   - `poll_widget_test.dart`: Oy ver, sonuçlar, süre dolmuş durumları
3. **Entegrasyon Testler:**
   - Auth flow: kayıt → giriş → çıkış → şifre sıfırlama
   - `mockito` + `mocktail` ile Supabase mock'lama
4. **Test Komutu:**
   ```bash
   flutter test                          # Tüm testler
   flutter test test/unit/               # Sadece unit
   flutter test --coverage               # Kapsam raporu
   ```

---

### Faz 8: Push Notification & Production Hazırlığı

**Hedef:** Uygulamayı App Store & Play Store'a yayınlama.

##### İlgili Dosyalar

| İşlem | Dosya | Açıklama |
|-------|-------|----------|
| NEW | [notification_service.dart](file:///c:/Users/mehme/Desktop/nubar/lib/shared/services/notification_service.dart) | FCM push notification |
| MODIFY | [send-notification/index.ts](file:///c:/Users/mehme/Desktop/nubar/supabase/functions/send-notification/index.ts) | FCM entegrasyonu |
| MODIFY | [pubspec.yaml](file:///c:/Users/mehme/Desktop/nubar/pubspec.yaml) | firebase_messaging ekle |
| MODIFY | [main.dart](file:///c:/Users/mehme/Desktop/nubar/lib/main.dart) | FCM init |

##### Yapılacak İşlemler

1. **FCM Setup:**
   - Firebase projesi oluştur
   - `firebase_messaging` + `firebase_core` ekle
   - Android: `google-services.json`, iOS: `GoogleService-Info.plist`
2. **notification_service.dart:**
   - FCM token al ve Supabase `users` tablosuna kaydet (`fcm_token` sütunu)
   - Foreground/background handler
   - Bildirime tıklayınca ilgili sayfaya yönlendirme
3. **send-notification/index.ts (Edge Function güncellemesi):**
   - Bildirim oluşturulduğunda alıcının FCM token'ını çek
   - Firebase Admin SDK ile push gönder
4. **Production Hazırlık:**
   - App ikonu ve splash screen
   - `flutter build appbundle` (Android) / `flutter build ios` (iOS)
   - Supabase production ortamı (ayrı proje)
   - `.env.production` dosyası
   - App Store Connect / Google Play Console metadata
   - Gizlilik politikası ve kullanım koşulları sayfaları

---

## 📊 Faz Öncelik Matrisi

| Faz | Süre (tahmini) | Öncelik | Bağımlılık |
|-----|:-:|:-:|:-:|
| **Faz 4** — Sosyal & Realtime | 2-3 hafta | 🔴 Yüksek | - |
| **Faz 5** — Ayarlar & UX | 1-2 hafta | 🟠 Orta | Faz 4 |
| **Faz 6** — SEO Katmanı | 1 hafta | 🟡 Düşük | Faz 4 |
| **Faz 7** — Test & Kalite | 1-2 hafta | 🟠 Orta | Faz 4-5 |
| **Faz 8** — Push & Production | 1-2 hafta | 🔴 Yüksek | Faz 4-7 |

---

## ⚠️ Dikkat Edilmesi Gerekenler

> [!WARNING]
> - **RTL Uyumluluk**: Her yeni widget LTR ve RTL'de test edilmeli (Soranî, Arapça)
> - **RLS Politikaları**: Yeni tablo/fonksiyon eklerken Supabase RLS mutlaka aktif olmalı
> - **State Invalidation**: Her action sonrası ilgili provider'lar invalidate edilmeli
> - **Code Split**: Feature bazlı modüler yapı korunmalı, cross-feature import minimum olmalı

> [!TIP]
> - [messages_provider.dart](file:///c:/Users/mehme/Desktop/nubar/lib/features/messages/providers/messages_provider.dart) zaten mükemmel bir Realtime pattern örneği — diğer realtime özellikleri bu şablondan kopyalayın
> - Badge sistemi DB'de hazır (10 badge seed'lenmiş), sadece tetikleme ve UI kalmış
> - `intl` dependency override mevcut (`0.20.2`), paket uyumsuzluklarına dikkat
