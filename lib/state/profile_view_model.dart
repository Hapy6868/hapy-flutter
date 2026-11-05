import 'package:flutter/foundation.dart';

import '../data/data.dart';
import '../services/services.dart';

class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel(this._settings, this._sync, this._speech) {
    _loadUrl();
  }

  static const _urlKey = 'sync_url';

  final SettingsRepository _settings;
  final SyncService _sync;
  final SpeechService _speech;

  String syncUrl = '';
  String status = '';
  bool busy = false;

  Future<void> _loadUrl() async {
    syncUrl = await _settings.get(_urlKey) ?? '';
    notifyListeners();
  }

  Future<void> setUrl(String url) async {
    syncUrl = url.trim();
    await _settings.set(_urlKey, syncUrl);
    notifyListeners();
  }

  Future<void> syncNow() async {
    if (syncUrl.isEmpty) {
      status = 'Hãy đặt địa chỉ server trước nhé.';
      notifyListeners();
      return;
    }
    busy = true;
    status = 'Đang đồng bộ... ☁️';
    notifyListeners();
    status = await _sync.sync(syncUrl);
    busy = false;
    notifyListeners();
  }

  Future<void> testVoice() => _speech.speak("Hello! Let's learn English together.");
}
