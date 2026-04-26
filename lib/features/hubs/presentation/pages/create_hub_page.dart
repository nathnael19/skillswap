import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/core/theme/theme.dart';
import 'package:skillswap/features/hubs/data/services/hub_backend_service.dart';
import 'package:skillswap/init_dependencies.dart';

class CreateHubPage extends StatefulWidget {
  const CreateHubPage({super.key});

  @override
  State<CreateHubPage> createState() => _CreateHubPageState();
}

class _CreateHubPageState extends State<CreateHubPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _slugController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  bool _isPrivate = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_updateSlug);
  }

  void _updateSlug() {
    if (_nameController.text.isNotEmpty) {
      _slugController.text = _nameController.text.strip().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_updateSlug);
    _nameController.dispose();
    _slugController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final service = serviceLocator<HubBackendService>();
      await service.createHub(
        name: _nameController.text.strip(),
        slug: _slugController.text.strip(),
        description: _descriptionController.text.strip(),
        category: _categoryController.text.strip(),
        isPrivate: _isPrivate,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create a Hub', style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Start a community for a specific skill.',
                style: GoogleFonts.dmSans(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              _buildField(
                label: 'Hub Name',
                hint: 'e.g. Flutter Experts',
                controller: _nameController,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              _buildField(
                label: 'Slug',
                hint: 'e.g. flutter-experts',
                controller: _slugController,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              _buildField(
                label: 'Category',
                hint: 'e.g. Programming',
                controller: _categoryController,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              _buildField(
                label: 'Description',
                hint: 'What is this hub about?',
                controller: _descriptionController,
                maxLines: 3,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              SwitchListTile(
                title: Text('Private Hub', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
                subtitle: const Text('Only members can see messages'),
                value: _isPrivate,
                onChanged: (v) => setState(() => _isPrivate = v),
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _loading ? null : _create,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('Create Hub', style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.overlay03,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }
}

extension on String {
  String strip() => trim();
}
