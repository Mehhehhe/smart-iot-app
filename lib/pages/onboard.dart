import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/view/farm_card.dart';

class OnboardingPage extends StatefulWidget {
  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: <Widget>[
          // Onboarding pages go here
          OnboardingPage1(),
          OnboardingPage2(),
          OnboardingPage3(),
        ],
        onPageChanged: (int page) {
          setState(() {
            _currentPage = page;
          });
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                _pageController.animateToPage(
                  2,
                  duration: Duration(milliseconds: 400),
                  curve: Curves.linear,
                );
              },
              child: Text("Skip"),
            ),
            Row(
              children: <Widget>[
                for (int i = 0; i < 3; i++)
                  if (i == _currentPage) _buildDot(true) else _buildDot(false),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                if (_currentPage != 2) {
                  _pageController.animateToPage(
                    _currentPage + 1,
                    duration: Duration(milliseconds: 400),
                    curve: Curves.linear,
                  );
                } else {
                  _storeOnboardingStatus();
                  // Navigator.of(context).pushReplacementNamed('/home');
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => farmCard(),
                  ));
                }
              },
              child: Text(
                _currentPage == 2 ? "Finish" : "Next",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.only(right: 8),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.green : Colors.amber,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  _storeOnboardingStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('onboarding', true);
  }

  Widget OnboardingPage1() {
    return Container(
      color: Colors.red,
    );
  }

  Widget OnboardingPage2() {
    return Container(
      color: Colors.green,
    );
  }

  Widget OnboardingPage3() {
    return Container(
      color: Colors.yellow,
    );
  }
}
