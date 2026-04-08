import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController(text: 'Julian Rivera');
  final TextEditingController _locationController = TextEditingController(text: 'Brooklyn, NY');
  final TextEditingController _bioController = TextEditingController(
      text: 'Product Designer & Digital Strategist. Passionate about creating seamless user experiences and mentoring emerging talent in the tech ecosystem.');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF101828), size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF101828),
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Save',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0B6A7A),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            _buildAvatarEditor(),
            const SizedBox(height: 12),
            Text(
              'TAP TO UPDATE AVATAR',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0B6A7A),
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 48),
            _buildInputField('FULL NAME', _nameController),
            const SizedBox(height: 24),
            _buildInputField('LOCATION', _locationController, icon: Icons.location_on_outlined),
            const SizedBox(height: 24),
            _buildInputField('PROFESSIONAL BIO', _bioController, maxLines: 5),
            const SizedBox(height: 40),
            _buildExpertiseSection(
              'Skills I Teach',
              ['UI/UX Design', 'Product Strategy', 'Figma'],
              const Color(0xFFEAECF5),
              const Color(0xFF344054),
            ),
            const SizedBox(height: 32),
            _buildExpertiseSection(
              'Skills I\'m Learning',
              ['React Native', '3D Modeling'],
              const Color(0xFFE0F2FE),
              const Color(0xFF026AA2),
              category: 'GROWTH',
            ),
            const SizedBox(height: 40),
            const Divider(color: Color(0xFFF2F4F7), height: 1),
            const SizedBox(height: 32),
            _buildSettingsTile(Icons.settings_outlined, 'Account Settings'),
            const SizedBox(height: 8),
            _buildSettingsTile(Icons.verified_user_outlined, 'Identity Verification'),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarEditor() {
    return Stack(
      children: [
        Container(
          height: 140,
          width: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFF2F4F7),
            image: const DecorationImage(
              image: AssetImage('assets/home.png'),
              fit: BoxFit.cover,
            ),
            border: Border.all(color: const Color(0xFFF2F4F7), width: 4),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 10,
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF0B6A7A),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {IconData? icon, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF667085),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFEAECF5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: const Color(0xFF667085), size: 20),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: TextField(
                  controller: controller,
                  maxLines: maxLines,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1D2939),
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpertiseSection(String title, List<String> tags, Color bgColor, Color textColor, {String? category}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (category != null) ...[
          Text(
            category,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0B6A7A),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF101828),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.add_circle_outline, color: Color(0xFF0B6A7A), size: 20),
                const SizedBox(width: 4),
                Text(
                  'Add',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0B6A7A),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: tags.map((tag) => _buildEditableTag(tag, bgColor, textColor)).toList(),
        ),
      ],
    );
  }

  Widget _buildEditableTag(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.cancel, color: textColor.withOpacity(0.3), size: 18),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF344054), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1D2939),
              ),
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF98A2B3), size: 24),
        ],
      ),
    );
  }
}
