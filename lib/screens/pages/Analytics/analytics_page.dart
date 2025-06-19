import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            _buildChartCard(
              context,
              title: 'Weekly Activity',
              chart: _buildBarChart(),
            ),
            SizedBox(height: 16),
            _buildChartCard(
              context,
              title: 'Subject Distribution',
              chart: _buildPieChart(),
            ),
            SizedBox(height: 16),
            _buildTutorPerformanceTable(),
          ],
        ),
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
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Container(height: 200, child: chart),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 10,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
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
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [BarChartRodData(toY: 5, color: Colors.blue, width: 16)],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [BarChartRodData(toY: 7, color: Colors.blue, width: 16)],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [BarChartRodData(toY: 3, color: Colors.blue, width: 16)],
          ),
          BarChartGroupData(
            x: 3,
            barRods: [BarChartRodData(toY: 8, color: Colors.blue, width: 16)],
          ),
          BarChartGroupData(
            x: 4,
            barRods: [BarChartRodData(toY: 4, color: Colors.blue, width: 16)],
          ),
          BarChartGroupData(
            x: 5,
            barRods: [BarChartRodData(toY: 2, color: Colors.blue, width: 16)],
          ),
          BarChartGroupData(
            x: 6,
            barRods: [BarChartRodData(toY: 0, color: Colors.blue, width: 16)],
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: [
          PieChartSectionData(
            color: Colors.blue,
            value: 25,
            title: 'Math',
            radius: 60,
            titleStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            color: Colors.green,
            value: 20,
            title: 'Science',
            radius: 60,
            titleStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            color: Colors.amber,
            value: 15,
            title: 'English',
            radius: 60,
            titleStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            color: Colors.purple,
            value: 10,
            title: 'History',
            radius: 60,
            titleStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorPerformanceTable() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tutor Performance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            DataTable(
              columns: [
                DataColumn(label: Text('Tutor')),
                DataColumn(label: Text('Sessions')),
                DataColumn(label: Text('Rating')),
                DataColumn(label: Text('Points')),
              ],
              rows: [
                _buildDataRow('Sarah Johnson', '42', '4.9', '3120'),
                _buildDataRow('Michael Chen', '38', '4.8', '2450'),
                _buildDataRow('David Lee', '35', '4.7', '2210'),
                _buildDataRow('Emily Rodriguez', '28', '4.6', '1980'),
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
              Icon(Icons.star, color: Colors.amber, size: 16),
              SizedBox(width: 4),
              Text(rating),
            ],
          ),
        ),
        DataCell(Text(points)),
      ],
    );
  }
}
