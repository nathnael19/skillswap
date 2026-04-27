import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:skillswap/core/common/cubits/connectivity/connectivity_cubit.dart';
import 'package:skillswap/core/common/widgets/connectivity_guard.dart';
import 'package:skillswap/core/common/widgets/offline_screen.dart';
import 'package:skillswap/core/layout/responsive.dart';
import 'package:skillswap/core/theme/theme.dart';
import 'package:skillswap/features/home/presentation/pages/live_session/live_session_page.dart';
import 'package:skillswap/features/live_sessions/data/models/live_session_model.dart';
import 'package:skillswap/features/live_sessions/data/models/session_resource_model.dart';
import 'package:skillswap/features/live_sessions/data/services/live_session_backend_service.dart';
import 'package:skillswap/features/live_sessions/data/services/live_session_firestore_service.dart';
import 'package:skillswap/features/live_sessions/presentation/cubit/live_session_cubit.dart';
import 'package:skillswap/features/live_sessions/presentation/cubit/live_session_state.dart';
import 'package:skillswap/init_dependencies.dart';
import 'package:flutter/services.dart';

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
  final LiveSessionBackendService _backend = serviceLocator<LiveSessionBackendService>();
  List<SessionResource> _resources = const [];
  bool _resourcesLoading = false;
  String? _resourcesError;

  @override
  void initState() {
    super.initState();
    context.read<LiveSessionCubit>().watchSession(widget.sessionId);
    _loadResources();
  }

  Future<void> _loadResources() async {
    setState(() {
      _resourcesLoading = true;
      _resourcesError = null;
    });
    try {
      final resources = await _backend.listResources(widget.sessionId);
      if (!mounted) return;
      setState(() {
        _resources = resources;
        _resourcesLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _resourcesLoading = false;
        _resourcesError = e.toString();
      });
    }
  }

  Future<void> _showAddResourceDialog() async {
    final result = await showDialog<_ResourceFormResult>(
      context: context,
      builder: (_) => const _AddResourceDialog(),
    );
    if (result == null) return;

    try {
      await _backend.createResource(
        sessionId: widget.sessionId,
        type: result.type,
        title: result.title,
        description: result.description,
        url: result.url,
        snippetText: result.snippetText,
      );
      if (!mounted) return;
      await _loadResources();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _deleteResource(String resourceId) async {
    try {
      await _backend.deleteResource(sessionId: widget.sessionId, resourceId: resourceId);
      if (!mounted) return;
      await _loadResources();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    }
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

  Future<void> _confirmDelete(BuildContext context, String sessionId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Session?'),
        content: const Text('This will permanently delete the session and notify all participants.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final ok = await context.read<LiveSessionCubit>().deleteSession(sessionId);
      if (ok && context.mounted) {
        Navigator.pop(context); // Go back after deletion
      }
    }
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
                  if (isHost && (isScheduled || isEnded)) ...[
                    ConnectivityGuard(
                      child: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => _confirmDelete(context, session.id),
                      ),
                    ),
                    if (isScheduled)
                      ConnectivityGuard(
                        child: IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _showEditSheet(context, session),
                        ),
                      ),
                  ],
                ],
              ),
              body: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.contentHorizontalPadding(context),
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: Responsive.contentMaxWidthFor(context),
                        ),
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

                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Text(
                          'Resource Hub',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const Spacer(),
                        if (isHost)
                          TextButton.icon(
                            onPressed: _showAddResourceDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Add'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_resourcesLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_resourcesError != null)
                      Text(
                        _resourcesError!,
                        style: const TextStyle(color: AppColors.error),
                      )
                    else if (_resources.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'No materials yet. Hosts can add PDFs, links, or snippets after sessions.',
                        ),
                      )
                    else
                      Column(
                        children: _resources.map((resource) {
                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      resource.type.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        resource.title,
                                        style: const TextStyle(fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    if (isHost)
                                      IconButton(
                                        onPressed: () => _deleteResource(resource.id),
                                        icon: const Icon(Icons.delete_outline, size: 18),
                                      ),
                                  ],
                                ),
                                if ((resource.description ?? '').isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(resource.description!),
                                  ),
                                if ((resource.url ?? '').isNotEmpty)
                                  TextButton.icon(
                                    onPressed: () async {
                                      await Clipboard.setData(ClipboardData(text: resource.url!));
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(this.context).showSnackBar(
                                        const SnackBar(content: Text('Link copied to clipboard')),
                                      );
                                    },
                                    icon: const Icon(Icons.link_rounded),
                                    label: const Text('Copy Link'),
                                  ),
                                if ((resource.snippetText ?? '').isNotEmpty)
                                  Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(top: 8),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      resource.snippetText!,
                                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

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

class _ResourceFormResult {
  final String type;
  final String title;
  final String? description;
  final String? url;
  final String? snippetText;

  const _ResourceFormResult({
    required this.type,
    required this.title,
    this.description,
    this.url,
    this.snippetText,
  });
}

class _AddResourceDialog extends StatefulWidget {
  const _AddResourceDialog();

  @override
  State<_AddResourceDialog> createState() => _AddResourceDialogState();
}

class _AddResourceDialogState extends State<_AddResourceDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _urlController = TextEditingController();
  final _snippetController = TextEditingController();
  String _type = 'link';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _urlController.dispose();
    _snippetController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.length < 2) return;
    final result = _ResourceFormResult(
      type: _type,
      title: title,
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      url: _urlController.text.trim().isEmpty ? null : _urlController.text.trim(),
      snippetText: _snippetController.text.trim().isEmpty ? null : _snippetController.text.trim(),
    );
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Session Material'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _type,
              items: const [
                DropdownMenuItem(value: 'pdf', child: Text('PDF')),
                DropdownMenuItem(value: 'link', child: Text('Link')),
                DropdownMenuItem(value: 'snippet', child: Text('Snippet')),
              ],
              onChanged: (value) => setState(() => _type = value ?? 'link'),
              decoration: const InputDecoration(labelText: 'Type'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description (optional)'),
            ),
            if (_type == 'pdf' || _type == 'link') ...[
              const SizedBox(height: 10),
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(labelText: 'URL'),
              ),
            ],
            if (_type == 'snippet') ...[
              const SizedBox(height: 10),
              TextField(
                controller: _snippetController,
                minLines: 4,
                maxLines: 8,
                decoration: const InputDecoration(labelText: 'Code Snippet'),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: _submit, child: const Text('Save')),
      ],
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
