import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_ckb.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ku.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('ckb'),
    Locale('en'),
    Locale('ku'),
    Locale('tr'),
  ];

  /// No description provided for @appName.
  ///
  /// In ku, this message translates to:
  /// **'Nûbar'**
  String get appName;

  /// No description provided for @login.
  ///
  /// In ku, this message translates to:
  /// **'Têkevin'**
  String get login;

  /// No description provided for @register.
  ///
  /// In ku, this message translates to:
  /// **'Tomar bikin'**
  String get register;

  /// No description provided for @email.
  ///
  /// In ku, this message translates to:
  /// **'E-peyam'**
  String get email;

  /// No description provided for @password.
  ///
  /// In ku, this message translates to:
  /// **'Şîfre'**
  String get password;

  /// No description provided for @username.
  ///
  /// In ku, this message translates to:
  /// **'Navê bikarhêner'**
  String get username;

  /// No description provided for @fullName.
  ///
  /// In ku, this message translates to:
  /// **'Navê tevahî'**
  String get fullName;

  /// No description provided for @firstName.
  ///
  /// In ku, this message translates to:
  /// **'Nav'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In ku, this message translates to:
  /// **'Paşnav'**
  String get lastName;

  /// No description provided for @phoneOptional.
  ///
  /// In ku, this message translates to:
  /// **'Hejmara Telefonê (Vebijarkî)'**
  String get phoneOptional;

  /// No description provided for @authUserAlreadyExists.
  ///
  /// In ku, this message translates to:
  /// **'Ev e-peyam jixwe tomar bûye. Ji kerema xwe têkeve.'**
  String get authUserAlreadyExists;

  /// No description provided for @authGenericError.
  ///
  /// In ku, this message translates to:
  /// **'Çewtiyek çêbû. Ji kerema xwe dîsa biceribîne.'**
  String get authGenericError;

  /// No description provided for @forgotPassword.
  ///
  /// In ku, this message translates to:
  /// **'Şîfre ji bîr kir?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In ku, this message translates to:
  /// **'Hesabê te tune ye?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In ku, this message translates to:
  /// **'Hesabê te heye?'**
  String get alreadyHaveAccount;

  /// No description provided for @createAccount.
  ///
  /// In ku, this message translates to:
  /// **'Hesab biafirîne'**
  String get createAccount;

  /// No description provided for @logout.
  ///
  /// In ku, this message translates to:
  /// **'Derkeve'**
  String get logout;

  /// No description provided for @feed.
  ///
  /// In ku, this message translates to:
  /// **'Hewal'**
  String get feed;

  /// No description provided for @search.
  ///
  /// In ku, this message translates to:
  /// **'Lêgerîn'**
  String get search;

  /// No description provided for @create.
  ///
  /// In ku, this message translates to:
  /// **'Biafirîne'**
  String get create;

  /// No description provided for @notifications.
  ///
  /// In ku, this message translates to:
  /// **'Agahdarî'**
  String get notifications;

  /// No description provided for @profile.
  ///
  /// In ku, this message translates to:
  /// **'Profîl'**
  String get profile;

  /// No description provided for @messages.
  ///
  /// In ku, this message translates to:
  /// **'Peyam'**
  String get messages;

  /// No description provided for @settings.
  ///
  /// In ku, this message translates to:
  /// **'Mîheng'**
  String get settings;

  /// No description provided for @editProfile.
  ///
  /// In ku, this message translates to:
  /// **'Profîlê biguherîne'**
  String get editProfile;

  /// No description provided for @editPost.
  ///
  /// In ku, this message translates to:
  /// **'Şandî biguherîne'**
  String get editPost;

  /// No description provided for @postShowFullContent.
  ///
  /// In ku, this message translates to:
  /// **'Hemî nivîsarê veke'**
  String get postShowFullContent;

  /// No description provided for @postShowLessContent.
  ///
  /// In ku, this message translates to:
  /// **'Kurt bike'**
  String get postShowLessContent;

  /// No description provided for @followers.
  ///
  /// In ku, this message translates to:
  /// **'Şopîner'**
  String get followers;

  /// No description provided for @following.
  ///
  /// In ku, this message translates to:
  /// **'Dişopîne'**
  String get following;

  /// No description provided for @posts.
  ///
  /// In ku, this message translates to:
  /// **'Şandin'**
  String get posts;

  /// No description provided for @communities.
  ///
  /// In ku, this message translates to:
  /// **'Civat'**
  String get communities;

  /// No description provided for @createPost.
  ///
  /// In ku, this message translates to:
  /// **'Şandinek biafirîne'**
  String get createPost;

  /// No description provided for @createCommunity.
  ///
  /// In ku, this message translates to:
  /// **'Civatek biafirîne'**
  String get createCommunity;

  /// No description provided for @writePost.
  ///
  /// In ku, this message translates to:
  /// **'Çi di hizra te de ye?'**
  String get writePost;

  /// No description provided for @comment.
  ///
  /// In ku, this message translates to:
  /// **'Şîrove'**
  String get comment;

  /// No description provided for @comments.
  ///
  /// In ku, this message translates to:
  /// **'Şîrove'**
  String get comments;

  /// No description provided for @like.
  ///
  /// In ku, this message translates to:
  /// **'Hez kirin'**
  String get like;

  /// No description provided for @share.
  ///
  /// In ku, this message translates to:
  /// **'Parve kirin'**
  String get share;

  /// No description provided for @repost.
  ///
  /// In ku, this message translates to:
  /// **'Ji nû ve parve kirin'**
  String get repost;

  /// No description provided for @bookmark.
  ///
  /// In ku, this message translates to:
  /// **'Tomar kirin'**
  String get bookmark;

  /// No description provided for @follow.
  ///
  /// In ku, this message translates to:
  /// **'Bişopîne'**
  String get follow;

  /// No description provided for @unfollow.
  ///
  /// In ku, this message translates to:
  /// **'Dev jê berde'**
  String get unfollow;

  /// No description provided for @report.
  ///
  /// In ku, this message translates to:
  /// **'Rapor bike'**
  String get report;

  /// No description provided for @delete.
  ///
  /// In ku, this message translates to:
  /// **'Jê bibe'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In ku, this message translates to:
  /// **'Betal bike'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In ku, this message translates to:
  /// **'Tomar bike'**
  String get save;

  /// No description provided for @send.
  ///
  /// In ku, this message translates to:
  /// **'Bişîne'**
  String get send;

  /// No description provided for @done.
  ///
  /// In ku, this message translates to:
  /// **'Temam'**
  String get done;

  /// No description provided for @loading.
  ///
  /// In ku, this message translates to:
  /// **'Tê barkirin...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In ku, this message translates to:
  /// **'Çewtî'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In ku, this message translates to:
  /// **'Dîsa biceribîne'**
  String get retry;

  /// No description provided for @noResults.
  ///
  /// In ku, this message translates to:
  /// **'Encam nehat dîtin'**
  String get noResults;

  /// No description provided for @noPosts.
  ///
  /// In ku, this message translates to:
  /// **'Hîn şandin tune ne'**
  String get noPosts;

  /// No description provided for @noNotifications.
  ///
  /// In ku, this message translates to:
  /// **'Hîn agahdarî tune ne'**
  String get noNotifications;

  /// No description provided for @noMessages.
  ///
  /// In ku, this message translates to:
  /// **'Hîn peyam tune ne'**
  String get noMessages;

  /// No description provided for @selectLanguage.
  ///
  /// In ku, this message translates to:
  /// **'Zimanekî hilbijêre'**
  String get selectLanguage;

  /// No description provided for @selectTheme.
  ///
  /// In ku, this message translates to:
  /// **'Temayekê hilbijêre'**
  String get selectTheme;

  /// No description provided for @bio.
  ///
  /// In ku, this message translates to:
  /// **'Biyografî'**
  String get bio;

  /// No description provided for @website.
  ///
  /// In ku, this message translates to:
  /// **'Malper'**
  String get website;

  /// No description provided for @location.
  ///
  /// In ku, this message translates to:
  /// **'Cih'**
  String get location;

  /// No description provided for @joinedDate.
  ///
  /// In ku, this message translates to:
  /// **'Beşdar bû di {date}'**
  String joinedDate(String date);

  /// No description provided for @followerCount.
  ///
  /// In ku, this message translates to:
  /// **'{count} şopîner'**
  String followerCount(int count);

  /// No description provided for @followingCount.
  ///
  /// In ku, this message translates to:
  /// **'{count} dişopîne'**
  String followingCount(int count);

  /// No description provided for @postCount.
  ///
  /// In ku, this message translates to:
  /// **'{count} şandin'**
  String postCount(int count);

  /// No description provided for @welcomeTitle.
  ///
  /// In ku, this message translates to:
  /// **'Bi xêr hatî Nûbar'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In ku, this message translates to:
  /// **'Platforma dîjîtal a çanda Kurdî'**
  String get welcomeSubtitle;

  /// No description provided for @onboardingTitle1.
  ///
  /// In ku, this message translates to:
  /// **'Parve bike'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In ku, this message translates to:
  /// **'Nivîs, wêne, vîdyo û PDF parve bike'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In ku, this message translates to:
  /// **'Civat'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In ku, this message translates to:
  /// **'Civatan biafirîne û beşdar bibe'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In ku, this message translates to:
  /// **'Bikarhêner'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In ku, this message translates to:
  /// **'Bi Kurdên din re têkilî deyne'**
  String get onboardingDesc3;

  /// No description provided for @getStarted.
  ///
  /// In ku, this message translates to:
  /// **'Dest pê bike'**
  String get getStarted;

  /// No description provided for @theme.
  ///
  /// In ku, this message translates to:
  /// **'Tema'**
  String get theme;

  /// No description provided for @language.
  ///
  /// In ku, this message translates to:
  /// **'Ziman'**
  String get language;

  /// No description provided for @darkMode.
  ///
  /// In ku, this message translates to:
  /// **'Moda tarî'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In ku, this message translates to:
  /// **'Moda ronahî'**
  String get lightMode;

  /// No description provided for @themeNubar.
  ///
  /// In ku, this message translates to:
  /// **'Nûbar'**
  String get themeNubar;

  /// No description provided for @themeDark.
  ///
  /// In ku, this message translates to:
  /// **'Tarî'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In ku, this message translates to:
  /// **'Ronahî'**
  String get themeLight;

  /// No description provided for @themeEarth.
  ///
  /// In ku, this message translates to:
  /// **'Erd'**
  String get themeEarth;

  /// No description provided for @themeOcean.
  ///
  /// In ku, this message translates to:
  /// **'Okyan'**
  String get themeOcean;

  /// No description provided for @themeAmoled.
  ///
  /// In ku, this message translates to:
  /// **'AMOLED'**
  String get themeAmoled;

  /// No description provided for @addImage.
  ///
  /// In ku, this message translates to:
  /// **'Wêne lê zêde bike'**
  String get addImage;

  /// No description provided for @addVideo.
  ///
  /// In ku, this message translates to:
  /// **'Vîdyo lê zêde bike'**
  String get addVideo;

  /// No description provided for @addPdf.
  ///
  /// In ku, this message translates to:
  /// **'PDF lê zêde bike'**
  String get addPdf;

  /// No description provided for @post.
  ///
  /// In ku, this message translates to:
  /// **'Bişîne'**
  String get post;

  /// No description provided for @writeComment.
  ///
  /// In ku, this message translates to:
  /// **'Şîroveyek binivîse...'**
  String get writeComment;

  /// No description provided for @memberCount.
  ///
  /// In ku, this message translates to:
  /// **'{count} endam'**
  String memberCount(int count);

  /// No description provided for @joinCommunity.
  ///
  /// In ku, this message translates to:
  /// **'Beşdar bibe'**
  String get joinCommunity;

  /// No description provided for @leaveCommunity.
  ///
  /// In ku, this message translates to:
  /// **'Dev jê berde'**
  String get leaveCommunity;

  /// No description provided for @communitySettings.
  ///
  /// In ku, this message translates to:
  /// **'Mîhenga civatê'**
  String get communitySettings;

  /// No description provided for @trending.
  ///
  /// In ku, this message translates to:
  /// **'Rojev'**
  String get trending;

  /// No description provided for @forYou.
  ///
  /// In ku, this message translates to:
  /// **'Ji bo te'**
  String get forYou;

  /// No description provided for @block.
  ///
  /// In ku, this message translates to:
  /// **'Asteng bike'**
  String get block;

  /// No description provided for @unblock.
  ///
  /// In ku, this message translates to:
  /// **'Astengê rake'**
  String get unblock;

  /// No description provided for @blocked.
  ///
  /// In ku, this message translates to:
  /// **'Astengkirî'**
  String get blocked;

  /// No description provided for @blockUser.
  ///
  /// In ku, this message translates to:
  /// **'Bikarhêner asteng bike'**
  String get blockUser;

  /// No description provided for @unblockUser.
  ///
  /// In ku, this message translates to:
  /// **'Astengê ji bikarhêner rake'**
  String get unblockUser;

  /// No description provided for @userBlocked.
  ///
  /// In ku, this message translates to:
  /// **'Bikarhêner hat astengkirin'**
  String get userBlocked;

  /// No description provided for @userUnblocked.
  ///
  /// In ku, this message translates to:
  /// **'Asteng ji bikarhêner hat rakirin'**
  String get userUnblocked;

  /// No description provided for @reportReason.
  ///
  /// In ku, this message translates to:
  /// **'Sedema raporê'**
  String get reportReason;

  /// No description provided for @spam.
  ///
  /// In ku, this message translates to:
  /// **'Spam'**
  String get spam;

  /// No description provided for @harassment.
  ///
  /// In ku, this message translates to:
  /// **'Tacîzkirin'**
  String get harassment;

  /// No description provided for @hateSpeech.
  ///
  /// In ku, this message translates to:
  /// **'Axaftina nefretê'**
  String get hateSpeech;

  /// No description provided for @misinformation.
  ///
  /// In ku, this message translates to:
  /// **'Agahiya çewt'**
  String get misinformation;

  /// No description provided for @other.
  ///
  /// In ku, this message translates to:
  /// **'Yên din'**
  String get other;

  /// No description provided for @reportSubmitted.
  ///
  /// In ku, this message translates to:
  /// **'Rapor hat şandin'**
  String get reportSubmitted;

  /// No description provided for @reportDetails.
  ///
  /// In ku, this message translates to:
  /// **'Hûrgilî (vebijarkî)'**
  String get reportDetails;

  /// No description provided for @badges.
  ///
  /// In ku, this message translates to:
  /// **'Nîşan'**
  String get badges;

  /// No description provided for @level.
  ///
  /// In ku, this message translates to:
  /// **'Ast'**
  String get level;

  /// No description provided for @noBadges.
  ///
  /// In ku, this message translates to:
  /// **'Hîn nîşan tune ne'**
  String get noBadges;

  /// No description provided for @online.
  ///
  /// In ku, this message translates to:
  /// **'Serhêl'**
  String get online;

  /// No description provided for @typing.
  ///
  /// In ku, this message translates to:
  /// **'Dinivîse...'**
  String get typing;

  /// No description provided for @delivered.
  ///
  /// In ku, this message translates to:
  /// **'Gihand'**
  String get delivered;

  /// No description provided for @newMessage.
  ///
  /// In ku, this message translates to:
  /// **'Peyamek nû'**
  String get newMessage;

  /// No description provided for @verified.
  ///
  /// In ku, this message translates to:
  /// **'Pejirandî'**
  String get verified;

  /// No description provided for @blockedUsers.
  ///
  /// In ku, this message translates to:
  /// **'Bikarhênerên astengkirî'**
  String get blockedUsers;

  /// No description provided for @noBlockedUsers.
  ///
  /// In ku, this message translates to:
  /// **'Bikarhênerên astengkirî tune ne'**
  String get noBlockedUsers;

  /// No description provided for @unblockConfirm.
  ///
  /// In ku, this message translates to:
  /// **'astengê wê bê rakirin?'**
  String get unblockConfirm;

  /// No description provided for @maxLevel.
  ///
  /// In ku, this message translates to:
  /// **'Asta herî bilind'**
  String get maxLevel;

  /// No description provided for @privacy.
  ///
  /// In ku, this message translates to:
  /// **'Taybetmendî'**
  String get privacy;

  /// No description provided for @account.
  ///
  /// In ku, this message translates to:
  /// **'Hesab'**
  String get account;

  /// No description provided for @about.
  ///
  /// In ku, this message translates to:
  /// **'Derbarê'**
  String get about;

  /// No description provided for @changePassword.
  ///
  /// In ku, this message translates to:
  /// **'Şîfreyê biguherîne'**
  String get changePassword;

  /// No description provided for @resetPasswordDesc.
  ///
  /// In ku, this message translates to:
  /// **'E-peyamê binivîse û em ê lînka guheztina şîfreyê bişînin.'**
  String get resetPasswordDesc;

  /// No description provided for @resetPasswordSent.
  ///
  /// In ku, this message translates to:
  /// **'E-peyama guheztina şîfreyê hat şandin'**
  String get resetPasswordSent;

  /// No description provided for @logoutConfirm.
  ///
  /// In ku, this message translates to:
  /// **'Tu dixwazî derkevî?'**
  String get logoutConfirm;

  /// No description provided for @noFollowers.
  ///
  /// In ku, this message translates to:
  /// **'Hîn şopîner tune ne'**
  String get noFollowers;

  /// No description provided for @noFollowing.
  ///
  /// In ku, this message translates to:
  /// **'Hîn kesî naşopîne'**
  String get noFollowing;

  /// No description provided for @discard.
  ///
  /// In ku, this message translates to:
  /// **'Dev jê berde'**
  String get discard;

  /// No description provided for @discardConfirm.
  ///
  /// In ku, this message translates to:
  /// **'Tu dixwazî dev jê berdî? Nivîsa te wê winda bibe.'**
  String get discardConfirm;

  /// No description provided for @camera.
  ///
  /// In ku, this message translates to:
  /// **'Kamera'**
  String get camera;

  /// No description provided for @poll.
  ///
  /// In ku, this message translates to:
  /// **'Rapirsî'**
  String get poll;

  /// No description provided for @pollDuration.
  ///
  /// In ku, this message translates to:
  /// **'Dem'**
  String get pollDuration;

  /// No description provided for @addOption.
  ///
  /// In ku, this message translates to:
  /// **'Vebijêrk Zêde Bike'**
  String get addOption;

  /// No description provided for @option.
  ///
  /// In ku, this message translates to:
  /// **'Vebijêrk'**
  String get option;

  /// No description provided for @fontSize.
  ///
  /// In ku, this message translates to:
  /// **'Mezinahiya Nivîsê'**
  String get fontSize;

  /// No description provided for @fontFamily.
  ///
  /// In ku, this message translates to:
  /// **'Cureyê Nivîsê'**
  String get fontFamily;

  /// No description provided for @contentStudio.
  ///
  /// In ku, this message translates to:
  /// **'Studyoya Naverokê'**
  String get contentStudio;

  /// No description provided for @quickPost.
  ///
  /// In ku, this message translates to:
  /// **'Posta Bilez'**
  String get quickPost;

  /// No description provided for @article.
  ///
  /// In ku, this message translates to:
  /// **'Gotar / Blog'**
  String get article;

  /// No description provided for @quiz.
  ///
  /// In ku, this message translates to:
  /// **'Testa Zanînê'**
  String get quiz;

  /// No description provided for @bookHub.
  ///
  /// In ku, this message translates to:
  /// **'Pirtûk (PDF)'**
  String get bookHub;

  /// No description provided for @thread.
  ///
  /// In ku, this message translates to:
  /// **'Postên Rêzkirî'**
  String get thread;

  /// No description provided for @voiceNote.
  ///
  /// In ku, this message translates to:
  /// **'Qeyda Dengî'**
  String get voiceNote;

  /// No description provided for @articleTitleHint.
  ///
  /// In ku, this message translates to:
  /// **'Sernavê Gotarê...'**
  String get articleTitleHint;

  /// No description provided for @articleSubtitleHint.
  ///
  /// In ku, this message translates to:
  /// **'Binnivîs (vebijarkî)...'**
  String get articleSubtitleHint;

  /// No description provided for @articleBodyHint.
  ///
  /// In ku, this message translates to:
  /// **'Nivîsa gotarê binivîse...'**
  String get articleBodyHint;

  /// No description provided for @addCoverImage.
  ///
  /// In ku, this message translates to:
  /// **'Wêneyê Bergê Zêde Bike'**
  String get addCoverImage;

  /// No description provided for @quizQuestionHint.
  ///
  /// In ku, this message translates to:
  /// **'Pirsê li vir binivîsin...'**
  String get quizQuestionHint;

  /// No description provided for @quizOptionsAndAnswer.
  ///
  /// In ku, this message translates to:
  /// **'Vebijêrk û Bersiva Rast'**
  String get quizOptionsAndAnswer;

  /// No description provided for @quizOptionHint.
  ///
  /// In ku, this message translates to:
  /// **'Vebijêrk'**
  String get quizOptionHint;

  /// No description provided for @quizExplanationOptional.
  ///
  /// In ku, this message translates to:
  /// **'Ravekirin (Vebijarkî)'**
  String get quizExplanationOptional;

  /// No description provided for @quizExplanationDesc.
  ///
  /// In ku, this message translates to:
  /// **'Bikarhêner piştî bersivdanê dê vê ravekirinê bibînin.'**
  String get quizExplanationDesc;

  /// No description provided for @quizExplanationHint.
  ///
  /// In ku, this message translates to:
  /// **'Rave bikin çima ev bersiv rast e...'**
  String get quizExplanationHint;

  /// No description provided for @pdfCover.
  ///
  /// In ku, this message translates to:
  /// **'Berg'**
  String get pdfCover;

  /// No description provided for @pdfTitle.
  ///
  /// In ku, this message translates to:
  /// **'Sernavê Pirtûkê'**
  String get pdfTitle;

  /// No description provided for @pdfAuthor.
  ///
  /// In ku, this message translates to:
  /// **'Nivîskar'**
  String get pdfAuthor;

  /// No description provided for @pdfPagesOptional.
  ///
  /// In ku, this message translates to:
  /// **'Hejmara Rûpelan (Vebijarkî)'**
  String get pdfPagesOptional;

  /// No description provided for @pdfDocAdded.
  ///
  /// In ku, this message translates to:
  /// **'Belgeya PDF Hat Zêdekirin'**
  String get pdfDocAdded;

  /// No description provided for @pdfSelectDoc.
  ///
  /// In ku, this message translates to:
  /// **'Belgeyek PDF Hilbijêrin'**
  String get pdfSelectDoc;

  /// No description provided for @pdfSummaryInfo.
  ///
  /// In ku, this message translates to:
  /// **'Kurtî û Danasîn'**
  String get pdfSummaryInfo;

  /// No description provided for @pdfSummaryHint.
  ///
  /// In ku, this message translates to:
  /// **'Mijara pirtûkê, xalên girîng...'**
  String get pdfSummaryHint;

  /// No description provided for @threadAdd.
  ///
  /// In ku, this message translates to:
  /// **'Li Rêzê Zêde Bike'**
  String get threadAdd;

  /// No description provided for @threadFirstHint.
  ///
  /// In ku, this message translates to:
  /// **'Çi diqewime?'**
  String get threadFirstHint;

  /// No description provided for @threadNextHint.
  ///
  /// In ku, this message translates to:
  /// **'Zêde bike...'**
  String get threadNextHint;

  /// No description provided for @voiceAdded.
  ///
  /// In ku, this message translates to:
  /// **'Deng Hat Zêdekirin'**
  String get voiceAdded;

  /// No description provided for @voiceRecording.
  ///
  /// In ku, this message translates to:
  /// **'Tê tomarkirin...'**
  String get voiceRecording;

  /// No description provided for @voicePrompt.
  ///
  /// In ku, this message translates to:
  /// **'Çîrokek bi deng vebêje...'**
  String get voicePrompt;

  /// No description provided for @voiceUploadFromDevice.
  ///
  /// In ku, this message translates to:
  /// **'An Ji Amûrê Deng Bar Bike'**
  String get voiceUploadFromDevice;

  /// No description provided for @voiceTitleHint.
  ///
  /// In ku, this message translates to:
  /// **'Sernavê Deng/Podcast'**
  String get voiceTitleHint;

  /// No description provided for @voiceDescHint.
  ///
  /// In ku, this message translates to:
  /// **'Kurtî an ravekirin binivîse...'**
  String get voiceDescHint;

  /// No description provided for @voiceBgImage.
  ///
  /// In ku, this message translates to:
  /// **'Wêneyê Paşxaneyê'**
  String get voiceBgImage;

  /// No description provided for @replies.
  ///
  /// In ku, this message translates to:
  /// **'Bersiv'**
  String get replies;

  /// No description provided for @media.
  ///
  /// In ku, this message translates to:
  /// **'Medya'**
  String get media;

  /// No description provided for @photos.
  ///
  /// In ku, this message translates to:
  /// **'Wêne'**
  String get photos;

  /// No description provided for @likes.
  ///
  /// In ku, this message translates to:
  /// **'Hezkirin'**
  String get likes;

  /// No description provided for @liked.
  ///
  /// In ku, this message translates to:
  /// **'Hezkirî'**
  String get liked;

  /// No description provided for @saved.
  ///
  /// In ku, this message translates to:
  /// **'Tomarkirî'**
  String get saved;

  /// No description provided for @noReplies.
  ///
  /// In ku, this message translates to:
  /// **'Hêj bersiv tune ne'**
  String get noReplies;

  /// No description provided for @noMedia.
  ///
  /// In ku, this message translates to:
  /// **'Hêj medya tune ne'**
  String get noMedia;

  /// No description provided for @noPhotos.
  ///
  /// In ku, this message translates to:
  /// **'Hêj wêne tune ne'**
  String get noPhotos;

  /// No description provided for @noLikedPosts.
  ///
  /// In ku, this message translates to:
  /// **'Hêj postên hezkirî tune ne'**
  String get noLikedPosts;

  /// No description provided for @noSavedPosts.
  ///
  /// In ku, this message translates to:
  /// **'Hêj postên tomarkirî tune ne'**
  String get noSavedPosts;

  /// No description provided for @reply.
  ///
  /// In ku, this message translates to:
  /// **'Bersiv'**
  String get reply;

  /// No description provided for @replyingToUser.
  ///
  /// In ku, this message translates to:
  /// **'Bersiva {username}'**
  String replyingToUser(String username);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'ckb', 'en', 'ku', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'ckb':
      return AppLocalizationsCkb();
    case 'en':
      return AppLocalizationsEn();
    case 'ku':
      return AppLocalizationsKu();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
