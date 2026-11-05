# Hướng dẫn cài đặt và đưa Hapy vào iPhone / Android (Windows)

> ⚠️ Mã nguồn này **chưa được biên dịch thử** (nơi tạo ra không có Flutter). Hãy coi lần chạy đầu là bước kiểm tra, gặp lỗi thì gửi nguyên dòng lỗi để sửa. `ci.yml` chạy `flutter analyze` + `flutter test` trên máy Linux để bắt lỗi sớm trước khi tốn thời gian máy Mac.

## 0. Chuẩn bị

1. Cài **Flutter SDK** và **Git** (đã làm ở bản trước; kiểm tra `flutter --version`). Thêm `...\flutter\bin` vào biến **Path** (không phải tạo biến mới tên `flutter`).
2. Giải nén `hapy-flutter.zip` vào thư mục mới (ví dụ `C:\dev\hapy-flutter`). **Không** trộn với thư mục `hapy` cũ.

## 1. Tạo thư mục ios/android và cấu hình iOS (1 lần)

Bấm đúp **`scripts\setup_project.bat`**. File này:
- sao lưu code Hapy, chạy `flutter create --org com.hapy --project-name hapy --platforms=ios,android .`, rồi khôi phục code Hapy;
- chạy `flutter pub get`;
- tự cấu hình iOS: quyền chọn ảnh, tên hiển thị `Hapy`, thông báo trong `AppDelegate.swift`.

Muốn cài **song song** với bản v1 trên iPhone: sửa `--org com.hapy` thành `--org com.hapy2` trong `scripts\setup_project.bat` trước khi chạy.

## 2. Build `hapy.ipa`

Bấm đúp **`scripts\build_ipa.bat`**. Lần đầu nó sẽ mở trình duyệt để đăng nhập GitHub, tạo repo riêng tư **hapy-flutter**, đẩy code, chạy build trên máy Mac của GitHub (khoảng 10–15 phút), rồi tải `output\hapy.ipa`.

Nếu báo "không lấy được máy macOS", chạy lại sau ít phút (lỗi hạ tầng GitHub). Nếu workflow `ci.yml` đỏ, mở tab **Actions**, vào bước bị đỏ, chép dòng lỗi gửi lại.

## 3. Cài vào iPhone 6s (iOS 15.8)

Dùng **AltStore** (đã cài được): *My Apps → dấu + → chọn `hapy.ipa`*. Hoặc kéo thả vào Sideloadly. iOS 15.8 không có Developer Mode, bỏ qua bước đó. Mở app, cho phép **Thông báo** và **Ảnh**; muốn nghe đọc thì tắt chế độ im lặng.

Apple ID miễn phí chỉ cho tối đa 3 app: AltStore chiếm 1 chỗ. Nếu app v1 cùng ID thì v2 cài đè lên v1.

## 3b. Quyền cần cấp trên iPhone

Lần đầu bấm 🎤 app sẽ hỏi **Micro** và **Nhận dạng giọng nói**: chọn **Cho phép**. Nếu lỡ từ chối: Cài đặt → Hapy → bật lại.
- Nhận dạng giọng nói tiếng **Nhật/Trung** thường cần **Internet**.
- Nghe (đọc to) tiếng Nhật/Trung: nếu máy chưa có giọng, vào Cài đặt → Trợ năng → Nội dung được đọc → Giọng nói để tải.
- `scripts\patch_ios.ps1` tự thêm các mô tả quyền (`NSMicrophoneUsageDescription`, `NSSpeechRecognitionUsageDescription`) vào Info.plist khi chạy `setup_project.bat`. Nếu bạn đã chạy `setup_project.bat` từ trước, hãy chạy lại file này (an toàn, không làm hỏng gì).

## 4. Android (tùy chọn)

Cần Android Studio + SDK, bật Gỡ lỗi USB. Sau `setup_project.bat`, sửa `android\app\build.gradle` và `AndroidManifest.xml` theo hướng dẫn của bản v1 (desugaring, quyền thông báo, `queries` cho TTS), và thêm cho giọng nói vào `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.INTERNET"/>
<queries>
  <intent><action android:name="android.speech.RecognitionService"/></intent>
</queries>
```
rồi:
```
flutter run --release
flutter build apk --release
```

## 5. Cách dùng

1. Mở app → **"Ai đang học nào?"** → **Thêm bé** (tên + hình đại diện) → chạm vào thẻ của bé.
2. Tab **📚 Từ điển**: đang hiện từ điển nào thì thêm vào đó. **🔄 Đổi** để chọn từ điển khác hoặc tạo mới (**Từ** hoặc **Câu**).
3. **Thêm từ/câu** → gõ **hoặc bấm 🎤 để nói** → **💡 Gợi ý** (tự chạy sau khi nói xong nếu bật ô "Tự gợi ý sau khi nói") (hoặc bấm Search trên bàn phím) → xem phiên âm, nghĩa, sửa tự do, bấm **Dùng** nếu muốn lấy lại gợi ý gốc → **Lưu**.
   - Tạo từ điển **tiếng Nhật / tiếng Trung**: tab Từ điển → 🔄 Đổi → ➕ Tạo từ điển mới → chọn **ngôn ngữ**. Phiên âm: Nhật = kana • romaji, Trung = pinyin, Anh = IPA.
   - 🎤 cạnh ô **Nghĩa** cho phép đọc nghĩa tiếng Việt thay vì gõ; 🎤 cạnh **Câu ví dụ** nói theo ngôn ngữ của từ điển.
4. **Ôn tập:** tab Từ điển → biểu tượng 🎓 → chọn nguồn, số thẻ, ưu tiên, phát âm tự động, cách hiện nghĩa (chạm / tự hiện / luôn hiện), chế độ tự chạy → **Bắt đầu ôn tập**. Chấm **😀 Đã nhớ / 😕 Chưa nhớ**; cuối buổi ôn lại riêng các thẻ chưa nhớ.
4b. Tab **📒 Nhật ký**: chọn ngày ở góc trên, ghi lại nội dung học.
5. Tab **⏰ Nhắc việc**: tạo nhắc một lần / hằng ngày / hằng tuần, bật tắt chuông 🔔/🔕.
6. Tab **🙂 Hồ sơ**: đổi bé, quản lý từ điển, đặt địa chỉ server và **Đồng bộ ngay**, thử giọng đọc.

## 6. Lỗi thường gặp

| Hiện tượng | Cách xử lý |
|---|---|
| `where flutter` không thấy | Thêm `...\flutter\bin` vào biến **Path** (xem hướng dẫn trước), mở CMD mới |
| `flutter analyze` báo lỗi ở CI | Chép dòng lỗi gửi lại; thường chỉ cần sửa 1–2 chỗ |
| Build iOS lỗi pod/phiên bản | Gửi log lỗi để chỉnh phiên bản thư viện |
| Build iOS báo `requires a development team` / `Signing for ...` dù đã `--no-codesign` | Flutter mới bật Swift Package Manager, gói có resource bundle (như `speech_to_text`) đòi ký. Workflow đã có bước `flutter config --no-enable-swift-package-manager` để dùng CocoaPods; nếu bạn dùng file workflow cũ thì thay bằng bản mới |
| Không có thông báo | Cài đặt → Thông báo → Hapy → bật |
| "Chưa tìm được gợi ý" | Kiểm tra mạng; hết lượt MyMemory trong ngày thì nhập tay |
| Server `http://` bị chặn trên iPhone | Dùng `https://` |
| App hết hạn sau 7 ngày | Để AltServer tự gia hạn |

## 7. Chưa có (để sau)

- Server nhận đồng bộ (định dạng JSON đã cố định, xem `docs/CAU_TRUC.md`).
- Ghi chú nhật ký chưa chèn được ảnh; chưa có trò chơi ôn từ dạng câu hỏi trắc nghiệm.
- Tiếng Nhật: câu có chữ Hán chưa tự tạo được cách đọc (cần bộ tách từ); hãy nhập tay.
- Chưa tự nhập chữ Hán/Trung bằng bàn phím riêng: dùng bàn phím của iPhone (thêm bàn phím tiếng Nhật/Trung trong Cài đặt → Cài đặt chung → Bàn phím).
- Chưa nhập lại dữ liệu từ bản v1 (nếu cần, có thể viết một bộ nhập một lần).
