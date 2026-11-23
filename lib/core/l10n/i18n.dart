import 'package:flutter/widgets.dart';

import 'package:homio_essentials/l10n/app_localizations.dart';

export 'package:homio_essentials/l10n/app_localizations.dart';

extension LContext on BuildContext {
  L get l => L.of(this);
  bool get bn => Localizations.localeOf(this).languageCode == 'bn';
}

const _bnDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];

/// Bangla names of the materia medica section headings (Boericke's body regions, Allen's parts).
/// Unknown headings (rare, e.g. "Magnetis Polus Arcticus") stay in English.
const _sectionBn = <String, String>{
  'overview': 'সারসংক্ষেপ', 'mind': 'মন', 'mental': 'মানসিক', 'head': 'মাথা', 'eyes': 'চোখ', 'eyes and ears': 'চোখ ও কান', 'ears': 'কান',
  'nose': 'নাক', 'face': 'মুখমণ্ডল', 'mouth': 'মুখগহ্বর', 'tongue': 'জিহ্বা', 'teeth': 'দাঁত', 'throat': 'গলা', 'neck': 'ঘাড়',
  'neck and back': 'ঘাড় ও পিঠ', 'stomach': 'পাকস্থলী', 'gastric': 'পাকস্থলী', 'stomach and abdomen': 'পাকস্থলী ও পেট',
  'gastro-intestinal': 'পাকস্থলী-অন্ত্র', 'gastro-enteric symptoms': 'পাকস্থলী-অন্ত্রের লক্ষণ', 'alimentary canal': 'পরিপাকনালী',
  'abdomen': 'পেট', 'liver': 'যকৃৎ', 'spleen': 'প্লীহা', 'stool': 'মল', 'stools': 'মল', 'bowels': 'অন্ত্র', 'rectum': 'মলদ্বার',
  'stool and anus': 'মল ও মলদ্বার', 'urine': 'প্রস্রাব', 'urinary': 'মূত্রতন্ত্র', 'urinary organs': 'মূত্রযন্ত্র', 'kidney': 'বৃক্ক (কিডনি)',
  'genito-urinary': 'প্রজনন-মূত্রতন্ত্র', 'male': 'পুরুষ', 'female': 'নারী', 'sexual': 'যৌন', 'respiratory': 'শ্বাসতন্ত্র',
  'respiratory organs': 'শ্বাসযন্ত্র', 'respiration': 'শ্বাসপ্রশ্বাস', 'chest': 'বুক', 'heart': 'হৃৎপিণ্ড', 'cardio-vascular': 'হৃৎপিণ্ড ও রক্তনালী',
  'circulatory organs': 'রক্তসঞ্চালন', 'blood': 'রক্ত', 'back': 'পিঠ', 'spine': 'মেরুদণ্ড', 'back and extremities': 'পিঠ ও হাত-পা',
  'extremities': 'হাত-পা', 'bones': 'হাড়', 'tissues': 'কলা (টিস্যু)', 'skin': 'ত্বক', 'sleep': 'ঘুম', 'fever': 'জ্বর',
  'nerves': 'স্নায়ু', 'nervous': 'স্নায়বিক', 'nervous system': 'স্নায়ুতন্ত্র', 'modalities': 'মডালিটি (হ্রাস-বৃদ্ধি)', 'modality': 'মডালিটি',
  'relationship': 'সম্পর্ক', 'relations': 'সম্পর্ক', 'dose': 'মাত্রা', 'doses': 'মাত্রা', 'uses': 'ব্যবহার',
  'non-homeopathic uses': 'হোমিওপ্যাথি-বহির্ভূত ব্যবহার', 'keynotes': 'মূল লক্ষণ', 'worse': 'বৃদ্ধি', 'better': 'উপশম',
};

const _formBn = <String, String>{
  'dilution': 'ডাইলিউশন (তরল)', 'globules': 'গ্লোবিউলস (বড়ি)', 'tablets': 'ট্যাবলেট', 'mother_tincture': 'মাদার টিংচার',
  'ointment': 'মলম', 'gel': 'জেল', 'drops': 'ড্রপস', 'syrup': 'সিরাপ', 'combination': 'কম্বিনেশন', 'other': 'অন্যান্য',
};
const _groupBn = <String, String>{
  'polychrest': 'পলিক্রেস্ট (বহুল ব্যবহৃত)', 'acute': 'তীব্র রোগে', 'first_aid': 'প্রাথমিক চিকিৎসা', 'tissue_salt': 'টিস্যু সল্ট (বায়োকেমিক)',
  'children': 'শিশুদের জন্য', 'nosode': 'নোসোড',
};

/// A product form (dilution, mother_tincture …) in the reading language.
String formLabel(String f, bool bangla) => bangla ? (_formBn[f] ?? f.replaceAll('_', ' ')) : f.replaceAll('_', ' ');

/// A remedy group (polychrest, first_aid …) in the reading language.
String groupLabel(String g, bool bangla) => bangla ? (_groupBn[g] ?? g.replaceAll('_', ' ')) : g.replaceAll('_', ' ');

/// A materia medica section heading in the reading language.
String sectionLabel(String section, bool bangla) => bangla ? (_sectionBn[section.trim().toLowerCase()] ?? section) : section;

/// Numbers in Bangla digits when the app is in Bangla (৭১৬), otherwise as-is.
String numL(BuildContext c, Object n) =>
    c.bn ? '$n'.split('').map((ch) => int.tryParse(ch) != null ? _bnDigits[int.parse(ch)] : ch).join() : '$n';

extension LabelLookups on L {
  String kingdom(String? k) => switch (k) {
        'plant' => kingdom_plant,
        'mineral' => kingdom_mineral,
        'animal' => kingdom_animal,
        'nosode' => kingdom_nosode,
        'sarcode' => kingdom_sarcode,
        'imponderabilia' => kingdom_imponderabilia,
        _ => kingdom_other,
      };

  String relation(String t) => switch (t) {
        'complementary' => rel_complementary,
        'antidote' => rel_antidote,
        'inimical' => rel_inimical,
        'follows_well' => rel_follows_well,
        _ => rel_compare,
      };

  String book(String b) => switch (b) { 'allen' => book_allen, 'clarke' => book_clarke, _ => book_boericke };
  String bookSource(String b) => switch (b) { 'allen' => bookFullAllen, 'clarke' => bookFullClarke, _ => bookFullBoericke };

  String status(String s) => switch (s) {
        'needs_info' => status_needs_info,
        'approved' => status_approved,
        'merged' => status_merged,
        'rejected' => status_rejected,
        _ => status_new,
      };

  String accent(String a) => switch (a) { 'ocean' => accent_ocean, 'forest' => accent_forest, 'plum' => accent_plum, _ => accent_teal };

  String modeNote(String role) => switch (role) {
        'student' => modeNote_student,
        'practitioner' => modeNote_practitioner,
        _ => modeNote_general,
      };
}
