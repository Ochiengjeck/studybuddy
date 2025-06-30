import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/utils/providers/providers.dart';

import '../../../utils/modelsAndRepsositories/models_and_repositories.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  @override
  void initState() {
    super.initState();
    // Load analytics data when the page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        Provider.of<AnalyticsProvider>(
          context,
          listen: false,
        ).loadAnalyticsData(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AnalyticsProvider>(
        builder: (context, provider, child) {
          if (FirebaseAuth.instance.currentUser == null) {
            return const Center(
              child: Text('Please log in to view analytics.'),
            );
          }

          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text('Error: ${provider.error}'));
          }

          final weeklyActivity = provider.weeklyActivity ?? [];
          final subjectDistribution = provider.subjectDistribution ?? [];
          final tutorPerformance = provider.tutorPerformance ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildChartCard(
                  context,
                  title: 'Weekly Activity',
                  chart: _buildBarChart(weeklyActivity),
                ),
                const SizedBox(height: 16),
                _buildChartCard(
                  context,
                  title: 'Subject Distribution',
                  chart: _buildPieChart(subjectDistribution),
                ),
                const SizedBox(height: 16),
                _buildTutorPerformanceTable(tutorPerformance),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChartCard(
    BuildContext context, {
    required String title,
    required Widget chart,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(height: 200, child: chart),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(List<WeeklyActivity> activities) {
    // Map days to indices for consistency
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final barGroups = List.generate(7, (index) {
      final activity = activities.firstWhere(
        (act) => act.day == days[index],
        orElse:
            () => WeeklyActivity(day: days[index], sessions: 0, duration: 0),
      );
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: activity.sessions.toDouble(),
            color: Colors.blue,
            width: 16,
          ),
        ],
      );
    });

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY:
            activities.isNotEmpty
                ? activities
                        .map((e) => e.sessions)
                        .reduce((a, b) => a > b ? a : b)
                        .toDouble() +
                    2
                : 10,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(days[value.toInt()]),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text(value.toInt().toString());
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
      ),
    );
  }

  Widget _buildPieChart(List<SubjectDistribution> distributions) {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections:
            distributions.isNotEmpty
                ? distributions.map((dist) {
                  return PieChartSectionData(
                    color: dist.color,
                    value: dist.count.toDouble(),
                    title: dist.subject,
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList()
                : [
                  PieChartSectionData(
                    color: Colors.grey,
                    value: 100,
                    title: 'No Data',
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
      ),
    );
  }

  Widget _buildTutorPerformanceTable(List<TutorPerformance> performances) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tutor Performance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DataTable(
              columns: const [
                DataColumn(label: Text('Tutor')),
                DataColumn(label: Text('Sessions')),
                DataColumn(label: Text('Rating')),
                DataColumn(label: Text('Points')),
              ],
              rows:
                  performances.isNotEmpty
                      ? performances.map((perf) {
                        return _buildDataRow(
                          perf.name,
                          perf.sessions.toString(),
                          perf.rating.toStringAsFixed(1),
                          perf.points.toString(),
                        );
                      }).toList()
                      : [
                        const DataRow(
                          cells: [
                            DataCell(Text('No Data')),
                            DataCell(Text('')),
                            DataCell(Text('')),
                            DataCell(Text('')),
                          ],
                        ),
                      ],
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildDataRow(
    String name,
    String sessions,
    String rating,
    String points,
  ) {
    return DataRow(
      cells: [
        DataCell(Text(name)),
        DataCell(Text(sessions)),
        DataCell(
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(rating),
            ],
          ),
        ),
        DataCell(Text(points)),
      ],
    );
  }
}
