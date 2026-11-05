import 'dart:convert';

import 'package:http/http.dart' as http;

import '../data/data.dart';

/// Gửi các bản ghi chưa đồng bộ lên server bằng một yêu cầu POST JSON:
/// { "users": [...], "lexicons": [...], "entries": [...], "notes": [...], "reminders": [...] }
/// Server trả mã 2xx thì các bản ghi đó được đánh dấu đã đồng bộ.
/// Lưu ý: iOS mặc định chỉ cho phép https.
class SyncService {
  SyncService(this._repo, this._client);

  final SyncRepository _repo;
  final http.Client _client;

  Future<String> sync(String url) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || !(uri.isScheme('https') || uri.isScheme('http')) || uri.host.isEmpty) {
      return 'Địa chỉ server không hợp lệ';
    }

    final data = await _repo.unsynced();
    if (data.values.every((rows) => rows.isEmpty)) return 'Không có dữ liệu mới 👍';

    try {
      final r = await _client
          .post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode(data))
          .timeout(const Duration(seconds: 15));
      if (r.statusCode < 200 || r.statusCode >= 300) return 'Server trả lỗi ${r.statusCode}';
      await _repo.markSynced(data);
      return 'Đồng bộ thành công ✅';
    } catch (_) {
      return 'Không kết nối được server';
    }
  }
}
