import 'package:flutter/material.dart';
import 'package:parentseye_parent/constants/app_colors.dart';

class IntroductionScreens extends StatefulWidget {
  const IntroductionScreens({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _IntroductionScreensState createState() => _IntroductionScreensState();
}

class _IntroductionScreensState extends State<IntroductionScreens> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<IntroPage> _pages = [
    IntroPage(
      title: "Welcome to ParentsEye",
      description:
          "This is a ParentsEye used for tracking school bus in real time",
      image: "assets/home.png",
      color: AppColors.primaryColor,
    ),
    IntroPage(
      title: "360 degree view of student",
      description: "From pickup to stop",
      image: "assets/home2.png",
      color: AppColors.primaryColor,
    ),
    IntroPage(
      title: "Smart Alerts and Notifications",
      description: "From pickup to stop",
      image: "assets/home3.png",
      color: AppColors.primaryColor,
    ),
    IntroPage(
      title: "Your profile will be prefilled from school",
      description: "It's that easy",
      image: "assets/home4.png",
      color: AppColors.primaryColor,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return _buildPageContent(_pages[index]);
            },
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: (_currentPage == _pages.length - 1)
                      ? [Container()]
                      : _buildPageIndicator(),
                ),
                if (_currentPage == _pages.length - 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.backgroundColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {},
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              "Get Started",
                              style: TextStyle(
                                  fontSize: 18, color: AppColors.textColor),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent(IntroPage page) {
    return Container(
      color: page.color,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            page.image,
            height: 300,
          ),
          const SizedBox(height: 50),
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              page.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageIndicator() {
    List<Widget> indicators = [];
    for (int i = 0; i < _pages.length; i++) {
      indicators.add(
        Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i == _currentPage ? Colors.white : Colors.white38,
          ),
        ),
      );
    }
    return indicators;
  }
}

class IntroPage {
  final String title;
  final String description;
  final String image;
  final Color color;

  IntroPage({
    required this.title,
    required this.description,
    required this.image,
    required this.color,
  });
}
