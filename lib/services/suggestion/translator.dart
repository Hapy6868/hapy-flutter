/// Nguồn dịch nghĩa cho từ hoặc câu.
abstract class Translator {
  Future<String> translate(String text, String from, String to);
}
