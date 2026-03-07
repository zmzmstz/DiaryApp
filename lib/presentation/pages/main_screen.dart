import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'home_page.dart';
import 'timeline_page.dart';
import 'statistics_page.dart';

class MainScreen extends StatefulWidget {
  final String currentUsername;
  final VoidCallback onLogout;

  const MainScreen({
    super.key,
    required this.currentUsername,
    required this.onLogout,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages = [
    const HomePage(),
    const TimelinePage(),
    const StatisticsPage(),
  ];

  void _showProfileSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final colorScheme = Theme.of(ctx).colorScheme;
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              CircleAvatar(
                radius: 36,
                backgroundColor: colorScheme.primaryContainer,
                child: Text(
                  widget.currentUsername.isNotEmpty
                      ? widget.currentUsername[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer),
                ),
              ),
              const SizedBox(height: 14),
              Text(widget.currentUsername,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    widget.onLogout();
                  },
                  icon: const FaIcon(FontAwesomeIcons.rightFromBracket,
                      size: 16, color: Colors.red),
                  label: const Text('Çıkış Yap',
                      style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          if (index == 3) {
            _showProfileSheet();
            return;
          }
          setState(() => _currentIndex = index);
        },
        destinations: [
          const NavigationDestination(
            icon: FaIcon(FontAwesomeIcons.list),
            label: 'Backlog',
          ),
          const NavigationDestination(
            icon: FaIcon(FontAwesomeIcons.timeline),
            label: 'Timeline',
          ),
          const NavigationDestination(
            icon: FaIcon(FontAwesomeIcons.chartPie),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: CircleAvatar(
              radius: 14,
              backgroundColor:
                  Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                widget.currentUsername.isNotEmpty
                    ? widget.currentUsername[0].toUpperCase()
                    : '?',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context)
                        .colorScheme
                        .onPrimaryContainer),
              ),
            ),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
