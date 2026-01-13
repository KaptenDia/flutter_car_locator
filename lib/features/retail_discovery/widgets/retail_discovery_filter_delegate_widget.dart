import 'package:flutter/material.dart';
import 'package:flutter_car_locator/core/constants/app_constants.dart';
import 'package:flutter_car_locator/core/models/campaign_pin_model.dart';

class RetailDiscoveryFilterDelegate extends SliverPersistentHeaderDelegate {
  final CampaignType? selectedType;
  final bool showExclusiveOnly;
  final Function(CampaignType?) onTypeSelected;
  final Function(bool) onExclusiveChanged;
  final int Function(CampaignType) getCampaignTypeColor;

  RetailDiscoveryFilterDelegate({
    required this.selectedType,
    required this.showExclusiveOnly,
    required this.onTypeSelected,
    required this.onExclusiveChanged,
    required this.getCampaignTypeColor,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.grey[50],
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              label: 'All',
              isSelected: selectedType == null,
              onTap: () => onTypeSelected(null),
            ),
            ...CampaignType.values.map(
              (type) => _buildFilterChip(
                label: type.name.toUpperCase(),
                isSelected: selectedType == type,
                onTap: () => onTypeSelected(type),
                color: Color(getCampaignTypeColor(type)),
              ),
            ),
            _buildFilterChip(
              label: 'EXCLUSIVE',
              isSelected: showExclusiveOnly,
              onTap: () => onExclusiveChanged(!showExclusiveOnly),
              color: const Color(AppColors.exclusiveColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor:
            color?.withAlpha(51) ??
            const Color(AppColors.primaryColor).withAlpha(51),
        checkmarkColor: color ?? const Color(AppColors.primaryColor),
        labelStyle: TextStyle(
          color: isSelected
              ? (color ?? const Color(AppColors.primaryColor))
              : Colors.grey[600],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  @override
  double get maxExtent => 70;

  @override
  double get minExtent => 70;

  @override
  bool shouldRebuild(covariant RetailDiscoveryFilterDelegate oldDelegate) {
    return oldDelegate.selectedType != selectedType ||
        oldDelegate.showExclusiveOnly != showExclusiveOnly;
  }
}
