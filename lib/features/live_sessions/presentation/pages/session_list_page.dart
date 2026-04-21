import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/features/live_sessions/data/services/live_session_firestore_service.dart';
import 'package:skillswap/features/live_sessions/presentation/cubit/live_session_cubit.dart';
import 'package:skillswap/features/live_sessions/presentation/cubit/live_session_state.dart';
import 'package:skillswap/features/live_sessions/presentation/pages/session_detail_page.dart';
import 'package:skillswap/init_dependencies.dart';

class SessionListPage extends StatelessWidget {
  const SessionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<LiveSessionCubit>(),
      child: const _SessionListView(),
    );
  }
}

class _SessionListView extends StatelessWidget {
  const _SessionListView();

  @override
  Widget build(BuildContext context) {
    final firestoreService = serviceLocator<LiveSessionFirestoreService>();

    return BlocListener<LiveSessionCubit, LiveSessionState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Live Sessions'),
          centerTitle: false,
        ),
        floatingActionButton: BlocBuilder<LiveSessionCubit, LiveSessionState>(
          builder: (context, state) {
            return FloatingActionButton.extended(
              onPressed: state.loading
                  ? null
                  : () => _showCreateDialog(context),
              icon: state.loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.video_call_rounded),
              label: const Text('Create Room'),
            );
          },
        ),
        body: StreamBuilder(
          stream: firestoreService.watchSessions(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Something went wrong: ${snapshot.error}'),
              );
            }
            final sessions = snapshot.data ?? [];
            if (sessions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.video_camera_back_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No sessions yet',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap "Create Room" to start one.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: sessions.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final session = sessions[index];
                final isLive = session.status == 'live';
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: isLive
                          ? Colors.red.withValues(alpha: 0.15)
                          : Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withValues(alpha: 0.5),
                      child: Icon(
                        isLive
                            ? Icons.fiber_manual_record
                            : Icons.schedule_rounded,
                        color: isLive
                            ? Colors.red
                            : Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      session.title,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          _StatusChip(status: session.status),
                          const SizedBox(width: 8),
                          _TypeChip(type: session.type),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.people_outline,
                            size: 14,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${session.participants.length}/${session.maxParticipants}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.outline,
                                ),
                          ),
                        ],
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            SessionDetailPage(sessionId: session.id),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    final cubit = context.read<LiveSessionCubit>();
    final titleController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    DateTime scheduledAt = DateTime.now().add(const Duration(minutes: 5));

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog(
              title: const Text('Create a Room'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Room title',
                        hintText: 'e.g. Flutter Q&A Session',
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      validator: (v) {
                        if (v == null || v.trim().length < 3) {
                          return 'Title must be at least 3 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Icon(
                          Icons.monetization_on_rounded,
                          size: 18,
                          color: Colors.amber.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Join Cost: 2 coins',
                          style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade900,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Starts at',
                      style: Theme.of(dialogContext).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 4),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.schedule_rounded, size: 18),
                      label: Text(
                        '${scheduledAt.hour.toString().padLeft(2, '0')}:${scheduledAt.minute.toString().padLeft(2, '0')} — ${scheduledAt.day}/${scheduledAt.month}/${scheduledAt.year}',
                      ),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: dialogContext,
                          initialDate: scheduledAt,
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 30)),
                        );
                        if (date == null) return;
                        if (!dialogContext.mounted) return;
                        final time = await showTimePicker(
                          context: dialogContext,
                          initialTime: TimeOfDay.fromDateTime(scheduledAt),
                        );
                        if (time == null) return;
                        setState(() {
                          scheduledAt = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    Navigator.pop(dialogContext);
                    final sessionId = await cubit.createSession(
                      title: titleController.text.trim(),
                      scheduledAt: scheduledAt,
                      type: 'group',
                    );
                    if (sessionId != null && context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              SessionDetailPage(sessionId: sessionId),
                        ),
                      );
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final isLive = status == 'live';
    final color = isLive ? Colors.red : Theme.of(context).colorScheme.outline;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        isLive ? '● LIVE' : status.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: isLive ? FontWeight.bold : FontWeight.normal,
            ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String type;
  const _TypeChip({required this.type});

  @override
  Widget build(BuildContext context) {
    final isOneOnOne = type == 'one-on-one';
    final color = isOneOnOne ? Colors.blue : Colors.green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOneOnOne ? Icons.person_rounded : Icons.groups_rounded,
            size: 10,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            isOneOnOne ? '1-to-1' : 'GROUP',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
