// ignore_for_file: unused_element, unused_field
import 'package:chat_flutter_poc/features/profile/presentation/screens/profile.dart';
import 'package:flutter/material.dart';

import 'package:chat_flutter_poc/features/chat_list/presentation/screens/chat_screen.dart';
import 'package:chat_flutter_poc/features/study/presentation/screens/study_screen.dart';

import 'package:chat_flutter_poc/core/theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final PageController _pageController;

  final List<Widget> _screens = const [ChatScreen(), StudyScreen()];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String get _screenTitle => _selectedIndex == 0 ? 'Chat' : 'Study';

  String get _sectionTitle =>
      _selectedIndex == 0 ? 'Your conversations' : 'Your learning space';

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openProfile() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Main header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _screenTitle,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Search',
                    onPressed: () => _showComingSoon('Search'),
                    icon: const Icon(Icons.search),
                  ),
                  if (_selectedIndex == 0)
                    IconButton(
                      tooltip: 'New chat',
                      onPressed: () => _showComingSoon('New chat'),
                      icon: const Icon(Icons.add_comment_outlined),
                    )
                  else
                    IconButton(
                      tooltip: 'Saved materials',
                      onPressed: () => _showComingSoon('Saved materials'),
                      icon: const Icon(Icons.bookmark_outline),
                    ),
                  IconButton(
                    tooltip: 'Profile',
                    onPressed: _openProfile,
                    icon: const Icon(Icons.account_circle_outlined),
                  ),
                ],
              ),
            ),

            // Swipeable screen content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: _screens,
              ),
            ),
          ],
        ),
      ),
      // Floating bottom navigation
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppColors.radius2xl),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.chat_bubble_outline,
                  selectedIcon: Icons.chat_bubble,
                  label: 'Chat',
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.menu_book_outlined,
                  selectedIcon: Icons.menu_book,
                  label: 'Study',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isSelected = _selectedIndex == index;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Material(
          color: isSelected ? colors.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(AppColors.radiusLg),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppColors.radiusLg),
            onTap: () => _onTabSelected(index),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isSelected ? selectedIcon : icon,
                  color: isSelected
                      ? colors.onPrimaryContainer
                      : colors.onSurfaceVariant,
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isSelected
                        ? colors.onPrimaryContainer
                        : colors.onSurfaceVariant,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
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
