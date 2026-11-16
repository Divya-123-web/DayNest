import 'package:daynest/screens/models/user_model.dart';
import 'package:daynest/theme/app-colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../statistics/statistics_screen.dart';

/// The theme options shown in the settings.
enum ThemeChoice { light, dark, system }

extension ThemeChoiceX on ThemeChoice {
  String get label {
    switch (this) {
      case ThemeChoice.light:
        return 'Light';
      case ThemeChoice.dark:
        return 'Dark';
      case ThemeChoice.system:
        return 'System';
    }
  }

  IconData get icon {
    switch (this) {
      case ThemeChoice.light:
        return Icons.light_mode_rounded;
      case ThemeChoice.dark:
        return Icons.dark_mode_rounded;
      case ThemeChoice.system:
        return Icons.phone_android_rounded;
    }
  }
}

/// The Profile tab: user details, statistics link, account info,
/// theme preference, about and log out.
/// The user details come from AuthProvider.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Light is the primary theme. This choice is only shown on screen for now.
  ThemeChoice _themeChoice = ThemeChoice.light;

  // Opens the Statistics screen on top of the tabs.
  void _openStatistics() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const StatisticsScreen()),
    );
  }

  // Shows a small dialog to change the display name.
  // The dialog manages its own text controller (see _EditNameDialog).
  Future<void> _editName(String currentName) async {
    final String? newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => _EditNameDialog(initialName: currentName),
    );

    if (newName == null || !mounted) return;
    context.read<AuthProvider>().updateName(newName);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Name updated')),
    );
  }

  // Asks for confirmation, logs out, then goes back to the Login screen.
  Future<void> _confirmLogout() async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.warmCream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Log out?',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              color: AppColors.darkBrown,
            ),
          ),
          content: Text(
            'You will need to log in again to see your tasks and notes.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.priorityHigh,
              ),
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true || !mounted) return;

    // Clear the signed-in user first, then show the Login screen.
    await context.read<AuthProvider>().logout();
    if (!mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  // Opens the built-in About dialog.
  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'Daynest',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.peach, AppColors.terracotta],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.check_rounded, color: AppColors.white),
      ),
      children: [
        Text(
          'Cloud-connected notes and todo app with Firebase sync.',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
      ],
    );
  }

  // Small grey section title.
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // watch: this screen updates when the name changes.
    final UserModel? user = context.watch<AuthProvider>().user;

    final String name = user?.name ?? 'Friend';
    final String email = user?.email ?? '';
    final String initial = user?.initial ?? 'D';
    final DateTime memberSince = user?.createdAt ?? DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile',
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkBrown,
                ),
              ),
              const SizedBox(height: 20),

              // User card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.peach,
                      child: Text(
                        initial,
                        style: GoogleFonts.poppins(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkBrown,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkBrown,
                      ),
                    ),
                    Text(
                      email,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: () => _editName(name),
                      icon: const Icon(Icons.edit_rounded, size: 18),
                      label: const Text('Edit name'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.terracotta,
                        side: const BorderSide(color: AppColors.terracotta),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Statistics shortcut
              _SettingsTile(
                icon: Icons.bar_chart_rounded,
                title: 'Productivity Statistics',
                subtitle: 'See your weekly progress',
                onTap: _openStatistics,
              ),
              const SizedBox(height: 28),

              // Account information
              _sectionTitle('Account'),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.person_outline_rounded,
                      label: 'Name',
                      value: name,
                    ),
                    const Divider(height: 1, color: AppColors.softBeige),
                    _InfoRow(
                      icon: Icons.mail_outline_rounded,
                      label: 'Email',
                      value: email,
                    ),
                    const Divider(height: 1, color: AppColors.softBeige),
                    _InfoRow(
                      icon: Icons.calendar_today_rounded,
                      label: 'Member since',
                      value: DateFormat('d MMM yyyy').format(memberSince),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Theme preference
              _sectionTitle('Theme'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: ThemeChoice.values.map((choice) {
                        final bool isSelected = choice == _themeChoice;
                        return ChoiceChip(
                          avatar: Icon(
                            choice.icon,
                            size: 18,
                            color: isSelected
                                ? AppColors.white
                                : AppColors.terracotta,
                          ),
                          label: Text(choice.label),
                          selected: isSelected,
                          showCheckmark: false,
                          onSelected: (_) =>
                              setState(() => _themeChoice = choice),
                          selectedColor: AppColors.terracotta,
                          backgroundColor: AppColors.warmCream,
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.terracotta
                                : AppColors.softBeige,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          labelStyle: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.white
                                : AppColors.darkBrown,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Light is the main theme. A dark theme is not '
                      'available yet.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        height: 1.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // About
              _SettingsTile(
                icon: Icons.info_outline_rounded,
                title: 'About Daynest',
                subtitle: 'Version 1.0.0',
                onTap: _showAbout,
              ),
              const SizedBox(height: 28),

              // Log out
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _confirmLogout,
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Log Out'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 54),
                    foregroundColor: AppColors.priorityHigh,
                    side: const BorderSide(
                      color: AppColors.priorityHigh,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The "Edit name" dialog.
/// It is its own widget so it creates and disposes its own text controller
/// at the right time.
class _EditNameDialog extends StatefulWidget {
  final String initialName;

  const _EditNameDialog({required this.initialName});

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Sends the new name back, ignoring an empty name.
  void _save() {
    final String value = _controller.text.trim();
    if (value.isEmpty) return;
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.warmCream,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      title: Text(
        'Edit name',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
          color: AppColors.darkBrown,
        ),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _save(),
        style: GoogleFonts.poppins(
          fontSize: 15,
          color: AppColors.darkBrown,
        ),
        decoration: const InputDecoration(hintText: 'Your name'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

/// White tappable row with an icon, a title and a subtitle.
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.lightApricot,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: AppColors.terracotta, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkBrown,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One line in the Account card: icon, label and value.
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.terracotta),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.darkBrown,
              ),
            ),
          ),
        ],
      ),
    );
  }
}