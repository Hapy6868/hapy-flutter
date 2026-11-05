import 'package:intl/intl.dart';

final DateFormat _keyFormat = DateFormat('yyyy-MM-dd');

/// Khóa ngày dạng yyyy-MM-dd, dùng để lưu và tìm dữ liệu theo ngày.
String dateKey(DateTime d) => _keyFormat.format(d);

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime parseDateKey(String s) {
  try {
    return _keyFormat.parseStrict(s);
  } catch (_) {
    return dateOnly(DateTime.now());
  }
}
