import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/blocs/backlog_bloc.dart';
import '../../models/backlog_item.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: BlocBuilder<BacklogBloc, BacklogState>(
        builder: (context, state) {
          if (state is BacklogLoaded) {
            final items = state.items;
            if (items.isEmpty) return const Center(child: Text("No items to analyze yet."));

            final total = items.length;
            final completed = items.where((e) => e.status == BacklogStatus.completed).length;
            final inProgress = items.where((e) => e.status == BacklogStatus.inProgress).length;
            final planned = items.where((e) => e.status == BacklogStatus.planned).length;

            // Group by Type
            final typeCounts = <BacklogType, int>{};
            for (var item in items) {
              typeCounts[item.type] = (typeCounts[item.type] ?? 0) + 1;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                     children: [
                       _buildStatCard(context, "Total", total.toString(), Colors.blue),
                       _buildStatCard(context, "Completed", completed.toString(), Colors.green),
                       _buildStatCard(context, "Planned", planned.toString(), Colors.orange),
                     ],
                   ),
                   const SizedBox(height: 32),
                   Text("Distribution by Type", style: Theme.of(context).textTheme.titleLarge),
                   const SizedBox(height: 32),
                   AspectRatio(
                     aspectRatio: 1.3,
                     child: PieChart(
                       PieChartData(
                         pieTouchData: PieTouchData(
                           touchCallback: (FlTouchEvent event, pieTouchResponse) {
                             setState(() {
                               if (!event.isInterestedForInteractions ||
                                   pieTouchResponse == null ||
                                   pieTouchResponse.touchedSection == null) {
                                 touchedIndex = -1;
                                 return;
                               }
                               touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                             });
                           },
                         ),
                         borderData: FlBorderData(show: false),
                         sectionsSpace: 0,
                         centerSpaceRadius: 40,
                         sections: () {
                           final entryList = typeCounts.entries.toList();
                           return List.generate(entryList.length, (i) {
                             final e = entryList[i];
                             final isTouched = i == touchedIndex;
                             final fontSize = isTouched ? 20.0 : 16.0;
                             final radius = isTouched ? 60.0 : 50.0;
                             final color = _getColorForType(e.key);

                             return PieChartSectionData(
                               color: color,
                               value: e.value.toDouble(),
                               title: '${(e.value / total * 100).toStringAsFixed(1)}%',
                               radius: radius,
                               titleStyle: TextStyle(
                                 fontSize: fontSize,
                                 fontWeight: FontWeight.bold,
                                 color: Colors.white,
                               ),
                             );
                           });
                         }(),
                       ),
                     ),
                   ),
                   const SizedBox(height: 16),
                   Wrap(
                     spacing: 16,
                     runSpacing: 8,
                     alignment: WrapAlignment.center,
                     children: typeCounts.keys.map((key) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(width: 12, height: 12, color: _getColorForType(key)),
                            const SizedBox(width: 4),
                            Text(key.name.toUpperCase()),
                          ],
                        );
                     }).toList(),
                   ),
                ],
              ),
            );
          }
           return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          ],
        ),
      ),
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
}
