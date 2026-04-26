import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skillswap/core/common/widgets/connectivity_guard.dart';
import 'package:skillswap/core/theme/theme.dart';
import 'package:skillswap/core/constants/app_constants.dart';
import 'package:skillswap/core/constants/app_categories.dart';

import 'package:skillswap/features/home/domain/models/user_model.dart';
import 'package:skillswap/features/home/presentation/cubits/profile_cubit.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_state.dart';
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
  static const Color kBackground = AppColors.background;
  static const Color kAccent = AppColors.primary;
  static const Color kText = AppColors.textPrimary;
  static const Color kTextSecondary = AppColors.textSecondary;

  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _locationController;
  late final TextEditingController _professionController;
  late final TextEditingController _bioController;
  late List<Skill> _userSkills;
  XFile? _pickedAvatar;
  final ImagePicker _picker = ImagePicker();

  String? _selectedCategory;
  String? _selectedExpertise;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _ageController = TextEditingController(text: widget.user.age.toString());
    _locationController = TextEditingController(text: widget.user.location);
    _professionController = TextEditingController(text: widget.user.profession);
    _bioController = TextEditingController(text: widget.user.bio);
    _userSkills = List.from(widget.user.allSkills);
    final initialCategory = widget.user.primaryCategory;
    if (initialCategory != null) {
      final match = AppCategories.categories
          .where((c) => c.toLowerCase() == initialCategory.toLowerCase())
          .firstOrNull;
      _selectedCategory = match ?? AppCategories.categories.first;
    } else {
      _selectedCategory = AppCategories.categories.first;
    }

    final initialExpertise = widget.user.expertiseLevel;
    if (initialExpertise != null) {
      final match = AppCategories.expertiseLevels
          .where((e) => e.toLowerCase() == initialExpertise.toLowerCase())
          .firstOrNull;
      _selectedExpertise = match ?? AppCategories.expertiseLevels[1];
    } else {
      _selectedExpertise = AppCategories.expertiseLevels[1];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _locationController.dispose();
    _professionController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _addSkill(String name, String type) {
    setState(() {
      _userSkills.add(
        Skill(
          name: name,
          type: type,
          category: AppConstants.defaultSkillCategory,
        ),
      );
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
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Add ${type == AppConstants.skillTypeTeach ? 'Skill to Teach' : 'Skill to Learn'}',
          style: AppTextStyles.labelMedium.copyWith(
            color: kAccent,
            letterSpacing: 1.5,
          ),
        ),

        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Skill name (e.g. Flutter)',
            hintStyle: AppTextStyles.bodySmall.copyWith(
              color: AppColors.overlay20,
            ),
            filled: true,
            fillColor: AppColors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.borderSubtle),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.borderSubtle),
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
              style: AppTextStyles.labelLarge.copyWith(color: kTextSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _addSkill(controller.text, type);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _pickAvatar() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _pickedAvatar = image;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  void _onSave() {
    final updatedUser = User(
      id: widget.user.id,
      name: _nameController.text,
      age: int.tryParse(_ageController.text) ?? widget.user.age,
      rating: widget.user.rating,
      imageUrl: _pickedAvatar?.path ?? widget.user.imageUrl,
      bio: _bioController.text,
      location: _locationController.text,
      profession: _professionController.text,
      allSkills: _userSkills,
      teaching: _userSkills.any((s) => s.type == AppConstants.skillTypeTeach)
          ? _userSkills.firstWhere((s) => s.type == AppConstants.skillTypeTeach)
          : null,
      learning: _userSkills.any((s) => s.type == AppConstants.skillTypeLearn)
          ? _userSkills.firstWhere((s) => s.type == AppConstants.skillTypeLearn)
          : null,
      primaryCategory: _selectedCategory,
      expertiseLevel: _selectedExpertise,
    );
    context.read<ProfileCubit>().updateUserProfile(updatedUser);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
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
        final isLoading =
            state is ProfileLoading ||
            context.watch<AuthCubit>().state is AuthLoading;

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
              style: AppTextStyles.labelMedium.copyWith(
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
                  child: ConnectivityGuard(
                    child: TextButton(
                      onPressed: _onSave,
                      style: TextButton.styleFrom(
                        foregroundColor: kAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: Text(
                        'Save',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: kAccent,
                          letterSpacing: 1.0,
                        ),
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
                ConnectivityGuard(
                  child: AvatarEditorSection(
                    imageUrl: widget.user.imageUrl,
                    localImage: _pickedAvatar,
                    onTap: _pickAvatar,
                  ),
                ),
                const SizedBox(height: 48),
                ProfileInputField(
                  label: 'Full Name',
                  controller: _nameController,
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 20),
                ProfileInputField(
                  label: 'Age',
                  controller: _ageController,
                  icon: Icons.calendar_today_outlined,
                  keyboardType: TextInputType.number,
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
                const SizedBox(height: 32),
                _buildSelectionSection(),
                const SizedBox(height: 40),
                ExpertiseEditorSection(
                  title: 'Teaching',
                  tags: _userSkills
                      .where((s) => s.type == AppConstants.skillTypeTeach)
                      .toList(),
                  onAdd: () => _showAddSkillDialog(AppConstants.skillTypeTeach),
                  onRemove: _removeSkill,
                ),
                const SizedBox(height: 32),
                ExpertiseEditorSection(
                  title: 'Learning',
                  tags: _userSkills
                      .where((s) => s.type == AppConstants.skillTypeLearn)
                      .toList(),
                  onAdd: () => _showAddSkillDialog(AppConstants.skillTypeLearn),
                  onRemove: _removeSkill,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CORE IDENTITY',
          style: AppTextStyles.labelMedium.copyWith(
            color: kAccent,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        DropdownButtonFormField<String>(
          initialValue: _selectedCategory,
          dropdownColor: AppColors.surface,
          style: AppTextStyles.bodyMedium.copyWith(color: kText),
          decoration: InputDecoration(
            labelText: 'Primary Category',
            labelStyle: AppTextStyles.labelSmall.copyWith(color: kAccent),
            prefixIcon: const Icon(
              Icons.category_outlined,
              color: kTextSecondary,
            ),
            filled: true,
            fillColor: AppColors.overlay05,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.borderSubtle),
            ),
          ),
          items: AppCategories.categories
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (val) => setState(() => _selectedCategory = val),
        ),
        const SizedBox(height: 20),
        DropdownButtonFormField<String>(
          initialValue: _selectedExpertise,
          dropdownColor: AppColors.surface,
          style: AppTextStyles.bodyMedium.copyWith(color: kText),
          decoration: InputDecoration(
            labelText: 'Expertise Level',
            labelStyle: AppTextStyles.labelSmall.copyWith(color: kAccent),
            prefixIcon: const Icon(
              Icons.show_chart_rounded,
              color: kTextSecondary,
            ),
            filled: true,
            fillColor: AppColors.overlay05,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.borderSubtle),
            ),
          ),
          items: AppCategories.expertiseLevels
              .where((e) => e != 'All')
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (val) => setState(() => _selectedExpertise = val),
        ),
      ],
    );
  }
}
