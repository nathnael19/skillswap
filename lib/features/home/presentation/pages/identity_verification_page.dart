import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IdentityVerificationPage extends StatefulWidget {
  const IdentityVerificationPage({super.key});

  @override
  State<IdentityVerificationPage> createState() => _IdentityVerificationPageState();
}

class _IdentityVerificationPageState extends State<IdentityVerificationPage> {
  // Premium Color Palette
  static const Color kBackground = Color(0xFF0C0A09);
  static const Color kAccent = Color(0xFFCA8A04);
  static const Color kText = Colors.white;

  bool _isFrontIdUploaded = false;
  bool _isBackIdUploaded = false;
  bool _isSelfieUploaded = false;
  bool _isSubmitting = false;

  void _submitVerification() async {
    if (!_isFrontIdUploaded || !_isBackIdUploaded || !_isSelfieUploaded) {
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

  void _toggleUpload(String type) {
    setState(() {
      if (type == 'front') _isFrontIdUploaded = !_isFrontIdUploaded;
      if (type == 'back') _isBackIdUploaded = !_isBackIdUploaded;
      if (type == 'selfie') _isSelfieUploaded = !_isSelfieUploaded;
    });
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Secure Your Account',
              style: GoogleFonts.dmSans(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'To ensure a safe community, please verify your identity by uploading your government-issued ID and a selfie.',
              style: GoogleFonts.dmSans(
                fontSize: 15,
                color: Colors.white.withValues(alpha: 0.4),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 48),

            _buildUploadCard(
              title: 'Front of ID',
              description: 'Upload the front of your government-issued ID',
              icon: Icons.badge_outlined,
              isUploaded: _isFrontIdUploaded,
              onTap: () => _toggleUpload('front'),
            ),
            const SizedBox(height: 20),

            _buildUploadCard(
              title: 'Back of ID',
              description: 'Upload the back of your government-issued ID',
              icon: Icons.credit_card_outlined,
              isUploaded: _isBackIdUploaded,
              onTap: () => _toggleUpload('back'),
            ),
            const SizedBox(height: 20),

            _buildUploadCard(
              title: 'Selfie',
              description: 'Take a clear selfie to match your ID',
              icon: Icons.face_rounded,
              isUploaded: _isSelfieUploaded,
              onTap: () => _toggleUpload('selfie'),
            ),

            const SizedBox(height: 48),
            
            SizedBox(
              width: double.infinity,
              height: 60,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kAccent, Color(0xFFB47B03)],
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
                    foregroundColor: Colors.white,
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
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Submit Verification',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadCard({
    required String title,
    required String description,
    required IconData icon,
    required bool isUploaded,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isUploaded ? kAccent.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isUploaded ? kAccent.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUploaded ? kAccent.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isUploaded ? Icons.check_circle_rounded : icon,
                color: isUploaded ? kAccent : Colors.white.withValues(alpha: 0.5),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isUploaded ? kAccent : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isUploaded ? 'Document uploaded successfully' : description,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: isUploaded ? kAccent.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.4),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
