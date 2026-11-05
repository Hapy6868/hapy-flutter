import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/palette.dart';
import '../../data/data.dart';
import '../../models/models.dart';
import '../../state/state.dart';
import 'dialogs.dart';

/// Chọn / tạo / xoá từ điển của bé đang học (dùng ở tab Từ điển và tab Hồ sơ).
class LexiconFlow {
  static Future<void> choose(BuildContext context) async {
    final session = context.read<AppSession>();
    final repo = context.read<LexiconRepository>();
    final user = session.user;
    if (user == null) return;

    final list = await repo.forUser(user.id!);
    if (!context.mounted) return;

    final pick = await chooseOne<Object>(
      context,
      'Chọn từ điển',
      [...list, 'new'],
      (o) => o is Lexicon ? o.label : '➕ Tạo từ điển mới',
    );
    if (pick == null || !context.mounted) return;
    if (pick is Lexicon) {
      await session.setLexicon(pick);
    } else {
      await create(context);
    }
  }

  /// Tạo từ điển mới: tên → ngôn ngữ (Anh/Nhật/Trung) → loại (Từ/Câu) → biểu tượng.
  static Future<void> create(BuildContext context) async {
    final session = context.read<AppSession>();
    final repo = context.read<LexiconRepository>();
    final user = session.user;
    if (user == null) return;

    final name = await promptText(context, 'Tên từ điển', hint: 'Ví dụ: Động vật, Đồ ăn, Câu chào hỏi');
    if (name == null || !context.mounted) return;

    final lang = await chooseOne<AppLanguage>(
        context, 'Ngôn ngữ của từ điển', AppLanguage.all, (l) => '${l.flag} ${l.title}');
    if (lang == null || !context.mounted) return;

    final kind = await chooseOne<EntryKind>(context, 'Loại nội dung', EntryKind.values,
        (k) => k == EntryKind.word ? '📚 Từ vựng (từng từ)' : '💬 Câu (cả câu)');
    if (kind == null || !context.mounted) return;

    final emoji = await chooseOne<String>(context, 'Chọn biểu tượng', Palette.emojis, (e) => e) ?? '📚';

    final lexicon = await repo.save(
        Lexicon(userId: user.id!, name: name, emoji: emoji, kind: kind, sourceLang: lang.code));
    await session.setLexicon(lexicon);
  }

  static Future<void> deleteCurrent(BuildContext context) async {
    final session = context.read<AppSession>();
    final repo = context.read<LexiconRepository>();
    final user = session.user;
    final current = session.lexicon;
    if (user == null || current == null) return;

    final ok = await confirm(context, 'Xoá từ điển?', 'Xoá "${current.name}" và toàn bộ từ/câu bên trong?');
    if (!ok) return;

    await repo.delete(current.id!);
    final rest = await repo.forUser(user.id!);
    await session.setLexicon(rest.isEmpty ? null : rest.first);
  }
}
