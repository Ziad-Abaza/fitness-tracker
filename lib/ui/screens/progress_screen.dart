import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../providers/workout_provider.dart';
import '../../providers/exercise_provider.dart';
import '../../providers/measurement_provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/app_theme.dart';
import '../../models/exercise.dart';
import '../../models/body_measurement.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  String? _selectedExerciseId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<SettingsProvider>(
          builder: (context, settings, child) => Text(settings.isArabic ? 'التحليلات' : 'ANALYTICS'),
        ),
      ),
      body: Consumer3<WorkoutProvider, ExerciseProvider, SettingsProvider>(
        builder: (context, workoutProvider, exerciseProvider, settings, child) {
          final isAr = settings.isArabic;
          final volumeData = workoutProvider.getVolumeProgressData();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopStats(workoutProvider, isAr),
                const SizedBox(height: 32),
                Text(
                  isAr ? 'تقدم حجم التمارين (30 يوم)' : 'VOLUME PROGRESS (30D)',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 16),
                _buildVolumeChart(volumeData, isAr),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isAr ? 'تقدم التمرين' : 'EXERCISE PROGRESS',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(child: _buildExerciseSelector(exerciseProvider, isAr)),
                  ],
                ),
                const SizedBox(height: 16),
                if (_selectedExerciseId != null)
                  _buildExerciseProgressChart(workoutProvider, _selectedExerciseId!, isAr)
                else
                  _buildEmptyState(isAr ? 'اختر تمرينًا لعرض تاريخ التقدم.' : 'Select an exercise to view progress history.'),
                const SizedBox(height: 32),
                Text(
                  isAr ? 'تحول الجسم' : 'BODY TRANSFORMATION',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 16),
                _buildBodyTransformationList(context, isAr),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBodyTransformationList(BuildContext context, bool isAr) {
    return Consumer<MeasurementProvider>(
      builder: (context, provider, child) {
        if (provider.measurements.isEmpty) return _buildEmptyState(isAr ? 'لم يتم تسجيل مقاييس الجسم بعد.' : 'No body measurements logged yet.');

        return Container(
          decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16)),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.measurements.length,
            separatorBuilder: (context, index) => const Divider(color: AppTheme.black, height: 1),
            itemBuilder: (context, index) {
              final m = provider.measurements[index];
              return ListTile(
                title: Text(DateFormat('MMM d, y', isAr ? 'ar' : 'en').format(m.date), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                subtitle: Text('${isAr ? 'الوزن' : 'Weight'}: ${m.weight} ${isAr ? 'كجم' : 'kg'}', style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${m.bodyFat.toStringAsFixed(1)}%', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontFamily: 'Orbitron', fontSize: 16)),
                    Text(isAr ? 'دهون الجسم' : 'BODY FAT', style: const TextStyle(fontSize: 8, color: AppTheme.textSecondary)),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTopStats(WorkoutProvider provider, bool isAr) {
    return Row(
      children: [
        _statCard(isAr ? 'الحجم' : 'VOLUME', '${provider.totalVolumeAllTime.toStringAsFixed(0)}', isAr ? 'كجم' : 'KG'),
        const SizedBox(width: 8),
        _statCard(isAr ? 'أفضل تكرار' : 'BEST 1RM', '${provider.best1RMAllTime.toStringAsFixed(1)}', isAr ? 'كجم' : 'KG'),
        const SizedBox(width: 8),
        _statCard(isAr ? 'التمارين' : 'WORKOUTS', '${provider.workoutCount}', isAr ? 'إجمالي' : 'TOTAL'),
      ],
    );
  }

  Widget _statCard(String label, String value, String unit) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primary.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(color: AppTheme.primary, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Orbitron')),
            Text(unit, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 8)),
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeChart(List<Map<String, dynamic>> data, bool isAr) {
    if (data.isEmpty) return _buildEmptyState(isAr ? 'لا توجد بيانات حجم للـ 30 يومًا الماضية.' : 'No volume data for the last 30 days.');

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16)),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() % 5 != 0) return const SizedBox();
                  final index = value.toInt();
                  if (index < 0 || index >= data.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(DateFormat('Md').format(data[index]['date']), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 8)),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value['volume'])).toList(),
              isCurved: true,
              color: AppTheme.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [AppTheme.primary.withOpacity(0.3), AppTheme.primary.withOpacity(0.0)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseSelector(ExerciseProvider provider, bool isAr) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(8)),
      child: DropdownButton<String>(
        value: _selectedExerciseId,
        isExpanded: true,
        hint: Text(isAr ? 'اختر تمرينًا' : 'SELECT EXERCISE', style: const TextStyle(fontSize: 10, color: AppTheme.primary)),
        underline: const SizedBox(),
        dropdownColor: AppTheme.surface,
        onChanged: (val) => setState(() => _selectedExerciseId = val),
        items: provider.exercises.take(20).map((e) => DropdownMenuItem(
          value: e.id,
          child: Text(e.localizedName.toUpperCase(), style: const TextStyle(fontSize: 10), overflow: TextOverflow.ellipsis),
        )).toList(),
      ),
    );
  }

  Widget _buildExerciseProgressChart(WorkoutProvider provider, String exerciseId, bool isAr) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: provider.getExerciseProgressData(exerciseId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) return _buildEmptyState(isAr ? 'لا توجد بيانات تقدم لهذا التمرين بعد.' : 'No progress data yet for this exercise.');

        final data = snapshot.data!;
        return Container(
          height: 250,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16)),
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value['estimated1RM'])).toList(),
                  isCurved: true,
                  color: AppTheme.primary,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [AppTheme.primary.withOpacity(0.2), AppTheme.primary.withOpacity(0.0)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16)),
      child: Center(
        child: Text(message, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12), textAlign: TextAlign.center),
      ),
    );
  }
}
