import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/features/home/data/mock_data.dart';
import 'package:skillswap/features/home/domain/models/user_model.dart';
import 'dart:ui';

class HomePage extends StatefulWidget {
  static MaterialPageRoute<dynamic> route() =>
      MaterialPageRoute(builder: (context) => const HomePage());
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  int _currentIndex = 0;
  late AnimationController _likeAnimationController;
  late Animation<double> _likeScaleAnimation;
  late Animation<double> _likeOpacityAnimation;
  bool _showHeart = false;

  late AnimationController _dislikeAnimationController;
  late Animation<double> _dislikeScaleAnimation;
  late Animation<double> _dislikeOpacityAnimation;
  late Animation<double> _dislikeShakeAnimation;
  bool _showClose = false;

  @override
  void initState() {
    super.initState();
    _likeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _likeScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.4)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.4, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 40,
      ),
    ]).animate(_likeAnimationController);

    _likeOpacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 20,
      ),
    ]).animate(_likeAnimationController);

    _dislikeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _dislikeScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.4)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.4, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 40,
      ),
    ]).animate(_dislikeAnimationController);

    _dislikeOpacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 20,
      ),
    ]).animate(_dislikeAnimationController);

    _dislikeShakeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -0.1),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.1, end: 0.1),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.1, end: 0.0),
        weight: 25,
      ),
    ]).animate(_dislikeAnimationController);
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    _dislikeAnimationController.dispose();
    super.dispose();
  }

  void _triggerLikeAnimation() {
    setState(() {
      _showHeart = true;
    });
    _likeAnimationController.forward(from: 0.0).then((_) {
      setState(() {
        _showHeart = false;
      });
      _nextCard();
    });
  }

  void _triggerDislikeAnimation() {
    setState(() {
      _showClose = true;
    });
    _dislikeAnimationController.forward(from: 0.0).then((_) {
      setState(() {
        _showClose = false;
      });
      _nextCard();
    });
  }

  void _nextCard() {
    if (_currentIndex < mockUsers.length - 1) {
      setState(() {
        _currentIndex++;
      });
    }
  }

  void _previousCard() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = mockUsers[_currentIndex];
    final hasMoreUsers = _currentIndex < mockUsers.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 70, // Increase leading width for the circle
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Center(
            child: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search,
                color: Color(0xFF1D2939),
                size: 20,
              ),
            ),
          ),
        ),
        title: Text(
          'SkillSwap',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: const Color(0xFF101828),
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.tune,
                color: Color(0xFF1D2939),
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  'TRENDING • CREATIVE ARTS',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: const Color(0xFF667085),
                  ),
                ),
                const Spacer(),
                Text(
                  '${_currentIndex + 1}/${mockUsers.length}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none, // Allow buttons to overflow the bottom
                children: [
                  GestureDetector(
                    onDoubleTap: _triggerLikeAnimation,
                    onHorizontalDragEnd: (details) {
                      if (details.primaryVelocity != null) {
                        if (details.primaryVelocity! < -300) {
                          _nextCard();
                        } else if (details.primaryVelocity! > 300) {
                          _previousCard();
                        }
                      }
                    },
                    child: _buildUserCard(currentUser, hasMoreUsers),
                  ),
                  if (_showHeart)
                    IgnorePointer(
                      child: AnimatedBuilder(
                        animation: _likeAnimationController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _likeOpacityAnimation.value,
                            child: Transform.scale(
                              scale: _likeScaleAnimation.value,
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.favorite,
                                  color: Colors.white,
                                  size: 100,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  if (_showClose)
                    IgnorePointer(
                      child: AnimatedBuilder(
                        animation: _dislikeAnimationController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _dislikeOpacityAnimation.value,
                            child: Transform.rotate(
                              angle: _dislikeShakeAnimation.value,
                              child: Transform.scale(
                                scale: _dislikeScaleAnimation.value,
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 100,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  if (!hasMoreUsers)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
                                color: Colors.white,
                                size: 80,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'No more profiles!',
                                style: GoogleFonts.inter(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _currentIndex = 0;
                                  });
                                },
                                child: Text(
                                  'Start Over',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFA67C52),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: -35, // Push buttons down to overlap card edge
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildCircleButton(
                            icon: Icons.close,
                            color: Colors.white.withOpacity(0.2), // Glass effect
                            iconColor: Colors.white,
                            onTap: _triggerDislikeAnimation,
                            enabled: hasMoreUsers,
                            isGlass: true,
                          ),
                          const SizedBox(width: 16),
                          _buildCircleButton(
                            icon: Icons.favorite,
                            color: const Color(0xFF9E6400), // Rich brown/orange
                            iconColor: Colors.white,
                            size: 84,
                            iconSize: 34,
                            hasShadow: true,
                            onTap: _triggerLikeAnimation,
                            enabled: hasMoreUsers,
                          ),
                          const SizedBox(width: 16),
                          _buildCircleButton(
                            icon: Icons.chat_bubble_outline,
                            color: Colors.white.withOpacity(0.2), // Glass effect
                            iconColor: Colors.white,
                            onTap: () {},
                            isGlass: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF0B6A7A), // Our tealColor
        unselectedItemColor: const Color(0xFF98A2B3),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4.0),
              child: Icon(Icons.auto_awesome_rounded),
            ),
            label: 'DISCOVER',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4.0),
              child: Icon(Icons.handshake_rounded),
            ),
            label: 'MATCHES',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4.0),
              child: Icon(Icons.favorite_rounded),
            ),
            label: 'LIKES',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4.0),
              child: Icon(Icons.person_rounded),
            ),
            label: 'PROFILE',
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(User user, bool hasMoreUsers) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(48),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(48),
        child: Stack(
          children: [
            Positioned.fill(child: Image.asset(user.imageUrl, fit: BoxFit.cover)),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.4, 0.9],
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 80,
              left: 24,
              right: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${user.name}, ${user.age}',
                        style: GoogleFonts.inter(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Color(0xFFFFB300),
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              user.rating.toString(),
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'TEACHING',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF4DD0E1), // Bright Cyan/Blue
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    user.teaching.name,
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'LEARNING',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFFFB74D), // Bright Orange
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    user.learning.name,
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required Color color,
    required Color iconColor,
    double size = 56,
    double iconSize = 24,
    bool hasShadow = false,
    VoidCallback? onTap,
    bool enabled = true,
    bool isGlass = false,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: isGlass ? 10 : 0,
            sigmaY: isGlass ? 10 : 0,
          ),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: enabled ? color : color.withOpacity(0.3),
              shape: BoxShape.circle,
              boxShadow: hasShadow && enabled
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
              border: isGlass
                  ? Border.all(color: Colors.white.withOpacity(0.2), width: 1.5)
                  : null,
            ),
            child: Icon(
              icon,
              color: enabled ? iconColor : iconColor.withOpacity(0.5),
              size: iconSize,
            ),
          ),
        ),
      ),
    );
  }
}
