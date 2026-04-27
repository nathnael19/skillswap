import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/core/layout/responsive.dart';
import 'package:skillswap/core/theme/theme.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(context),
        body: const Center(
          child: Text("Not logged in", style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('notifications')
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading notifications",
                style: GoogleFonts.dmSans(color: Colors.red[300]),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_rounded,
                    size: Responsive.valueFor<double>(
                      context,
                      compact: 48,
                      mobile: 56,
                      tablet: 60,
                      tabletWide: 64,
                      desktop: 64,
                    ),
                    color: AppColors.overlay10,
                  ),
                  SizedBox(
                    height: Responsive.valueFor<double>(
                      context,
                      compact: 12,
                      mobile: 14,
                      tablet: 16,
                      tabletWide: 16,
                      desktop: 16,
                    ),
                  ),
                  Text(
                    "No notifications yet",
                    style: GoogleFonts.dmSans(
                      color: AppColors.textSecondary,
                      fontSize: Responsive.valueFor<double>(
                        context,
                        compact: 14,
                        mobile: 15,
                        tablet: 16,
                        tabletWide: 16,
                        desktop: 16,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final hPad = Responsive.contentHorizontalPadding(context);
          final vPad = Responsive.valueFor<double>(
            context,
            compact: 12,
            mobile: 16,
            tablet: 18,
            tabletWide: 20,
            desktop: 20,
          );
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: Responsive.contentMaxWidthFor(context).isFinite
                    ? Responsive.contentMaxWidthFor(context)
                    : double.infinity,
              ),
              child: ListView.builder(
            padding: EdgeInsets.fromLTRB(hPad, vPad, hPad, vPad),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final title = data['title'] ?? 'Notification';
              final body = data['body'] ?? '';
              final isRead = data['is_read'] ?? false;
              final priority = data['priority'] ?? false;
              final Timestamp? createdAt = data['created_at'];

              String timeString = "Just now";
              if (createdAt != null) {
                timeString = DateFormat(
                  'MMM d, h:mm a',
                ).format(createdAt.toDate());
              }

              return GestureDetector(
                onTap: () {
                  if (!isRead) {
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUser.uid)
                        .collection('notifications')
                        .doc(docs[index].id)
                        .update({'is_read': true});
                  }
                },
                child: Container(
                  margin: EdgeInsets.only(
                    bottom: Responsive.valueFor<double>(
                      context,
                      compact: 8,
                      mobile: 10,
                      tablet: 12,
                      tabletWide: 12,
                      desktop: 12,
                    ),
                  ),
                  padding: EdgeInsets.all(
                    Responsive.valueFor<double>(
                      context,
                      compact: 12,
                      mobile: 14,
                      tablet: 15,
                      tabletWide: 16,
                      desktop: 16,
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: isRead ? AppColors.surface : AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: priority
                          ? AppColors.primary.withValues(alpha: 0.5)
                          : AppColors.overlay05,
                      width: priority ? 1 : 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(
                          Responsive.valueFor<double>(
                            context,
                            compact: 8,
                            mobile: 9,
                            tablet: 10,
                            tabletWide: 10,
                            desktop: 10,
                          ),
                        ),
                        decoration: BoxDecoration(
                          color: priority
                              ? AppColors.primary.withValues(alpha: 0.2)
                              : AppColors.overlay05,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          priority
                              ? Icons.priority_high_rounded
                              : Icons.notifications_rounded,
                          color: priority
                              ? AppColors.primary
                              : AppColors.textPrimary,
                          size: Responsive.valueFor<double>(
                            context,
                            compact: 18,
                            mobile: 19,
                            tablet: 20,
                            tabletWide: 20,
                            desktop: 22,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: Responsive.valueFor<double>(
                          context,
                          compact: 12,
                          mobile: 14,
                          tablet: 16,
                          tabletWide: 16,
                          desktop: 16,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    style: GoogleFonts.dmSans(
                                      fontWeight: isRead
                                          ? FontWeight.w500
                                          : FontWeight.bold,
                                      fontSize: Responsive.valueFor<double>(
                                        context,
                                        compact: 14,
                                        mobile: 15,
                                        tablet: 16,
                                        tabletWide: 16,
                                        desktop: 16,
                                      ),
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                if (!isRead)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              body,
                              style: GoogleFonts.dmSans(
                                color: AppColors.textSecondary,
                                fontSize: Responsive.valueFor<double>(
                                  context,
                                  compact: 12,
                                  mobile: 13,
                                  tablet: 14,
                                  tabletWide: 14,
                                  desktop: 14,
                                ),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              timeString,
                              style: GoogleFonts.dmSans(
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.5,
                                ),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(
        Responsive.valueFor<double>(
          context,
          compact: 64,
          mobile: 68,
          tablet: 70,
          tabletWide: 72,
          desktop: 72,
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: AppBar(
            backgroundColor: AppColors.background.withValues(alpha: 0.8),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.textPrimary,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              "NOTIFICATIONS",
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: AppColors.textPrimary,
                letterSpacing: 2.0,
              ),
            ),
            centerTitle: true,
            shape: const Border(
              bottom: BorderSide(color: AppColors.overlay05, width: 1),
            ),
          ),
        ),
      ),
    );
  }
}
