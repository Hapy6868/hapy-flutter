import 'package:flutter/material.dart';

import 'entries_page.dart';
import 'notes_page.dart';
import 'profile_page.dart';
import 'reminders_page.dart';

/// Khung chính với 4 tab. IndexedStack giữ trạng thái từng tab khi chuyển qua lại.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: const [EntriesPage(), NotesPage(), RemindersPage(), ProfilePage()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Text('📚', style: TextStyle(fontSize: 24)), label: 'Từ điển'),
          NavigationDestination(icon: Text('📒', style: TextStyle(fontSize: 24)), label: 'Nhật ký'),
          NavigationDestination(icon: Text('⏰', style: TextStyle(fontSize: 24)), label: 'Nhắc việc'),
          NavigationDestination(icon: Text('🙂', style: TextStyle(fontSize: 24)), label: 'Hồ sơ'),
        ],
      ),
    );
  }
}
