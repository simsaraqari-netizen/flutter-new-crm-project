import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/property.dart';
import '../../providers/favorites_provider.dart';
import '../../utils/theme.dart';

class PropertyDetailScreen extends ConsumerWidget {
  final Property property;

  const PropertyDetailScreen({super.key, required this.property});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favState = ref.watch(favoritesProvider);
    final isFav = favState.isFavorite(property.id);

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: CustomScrollView(
        slivers: [
          // Image Gallery
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.primaryDark,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () => ref.read(favoritesProvider.notifier).toggleFavorite(property.id),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? AppTheme.error : Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildGallery(),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: AppTheme.primaryDark,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title & Status
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            property.title,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              height: 1.4,
                            ),
                          ),
                        ),
                        if (property.isSold)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppTheme.error,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'تم البيع',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Price card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.monetization_on_outlined, color: Colors.white, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            property.displayPrice,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tags row
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (property.purpose != null)
                          _buildTag(property.purpose!, Icons.flag_outlined, AppTheme.accentGold),
                        if (property.type != null)
                          _buildTag(property.type!, Icons.home_outlined, AppTheme.primaryBlue),
                        if (property.pt != null)
                          _buildTag(property.pt!, Icons.category_outlined, AppTheme.accentCyan),
                        if (property.status != null)
                          _buildTag(property.status!, Icons.info_outline, AppTheme.success),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Location section
                    _buildSectionTitle('الموقع', Icons.location_on_outlined),
                    const SizedBox(height: 12),
                    _buildInfoGrid([
                      if (property.gov != null) _InfoItem('المحافظة', property.gov!),
                      if (property.loc != null) _InfoItem('المنطقة', property.loc!),
                      if (property.sector != null) _InfoItem('القطاع', property.sector!),
                      if (property.block != null) _InfoItem('القطعة', property.block!),
                      if (property.street != null) _InfoItem('الشارع', property.street!),
                      if (property.avenue != null) _InfoItem('الجادة', property.avenue!),
                      if (property.plotNumber != null) _InfoItem('رقم القسيمة', property.plotNumber!),
                      if (property.houseNumber != null) _InfoItem('رقم المنزل', property.houseNumber!),
                      if (property.location != null) _InfoItem('العنوان', property.location!),
                    ]),

                    if (property.details != null && property.details!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildSectionTitle('التفاصيل', Icons.description_outlined),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.divider),
                        ),
                        child: Text(
                          property.details!,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],

                    if (property.description != null && property.description!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildSectionTitle('الوصف', Icons.notes_outlined),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.divider),
                        ),
                        child: Text(
                          property.description!,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],

                    if (property.lastComment != null && property.lastComment!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildSectionTitle('آخر تعليق', Icons.comment_outlined),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.divider),
                        ),
                        child: Text(
                          property.lastComment!,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],

                    // Seller info
                    if (property.seller != null) ...[
                      const SizedBox(height: 24),
                      _buildSectionTitle('البائع', Icons.person_outlined),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.divider),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.person, color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                property.seller!,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 100), // Bottom padding for action bar
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // Bottom action bar
      bottomNavigationBar: property.phone != null && property.phone!.isNotEmpty
          ? Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                border: Border(top: BorderSide(color: AppTheme.divider)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.phone,
                      label: 'اتصال',
                      color: AppTheme.success,
                      onTap: () => _callPhone(property.phone!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.message,
                      label: 'واتساب',
                      color: const Color(0xFF25D366),
                      onTap: () => _openWhatsApp(property.phone!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildActionButton(
                    icon: Icons.share_outlined,
                    label: '',
                    color: AppTheme.primaryBlue,
                    onTap: () => _shareProperty(),
                    compact: true,
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildGallery() {
    if (property.images.isEmpty && property.photo == null) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryBlue.withValues(alpha: 0.3),
              AppTheme.accentCyan.withValues(alpha: 0.1),
              AppTheme.primaryDark,
            ],
          ),
        ),
        child: const Center(
          child: Icon(Icons.home_work_rounded, size: 80, color: AppTheme.textMuted),
        ),
      );
    }

    final imageUrls = property.images.isNotEmpty
        ? property.images
        : [property.photo!];

    if (imageUrls.length == 1) {
      return CachedNetworkImage(
        imageUrl: imageUrls.first,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 300,
        errorWidget: (_, e1, e2) => Container(
          color: AppTheme.surfaceElevated,
          child: const Icon(Icons.image_not_supported, color: AppTheme.textMuted, size: 60),
        ),
      );
    }

    return PageView.builder(
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return CachedNetworkImage(
          imageUrl: imageUrls[index],
          fit: BoxFit.cover,
          width: double.infinity,
          errorWidget: (_, e1, e2) => Container(
            color: AppTheme.surfaceElevated,
            child: const Icon(Icons.image_not_supported, color: AppTheme.textMuted, size: 60),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.accentCyan),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoGrid(List<_InfoItem> items) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Wrap(
        spacing: 0,
        runSpacing: 12,
        children: items.map((item) {
          return SizedBox(
            width: 180,
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppTheme.accentCyan,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${item.label}: ',
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
                Expanded(
                  child: Text(
                    item.value,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTag(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool compact = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 14 : 0,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _callPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void _openWhatsApp(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    final whatsappPhone = cleanPhone.startsWith('965') ? cleanPhone : '965$cleanPhone';
    final uri = Uri.parse('https://wa.me/$whatsappPhone');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _shareProperty() {
    // Share functionality placeholder
  }
}

class _InfoItem {
  final String label;
  final String value;
  _InfoItem(this.label, this.value);
}
