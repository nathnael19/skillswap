import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/features/home/domain/models/user_model.dart';
import 'package:skillswap/features/home/presentation/cubits/profile_cubit.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_state.dart';
import 'package:skillswap/features/auth/presentation/pages/login_page.dart';
import 'package:skillswap/features/home/presentation/pages/identity_verification_page.dart';

class EditProfilePage extends StatefulWidget {
  final User user;
  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Premium Color Palette
  static const Color kBackground = Color(0xFF0C0A09);
  static const Color kAccent = Color(0xFFCA8A04);
  static const Color kSurface = Color(0xFF1C1917);
  static const Color kBorder = Color(0xFF292524);
  static const Color kText = Colors.white;
  static const Color kTextMuted = Color(0xFFA8A29E);

  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  late final TextEditingController _professionController;
  late final TextEditingController _bioController;
  late List<Skill> _userSkills;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _locationController = TextEditingController(text: widget.user.location);
    _professionController = TextEditingController(text: widget.user.profession);
    _bioController = TextEditingController(text: widget.user.bio);
    _userSkills = List.from(widget.user.allSkills);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _professionController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _addSkill(String name, String type) {
    setState(() {
      _userSkills.add(Skill(name: name, type: type, category: 'General'));
    });
  }

  void _removeSkill(Skill skill) {
    setState(() {
      _userSkills.remove(skill);
    });
  }

  void _showAddSkillDialog(String type) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1917),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Add ${type == 'teach' ? 'Skill to Teach' : 'Skill to Learn'}',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w900,
            fontSize: 14,
            color: kAccent,
            letterSpacing: 1.5,
          ),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Skill name (e.g. Flutter)',
            hintStyle: GoogleFonts.dmSans(color: Colors.white.withValues(alpha: 0.2)),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.03),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: kAccent),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.dmSans(
                color: kTextMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _addSkill(controller.text, type);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              'Add',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  void _onSave() {
    final updatedUser = User(
      id: widget.user.id,
      name: _nameController.text,
      age: widget.user.age,
      rating: widget.user.rating,
      imageUrl: widget.user.imageUrl,
      bio: _bioController.text,
      location: _locationController.text,
      profession: _professionController.text,
      allSkills: _userSkills,
      teaching: _userSkills.any((s) => s.type == 'teach')
          ? _userSkills.firstWhere((s) => s.type == 'teach')
          : null,
      learning: _userSkills.any((s) => s.type == 'learn')
          ? _userSkills.firstWhere((s) => s.type == 'learn')
          : null,
    );
    context.read<ProfileCubit>().updateUserProfile(updatedUser);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          Navigator.of(
            context,
          ).pushAndRemoveUntil(LoginPage.route(), (route) => false);
        }
      },
      child: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully!')),
            );
            Navigator.pop(context);
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
          }
        },
        builder: (context, state) {
          final isLoading = state is ProfileLoading;

          return Scaffold(
            backgroundColor: kBackground,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: kText,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Edit Profile',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: kAccent,
                  letterSpacing: 2.0,
                ),
              ),
              centerTitle: true,
              actions: [
                if (isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: kAccent,
                        ),
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: TextButton(
                      onPressed: _onSave,
                      style: TextButton.styleFrom(
                        foregroundColor: kAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: Text(
                        'Save',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: kAccent,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildAvatarEditor(),
                  const SizedBox(height: 16),
                  Text(
                    'Change Photo',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: kAccent,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 48),
                  _buildInputField(
                    'Full Name',
                    _nameController,
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 20),
                  _buildInputField(
                    'Profession',
                    _professionController,
                    icon: Icons.work_outline_rounded,
                  ),
                  const SizedBox(height: 20),
                  _buildInputField(
                    'Location',
                    _locationController,
                    icon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 20),
                  _buildInputField(
                    'Bio',
                    _bioController,
                    maxLines: 4,
                    icon: Icons.description_outlined,
                  ),
                  const SizedBox(height: 40),
                  _buildExpertiseSection(
                    'Teaching',
                    _userSkills.where((s) => s.type == 'teach').toList(),
                    kAccent.withValues(alpha: 0.1),
                    kAccent,
                    onAdd: () => _showAddSkillDialog('teach'),
                    onRemove: _removeSkill,
                  ),
                  const SizedBox(height: 32),
                  _buildExpertiseSection(
                    'Learning',
                    _userSkills.where((s) => s.type == 'learn').toList(),
                    kAccent.withValues(alpha: 0.1),
                    kAccent,
                    onAdd: () => _showAddSkillDialog('learn'),
                    onRemove: _removeSkill,
                  ),
                  const SizedBox(height: 48),
                  _buildSettingsSection(),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatarEditor() {
    return Container(
      height: 120,
      width: 120,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: kAccent.withValues(alpha: 0.2), width: 1),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: widget.user.imageUrl.startsWith('http')
                    ? NetworkImage(widget.user.imageUrl) as ImageProvider
                    : AssetImage(widget.user.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              height: 34,
              width: 34,
              decoration: BoxDecoration(
                color: kAccent,
                shape: BoxShape.circle,
                border: Border.all(color: kBackground, width: 2.5),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller, {
    IconData? icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: kAccent,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            crossAxisAlignment: maxLines > 1
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    icon,
                    color: kAccent.withValues(alpha: 0.4),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: TextField(
                  controller: controller,
                  maxLines: maxLines,
                  cursorColor: kAccent,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: kText,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpertiseSection(
    String title,
    List<Skill> tags,
    Color bgColor,
    Color textColor, {
    required VoidCallback onAdd,
    required Function(Skill) onRemove,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: kAccent,
                letterSpacing: 1.5,
              ),
            ),
            InkWell(
              onTap: onAdd,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: textColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add_rounded, color: textColor, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      'Add',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: tags
              .map(
                (skill) =>
                    _buildEditableTag(skill, bgColor, textColor, onRemove),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildEditableTag(
    Skill skill,
    Color bgColor,
    Color textColor,
    Function(Skill) onRemove,
  ) {
    return Container(
      padding: const EdgeInsets.only(left: 14, right: 8, top: 8, bottom: 8),
      decoration: BoxDecoration(
        color: kAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kAccent.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            skill.name,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: kAccent,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => onRemove(skill),
            child: Icon(
              Icons.close_rounded,
              color: textColor.withValues(alpha: 0.5),
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Settings',
          style: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: kAccent,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            children: [
              _buildSettingsTile(Icons.settings_outlined, 'Account Settings'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Divider(
                  color: Colors.white.withValues(alpha: 0.05),
                  height: 1,
                ),
              ),
              _buildSettingsTile(
                Icons.verified_user_outlined,
                'Identity Verification',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const IdentityVerificationPage(),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Divider(
                  color: Colors.white.withValues(alpha: 0.05),
                  height: 1,
                ),
              ),
              _buildLogoutTile(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: kAccent, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: kText,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withValues(alpha: 0.2),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutTile() {
    return InkWell(
      onTap: () => _showLogoutConfirmation(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFEF4444),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Sign Out',
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFEF4444),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1917),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Sign Out',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w900,
            color: const Color(0xFFEF4444),
            letterSpacing: 1.0,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out of your account?',
          style: GoogleFonts.dmSans(color: kTextMuted, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w600,
                color: kTextMuted,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthCubit>().signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Sign Out',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
