import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'filter/category_selector.dart';
import 'filter/expertise_segmented_control.dart';
import 'filter/rating_selector.dart';

class FilterBottomSheet extends StatefulWidget {
  final List<String> selectedCategories;
  final String selectedExpertise;
  final double minRating;
  final Function(List<String>, String, double) onApply;

  const FilterBottomSheet({
    super.key,
    required this.selectedCategories,
    required this.selectedExpertise,
    required this.minRating,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late List<String> _tempCategories;
  late String _tempExpertise;
  late double _tempRating;

  final List<String> _categories = [
    'Design',
    'Development',
    'Marketing',
    'Writing',
    'Business',
    'Data Science',
  ];

  final List<String> _expertiseLevels = ['Beginner', 'Intermediate', 'Expert'];

  @override
  void initState() {
    super.initState();
    _tempCategories = List.from(widget.selectedCategories);
    _tempExpertise = widget.selectedExpertise;
    _tempRating = widget.minRating;
  }

  @override
  Widget build(BuildContext context) {
    const primaryBgColor = Color(0xFF0C0A09);
    
    return Container(
      decoration: const BoxDecoration(
        color: primaryBgColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildHeader(),
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.05),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('FILTERS', 'Skill Categories'),
                  const SizedBox(height: 20),
                  CategorySelector(
                    categories: _categories,
                    selectedCategories: _tempCategories,
                    onToggle: (category) {
                      setState(() {
                        if (_tempCategories.contains(category)) {
                          _tempCategories.remove(category);
                        } else {
                          _tempCategories.add(category);
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 40),
                  _buildSectionHeader('EXPERTISE', 'Expertise Level'),
                  const SizedBox(height: 20),
                  ExpertiseSegmentedControl(
                    expertiseLevels: _expertiseLevels,
                    selectedExpertise: _tempExpertise,
                    onSelect: (level) {
                      setState(() {
                        _tempExpertise = level;
                      });
                    },
                  ),
                  const SizedBox(height: 40),
                  _buildSectionHeader('RATING', 'Minimum Level'),
                  const SizedBox(height: 20),
                  RatingSelector(
                    currentRating: _tempRating,
                    onSelect: (rating) {
                      setState(() {
                        _tempRating = rating;
                      });
                    },
                  ),
                  const SizedBox(height: 48),
                  _buildApplyButton(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Filters',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2.0,
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _tempCategories = ['Design'];
                _tempExpertise = 'Intermediate';
                _tempRating = 4.0;
              });
            },
            child: Text(
              'Reset',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFCA8A04),
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String subtitle, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFFCA8A04),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              subtitle,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFCA8A04),
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: GoogleFonts.dmSans(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildApplyButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFCA8A04), Color(0xFFB47B03)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCA8A04).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          widget.onApply(_tempCategories, _tempExpertise, _tempRating);
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Text(
          'Show Results',
          style: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
