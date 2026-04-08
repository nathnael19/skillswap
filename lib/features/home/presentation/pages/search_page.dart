import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/mock_data.dart';
import '../widgets/expert_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'UI Design', 'Python', 'Cooking', 'Business'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // Very light bluish gray
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.search, color: Color(0xFF101828)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'SkillSwap',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: const Color(0xFF101828),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFEAECF0),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search for skills, mentors, or topics',
                  hintStyle: GoogleFonts.inter(
                    color: const Color(0xFF667085),
                    fontSize: 15,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF667085)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),

          // Horizontal Categories
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = category),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF0B6A7A) : const Color(0xFFEAECF0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : const Color(0xFF344054),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 32),

          // Recommended Experts Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CURATED FOR YOU',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0B6A7A),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Recommended Experts',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF101828),
                      ),
                    ),
                  ],
                ),
                Text(
                  'See all',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0B6A7A),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Experts List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 20),
              itemCount: mockUsers.length,
              itemBuilder: (context, index) {
                // To match mockup layout exactly, we'll show special users or just the whole list
                return ExpertCard(user: mockUsers[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
