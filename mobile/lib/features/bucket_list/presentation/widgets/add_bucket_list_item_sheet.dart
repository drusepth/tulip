import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/constants/tulip_colors.dart';
import '../../../../shared/constants/tulip_text_styles.dart';
import '../../../places/data/models/gallery_item_model.dart';
import '../../../places/presentation/providers/gallery_provider.dart';
import '../../data/models/bucket_list_item_model.dart';
import '../providers/bucket_list_provider.dart';

class AddBucketListItemSheet extends ConsumerStatefulWidget {
  final int stayId;

  const AddBucketListItemSheet({super.key, required this.stayId});

  @override
  ConsumerState<AddBucketListItemSheet> createState() =>
      _AddBucketListItemSheetState();
}

class _AddBucketListItemSheetState
    extends ConsumerState<AddBucketListItemSheet> {
  final _titleController = TextEditingController();
  final _titleFocusNode = FocusNode();

  List<GalleryItem> _suggestions = [];
  bool _showSuggestions = false;
  int? _selectedPlaceId;
  String? _selectedCategory;
  String? _selectedAddress;
  double? _selectedLat;
  double? _selectedLng;
  String? _selectedPlaceName;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onTitleChanged);
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
    _titleController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  void _onTitleChanged() {
    final query = _titleController.text.trim();

    // If user edits the title after selecting a place, clear the link
    if (_selectedPlaceName != null && query != _selectedPlaceName) {
      _selectedPlaceId = null;
      _selectedCategory = null;
      _selectedAddress = null;
      _selectedLat = null;
      _selectedLng = null;
      _selectedPlaceName = null;
    }

    if (query.length < 2) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    final galleryState = ref.read(galleryProvider(widget.stayId));
    final allItems = galleryState.valueOrNull?.items ?? [];

    final lowerQuery = query.toLowerCase();
    final filtered = allItems
        .where((item) => item.name.toLowerCase().contains(lowerQuery))
        .take(6)
        .toList();

    setState(() {
      _suggestions = filtered;
      _showSuggestions = filtered.isNotEmpty;
    });
  }

  void _selectSuggestion(GalleryItem item) {
    setState(() {
      _titleController.text = item.name;
      _selectedPlaceId = item.id;
      _selectedPlaceName = item.name;
      _selectedCategory = _mapPlaceCategory(item.category);
      _selectedAddress = item.address;
      _selectedLat = item.latitude;
      _selectedLng = item.longitude;
      _suggestions = [];
      _showSuggestions = false;
    });
    // Move cursor to end of text
    _titleController.selection = TextSelection.fromPosition(
      TextPosition(offset: _titleController.text.length),
    );
  }

  String _mapPlaceCategory(String placeCategory) {
    switch (placeCategory.toLowerCase()) {
      case 'coffee':
      case 'food':
      case 'restaurant':
      case 'restaurants':
        return 'restaurant';
      case 'grocery':
        return 'shopping';
      case 'gym':
      case 'gyms':
      case 'coworking':
        return 'activity';
      case 'library':
        return 'activity';
      case 'parks':
      case 'park':
        return 'nature';
      case 'bars':
      case 'bar':
        return 'nightlife';
      case 'attractions':
        return 'landmark';
      default:
        return 'other';
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'coffee':
        return Icons.coffee;
      case 'restaurants':
      case 'restaurant':
      case 'food':
        return Icons.restaurant;
      case 'grocery':
        return Icons.shopping_cart;
      case 'bars':
      case 'bar':
        return Icons.local_bar;
      case 'gyms':
      case 'gym':
        return Icons.fitness_center;
      case 'parks':
      case 'park':
        return Icons.park;
      case 'coworking':
        return Icons.laptop_mac;
      case 'library':
        return Icons.menu_book;
      case 'attractions':
        return Icons.museum;
      default:
        return Icons.place;
    }
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    setState(() => _isSubmitting = true);

    final request = BucketListItemRequest(
      title: title,
      category: _selectedCategory,
      address: _selectedAddress,
      latitude: _selectedLat,
      longitude: _selectedLng,
      placeId: _selectedPlaceId,
    );

    await ref
        .read(bucketListProvider(widget.stayId).notifier)
        .createItem(request);

    // Mark the place as "in bucket list" in the gallery if applicable
    if (_selectedPlaceId != null) {
      ref
          .read(galleryProvider(widget.stayId).notifier)
          .updateItemBucketList(_selectedPlaceId!, true);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: TulipColors.taupeLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: TulipColors.sageLight,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.checklist_rounded,
                      color: TulipColors.sageDark,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Add to Bucket List', style: TulipTextStyles.heading3),
                ],
              ),
              const SizedBox(height: 20),

              // Title input label
              Text(
                'What do you want to do?',
                style: TulipTextStyles.label,
              ),
              const SizedBox(height: 8),

              // Title input
              TextField(
                controller: _titleController,
                focusNode: _titleFocusNode,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                style: TulipTextStyles.body,
                decoration: InputDecoration(
                  hintText: 'e.g. Visit the local market',
                  hintStyle: TulipTextStyles.bodySmall.copyWith(
                    color: TulipColors.brownLighter,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: TulipColors.taupeLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: TulipColors.taupeLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: TulipColors.sage, width: 2),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  suffixIcon: _selectedPlaceId != null
                      ? Icon(Icons.place, color: TulipColors.sage, size: 20)
                      : null,
                ),
                onSubmitted: (_) => _submit(),
              ),

              // Autocomplete suggestions
              if (_showSuggestions) _buildSuggestionsList(),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed:
                          _isSubmitting ? null : () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: TulipColors.brownLight,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _submit,
                      icon: _isSubmitting
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.add, size: 18),
                      label: Text(_isSubmitting ? 'Adding...' : 'Add to List'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TulipColors.sage,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionsList() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TulipColors.taupeLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      constraints: const BoxConstraints(maxHeight: 240),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: _suggestions.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            color: TulipColors.taupeLight.withAlpha(128),
          ),
          itemBuilder: (context, index) {
            final item = _suggestions[index];
            return _buildSuggestionTile(item);
          },
        ),
      ),
    );
  }

  Widget _buildSuggestionTile(GalleryItem item) {
    return InkWell(
      onTap: () => _selectSuggestion(item),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            // Category icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: TulipColors.lavenderLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getCategoryIcon(item.category),
                size: 16,
                color: TulipColors.lavenderDark,
              ),
            ),
            const SizedBox(width: 12),

            // Name and address
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TulipTextStyles.body.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.address != null)
                    Text(
                      item.address!,
                      style: TulipTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

            // Distance
            if (item.distanceFormatted != null) ...[
              const SizedBox(width: 8),
              Text(
                item.distanceFormatted!,
                style: TulipTextStyles.caption.copyWith(
                  color: TulipColors.sage,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
