import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/features/home/presentation/pages/live_session_page.dart';
import 'package:skillswap/features/home/presentation/widgets/schedule/calendar_slot_picker.dart';
import 'package:skillswap/features/home/presentation/widgets/schedule/meeting_hub_section.dart';
import 'package:skillswap/features/home/presentation/widgets/schedule/session_progress_header.dart';
import 'package:skillswap/features/home/presentation/widgets/schedule/teaching_points_section.dart';

class ScheduleSessionPage extends StatefulWidget {
  const ScheduleSessionPage({super.key});

  @override
  State<ScheduleSessionPage> createState() => _ScheduleSessionPageState();
}

class _ScheduleSessionPageState extends State<ScheduleSessionPage> {
  DateTime? selectedDate = DateTime.now().add(const Duration(days: 1));
  String? selectedTime = '10:30 AM';
  final List<String> manifestations = [];
  final TextEditingController _topicController = TextEditingController();

  void _addManifestation() {
    if (_topicController.text.trim().isNotEmpty) {
      setState(() {
        manifestations.add(_topicController.text.trim());
        _topicController.clear();
      });
    }
  }

  void _removeManifestation(int index) {
    setState(() {
      manifestations.removeAt(index);
    });
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryBgColor = Color(0xFF0C0A09);

    // Calculate sub-progress for Step 2
    double subProgress = 0.0;
    if (selectedDate != null && selectedTime != null) subProgress += 0.5;
    if (manifestations.isNotEmpty) subProgress += 0.5;
    
    // Total progress logic: Discovery (1.0) + Logistics (0.0 to 1.0)
    final totalProgress = (1.0 + subProgress) / 3.0;

    return Scaffold(
      backgroundColor: primaryBgColor,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: AppBar(
              backgroundColor: primaryBgColor.withValues(alpha: 0.8),
              elevation: 0,
              leading: Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ),
              title: Text(
                'NEXUS APPOINTMENT',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2.0,
                ),
              ),
              centerTitle: true,
              shape: Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.05),
                  width: 1,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 120),
            SessionProgressHeader(
              progress: totalProgress,
              currentStep: 2,
              totalSteps: 3,
              label: 'APPOINTMENT LOGISTICS',
              title: 'Nexus Synchronization',
              quote: 'Manifesting the perfect synergy.',
            ),
            const SizedBox(height: 48),
            CalendarSlotPicker(
              selectedDate: selectedDate,
              selectedTime: selectedTime,
              onDateSelected: (date) => setState(() => selectedDate = date),
              onTimeSelected: (time) => setState(() => selectedTime = time),
            ),
            const SizedBox(height: 48),
            TeachingPointsSection(
              topics: manifestations,
              controller: _topicController,
              onAdd: _addManifestation,
              onRemove: _removeManifestation,
            ),
            const SizedBox(height: 48),
            const MeetingHubSection(),
            const SizedBox(height: 56),
            _buildConfirmButton(context),
            const SizedBox(height: 24),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  'BY MANIFESTING, BOTH MASTERS AGREE TO THE NEXUS CODE OF CONDUCT AND ETHICAL SYNERGY',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Colors.white.withValues(alpha: 0.2),
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    const accentColor = Color(0xFFCA8A04);
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LiveSessionPage(agenda: manifestations)),
        );
      },
      child: Container(
        width: double.infinity,
        height: 72,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [accentColor, Color(0xFFB47B03)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 22),
              const SizedBox(width: 16),
              Text(
                'MANIFEST SYNERGY',
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
