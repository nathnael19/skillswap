import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/features/home/domain/models/user_model.dart';
import 'package:skillswap/features/home/presentation/cubits/profile_cubit.dart';
import 'components/add_project_dialog.dart';
import 'components/empty_portfolio_state.dart';
import 'components/portfolio_project_tile.dart';
import 'package:skillswap/core/theme/theme.dart';

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
    showDialog(
      context: context,
      builder: (context) => AddProjectDialog(onAdd: _addProject),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdateSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Portfolio updated!')));
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        final isLoading = state is ProfileLoading;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Manage Portfolio',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
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
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
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
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: _portfolio.isEmpty
                    ? const EmptyPortfolioState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: _portfolio.length,
                        itemBuilder: (context, index) {
                          return PortfolioProjectTile(
                            item: _portfolio[index],
                            onDelete: () => _removeProject(index),
                          );
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
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}
