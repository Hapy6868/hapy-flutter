class PhoneticResult {
  const PhoneticResult(this.phonetic, this.example, {this.partial = false});

  final String phonetic;
  final String example;

  /// true nếu chỉ tìm được một phần (ví dụ thiếu phiên âm vài từ).
  final bool partial;

  static const empty = PhoneticResult('', '');
}

/// Nguồn phiên âm / cách đọc cho MỘT ngôn ngữ.
/// Mỗi ngôn ngữ có một cài đặt riêng; muốn đổi nguồn chỉ cần viết lớp mới
/// cài đặt giao diện này rồi đăng ký trong app/app_dependencies.dart.
abstract class PhoneticProvider {
  /// Mã ngôn ngữ mà nguồn này phụ trách: 'en', 'ja', 'zh'.
  String get language;

  Future<PhoneticResult> forWord(String word);

  Future<PhoneticResult> forSentence(String sentence);
}
