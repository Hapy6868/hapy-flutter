import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Nhập bằng giọng nói (Speech-to-Text) bằng bộ nhận dạng của hệ điều hành.
/// Cần quyền micro + nhận dạng giọng nói; một số ngôn ngữ cần Internet.
class VoiceInputService {
  final stt.SpeechToText _stt = stt.SpeechToText();

  bool _initialized = false;
  bool _available = false;
  void Function()? _onDone;

  bool get isListening => _stt.isListening;

  Future<bool> _ensureReady() async {
    if (_initialized) return _available;
    _available = await _stt.initialize(
      onStatus: (s) {
        if (s == 'done' || s == 'notListening') _onDone?.call();
      },
      onError: (_) => _onDone?.call(),
    );
    _initialized = true;
    return _available;
  }

  /// Bắt đầu nghe. Trả về null nếu thành công, hoặc thông báo lỗi tiếng Việt.
  /// [locale] ví dụ ja_JP; [onWords] được gọi liên tục với chữ nhận được.
  Future<String?> start({
    required String locale,
    required void Function(String words, bool isFinal) onWords,
    required void Function() onDone,
  }) async {
    if (!await _ensureReady()) {
      return 'Chưa cấp quyền micro / nhận dạng giọng nói. Vào Cài đặt → Hapy để bật nhé.';
    }
    final id = await _resolveLocale(locale);
    if (id == null) {
      return 'Máy chưa có gói nhận dạng giọng nói cho ngôn ngữ này. Hãy thử nhập bằng bàn phím.';
    }
    _onDone = onDone;
    await _stt.listen(
      onResult: (r) => onWords(r.recognizedWords, r.finalResult),
      localeId: id,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
    );
    return null;
  }

  Future<void> stop() async {
    _onDone = null;
    if (_stt.isListening) await _stt.stop();
  }

  /// Tìm mã ngôn ngữ mà máy thực sự hỗ trợ (ja_JP / ja-JP đều được).
  Future<String?> _resolveLocale(String wanted) async {
    String norm(String s) => s.replaceAll('-', '_').toLowerCase();
    final w = norm(wanted);
    final lang = w.split('_').first;
    final locales = await _stt.locales();
    for (final l in locales) {
      if (norm(l.localeId) == w) return l.localeId;
    }
    for (final l in locales) {
      final n = norm(l.localeId);
      if (n == lang || n.startsWith('${lang}_')) return l.localeId;
    }
    return null;
  }
}
