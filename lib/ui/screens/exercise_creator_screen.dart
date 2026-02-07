import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/exercise.dart';
import '../../providers/exercise_provider.dart';
import '../../core/app_theme.dart';

class ExerciseCreatorScreen extends StatefulWidget {
  const ExerciseCreatorScreen({super.key});

  @override
  State<ExerciseCreatorScreen> createState() => _ExerciseCreatorScreenState();
}

class _ExerciseCreatorScreenState extends State<ExerciseCreatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nameArController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _instructionsArController = TextEditingController();
  
  String? _selectedBodyPart;
  String? _selectedEquipment;
  File? _selectedImage;
  
  final List<String> _selectedPrimaryMuscles = [];
  final List<String> _selectedSecondaryMuscles = [];

  final List<String> _bodyParts = [
    'Shoulders', 'Chest', 'Back', 'Arms', 'Abdominals', 'Legs', 'Cardio', 'Full Body'
  ];

  final List<String> _equipments = [
    'Dumbbell', 'Barbell', 'Machine', 'Cable', 'Bodyweight', 'Kettlebell', 'Band', 'Other'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _nameArController.dispose();
    _instructionsController.dispose();
    _instructionsArController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _saveExercise() {
    if (_formKey.currentState!.validate()) {
      if (_selectedBodyPart == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a body part')),
        );
        return;
      }

      final List<String> instructions = _instructionsController.text.isNotEmpty
          ? _instructionsController.text.split('\n').where((s) => s.trim().isNotEmpty).toList()
          : ['No instructions provided'];
          
      final List<String>? instructionsAr = _instructionsArController.text.isNotEmpty
          ? _instructionsArController.text.split('\n').where((s) => s.trim().isNotEmpty).toList()
          : (_instructionsController.text.isEmpty ? ['لا توجد تعليمات'] : null);

      final newExercise = Exercise(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text,
        name_ar: _nameArController.text.isNotEmpty ? _nameArController.text : null,
        force: '',
        level: 'Intermediate',
        mechanic: '',
        equipment: _selectedEquipment ?? 'Other',
        primaryMuscles: _selectedPrimaryMuscles.isNotEmpty ? _selectedPrimaryMuscles : [_selectedBodyPart!],
        secondaryMuscles: _selectedSecondaryMuscles,
        instructions: instructions,
        instructions_ar: instructionsAr,
        category: _selectedBodyPart!,
        images: _selectedImage != null ? [_selectedImage!.path] : [],
      );

      context.read<ExerciseProvider>().addCustomExercise(newExercise);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NEW EXERCISE'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImagePicker(),
              const SizedBox(height: 32),
              
              _buildSectionHeader('BASIC INFO'),
              _buildTextField('EXERCISE NAME *', _nameController, true),
              const SizedBox(height: 16),
              _buildTextField('NAME (ARABIC)', _nameArController, false),
              const SizedBox(height: 16),
              _buildDropdown('BODY PART *', _bodyParts, _selectedBodyPart, (val) => setState(() => _selectedBodyPart = val)),
              const SizedBox(height: 16),
              _buildDropdown('EQUIPMENT', _equipments, _selectedEquipment, (val) => setState(() => _selectedEquipment = val)),
              
              const SizedBox(height: 32),
              _buildSectionHeader('DETAILED SPECS (OPTIONAL)'),
              _buildMusclePicker('PRIMARY MUSCLES', context.read<ExerciseProvider>().muscles, _selectedPrimaryMuscles),
              const SizedBox(height: 16),
              _buildMusclePicker('SECONDARY MUSCLES', context.read<ExerciseProvider>().muscles, _selectedSecondaryMuscles),
              const SizedBox(height: 24),
              _buildTextField('INSTRUCTIONS (EN)', _instructionsController, false, maxLines: 4, hint: 'Step 1: ...\nStep 2: ...'),
              const SizedBox(height: 16),
              _buildTextField('INSTRUCTIONS (AR)', _instructionsArController, false, maxLines: 4, hint: 'الخطوة ١: ...'),
              
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _saveExercise,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                  backgroundColor: AppTheme.primary,
                  foregroundColor: AppTheme.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('CREATE EXERCISE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          color: AppTheme.primary.withOpacity(0.8),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Center(
        child: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.primary.withOpacity(0.3), width: 2),
            boxShadow: [
              BoxShadow(color: AppTheme.primary.withOpacity(0.05), blurRadius: 10, spreadRadius: 2)
            ],
          ),
          child: _selectedImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_a_photo_outlined, color: AppTheme.primary, size: 36),
                    const SizedBox(height: 12),
                    Text('ADD IMAGE', style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, bool isRequired, {int maxLines = 1, String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: AppTheme.textPrimary),
          validator: isRequired ? (val) => val == null || val.isEmpty ? 'Required' : null : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppTheme.textSecondary.withOpacity(0.3), fontSize: 14),
            filled: true,
            fillColor: AppTheme.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: AppTheme.surface,
              hint: Text('Select $label', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
              items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMusclePicker(String label, List<String> allMuscles, List<String> selectedList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: AppTheme.surface,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
              builder: (context) {
                return StatefulBuilder(
                  builder: (context, setModalState) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('SELECT ${label.split(' ')[0]}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: allMuscles.length,
                            itemBuilder: (context, index) {
                              final muscle = allMuscles[index];
                              final isSelected = selectedList.contains(muscle);
                              return CheckboxListTile(
                                value: isSelected,
                                title: Text(muscle.toUpperCase(), style: const TextStyle(fontSize: 12)),
                                activeColor: AppTheme.primary,
                                checkColor: AppTheme.black,
                                onChanged: (val) {
                                  setState(() {
                                    if (val == true) {
                                      selectedList.add(muscle);
                                    } else {
                                      selectedList.remove(muscle);
                                    }
                                  });
                                  setModalState(() {});
                                },
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                            child: const Text('DONE'),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: selectedList.isEmpty
                ? const Text('None selected', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14))
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: selectedList.map((m) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                      ),
                      child: Text(m.toUpperCase(), style: const TextStyle(fontSize: 10, color: AppTheme.primary, fontWeight: FontWeight.bold)),
                    )).toList(),
                  ),
          ),
        ),
      ],
    );
  }
}
