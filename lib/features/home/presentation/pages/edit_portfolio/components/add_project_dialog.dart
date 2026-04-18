import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/features/home/domain/models/user_model.dart';
import 'package:skillswap/core/theme/theme.dart';

class AddProjectDialog extends StatefulWidget {
  final Function(PortfolioItem) onAdd;

  const AddProjectDialog({super.key, required this.onAdd});

  @override
  State<AddProjectDialog> createState() => _AddProjectDialogState();
}

class _AddProjectDialogState extends State<AddProjectDialog> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _imageController = TextEditingController();
  final _githubController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _imageController.dispose();
    _githubController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: AppColors.overlay10),
      ),
      title: Text(
        'New Project',
        style: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
          letterSpacing: 1.5,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogField(
              'Project Title',
              _titleController,
              'e.g. SkillSwap App',
            ),
            const SizedBox(height: 16),
            _buildDialogField(
              'Description',
              _descController,
              'What did you build?',
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _buildDialogField(
              'Image URL (Optional)',
              _imageController,
              'https://...',
            ),
            const SizedBox(height: 16),
            _buildDialogField(
              'GitHub URL (Optional)',
              _githubController,
              'https://github.com/...',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: GoogleFonts.dmSans(
              color: AppColors.overlay50,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty &&
                _descController.text.isNotEmpty) {
              widget.onAdd(
                PortfolioItem(
                  title: _titleController.text,
                  description: _descController.text,
                  imageUrl: _imageController.text.isNotEmpty
                      ? _imageController.text
                      : null,
                  githubUrl: _githubController.text.isNotEmpty
                      ? _githubController.text
                      : null,
                ),
              );
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Add Project',
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _buildDialogField(
    String label,
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.overlay50,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.dmSans(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.dmSans(color: AppColors.overlay20),
            filled: true,
            fillColor: AppColors.overlay05,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
