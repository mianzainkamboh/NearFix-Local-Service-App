import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/category_service.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;
  String _selectedIcon = 'build';

  final CategoryService _categoryService = CategoryService();

  static const Map<String, IconData> _iconOptions = {
    'electrical_services': Icons.electrical_services,
    'plumbing': Icons.plumbing,
    'cleaning_services': Icons.cleaning_services,
    'carpenter': Icons.carpenter,
    'build': Icons.build,
    'format_paint': Icons.format_paint,
    'home_repair_service': Icons.home_repair_service,
    'local_laundry_service': Icons.local_laundry_service,
    'content_cut': Icons.content_cut,
    'computer': Icons.computer,
    'directions_car': Icons.directions_car,
    'restaurant': Icons.restaurant,
    'fitness_center': Icons.fitness_center,
    'camera_alt': Icons.camera_alt,
    'school': Icons.school,
    'more_horiz': Icons.more_horiz,
  };

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final result = await _categoryService.addCategory(
      name: _nameController.text.trim(),
      icon: _selectedIcon,
      description: _descriptionController.text.trim(),
    );

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? AppColors.success : AppColors.error,
        ),
      );
      if (result['success']) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add Category'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('New Category', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Add a new service category to the platform', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: AppConstants.paddingXL),
              CustomTextField(
                label: 'Category Name',
                hint: 'e.g. Electrician',
                controller: _nameController,
                prefixIcon: Icons.category,
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: AppConstants.paddingM),
              CustomTextField(
                label: 'Description (Optional)',
                hint: 'Brief description',
                controller: _descriptionController,
                prefixIcon: Icons.description,
                maxLines: 2,
              ),
              const SizedBox(height: AppConstants.paddingM),
              const Text('Select Icon', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _iconOptions.entries.map((entry) {
                  final isSelected = _selectedIcon == entry.key;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = entry.key),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isSelected ? AppColors.primary : AppColors.textLight),
                      ),
                      child: Icon(entry.value, color: isSelected ? Colors.white : AppColors.textSecondary),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppConstants.paddingXL),
              CustomButton(
                text: 'Add Category',
                onPressed: _handleSubmit,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
