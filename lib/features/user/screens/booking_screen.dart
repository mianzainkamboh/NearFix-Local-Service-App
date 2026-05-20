import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/booking_service.dart';
import '../../../core/services/provider_service.dart';
import '../../../core/services/service_service.dart';
import '../../../core/services/availability_service.dart';
import '../../../shared/widgets/custom_button.dart';

class BookingScreen extends StatefulWidget {
  final String providerId;
  final String serviceId;

  const BookingScreen({
    super.key,
    required this.providerId,
    required this.serviceId,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedTimeSlot;
  String _selectedPayment = 'cash';
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;
  bool _isDataLoading = true;

  final BookingService _bookingService = BookingService();
  final ProviderService _providerService = ProviderService();
  final ServiceService _serviceService = ServiceService();
  final AvailabilityService _availabilityService = AvailabilityService();

  Map<String, dynamic> _provider = {};
  Map<String, dynamic>? _service;
  List<String> _timeSlots = [];
  List<String> _workingDays = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    // Load provider
    final providerData = await _providerService.getProvider(widget.providerId);
    
    // Load service if serviceId provided
    Map<String, dynamic>? serviceData;
    if (widget.serviceId.isNotEmpty) {
      serviceData = await _serviceService.getService(widget.serviceId);
    }

    // Load availability
    final avail = await _availabilityService.getAvailability(widget.providerId);
    List<String> slots = [];
    List<String> days = [];
    if (avail != null) {
      days = List<String>.from(avail['workingDays'] ?? []);
      slots = _availabilityService.generateTimeSlots(
        avail['startTime'] ?? '09:00 AM',
        avail['endTime'] ?? '05:00 PM',
        (avail['slotDuration'] ?? 60) as int,
      );
    }

    if (slots.isEmpty) {
      // Default slots if no availability set
      slots = ['09:00 AM', '10:00 AM', '11:00 AM', '12:00 PM', '02:00 PM', '03:00 PM', '04:00 PM', '05:00 PM'];
    }

    if (mounted) {
      setState(() {
        _provider = providerData ?? {};
        _service = serviceData;
        _timeSlots = slots;
        _workingDays = days;
        _isDataLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
        _selectedTimeSlot = null; // Reset time slot when date changes
      });
    }
  }

  bool _isTimeSlotInPast(String timeSlot) {
    // Check if selected date is today
    final now = DateTime.now();
    final isToday = _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;

    if (!isToday) {
      return false; // Future dates are always valid
    }

    // Parse time slot (e.g., "09:00 AM" or "02:30 PM")
    try {
      final timeParts = timeSlot.split(' ');
      final hourMinute = timeParts[0].split(':');
      int hour = int.parse(hourMinute[0]);
      final minute = int.parse(hourMinute[1]);
      final isPM = timeParts[1].toUpperCase() == 'PM';

      // Convert to 24-hour format
      if (isPM && hour != 12) {
        hour += 12;
      } else if (!isPM && hour == 12) {
        hour = 0;
      }

      final slotTime = DateTime(now.year, now.month, now.day, hour, minute);
      return slotTime.isBefore(now);
    } catch (e) {
      return false; // If parsing fails, allow the slot
    }
  }

  void _handleBooking() async {
    if (_selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time slot')),
      );
      return;
    }

    // Check if selected time is in the past
    if (_isTimeSlotInPast(_selectedTimeSlot!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot book a time slot in the past. Please select a future time.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your address')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final price = _service != null
        ? (_service!['price'] ?? 0).toDouble()
        : 0.0;
    final serviceName = _service?['name'] ?? _provider['businessName'] ?? 'Service';

    final result = await _bookingService.createBooking(
      userId: userId,
      providerId: widget.providerId,
      serviceId: widget.serviceId,
      serviceName: serviceName,
      date: '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
      timeSlot: _selectedTimeSlot!,
      address: _addressController.text,
      price: price,
      notes: _notesController.text,
      paymentMethod: _selectedPayment,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (result['success']) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.bookingConfirmation,
          arguments: {'bookingId': result['bookingId']},
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message']), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final price = _service != null ? (_service!['price'] ?? 0).toDouble() : 0.0;
    final providerName = _provider['name'] ?? 'Provider';
    final serviceName = _service?['name'] ?? _provider['businessName'] ?? 'Service';
    final rating = (_provider['rating'] ?? 0.0).toDouble();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Book Service'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: _isDataLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Provider Info Card
                  Container(
                    margin: const EdgeInsets.all(AppConstants.paddingM),
                    padding: const EdgeInsets.all(AppConstants.paddingM),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppConstants.radiusL),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.primary,
                          child: Icon(Icons.person, color: Colors.white, size: 30),
                        ),
                        const SizedBox(width: AppConstants.paddingM),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(providerName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(serviceName, style: const TextStyle(color: AppColors.textSecondary)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star, size: 16, color: AppColors.warning),
                                  const SizedBox(width: 4),
                                  Text('$rating', style: const TextStyle(fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (price > 0)
                          Text(
                            '₹${price.toInt()}',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                      ],
                    ),
                  ),
                  // Date Selection
                  _buildSectionTitle('Select Date'),
                  GestureDetector(
                    onTap: _selectDate,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
                      padding: const EdgeInsets.all(AppConstants.paddingM),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppConstants.radiusM),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: AppColors.primary),
                          const SizedBox(width: AppConstants.paddingM),
                          Text(
                            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                  // Time Slots
                  _buildSectionTitle('Select Time Slot'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _timeSlots.map((slot) {
                        final isSelected = _selectedTimeSlot == slot;
                        final isPast = _isTimeSlotInPast(slot);
                        return GestureDetector(
                          onTap: isPast ? null : () => setState(() => _selectedTimeSlot = slot),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isPast 
                                  ? AppColors.textLight.withValues(alpha: 0.3)
                                  : isSelected 
                                      ? AppColors.primary 
                                      : AppColors.surface,
                              borderRadius: BorderRadius.circular(AppConstants.radiusM),
                              border: Border.all(
                                color: isPast
                                    ? AppColors.textLight
                                    : isSelected 
                                        ? AppColors.primary 
                                        : AppColors.textLight,
                              ),
                            ),
                            child: Text(
                              slot,
                              style: TextStyle(
                                color: isPast
                                    ? AppColors.textLight
                                    : isSelected 
                                        ? Colors.white 
                                        : AppColors.textPrimary,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                decoration: isPast ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  // Address
                  _buildSectionTitle('Service Address'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
                    child: TextField(
                      controller: _addressController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Enter your complete address',
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.radiusM),
                          borderSide: const BorderSide(color: AppColors.textLight),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.radiusM),
                          borderSide: const BorderSide(color: AppColors.textLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.radiusM),
                          borderSide: const BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                  ),
                  // Notes
                  _buildSectionTitle('Additional Notes (Optional)'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
                    child: TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Any specific instructions...',
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.radiusM),
                          borderSide: const BorderSide(color: AppColors.textLight),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.radiusM),
                          borderSide: const BorderSide(color: AppColors.textLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.radiusM),
                          borderSide: const BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                  ),
                  // Payment Method
                  _buildSectionTitle('Payment Method'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
                    child: Column(
                      children: [
                        _buildPaymentOption('cash', 'Cash on Service', Icons.money),
                        const SizedBox(height: 10),
                        _buildPaymentOption('online', 'Online Payment', Icons.credit_card),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingXL),
                ],
              ),
            ),
      bottomNavigationBar: _isDataLoading
          ? null
          : Container(
              padding: const EdgeInsets.all(AppConstants.paddingM),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Amount', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        Text(price > 0 ? '₹${price.toInt()}' : 'TBD', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ],
                    ),
                    const SizedBox(width: AppConstants.paddingL),
                    Expanded(
                      child: CustomButton(
                        text: 'Confirm Booking',
                        onPressed: _handleBooking,
                        isLoading: _isLoading,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppConstants.paddingM, AppConstants.paddingL, AppConstants.paddingM, AppConstants.paddingS),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
    );
  }

  Widget _buildPaymentOption(String value, String title, IconData icon) {
    final isSelected = _selectedPayment == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = value),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.textLight),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: AppConstants.paddingM),
            Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
            const Spacer(),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
