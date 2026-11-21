import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L
/// returned by `L.of(context)`.
///
/// Applications need to include `L.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L.localizationsDelegates,
///   supportedLocales: L.supportedLocales,
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
/// be consistent with the languages listed in the L.supportedLocales
/// property.
abstract class L {
  L(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L of(BuildContext context) {
    return Localizations.of<L>(context, L)!;
  }

  static const LocalizationsDelegate<L> delegate = _LDelegate();

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
    Locale('bn'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Homio Essentials'**
  String get appName;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get tabExplore;

  /// No description provided for @tabSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get tabSaved;

  /// No description provided for @tabSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tabSettings;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @savedSnack.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedSnack;

  /// No description provided for @removedSnack.
  ///
  /// In en, this message translates to:
  /// **'Removed from saved'**
  String get removedSnack;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @bangla.
  ///
  /// In en, this message translates to:
  /// **'বাংলা'**
  String get bangla;

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline — showing the archive saved on this phone.'**
  String get offlineBanner;

  /// No description provided for @loadingArchive.
  ///
  /// In en, this message translates to:
  /// **'Downloading the archive… this happens only once.'**
  String get loadingArchive;

  /// No description provided for @loadFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the archive'**
  String get loadFailedTitle;

  /// No description provided for @loadFailedBody.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection. The app downloads the archive once; after that it works offline.'**
  String get loadFailedBody;

  /// No description provided for @notFound.
  ///
  /// In en, this message translates to:
  /// **'This item isn\'t in the archive.'**
  String get notFound;

  /// No description provided for @kingdom_plant.
  ///
  /// In en, this message translates to:
  /// **'Plant'**
  String get kingdom_plant;

  /// No description provided for @kingdom_mineral.
  ///
  /// In en, this message translates to:
  /// **'Mineral'**
  String get kingdom_mineral;

  /// No description provided for @kingdom_animal.
  ///
  /// In en, this message translates to:
  /// **'Animal'**
  String get kingdom_animal;

  /// No description provided for @kingdom_nosode.
  ///
  /// In en, this message translates to:
  /// **'Nosode'**
  String get kingdom_nosode;

  /// No description provided for @kingdom_sarcode.
  ///
  /// In en, this message translates to:
  /// **'Sarcode'**
  String get kingdom_sarcode;

  /// No description provided for @kingdom_imponderabilia.
  ///
  /// In en, this message translates to:
  /// **'Imponderable'**
  String get kingdom_imponderabilia;

  /// No description provided for @kingdom_other.
  ///
  /// In en, this message translates to:
  /// **'Chemical'**
  String get kingdom_other;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'The homeopathic medicine archive'**
  String get welcomeTitle;

  /// No description provided for @welcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Remedies, what they are used for, doses by age and the classic Materia Medica — in English and বাংলা. Works offline once downloaded.'**
  String get welcomeBody;

  /// No description provided for @welcomePoint1.
  ///
  /// In en, this message translates to:
  /// **'700+ remedies from Boericke\'s Materia Medica'**
  String get welcomePoint1;

  /// No description provided for @welcomePoint2.
  ///
  /// In en, this message translates to:
  /// **'Dose guide by age group and potency'**
  String get welcomePoint2;

  /// No description provided for @welcomePoint3.
  ///
  /// In en, this message translates to:
  /// **'Search by voice or typing — English, বাংলা or Banglish'**
  String get welcomePoint3;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get chooseLanguage;

  /// No description provided for @languageNote.
  ///
  /// In en, this message translates to:
  /// **'You can change this any time in Settings.'**
  String get languageNote;

  /// No description provided for @chooseRole.
  ///
  /// In en, this message translates to:
  /// **'How will you use {app}?'**
  String chooseRole(String app);

  /// No description provided for @roleGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get roleGeneral;

  /// No description provided for @roleGeneralDesc.
  ///
  /// In en, this message translates to:
  /// **'Plain language: uses and a dose guide'**
  String get roleGeneralDesc;

  /// No description provided for @roleStudent.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get roleStudent;

  /// No description provided for @roleStudentDesc.
  ///
  /// In en, this message translates to:
  /// **'Adds Materia Medica, keynotes and related remedies'**
  String get roleStudentDesc;

  /// No description provided for @rolePractitioner.
  ///
  /// In en, this message translates to:
  /// **'Practitioner'**
  String get rolePractitioner;

  /// No description provided for @rolePractitionerDesc.
  ///
  /// In en, this message translates to:
  /// **'Everything, with source books and full text'**
  String get rolePractitionerDesc;

  /// No description provided for @beforeYouStart.
  ///
  /// In en, this message translates to:
  /// **'Before you start'**
  String get beforeYouStart;

  /// No description provided for @iUnderstand.
  ///
  /// In en, this message translates to:
  /// **'I understand'**
  String get iUnderstand;

  /// No description provided for @disclaimerFallback.
  ///
  /// In en, this message translates to:
  /// **'Reference information from homeopathic literature — not medical advice. Ask a registered practitioner before use, especially for infants, pregnancy or long-term conditions. In an emergency, get medical help.'**
  String get disclaimerFallback;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcomeBack;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Find a remedy, brand or symptom'**
  String get homeTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search “Arnica”, “fever”, “SBL”…'**
  String get searchHint;

  /// No description provided for @remedyOfDay.
  ///
  /// In en, this message translates to:
  /// **'REMEDY OF THE DAY'**
  String get remedyOfDay;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get readMore;

  /// No description provided for @browseArchive.
  ///
  /// In en, this message translates to:
  /// **'Browse the archive'**
  String get browseArchive;

  /// No description provided for @browseRemedies.
  ///
  /// In en, this message translates to:
  /// **'Remedies'**
  String get browseRemedies;

  /// No description provided for @browseSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get browseSymptoms;

  /// No description provided for @browseCompanies.
  ///
  /// In en, this message translates to:
  /// **'Companies'**
  String get browseCompanies;

  /// No description provided for @browseMateria.
  ///
  /// In en, this message translates to:
  /// **'Materia Medica'**
  String get browseMateria;

  /// No description provided for @browseSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get browseSaved;

  /// No description provided for @browseGuide.
  ///
  /// In en, this message translates to:
  /// **'Potency guide'**
  String get browseGuide;

  /// No description provided for @studyModesNote.
  ///
  /// In en, this message translates to:
  /// **'Materia Medica opens fully in Student and Practitioner modes.'**
  String get studyModesNote;

  /// No description provided for @findBySymptom.
  ///
  /// In en, this message translates to:
  /// **'Find by symptom'**
  String get findBySymptom;

  /// No description provided for @doseByAge.
  ///
  /// In en, this message translates to:
  /// **'Dose by age group'**
  String get doseByAge;

  /// No description provided for @recentlyViewed.
  ///
  /// In en, this message translates to:
  /// **'Recently viewed'**
  String get recentlyViewed;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @learnBasics.
  ///
  /// In en, this message translates to:
  /// **'Learn the basics'**
  String get learnBasics;

  /// No description provided for @guideBadge.
  ///
  /// In en, this message translates to:
  /// **'Guide · 3 min read'**
  String get guideBadge;

  /// No description provided for @potencyGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Potency, dilution and dose — a beginner\'s guide'**
  String get potencyGuideTitle;

  /// No description provided for @potencyGuideBody.
  ///
  /// In en, this message translates to:
  /// **'What 6C, 30C and 200C mean, and how they are used.'**
  String get potencyGuideBody;

  /// No description provided for @archiveStats.
  ///
  /// In en, this message translates to:
  /// **'{remedies} remedies · {conditions} symptoms'**
  String archiveStats(String remedies, String conditions);

  /// No description provided for @exploreTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get exploreTitle;

  /// No description provided for @exploreSub.
  ///
  /// In en, this message translates to:
  /// **'The A–Z archive of homeopathic remedies'**
  String get exploreSub;

  /// No description provided for @searchArchive.
  ///
  /// In en, this message translates to:
  /// **'Search the archive'**
  String get searchArchive;

  /// No description provided for @segRemedies.
  ///
  /// In en, this message translates to:
  /// **'Remedies'**
  String get segRemedies;

  /// No description provided for @segSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get segSymptoms;

  /// No description provided for @segCompanies.
  ///
  /// In en, this message translates to:
  /// **'Companies'**
  String get segCompanies;

  /// No description provided for @remedyCount.
  ///
  /// In en, this message translates to:
  /// **'{count} remedies'**
  String remedyCount(String count);

  /// No description provided for @noMatches.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches this filter.'**
  String get noMatches;

  /// No description provided for @soldInBd.
  ///
  /// In en, this message translates to:
  /// **'Sold in Bangladesh'**
  String get soldInBd;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @searchFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Remedies, symptoms, companies'**
  String get searchFieldHint;

  /// No description provided for @results.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get results;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get recentSearches;

  /// No description provided for @banglishTipTitle.
  ///
  /// In en, this message translates to:
  /// **'Type in Banglish, too.'**
  String get banglishTipTitle;

  /// No description provided for @banglishTipBody.
  ///
  /// In en, this message translates to:
  /// **'“arnika” or “nuks vomika” finds Arnica and Nux vomica — and আর্নিকা works as well.'**
  String get banglishTipBody;

  /// No description provided for @noResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No match for “{q}”'**
  String noResultsTitle(String q);

  /// No description provided for @noResultsBody.
  ///
  /// In en, this message translates to:
  /// **'Check the spelling, or ask us to add this medicine.'**
  String get noResultsBody;

  /// No description provided for @requestThis.
  ///
  /// In en, this message translates to:
  /// **'Request this medicine'**
  String get requestThis;

  /// No description provided for @kindRemedy.
  ///
  /// In en, this message translates to:
  /// **'Remedy'**
  String get kindRemedy;

  /// No description provided for @kindSymptom.
  ///
  /// In en, this message translates to:
  /// **'Symptom'**
  String get kindSymptom;

  /// No description provided for @kindCompany.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get kindCompany;

  /// No description provided for @tabOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get tabOverview;

  /// No description provided for @tabUses.
  ///
  /// In en, this message translates to:
  /// **'Uses'**
  String get tabUses;

  /// No description provided for @tabDosage.
  ///
  /// In en, this message translates to:
  /// **'Dosage'**
  String get tabDosage;

  /// No description provided for @tabBrands.
  ///
  /// In en, this message translates to:
  /// **'Brands'**
  String get tabBrands;

  /// No description provided for @tabStudy.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get tabStudy;

  /// No description provided for @forms.
  ///
  /// In en, this message translates to:
  /// **'Forms'**
  String get forms;

  /// No description provided for @potency.
  ///
  /// In en, this message translates to:
  /// **'Potency'**
  String get potency;

  /// No description provided for @route.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get route;

  /// No description provided for @routeOral.
  ///
  /// In en, this message translates to:
  /// **'By mouth'**
  String get routeOral;

  /// No description provided for @routeOralSkin.
  ///
  /// In en, this message translates to:
  /// **'Mouth + skin'**
  String get routeOralSkin;

  /// No description provided for @mostlyUsedFor.
  ///
  /// In en, this message translates to:
  /// **'Mostly used for'**
  String get mostlyUsedFor;

  /// No description provided for @typicalAdultDose.
  ///
  /// In en, this message translates to:
  /// **'Typical adult dose'**
  String get typicalAdultDose;

  /// No description provided for @pellets.
  ///
  /// In en, this message translates to:
  /// **'pellets'**
  String get pellets;

  /// No description provided for @tablets.
  ///
  /// In en, this message translates to:
  /// **'tablets'**
  String get tablets;

  /// No description provided for @dosesByAge.
  ///
  /// In en, this message translates to:
  /// **'Doses by age →'**
  String get dosesByAge;

  /// No description provided for @safety.
  ///
  /// In en, this message translates to:
  /// **'Safety'**
  String get safety;

  /// No description provided for @moreNotes.
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String moreNotes(String count);

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @inEnglishNote.
  ///
  /// In en, this message translates to:
  /// **'Shown in English — the Bangla text is being prepared.'**
  String get inEnglishNote;

  /// No description provided for @keynotes.
  ///
  /// In en, this message translates to:
  /// **'Keynotes'**
  String get keynotes;

  /// No description provided for @keynotesSource.
  ///
  /// In en, this message translates to:
  /// **'From H. C. Allen, Keynotes and Characteristics (1898)'**
  String get keynotesSource;

  /// No description provided for @relatedRemedies.
  ///
  /// In en, this message translates to:
  /// **'Related remedies'**
  String get relatedRemedies;

  /// No description provided for @rel_compare.
  ///
  /// In en, this message translates to:
  /// **'Compare'**
  String get rel_compare;

  /// No description provided for @rel_complementary.
  ///
  /// In en, this message translates to:
  /// **'Complementary'**
  String get rel_complementary;

  /// No description provided for @rel_antidote.
  ///
  /// In en, this message translates to:
  /// **'Antidote'**
  String get rel_antidote;

  /// No description provided for @rel_inimical.
  ///
  /// In en, this message translates to:
  /// **'Inimical'**
  String get rel_inimical;

  /// No description provided for @rel_follows_well.
  ///
  /// In en, this message translates to:
  /// **'Follows well'**
  String get rel_follows_well;

  /// No description provided for @sources.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get sources;

  /// No description provided for @sourceBoericke.
  ///
  /// In en, this message translates to:
  /// **'Boericke, Pocket Manual of Homoeopathic Materia Medica'**
  String get sourceBoericke;

  /// No description provided for @sourceChecked.
  ///
  /// In en, this message translates to:
  /// **'Checked against the 1922 printed edition, page {page}'**
  String sourceChecked(String page);

  /// No description provided for @sourceCurated.
  ///
  /// In en, this message translates to:
  /// **'Summary, uses and doses written for {app} and awaiting review by a registered homeopath.'**
  String sourceCurated(String app);

  /// No description provided for @referenceNote.
  ///
  /// In en, this message translates to:
  /// **'Reference information from homeopathic literature — not medical advice.'**
  String get referenceNote;

  /// No description provided for @readFullNote.
  ///
  /// In en, this message translates to:
  /// **'Read the full note'**
  String get readFullNote;

  /// No description provided for @doseGuide.
  ///
  /// In en, this message translates to:
  /// **'Dose guide'**
  String get doseGuide;

  /// No description provided for @usesTitle.
  ///
  /// In en, this message translates to:
  /// **'What it is used for'**
  String get usesTitle;

  /// No description provided for @usesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No reviewed uses yet'**
  String get usesEmptyTitle;

  /// No description provided for @usesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Uses by symptom haven\'t been reviewed for this remedy yet. Its full description from Boericke\'s Materia Medica is in the Study tab.'**
  String get usesEmptyBody;

  /// No description provided for @openStudy.
  ///
  /// In en, this message translates to:
  /// **'Open Study'**
  String get openStudy;

  /// No description provided for @externalUse.
  ///
  /// In en, this message translates to:
  /// **'Also used on the skin'**
  String get externalUse;

  /// No description provided for @doseGuideSub.
  ///
  /// In en, this message translates to:
  /// **'Pick a potency and an age group. Guidance is general — your practitioner\'s advice comes first.'**
  String get doseGuideSub;

  /// No description provided for @stepPotency.
  ///
  /// In en, this message translates to:
  /// **'1 · Potency'**
  String get stepPotency;

  /// No description provided for @stepWho.
  ///
  /// In en, this message translates to:
  /// **'2 · Who is it for?'**
  String get stepWho;

  /// No description provided for @dosePerTime.
  ///
  /// In en, this message translates to:
  /// **'DOSE PER TIME'**
  String get dosePerTime;

  /// No description provided for @dissolveUnderTongue.
  ///
  /// In en, this message translates to:
  /// **'Dissolve under the tongue'**
  String get dissolveUnderTongue;

  /// No description provided for @chewOrDissolve.
  ///
  /// In en, this message translates to:
  /// **'Chew, or dissolve on the tongue'**
  String get chewOrDissolve;

  /// No description provided for @highPotencyWarn.
  ///
  /// In en, this message translates to:
  /// **'High potency. Use only as advised by a registered practitioner.'**
  String get highPotencyWarn;

  /// No description provided for @notCuratedDose.
  ///
  /// In en, this message translates to:
  /// **'This remedy\'s dose hasn\'t been reviewed yet. Below is the general guide and Boericke\'s own dose note — ask a practitioner before use.'**
  String get notCuratedDose;

  /// No description provided for @howToTake.
  ///
  /// In en, this message translates to:
  /// **'How to take pellets'**
  String get howToTake;

  /// No description provided for @step1T.
  ///
  /// In en, this message translates to:
  /// **'Clear the mouth.'**
  String get step1T;

  /// No description provided for @step1B.
  ///
  /// In en, this message translates to:
  /// **'No food, drink, mint or toothpaste for 15–30 minutes before and after.'**
  String get step1B;

  /// No description provided for @step2T.
  ///
  /// In en, this message translates to:
  /// **'Pour into the cap.'**
  String get step2T;

  /// No description provided for @step2B.
  ///
  /// In en, this message translates to:
  /// **'Avoid touching pellets with your fingers.'**
  String get step2B;

  /// No description provided for @step3T.
  ///
  /// In en, this message translates to:
  /// **'Let them dissolve under the tongue.'**
  String get step3T;

  /// No description provided for @step3B.
  ///
  /// In en, this message translates to:
  /// **'For infants, dissolve in a little clean water first.'**
  String get step3B;

  /// No description provided for @step4T.
  ///
  /// In en, this message translates to:
  /// **'Store away from heat and strong smells.'**
  String get step4T;

  /// No description provided for @step4B.
  ///
  /// In en, this message translates to:
  /// **'Keep out of sunlight, away from camphor, perfume and mobile phones.'**
  String get step4B;

  /// No description provided for @boerickeDose.
  ///
  /// In en, this message translates to:
  /// **'Boericke\'s dose note'**
  String get boerickeDose;

  /// No description provided for @doseDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Dosing here is general guidance from homeopathic literature. It is not a prescription.'**
  String get doseDisclaimer;

  /// No description provided for @brandsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No verified brands yet'**
  String get brandsEmptyTitle;

  /// No description provided for @brandsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'We list only brands and prices we have checked. Know a brand of this remedy sold in Bangladesh? Send it to us.'**
  String get brandsEmptyBody;

  /// No description provided for @suggestBrand.
  ///
  /// In en, this message translates to:
  /// **'Suggest a brand'**
  String get suggestBrand;

  /// No description provided for @materiaMedica.
  ///
  /// In en, this message translates to:
  /// **'Materia Medica'**
  String get materiaMedica;

  /// No description provided for @sourceBook.
  ///
  /// In en, this message translates to:
  /// **'Source book'**
  String get sourceBook;

  /// No description provided for @book_boericke.
  ///
  /// In en, this message translates to:
  /// **'Boericke'**
  String get book_boericke;

  /// No description provided for @book_allen.
  ///
  /// In en, this message translates to:
  /// **'Allen\'s Keynotes'**
  String get book_allen;

  /// No description provided for @studyLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Full Materia Medica is for students and practitioners'**
  String get studyLockedTitle;

  /// No description provided for @studyLockedBody.
  ///
  /// In en, this message translates to:
  /// **'Switch your detail level to Student or Practitioner to read the complete text from Boericke and Allen.'**
  String get studyLockedBody;

  /// No description provided for @switchToStudent.
  ///
  /// In en, this message translates to:
  /// **'Switch to Student'**
  String get switchToStudent;

  /// No description provided for @studyFooter.
  ///
  /// In en, this message translates to:
  /// **'Public-domain text: W. Boericke, Pocket Manual of Homoeopathic Materia Medica (1927); H. C. Allen, Keynotes (1898). For study — not medical advice.'**
  String get studyFooter;

  /// No description provided for @materiaOffline.
  ///
  /// In en, this message translates to:
  /// **'This text hasn\'t been downloaded yet. Connect once to read it — after that it stays on your phone.'**
  String get materiaOffline;

  /// No description provided for @studyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No book text for this remedy yet.'**
  String get studyEmpty;

  /// No description provided for @viewSource.
  ///
  /// In en, this message translates to:
  /// **'View source'**
  String get viewSource;

  /// No description provided for @seeDoctorIf.
  ///
  /// In en, this message translates to:
  /// **'See a doctor if'**
  String get seeDoctorIf;

  /// No description provided for @conditionEmpty.
  ///
  /// In en, this message translates to:
  /// **'No remedies are linked to this symptom yet.'**
  String get conditionEmpty;

  /// No description provided for @remediesForThis.
  ///
  /// In en, this message translates to:
  /// **'Remedies to compare'**
  String get remediesForThis;

  /// No description provided for @savedTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedTitle;

  /// No description provided for @savedSub.
  ///
  /// In en, this message translates to:
  /// **'Kept on this phone — no account needed'**
  String get savedSub;

  /// No description provided for @savedEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing saved yet'**
  String get savedEmptyTitle;

  /// No description provided for @savedEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the bookmark on any remedy to keep it here.'**
  String get savedEmptyBody;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSub.
  ///
  /// In en, this message translates to:
  /// **'Make the app comfortable to read'**
  String get settingsSub;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @dayMode.
  ///
  /// In en, this message translates to:
  /// **'Day mode'**
  String get dayMode;

  /// No description provided for @nightMode.
  ///
  /// In en, this message translates to:
  /// **'Night mode'**
  String get nightMode;

  /// No description provided for @daySub.
  ///
  /// In en, this message translates to:
  /// **'Bright and crisp for daytime'**
  String get daySub;

  /// No description provided for @nightSub.
  ///
  /// In en, this message translates to:
  /// **'Easier on the eyes after dark'**
  String get nightSub;

  /// No description provided for @systemSub.
  ///
  /// In en, this message translates to:
  /// **'Following your phone\'s setting'**
  String get systemSub;

  /// No description provided for @matchPhone.
  ///
  /// In en, this message translates to:
  /// **'Match my phone'**
  String get matchPhone;

  /// No description provided for @matchPhoneSub.
  ///
  /// In en, this message translates to:
  /// **'Switch with the system setting'**
  String get matchPhoneSub;

  /// No description provided for @themeColour.
  ///
  /// In en, this message translates to:
  /// **'Theme colour'**
  String get themeColour;

  /// No description provided for @accent_teal.
  ///
  /// In en, this message translates to:
  /// **'Teal'**
  String get accent_teal;

  /// No description provided for @accent_ocean.
  ///
  /// In en, this message translates to:
  /// **'Ocean'**
  String get accent_ocean;

  /// No description provided for @accent_forest.
  ///
  /// In en, this message translates to:
  /// **'Forest'**
  String get accent_forest;

  /// No description provided for @accent_plum.
  ///
  /// In en, this message translates to:
  /// **'Plum'**
  String get accent_plum;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @reading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get reading;

  /// No description provided for @textSize.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get textSize;

  /// No description provided for @textSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get textSmall;

  /// No description provided for @textMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get textMedium;

  /// No description provided for @textLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get textLarge;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @detailLevel.
  ///
  /// In en, this message translates to:
  /// **'Detail level'**
  String get detailLevel;

  /// No description provided for @modeNote_general.
  ///
  /// In en, this message translates to:
  /// **'Plain language, dose guide and brands.'**
  String get modeNote_general;

  /// No description provided for @modeNote_student.
  ///
  /// In en, this message translates to:
  /// **'Adds Materia Medica, keynotes and related remedies.'**
  String get modeNote_student;

  /// No description provided for @modeNote_practitioner.
  ///
  /// In en, this message translates to:
  /// **'Everything, with source books and full text.'**
  String get modeNote_practitioner;

  /// No description provided for @contribute.
  ///
  /// In en, this message translates to:
  /// **'Contribute'**
  String get contribute;

  /// No description provided for @requestMedicine.
  ///
  /// In en, this message translates to:
  /// **'Request a new medicine'**
  String get requestMedicine;

  /// No description provided for @requestMedicineSub.
  ///
  /// In en, this message translates to:
  /// **'Can\'t find a remedy or brand? Send it for review'**
  String get requestMedicineSub;

  /// No description provided for @myRequests.
  ///
  /// In en, this message translates to:
  /// **'My requests'**
  String get myRequests;

  /// No description provided for @myRequestsSub.
  ///
  /// In en, this message translates to:
  /// **'See what happened to what you sent'**
  String get myRequestsSub;

  /// No description provided for @reportError.
  ///
  /// In en, this message translates to:
  /// **'Report an error'**
  String get reportError;

  /// No description provided for @reportErrorSub.
  ///
  /// In en, this message translates to:
  /// **'Wrong dose, name or price'**
  String get reportErrorSub;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get contactUs;

  /// No description provided for @contactEmpty.
  ///
  /// In en, this message translates to:
  /// **'Contact details will appear here.'**
  String get contactEmpty;

  /// No description provided for @dataAbout.
  ///
  /// In en, this message translates to:
  /// **'Data & about'**
  String get dataAbout;

  /// No description provided for @offlineData.
  ///
  /// In en, this message translates to:
  /// **'Offline & data'**
  String get offlineData;

  /// No description provided for @upToDate.
  ///
  /// In en, this message translates to:
  /// **'Up to date · {size}'**
  String upToDate(String size);

  /// No description provided for @updating.
  ///
  /// In en, this message translates to:
  /// **'Checking for updates…'**
  String get updating;

  /// No description provided for @offlineSaved.
  ///
  /// In en, this message translates to:
  /// **'Offline · {size} saved'**
  String offlineSaved(String size);

  /// No description provided for @medicalDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Medical disclaimer'**
  String get medicalDisclaimer;

  /// No description provided for @sourcesCredits.
  ///
  /// In en, this message translates to:
  /// **'Sources & credits'**
  String get sourcesCredits;

  /// No description provided for @versionLine.
  ///
  /// In en, this message translates to:
  /// **'Version {v} · data {d}'**
  String versionLine(String v, String d);

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated {when}'**
  String lastUpdated(String when);

  /// No description provided for @checkUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get checkUpdates;

  /// No description provided for @onThisPhone.
  ///
  /// In en, this message translates to:
  /// **'On this phone'**
  String get onThisPhone;

  /// No description provided for @storageUsed.
  ///
  /// In en, this message translates to:
  /// **'Storage used'**
  String get storageUsed;

  /// No description provided for @bookTextNote.
  ///
  /// In en, this message translates to:
  /// **'Book text for a remedy downloads the first time you open its Study tab, then stays available offline.'**
  String get bookTextNote;

  /// No description provided for @statRemedies.
  ///
  /// In en, this message translates to:
  /// **'Remedies'**
  String get statRemedies;

  /// No description provided for @statSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get statSymptoms;

  /// No description provided for @statRelations.
  ///
  /// In en, this message translates to:
  /// **'Remedy links'**
  String get statRelations;

  /// No description provided for @statCompanies.
  ///
  /// In en, this message translates to:
  /// **'Companies'**
  String get statCompanies;

  /// No description provided for @requestTitle.
  ///
  /// In en, this message translates to:
  /// **'Request a medicine'**
  String get requestTitle;

  /// No description provided for @requestIntro.
  ///
  /// In en, this message translates to:
  /// **'Tell us what\'s missing. An editor checks every request before anything is added.'**
  String get requestIntro;

  /// No description provided for @kindRemedyLabel.
  ///
  /// In en, this message translates to:
  /// **'A remedy'**
  String get kindRemedyLabel;

  /// No description provided for @kindProductLabel.
  ///
  /// In en, this message translates to:
  /// **'A brand / product'**
  String get kindProductLabel;

  /// No description provided for @fieldLatin.
  ///
  /// In en, this message translates to:
  /// **'Remedy name (Latin)'**
  String get fieldLatin;

  /// No description provided for @fieldLatinHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Arnica montana'**
  String get fieldLatinHint;

  /// No description provided for @fieldCommon.
  ///
  /// In en, this message translates to:
  /// **'Common or Bangla name'**
  String get fieldCommon;

  /// No description provided for @fieldBrand.
  ///
  /// In en, this message translates to:
  /// **'Brand and company'**
  String get fieldBrand;

  /// No description provided for @fieldBrandHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Arnica 30 — SBL'**
  String get fieldBrandHint;

  /// No description provided for @fieldPotency.
  ///
  /// In en, this message translates to:
  /// **'Potency, form or pack'**
  String get fieldPotency;

  /// No description provided for @fieldNotes.
  ///
  /// In en, this message translates to:
  /// **'Anything else'**
  String get fieldNotes;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get fieldRequired;

  /// No description provided for @iAmA.
  ///
  /// In en, this message translates to:
  /// **'I am a'**
  String get iAmA;

  /// No description provided for @sendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get sendRequest;

  /// No description provided for @requestSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent. Follow it in My requests.'**
  String get requestSent;

  /// No description provided for @sendFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send. Check your connection and try again.'**
  String get sendFailed;

  /// No description provided for @myRequestsEmpty.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t sent any requests yet.'**
  String get myRequestsEmpty;

  /// No description provided for @status_new.
  ///
  /// In en, this message translates to:
  /// **'In review'**
  String get status_new;

  /// No description provided for @status_needs_info.
  ///
  /// In en, this message translates to:
  /// **'Needs info'**
  String get status_needs_info;

  /// No description provided for @status_approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get status_approved;

  /// No description provided for @status_merged.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get status_merged;

  /// No description provided for @status_rejected.
  ///
  /// In en, this message translates to:
  /// **'Not added'**
  String get status_rejected;

  /// No description provided for @reportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report an error'**
  String get reportTitle;

  /// No description provided for @reportHint.
  ///
  /// In en, this message translates to:
  /// **'What\'s wrong? e.g. a dose, a name or a price'**
  String get reportHint;

  /// No description provided for @reportSent.
  ///
  /// In en, this message translates to:
  /// **'Thanks — an editor will check it.'**
  String get reportSent;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @sponsored.
  ///
  /// In en, this message translates to:
  /// **'Sponsored'**
  String get sponsored;

  /// No description provided for @promoNote.
  ///
  /// In en, this message translates to:
  /// **'Sponsored content is kept apart from remedy information and never changes it.'**
  String get promoNote;

  /// No description provided for @advertiseWithUs.
  ///
  /// In en, this message translates to:
  /// **'Advertise with us'**
  String get advertiseWithUs;

  /// No description provided for @promoFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Your promotion here'**
  String get promoFallbackTitle;

  /// No description provided for @promoFallbackBody.
  ///
  /// In en, this message translates to:
  /// **'Reach patients, students and practitioners across Bangladesh.'**
  String get promoFallbackBody;

  /// No description provided for @disclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Medical disclaimer'**
  String get disclaimerTitle;

  /// No description provided for @guideTitle.
  ///
  /// In en, this message translates to:
  /// **'Potency guide'**
  String get guideTitle;

  /// No description provided for @guideP1T.
  ///
  /// In en, this message translates to:
  /// **'What a potency is'**
  String get guideP1T;

  /// No description provided for @guideP1.
  ///
  /// In en, this message translates to:
  /// **'A homeopathic medicine is made by diluting a starting substance step by step and shaking it at each step. The number tells you how many steps: 6C means six steps of 1 part in 100; 6X means six steps of 1 part in 10. Q (mother tincture) is the undiluted starting tincture.'**
  String get guideP1;

  /// No description provided for @guideP2T.
  ///
  /// In en, this message translates to:
  /// **'Low, middle and high'**
  String get guideP2T;

  /// No description provided for @guideP2.
  ///
  /// In en, this message translates to:
  /// **'Low potencies (3X–12X, 6C) are often repeated a few times a day. 30C is the most common strength for first aid and short-term complaints. 200C and 1M are high potencies, given less often and normally on a practitioner\'s advice.'**
  String get guideP2;

  /// No description provided for @guideP3T.
  ///
  /// In en, this message translates to:
  /// **'How much and how often'**
  String get guideP3T;

  /// No description provided for @guideP3.
  ///
  /// In en, this message translates to:
  /// **'The amount per dose changes little with potency; the age group and how often it is repeated matter more. Stop when you feel better, and see a doctor if a complaint is severe, lasts, or keeps coming back.'**
  String get guideP3;

  /// No description provided for @guideP4T.
  ///
  /// In en, this message translates to:
  /// **'Tissue salts'**
  String get guideP4T;

  /// No description provided for @guideP4.
  ///
  /// In en, this message translates to:
  /// **'The twelve Schüssler tissue salts are usually taken as 6X or 12X tablets, chewed or dissolved on the tongue.'**
  String get guideP4;

  /// No description provided for @guideNote.
  ///
  /// In en, this message translates to:
  /// **'General information from homeopathic literature — not a prescription.'**
  String get guideNote;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @voiceSearch.
  ///
  /// In en, this message translates to:
  /// **'Voice search'**
  String get voiceSearch;

  /// No description provided for @reviewed.
  ///
  /// In en, this message translates to:
  /// **'Reviewed'**
  String get reviewed;

  /// No description provided for @advertisement.
  ///
  /// In en, this message translates to:
  /// **'Advertisement'**
  String get advertisement;

  /// No description provided for @testAd.
  ///
  /// In en, this message translates to:
  /// **'Test ad'**
  String get testAd;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @historyCleared.
  ///
  /// In en, this message translates to:
  /// **'History cleared'**
  String get historyCleared;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @popularRemedies.
  ///
  /// In en, this message translates to:
  /// **'Popular remedies'**
  String get popularRemedies;

  /// No description provided for @booksTipTitle.
  ///
  /// In en, this message translates to:
  /// **'Search inside the books.'**
  String get booksTipTitle;

  /// No description provided for @booksTipBody.
  ///
  /// In en, this message translates to:
  /// **'Type a symptom like “worse at night” or “fear of death” to find it in Boericke and Allen (needs internet).'**
  String get booksTipBody;

  /// No description provided for @inTheBooks.
  ///
  /// In en, this message translates to:
  /// **'In the books'**
  String get inTheBooks;

  /// No description provided for @booksOffline.
  ///
  /// In en, this message translates to:
  /// **'Searching inside the books needs an internet connection.'**
  String get booksOffline;

  /// No description provided for @booksFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t search the books right now.'**
  String get booksFailed;

  /// No description provided for @booksExplain.
  ///
  /// In en, this message translates to:
  /// **'Matches in the full text of Boericke\'s Materia Medica and Allen\'s Keynotes (English).'**
  String get booksExplain;

  /// No description provided for @noBookMatches.
  ///
  /// In en, this message translates to:
  /// **'No book text mentions “{q}”.'**
  String noBookMatches(String q);

  /// No description provided for @didYouMean.
  ///
  /// In en, this message translates to:
  /// **'Did you mean “{term}”?'**
  String didYouMean(String term);

  /// No description provided for @seeAllN.
  ///
  /// In en, this message translates to:
  /// **'See all {count}'**
  String seeAllN(String count);

  /// No description provided for @resultsFor.
  ///
  /// In en, this message translates to:
  /// **'{count} results for “{q}”'**
  String resultsFor(String count, String q);

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @sortRelevance.
  ///
  /// In en, this message translates to:
  /// **'Best match first'**
  String get sortRelevance;

  /// No description provided for @sortAZ.
  ///
  /// In en, this message translates to:
  /// **'A–Z'**
  String get sortAZ;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @kingdomLabel.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get kingdomLabel;

  /// No description provided for @reviewedOnly.
  ///
  /// In en, this message translates to:
  /// **'Reviewed only'**
  String get reviewedOnly;

  /// No description provided for @reviewedOnlySub.
  ///
  /// In en, this message translates to:
  /// **'Remedies with reviewed uses and doses'**
  String get reviewedOnlySub;

  /// No description provided for @withBangla.
  ///
  /// In en, this message translates to:
  /// **'Has a Bangla page'**
  String get withBangla;

  /// No description provided for @withBanglaSub.
  ///
  /// In en, this message translates to:
  /// **'Name and summary in বাংলা'**
  String get withBanglaSub;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Show results'**
  String get apply;

  /// No description provided for @voiceListening.
  ///
  /// In en, this message translates to:
  /// **'Listening…'**
  String get voiceListening;

  /// No description provided for @voiceInBangla.
  ///
  /// In en, this message translates to:
  /// **'Speak in বাংলা — English works too'**
  String get voiceInBangla;

  /// No description provided for @voiceInEnglish.
  ///
  /// In en, this message translates to:
  /// **'Speak in English — switch the app to বাংলা to speak Bangla'**
  String get voiceInEnglish;

  /// No description provided for @voiceTapToStop.
  ///
  /// In en, this message translates to:
  /// **'Tap the mic to stop'**
  String get voiceTapToStop;

  /// No description provided for @voiceTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Tap the mic to try again'**
  String get voiceTryAgain;

  /// No description provided for @voiceDenied.
  ///
  /// In en, this message translates to:
  /// **'Microphone access is off. Allow it in your phone\'s settings to search by voice.'**
  String get voiceDenied;

  /// No description provided for @voiceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Voice search isn\'t available on this device.'**
  String get voiceUnavailable;

  /// No description provided for @voiceNothingHeard.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t catch that. Try again a little closer to the phone.'**
  String get voiceNothingHeard;

  /// No description provided for @voiceSpeakNow.
  ///
  /// In en, this message translates to:
  /// **'Say a remedy or a symptom'**
  String get voiceSpeakNow;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @firstAidKit.
  ///
  /// In en, this message translates to:
  /// **'First-aid kit'**
  String get firstAidKit;

  /// No description provided for @azIndex.
  ///
  /// In en, this message translates to:
  /// **'Jump to letter'**
  String get azIndex;

  /// No description provided for @swipeToRemove.
  ///
  /// In en, this message translates to:
  /// **'Swipe left to remove'**
  String get swipeToRemove;

  /// No description provided for @adPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Ad privacy choices'**
  String get adPrivacy;

  /// No description provided for @adPrivacySub.
  ///
  /// In en, this message translates to:
  /// **'Change how ads use your data'**
  String get adPrivacySub;

  /// No description provided for @backToTop.
  ///
  /// In en, this message translates to:
  /// **'Back to top'**
  String get backToTop;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeOptionLabel.
  ///
  /// In en, this message translates to:
  /// **'{label} theme'**
  String themeOptionLabel(String label);

  /// No description provided for @textDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get textDefault;

  /// No description provided for @textSmaller.
  ///
  /// In en, this message translates to:
  /// **'Smaller'**
  String get textSmaller;

  /// No description provided for @textLarger.
  ///
  /// In en, this message translates to:
  /// **'Larger'**
  String get textLarger;

  /// No description provided for @textLargest.
  ///
  /// In en, this message translates to:
  /// **'Largest'**
  String get textLargest;

  /// No description provided for @textPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview: Arnica 30C, three pellets under the tongue, twice a day.'**
  String get textPreview;

  /// No description provided for @behaviour.
  ///
  /// In en, this message translates to:
  /// **'Behaviour'**
  String get behaviour;

  /// No description provided for @hideBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Hide tab bar while scrolling'**
  String get hideBarTitle;

  /// No description provided for @hideBarSub.
  ///
  /// In en, this message translates to:
  /// **'Slides away as you scroll down and returns when you scroll up.'**
  String get hideBarSub;

  /// No description provided for @secOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get secOverview;

  /// No description provided for @secUses.
  ///
  /// In en, this message translates to:
  /// **'Indications'**
  String get secUses;

  /// No description provided for @secDosage.
  ///
  /// In en, this message translates to:
  /// **'Dosage & administration'**
  String get secDosage;

  /// No description provided for @secSafety.
  ///
  /// In en, this message translates to:
  /// **'Safety & precautions'**
  String get secSafety;

  /// No description provided for @secSafetySummary.
  ///
  /// In en, this message translates to:
  /// **'Pregnancy · children · storage · when to see a doctor'**
  String get secSafetySummary;

  /// No description provided for @secRelations.
  ///
  /// In en, this message translates to:
  /// **'Relationships'**
  String get secRelations;

  /// No description provided for @secBrands.
  ///
  /// In en, this message translates to:
  /// **'Available brands'**
  String get secBrands;

  /// No description provided for @secMateriaSummary.
  ///
  /// In en, this message translates to:
  /// **'Boericke & Allen, section by section'**
  String get secMateriaSummary;

  /// No description provided for @secSources.
  ///
  /// In en, this message translates to:
  /// **'Sources & review'**
  String get secSources;

  /// No description provided for @secSourcesSummary.
  ///
  /// In en, this message translates to:
  /// **'Where this text comes from'**
  String get secSourcesSummary;

  /// No description provided for @quickFacts.
  ///
  /// In en, this message translates to:
  /// **'Quick facts'**
  String get quickFacts;

  /// No description provided for @factCommon.
  ///
  /// In en, this message translates to:
  /// **'Common name'**
  String get factCommon;

  /// No description provided for @factBangla.
  ///
  /// In en, this message translates to:
  /// **'Bangla name'**
  String get factBangla;

  /// No description provided for @factAbbr.
  ///
  /// In en, this message translates to:
  /// **'Abbreviation'**
  String get factAbbr;

  /// No description provided for @factKingdom.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get factKingdom;

  /// No description provided for @factFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get factFamily;

  /// No description provided for @factGroups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get factGroups;

  /// No description provided for @expandAll.
  ///
  /// In en, this message translates to:
  /// **'Expand all sections'**
  String get expandAll;

  /// No description provided for @collapseAll.
  ///
  /// In en, this message translates to:
  /// **'Collapse all sections'**
  String get collapseAll;

  /// No description provided for @doseTable.
  ///
  /// In en, this message translates to:
  /// **'All age groups · {potency}'**
  String doseTable(String potency);

  /// No description provided for @colAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get colAge;

  /// No description provided for @colDose.
  ///
  /// In en, this message translates to:
  /// **'Dose'**
  String get colDose;

  /// No description provided for @colFrequency.
  ///
  /// In en, this message translates to:
  /// **'How often'**
  String get colFrequency;

  /// No description provided for @precPregnancyT.
  ///
  /// In en, this message translates to:
  /// **'Pregnancy & breastfeeding'**
  String get precPregnancyT;

  /// No description provided for @precPregnancyB.
  ///
  /// In en, this message translates to:
  /// **'Ask a registered homeopath or doctor before using any remedy.'**
  String get precPregnancyB;

  /// No description provided for @precChildrenT.
  ///
  /// In en, this message translates to:
  /// **'Children & infants'**
  String get precChildrenT;

  /// No description provided for @precChildrenB.
  ///
  /// In en, this message translates to:
  /// **'Doses differ by age — follow the age-wise table and ask a practitioner for babies.'**
  String get precChildrenB;

  /// No description provided for @precOngoingT.
  ///
  /// In en, this message translates to:
  /// **'Existing treatment'**
  String get precOngoingT;

  /// No description provided for @precOngoingB.
  ///
  /// In en, this message translates to:
  /// **'Do not stop prescribed medicines because of a homeopathic remedy.'**
  String get precOngoingB;

  /// No description provided for @precStorageT.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get precStorageT;

  /// No description provided for @precStorageB.
  ///
  /// In en, this message translates to:
  /// **'Keep in a cool, dry place away from sunlight, heat and strong smells such as camphor, menthol or perfume.'**
  String get precStorageB;

  /// No description provided for @precDoctorT.
  ///
  /// In en, this message translates to:
  /// **'When to see a doctor'**
  String get precDoctorT;

  /// No description provided for @precDoctorB.
  ///
  /// In en, this message translates to:
  /// **'Get medical care for severe, sudden or lasting symptoms. Remedies do not replace emergency care.'**
  String get precDoctorB;

  /// No description provided for @relationAvoidNote.
  ///
  /// In en, this message translates to:
  /// **'Remedies that cancel or clash with this one — usually not taken together.'**
  String get relationAvoidNote;

  /// No description provided for @brandsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} brands'**
  String brandsCount(String count);

  /// No description provided for @sortByPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get sortByPrice;

  /// No description provided for @brandsNote.
  ///
  /// In en, this message translates to:
  /// **'Prices are indicative pack prices and can differ by shop.'**
  String get brandsNote;

  /// No description provided for @priceFrom.
  ///
  /// In en, this message translates to:
  /// **'from ৳{price}'**
  String priceFrom(String price);

  /// No description provided for @dataUpdated.
  ///
  /// In en, this message translates to:
  /// **'Archive updated {date}'**
  String dataUpdated(String date);

  /// No description provided for @trySearching.
  ///
  /// In en, this message translates to:
  /// **'Try searching'**
  String get trySearching;

  /// No description provided for @booksNeedNet.
  ///
  /// In en, this message translates to:
  /// **'Searching inside the books needs an internet connection.'**
  String get booksNeedNet;

  /// No description provided for @useThisSearch.
  ///
  /// In en, this message translates to:
  /// **'Edit this search'**
  String get useThisSearch;
}

class _LDelegate extends LocalizationsDelegate<L> {
  const _LDelegate();

  @override
  Future<L> load(Locale locale) {
    return SynchronousFuture<L>(lookupL(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_LDelegate old) => false;
}

L lookupL(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return LBn();
    case 'en':
      return LEn();
  }

  throw FlutterError(
    'L.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
