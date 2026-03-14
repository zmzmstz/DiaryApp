import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../main.dart';
import '../../logic/blocs/search_bloc.dart';
import '../../logic/blocs/backlog_bloc.dart';
import '../../models/search_result.dart';
import '../../models/backlog_item.dart';
import 'dart:math';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      context.read<SearchBloc>().add(SearchQueryChanged(query));
    });
  }

  bool _isAlreadyInBacklog(SearchResult result) {
    final state = context.read<BacklogBloc>().state;
    if (state is BacklogLoaded) {
      return state.items.any((item) =>
          item.title.toLowerCase() == result.title.toLowerCase() &&
          item.type == result.type);
    }
    return false;
  }

  void _showAddSheet(SearchResult result) {
    if (_isAlreadyInBacklog(result)) {
      final root = MyApp.rootMessengerKey.currentState;
      root?.clearSnackBars();
      root?.showSnackBar(
        SnackBar(
          content: Text('${result.title} zaten backlog\'da!'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _AddToBacklogSheet(
        result: result,
        onSave: (status, rating, review) {
          final item = BacklogItem(
            id: Random().nextInt(100000).toString(),
            title: result.title,
            type: result.type,
            status: status,
            createdAt: DateTime.now(),
            imageUrl: result.imageUrl,
            rating: rating,
            review: review,
            dateCompleted:
                status == BacklogStatus.completed ? DateTime.now() : null,
          );

          final bloc = context.read<BacklogBloc>();
          bloc.add(AddBacklogItem(item));
          Navigator.pop(sheetContext);
          Navigator.of(context).pop();

          final root = MyApp.rootMessengerKey.currentState;
          root?.clearSnackBars();
          root?.showSnackBar(
            SnackBar(
              content: Text('${result.title} backlog\'a eklendi!'),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              action: SnackBarAction(
                label: 'Geri Al',
                onPressed: () {
                  bloc.add(DeleteBacklogItem(item.id));
                },
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Arama', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Film, dizi veya oyun ara...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<SearchBloc>().add(SearchCleared());
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor:
                    colorScheme.surfaceContainerHighest.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                if (state is SearchInitial) {
                  return _buildEmptyState();
                } else if (state is SearchLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is SearchLoaded) {
                  if (state.results.isEmpty) {
                    return _buildNoResults(state.query);
                  }
                  return _buildResultsList(state.results);
                } else if (state is SearchError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(FontAwesomeIcons.triangleExclamation,
                            size: 48, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text(state.message,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(FontAwesomeIcons.magnifyingGlass,
              size: 56, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Film, dizi veya oyun arayın',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'TMDB, RAWG ve Trakt.tv üzerinden arama yapılır',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults(String query) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(FontAwesomeIcons.faceSadTear,
              size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            '"$query" için sonuç bulunamadı',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(List<SearchResult> results) {
    return BlocBuilder<BacklogBloc, BacklogState>(
      builder: (context, backlogState) {
        final backlogTitles = <String>{};
        if (backlogState is BacklogLoaded) {
          for (final item in backlogState.items) {
            backlogTitles.add('${item.title.toLowerCase()}_${item.type.name}');
          }
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final r = results[index];
            final key = '${r.title.toLowerCase()}_${r.type.name}';
            return _SearchResultCard(
              result: r,
              isAdded: backlogTitles.contains(key),
              onTap: () => _showAddSheet(r),
            );
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Search result card
// ---------------------------------------------------------------------------

class _SearchResultCard extends StatelessWidget {
  final SearchResult result;
  final bool isAdded;
  final VoidCallback onTap;

  const _SearchResultCard({
    required this.result,
    required this.onTap,
    this.isAdded = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _poster(colorScheme),
              const SizedBox(width: 12),
              Expanded(child: _info()),
              isAdded
                  ? const FaIcon(FontAwesomeIcons.circleCheck,
                      color: Colors.green, size: 18)
                  : const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _poster(ColorScheme cs) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 80,
        height: 120,
        child: result.imageUrl != null
            ? CachedNetworkImage(
                imageUrl: result.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: cs.surfaceContainerHighest,
                  child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: cs.surfaceContainerHighest,
                  child: Icon(Icons.broken_image, color: Colors.grey[400]),
                ),
              )
            : Container(
                color: cs.surfaceContainerHighest,
                child: Icon(_iconFor(result.type),
                    color: Colors.grey[400], size: 32),
              ),
      ),
    );
  }

  Widget _info() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(result.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        Row(children: [
          _chip(_labelFor(result.type), _colorFor(result.type)),
          const SizedBox(width: 6),
          _chip(result.source.toUpperCase(), _sourceColor(result.source),
              small: true),
        ]),
        if (result.releaseDate != null && result.releaseDate!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            result.releaseDate!.length >= 4
                ? result.releaseDate!.substring(0, 4)
                : result.releaseDate!,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
        if (result.overview != null && result.overview!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(result.overview!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
        if (result.rating != null && result.rating! > 0) ...[
          const SizedBox(height: 6),
          Row(children: [
            const FaIcon(FontAwesomeIcons.solidStar,
                size: 10, color: Colors.amber),
            const SizedBox(width: 4),
            Text(result.rating!.toStringAsFixed(1),
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ]),
        ],
      ],
    );
  }

  Widget _chip(String text, Color color, {bool small = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: small ? 9 : 10,
              fontWeight: FontWeight.w600,
              color: color)),
    );
  }

  IconData _iconFor(BacklogType t) => switch (t) {
        BacklogType.movie => Icons.movie,
        BacklogType.series => Icons.tv,
        BacklogType.game => Icons.sports_esports,
      BacklogType.song => Icons.music_note,
      BacklogType.book => Icons.menu_book,
      BacklogType.hobby => Icons.category,
        _ => Icons.category,
      };

  Color _colorFor(BacklogType t) => switch (t) {
        BacklogType.movie => Colors.deepPurple,
        BacklogType.series => Colors.indigo,
        BacklogType.game => Colors.redAccent,
      BacklogType.song => Colors.green,
      BacklogType.book => Colors.brown,
      BacklogType.hobby => Colors.blueGrey,
        _ => Colors.grey,
      };

  String _labelFor(BacklogType t) => switch (t) {
        BacklogType.movie => 'Film',
        BacklogType.series => 'Dizi',
        BacklogType.game => 'Oyun',
      BacklogType.song => 'Muzik',
      BacklogType.book => 'Kitap',
      BacklogType.hobby => 'Hobi',
        _ => t.name,
      };

  Color _sourceColor(String s) => switch (s) {
        'tmdb' => Colors.teal,
        'rawg' => Colors.orange,
        'trakt' => Colors.blue,
      'spotify' => Colors.green,
        'open_library' => Colors.brown,
        _ => Colors.grey,
      };
}

// ---------------------------------------------------------------------------
// Bottom sheet for status / rating / review selection
// ---------------------------------------------------------------------------

class _AddToBacklogSheet extends StatefulWidget {
  final SearchResult result;
  final void Function(BacklogStatus status, double? rating, String? review)
      onSave;

  const _AddToBacklogSheet({required this.result, required this.onSave});

  @override
  State<_AddToBacklogSheet> createState() => _AddToBacklogSheetState();
}

class _AddToBacklogSheetState extends State<_AddToBacklogSheet> {
  BacklogStatus _status = BacklogStatus.planned;
  double _rating = 0;
  bool _showRating = false;
  final _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomPadding),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Header: poster + title
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 70,
                    height: 105,
                    child: widget.result.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: widget.result.imageUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Container(
                              color: colorScheme.surfaceContainerHighest,
                              child: const Icon(Icons.broken_image),
                            ),
                          )
                        : Container(
                            color: colorScheme.surfaceContainerHighest,
                            child: const Icon(Icons.image, size: 32),
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.result.title,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Text(
                        _typeLabel(widget.result.type),
                        style: TextStyle(
                            color: Colors.grey[600], fontSize: 13),
                      ),
                      if (widget.result.releaseDate != null &&
                          widget.result.releaseDate!.length >= 4) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.result.releaseDate!.substring(0, 4),
                          style: TextStyle(
                              color: Colors.grey[500], fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Status selection
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Durum',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: colorScheme.onSurface)),
            ),
            const SizedBox(height: 10),
            Row(
              children: BacklogStatus.values.map((s) {
                final selected = _status == s;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                        right: s != BacklogStatus.values.last ? 8 : 0),
                    child: _StatusButton(
                      label: _statusLabel(s),
                      icon: _statusIcon(s),
                      color: _statusColor(s),
                      selected: selected,
                      onTap: () => setState(() => _status = s),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Rating toggle + slider
            Row(
              children: [
                Text('Puan',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: colorScheme.onSurface)),
                const Spacer(),
                Switch(
                  value: _showRating,
                  onChanged: (v) => setState(() => _showRating = v),
                ),
              ],
            ),
            if (_showRating) ...[
              Slider(
                value: _rating,
                min: 0,
                max: 5,
                divisions: 10,
                label: _rating.toStringAsFixed(1),
                onChanged: (v) => setState(() => _rating = v),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FaIcon(FontAwesomeIcons.solidStar,
                      size: 14, color: Colors.amber),
                  const SizedBox(width: 6),
                  Text('${_rating.toStringAsFixed(1)} / 5.0',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
              const SizedBox(height: 8),
            ],

            const SizedBox(height: 8),

            // Review / notes
            TextField(
              controller: _reviewController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Not / Yorum (isteğe bağlı)',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.notes),
              ),
            ),

            const SizedBox(height: 20),

            // Save button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  widget.onSave(
                    _status,
                    _showRating ? _rating : null,
                    _reviewController.text.isNotEmpty
                        ? _reviewController.text
                        : null,
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Backlog\'a Ekle'),
                style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _typeLabel(BacklogType t) => switch (t) {
        BacklogType.movie => 'Film',
        BacklogType.series => 'Dizi',
        BacklogType.game => 'Oyun',
        BacklogType.book => 'Kitap',
        BacklogType.song => 'Müzik',
        BacklogType.hobby => 'Hobi',
      };

  String _statusLabel(BacklogStatus s) => switch (s) {
        BacklogStatus.planned => 'Planned',
        BacklogStatus.inProgress => 'In Progress',
        BacklogStatus.completed => 'Completed',
      };

  IconData _statusIcon(BacklogStatus s) => switch (s) {
        BacklogStatus.planned => FontAwesomeIcons.clock,
        BacklogStatus.inProgress => FontAwesomeIcons.play,
        BacklogStatus.completed => FontAwesomeIcons.circleCheck,
      };

  Color _statusColor(BacklogStatus s) => switch (s) {
        BacklogStatus.planned => Colors.orange,
        BacklogStatus.inProgress => Colors.blue,
        BacklogStatus.completed => Colors.green,
      };
}

class _StatusButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _StatusButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? color.withOpacity(0.15) : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? color : Colors.grey.withOpacity(0.3),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              FaIcon(icon, size: 18, color: selected ? color : Colors.grey),
              const SizedBox(height: 4),
              Text(label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    color: selected ? color : Colors.grey[600],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
