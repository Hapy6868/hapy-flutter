/// Ngôn ngữ của một từ điển. Mỗi ngôn ngữ có giọng đọc, giọng nhận dạng,
/// nhãn phiên âm và gợi ý nhập riêng.
class AppLanguage {
  const AppLanguage({
    required this.code,
    required this.name,
    required this.flag,
    required this.ttsLocale,
    required this.sttLocale,
    required this.translateCode,
    required this.phoneticLabel,
    required this.phoneticHint,
    required this.wordHint,
    required this.sentenceHint,
  });

  /// Mã lưu trong CSDL: en / ja / zh.
  final String code;
  final String name;
  final String flag;

  /// Giọng đọc (Text-to-Speech), ví dụ ja-JP.
  final String ttsLocale;

  /// Giọng nhận dạng khi nói (Speech-to-Text), ví dụ ja_JP.
  final String sttLocale;

  /// Mã ngôn ngữ gửi cho dịch vụ dịch.
  final String translateCode;

  final String phoneticLabel;
  final String phoneticHint;
  final String wordHint;
  final String sentenceHint;

  /// Tên viết hoa chữ đầu: "Tiếng Nhật".
  String get title => name[0].toUpperCase() + name.substring(1);

  static const en = AppLanguage(
    code: 'en',
    name: 'tiếng Anh',
    flag: '🇺🇸',
    ttsLocale: 'en-US',
    sttLocale: 'en_US',
    translateCode: 'en',
    phoneticLabel: 'Phiên âm (IPA)',
    phoneticHint: '/.../',
    wordHint: 'Gõ hoặc nói một từ tiếng Anh',
    sentenceHint: 'Gõ hoặc nói một câu tiếng Anh',
  );

  static const ja = AppLanguage(
    code: 'ja',
    name: 'tiếng Nhật',
    flag: '🇯🇵',
    ttsLocale: 'ja-JP',
    sttLocale: 'ja_JP',
    translateCode: 'ja',
    phoneticLabel: 'Cách đọc (kana • romaji)',
    phoneticHint: 'ねこ • neko',
    wordHint: 'Gõ hoặc nói một từ tiếng Nhật',
    sentenceHint: 'Gõ hoặc nói một câu tiếng Nhật',
  );

  static const zh = AppLanguage(
    code: 'zh',
    name: 'tiếng Trung',
    flag: '🇨🇳',
    ttsLocale: 'zh-CN',
    sttLocale: 'zh_CN',
    translateCode: 'zh-CN',
    phoneticLabel: 'Pinyin',
    phoneticHint: 'nǐ hǎo',
    wordHint: 'Gõ hoặc nói một từ tiếng Trung',
    sentenceHint: 'Gõ hoặc nói một câu tiếng Trung',
  );

  static const all = [en, ja, zh];

  static AppLanguage byCode(String code) {
    for (final l in all) {
      if (l.code == code) return l;
    }
    return en;
  }
}
