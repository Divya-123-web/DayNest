import 'package:daynest/theme/app-colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';

/// Simple data holder for one onboarding page.
class _OnboardingPageData {
final IconData mainIcon;
final IconData accentIcon;
final String title;
final String description;

const _OnboardingPageData({
required this.mainIcon,
required this.accentIcon,
required this.title,
required this.description,
});
}

/// Three-page introduction shown to new users.
/// Tapping "Get Started" or "Skip" opens [nextScreen].
/// (Later, nextScreen will be the Login screen.)
class OnboardingScreen extends StatefulWidget {
final Widget nextScreen;

const OnboardingScreen({super.key, required this.nextScreen});

@override
State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
final PageController _pageController = PageController();
int _currentPage = 0;

static const List<_OnboardingPageData> _pages = [
_OnboardingPageData(
mainIcon: Icons.checklist_rounded,
accentIcon: Icons.flag_rounded,
title: 'Organize your tasks',
description:
'Create tasks, set priorities and due dates, and never miss what matters most.',
),
_OnboardingPageData(
mainIcon: Icons.sticky_note_2_rounded,
accentIcon: Icons.cloud_done_rounded,
title: 'Notes that follow you',
description:
'Write personal notes and sync them to the cloud, ready on every device you use.',
),
_OnboardingPageData(
mainIcon: Icons.bar_chart_rounded,
accentIcon: Icons.trending_up_rounded,
title: 'Track your productivity',
description:
'See your progress with simple charts and build the habit of finishing your day.',
),
];

bool get _isLastPage => _currentPage == _pages.length - 1;

@override
void dispose() {
_pageController.dispose();
super.dispose();
}

// Moves to the next page, or finishes on the last page.
void _onNextPressed() {
if (_isLastPage) {
_finishOnboarding();
} else {
_pageController.nextPage(
duration: const Duration(milliseconds: 400),
curve: Curves.easeInOut,
);
}
}

// Leaves onboarding with a smooth fade.
void _finishOnboarding() {
Navigator.of(context).pushReplacement(
PageRouteBuilder(
pageBuilder: (context, animation, secondaryAnimation) =>
widget.nextScreen,
transitionsBuilder: (context, animation, secondaryAnimation, child) {
return FadeTransition(opacity: animation, child: child);
},
transitionDuration: const Duration(milliseconds: 500),
),
);
}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: AppColors.warmCream,
body: SafeArea(
child: Column(
children: [
// Skip button (hidden on the last page but keeps its space)
Align(
alignment: Alignment.centerRight,
child: Padding(
padding: const EdgeInsets.only(top: 8, right: 16),
child: Visibility(
visible: !_isLastPage,
maintainSize: true,
maintainAnimation: true,
maintainState: true,
child: TextButton(
onPressed: _finishOnboarding,
child: const Text('Skip'),
),
),
),
),

// Swipeable pages  
        Expanded(  
          child: PageView.builder(  
            controller: _pageController,  
            itemCount: _pages.length,  
            onPageChanged: (index) {  
              setState(() => _currentPage = index);  
            },  
            itemBuilder: (context, index) {  
              return _OnboardingPage(data: _pages[index]);  
            },  
          ),  
        ),  

        // Page indicator dots  
        Row(  
          mainAxisAlignment: MainAxisAlignment.center,  
          children: List.generate(_pages.length, (index) {  
            final bool isActive = index == _currentPage;  
            return AnimatedContainer(  
              duration: const Duration(milliseconds: 300),  
              margin: const EdgeInsets.symmetric(horizontal: 4),  
              width: isActive ? 28 : 8,  
              height: 8,  
              decoration: BoxDecoration(  
                color: isActive ? AppColors.terracotta : AppColors.peach,  
                borderRadius: BorderRadius.circular(4),  
              ),  
            );  
          }),  
        ),  

        const SizedBox(height: 28),  

        // Next / Get Started button  
        Padding(  
          padding: const EdgeInsets.symmetric(horizontal: 24),  
          child: ElevatedButton(  
            onPressed: _onNextPressed,  
            child: Text(_isLastPage ? 'Get Started' : 'Next'),  
          ),  
        ),  

        const SizedBox(height: 32),  
      ],  
    ),  
  ),  
);

}
}

/// One page: illustration on top, title and description below.
class _OnboardingPage extends StatelessWidget {
final _OnboardingPageData data;

const _OnboardingPage({required this.data});

@override
Widget build(BuildContext context) {
return Center(
child: SingleChildScrollView(
padding: const EdgeInsets.symmetric(horizontal: 32),
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
_Illustration(
mainIcon: data.mainIcon,
accentIcon: data.accentIcon,
),
const SizedBox(height: 40),
Text(
data.title,
textAlign: TextAlign.center,
style: GoogleFonts.poppins(
fontSize: 26,
fontWeight: FontWeight.w700,
color: AppColors.darkBrown,
),
),
const SizedBox(height: 14),
Text(
data.description,
textAlign: TextAlign.center,
style: GoogleFonts.poppins(
fontSize: 15,
height: 1.6,
color: AppColors.textSecondary,
),
),
],
),
),
);
}
}

/// Illustration built only from circles, a card and icons.
class _Illustration extends StatelessWidget {
final IconData mainIcon;
final IconData accentIcon;

const _Illustration({required this.mainIcon, required this.accentIcon});

@override
Widget build(BuildContext context) {
return SizedBox(
width: 260,
height: 260,
child: Stack(
alignment: Alignment.center,
children: [
// Large soft background circle
Container(
width: 240,
height: 240,
decoration: const BoxDecoration(
color: AppColors.lightApricot,
shape: BoxShape.circle,
),
),

// Small decorative circles  
      Positioned(  
        top: 14,  
        left: 20,  
        child: Container(  
          width: 36,  
          height: 36,  
          decoration: const BoxDecoration(  
            color: AppColors.peach,  
            shape: BoxShape.circle,  
          ),  
        ),  
      ),  
      Positioned(  
        bottom: 24,  
        left: 6,  
        child: Container(  
          width: 20,  
          height: 20,  
          decoration: const BoxDecoration(  
            color: AppColors.softBeige,  
            shape: BoxShape.circle,  
          ),  
        ),  
      ),  

      // Main white card with big icon  
      Container(  
        width: 150,  
        height: 150,  
        decoration: BoxDecoration(  
          color: AppColors.white,  
          borderRadius: BorderRadius.circular(40),  
          boxShadow: const [  
            BoxShadow(  
              color: AppColors.shadow,  
              blurRadius: 28,  
              offset: Offset(0, 12),  
            ),  
          ],  
        ),  
        child: Icon(mainIcon, size: 80, color: AppColors.terracotta),  
      ),  

      // Small floating badge with accent icon  
      Positioned(  
        top: 34,  
        right: 22,  
        child: Container(  
          width: 62,  
          height: 62,  
          decoration: BoxDecoration(  
            gradient: const LinearGradient(  
              begin: Alignment.topLeft,  
              end: Alignment.bottomRight,  
              colors: [AppColors.peach, AppColors.terracotta],  
            ),  
            borderRadius: BorderRadius.circular(20),  
            boxShadow: const [  
              BoxShadow(  
                color: AppColors.shadow,  
                blurRadius: 16,  
                offset: Offset(0, 6),  
              ),  
            ],  
          ),  
          child: Icon(accentIcon, size: 30, color: AppColors.white),  
        ),  
      ),  
    ],  
  ),  
);

}
}