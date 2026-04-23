import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:skillswap/core/common/cubits/connectivity/connectivity_cubit.dart';
import 'package:skillswap/core/common/widgets/connectivity_guard.dart';
import 'package:skillswap/core/common/widgets/offline_screen.dart';
import 'package:skillswap/core/theme/theme.dart';
import 'package:skillswap/features/home/presentation/pages/live_session/live_session_page.dart';
import 'package:skillswap/features/live_sessions/data/models/live_session_model.dart';
import 'package:skillswap/features/live_sessions/data/services/live_session_firestore_service.dart';
import 'package:skillswap/features/live_sessions/presentation/cubit/live_session_cubit.dart';
import 'package:skillswap/features/live_sessions/presentation/cubit/live_session_state.dart';
import 'package:skillswap/init_dependencies.dart';

class SessionDetailPage extends StatelessWidget {
  final String sessionId;
  const SessionDetailPage({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<LiveSessionCubit>(),
      child: _SessionDetailView(sessionId: sessionId),
    );
  }
}

class _SessionDetailView extends StatefulWidget {
  final String sessionId;
  const _SessionDetailView({required this.sessionId});

  @override
  State<_SessionDetailView> createState() => _SessionDetailViewState();
}

class _SessionDetailViewState extends State<_SessionDetailView> {
  @override
  void initState() {
    super.initState();
    context.read<LiveSessionCubit>().watchSession(widget.sessionId);
  }

  void _showEditSheet(BuildContext context, LiveSession session) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<LiveSessionCubit>(),
        child: _EditSessionSheet(session: session),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firestore = serviceLocator<LiveSessionFirestoreService>();

    return BlocConsumer<LiveSessionCubit, LiveSessionState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!), backgroundColor: AppColors.error),
          );
        }
      },
      builder: (context, state) {
        return BlocBuilder<ConnectivityCubit, ConnectivityStatus>(
          builder: (context, connectivity) {
            final session = state.session;
            if (session == null) {
              if (connectivity == ConnectivityStatus.disconnected) {
                return Scaffold(
                  body: OfflineScreen(
                    onRetry: () => context.read<LiveSessionCubit>().watchSession(widget.sessionId),
                  ),
                );
              }
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final isHost = session.hostId == firestore.currentUserId;
            final isLive = session.status == 'live';
            final isEnded = session.status == 'ended';
            final isScheduled = session.status == 'scheduled';
            final dateStr = DateFormat('MMM dd, yyyy • hh:mm a').format(session.scheduledAt);

            return Scaffold(
              appBar: AppBar(
                title: const Text('Session Details'),
                actions: [
                  if (isHost && isScheduled)
                    ConnectivityGuard(
                      child: IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _showEditSheet(context, session),
                      ),
                    ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.secondary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _StatusBadge(status: session.status),
                              const Spacer(),
                              const Icon(Icons.videocam_rounded, color: Colors.white, size: 20),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            session.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, color: Colors.white70, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                dateStr,
                                style: const TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Info Section
                    Text(
                      'About this session',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _InfoTile(
                      icon: Icons.people_outline,
                      label: 'Capacity',
                      value: '${session.participants.length} / ${session.maxParticipants} joined',
                    ),
                    _InfoTile(
                      icon: Icons.person_outline,
                      label: 'Host',
                      value: isHost ? 'You are the host' : 'Participant',
                    ),

                    // Topics Section
                    if (session.topics.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Topics',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: session.topics
                            .map(
                              (topic) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  topic,
                                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],

                    const SizedBox(height: 40),

                    // Action Buttons
                    if (isHost && isScheduled)
                      SizedBox(
                        width: double.infinity,
                        child: ConnectivityGuard(
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () => context.read<LiveSessionCubit>().startSession(session.id),
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: const Text('Start Session Now'),
                          ),
                        ),
                      ),

                    if (!isHost && isScheduled)
                      Builder(builder: (context) {
                        final hasJoined = session.participants.contains(firestore.currentUserId);
                        if (!hasJoined) {
                          return SizedBox(
                            width: double.infinity,
                            child: ConnectivityGuard(
                              child: FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                onPressed: () => context.read<LiveSessionCubit>().joinSession(
                                      sessionId: session.id,
                                      userName: 'User',
                                    ),
                                icon: const Icon(Icons.how_to_reg_rounded),
                                label: Text('Join Waitlist (${session.type == 'one-on-one' ? '3' : '2'} coins)'),
                              ),
                            ),
                          );
                        }
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.hourglass_empty_rounded, color: Colors.amber),
                              SizedBox(height: 8),
                              Text(
                                'You are in the waitlist!',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'The session will start once the host goes live.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      }),

                    if (isLive)
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ConnectivityGuard(
                              child: FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: Colors.redAccent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => LiveSessionPage(
                                        agenda: const [],
                                        sessionId: session.id,
                                        peerName: '',
                                        peerImageUrl: '',
                                        currentUserId: firestore.currentUserId ?? '',
                                        peerId: '',
                                        sessionTitle: session.title,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.sensors_rounded),
                                label: const Text('Join Live Session'),
                              ),
                            ),
                          ),
                          if (isHost) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ConnectivityGuard(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    foregroundColor: Colors.redAccent,
                                    side: const BorderSide(color: Colors.redAccent),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('End Session?'),
                                        content: const Text('This will end the session for everyone.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            child: const Text('End Session'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true && context.mounted) {
                                      context.read<LiveSessionCubit>().endSession(session.id);
                                    }
                                  },
                                  icon: const Icon(Icons.stop_circle_outlined),
                                  label: const Text('End Session for All'),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),

                    if (isEnded)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'This session has ended.',
                            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ─── Edit Session Bottom Sheet ────────────────────────────────────────────────

class _EditSessionSheet extends StatefulWidget {
  final LiveSession session;
  const _EditSessionSheet({required this.session});

  @override
  State<_EditSessionSheet> createState() => _EditSessionSheetState();
}

class _EditSessionSheetState extends State<_EditSessionSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _topicController;
  late DateTime _scheduledAt;
  late List<String> _topics;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.session.title);
    _topicController = TextEditingController();
    _scheduledAt = widget.session.scheduledAt;
    _topics = List<String>.from(widget.session.topics);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _topicController.dispose();
    super.dispose();
  }

  void _addTopic() {
    final text = _topicController.text.trim();
    if (text.isNotEmpty && !_topics.contains(text)) {
      setState(() {
        _topics.add(text);
        _topicController.clear();
      });
    }
  }

  void _removeTopic(int index) {
    setState(() => _topics.removeAt(index));
  }

  Future<void> _pickSchedule() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledAt,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledAt),
    );
    if (time == null) return;
    setState(() {
      _scheduledAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final newTitle = _titleController.text.trim();
    final cubit = context.read<LiveSessionCubit>();

    final ok = await cubit.updateSession(
      sessionId: widget.session.id,
      title: newTitle != widget.session.title ? newTitle : null,
      scheduledAt: _scheduledAt != widget.session.scheduledAt ? _scheduledAt : null,
      topics: _topics,
    );

    if (!mounted) return;
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Text(
                'Edit Session',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Title field
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Session title',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
                validator: (v) {
                  if (v == null || v.trim().length < 3) return 'Title must be at least 3 characters';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Date & Time
              Text('Schedule', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.schedule_rounded, size: 18),
                label: Text(
                  DateFormat('MMM dd, yyyy • hh:mm a').format(_scheduledAt),
                ),
                onPressed: _pickSchedule,
              ),
              const SizedBox(height: 24),

              // Topics
              Text('Topics', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _topicController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Add a topic...',
                        prefixIcon: Icon(Icons.tag_rounded, size: 18),
                        isDense: true,
                      ),
                      onFieldSubmitted: (_) => _addTopic(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _addTopic,
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_topics.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _topics.asMap().entries.map((entry) {
                    return Chip(
                      label: Text(entry.value),
                      onDeleted: () => _removeTopic(entry.key),
                      deleteIcon: const Icon(Icons.close_rounded, size: 14),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 32),

              // Save button
              BlocBuilder<LiveSessionCubit, LiveSessionState>(
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: state.loading ? null : _save,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: state.loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Save Changes'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isLive = status == 'live';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isLive ? Colors.red : Colors.white24,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
