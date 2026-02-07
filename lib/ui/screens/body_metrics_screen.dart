import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../core/app_theme.dart';
import '../../core/body_fat_calculator.dart';
import '../../models/body_measurement.dart';
import '../../providers/measurement_provider.dart';
import '../../providers/settings_provider.dart';

class BodyMetricsScreen extends StatefulWidget {
  const BodyMetricsScreen({super.key});

  @override
  State<BodyMetricsScreen> createState() => _BodyMetricsScreenState();
}

class _BodyMetricsScreenState extends State<BodyMetricsScreen> {
  final _weightController = TextEditingController();
  final _neckController = TextEditingController();
  final _waistController = TextEditingController();
  final _heightController = TextEditingController();
  final _bodyFatController = TextEditingController();

  bool _isManualBodyFat = false;
  bool _isMale = true;

  @override
  void initState() {
    super.initState();
    _weightController.addListener(_onInputChanged);
    _neckController.addListener(_onInputChanged);
    _waistController.addListener(_onInputChanged);
    _heightController.addListener(_onInputChanged);
  }

  void _onInputChanged() {
    if (!_isManualBodyFat) {
      final h = double.tryParse(_heightController.text) ?? 0;
      final w = double.tryParse(_waistController.text) ?? 0;
      final n = double.tryParse(_neckController.text) ?? 0;

      if (h > 0 && w > 0 && n > 0 && w > n) {
        final bf = BodyFatCalculator.calculate(
          height: h,
          waist: w,
          neck: n,
          isMale: _isMale,
        );
        _bodyFatController.text = bf.toStringAsFixed(1);
      }
    }
  }

  Future<void> _saveMetrics() async {
    final weight = double.tryParse(_weightController.text);
    final bodyFat = double.tryParse(_bodyFatController.text);

    if (weight == null || bodyFat == null) {
      final isAr = context.read<SettingsProvider>().isArabic;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isAr ? 'يرجى إدخال الوزن ونسبة الدهون في الجسم' : 'Please enter weight and body fat %')),
      );
      return;
    }

    final measurement = BodyMeasurement(
      weight: weight,
      neck: double.tryParse(_neckController.text),
      waist: double.tryParse(_waistController.text),
      height: double.tryParse(_heightController.text),
      bodyFat: bodyFat,
      date: DateTime.now(),
      isManualBodyFat: _isManualBodyFat,
    );

    await context.read<MeasurementProvider>().addMeasurement(measurement);
    HapticFeedback.lightImpact();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _neckController.dispose();
    _waistController.dispose();
    _heightController.dispose();
    _bodyFatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.black,
      appBar: AppBar(
        title: Consumer<SettingsProvider>(
          builder: (context, settings, child) => Text(settings.isArabic ? 'مقاييس الجسم' : 'BODY METRICS'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGenderSwitch(),
            const SizedBox(height: 24),
            Consumer<SettingsProvider>(
              builder: (context, settings, child) {
                final isAr = settings.isArabic;
                return Column(
                  children: [
                    _buildInputField(isAr ? 'الوزن (كجم)' : 'WEIGHT (KG)', _weightController, Icons.monitor_weight_outlined),
                    _buildInputField(isAr ? 'الطول (سم)' : 'HEIGHT (CM)', _heightController, Icons.height),
                    _buildInputField(isAr ? 'الرقبة (سم)' : 'NECK (CM)', _neckController, Icons.accessibility_new),
                    _buildInputField(isAr ? 'الخصر (سم)' : 'WAIST (CM)', _waistController, Icons.straighten),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            _buildBodyFatSection(),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _saveMetrics,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
                backgroundColor: AppTheme.primary,
              ),
              child: Consumer<SettingsProvider>(
                builder: (context, settings, child) => Text(
                  settings.isArabic ? 'حفظ المدخلات' : 'SAVE ENTRY',
                  style: const TextStyle(color: AppTheme.black, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderSwitch() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final isAr = settings.isArabic;
        return Row(
          children: [
            _genderButton(isAr ? 'ذكر' : 'MALE', _isMale, () => setState(() { _isMale = true; _onInputChanged(); })),
            const SizedBox(width: 12),
            _genderButton(isAr ? 'أنثى' : 'FEMALE', !_isMale, () => setState(() { _isMale = false; _onInputChanged(); })),
          ],
        );
      },
    );
  }

  Widget _genderButton(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary : AppTheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.black : AppTheme.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: AppTheme.textPrimary, fontFamily: 'Orbitron'),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppTheme.primary, size: 20),
              filled: true,
              fillColor: AppTheme.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyFatSection() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final isAr = settings.isArabic;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _isManualBodyFat ? AppTheme.primary : Colors.transparent),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(isAr ? 'نسبة الدهون %' : 'BODY FAT %', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Text(isAr ? 'تجاوز يدوي' : 'MANUAL OVERRIDE', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
                      Switch(
                        value: _isManualBodyFat,
                        onChanged: (val) => setState(() => _isManualBodyFat = val),
                        activeColor: AppTheme.primary,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _bodyFatController,
                enabled: _isManualBodyFat,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primary, fontFamily: 'Orbitron'),
                decoration: const InputDecoration(
                  suffixText: '%',
                  suffixStyle: TextStyle(fontSize: 18, color: AppTheme.primary),
                  border: InputBorder.none,
                  hintText: '00.0',
                ),
              ),
              if (!_isManualBodyFat)
                Text(
                  isAr ? 'مُقدر عبر طريقة البحرية الأمريكية' : 'ESTIMATED VIA U.S. NAVY METHOD',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 8, letterSpacing: 1),
                ),
            ],
          ),
        );
      },
    );
  }
}
