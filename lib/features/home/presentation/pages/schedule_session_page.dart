import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/features/home/presentation/pages/live_session_page.dart';
import 'package:skillswap/features/home/presentation/widgets/schedule/calendar_slot_picker.dart';
import 'package:skillswap/features/home/presentation/widgets/schedule/meeting_hub_section.dart';
import 'package:skillswap/features/home/presentation/widgets/schedule/session_progress_header.dart';
import 'package:skillswap/features/home/presentation/widgets/schedule/teaching_points_section.dart';

class ScheduleSessionPage extends StatelessWidget {
  const ScheduleSessionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFEAECF5)),
                ),
                child: const Icon(Icons.arrow_back,
                    color: Color(0xFF101828), size: 20),
              ),
            ),
          ),
        ),
        title: Text(
          'Schedule Session',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF101828),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const SessionProgressHeader(
              currentStep: 2,
              totalSteps: 3,
              label: 'SESSION SETUP',
              title: 'Agreement & Logistics',
              quote: 'Almost ready to swap!',
            ),
            const SizedBox(height: 40),
            const CalendarSlotPicker(),
            const SizedBox(height: 32),
            const TeachingPointsSection(),
            const SizedBox(height: 32),
            const MeetingHubSection(),
            const SizedBox(height: 40),
            _buildConfirmButton(context),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'BY CONFIRMING, BOTH USERS AGREE TO THE SKILLSWAP\nCODE OF CONDUCT',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF98A2B3),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LiveSessionPage()),
        );
      },
      child: Container(
        width: double.infinity,
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFF0B6A7A),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0B6A7A).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline,
                  color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                'Confirm Session',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
