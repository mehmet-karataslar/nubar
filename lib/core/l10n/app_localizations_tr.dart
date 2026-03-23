// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'Nûbar';

  @override
  String get login => 'Giriş Yap';

  @override
  String get register => 'Kayıt Ol';

  @override
  String get email => 'E-posta';

  @override
  String get password => 'Şifre';

  @override
  String get username => 'Kullanıcı Adı';

  @override
  String get fullName => 'Tam Ad';

  @override
  String get firstName => 'Ad';

  @override
  String get lastName => 'Soyad';

  @override
  String get phoneOptional => 'Telefon Numarası (Opsiyonel)';

  @override
  String get authUserAlreadyExists =>
      'Bu e-posta zaten kayıtlı. Lütfen giriş yapın.';

  @override
  String get authGenericError => 'Bir hata oluştu. Lütfen tekrar deneyin.';

  @override
  String get forgotPassword => 'Şifreni mi unuttun?';

  @override
  String get dontHaveAccount => 'Hesabın yok mu?';

  @override
  String get alreadyHaveAccount => 'Zaten hesabın var mı?';

  @override
  String get createAccount => 'Hesap Oluştur';

  @override
  String get logout => 'Çıkış Yap';

  @override
  String get feed => 'Akış';

  @override
  String get search => 'Ara';

  @override
  String get create => 'Oluştur';

  @override
  String get notifications => 'Bildirimler';

  @override
  String get profile => 'Profil';

  @override
  String get messages => 'Mesajlar';

  @override
  String get settings => 'Ayarlar';

  @override
  String get editProfile => 'Profili Düzenle';

  @override
  String get editPost => 'Gönderiyi düzenle';

  @override
  String get postShowFullContent => 'Tam metni göster';

  @override
  String get postShowLessContent => 'Daha az göster';

  @override
  String get followers => 'Takipçiler';

  @override
  String get following => 'Takip Edilenler';

  @override
  String get posts => 'Gönderiler';

  @override
  String get communities => 'Topluluklar';

  @override
  String get createPost => 'Gönderi Oluştur';

  @override
  String get createCommunity => 'Topluluk Oluştur';

  @override
  String get writePost => 'Aklından ne geçiyor?';

  @override
  String get comment => 'Yorum';

  @override
  String get comments => 'Yorumlar';

  @override
  String get like => 'Beğen';

  @override
  String get share => 'Paylaş';

  @override
  String get repost => 'Yeniden Paylaş';

  @override
  String get bookmark => 'Kaydet';

  @override
  String get follow => 'Takip Et';

  @override
  String get unfollow => 'Takibi Bırak';

  @override
  String get report => 'Şikayet Et';

  @override
  String get delete => 'Sil';

  @override
  String get cancel => 'İptal';

  @override
  String get save => 'Kaydet';

  @override
  String get send => 'Gönder';

  @override
  String get done => 'Tamam';

  @override
  String get loading => 'Yükleniyor...';

  @override
  String get error => 'Hata';

  @override
  String get retry => 'Tekrar Dene';

  @override
  String get noResults => 'Sonuç bulunamadı';

  @override
  String get noPosts => 'Henüz gönderi yok';

  @override
  String get noNotifications => 'Henüz bildirim yok';

  @override
  String get noMessages => 'Henüz mesaj yok';

  @override
  String get selectLanguage => 'Dil Seç';

  @override
  String get selectTheme => 'Tema Seç';

  @override
  String get bio => 'Biyografi';

  @override
  String get website => 'Web Sitesi';

  @override
  String get location => 'Konum';

  @override
  String joinedDate(String date) {
    return '$date tarihinde katıldı';
  }

  @override
  String followerCount(int count) {
    return '$count takipçi';
  }

  @override
  String followingCount(int count) {
    return '$count takip';
  }

  @override
  String postCount(int count) {
    return '$count gönderi';
  }

  @override
  String get welcomeTitle => 'Nûbar\'a Hoş Geldiniz';

  @override
  String get welcomeSubtitle => 'Kürt kültürü dijital platformu';

  @override
  String get onboardingTitle1 => 'Paylaş';

  @override
  String get onboardingDesc1 => 'Yazı, fotoğraf, video ve PDF paylaş';

  @override
  String get onboardingTitle2 => 'Topluluk';

  @override
  String get onboardingDesc2 => 'Topluluklar oluştur ve katıl';

  @override
  String get onboardingTitle3 => 'Bağlan';

  @override
  String get onboardingDesc3 => 'Diğer Kürtlerle bağlantı kur';

  @override
  String get getStarted => 'Başla';

  @override
  String get theme => 'Tema';

  @override
  String get language => 'Dil';

  @override
  String get darkMode => 'Karanlık Mod';

  @override
  String get lightMode => 'Aydınlık Mod';

  @override
  String get themeNubar => 'Nûbar';

  @override
  String get themeDark => 'Karanlık';

  @override
  String get themeLight => 'Aydınlık';

  @override
  String get themeEarth => 'Toprak';

  @override
  String get themeOcean => 'Okyanus';

  @override
  String get themeAmoled => 'AMOLED';

  @override
  String get addImage => 'Fotoğraf Ekle';

  @override
  String get addVideo => 'Video Ekle';

  @override
  String get addPdf => 'PDF Ekle';

  @override
  String get post => 'Gönder';

  @override
  String get writeComment => 'Yorum yaz...';

  @override
  String memberCount(int count) {
    return '$count üye';
  }

  @override
  String get joinCommunity => 'Katıl';

  @override
  String get leaveCommunity => 'Ayrıl';

  @override
  String get communitySettings => 'Topluluk Ayarları';

  @override
  String get trending => 'Gündem';

  @override
  String get forYou => 'Senin İçin';

  @override
  String get block => 'Engelle';

  @override
  String get unblock => 'Engeli Kaldır';

  @override
  String get blocked => 'Engellendi';

  @override
  String get blockUser => 'Kullanıcıyı Engelle';

  @override
  String get unblockUser => 'Engeli Kaldır';

  @override
  String get userBlocked => 'Kullanıcı engellendi';

  @override
  String get userUnblocked => 'Engel kaldırıldı';

  @override
  String get reportReason => 'Şikayet Nedeni';

  @override
  String get spam => 'Spam';

  @override
  String get harassment => 'Taciz';

  @override
  String get hateSpeech => 'Nefret Söylemi';

  @override
  String get misinformation => 'Yanlış Bilgi';

  @override
  String get other => 'Diğer';

  @override
  String get reportSubmitted => 'Şikayet gönderildi';

  @override
  String get reportDetails => 'Detaylar (isteğe bağlı)';

  @override
  String get badges => 'Rozetler';

  @override
  String get level => 'Seviye';

  @override
  String get noBadges => 'Henüz rozet yok';

  @override
  String get online => 'Çevrimiçi';

  @override
  String get typing => 'Yazıyor...';

  @override
  String get delivered => 'İletildi';

  @override
  String get newMessage => 'Yeni mesaj';

  @override
  String get verified => 'Doğrulanmış';

  @override
  String get blockedUsers => 'Engellenen Kullanıcılar';

  @override
  String get noBlockedUsers => 'Engellenen kullanıcı yok';

  @override
  String get unblockConfirm => 'kullanıcısının engeli kaldırılacak?';

  @override
  String get maxLevel => 'En Yüksek Seviye';

  @override
  String get privacy => 'Gizlilik';

  @override
  String get account => 'Hesap';

  @override
  String get about => 'Hakkında';

  @override
  String get changePassword => 'Şifre Değiştir';

  @override
  String get resetPasswordDesc =>
      'E-posta adresinizi girin, size şifre sıfırlama bağlantısı gönderelim.';

  @override
  String get resetPasswordSent => 'Şifre sıfırlama e-postası gönderildi';

  @override
  String get logoutConfirm => 'Çıkış yapmak istediğinize emin misiniz?';

  @override
  String get noFollowers => 'Henüz takipçi yok';

  @override
  String get noFollowing => 'Henüz kimseyi takip etmiyor';

  @override
  String get discard => 'Vazgeç';

  @override
  String get discardConfirm =>
      'Vazgeçmek istediğinize emin misiniz? Gönderiniz kaybolacak.';

  @override
  String get camera => 'Kamera';

  @override
  String get poll => 'Anket';

  @override
  String get pollDuration => 'Süre';

  @override
  String get addOption => 'Seçenek Ekle';

  @override
  String get option => 'Seçenek';

  @override
  String get fontSize => 'Yazı Boyutu';

  @override
  String get fontFamily => 'Yazı Tipi';

  @override
  String get contentStudio => 'İçerik Stüdyosu';

  @override
  String get quickPost => 'Hızlı Gönderi';

  @override
  String get article => 'Makale / Blog';

  @override
  String get quiz => 'Bilgi Testi';

  @override
  String get bookHub => 'Kitap (PDF)';

  @override
  String get thread => 'Zincir Gönderi';

  @override
  String get voiceNote => 'Sesli Kayıt';

  @override
  String get articleTitleHint => 'Makale Başlığı...';

  @override
  String get articleSubtitleHint => 'Alt başlık (isteğe bağlı)...';

  @override
  String get articleBodyHint => 'Makale metnini yaz...';

  @override
  String get addCoverImage => 'Kapak Görseli Ekle';

  @override
  String get quizQuestionHint => 'Soruyu buraya yazın...';

  @override
  String get quizOptionsAndAnswer => 'Seçenekler & Doğru Cevap';

  @override
  String get quizOptionHint => 'Seçenek';

  @override
  String get quizExplanationOptional => 'Açıklama (İsteğe Bağlı)';

  @override
  String get quizExplanationDesc =>
      'Kullanıcılar cevap verdikten sonra bu açıklamayı görecek.';

  @override
  String get quizExplanationHint =>
      'Bu cevabın neden doğru olduğunu açıklayın...';

  @override
  String get pdfCover => 'Kapak';

  @override
  String get pdfTitle => 'Kitap Başlığı';

  @override
  String get pdfAuthor => 'Yazar';

  @override
  String get pdfPagesOptional => 'Sayfa Sayısı (Opsiyonel)';

  @override
  String get pdfDocAdded => 'PDF Belgesi Eklendi';

  @override
  String get pdfSelectDoc => 'PDF Dosyasını Seçin';

  @override
  String get pdfSummaryInfo => 'Özet & Tanıtım';

  @override
  String get pdfSummaryHint => 'Kitabın konusu, öne çıkan noktalar...';

  @override
  String get threadAdd => 'Zincire Ekle';

  @override
  String get threadFirstHint => 'Neler oluyor?';

  @override
  String get threadNextHint => 'Buna ekle...';

  @override
  String get voiceAdded => 'Ses Eklendi';

  @override
  String get voiceRecording => 'Kaydediliyor...';

  @override
  String get voicePrompt => 'Sesli bir hikaye anlat...';

  @override
  String get voiceUploadFromDevice => 'Veya Cihazdan Ses Yükle';

  @override
  String get voiceTitleHint => 'Podcast / Ses Başlığı';

  @override
  String get voiceDescHint => 'Açıklama veya özet yazın...';

  @override
  String get voiceBgImage => 'Arka Plan Görseli';

  @override
  String get replies => 'Yanıtlar';

  @override
  String get media => 'Medya';

  @override
  String get photos => 'Fotoğraflar';

  @override
  String get likes => 'Beğeniler';

  @override
  String get liked => 'Beğenilenler';

  @override
  String get saved => 'Kaydedilenler';

  @override
  String get noReplies => 'Henüz yanıt yok';

  @override
  String get noMedia => 'Henüz medya yok';

  @override
  String get noPhotos => 'Henüz fotoğraf yok';

  @override
  String get noLikedPosts => 'Henüz beğenilen gönderi yok';

  @override
  String get noSavedPosts => 'Henüz kaydedilen gönderi yok';

  @override
  String get reply => 'Yanıtla';

  @override
  String replyingToUser(String username) {
    return '$username için yanıt';
  }
}
