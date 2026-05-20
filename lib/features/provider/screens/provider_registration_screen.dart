import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/provider_service.dart';
import '../../../core/services/category_service.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class ProviderRegistrationScreen extends StatefulWidget {
  const ProviderRegistrationScreen({super.key});

  @override
  State<ProviderRegistrationScreen> createState() => _ProviderRegistrationScreenState();
}

class _ProviderRegistrationScreenState extends State<ProviderRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _experienceController = TextEditingController();
  final _serviceAreaController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  final ProviderService _providerService = ProviderService();
  final CategoryService _categoryService = CategoryService();
  
  String? _selectedCategoryId;
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() {
    _categoryService.getCategoriesStream().listen((cats) {
      if (mounted) setState(() => _categories = cats);
    });
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _descriptionController.dispose();
    _experienceController.dispose();
    _serviceAreaController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleRegistration() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a service category')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    final result = await _providerService.registerProvider(
      uid: uid,
      categoryId: _selectedCategoryId!,
      businessName: _businessNameController.text.trim(),
      description: _descriptionController.text.trim(),
      experience: _experienceController.text.trim(),
      serviceArea: _serviceAreaController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? AppColors.success : AppColors.error,
        ),
      );
      if (result['success']) {
        // Navigate back to user dashboard, not provider dashboard
        Navigator.pushReplacementNamed(context, AppRoutes.userMain);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Provider Registration'),
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
              const Text('Register as a Service Provider',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              const Text('Fill in your details to start offering services',
                  style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: AppConstants.paddingXL),
              // Category Dropdown
              const Text('Service Category', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                decoration: InputDecoration(
                  hintText: 'Select your service category',
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    borderSide: const BorderSide(color: AppColors.textLight),
                  ),
                ),
                items: _categories.map((cat) {
                  return DropdownMenuItem<String>(
                    value: cat['id'],
                    child: Text(cat['name'] ?? ''),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedCategoryId = value),
              ),
              const SizedBox(height: AppConstants.paddingM),
              CustomTextField(
                label: 'Business Name',
                hint: 'Enter your business name',
                controller: _businessNameController,
                prefixIcon: Icons.business,
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: AppConstants.paddingM),
              CustomTextField(
                label: 'Description',
                hint: 'Describe your services',
                controller: _descriptionController,
                prefixIcon: Icons.description,
                maxLines: 3,
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: AppConstants.paddingM),
              CustomTextField(
                label: 'Experience',
                hint: 'e.g. 5 years',
                controller: _experienceController,
                prefixIcon: Icons.work_history,
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: AppConstants.paddingM),
              CustomTextField(
                label: 'Service Area',
                hint: 'e.g. Lahore, Pakistan',
                controller: _serviceAreaController,
                prefixIcon: Icons.location_on,
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: AppConstants.paddingM),
              CustomTextField(
                label: 'Phone Number',
                hint: 'Your contact number',
                controller: _phoneController,
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v?.isEmpty == true) return 'Required';
                  if (v!.length < 10) return 'Enter a valid phone number';
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.paddingXL),
              CustomButton(
                text: 'Submit Registration',
                onPressed: _handleRegistration,
                isLoading: _isLoading,
              ),
              const SizedBox(height: AppConstants.paddingM),
              const Text(
                'Note: Your registration will be reviewed by an admin before you can start receiving bookings.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
