import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skillswap/core/common/widgets/connectivity_guard.dart';
import 'package:skillswap/core/layout/responsive.dart';
import 'package:skillswap/core/theme/theme.dart';

class IdentityVerificationPage extends StatefulWidget {
  const IdentityVerificationPage({super.key});

  @override
  State<IdentityVerificationPage> createState() =>
      _IdentityVerificationPageState();
}

class _IdentityVerificationPageState extends State<IdentityVerificationPage> {
  // Premium Color Palette
  static const Color kBackground = AppColors.background;
  static const Color kAccent = AppColors.primary;
  static const Color kText = AppColors.textPrimary;

  XFile? _frontIdFile;
  XFile? _backIdFile;
  XFile? _selfieFile;
  bool _isSubmitting = false;

  final ImagePicker _picker = ImagePicker();

  void _submitVerification() async {
    if (_frontIdFile == null || _backIdFile == null || _selfieFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload all required documents.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isSubmitting = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification submitted successfully!')),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _pickImage(String type) async {
    try {
      final source = type == 'selfie' ? ImageSource.camera : ImageSource.gallery;
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          if (type == 'front') _frontIdFile = pickedFile;
          if (type == 'back') _backIdFile = pickedFile;
          if (type == 'selfie') _selfieFile = pickedFile;
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

  @override
  Widget build(BuildContext context) {
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
          'Identity Verification',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: kAccent,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: Responsive.contentMaxWidthFor(context).isFinite
                ? Responsive.contentMaxWidthFor(context)
                : double.infinity,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              Responsive.contentHorizontalPadding(context),
              Responsive.valueFor<double>(
                context,
                compact: 12,
                mobile: 16,
                tablet: 20,
                tabletWide: 24,
                desktop: 24,
              ),
              Responsive.contentHorizontalPadding(context),
              Responsive.valueFor<double>(
                    context,
                    compact: 16,
                    mobile: 20,
                    tablet: 24,
                    tabletWide: 28,
                    desktop: 32,
                  ) +
                  MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Secure Your Account',
                  style: GoogleFonts.dmSans(
                    fontSize: Responsive.valueFor<double>(
                      context,
                      compact: 22,
                      mobile: 24,
                      tablet: 26,
                      tabletWide: 28,
                      desktop: 28,
                    ),
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.8,
                  ),
                ),
                SizedBox(
                  height: Responsive.valueFor<double>(
                    context,
                    compact: 8,
                    mobile: 12,
                    tablet: 14,
                    tabletWide: 16,
                    desktop: 16,
                  ),
                ),
                Text(
                  'To ensure a safe community, please verify your identity by uploading your government-issued ID and a selfie.',
                  style: GoogleFonts.dmSans(
                    fontSize: Responsive.valueFor<double>(
                      context,
                      compact: 13,
                      mobile: 14,
                      tablet: 15,
                      tabletWide: 15,
                      desktop: 16,
                    ),
                    color: AppColors.overlay40,
                    height: 1.6,
                  ),
                ),
                SizedBox(
                  height: Responsive.valueFor<double>(
                    context,
                    compact: 32,
                    mobile: 40,
                    tablet: 44,
                    tabletWide: 48,
                    desktop: 48,
                  ),
                ),

                if (Responsive.isTwoPane(context))
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            ConnectivityGuard(
                              child: _buildUploadCard(
                                context,
                                title: 'Front of ID',
                                description:
                                    'Upload the front of your government-issued ID',
                                icon: Icons.badge_outlined,
                                file: _frontIdFile,
                                onTap: () => _pickImage('front'),
                              ),
                            ),
                            SizedBox(
                              height: Responsive.valueFor<double>(
                                context,
                                compact: 16,
                                mobile: 18,
                                tablet: 20,
                                tabletWide: 20,
                                desktop: 20,
                              ),
                            ),
                            ConnectivityGuard(
                              child: _buildUploadCard(
                                context,
                                title: 'Back of ID',
                                description:
                                    'Upload the back of your government-issued ID',
                                icon: Icons.credit_card_outlined,
                                file: _backIdFile,
                                onTap: () => _pickImage('back'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: Responsive.valueFor<double>(
                          context,
                          compact: 12,
                          mobile: 16,
                          tablet: 20,
                          tabletWide: 24,
                          desktop: 24,
                        ),
                      ),
                      Expanded(
                        child: ConnectivityGuard(
                          child: _buildUploadCard(
                            context,
                            title: 'Selfie',
                            description: 'Take a clear selfie to match your ID',
                            icon: Icons.face_rounded,
                            file: _selfieFile,
                            onTap: () => _pickImage('selfie'),
                          ),
                        ),
                      ),
                    ],
                  )
                else ...[
                  ConnectivityGuard(
                    child: _buildUploadCard(
                      context,
                      title: 'Front of ID',
                      description:
                          'Upload the front of your government-issued ID',
                      icon: Icons.badge_outlined,
                      file: _frontIdFile,
                      onTap: () => _pickImage('front'),
                    ),
                  ),
                  SizedBox(
                    height: Responsive.valueFor<double>(
                      context,
                      compact: 16,
                      mobile: 18,
                      tablet: 20,
                      tabletWide: 20,
                      desktop: 20,
                    ),
                  ),
                  ConnectivityGuard(
                    child: _buildUploadCard(
                      context,
                      title: 'Back of ID',
                      description:
                          'Upload the back of your government-issued ID',
                      icon: Icons.credit_card_outlined,
                      file: _backIdFile,
                      onTap: () => _pickImage('back'),
                    ),
                  ),
                  SizedBox(
                    height: Responsive.valueFor<double>(
                      context,
                      compact: 16,
                      mobile: 18,
                      tablet: 20,
                      tabletWide: 20,
                      desktop: 20,
                    ),
                  ),
                  ConnectivityGuard(
                    child: _buildUploadCard(
                      context,
                      title: 'Selfie',
                      description: 'Take a clear selfie to match your ID',
                      icon: Icons.face_rounded,
                      file: _selfieFile,
                      onTap: () => _pickImage('selfie'),
                    ),
                  ),
                ],

                SizedBox(
                  height: Responsive.valueFor<double>(
                    context,
                    compact: 32,
                    mobile: 40,
                    tablet: 44,
                    tabletWide: 48,
                    desktop: 48,
                  ),
                ),

                SizedBox(
                  width: double.infinity,
                  height: Responsive.valueFor<double>(
                    context,
                    compact: 52,
                    mobile: 56,
                    tablet: 58,
                    tabletWide: 60,
                    desktop: 60,
                  ),
                  child: ConnectivityGuard(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [kAccent, AppColors.primaryDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: kAccent.withValues(alpha: 0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitVerification,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: AppColors.textPrimary,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: AppColors.textPrimary,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Submit Verification',
                                style: GoogleFonts.dmSans(
                                  fontSize: Responsive.valueFor<double>(
                                    context,
                                    compact: 14,
                                    mobile: 15,
                                    tablet: 16,
                                    tabletWide: 16,
                                    desktop: 16,
                                  ),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: Responsive.valueFor<double>(
                    context,
                    compact: 40,
                    mobile: 48,
                    tablet: 54,
                    tabletWide: 60,
                    desktop: 60,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required XFile? file,
    required VoidCallback onTap,
  }) {
    final bool isUploaded = file != null;

    final pad = Responsive.valueFor<double>(
      context,
      compact: 14,
      mobile: 16,
      tablet: 18,
      tabletWide: 20,
      desktop: 20,
    );
    final thumb = Responsive.valueFor<double>(
      context,
      compact: 44,
      mobile: 48,
      tablet: 50,
      tabletWide: 52,
      desktop: 52,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(pad),
        decoration: BoxDecoration(
          color:
              isUploaded
                  ? kAccent.withValues(alpha: 0.05)
                  : AppColors.textPrimary.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color:
                isUploaded
                    ? kAccent.withValues(alpha: 0.3)
                    : AppColors.overlay05,
          ),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: thumb,
                  height: thumb,
                  decoration: BoxDecoration(
                    color:
                        isUploaded
                            ? kAccent.withValues(alpha: 0.1)
                            : AppColors.overlay05,
                    borderRadius: BorderRadius.circular(16),
                    image:
                        isUploaded
                            ? DecorationImage(
                              image: FileImage(File(file.path)),
                              fit: BoxFit.cover,
                            )
                            : null,
                  ),
                  child:
                      !isUploaded
                          ? Icon(
                              icon,
                              color: AppColors.overlay50,
                              size: Responsive.valueFor<double>(
                                context,
                                compact: 20,
                                mobile: 22,
                                tablet: 24,
                                tabletWide: 24,
                                desktop: 24,
                              ),
                            )
                          : null,
                ),
                if (isUploaded)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: AppColors.textPrimary,
                        size: 10,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(
              width: Responsive.valueFor<double>(
                context,
                compact: 12,
                mobile: 14,
                tablet: 16,
                tabletWide: 16,
                desktop: 16,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.dmSans(
                      fontSize: Responsive.valueFor<double>(
                        context,
                        compact: 14,
                        mobile: 15,
                        tablet: 16,
                        tabletWide: 16,
                        desktop: 16,
                      ),
                      fontWeight: FontWeight.w700,
                      color: isUploaded ? kAccent : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isUploaded ? 'Document selected' : description,
                    style: GoogleFonts.dmSans(
                      fontSize: Responsive.valueFor<double>(
                        context,
                        compact: 12,
                        mobile: 12,
                        tablet: 13,
                        tabletWide: 13,
                        desktop: 14,
                      ),
                      color:
                          isUploaded
                              ? kAccent.withValues(alpha: 0.7)
                              : AppColors.overlay40,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (isUploaded)
              const Icon(Icons.refresh_rounded, color: kAccent, size: 18),
          ],
        ),
      ),
    );
  }
}
