import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/availability_service.dart';
import '../../../shared/widgets/custom_button.dart';

class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  final AvailabilityService _availabilityService = AvailabilityService();
  bool _isLoading = false;
  bool _isDataLoading = true;

  final List<String> _allDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  List<String> _selectedDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];

  String _startTime = '09:00 AM';
  String _endTime = '05:00 PM';
  int _slotDuration = 60;

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  void _loadAvailability() async {
    final data = await _availabilityService.getAvailability(_uid);
    if (mounted) {
      if (data != null) {
        setState(() {
          _selectedDays = List<String>.from(data['workingDays'] ?? _selectedDays);
          _startTime = data['startTime'] ?? _startTime;
          _endTime = data['endTime'] ?? _endTime;
          _slotDuration = (data['slotDuration'] ?? _slotDuration) as int;
        });
      }
      setState(() => _isDataLoading = false);
    }
  }

  void _saveAvailability() async {
    setState(() => _isLoading = true);
    final result = await _availabilityService.saveAvailability(
      providerId: _uid,
      workingDays: _selectedDays,
      startTime: _startTime,
      endTime: _endTime,
      slotDuration: _slotDuration,
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
        title: const Text('Availability'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: _isDataLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Working Days', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _allDays.map((day) {
                      final isSelected = _selectedDays.contains(day);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedDays.remove(day);
                            } else {
                              _selectedDays.add(day);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : AppColors.surface,
                            borderRadius: BorderRadius.circular(AppConstants.radiusM),
                            border: Border.all(color: isSelected ? AppColors.primary : AppColors.textLight),
                          ),
                          child: Text(
                            day.substring(0, 3),
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppConstants.paddingXL),
                  const Text('Working Hours', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildTimeSelector('Start Time', _startTime, (v) => setState(() => _startTime = v))),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTimeSelector('End Time', _endTime, (v) => setState(() => _endTime = v))),
                    ],
                  ),
                  const SizedBox(height: AppConstants.paddingXL),
                  const Text('Slot Duration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [30, 45, 60, 90, 120].map((mins) {
                      final isSelected = _slotDuration == mins;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _slotDuration = mins),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : AppColors.surface,
                              borderRadius: BorderRadius.circular(AppConstants.radiusM),
                              border: Border.all(color: isSelected ? AppColors.primary : AppColors.textLight),
                            ),
                            child: Text(
                              '${mins}m',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppConstants.paddingXL * 2),
                  CustomButton(
                    text: 'Save Availability',
                    onPressed: _saveAvailability,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTimeSelector(String label, String current, Function(String) onChanged) {
    final times = [
      '06:00 AM', '07:00 AM', '08:00 AM', '09:00 AM', '10:00 AM', '11:00 AM',
      '12:00 PM', '01:00 PM', '02:00 PM', '03:00 PM', '04:00 PM', '05:00 PM',
      '06:00 PM', '07:00 PM', '08:00 PM', '09:00 PM',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: times.contains(current) ? current : times[3],
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              borderSide: const BorderSide(color: AppColors.textLight),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          items: times.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 14)))).toList(),
          onChanged: (v) => onChanged(v ?? current),
        ),
      ],
    );
  }
}
