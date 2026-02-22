import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/tulip_text_styles.dart';
import '../../../../shared/widgets/tulip_button.dart';
import '../../../../shared/widgets/tulip_text_field.dart';

class StayFormScreen extends ConsumerStatefulWidget {
  final int? stayId;

  const StayFormScreen({super.key, this.stayId});

  @override
  ConsumerState<StayFormScreen> createState() => _StayFormScreenState();
}

class _StayFormScreenState extends ConsumerState<StayFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();

  bool get isEditing => widget.stayId != null;

  @override
  void dispose() {
    _titleController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;
    // TODO: Save stay via API
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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

                TulipTextField(
                  controller: _cityController,
                  label: 'City',
                  hint: 'e.g., Portland',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a city';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TulipTextField(
                  controller: _countryController,
                  label: 'Country',
                  hint: 'e.g., USA',
                ),
                const SizedBox(height: 24),

                // More fields will be added here
                Text(
                  'More options coming soon...',
                  style: TulipTextStyles.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                TulipButton(
                  onPressed: _handleSave,
                  label: isEditing ? 'Save Changes' : 'Create Stay',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
