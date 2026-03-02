import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'home_page.dart';
import 'timeline_page.dart';
import 'statistics_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    const HomePage(),
    const TimelinePage(),
    const StatisticsPage(),
  ];

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
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: FaIcon(FontAwesomeIcons.list),
            label: 'Backlog',
          ),
          NavigationDestination(
            icon: FaIcon(FontAwesomeIcons.timeline),
            label: 'Timeline',
          ),
          NavigationDestination(
            icon: FaIcon(FontAwesomeIcons.chartPie),
            label: 'Stats',
          ),
        ],
      ),
    );
  }
}
