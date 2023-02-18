import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/view/farm_card.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';

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
      backgroundColor: Colors.yellow.shade500,
      body: PageView(
        controller: _pageController,
        children: <Widget>[
          // Onboarding pages go here
          OnboardingPage1(),
          OnboardingPage2(),
          OnboardingPage3(),
          OnboardingPage4()
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
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.linear,
                );
              },
              child: const Text("Skip"),
            ),
            Row(
              children: <Widget>[
                for (int i = 0; i < 4; i++)
                  if (i == _currentPage) _buildDot(true) else _buildDot(false),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                if (_currentPage != 3) {
                  _pageController.animateToPage(
                    _currentPage + 1,
                    duration: const Duration(milliseconds: 400),
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
                _currentPage == 3 ? "Finish" : "Next",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.green : Colors.amber,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  _storeOnboardingStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('onboarding', true);
  }

// Introduction & First time settings

  Widget OnboardingPage1() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //Image.network('https://t4.ftcdn.net/jpg/02/63/38/55/360_F_263385574_H7SxVE8PwEY6p3Ur32MI4CsdgwXhEoaM.jpg', fit: BoxFit.cover, width: double.infinity,),
          const Image(
            image: AssetImage('assets/images/onboarding0.png'),
            fit: BoxFit.cover,
            width: double.infinity,
          ),
          const SizedBox(height: 35),
          const Text(
            "Let get started",
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 24,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: const Text(
              "Would you like to read how to use it? if you don't want you can press the Skip button at the top right at any time.",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget OnboardingPage2() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            'https://media.istockphoto.com/id/511991248/vector/smartphone-with-app-icons.jpg?s=612x612&w=0&k=20&c=UmEdw7hbpARzqW5bJEZc4sBao0WA56wB-vZlBGkI23k=',
            fit: BoxFit.cover,
            width: double.infinity,
          ),
          const SizedBox(height: 35),
          const Text(
            "Manage your device",
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 24,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: const Text(
              "you can manage device on your farm by pressing manage button and change farm by press select farm button",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget OnboardingPage3() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            'https://media.istockphoto.com/id/511991248/vector/smartphone-with-app-icons.jpg?s=612x612&w=0&k=20&c=UmEdw7hbpARzqW5bJEZc4sBao0WA56wB-vZlBGkI23k=',
            fit: BoxFit.cover,
            width: double.infinity,
          ),
          const SizedBox(height: 35),
          const Text(
            "View all history",
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 24,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: const Text(
              "If you want to see the status of devices within the farm. You can press the History button on the home page.",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget OnboardingPage4() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Image(
            image: AssetImage('assets/images/onboarding2.png'),
            fit: BoxFit.cover,
            width: double.infinity,
          ),
          const SizedBox(height: 35),
          const Text(
            "You ready now !",
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 24,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => farmCard()));
              },
              style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))),
              child: Ink(
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Colors.deepOrangeAccent, Colors.orangeAccent]),
                    // color: Colors.orangeAccent,
                    borderRadius: BorderRadius.circular(15)),
                child: Container(
                  width: 300,
                  height: 50,
                  alignment: Alignment.center,
                  child: const Text(
                    'Get Started',
                    style: const TextStyle(
                      fontSize: 24,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
