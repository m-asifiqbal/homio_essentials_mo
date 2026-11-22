// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class LEn extends L {
  LEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Homio Essentials';

  @override
  String get tabHome => 'Home';

  @override
  String get tabExplore => 'Explore';

  @override
  String get tabSaved => 'Saved';

  @override
  String get tabSettings => 'Settings';

  @override
  String get retry => 'Try again';

  @override
  String get seeAll => 'See all';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get save => 'Save';

  @override
  String get savedSnack => 'Saved';

  @override
  String get removedSnack => 'Removed from saved';

  @override
  String get share => 'Share';

  @override
  String get all => 'All';

  @override
  String get english => 'English';

  @override
  String get bangla => 'বাংলা';

  @override
  String get offlineBanner =>
      'You\'re offline — showing the archive saved on this phone.';

  @override
  String get loadingArchive =>
      'Downloading the archive… this happens only once.';

  @override
  String get loadFailedTitle => 'Couldn\'t load the archive';

  @override
  String get loadFailedBody =>
      'Check your internet connection. The app downloads the archive once; after that it works offline.';

  @override
  String get notFound => 'This item isn\'t in the archive.';

  @override
  String get kingdom_plant => 'Plant';

  @override
  String get kingdom_mineral => 'Mineral';

  @override
  String get kingdom_animal => 'Animal';

  @override
  String get kingdom_nosode => 'Nosode';

  @override
  String get kingdom_sarcode => 'Sarcode';

  @override
  String get kingdom_imponderabilia => 'Imponderable';

  @override
  String get kingdom_other => 'Chemical';

  @override
  String get welcomeTitle => 'The homeopathic medicine archive';

  @override
  String get welcomeBody =>
      'Remedies, what they are used for, doses by age and the classic Materia Medica — in English and বাংলা. Works offline once downloaded.';

  @override
  String get welcomePoint1 => '700+ remedies from Boericke\'s Materia Medica';

  @override
  String get welcomePoint2 => 'Dose guide by age group and potency';

  @override
  String get welcomePoint3 =>
      'Search by voice or typing — English, বাংলা or Banglish';

  @override
  String get getStarted => 'Get started';

  @override
  String get chooseLanguage => 'Choose your language';

  @override
  String get languageNote => 'You can change this any time in Settings.';

  @override
  String chooseRole(String app) {
    return 'How will you use $app?';
  }

  @override
  String get roleGeneral => 'General';

  @override
  String get roleGeneralDesc => 'Plain language: uses and a dose guide';

  @override
  String get roleStudent => 'Student';

  @override
  String get roleStudentDesc =>
      'Adds Materia Medica, keynotes and related remedies';

  @override
  String get rolePractitioner => 'Practitioner';

  @override
  String get rolePractitionerDesc =>
      'Everything, with source books and full text';

  @override
  String get beforeYouStart => 'Before you start';

  @override
  String get iUnderstand => 'I understand';

  @override
  String get disclaimerFallback =>
      'Reference information from homeopathic literature — not medical advice. Ask a registered practitioner before use, especially for infants, pregnancy or long-term conditions. In an emergency, get medical help.';

  @override
  String get welcomeBack => 'Welcome';

  @override
  String get homeTitle => 'Find a remedy, brand or symptom';

  @override
  String get searchHint => 'Search “Arnica”, “fever”, “SBL”…';

  @override
  String get remedyOfDay => 'REMEDY OF THE DAY';

  @override
  String get readMore => 'Read more';

  @override
  String get browseArchive => 'Browse the archive';

  @override
  String get browseRemedies => 'Remedies';

  @override
  String get browseSymptoms => 'Symptoms';

  @override
  String get browseCompanies => 'Companies';

  @override
  String get browseMateria => 'Materia Medica';

  @override
  String get browseSaved => 'Saved';

  @override
  String get browseGuide => 'Potency guide';

  @override
  String get studyModesNote =>
      'Materia Medica opens fully in Student and Practitioner modes.';

  @override
  String get findBySymptom => 'Find by symptom';

  @override
  String get doseByAge => 'Dose by age group';

  @override
  String get recentlyViewed => 'Recently viewed';

  @override
  String get history => 'History';

  @override
  String get learnBasics => 'Learn the basics';

  @override
  String get guideBadge => 'Guide · 3 min read';

  @override
  String get potencyGuideTitle =>
      'Potency, dilution and dose — a beginner\'s guide';

  @override
  String get potencyGuideBody =>
      'What 6C, 30C and 200C mean, and how they are used.';

  @override
  String archiveStats(String remedies, String conditions) {
    return '$remedies remedies · $conditions symptoms';
  }

  @override
  String get exploreTitle => 'Explore';

  @override
  String get exploreSub => 'The A–Z archive of homeopathic remedies';

  @override
  String get searchArchive => 'Search the archive';

  @override
  String get segRemedies => 'Remedies';

  @override
  String get segSymptoms => 'Symptoms';

  @override
  String get segCompanies => 'Companies';

  @override
  String remedyCount(String count) {
    return '$count remedies';
  }

  @override
  String get noMatches => 'Nothing matches this filter.';

  @override
  String get soldInBd => 'Sold in Bangladesh';

  @override
  String get website => 'Website';

  @override
  String get searchFieldHint => 'Remedies, symptoms, companies';

  @override
  String get results => 'Results';

  @override
  String get recentSearches => 'Recent searches';

  @override
  String get banglishTipTitle => 'Type in Banglish, too.';

  @override
  String get banglishTipBody =>
      '“arnika” or “nuks vomika” finds Arnica and Nux vomica — and আর্নিকা works as well.';

  @override
  String noResultsTitle(String q) {
    return 'No match for “$q”';
  }

  @override
  String get noResultsBody =>
      'Check the spelling, or ask us to add this medicine.';

  @override
  String get requestThis => 'Request this medicine';

  @override
  String get kindRemedy => 'Remedy';

  @override
  String get kindSymptom => 'Symptom';

  @override
  String get kindCompany => 'Company';

  @override
  String get tabOverview => 'Overview';

  @override
  String get tabUses => 'Uses';

  @override
  String get tabDosage => 'Dosage';

  @override
  String get tabBrands => 'Brands';

  @override
  String get tabStudy => 'Study';

  @override
  String get forms => 'Forms';

  @override
  String get potency => 'Potency';

  @override
  String get route => 'Route';

  @override
  String get routeOral => 'By mouth';

  @override
  String get routeOralSkin => 'Mouth + skin';

  @override
  String get mostlyUsedFor => 'Mostly used for';

  @override
  String get typicalAdultDose => 'Typical adult dose';

  @override
  String get pellets => 'pellets';

  @override
  String get tablets => 'tablets';

  @override
  String get dosesByAge => 'Doses by age →';

  @override
  String get safety => 'Safety';

  @override
  String moreNotes(String count) {
    return '+$count more';
  }

  @override
  String get about => 'About';

  @override
  String get inEnglishNote =>
      'Shown in English — the Bangla text is being prepared.';

  @override
  String get keynotes => 'Keynotes';

  @override
  String get keynotesSource =>
      'From H. C. Allen, Keynotes and Characteristics (1898)';

  @override
  String get relatedRemedies => 'Related remedies';

  @override
  String get rel_compare => 'Compare';

  @override
  String get rel_complementary => 'Complementary';

  @override
  String get rel_antidote => 'Antidote';

  @override
  String get rel_inimical => 'Inimical';

  @override
  String get rel_follows_well => 'Follows well';

  @override
  String get sources => 'Sources';

  @override
  String get sourceBoericke =>
      'Boericke, Pocket Manual of Homoeopathic Materia Medica';

  @override
  String sourceChecked(String page) {
    return 'Checked against the 1922 printed edition, page $page';
  }

  @override
  String sourceCurated(String app) {
    return 'Summary, uses and doses written for $app and awaiting review by a registered homeopath.';
  }

  @override
  String get referenceNote =>
      'Reference information from homeopathic literature — not medical advice.';

  @override
  String get readFullNote => 'Read the full note';

  @override
  String get doseGuide => 'Dose guide';

  @override
  String get usesTitle => 'What it is used for';

  @override
  String get usesEmptyTitle => 'No reviewed uses yet';

  @override
  String get usesEmptyBody =>
      'Uses by symptom haven\'t been reviewed for this remedy yet. Its full description from Boericke\'s Materia Medica is in the Study tab.';

  @override
  String get openStudy => 'Open Study';

  @override
  String get externalUse => 'Also used on the skin';

  @override
  String get doseGuideSub =>
      'Pick a potency and an age group. Guidance is general — your practitioner\'s advice comes first.';

  @override
  String get stepPotency => '1 · Potency';

  @override
  String get stepWho => '2 · Who is it for?';

  @override
  String get dosePerTime => 'DOSE PER TIME';

  @override
  String get dissolveUnderTongue => 'Dissolve under the tongue';

  @override
  String get chewOrDissolve => 'Chew, or dissolve on the tongue';

  @override
  String get highPotencyWarn =>
      'High potency. Use only as advised by a registered practitioner.';

  @override
  String get notCuratedDose =>
      'This remedy\'s dose hasn\'t been reviewed yet. Below is the general guide and Boericke\'s own dose note — ask a practitioner before use.';

  @override
  String get howToTake => 'How to take pellets';

  @override
  String get step1T => 'Clear the mouth.';

  @override
  String get step1B =>
      'No food, drink, mint or toothpaste for 15–30 minutes before and after.';

  @override
  String get step2T => 'Pour into the cap.';

  @override
  String get step2B => 'Avoid touching pellets with your fingers.';

  @override
  String get step3T => 'Let them dissolve under the tongue.';

  @override
  String get step3B => 'For infants, dissolve in a little clean water first.';

  @override
  String get step4T => 'Store away from heat and strong smells.';

  @override
  String get step4B =>
      'Keep out of sunlight, away from camphor, perfume and mobile phones.';

  @override
  String get boerickeDose => 'Boericke\'s dose note';

  @override
  String get doseDisclaimer =>
      'Dosing here is general guidance from homeopathic literature. It is not a prescription.';

  @override
  String get brandsEmptyTitle => 'No verified brands yet';

  @override
  String get brandsEmptyBody =>
      'We list only brands and prices we have checked. Know a brand of this remedy sold in Bangladesh? Send it to us.';

  @override
  String get suggestBrand => 'Suggest a brand';

  @override
  String get materiaMedica => 'Materia Medica';

  @override
  String get sourceBook => 'Source book';

  @override
  String get book_boericke => 'Boericke';

  @override
  String get book_allen => 'Allen\'s Keynotes';

  @override
  String get studyLockedTitle =>
      'Full Materia Medica is for students and practitioners';

  @override
  String get studyLockedBody =>
      'Switch your detail level to Student or Practitioner to read the complete text from Boericke and Allen.';

  @override
  String get switchToStudent => 'Switch to Student';

  @override
  String get studyFooter =>
      'Public-domain text: W. Boericke, Pocket Manual of Homoeopathic Materia Medica (1927); H. C. Allen, Keynotes (1898). For study — not medical advice.';

  @override
  String get materiaOffline =>
      'This text hasn\'t been downloaded yet. Connect once to read it — after that it stays on your phone.';

  @override
  String get studyEmpty => 'No book text for this remedy yet.';

  @override
  String get viewSource => 'View source';

  @override
  String get seeDoctorIf => 'See a doctor if';

  @override
  String get conditionEmpty => 'No remedies are linked to this symptom yet.';

  @override
  String get remediesForThis => 'Remedies to compare';

  @override
  String get savedTitle => 'Saved';

  @override
  String get savedSub => 'Kept on this phone — no account needed';

  @override
  String get savedEmptyTitle => 'Nothing saved yet';

  @override
  String get savedEmptyBody =>
      'Tap the bookmark on any remedy to keep it here.';

  @override
  String get clear => 'Clear';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSub => 'Make the app comfortable to read';

  @override
  String get appearance => 'Appearance';

  @override
  String get dayMode => 'Day mode';

  @override
  String get nightMode => 'Night mode';

  @override
  String get daySub => 'Bright and crisp for daytime';

  @override
  String get nightSub => 'Easier on the eyes after dark';

  @override
  String get systemSub => 'Following your phone\'s setting';

  @override
  String get matchPhone => 'Match my phone';

  @override
  String get matchPhoneSub => 'Switch with the system setting';

  @override
  String get themeColour => 'Theme colour';

  @override
  String get accent_teal => 'Teal';

  @override
  String get accent_ocean => 'Ocean';

  @override
  String get accent_forest => 'Forest';

  @override
  String get accent_plum => 'Plum';

  @override
  String get preview => 'Preview';

  @override
  String get reading => 'Reading';

  @override
  String get textSize => 'Text size';

  @override
  String get textSmall => 'Small';

  @override
  String get textMedium => 'Medium';

  @override
  String get textLarge => 'Large';

  @override
  String get language => 'Language';

  @override
  String get detailLevel => 'Detail level';

  @override
  String get modeNote_general => 'Plain language, dose guide and brands.';

  @override
  String get modeNote_student =>
      'Adds Materia Medica, keynotes and related remedies.';

  @override
  String get modeNote_practitioner =>
      'Everything, with source books and full text.';

  @override
  String get contribute => 'Contribute';

  @override
  String get requestMedicine => 'Request a new medicine';

  @override
  String get requestMedicineSub =>
      'Can\'t find a remedy or brand? Send it for review';

  @override
  String get myRequests => 'My requests';

  @override
  String get myRequestsSub => 'See what happened to what you sent';

  @override
  String get reportError => 'Report an error';

  @override
  String get reportErrorSub => 'Wrong dose, name or price';

  @override
  String get contactUs => 'Contact us';

  @override
  String get contactEmpty => 'Contact details will appear here.';

  @override
  String get dataAbout => 'Data & about';

  @override
  String get offlineData => 'Offline & data';

  @override
  String upToDate(String size) {
    return 'Up to date · $size';
  }

  @override
  String get updating => 'Checking for updates…';

  @override
  String offlineSaved(String size) {
    return 'Offline · $size saved';
  }

  @override
  String get medicalDisclaimer => 'Medical disclaimer';

  @override
  String get sourcesCredits => 'Sources & credits';

  @override
  String versionLine(String v, String d) {
    return 'Version $v · data $d';
  }

  @override
  String lastUpdated(String when) {
    return 'Last updated $when';
  }

  @override
  String get checkUpdates => 'Check for updates';

  @override
  String get onThisPhone => 'On this phone';

  @override
  String get storageUsed => 'Storage used';

  @override
  String get bookTextNote =>
      'Book text for a remedy downloads the first time you open its Study tab, then stays available offline.';

  @override
  String get statRemedies => 'Remedies';

  @override
  String get statSymptoms => 'Symptoms';

  @override
  String get statRelations => 'Remedy links';

  @override
  String get statCompanies => 'Companies';

  @override
  String get requestTitle => 'Request a medicine';

  @override
  String get requestIntro =>
      'Tell us what\'s missing. An editor checks every request before anything is added.';

  @override
  String get kindRemedyLabel => 'A remedy';

  @override
  String get kindProductLabel => 'A brand / product';

  @override
  String get fieldLatin => 'Remedy name (Latin)';

  @override
  String get fieldLatinHint => 'e.g. Arnica montana';

  @override
  String get fieldCommon => 'Common or Bangla name';

  @override
  String get fieldBrand => 'Brand and company';

  @override
  String get fieldBrandHint => 'e.g. Arnica 30 — SBL';

  @override
  String get fieldPotency => 'Potency, form or pack';

  @override
  String get fieldNotes => 'Anything else';

  @override
  String get fieldRequired => 'Required';

  @override
  String get iAmA => 'I am a';

  @override
  String get sendRequest => 'Send request';

  @override
  String get requestSent => 'Request sent. Follow it in My requests.';

  @override
  String get sendFailed =>
      'Couldn\'t send. Check your connection and try again.';

  @override
  String get myRequestsEmpty => 'You haven\'t sent any requests yet.';

  @override
  String get status_new => 'In review';

  @override
  String get status_needs_info => 'Needs info';

  @override
  String get status_approved => 'Approved';

  @override
  String get status_merged => 'Added';

  @override
  String get status_rejected => 'Not added';

  @override
  String get reportTitle => 'Report an error';

  @override
  String get reportHint => 'What\'s wrong? e.g. a dose, a name or a price';

  @override
  String get reportSent => 'Thanks — an editor will check it.';

  @override
  String get send => 'Send';

  @override
  String get sponsored => 'Sponsored';

  @override
  String get promoNote =>
      'Sponsored content is kept apart from remedy information and never changes it.';

  @override
  String get advertiseWithUs => 'Advertise with us';

  @override
  String get promoFallbackTitle => 'Your promotion here';

  @override
  String get promoFallbackBody =>
      'Reach patients, students and practitioners across Bangladesh.';

  @override
  String get disclaimerTitle => 'Medical disclaimer';

  @override
  String get guideTitle => 'Potency guide';

  @override
  String get guideP1T => 'What a potency is';

  @override
  String get guideP1 =>
      'A homeopathic medicine is made by diluting a starting substance step by step and shaking it at each step. The number tells you how many steps: 6C means six steps of 1 part in 100; 6X means six steps of 1 part in 10. Q (mother tincture) is the undiluted starting tincture.';

  @override
  String get guideP2T => 'Low, middle and high';

  @override
  String get guideP2 =>
      'Low potencies (3X–12X, 6C) are often repeated a few times a day. 30C is the most common strength for first aid and short-term complaints. 200C and 1M are high potencies, given less often and normally on a practitioner\'s advice.';

  @override
  String get guideP3T => 'How much and how often';

  @override
  String get guideP3 =>
      'The amount per dose changes little with potency; the age group and how often it is repeated matter more. Stop when you feel better, and see a doctor if a complaint is severe, lasts, or keeps coming back.';

  @override
  String get guideP4T => 'Tissue salts';

  @override
  String get guideP4 =>
      'The twelve Schüssler tissue salts are usually taken as 6X or 12X tablets, chewed or dissolved on the tongue.';

  @override
  String get guideNote =>
      'General information from homeopathic literature — not a prescription.';

  @override
  String get remove => 'Remove';

  @override
  String get voiceSearch => 'Voice search';

  @override
  String get reviewed => 'Reviewed';

  @override
  String get advertisement => 'Advertisement';

  @override
  String get testAd => 'Test ad';

  @override
  String get clearAll => 'Clear all';

  @override
  String get historyCleared => 'History cleared';

  @override
  String get undo => 'Undo';

  @override
  String get popularRemedies => 'Popular remedies';

  @override
  String get booksTipTitle => 'Search inside the books.';

  @override
  String get booksTipBody =>
      'Type a symptom like “worse at night” or “fear of death” to find it in Boericke and Allen (needs internet).';

  @override
  String get inTheBooks => 'In the books';

  @override
  String get booksOffline =>
      'Searching inside the books needs an internet connection.';

  @override
  String get booksFailed => 'Couldn\'t search the books right now.';

  @override
  String get booksExplain =>
      'Matches in the full text of Boericke\'s Materia Medica and Allen\'s Keynotes (English).';

  @override
  String noBookMatches(String q) {
    return 'No book text mentions “$q”.';
  }

  @override
  String didYouMean(String term) {
    return 'Did you mean “$term”?';
  }

  @override
  String seeAllN(String count) {
    return 'See all $count';
  }

  @override
  String resultsFor(String count, String q) {
    return '$count results for “$q”';
  }

  @override
  String get filters => 'Filters';

  @override
  String get sortRelevance => 'Best match first';

  @override
  String get sortAZ => 'A–Z';

  @override
  String get reset => 'Reset';

  @override
  String get kingdomLabel => 'Source';

  @override
  String get reviewedOnly => 'Reviewed only';

  @override
  String get reviewedOnlySub => 'Remedies with reviewed uses and doses';

  @override
  String get withBangla => 'Has a Bangla page';

  @override
  String get withBanglaSub => 'Name and summary in বাংলা';

  @override
  String get sortBy => 'Sort by';

  @override
  String get apply => 'Show results';

  @override
  String get voiceListening => 'Listening…';

  @override
  String get voiceInBangla => 'Speak in বাংলা — English works too';

  @override
  String get voiceInEnglish =>
      'Speak in English — switch the app to বাংলা to speak Bangla';

  @override
  String get voiceTapToStop => 'Tap the mic to stop';

  @override
  String get voiceTryAgain => 'Tap the mic to try again';

  @override
  String get voiceDenied =>
      'Microphone access is off. Allow it in your phone\'s settings to search by voice.';

  @override
  String get voiceUnavailable =>
      'Voice search isn\'t available on this device.';

  @override
  String get voiceNothingHeard =>
      'Didn\'t catch that. Try again a little closer to the phone.';

  @override
  String get voiceSpeakNow => 'Say a remedy or a symptom';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get firstAidKit => 'First-aid kit';

  @override
  String get azIndex => 'Jump to letter';

  @override
  String get swipeToRemove => 'Swipe left to remove';

  @override
  String get adPrivacy => 'Ad privacy choices';

  @override
  String get adPrivacySub => 'Change how ads use your data';

  @override
  String get backToTop => 'Back to top';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String themeOptionLabel(String label) {
    return '$label theme';
  }

  @override
  String get textDefault => 'Default';

  @override
  String get textSmaller => 'Smaller';

  @override
  String get textLarger => 'Larger';

  @override
  String get textLargest => 'Largest';

  @override
  String get textPreview =>
      'Preview: Arnica 30C, three pellets under the tongue, twice a day.';

  @override
  String get secOverview => 'Overview';

  @override
  String get secUses => 'Indications';

  @override
  String get secDosage => 'Dosage & administration';

  @override
  String get secSafety => 'Safety & precautions';

  @override
  String get secSafetySummary =>
      'Pregnancy · children · storage · when to see a doctor';

  @override
  String get secRelations => 'Relationships';

  @override
  String get secBrands => 'Available brands';

  @override
  String get secMateriaSummary => 'Boericke & Allen, section by section';

  @override
  String get secSources => 'Sources & review';

  @override
  String get secSourcesSummary => 'Where this text comes from';

  @override
  String get quickFacts => 'Quick facts';

  @override
  String get factCommon => 'Common name';

  @override
  String get factBangla => 'Bangla name';

  @override
  String get factAbbr => 'Abbreviation';

  @override
  String get factKingdom => 'Source';

  @override
  String get factFamily => 'Family';

  @override
  String get factGroups => 'Groups';

  @override
  String get expandAll => 'Expand all sections';

  @override
  String get collapseAll => 'Collapse all sections';

  @override
  String doseTable(String potency) {
    return 'All age groups · $potency';
  }

  @override
  String get colAge => 'Age';

  @override
  String get colDose => 'Dose';

  @override
  String get colFrequency => 'How often';

  @override
  String get precPregnancyT => 'Pregnancy & breastfeeding';

  @override
  String get precPregnancyB =>
      'Ask a registered homeopath or doctor before using any remedy.';

  @override
  String get precChildrenT => 'Children & infants';

  @override
  String get precChildrenB =>
      'Doses differ by age — follow the age-wise table and ask a practitioner for babies.';

  @override
  String get precOngoingT => 'Existing treatment';

  @override
  String get precOngoingB =>
      'Do not stop prescribed medicines because of a homeopathic remedy.';

  @override
  String get precStorageT => 'Storage';

  @override
  String get precStorageB =>
      'Keep in a cool, dry place away from sunlight, heat and strong smells such as camphor, menthol or perfume.';

  @override
  String get precDoctorT => 'When to see a doctor';

  @override
  String get precDoctorB =>
      'Get medical care for severe, sudden or lasting symptoms. Remedies do not replace emergency care.';

  @override
  String get relationAvoidNote =>
      'Remedies that cancel or clash with this one — usually not taken together.';

  @override
  String brandsCount(String count) {
    return '$count brands';
  }

  @override
  String get sortByPrice => 'Price';

  @override
  String get brandsNote =>
      'Prices are indicative pack prices and can differ by shop.';

  @override
  String priceFrom(String price) {
    return 'from ৳$price';
  }

  @override
  String dataUpdated(String date) {
    return 'Archive updated $date';
  }

  @override
  String get trySearching => 'Try searching';

  @override
  String get booksNeedNet =>
      'Searching inside the books needs an internet connection.';

  @override
  String get useThisSearch => 'Edit this search';
}
