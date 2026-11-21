import 'package:flutter_test/flutter_test.dart';
import 'package:homio_essentials/core/archive/domain/entities/archive.dart';
import 'package:homio_essentials/features/search/domain/services/search_index.dart';

Archive _archive() => Archive.build({
      'remedies': [
        {'id': '1', 'slug': 'arnica-montana', 'latin_name': 'Arnica montana', 'abbreviation': 'Arn.', 'kingdom': 'plant', 'search_keys': ['arnika']},
        {'id': '2', 'slug': 'nux-vomica', 'latin_name': 'Nux vomica', 'abbreviation': 'Nux-v.', 'kingdom': 'plant', 'search_keys': <String>[]},
        {'id': '3', 'slug': 'phosphorus', 'latin_name': 'Phosphorus', 'abbreviation': 'Phos.', 'kingdom': 'mineral', 'search_keys': <String>[]},
        {'id': '4', 'slug': 'hepar-sulphuris-calcareum', 'latin_name': 'Hepar sulphuris calcareum', 'kingdom': 'mineral', 'search_keys': <String>[]},
      ],
      'remedy_translations': [
        {'remedy_id': '1', 'locale': 'en', 'common_name': "Leopard's Bane"},
        {'remedy_id': '1', 'locale': 'bn', 'display_name': 'আর্নিকা মন্টানা'},
      ],
      'conditions': [
        {'id': 'c1', 'slug': 'cough', 'sort_order': 1},
      ],
      'condition_translations': [
        {'condition_id': 'c1', 'locale': 'en', 'name': 'Cough', 'search_keys': ['khashi']},
        {'condition_id': 'c1', 'locale': 'bn', 'name': 'কাশি'},
      ],
    }, 'test', DateTime(2026));

void main() {
  final index = SearchIndex(_archive());
  String top(String q) => index.search(q).first.id;

  test('Latin prefix', () => expect(top('arn'), 'arnica-montana'));
  test('Banglish spelling', () => expect(top('arnika'), 'arnica-montana'));
  test('Banglish phonetic: nuks vomika', () => expect(top('nuks vomika'), 'nux-vomica'));
  test('Bangla script', () => expect(top('আর্নিকা'), 'arnica-montana'));
  test('Bangla condition', () => expect(top('কাশি'), 'cough'));
  test('Common name', () => expect(top('leopard'), 'arnica-montana'));
  test('Typo tolerance', () => expect(top('phosphorous'), 'phosphorus'));
  test('Word inside name', () => expect(top('sulphuris'), 'hepar-sulphuris-calcareum'));
  test('Nothing for nonsense', () => expect(index.search('zzqqxx'), isEmpty));
  test('Mixed-language query falls back to matching words', () => expect(top('কনিয়াম arnica'), 'arnica-montana'));
  test('Phonetic matching already finds "phosforrus"', () => expect(top('phosforrus'), 'phosphorus'));
  test('Did you mean: nearest name when nothing matches', () => expect(index.didYouMean('lepard'), "Leopard's Bane"));
  test('Did you mean: nothing when spelled right', () => expect(index.didYouMean('arnica'), isNull));

  test('remedy of the day is stable within a day', () {
    final a = _archive();
    expect(a.remedyOfTheDay(DateTime(2026, 11, 21, 8)), same(a.remedyOfTheDay(DateTime(2026, 11, 21, 20))));
  });
}
