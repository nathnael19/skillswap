import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
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
                color: const Color(0xFFEAECF0),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildHeader(),
          const Divider(height: 1, color: Color(0xFFF2F4F7)),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('CURATION', 'Skill Categories'),
                  const SizedBox(height: 16),
                  _buildCategoryChips(),
                  const SizedBox(height: 32),
                  _buildSectionHeader('MASTERY', 'Expertise Level'),
                  const SizedBox(height: 16),
                  _buildExpertiseSegmented(),
                  const SizedBox(height: 32),
                  _buildSectionHeader('TRUST SCORE', 'Minimum Rating'),
                  const SizedBox(height: 16),
                  _buildRatingSelector(),
                  const SizedBox(height: 40),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Color(0xFF101828)),
          ),
          Text(
            'Filters',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF101828),
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
              'RESET',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0B6A7A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String subtitle, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF667085),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF101828),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChips() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _categories.map((category) {
        final isSelected = _tempCategories.contains(category);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _tempCategories.remove(category);
              } else {
                _tempCategories.add(category);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF0B6A7A)
                  : const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              category,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF344054),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExpertiseSegmented() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: _expertiseLevels.map((level) {
          final isSelected = _tempExpertise == level;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _tempExpertise = level),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF0B6A7A)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF0B6A7A).withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  level,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF667085),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRatingSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF2F4F7), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: List.generate(5, (index) {
              final ratingVal = index + 1.0;
              return GestureDetector(
                onTap: () => setState(() => _tempRating = ratingVal),
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(
                    index < _tempRating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: index < _tempRating
                        ? const Color(0xFFFDB022)
                        : const Color(0xFFD0D5DD),
                    size: 32,
                  ),
                ),
              );
            }),
          ),
          Text(
            '${_tempRating.toInt()}.0 & Up',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF101828),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplyButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          widget.onApply(_tempCategories, _tempExpertise, _tempRating);
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0B6A7A),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
        ),
        child: Text(
          'Apply Filters',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
