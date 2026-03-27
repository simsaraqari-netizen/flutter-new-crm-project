import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';

class SearchFilterBar extends StatefulWidget {
  final String? initialQuery;
  final String? selectedPurpose;
  final String? selectedType;
  final String? selectedGovernorate;
  final ValueChanged<String> onSearch;
  final ValueChanged<String?> onPurposeChanged;
  final ValueChanged<String?> onTypeChanged;
  final ValueChanged<String?> onGovernorateChanged;
  final VoidCallback? onClearAll;

  const SearchFilterBar({
    super.key,
    this.initialQuery,
    this.selectedPurpose,
    this.selectedType,
    this.selectedGovernorate,
    required this.onSearch,
    required this.onPurposeChanged,
    required this.onTypeChanged,
    required this.onGovernorateChanged,
    this.onClearAll,
  });

  @override
  State<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends State<SearchFilterBar> {
  late TextEditingController _searchController;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasFilters = widget.selectedPurpose != null ||
        widget.selectedType != null ||
        widget.selectedGovernorate != null;

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.divider),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                const Icon(Icons.search, color: AppTheme.textMuted, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: widget.onSearch,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'ابحث عن عقار...',
                      hintStyle: TextStyle(color: AppTheme.textMuted),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                      fillColor: Colors.transparent,
                      filled: true,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
                // Filter toggle
                GestureDetector(
                  onTap: () => setState(() => _showFilters = !_showFilters),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Stack(
                      children: [
                        Icon(
                          Icons.tune,
                          color: _showFilters ? AppTheme.primaryBlue : AppTheme.textMuted,
                          size: 20,
                        ),
                        if (hasFilters)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppTheme.accentCyan,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ],
            ),
          ),
        ),

        // Filter chips
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: _buildFilterSection(hasFilters),
          crossFadeState: _showFilters ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }

  Widget _buildFilterSection(bool hasFilters) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Purpose chips
          _buildChipRow(
            label: 'الغرض',
            items: AppConstants.purposes,
            selected: widget.selectedPurpose,
            onSelected: widget.onPurposeChanged,
          ),
          const SizedBox(height: 8),
          // Type chips
          _buildChipRow(
            label: 'النوع',
            items: AppConstants.propertyTypes.take(6).toList(),
            selected: widget.selectedType,
            onSelected: widget.onTypeChanged,
          ),
          const SizedBox(height: 8),
          // Governorate chips
          _buildChipRow(
            label: 'المحافظة',
            items: AppConstants.governorates.keys.toList(),
            selected: widget.selectedGovernorate,
            onSelected: widget.onGovernorateChanged,
          ),
          if (hasFilters) ...[
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: widget.onClearAll,
                icon: const Icon(Icons.clear_all, size: 18),
                label: const Text('مسح الكل'),
                style: TextButton.styleFrom(foregroundColor: AppTheme.error),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChipRow({
    required String label,
    required List<String> items,
    String? selected,
    required ValueChanged<String?> onSelected,
  }) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (_, i) => const SizedBox(width: 8),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = item == selected;
          return GestureDetector(
            onTap: () => onSelected(isSelected ? null : item),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                gradient: isSelected ? AppTheme.primaryGradient : null,
                color: isSelected ? null : AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(20),
                border: isSelected ? null : Border.all(color: AppTheme.divider, width: 0.5),
              ),
              child: Text(
                item,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
