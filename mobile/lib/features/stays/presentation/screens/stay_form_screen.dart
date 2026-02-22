import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../shared/constants/tulip_colors.dart';
import '../../../../shared/constants/tulip_text_styles.dart';
import '../../../../shared/widgets/tulip_button.dart';
import '../../../../shared/widgets/tulip_text_field.dart';
import '../../../../shared/widgets/cozy_card.dart';
import '../providers/stays_provider.dart';
import '../../data/models/stay_model.dart';

class StayFormScreen extends ConsumerStatefulWidget {
  final int? stayId;

  const StayFormScreen({super.key, this.stayId});

  @override
  ConsumerState<StayFormScreen> createState() => _StayFormScreenState();
}

class _StayFormScreenState extends ConsumerState<StayFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _priceController = TextEditingController();
  final _bookingUrlController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _checkIn;
  DateTime? _checkOut;
  String _currency = 'USD';
  String? _stayType;
  bool _booked = false;
  bool _isLoading = false;

  static const _stayTypes = [
    ('airbnb', 'Airbnb'),
    ('hotel', 'Hotel'),
    ('hostel', 'Hostel'),
    ('friend', 'Friend/Family'),
    ('other', 'Other'),
  ];

  static const _currencies = [
    'USD', 'EUR', 'GBP', 'JPY', 'AUD', 'CAD', 'CHF', 'CNY', 'INR', 'MXN'
  ];

  bool get isEditing => widget.stayId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _loadExistingStay();
    }
  }

  Future<void> _loadExistingStay() async {
    setState(() => _isLoading = true);
    try {
      final stay = await ref.read(stayDetailProvider(widget.stayId!).future);
      _populateForm(stay);
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _populateForm(Stay stay) {
    _titleController.text = stay.title;
    _addressController.text = stay.address ?? '';
    _cityController.text = stay.city;
    _stateController.text = stay.state ?? '';
    _countryController.text = stay.country ?? '';
    if (stay.priceTotalCents != null) {
      _priceController.text = (stay.priceTotalCents! / 100.0).toStringAsFixed(2);
    }
    _bookingUrlController.text = stay.bookingUrl ?? '';
    _imageUrlController.text = stay.imageUrl ?? '';
    _notesController.text = stay.notes ?? '';
    setState(() {
      _checkIn = stay.checkIn;
      _checkOut = stay.checkOut;
      _currency = stay.currency;
      _stayType = stay.stayType;
      _booked = stay.booked;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _priceController.dispose();
    _bookingUrlController.dispose();
    _imageUrlController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final request = StayRequest(
      title: _titleController.text.trim(),
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim().isEmpty
          ? null
          : _stateController.text.trim(),
      country: _countryController.text.trim().isEmpty
          ? null
          : _countryController.text.trim(),
      checkIn: _checkIn,
      checkOut: _checkOut,
      priceTotalDollars: _priceController.text.trim().isEmpty
          ? null
          : double.tryParse(_priceController.text.trim()),
      currency: _currency,
      stayType: _stayType,
      bookingUrl: _bookingUrlController.text.trim().isEmpty
          ? null
          : _bookingUrlController.text.trim(),
      imageUrl: _imageUrlController.text.trim().isEmpty
          ? null
          : _imageUrlController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      booked: _booked,
    );

    final formNotifier = ref.read(stayFormProvider.notifier);
    final success = isEditing
        ? await formNotifier.updateStay(widget.stayId!, request)
        : await formNotifier.createStay(request);

    if (success && mounted) {
      context.pop();
    }
  }

  Future<void> _selectDate(bool isCheckIn) async {
    final initialDate = isCheckIn
        ? (_checkIn ?? DateTime.now())
        : (_checkOut ?? _checkIn?.add(const Duration(days: 1)) ?? DateTime.now());

    final firstDate = isCheckIn
        ? DateTime.now().subtract(const Duration(days: 365))
        : (_checkIn ?? DateTime.now());

    final lastDate = DateTime.now().add(const Duration(days: 365 * 3));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: TulipColors.sage,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: TulipColors.brown,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkIn = picked;
          // If check-out is before or equal to check-in, clear it
          if (_checkOut != null && _checkOut!.isBefore(picked.add(const Duration(days: 1)))) {
            _checkOut = null;
          }
        } else {
          _checkOut = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(stayFormProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Stay' : 'New Stay',
          style: TulipTextStyles.heading3,
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: TulipColors.sage))
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Error message
                            if (formState.error != null) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: TulipColors.roseLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  formState.error!,
                                  style: TulipTextStyles.bodySmall.copyWith(
                                    color: TulipColors.roseDark,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Basic Info Section
                            Text('Basic Info', style: TulipTextStyles.heading3),
                            const SizedBox(height: 12),

                            TulipTextField(
                              controller: _titleController,
                              label: 'Title',
                              hint: 'e.g., Portland Spring Trip',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a title';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Stay Type dropdown
                            DropdownButtonFormField<String>(
                              value: _stayType,
                              decoration: InputDecoration(
                                labelText: 'Stay Type',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: TulipColors.taupeLight),
                                ),
                              ),
                              items: _stayTypes
                                  .map((t) => DropdownMenuItem(
                                        value: t.$1,
                                        child: Text(t.$2),
                                      ))
                                  .toList(),
                              onChanged: (value) => setState(() => _stayType = value),
                            ),
                            const SizedBox(height: 24),

                            // Location Section
                            Text('Location', style: TulipTextStyles.heading3),
                            const SizedBox(height: 12),

                            TulipTextField(
                              controller: _addressController,
                              label: 'Address',
                              hint: 'Street address (optional)',
                            ),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: TulipTextField(
                                    controller: _cityController,
                                    label: 'City',
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Required';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TulipTextField(
                                    controller: _stateController,
                                    label: 'State',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            TulipTextField(
                              controller: _countryController,
                              label: 'Country',
                            ),
                            const SizedBox(height: 24),

                            // Dates Section
                            Text('Dates', style: TulipTextStyles.heading3),
                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Expanded(
                                  child: _DatePickerField(
                                    label: 'Check-in',
                                    date: _checkIn,
                                    onTap: () => _selectDate(true),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _DatePickerField(
                                    label: 'Check-out',
                                    date: _checkOut,
                                    onTap: () => _selectDate(false),
                                  ),
                                ),
                              ],
                            ),
                            if (_checkIn != null && _checkOut != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  '${_checkOut!.difference(_checkIn!).inDays} nights',
                                  style: TulipTextStyles.bodySmall,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            const SizedBox(height: 24),

                            // Price Section
                            Text('Price', style: TulipTextStyles.heading3),
                            const SizedBox(height: 12),

                            Row(
                              children: [
                                SizedBox(
                                  width: 100,
                                  child: DropdownButtonFormField<String>(
                                    value: _currency,
                                    decoration: InputDecoration(
                                      labelText: 'Currency',
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: TulipColors.taupeLight),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 16,
                                      ),
                                    ),
                                    items: _currencies
                                        .map((c) => DropdownMenuItem(
                                              value: c,
                                              child: Text(c),
                                            ))
                                        .toList(),
                                    onChanged: (value) =>
                                        setState(() => _currency = value ?? 'USD'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TulipTextField(
                                    controller: _priceController,
                                    label: 'Total Price',
                                    hint: '0.00',
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Booking Section
                            Text('Booking', style: TulipTextStyles.heading3),
                            const SizedBox(height: 12),

                            CozyCard(
                              child: SwitchListTile(
                                value: _booked,
                                onChanged: (value) => setState(() => _booked = value),
                                title: Text('Booked', style: TulipTextStyles.label),
                                subtitle: Text(
                                  _booked
                                      ? 'This stay has been confirmed'
                                      : 'Mark as booked once confirmed',
                                  style: TulipTextStyles.caption,
                                ),
                                activeColor: TulipColors.sage,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            const SizedBox(height: 16),

                            TulipTextField(
                              controller: _bookingUrlController,
                              label: 'Booking URL',
                              hint: 'Link to reservation',
                              keyboardType: TextInputType.url,
                            ),
                            const SizedBox(height: 16),

                            TulipTextField(
                              controller: _imageUrlController,
                              label: 'Image URL',
                              hint: 'Link to property image',
                              keyboardType: TextInputType.url,
                            ),
                            const SizedBox(height: 24),

                            // Notes Section
                            Text('Notes', style: TulipTextStyles.heading3),
                            const SizedBox(height: 12),

                            TulipTextField(
                              controller: _notesController,
                              label: 'Notes',
                              hint: 'Any additional notes about this stay...',
                              maxLines: 4,
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Save Button
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: TulipColors.taupeLight),
                      ),
                    ),
                    child: TulipButton(
                      onPressed: formState.isLoading ? null : _handleSave,
                      isLoading: formState.isLoading,
                      label: isEditing ? 'Save Changes' : 'Create Stay',
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DatePickerField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return GestureDetector(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: TulipColors.taupeLight),
          ),
          suffixIcon: const Icon(
            Icons.calendar_today_outlined,
            color: TulipColors.brownLight,
          ),
        ),
        child: Text(
          date != null ? dateFormat.format(date!) : 'Select date',
          style: date != null
              ? TulipTextStyles.body
              : TulipTextStyles.bodySmall,
        ),
      ),
    );
  }
}
