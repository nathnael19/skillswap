import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/features/home/domain/models/user_model.dart';
import 'package:skillswap/features/home/presentation/cubits/profile_cubit.dart';

class EditPortfolioPage extends StatefulWidget {
  final User user;
  const EditPortfolioPage({super.key, required this.user});

  static Route route(BuildContext context, User user) {
    final profileCubit = BlocProvider.of<ProfileCubit>(context);
    return MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: profileCubit,
        child: EditPortfolioPage(user: user),
      ),
    );
  }

  @override
  State<EditPortfolioPage> createState() => _EditPortfolioPageState();
}

class _EditPortfolioPageState extends State<EditPortfolioPage> {
  late List<PortfolioItem> _portfolio;

  @override
  void initState() {
    super.initState();
    _portfolio = List.from(widget.user.portfolio);
  }

  void _addProject(PortfolioItem item) {
    setState(() {
      _portfolio.add(item);
    });
  }

  void _removeProject(int index) {
    setState(() {
      _portfolio.removeAt(index);
    });
  }

  void _onSave() {
    final updatedUser = User(
      id: widget.user.id,
      name: widget.user.name,
      age: widget.user.age,
      rating: widget.user.rating,
      imageUrl: widget.user.imageUrl,
      bio: widget.user.bio,
      location: widget.user.location,
      profession: widget.user.profession,
      allSkills: widget.user.allSkills,
      teaching: widget.user.teaching,
      learning: widget.user.learning,
      portfolio: _portfolio,
    );
    context.read<ProfileCubit>().updateUserProfile(updatedUser);
  }

  void _showAddProjectDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final imageController = TextEditingController();
    final githubController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1917),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        title: Text(
          'New Project',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: const Color(0xFFCA8A04),
            letterSpacing: 1.5,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogField('Project Title', titleController, 'e.g. SkillSwap App'),
              const SizedBox(height: 16),
              _buildDialogField('Description', descController, 'What did you build?', maxLines: 3),
              const SizedBox(height: 16),
              _buildDialogField('Image URL (Optional)', imageController, 'https://...'),
              const SizedBox(height: 16),
              _buildDialogField('GitHub URL (Optional)', githubController, 'https://github.com/...'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.dmSans(
                color: Colors.white.withValues(alpha: 0.5),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && descController.text.isNotEmpty) {
                _addProject(PortfolioItem(
                  title: titleController.text,
                  description: descController.text,
                  imageUrl: imageController.text.isNotEmpty ? imageController.text : null,
                  githubUrl: githubController.text.isNotEmpty ? githubController.text : null,
                ));
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCA8A04),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Add Project',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogField(String label, TextEditingController controller, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.dmSans(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.dmSans(color: Colors.white.withValues(alpha: 0.2)),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Portfolio updated!')),
          );
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        final isLoading = state is ProfileLoading;

        return Scaffold(
          backgroundColor: const Color(0xFF0C0A09),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0C0A09),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Manage Portfolio',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            actions: [
              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFCA8A04)),
                    ),
                  ),
                )
              else
                TextButton(
                  onPressed: _onSave,
                  child: Text(
                    'Save',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFCA8A04),
                    ),
                  ),
                ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: _portfolio.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: _portfolio.length,
                        itemBuilder: (context, index) {
                          final item = _portfolio[index];
                          return _buildProjectTile(item, index);
                        },
                      ),
              ),
              _buildAddButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome_motion_rounded, size: 64, color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          Text(
            'No projects yet',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your best work to show off your skills.',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectTile(PortfolioItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _removeProject(index),
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton.icon(
          onPressed: _showAddProjectDialog,
          icon: const Icon(Icons.add_rounded),
          label: Text(
            'Add Project',
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w800, letterSpacing: 1.0),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFCA8A04),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
      ),
    );
  }
}
