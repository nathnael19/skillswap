import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/core/common/cubits/connectivity/connectivity_cubit.dart';
import 'package:skillswap/core/layout/responsive.dart';
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
    return BlocListener<ConnectivityCubit, ConnectivityStatus>(
      listenWhen: (prev, curr) =>
          prev == ConnectivityStatus.disconnected &&
          curr == ConnectivityStatus.connected,
      listener: (context, _) => _load(),
      child: Scaffold(
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
                        style: GoogleFonts.dmSans(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : Responsive.isTwoPane(context)
              ? CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.all(
                        Responsive.contentHorizontalPadding(context),
                      ),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: Responsive.valueFor<double>(
                            context,
                            compact: 10,
                            mobile: 12,
                            tablet: 14,
                            tabletWide: 16,
                            desktop: 16,
                          ),
                          crossAxisSpacing: Responsive.valueFor<double>(
                            context,
                            compact: 10,
                            mobile: 12,
                            tablet: 14,
                            tabletWide: 16,
                            desktop: 16,
                          ),
                          childAspectRatio: 1.05,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildHubTile(_hubs[index]),
                          childCount: _hubs.length,
                        ),
                      ),
                    ),
                  ],
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(
                    Responsive.contentHorizontalPadding(context),
                  ),
                  itemCount: _hubs.length,
                  separatorBuilder: (_, _) => SizedBox(
                    height: Responsive.valueFor<double>(
                      context,
                      compact: 8,
                      mobile: 10,
                      tablet: 10,
                      tabletWide: 12,
                      desktop: 12,
                    ),
                  ),
                  itemBuilder: (context, index) => _buildHubTile(_hubs[index]),
                ),
        ),
      ),
    );
  }

  Widget _buildHubTile(Hub hub) {
    final pad = Responsive.valueFor<double>(
      context,
      compact: 12,
      mobile: 14,
      tablet: 14,
      tabletWide: 16,
      desktop: 16,
    );
    return Container(
      padding: EdgeInsets.all(pad),
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(
            height: Responsive.valueFor<double>(
              context,
              compact: 4,
              mobile: 6,
              tablet: 6,
              tabletWide: 8,
              desktop: 8,
            ),
          ),
          Text(
            hub.description,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
            maxLines: Responsive.isTwoPane(context) ? 4 : 8,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(
            height: Responsive.valueFor<double>(
              context,
              compact: 8,
              mobile: 10,
              tablet: 10,
              tabletWide: 10,
              desktop: 10,
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                '${hub.memberCount} members • ${hub.category}',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
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
  }
}
