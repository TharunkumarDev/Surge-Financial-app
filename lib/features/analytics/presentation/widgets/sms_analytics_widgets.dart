import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/design_system.dart';
import '../../../auto_tracking/domain/auto_transaction.dart';
import 'package:intl/intl.dart';

class SmsAnalyticsSection extends StatelessWidget {
  final List<AutoTransaction> transactions;
  final String currencySymbol;

  const SmsAnalyticsSection({
    super.key,
    required this.transactions,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sentAmount = transactions.where((t) => t.type == TransactionType.debit).fold<double>(0.0, (sum, t) => sum + (t.amount ?? 0.0));
    final receivedAmount = transactions.where((t) => t.type == TransactionType.credit).fold<double>(0.0, (sum, t) => sum + (t.amount ?? 0.0));
    final avgAmount = transactions.isEmpty ? 0.0 : (sentAmount + receivedAmount) / transactions.length;
    final last7Days = _getLast7DaysData();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SMS Tracking Analytics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.darkGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Last 7 Days',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).brightness == Brightness.dark ? AppTheme.limeAccent : AppTheme.darkGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Statistics Cards Row
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Sent Payment',
                  value: '$currencySymbol${sentAmount.toStringAsFixed(0)}',
                  icon: Icons.unfold_less_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Received Payment',
                  value: '$currencySymbol${receivedAmount.toStringAsFixed(0)}',
                  icon: Icons.unfold_more_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Total Count',
                  value: '${transactions.length}',
                  icon: Icons.sms_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Daily Average',
                  value: '$currencySymbol${(avgAmount / 7).toStringAsFixed(0)}',
                  icon: Icons.auto_graph_rounded,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Trend Chart
          if (transactions.isNotEmpty) ...[
            Text(
              '7-Day Trend',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: SmsTrendChart(
                data: last7Days,
                currencySymbol: currencySymbol,
              ),
            ),
          ] else
            Container(
              height: 140,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.02) : Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.limeAccent.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.analytics_outlined,
                      size: 32,
                      color: isDark ? AppTheme.limeAccent : AppTheme.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No SMS transactions yet',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap "Sync Now" in Profile to track',
                    style: TextStyle(
                      color: isDark ? Colors.white38 : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Map<String, double> _getLast7DaysData() {
    final Map<String, double> data = {};
    final now = DateTime.now();

    // Initialize last 7 days with 0
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = DateFormat('MMM dd').format(date);
      data[key] = 0.0;
    }

    // Aggregate transactions by day
    for (var transaction in transactions) {
      if (transaction.receivedAt != null) {
        final diff = now.difference(transaction.receivedAt).inDays;
        if (diff <= 7) {
          final key = DateFormat('MMM dd').format(transaction.receivedAt);
          data[key] = (data[key] ?? 0.0) + (transaction.amount ?? 0.0);
        }
      }
    }

    return data;
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.limeAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon, 
                  size: 16, 
                  color: isDark ? AppTheme.limeAccent : AppTheme.darkGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppTheme.darkGreen,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white38 : Colors.black45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class SmsTrendChart extends StatelessWidget {
  final Map<String, double> data;
  final String currencySymbol;

  const SmsTrendChart({
    super.key,
    required this.data,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final spots = <FlSpot>[];
    final keys = data.keys.toList();
    
    for (int i = 0; i < keys.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[keys[i]] ?? 0.0));
    }

    final maxY = data.values.isEmpty ? 100.0 : data.values.reduce((a, b) => a > b ? a : b) * 1.2;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < keys.length) {
                  // Show only every other label to avoid crowding
                  if (index % 2 == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        keys[index].split(' ')[1], // Show day only
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (keys.length - 1).toDouble(),
        minY: 0,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: isDark ? AppTheme.limeAccent : AppTheme.darkGreen,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: isDark ? AppTheme.darkGreen : Colors.white,
                  strokeWidth: 2,
                  strokeColor: isDark ? AppTheme.limeAccent : AppTheme.darkGreen,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  (isDark ? AppTheme.limeAccent : AppTheme.darkGreen).withOpacity(0.2),
                  (isDark ? AppTheme.limeAccent : AppTheme.darkGreen).withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => Colors.black87,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '$currencySymbol${spot.y.toStringAsFixed(0)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}
