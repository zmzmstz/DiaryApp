import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../logic/blocs/backlog_bloc.dart';
import '../../models/backlog_item.dart';
import '../widgets/backlog_list_item.dart';
import 'add_edit_item_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final List<String> _tabs = ["All", "Movies", "Series", "Books", "Games", "Music", "Hobbies"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  // Adjust mappings to match BacklogType order: movie, series, song, book, game, hobby
  BacklogType? _getTypeFromIndex(int index) {
    if (index == 0) return null;
    // Map index to BacklogType
    // 1 -> Movies -> BacklogType.movie (index 0)
    // 2 -> Series -> BacklogType.series (index 1)
    // 3 -> Books -> BacklogType.book (index 3) -- Wait, order matters
    // 4 -> Games -> BacklogType.game (index 4)
    // 5 -> Music -> BacklogType.song (index 2)
    // 6 -> Hobbies -> BacklogType.hobby (index 5)
    
    switch (index) {
      case 1: return BacklogType.movie;
      case 2: return BacklogType.series;
      case 3: return BacklogType.book;
      case 4: return BacklogType.game;
      case 5: return BacklogType.song;
      case 6: return BacklogType.hobby;
      default: return null;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Backlog', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _tabs.map((e) => Tab(text: e)).toList(),
          indicatorSize: TabBarIndicatorSize.label,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(_tabs.length, (index) {
          final type = _getTypeFromIndex(index);
          return _buildList(type);
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditItemPage()),
          );
        },
        label: const Text("Add New"),
        icon: const FaIcon(FontAwesomeIcons.plus),
      ),
    );
  }

  Widget _buildList(BacklogType? type) {
    return BlocBuilder<BacklogBloc, BacklogState>(
      builder: (context, state) {
        if (state is BacklogLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is BacklogLoaded) {
          final items = type == null 
              ? state.items 
              : state.items.where((item) => item.type == type).toList();
          
          if (items.isEmpty) {
             return Center(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   FaIcon(FontAwesomeIcons.boxOpen, size: 50, color: Colors.grey[400]),
                   const SizedBox(height: 16),
                   Text("No items here yet!", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                 ],
               ),
             );
          }

          // Sort by creation date desc
          items.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return BacklogListItem(item: item);
            },
          );
        } else if (state is BacklogError) {
          return Center(child: Text("Error: ${state.message}"));
        }
        return const SizedBox.shrink();
      },
    );
  }
}
