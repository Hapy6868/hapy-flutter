# Cấu trúc Hapy (Flutter) – mỗi lớp, mỗi class làm gì

## 0. Tính năng chính (bản 2.1)

- **Nhiều bé**, mỗi bé nhiều từ điển. Mỗi từ điển có **ngôn ngữ** (🇺🇸 Tiếng Anh / 🇯🇵 Tiếng Nhật / 🇨🇳 Tiếng Trung) và **loại** (Từ / Câu).
- **Nhập bằng giọng nói** (Speech-to-Text): nói để nhập từ/câu, nói nghĩa tiếng Việt, nói câu ví dụ. Nghe theo đúng ngôn ngữ của từ điển.
- **Gợi ý theo ngôn ngữ:** Anh → IPA; Nhật → kana + romaji; Trung → pinyin có dấu. Kèm dịch nghĩa tiếng Việt.
- **Ôn tập tự động:** app tự chọn từ/câu, tự phát âm, hiện nghĩa theo cho phép của người dùng, có chế độ tự chạy.

## 1. Sơ đồ thư mục

```
hapy-flutter/                      ← THƯ MỤC GỐC = 1 repo Git riêng (GitHub: hapy-flutter)
├── pubspec.yaml                   Khai báo gói thư viện
├── lib/
│   ├── main.dart                  Chỉ khởi động: tạo AppDependencies rồi chạy HapyApp
│   │
│   ├── app/                       ★ NƠI NỐI CÁC LỚP VỚI NHAU
│   │   ├── app_dependencies.dart    Tạo + nối mọi đối tượng (DB, repository, dịch vụ, session)
│   │   └── hapy_app.dart            MaterialApp, đăng ký Provider, cổng "chưa chọn bé → chọn bé"
│   │
│   ├── core/                      Tiện ích dùng chung
│   │   ├── date_keys.dart           Đổi ngày ⇄ chuỗi yyyy-MM-dd
│   │   └── palette.dart             Màu sắc, emoji
│   │
│   ├── models/                    ★ LỚP DỮ LIỆU (Dart thuần, không phụ thuộc Flutter)
│   │   ├── app_user.dart            Bé
│   │   ├── lexicon.dart             Từ điển của một bé (loại Từ/Câu, cặp ngôn ngữ)
│   │   ├── vocab_entry.dart         Một từ hoặc một câu (có gợi ý gốc + bản đã chỉnh)
│   │   ├── study_note.dart          Ghi chú học trong ngày
│   │   ├── reminder.dart            Nhắc việc
│   │   ├── enums.dart               EntryKind (word/sentence), RepeatKind (once/daily/weekly)
│   │   ├── language.dart            AppLanguage: en/ja/zh (giọng đọc, giọng nghe, nhãn phiên âm, gợi ý nhập)
│   │   ├── review.dart              Cấu hình ôn tập (ReviewConfig) và thẻ ôn (ReviewCard)
│   │   └── models.dart              Cổng chung: import 1 file là có đủ model
│   │
│   ├── data/                      ★ LỚP LƯU TRỮ (SQLite)
│   │   ├── app_database.dart        Mở DB, tạo bảng, hàm save() dùng chung
│   │   ├── repositories/            Mỗi bảng một repository: user, lexicon, entry, note,
│   │   │                            reminder, settings, sync
│   │   └── data.dart                Cổng chung
│   │
│   ├── services/                  ★ LỚP DỊCH VỤ (việc ngoài CSDL: mạng, loa, ảnh, thông báo)
│   │   ├── suggestion/              Gợi ý phiên âm + nghĩa (mỗi ngôn ngữ một nguồn)
│   │   │   ├── phonetic_provider.dart     Giao diện nguồn phiên âm (language, forWord, forSentence)
│   │   │   ├── dictionary_api_provider.dart  Tiếng Anh: IPA từ dictionaryapi.dev (câu: ghép từng từ)
│   │   │   ├── jisho_provider.dart        Tiếng Nhật: cách đọc từ jisho.org
│   │   │   ├── kana_romaji.dart           Kana → romaji, chạy offline
│   │   │   ├── pinyin_provider.dart       Tiếng Trung: pinyin có dấu, chạy offline
│   │   │   ├── translator.dart            Giao diện nguồn dịch
│   │   │   ├── mymemory_translator.dart   Cài đặt bằng MyMemory
│   │   │   └── suggestion_service.dart    Gộp lại: gợi ý cho TỪ và cho CÂU
│   │   ├── speech_service.dart      Đọc to (Text-to-Speech), chọn giọng theo ngôn ngữ
│   │   ├── voice_input_service.dart Nhập bằng giọng nói (Speech-to-Text)
│   │   ├── review_planner.dart      Tự động chọn từ để ôn (thuật toán chấm điểm ưu tiên)
│   │   ├── image_store.dart         Chọn ảnh, lưu vào bộ nhớ app
│   │   ├── reminder_scheduler.dart  Đặt/huỷ thông báo (giao diện + bản cài đặt)
│   │   └── sync_service.dart        Gửi dữ liệu chưa đồng bộ lên server
│   │
│   ├── state/                     ★ LỚP LOGIC MÀN HÌNH (ViewModel, ChangeNotifier)
│   │   ├── app_session.dart         Bé đang học, từ điển đang chọn, ngày đang xem
│   │   └── *_view_model.dart        Mỗi màn hình một ViewModel
│   │
│   └── ui/                        ★ LỚP GIAO DIỆN (chỉ vẽ + chuyển thao tác cho ViewModel)
│       ├── pages/                   user_picker, home_shell (4 tab), entries, entry_edit,
│       │                            notes, reminders, reminder_edit, profile,
│       │                            review_setup, review_session
│       └── widgets/                 dialogs, emoji_picker, thumb, date_button, lexicon_flow...
│
├── test/suggestion_test.dart      Kiểm thử không cần điện thoại/Internet
├── .github/workflows/             ★ NƠI KẾT NỐI GITHUB
│   ├── ci.yml                       Tự chạy mỗi lần push: flutter analyze + flutter test
│   └── build-ios.yml                Chạy tay/bằng script: build iOS trên máy Mac → hapy.ipa chưa ký
├── scripts/                       Tiện ích cho Windows
│   ├── setup_project.bat            flutter create + khôi phục code Hapy + cấu hình iOS
│   ├── patch_ios.ps1               (được setup_project.bat gọi) sửa Info.plist, AppDelegate.swift
│   └── build_ipa.bat                Đẩy code → chạy build-ios → tải output\hapy.ipa
└── docs/                          Tài liệu
```
(Thư mục `ios/` và `android/` được sinh ra bởi `scripts\setup_project.bat`, không nằm trong zip.)

## 2. Quy tắc phụ thuộc (để dùng chung, thay thế dễ)

```
ui  ──►  state  ──►  data / services  ──►  models
 │                        ▲
 └──────── app (nối dây) ─┘
```

| Lớp | Được dùng | KHÔNG được dùng |
|---|---|---|
| `models` | Dart thuần | Flutter, SQLite, mạng |
| `data` | `models`, sqflite | `ui`, `state`, `services` |
| `services` | `models` (và `data` riêng sync_service) | `ui`, `state` |
| `state` | `data`, `services`, `models` | `ui` (không biết widget nào) |
| `ui` | `state`, widget Flutter | Truy cập SQLite hay mạng trực tiếp |

**Mỗi dịch vụ có "giao diện" (abstract class) tách khỏi "cài đặt":**

| Giao diện | Cài đặt hiện tại | Thay bằng |
|---|---|---|
| `PhoneticProvider` | `DictionaryApiProvider` (en), `JishoProvider` (ja), `PinyinProvider` (zh) | từ điển offline, server riêng, **thêm ngôn ngữ mới** |
| `Translator` | `MyMemoryTranslator` | Google/DeepL/server của bạn |
| `SuggestionService` | `OnlineSuggestionService` | bản chạy hoàn toàn offline |
| `ReminderScheduler` | `LocalReminderScheduler` | cơ chế thông báo khác |

Đổi cài đặt = sửa **một dòng** trong `app/app_dependencies.dart`. Giao diện và ViewModel không phải đổi.

## 3. Kết nối dùng chung (tái sử dụng)

- Các lớp `models` + `data` + `services` không phụ thuộc giao diện, nên sau này có thể **tách thành một package Dart riêng** (ví dụ `packages/hapy_core/`), rồi dùng chung cho app khác (app phụ huynh, server Dart…): chuyển 3 thư mục đó và `core/date_keys.dart`, thêm vào `pubspec.yaml` của app dạng `hapy_core: { path: packages/hapy_core }`.
- Mọi thư mục có **file cổng** (`models.dart`, `data.dart`, `services.dart`, `state.dart`) để bên ngoài chỉ cần `import` một file.
- Định dạng đồng bộ cố định: `POST` JSON `{ "users": [...], "lexicons": [...], "entries": [...], "notes": [...], "reminders": [...] }`, mỗi phần tử là một hàng của bảng cùng tên (xem `lib/data/app_database.dart`). Server nào nhận đúng định dạng này đều dùng được.

## 4. Mô hình dữ liệu (nhiều bé, mỗi bé nhiều từ điển)

```
AppUser (bé)  1 ──── n  Lexicon (từ điển: tên, emoji, loại Từ/Câu, en→vi)
     │                       └── 1 ──── n  VocabEntry (từ/câu: text, phonetic, meaning, example, ảnh, ngày,
     │                                                  autoPhonetic, autoMeaning, meaningEdited)
     ├── 1 ──── n  StudyNote
     └── 1 ──── n  Reminder
```
- Tạo bé mới → tự có 2 từ điển: **"Từ vựng của bé" (Từ)** và **"Câu giao tiếp" (Câu)**; có thể tạo thêm theo chủ đề.
- Ảnh lưu thành file trong bộ nhớ app; CSDL chỉ lưu **tên file**.
- Mọi bảng có cột `synced` (0 = chưa gửi lên server).

## 5. Cách gợi ý phiên âm và nghĩa

1. **Từ:** phiên âm + câu ví dụ từ dictionaryapi.dev; nghĩa tiếng Việt từ MyMemory.
2. **Câu:** phiên âm **ghép** từ phiên âm từng từ (tối đa 20 từ); nghĩa dịch cả câu. Từ không tra được giữ nguyên chữ và đánh dấu "chỉ một phần".
3. Gợi ý gốc hiện ở dòng **💡 Gợi ý** dưới ô nhập, kèm nút **Dùng**. Ô nhập **chỉ được tự điền khi còn trống**, không ghi đè chữ bé/phụ huynh đã nhập.
4. Nếu chính bé đó **đã từng lưu nghĩa** cho cùng từ/câu, app dùng nghĩa đã lưu trước.
5. Khi lưu, nghĩa khác gợi ý gốc → đánh dấu **✏️ Nghĩa do bé / phụ huynh chỉnh**.

Nghĩa tiếng Việt là dịch tự động, cần người lớn kiểm tra. Hai nguồn miễn phí có giới hạn lượt dùng/ngày và cần Internet.

## 5b. Mỗi loại từ điển hỗ trợ nhập gì

| | 🇺🇸 Tiếng Anh | 🇯🇵 Tiếng Nhật | 🇨🇳 Tiếng Trung |
|---|---|---|---|
| Giọng đọc (TTS) | en-US | ja-JP | zh-CN |
| Nói để nhập (STT) | en_US | ja_JP | zh_CN |
| Phiên âm / cách đọc | IPA (dictionaryapi.dev, cần mạng) | kana • romaji (Jisho cần mạng cho chữ Hán; kana tự đổi offline) | pinyin có dấu (offline) |
| Câu | ghép phiên âm từng từ | chỉ tự tạo khi câu toàn kana; câu có chữ Hán nhập tay | pinyin cả câu |
| Dịch sang tiếng Việt | MyMemory (cần mạng) | MyMemory | MyMemory |

Ô **nghĩa tiếng Việt** luôn nghe bằng tiếng Việt (vi_VN). Ngôn ngữ chọn lúc **tạo từ điển** và lưu trong cột `lexicons.source_lang`.

**Thêm ngôn ngữ mới** (ví dụ tiếng Hàn): (1) thêm một hằng `AppLanguage` trong `models/language.dart`; (2) viết một `PhoneticProvider` mới; (3) thêm nó vào danh sách trong `app/app_dependencies.dart`.

## 5c. Ôn tập tự động

Vào tab **Từ điển → biểu tượng 🎓 Ôn tập**. Chọn:
- **Lấy từ ở đâu:** từ điển đang chọn hoặc tất cả từ điển của bé; **trong khoảng:** hôm nay / 7 ngày / tất cả.
- **Số thẻ:** 5 / 10 / 20 / 30; **ưu tiên:** 🎲 Tự động, 😕 Từ khó nhớ, 🆕 Mới thêm.
- **Phát âm tự động**, **hiện phiên âm**, **nghĩa:** 🙈 chạm mới xem / ⏱ tự hiện sau 3 giây / 👁 luôn hiện.
- **Chế độ tự chạy:** tự đọc → (tự hiện nghĩa nếu cho phép) → tự sang thẻ tiếp; có nút tạm dừng.

Thuật toán chọn (`services/review_planner.dart`): thẻ chưa ôn lần nào +3, thẻ đang "khó" +4 (hoặc +20 nếu chọn ưu tiên từ khó), lâu chưa ôn tối đa +3, mới thêm tối đa +10 (nếu chọn ưu tiên mới), cộng chút ngẫu nhiên. Bấm **😀 Đã nhớ** thì bỏ nhãn "khó"; **😕 Chưa nhớ** thì gắn nhãn "khó". Cuối buổi có thể **ôn lại riêng các thẻ chưa nhớ**. Chế độ tự chạy **không** ghi nhớ/chưa nhớ (chỉ để nghe và xem).

CSDL thêm 3 cột cho bảng `entries`: `review_count`, `last_reviewed`, `hard` (phiên bản DB 2, tự nâng cấp từ bản 1).

## 6. GitHub nối ở đâu

| Thành phần | Vị trí | Vai trò |
|---|---|---|
| Kho mã | Thư mục gốc `hapy-flutter/` (có thư mục ẩn `.git`) | Toàn bộ mã nguồn |
| Địa chỉ từ xa | `origin` → `https://github.com/<tên-bạn>/hapy-flutter` | `scripts\build_ipa.bat` tự tạo bằng `gh repo create` |
| Tự động hóa | `.github/workflows/*.yml` | GitHub đọc để chạy test/build |
| Kết quả build | Tab **Actions → Artifacts** (`hapy-ipa`) | File cài vào iPhone |

| | Flutter v1 | **Flutter v2 (repo này)** | MAUI |
|---|---|---|---|
| Thư mục / repo | `hapy` | `hapy-flutter` | `hapy-maui` |
| Dữ liệu trên máy | `hapy.db` | `hapy_v2.db` | `hapy.db3` |

Flutter v1 và v2 dùng **cùng ID app** (`com.hapy.hapy`) nên cài v2 sẽ **thay thế** v1 trên iPhone (dữ liệu v1 vẫn nằm trong file cũ, v2 không đọc). Nếu muốn cài song song, đổi `--org` khi chạy `flutter create` (xem hướng dẫn).

## 7. Muốn thêm tính năng thì sửa ở đâu?

| Việc | Sửa |
|---|---|
| Thêm cột/bảng | `models/*.dart` + `data/app_database.dart` (tăng `version`, thêm `onUpgrade`) + repository |
| Thêm màn hình | `ui/pages/xxx_page.dart` + `state/xxx_view_model.dart` (+ đăng ký repository ở `app/hapy_app.dart` nếu có) |
| Đổi nguồn gợi ý | viết lớp mới cài `PhoneticProvider`/`Translator`, đổi 1 dòng ở `app_dependencies.dart` |
| Đổi màu | `core/palette.dart` |
| Đổi bước build | `.github/workflows/*.yml` |
