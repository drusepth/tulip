import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/tulip_colors.dart';
import '../../../../shared/constants/tulip_text_styles.dart';
import '../../../places/data/models/poi_model.dart';
import '../../../stays/data/models/stay_model.dart';

/// Bottom popup widget shown when a POI marker is tapped.
class PoiPopup extends StatelessWidget {
  final Poi poi;
  final Stay? nearestStay;
  final VoidCallback onClose;
  final Future<bool> Function(Stay stay)? onAddToBucketList;

  const PoiPopup({
    super.key,
    required this.poi,
    this.nearestStay,
    required this.onClose,
    this.onAddToBucketList,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with category badge and close button
          Row(
            children: [
              _buildCategoryBadge(),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: onClose,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: TulipColors.brownLight,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // POI name
          Text(
            poi.name,
            style: TulipTextStyles.heading3,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          // Address
          if (poi.address != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: TulipColors.brownLight,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    poi.address!,
                    style: TulipTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],

          // Distance and rating row
          const SizedBox(height: 8),
          Row(
            children: [
              // Distance
              if (poi.distanceFormatted != null) ...[
                Icon(
                  Icons.directions_walk,
                  size: 14,
                  color: TulipColors.brownLight,
                ),
                const SizedBox(width: 4),
                Text(
                  poi.distanceFormatted!,
                  style: TulipTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
              ],

              // Foursquare rating
              if (poi.foursquareRating != null) ...[
                Icon(
                  Icons.star,
                  size: 14,
                  color: TulipColors.coral,
                ),
                const SizedBox(width: 4),
                Text(
                  poi.foursquareRating!.toStringAsFixed(1),
                  style: TulipTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
              ],

              // Price level
              if (poi.priceDisplay != null)
                Text(
                  poi.priceDisplay!,
                  style: TulipTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w500,
                    color: TulipColors.sage,
                  ),
                ),
            ],
          ),

          // Opening hours
          if (poi.openingHours != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: TulipColors.brownLight,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    poi.openingHours!,
                    style: TulipTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              // View Details button (only if placeId exists)
              if (poi.placeId != null) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      context.push('/places/${poi.placeId}');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: TulipColors.sage,
                      side: const BorderSide(color: TulipColors.sage),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('View Details'),
                  ),
                ),
                const SizedBox(width: 8),
              ],

              // Add to Bucket List button
              if (nearestStay != null)
                Expanded(
                  child: _AddToBucketListButton(
                    poi: poi,
                    stay: nearestStay!,
                    onAdd: onAddToBucketList,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge() {
    final (bgColor, textColor) = _getCategoryColors(poi.category);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getCategoryIcon(poi.category),
            size: 14,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            poi.categoryDisplay,
            style: TulipTextStyles.caption.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color) _getCategoryColors(String category) {
    switch (category.toLowerCase()) {
      case 'coffee':
        return (TulipColors.taupeLight, TulipColors.taupeDark);
      case 'restaurants':
        return (TulipColors.roseLight, TulipColors.roseDark);
      case 'grocery':
        return (TulipColors.sageLight, TulipColors.sageDark);
      case 'bars':
        return (TulipColors.lavenderLight, TulipColors.lavenderDark);
      case 'gyms':
        return (const Color(0xFFE8F0FE), const Color(0xFF1A73E8));
      case 'parks':
        return (TulipColors.sageLight, TulipColors.sageDark);
      case 'transit':
        return (const Color(0xFFFEE8E8), const Color(0xFFD32F2F));
      case 'attractions':
        return (TulipColors.lavenderLight, TulipColors.lavenderDark);
      default:
        return (TulipColors.taupeLight, TulipColors.taupeDark);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'coffee':
        return Icons.coffee;
      case 'restaurants':
        return Icons.restaurant;
      case 'grocery':
        return Icons.shopping_cart;
      case 'bars':
        return Icons.local_bar;
      case 'gyms':
        return Icons.fitness_center;
      case 'parks':
        return Icons.park;
      case 'transit':
        return Icons.directions_transit;
      case 'attractions':
        return Icons.museum;
      default:
        return Icons.place;
    }
  }
}

/// Button that handles adding a POI to a stay's bucket list with loading states.
class _AddToBucketListButton extends StatefulWidget {
  final Poi poi;
  final Stay stay;
  final Future<bool> Function(Stay stay)? onAdd;

  const _AddToBucketListButton({
    required this.poi,
    required this.stay,
    this.onAdd,
  });

  @override
  State<_AddToBucketListButton> createState() => _AddToBucketListButtonState();
}

class _AddToBucketListButtonState extends State<_AddToBucketListButton> {
  bool _isLoading = false;
  bool _isSuccess = false;

  Future<void> _handleAdd() async {
    if (_isLoading || _isSuccess || widget.onAdd == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await widget.onAdd!(widget.stay);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSuccess = success;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSuccess) {
      return ElevatedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.check, size: 18),
        label: const Text('Added!'),
        style: ElevatedButton.styleFrom(
          backgroundColor: TulipColors.sage,
          foregroundColor: Colors.white,
          disabledBackgroundColor: TulipColors.sage,
          disabledForegroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: _isLoading ? null : _handleAdd,
      icon: _isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.add, size: 18),
      label: Text(_isLoading ? 'Adding...' : 'Add to Bucket List'),
      style: ElevatedButton.styleFrom(
        backgroundColor: TulipColors.sage,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
