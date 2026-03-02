import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../logic/blocs/backlog_bloc.dart';
import '../../models/backlog_item.dart';
import '../widgets/backlog_list_item.dart';

class TimelinePage extends StatelessWidget {
  const TimelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Timeline')),
      body: BlocBuilder<BacklogBloc, BacklogState>(
        builder: (context, state) {
          if (state is BacklogLoaded) {
            final items = state.items.where((e) => e.dateCompleted != null).toList();
            items.sort((a, b) => b.dateCompleted!.compareTo(a.dateCompleted!));

            if (items.isEmpty) {
              return const Center(child: Text("No completed items yet. Finish something!"));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                // Check if we need a date header
                bool showHeader = false;
                if (index == 0) {
                  showHeader = true;
                } else {
                  final prevItem = items[index - 1];
                  if (!_isSameMonth(prevItem.dateCompleted!, item.dateCompleted!)) {
                    showHeader = true;
                  }
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showHeader)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          DateFormat.yMMMM().format(item.dateCompleted!),
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                        ),
                      ),
                    BacklogListItem(item: item),
                  ],
                );
              },
            );
          }
           return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  bool _isSameMonth(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month;
  }
}
