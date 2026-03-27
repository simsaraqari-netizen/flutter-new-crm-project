import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final profile = authState.profile;
    final isLoggedIn = authState.isLoggedIn;

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Avatar
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 16),

              // Name
              Text(
                profile?.name ?? 'مستخدم',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                profile?.phone ?? authState.user?.phone ?? '',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
              if (profile?.role != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentCyan.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    profile!.role == 'admin'
                        ? 'مدير'
                        : profile.role == 'agent'
                            ? 'وكيل'
                            : 'مستخدم',
                    style: const TextStyle(
                      color: AppTheme.accentCyan,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),

              // Profile details card
              if (profile != null) ...[
                _buildInfoCard([
                  if (profile.email != null) _InfoRow(Icons.email_outlined, 'البريد', profile.email!),
                  if (profile.companyName != null) _InfoRow(Icons.business, 'الشركة', profile.companyName!),
                  if (profile.whatsapp != null) _InfoRow(Icons.message, 'واتساب', profile.whatsapp!),
                  if (profile.bio != null) _InfoRow(Icons.info_outline, 'نبذة', profile.bio!),
                ]),
                const SizedBox(height: 16),
              ],

              // Menu items
              _buildMenuCard([
                _MenuItem(
                  icon: Icons.edit_outlined,
                  title: 'تعديل الملف الشخصي',
                  onTap: () => _showEditProfileDialog(context),
                ),
                _MenuItem(
                  icon: Icons.notifications_outlined,
                  title: 'الإشعارات',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.language,
                  title: 'اللغة',
                  subtitle: 'عربي',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.info_outline,
                  title: 'عن التطبيق',
                  onTap: () {},
                ),
              ]),

              const SizedBox(height: 16),

              if (isLoggedIn)
                _buildMenuCard([
                  _MenuItem(
                    icon: Icons.logout,
                    title: 'تسجيل الخروج',
                    color: AppTheme.error,
                    onTap: () => _confirmSignOut(context),
                  ),
                ]),
              
              if (!isLoggedIn)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    icon: const Icon(Icons.login),
                    label: const Text('تسجيل الدخول'),
                  ),
                ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<_InfoRow> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Icon(item.icon, size: 18, color: AppTheme.accentCyan),
                const SizedBox(width: 12),
                Text(item.label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                const Spacer(),
                Flexible(
                  child: Text(
                    item.value,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
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

  Widget _buildMenuCard(List<_MenuItem> items) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Column(
            children: [
              ListTile(
                leading: Icon(item.icon, color: item.color ?? AppTheme.textSecondary, size: 22),
                title: Text(
                  item.title,
                  style: TextStyle(
                    color: item.color ?? AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: item.subtitle != null
                    ? Text(item.subtitle!, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12))
                    : null,
                trailing: Icon(Icons.arrow_forward_ios, size: 14, color: item.color ?? AppTheme.textMuted),
                onTap: item.onTap,
              ),
              if (index < items.length - 1)
                const Divider(height: 1, indent: 56, color: AppTheme.divider),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final profile = ref.read(authProvider).profile;
    final nameController = TextEditingController(text: profile?.name ?? '');
    final companyController = TextEditingController(text: profile?.companyName ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.divider, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text('تعديل الملف الشخصي', style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            TextFormField(
              controller: nameController,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(labelText: 'الاسم', labelStyle: TextStyle(color: AppTheme.textMuted)),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: companyController,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(labelText: 'اسم الشركة', labelStyle: TextStyle(color: AppTheme.textMuted)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(authProvider.notifier).updateProfile({
                    'name': nameController.text.trim(),
                    'company_name': companyController.text.trim(),
                  });
                  Navigator.pop(ctx);
                },
                child: const Text('حفظ'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        title: const Text('تسجيل الخروج', style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟', style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).signOut();
            },
            child: const Text('خروج', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}

class _InfoRow {
  final IconData icon;
  final String label;
  final String value;
  _InfoRow(this.icon, this.label, this.value);
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? color;
  final VoidCallback onTap;
  _MenuItem({required this.icon, required this.title, this.subtitle, this.color, required this.onTap});
}
