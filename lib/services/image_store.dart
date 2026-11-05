import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Chọn ảnh từ thư viện và sao chép vào thư mục của app.
/// CSDL chỉ lưu TÊN file (đường dẫn trên iOS thay đổi khi cài lại app).
class ImageStore {
  late final String _dir;

  Future<void> init() async => _dir = (await getApplicationDocumentsDirectory()).path;

  Future<String?> pick() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1024, imageQuality: 80);
    if (x == null) return null;
    final name = '${DateTime.now().millisecondsSinceEpoch}${p.extension(x.path)}';
    await File(x.path).copy(p.join(_dir, name));
    return name;
  }

  File? fileOf(String? name) {
    if (name == null || name.isEmpty) return null;
    final f = File(p.join(_dir, name));
    return f.existsSync() ? f : null;
  }
}
