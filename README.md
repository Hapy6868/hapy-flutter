# 🎈 Hapy (Flutter, bản chia lớp)

Ứng dụng học tập vui cho trẻ em: từ vựng và câu tiếng Anh (phiên âm, nghĩa, đọc thành tiếng, ảnh, emoji), nhật ký học theo ngày, nhắc việc có thông báo. **Nhiều bé dùng chung một máy**, mỗi bé có nhiều từ điển riêng (loại **Từ** hoặc **Câu**), ngôn ngữ **Anh / Nhật / Trung**, nhập bằng **giọng nói**, và **ôn tập tự động**.

- Ngôn ngữ: Dart / Flutter. Chạy trên **iPhone (iOS 15+, gồm iPhone 6s iOS 15.8)** và **Android**.
- Dữ liệu: SQLite (`hapy_v2.db`). Đồng bộ server bằng POST JSON.
- Đây là bản **viết lại có cấu trúc** của bản Flutter đầu tiên (`hapy`, một file `main.dart`). Repo riêng: `hapy-flutter`.

| Cần làm | Xem |
|---|---|
| Từng thư mục/class làm gì, cách nối các lớp, cách tái sử dụng | [`docs/CAU_TRUC.md`](docs/CAU_TRUC.md) |
| Cài công cụ, build `.ipa` bằng GitHub, cài bằng AltStore, Android | [`docs/HUONG_DAN.md`](docs/HUONG_DAN.md) |

Chạy nhanh trên Windows (đã cài Flutter + Git):

```
scripts\setup_project.bat    (tao thu muc ios/android, cau hinh iOS)
scripts\build_ipa.bat        (day len GitHub, build tren may Mac, tai output\hapy.ipa)
```
