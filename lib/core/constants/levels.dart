// Mapping stored English level keys to Arabic display names
const Map<String, String> levelNamesArabic = {
  'level1': 'المستوى الأول',
  'level2': 'المستوى الثاني',
  'level3': 'المستوى الثالث',
  'level4': 'المستوى الرابع',
  'level5': 'المستوى الخامس',
  'level6': 'المستوى السادس',
  'level7': 'المستوى السابع',
};

String levelEnToArabic(String levelEn) => levelNamesArabic[levelEn] ?? levelEn;
