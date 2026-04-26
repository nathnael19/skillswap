import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:skillswap/core/theme/theme.dart';
import 'package:skillswap/features/auth/presentation/pages/login_page.dart';
import 'package:skillswap/features/hubs/data/models/hub_model.dart';
import 'package:skillswap/features/hubs/data/services/hub_backend_service.dart';
import 'package:skillswap/features/hubs/presentation/pages/hub_chat_page.dart';
import 'package:skillswap/features/hubs/presentation/pages/create_hub_page.dart';
import 'package:skillswap/init_dependencies.dart';
import 'package:google_fonts/google_fonts.dart';

class HubListPage extends StatefulWidget {
  const HubListPage({super.key});

  @override
  State<HubListPage> createState() => _HubListPageState();
}

class _HubListPageState extends State<HubListPage> {
  final HubBackendService _service = serviceLocator<HubBackendService>();
  bool _loading = true;
  String? _error;
  List<Hub> _hubs = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _service.listHubs();
      if (!mounted) return;
      setState(() {
        _hubs = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _join(Hub hub) async {
    if (FirebaseAuth.instance.currentUser == null) {
      if (!mounted) return;
      Navigator.of(context).push(LoginPage.route());
      return;
    }
    try {
      await _service.joinHub(hub.id);
      if (!mounted) return;
      await _load();
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HubChatPage(hubId: hub.id, hubName: hub.name),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    }
  }

  void _openHub(Hub hub) {
    if (FirebaseAuth.instance.currentUser == null) {
      Navigator.of(context).push(LoginPage.route());
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HubChatPage(hubId: hub.id, hubName: hub.name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skill Hubs'),
        actions: [
          IconButton.filledTonal(
            onPressed: () async {
              if (FirebaseAuth.instance.currentUser == null) {
                Navigator.of(context).push(LoginPage.route());
                return;
              }
              final created = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => const CreateHubPage()),
              );
              if (created == true) _load();
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: Text(
                  _error!,
                  style: const TextStyle(color: AppColors.error),
                ),
              )
            : _hubs.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.groups_3_rounded,
                      size: 64,
                      color: AppColors.overlay20,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hubs yet',
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Be the first to create a skill community!',
                      style: GoogleFonts.dmSans(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _hubs.length,
                separatorBuilder: (_, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final hub = _hubs[index];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hub.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          hub.description,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              '${hub.memberCount} members • ${hub.category}',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            if (hub.isMember)
                              FilledButton(
                                onPressed: () => _openHub(hub),
                                child: const Text('Open'),
                              )
                            else
                              OutlinedButton(
                                onPressed: () => _join(hub),
                                child: const Text('Join'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
