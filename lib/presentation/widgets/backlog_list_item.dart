import 'package:flutter/material.dart';
import '../../models/backlog_item.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class BacklogListItem extends StatelessWidget {
  final BacklogItem item;

  const BacklogListItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Show details or edit
          // For now just show snackbar
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: _getColorForType(item.type).withOpacity(0.1),
                radius: 24,
                child: FaIcon(_getIconForType(item.type), color: _getColorForType(item.type), size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                        "${DateFormat.yMMMd().format(item.createdAt)}",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildStatusChip(context, item.status),
                        if (item.rating != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const FaIcon(FontAwesomeIcons.solidStar, size: 10, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text(item.rating.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (item.status == BacklogStatus.completed)
                const FaIcon(FontAwesomeIcons.circleCheck, color: Colors.green, size: 16),
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
      child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Color _getColorForType(BacklogType type) {
    switch (type) {
      case BacklogType.movie: return Colors.deepPurple;
      case BacklogType.series: return Colors.indigo;
      case BacklogType.song: return Colors.pink;
      case BacklogType.book: return Colors.brown;
      case BacklogType.game: return Colors.redAccent;
      case BacklogType.hobby: return Colors.teal;
    }
  }

  IconData _getIconForType(BacklogType type) {
    switch (type) {
      case BacklogType.movie: return FontAwesomeIcons.film;
      case BacklogType.series: return FontAwesomeIcons.tv;
      case BacklogType.song: return FontAwesomeIcons.music;
      case BacklogType.book: return FontAwesomeIcons.bookOpen;
      case BacklogType.game: return FontAwesomeIcons.gamepad;
      case BacklogType.hobby: return FontAwesomeIcons.palette;
    }
  }
}
