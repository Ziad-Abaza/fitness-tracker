import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/exercise_provider.dart';
import '../../providers/workout_provider.dart';
import '../../core/app_theme.dart';
import '../widgets/exercise_detail_sheet.dart';
import '../widgets/exercise_image.dart';
import 'exercise_creator_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EXERCISE LIBRARY'),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(child: _buildExerciseList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ExerciseCreatorScreen()),
          );
        },
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: AppTheme.black),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        onChanged: (value) =>
            context.read<ExerciseProvider>().updateSearch(value),
        style: const TextStyle(color: AppTheme.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search exercises...',
          hintStyle: const TextStyle(color: AppTheme.textSecondary),
          prefixIcon: const Icon(Icons.search, color: AppTheme.primary),
          filled: true,
          fillColor: AppTheme.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.primary, width: 1),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Consumer<ExerciseProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            SizedBox(
              height: 45,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _CategoryChip(
                    label: 'ALL',
                    isSelected: provider.selectedBodyPart == null,
                    onSelected: () => provider.setBodyPart(null),
                  ),
                  ...provider.bodyParts.map((part) => _CategoryChip(
                        label: part.toUpperCase(),
                        isSelected: provider.selectedBodyPart == part,
                        onSelected: () => provider.setBodyPart(part),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _FilterDropdown(
                    label: 'Muscle',
                    items: provider.muscles,
                    onChanged: (val) => provider.setMuscle(val),
                  ),
                  const SizedBox(width: 8),
                  _FilterDropdown(
                    label: 'Equipment',
                    items: provider.equipments,
                    onChanged: (val) => provider.setEquipment(val),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExerciseList() {
    return Consumer<ExerciseProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
        }

        if (provider.exercises.isEmpty) {
          return const Center(
            child: Text('No exercises found.', style: TextStyle(color: AppTheme.textSecondary)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: provider.exercises.length,
          itemBuilder: (context, index) {
            final exercise = provider.exercises[index];
            return Card(
              color: AppTheme.surface,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                onLongPress: () {
                  HapticFeedback.heavyImpact();
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      backgroundColor: AppTheme.surface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: ExerciseImage(
                              gifPath: exercise.gifPath, 
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              exercise.localizedName.toUpperCase(),
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                onTap: () {
                  HapticFeedback.lightImpact();
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => ExerciseDetailSheet(exercise: exercise),
                  );
                },
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 50,
                    height: 50,
                    color: AppTheme.black,
                    child: ExerciseImage(
                      gifPath: exercise.gifPath,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                title: Text(
                  exercise.localizedName.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1),
                ),
                subtitle: Text(
                  '${exercise.category} • ${exercise.equipment}',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                ),
                trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary, size: 20),
              ),
            );
          },
        );
      },
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final List<String> items;
  final Function(String?) onChanged;

  const _FilterDropdown({
    required this.label,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onChanged,
      color: AppTheme.surface,
      offset: const Offset(0, 45),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => [
        const PopupMenuItem<String>(
          value: null,
          child: Text('Clear Filter', style: TextStyle(color: AppTheme.primary)),
        ),
        ...items.map((item) => PopupMenuItem<String>(
              value: item,
              child: Text(item.toUpperCase(), style: const TextStyle(fontSize: 12)),
            )),
      ],
      child: Chip(
        backgroundColor: AppTheme.surface,
        side: BorderSide(color: AppTheme.textSecondary.withOpacity(0.2)),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label.toUpperCase(), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
            const Icon(Icons.arrow_drop_down, color: AppTheme.textSecondary, size: 16),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onSelected(),
        selectedColor: AppTheme.primary,
        backgroundColor: AppTheme.surface,
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.black : AppTheme.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppTheme.primary : AppTheme.textSecondary.withOpacity(0.2),
          ),
        ),
        showCheckmark: false,
      ),
    );
  }
}
