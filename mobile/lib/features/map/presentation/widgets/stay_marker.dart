import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../shared/constants/tulip_colors.dart';
import '../../../../shared/constants/tulip_text_styles.dart';
import '../../../stays/data/models/stay_model.dart';

/// Creates a Marker for a Stay with appropriate styling
class StayMarkerBuilder {
  /// Build a marker for a stay
  static Marker build({
    required Stay stay,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    if (stay.latitude == null || stay.longitude == null) {
      throw ArgumentError('Stay must have coordinates');
    }

    return Marker(
      point: LatLng(stay.latitude!, stay.longitude!),
      width: isSelected ? 48 : 40,
      height: isSelected ? 48 : 40,
      child: GestureDetector(
        onTap: onTap,
        child: _StayMarkerIcon(
          stay: stay,
          isSelected: isSelected,
        ),
      ),
    );
  }

  /// Build markers for multiple stays
  static List<Marker> buildAll({
    required List<Stay> stays,
    required void Function(Stay stay) onTap,
    int? selectedStayId,
  }) {
    return stays
        .where((stay) => stay.hasCoordinates)
        .map((stay) => build(
              stay: stay,
              onTap: () => onTap(stay),
              isSelected: stay.id == selectedStayId,
            ))
        .toList();
  }
}

class _StayMarkerIcon extends StatelessWidget {
  final Stay stay;
  final bool isSelected;

  const _StayMarkerIcon({
    required this.stay,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();
    final size = isSelected ? 48.0 : 40.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: isSelected ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: isSelected ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        _getIcon(),
        color: Colors.white,
        size: isSelected ? 24 : 20,
      ),
    );
  }

  Color _getStatusColor() {
    switch (stay.status) {
      case 'current':
        return TulipColors.lavender;
      case 'upcoming':
        return TulipColors.sage;
      case 'past':
        return TulipColors.taupe;
      default:
        return TulipColors.sage;
    }
  }

  IconData _getIcon() {
    switch (stay.stayType) {
      case 'hotel':
        return Icons.hotel;
      case 'hostel':
        return Icons.night_shelter;
      case 'friend':
        return Icons.people;
      case 'airbnb':
      default:
        return Icons.home;
    }
  }
}

/// Floating card shown when a stay marker is tapped
class StayMarkerPopup extends StatelessWidget {
  final Stay stay;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const StayMarkerPopup({
    super.key,
    required this.stay,
    required this.onTap,
    required this.onClose,
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
          Row(
            children: [
              Expanded(
                child: Text(
                  stay.title,
                  style: TulipTextStyles.heading3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: onClose,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: TulipColors.brownLight,
              ),
            ],
          ),
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
                  stay.location,
                  style: TulipTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (stay.dateRange != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: TulipColors.brownLight,
                ),
                const SizedBox(width: 4),
                Text(
                  stay.dateRange!,
                  style: TulipTextStyles.caption,
                ),
                const SizedBox(width: 8),
                _buildStatusBadge(),
              ],
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: TulipColors.sage,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('View Details'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color bgColor;
    Color textColor;
    String label;

    switch (stay.status) {
      case 'current':
        bgColor = TulipColors.lavenderLight;
        textColor = TulipColors.lavenderDark;
        label = 'Current';
        break;
      case 'upcoming':
        bgColor = TulipColors.sageLight;
        textColor = TulipColors.sageDark;
        label = 'Upcoming';
        break;
      case 'past':
        bgColor = TulipColors.taupeLight;
        textColor = TulipColors.taupeDark;
        label = 'Past';
        break;
      default:
        bgColor = TulipColors.taupeLight;
        textColor = TulipColors.taupeDark;
        label = stay.status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TulipTextStyles.caption.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
