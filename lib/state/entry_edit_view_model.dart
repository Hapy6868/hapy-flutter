import 'package:flutter/material.dart';

import '../core/date_keys.dart';
import '../data/data.dart';
import '../models/models.dart';
import '../services/services.dart';
import 'app_session.dart';

/// Ô nhập có thể dùng giọng nói.
enum VoiceField { text, meaning, example }

/// Nhập / sửa một từ hoặc một câu.
/// Quy ước: autoPhonetic/autoMeaning là GỢI Ý của hệ thống;
/// ô phiên âm/nghĩa là bản cuối cùng do bé hoặc phụ huynh chọn.
class EntryEditViewModel extends ChangeNotifier {
  EntryEditViewModel({
    required this.session,
    required this.entries,
    required this.suggestions,
    required this.speech,
    required this.voice,
    required this.images,
    this.existing,
  }) {
    final e = existing;
    if (e != null) {
      text.text = e.text;
      phonetic.text = e.phonetic;
      meaning.text = e.meaning;
      example.text = e.example;
      autoPhonetic = e.autoPhonetic;
      autoMeaning = e.autoMeaning;
      imageFile = e.image;
      studyDate = parseDateKey(e.studyDate);
    } else {
      studyDate = session.date;
    }
    for (final c in [text, phonetic, meaning, example]) {
      c.addListener(notifyListeners);
    }
  }

  final AppSession session;
  final EntryRepository entries;
  final SuggestionService suggestions;
  final SpeechService speech;
  final VoiceInputService voice;
  final ImageStore images;
  final VocabEntry? existing;

  final text = TextEditingController();
  final phonetic = TextEditingController();
  final meaning = TextEditingController();
  final example = TextEditingController();

  String autoPhonetic = '';
  String autoMeaning = '';
  String imageFile = '';
  String hint = '';
  bool busy = false;
  late DateTime studyDate;

  /// Ô đang nghe giọng nói (null = không nghe).
  VoiceField? listening;

  /// Tự bấm "Gợi ý" sau khi nói xong ở ô nội dung.
  bool autoSuggestAfterVoice = true;

  AppLanguage get lang => session.lexicon?.language ?? AppLanguage.en;
  bool get isWord => session.lexicon?.kind != EntryKind.sentence;
  bool get hasAutoPhonetic => autoPhonetic.isNotEmpty && autoPhonetic != phonetic.text;
  bool get hasAutoMeaning => autoMeaning.isNotEmpty && autoMeaning != meaning.text;

  void setDate(DateTime d) {
    studyDate = dateOnly(d);
    notifyListeners();
  }

  void usePhonetic() {
    phonetic.text = autoPhonetic;
  }

  void useMeaning() {
    meaning.text = autoMeaning;
  }

  void removeImage() {
    imageFile = '';
    notifyListeners();
  }

  void setAutoSuggestAfterVoice(bool v) {
    autoSuggestAfterVoice = v;
    notifyListeners();
  }

  Future<void> speakText() => speech.speak(text.text, locale: lang.ttsLocale);

  Future<void> pickImage() async {
    try {
      final name = await images.pick();
      if (name != null) {
        imageFile = name;
        notifyListeners();
      }
    } catch (_) {
      hint = 'Không mở được thư viện ảnh. Hãy cho phép truy cập ảnh trong Cài đặt.';
      notifyListeners();
    }
  }

  // ───── Nhập bằng giọng nói ─────

  /// Bấm lần đầu: bắt đầu nghe. Bấm lần nữa (hoặc bấm ô khác): dừng.
  /// Ô nội dung và ví dụ nghe theo ngôn ngữ của từ điển; ô nghĩa nghe tiếng Việt.
  Future<void> toggleVoice(VoiceField field) async {
    final current = listening;
    if (current != null) {
      await voice.stop();
      listening = null;
      notifyListeners();
      if (current == field) return;
    }

    final controller = switch (field) {
      VoiceField.text => text,
      VoiceField.meaning => meaning,
      VoiceField.example => example,
    };
    final locale = field == VoiceField.meaning ? 'vi_VN' : lang.sttLocale;

    // Ô nội dung được thay mới; ô nghĩa/ví dụ nói thêm vào phía sau.
    final base = (field == VoiceField.text || controller.text.trim().isEmpty) ? '' : '${controller.text.trim()} ';

    final error = await voice.start(
      locale: locale,
      onWords: (words, isFinal) {
        controller.text = base + words;
        controller.selection = TextSelection.collapsed(offset: controller.text.length);
        if (isFinal && field == VoiceField.text && autoSuggestAfterVoice && words.trim().isNotEmpty) {
          suggest();
        }
      },
      onDone: () {
        if (listening == field) {
          listening = null;
          notifyListeners();
        }
      },
    );

    if (error != null) {
      hint = error;
    } else {
      listening = field;
      hint = 'Đang nghe... 🎤 Hãy nói rõ từng từ nhé!';
    }
    notifyListeners();
  }

  // ───── Gợi ý phiên âm / nghĩa ─────

  Future<void> suggest() async {
    final user = session.user;
    final lex = session.lexicon;
    if (user == null || lex == null) return;

    final t = text.text.trim();
    if (t.isEmpty) {
      hint = 'Hãy gõ hoặc nói nội dung trước nhé! ✏️';
      notifyListeners();
      return;
    }

    busy = true;
    hint = 'Đang tìm gợi ý... 🔍';
    notifyListeners();
    try {
      final mine = await entries.findUserEntry(user.id!, t, exceptId: existing?.id);
      final s = await suggestions.suggest(t, lex.kind, lex.sourceLang, lex.targetLang);

      autoPhonetic = s.phonetic;
      autoMeaning = s.meaning;

      // Chỉ điền vào ô còn trống: không ghi đè nội dung bé/phụ huynh đã nhập.
      final minePhonetic = mine?.phonetic ?? '';
      final mineMeaning = mine?.meaning ?? '';
      if (phonetic.text.isEmpty) phonetic.text = minePhonetic.isNotEmpty ? minePhonetic : s.phonetic;
      if (meaning.text.isEmpty) meaning.text = mineMeaning.isNotEmpty ? mineMeaning : s.meaning;
      if (example.text.isEmpty) example.text = s.example;

      if (mine != null) {
        hint = 'Đã dùng nghĩa bé từng lưu ✅ Bấm "Dùng" để đổi sang gợi ý mới.';
      } else if (s.phonetic.isEmpty && s.meaning.isEmpty) {
        hint = 'Chưa tìm được gợi ý. Hãy kiểm tra mạng hoặc nhập tay nhé.';
      } else if (s.phonetic.isEmpty && lex.sourceLang == 'ja' && lex.kind == EntryKind.sentence) {
        hint = 'Đã có nghĩa. Câu tiếng Nhật có chữ Hán chưa tự tạo được cách đọc, hãy nhập tay nhé.';
      } else if (s.partial) {
        hint = 'Chỉ tìm được một phần. Hãy kiểm tra và sửa lại cho đúng nhé.';
      } else {
        hint = 'Đã có gợi ý! Bé hoặc phụ huynh có thể sửa lại cho phù hợp ✏️';
      }
    } catch (_) {
      hint = 'Không có mạng hoặc dịch vụ bận. Hãy nhập tay nhé.';
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  /// Trả về true nếu đã lưu.
  Future<bool> save() async {
    final user = session.user;
    final lex = session.lexicon;
    if (user == null || lex == null) return false;
    if (text.text.trim().isEmpty) {
      hint = 'Hãy nhập nội dung trước khi lưu nhé! ✏️';
      notifyListeners();
      return false;
    }

    final e = existing ??
        VocabEntry(lexiconId: lex.id!, userId: user.id!, text: '', studyDate: dateKey(studyDate));
    e.lexiconId = lex.id!;
    e.userId = user.id!;
    e.text = text.text.trim();
    e.phonetic = phonetic.text.trim();
    e.meaning = meaning.text.trim();
    e.example = example.text.trim();
    e.autoPhonetic = autoPhonetic.trim();
    e.autoMeaning = autoMeaning.trim();
    e.phoneticEdited = e.phonetic.isNotEmpty && e.phonetic != e.autoPhonetic;
    e.meaningEdited = e.meaning.isNotEmpty && e.meaning != e.autoMeaning;
    e.image = imageFile;
    e.studyDate = dateKey(studyDate);
    await entries.save(e);
    return true;
  }

  Future<void> deleteExisting() async {
    final id = existing?.id;
    if (id != null) await entries.delete(id);
  }

  @override
  void dispose() {
    voice.stop();
    text.dispose();
    phonetic.dispose();
    meaning.dispose();
    example.dispose();
    super.dispose();
  }
}
