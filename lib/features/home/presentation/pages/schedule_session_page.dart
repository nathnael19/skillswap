import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:skillswap/features/live_sessions/presentation/cubit/live_session_cubit.dart';
import 'package:skillswap/features/live_sessions/presentation/pages/session_detail_page.dart';
import 'package:skillswap/features/home/presentation/shared/schedule/calendar_slot_picker.dart';
import 'package:skillswap/features/home/presentation/shared/schedule/session_progress_header.dart';
import 'package:skillswap/features/home/presentation/shared/schedule/teaching_points_section.dart';
import 'package:skillswap/init_dependencies.dart';
import 'package:skillswap/core/constants/app_constants.dart';
import 'package:skillswap/core/layout/responsive.dart';
import 'package:skillswap/core/theme/theme.dart';

class ScheduleSessionPage extends StatefulWidget {
  final String matchId;
  final String peerName;
  final String peerImageUrl;
  final String currentUserId;
  final String peerId;
  final String? currentUserName;
  final String? currentUserImageUrl;

  const ScheduleSessionPage({
    super.key,
    required this.matchId,
    required this.peerName,
    required this.peerImageUrl,
    required this.currentUserId,
    required this.peerId,
    this.currentUserName,
    this.currentUserImageUrl,
  });

  @override
  State<ScheduleSessionPage> createState() => _ScheduleSessionPageState();
}

class _ScheduleSessionPageState extends State<ScheduleSessionPage> {
  DateTime? selectedDate = DateTime.now().add(const Duration(days: 1));
  String? selectedTime = AppConstants.defaultScheduleTime;
  final List<String> manifestations = [];
  final TextEditingController _topicController = TextEditingController();
  bool _creatingSession = false;

  bool get _isValid =>
      manifestations.isNotEmpty &&
      (() {
        try {
          return _combinedSchedule().isAfter(DateTime.now());
        } catch (_) {
          return false;
        }
      })();

  DateTime _combinedSchedule() {
    final d = selectedDate!;
    final slot = selectedTime ?? AppConstants.defaultScheduleTime;
    final normalized = slot
        .replaceAll('\u202f', ' ')
        .replaceAll('\u00a0', ' ')
        .trim();
    DateTime? timePart;
    for (final format in [
      DateFormat.jm(),
      DateFormat('hh:mm a'),
      DateFormat('h:mm a'),
    ]) {
      try {
        timePart = format.parseLoose(normalized);
        break;
      } catch (_) {}
    }
    if (timePart == null) {
      throw const FormatException('Invalid selected schedule time');
    }
    return DateTime(d.year, d.month, d.day, timePart.hour, timePart.minute);
  }

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
    const primaryBgColor = AppColors.background;

    // Calculate sub-progress for Step 2
    double subProgress = 0.0;
    if (selectedDate != null && selectedTime != null) subProgress += 0.5;
    if (manifestations.isNotEmpty) subProgress += 0.5;

    // Total progress logic: Time (0.5) + Topics (0.5)
    final totalProgress = subProgress;

    return Scaffold(
      backgroundColor: primaryBgColor,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          Responsive.valueFor<double>(
            context,
            compact: 64,
            mobile: 70,
            tablet: 72,
            tabletWide: 72,
            desktop: 72,
          ),
        ),
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
                    height: Responsive.valueFor<double>(
                      context,
                      compact: 44,
                      mobile: 48,
                      tablet: 48,
                      tabletWide: 48,
                      desktop: 48,
                    ),
                    width: Responsive.valueFor<double>(
                      context,
                      compact: 44,
                      mobile: 48,
                      tablet: 48,
                      tabletWide: 48,
                      desktop: 48,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.overlay05,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.overlay10),
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                  ),
                ),
              ),
              title: Text(
                'Schedule Swap',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: 2.0,
                ),
              ),
              centerTitle: true,
              shape: Border(
                bottom: BorderSide(color: AppColors.overlay05, width: 1),
              ),
            ),
          ),
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: Responsive.contentMaxWidthFor(context).isFinite
                ? Responsive.contentMaxWidthFor(context)
                : double.infinity,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              Responsive.contentHorizontalPadding(context),
              Responsive.valueFor<double>(
                context,
                compact: 100,
                mobile: 115,
                tablet: 120,
                tabletWide: 124,
                desktop: 128,
              ),
              Responsive.contentHorizontalPadding(context),
              Responsive.valueFor<double>(
                    context,
                    compact: 24,
                    mobile: 32,
                    tablet: 40,
                    tabletWide: 48,
                    desktop: 48,
                  ) +
                  MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SessionProgressHeader(
                  progress: totalProgress,
                  currentStep: 2,
                  totalSteps: 2,
                  label: 'Session Details',
                  title: 'Schedule Your Session',
                  quote: 'Pick a time that works for both of you.',
                ),
                SizedBox(
                  height: Responsive.valueFor<double>(
                    context,
                    compact: 32,
                    mobile: 40,
                    tablet: 44,
                    tabletWide: 48,
                    desktop: 48,
                  ),
                ),
                if (Responsive.isTwoPane(context))
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: CalendarSlotPicker(
                          selectedDate: selectedDate,
                          selectedTime: selectedTime,
                          onDateSelected: (date) =>
                              setState(() => selectedDate = date),
                          onTimeSelected: (time) =>
                              setState(() => selectedTime = time),
                        ),
                      ),
                      SizedBox(
                        width: Responsive.valueFor<double>(
                          context,
                          compact: 16,
                          mobile: 20,
                          tablet: 24,
                          tabletWide: 28,
                          desktop: 32,
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TeachingPointsSection(
                              topics: manifestations,
                              controller: _topicController,
                              onAdd: _addManifestation,
                              onRemove: _removeManifestation,
                            ),
                            SizedBox(
                              height: Responsive.valueFor<double>(
                                context,
                                compact: 40,
                                mobile: 48,
                                tablet: 52,
                                tabletWide: 56,
                                desktop: 56,
                              ),
                            ),
                            _buildConfirmButton(context),
                            SizedBox(
                              height: Responsive.valueFor<double>(
                                context,
                                compact: 16,
                                mobile: 20,
                                tablet: 22,
                                tabletWide: 24,
                                desktop: 24,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: Responsive.valueFor<double>(
                                  context,
                                  compact: 8,
                                  mobile: 16,
                                  tablet: 20,
                                  tabletWide: 24,
                                  desktop: 28,
                                ),
                              ),
                              child: Text(
                                'By scheduling, both users agree to the SkillSwap Code of Conduct.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.dmSans(
                                  fontSize: Responsive.valueFor<double>(
                                    context,
                                    compact: 8,
                                    mobile: 9,
                                    tablet: 10,
                                    tabletWide: 10,
                                    desktop: 10,
                                  ),
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.overlay20,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                else ...[
                  CalendarSlotPicker(
                    selectedDate: selectedDate,
                    selectedTime: selectedTime,
                    onDateSelected: (date) => setState(() => selectedDate = date),
                    onTimeSelected: (time) => setState(() => selectedTime = time),
                  ),
                  SizedBox(
                    height: Responsive.valueFor<double>(
                      context,
                      compact: 32,
                      mobile: 40,
                      tablet: 44,
                      tabletWide: 48,
                      desktop: 48,
                    ),
                  ),
                  TeachingPointsSection(
                    topics: manifestations,
                    controller: _topicController,
                    onAdd: _addManifestation,
                    onRemove: _removeManifestation,
                  ),
                  SizedBox(
                    height: Responsive.valueFor<double>(
                      context,
                      compact: 40,
                      mobile: 48,
                      tablet: 52,
                      tabletWide: 56,
                      desktop: 56,
                    ),
                  ),
                  _buildConfirmButton(context),
                  SizedBox(
                    height: Responsive.valueFor<double>(
                      context,
                      compact: 16,
                      mobile: 20,
                      tablet: 22,
                      tabletWide: 24,
                      desktop: 24,
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.valueFor<double>(
                          context,
                          compact: 16,
                          mobile: 24,
                          tablet: 28,
                          tabletWide: 32,
                          desktop: 36,
                        ),
                      ),
                      child: Text(
                        'By scheduling, both users agree to the SkillSwap Code of Conduct.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: Responsive.valueFor<double>(
                            context,
                            compact: 8,
                            mobile: 9,
                            tablet: 10,
                            tabletWide: 10,
                            desktop: 10,
                          ),
                          fontWeight: FontWeight.w800,
                          color: AppColors.overlay20,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
                SizedBox(
                  height: Responsive.valueFor<double>(
                    context,
                    compact: 48,
                    mobile: 72,
                    tablet: 88,
                    tabletWide: 100,
                    desktop: 100,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    const accentColor = AppColors.primary;

    final isValid = _isValid;

    return GestureDetector(
      onTap: (_creatingSession || !isValid)
          ? () {
              if (!isValid && !_creatingSession) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      manifestations.isEmpty
                          ? 'Please add at least one topic to discuss.'
                          : 'Please select a future date and time.',
                      style: GoogleFonts.dmSans(),
                    ),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            }
          : () async {
              setState(() => _creatingSession = true);
              final cubit = serviceLocator<LiveSessionCubit>();

              final resultId = await cubit.createSession(
                title: '1-to-1 Swap with ${widget.peerName}',
                scheduledAt: _combinedSchedule(),
                type: 'one-on-one',
                participantId: widget.peerId,
                topics: manifestations,
              );

              if (!context.mounted) return;
              setState(() => _creatingSession = false);

              if (resultId != null) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SessionDetailPage(sessionId: resultId),
                  ),
                );
              } else {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(cubit.state.error ?? 'Failed to schedule session.'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isValid ? 1.0 : 0.4,
        child: Container(
          width: double.infinity,
          height: Responsive.valueFor<double>(
            context,
            compact: 60,
            mobile: 64,
            tablet: 68,
            tabletWide: 72,
            desktop: 72,
          ),
          decoration: BoxDecoration(
            gradient: isValid
                ? const LinearGradient(
                    colors: [accentColor, AppColors.primaryDark],
                  )
                : LinearGradient(
                    colors: [AppColors.overlay10, AppColors.overlay05],
                  ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: isValid
                ? [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_creatingSession)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.textPrimary,
                    ),
                  )
                else
                  Icon(
                    isValid
                        ? Icons.auto_awesome_rounded
                        : Icons.info_outline_rounded,
                    color: AppColors.textPrimary,
                    size: 22,
                  ),
                const SizedBox(width: 16),
                Text(
                  _creatingSession ? 'Scheduling...' : 'Schedule Session',
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
