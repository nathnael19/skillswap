import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/features/home/domain/models/user_model.dart';
import 'package:skillswap/features/home/presentation/cubits/profile_cubit.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_state.dart';
import 'package:skillswap/features/auth/presentation/pages/login_page.dart';
import 'package:skillswap/features/home/presentation/pages/identity_verification_page.dart';
import 'components/account_settings_section.dart';
import 'components/avatar_editor_section.dart';
import 'components/expertise_editor_section.dart';
import 'components/profile_input_field.dart';

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
                  AvatarEditorSection(
                    imageUrl: widget.user.imageUrl,
                    onTap: () {},
                  ),
                  const SizedBox(height: 48),
                  ProfileInputField(
                    label: 'Full Name',
                    controller: _nameController,
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 20),
                  ProfileInputField(
                    label: 'Profession',
                    controller: _professionController,
                    icon: Icons.work_outline_rounded,
                  ),
                  const SizedBox(height: 20),
                  ProfileInputField(
                    label: 'Location',
                    controller: _locationController,
                    icon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 20),
                  ProfileInputField(
                    label: 'Bio',
                    controller: _bioController,
                    maxLines: 4,
                    icon: Icons.description_outlined,
                  ),
                  const SizedBox(height: 40),
                  ExpertiseEditorSection(
                    title: 'Teaching',
                    tags: _userSkills.where((s) => s.type == 'teach').toList(),
                    onAdd: () => _showAddSkillDialog('teach'),
                    onRemove: _removeSkill,
                  ),
                  const SizedBox(height: 32),
                  ExpertiseEditorSection(
                    title: 'Learning',
                    tags: _userSkills.where((s) => s.type == 'learn').toList(),
                    onAdd: () => _showAddSkillDialog('learn'),
                    onRemove: _removeSkill,
                  ),
                  const SizedBox(height: 48),
                  AccountSettingsSection(
                    onIdentityVerificationTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const IdentityVerificationPage(),
                        ),
                      );
                    },
                    onLogoutTap: _showLogoutConfirmation,
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
