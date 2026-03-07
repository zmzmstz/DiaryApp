import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../main.dart';
import '../../models/backlog_item.dart';
import '../../logic/blocs/backlog_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class BacklogListItem extends StatelessWidget {
  final BacklogItem item;

  const BacklogListItem({super.key, required this.item});

  void _showEditSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _EditItemSheet(
        item: item,
        onUpdate: (updatedItem) {
          context.read<BacklogBloc>().add(UpdateBacklogItem(updatedItem));
          Navigator.pop(sheetContext);
          final root = MyApp.rootMessengerKey.currentState;
          root?.clearSnackBars();
          root?.showSnackBar(
            SnackBar(
              content: Text('${updatedItem.title} güncellendi!'),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        },
        onDelete: () {
          context.read<BacklogBloc>().add(DeleteBacklogItem(item.id));
          Navigator.pop(sheetContext);
          final root = MyApp.rootMessengerKey.currentState;
          root?.clearSnackBars();
          root?.showSnackBar(
            SnackBar(
              content: Text('${item.title} kaldırıldı!'),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showEditSheet(context),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 56,
                  height: 80,
                  child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: item.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: _getColorForType(item.type).withOpacity(0.1),
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: _getColorForType(item.type).withOpacity(0.1),
                            child: FaIcon(_getIconForType(item.type),
                                color: _getColorForType(item.type), size: 20),
                          ),
                        )
                      : Container(
                          color: _getColorForType(item.type).withOpacity(0.1),
                          child: Center(
                            child: FaIcon(_getIconForType(item.type),
                                color: _getColorForType(item.type), size: 20),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat.yMMMd().format(item.createdAt),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildStatusChip(context, item.status),
                        if (item.rating != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Colors.amber.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const FaIcon(FontAwesomeIcons.solidStar,
                                    size: 10, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text(item.rating.toString(),
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (item.status == BacklogStatus.completed)
                const FaIcon(FontAwesomeIcons.circleCheck,
                    color: Colors.green, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, BacklogStatus status) {
    Color color;
    String text;
    switch (status) {
      case BacklogStatus.completed:
        color = Colors.green;
        text = "Completed";
        break;
      case BacklogStatus.inProgress:
        color = Colors.blue;
        text = "In Progress";
        break;
      case BacklogStatus.planned:
        color = Colors.orange;
        text = "Planned";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Color _getColorForType(BacklogType type) {
    switch (type) {
      case BacklogType.movie:
        return Colors.deepPurple;
      case BacklogType.series:
        return Colors.indigo;
      case BacklogType.song:
        return Colors.pink;
      case BacklogType.book:
        return Colors.brown;
      case BacklogType.game:
        return Colors.redAccent;
      case BacklogType.hobby:
        return Colors.teal;
    }
  }

  IconData _getIconForType(BacklogType type) {
    switch (type) {
      case BacklogType.movie:
        return FontAwesomeIcons.film;
      case BacklogType.series:
        return FontAwesomeIcons.tv;
      case BacklogType.song:
        return FontAwesomeIcons.music;
      case BacklogType.book:
        return FontAwesomeIcons.bookOpen;
      case BacklogType.game:
        return FontAwesomeIcons.gamepad;
      case BacklogType.hobby:
        return FontAwesomeIcons.palette;
    }
  }
}

// ---------------------------------------------------------------------------
// Edit / Delete bottom sheet
// ---------------------------------------------------------------------------

class _EditItemSheet extends StatefulWidget {
  final BacklogItem item;
  final void Function(BacklogItem updatedItem) onUpdate;
  final VoidCallback onDelete;

  const _EditItemSheet({
    required this.item,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<_EditItemSheet> createState() => _EditItemSheetState();
}

class _EditItemSheetState extends State<_EditItemSheet> {
  late BacklogStatus _status;
  late double _rating;
  late bool _showRating;
  late TextEditingController _reviewController;

  @override
  void initState() {
    super.initState();
    _status = widget.item.status;
    _rating = widget.item.rating ?? 0;
    _showRating = widget.item.rating != null;
    _reviewController =
        TextEditingController(text: widget.item.review ?? '');
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _save() {
    final updated = widget.item.copyWith(
      status: _status,
      rating: _showRating ? _rating : null,
      review:
          _reviewController.text.isNotEmpty ? _reviewController.text : null,
      dateCompleted:
          _status == BacklogStatus.completed ? DateTime.now() : null,
    );
    widget.onUpdate(updated);
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
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 70,
                    height: 105,
                    child: widget.item.imageUrl != null &&
                            widget.item.imageUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: widget.item.imageUrl!,
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
                      Text(widget.item.title,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Text(
                        _typeLabel(widget.item.type),
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat.yMMMd().format(widget.item.createdAt),
                        style:
                            TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Status
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

            // Rating
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

            // Review
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
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Kaydet'),
                style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ),

            const SizedBox(height: 10),

            // Delete button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (dialogCtx) => AlertDialog(
                      title: const Text('Kaldır'),
                      content: Text(
                          '"${widget.item.title}" backlog\'dan kaldırılsın mı?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogCtx),
                          child: const Text('İptal'),
                        ),
                        FilledButton(
                          onPressed: () {
                            Navigator.pop(dialogCtx);
                            widget.onDelete();
                          },
                          style: FilledButton.styleFrom(
                              backgroundColor: Colors.red),
                          child: const Text('Kaldır'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const FaIcon(FontAwesomeIcons.trash,
                    size: 16, color: Colors.red),
                label:
                    const Text('Backlog\'dan Kaldır',
                        style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Colors.red),
                ),
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
                    fontWeight:
                        selected ? FontWeight.bold : FontWeight.normal,
                    color: selected ? color : Colors.grey[600],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
