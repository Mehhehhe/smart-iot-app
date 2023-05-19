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
      backgroundColor: Colors.white,
      body: PageView(
        controller: _pageController,
        children: <Widget>[
          // Onboarding pages go here
          Onboarding_Page0(),
          Onboarding_Page1(),
          Onboarding_Page2(),
          Onboarding_LastPage()
        ],
        onPageChanged: (int page) {
          setState(() {
            _currentPage = page;
          });
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Skip_button(),
              Row(
                children: <Widget>[
                  for (int i = 0; i < 4; i++)
                    if (i == _currentPage)
                      _buildDot(true)
                    else
                      _buildDot(false),
                ],
              ),
              Next_button(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: isActive ? 24 : 15,
      decoration: BoxDecoration(
        color: isActive ? Colors.red : Color.fromARGB(255, 255, 210, 125),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  _storeOnboardingStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setBool('onboarding', true);
  }

  Widget Next_button() {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: Colors.deepOrange.shade600,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
      ),
      child: TextButton(
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
            // Navigator.pushAndRemoveUntil(
            //   context,
            //   MaterialPageRoute(builder: (BuildContext context) {
            //     return farmCard();
            //   }),
            //   (r) {
            //     return false;
            //   },
            // );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => farmCard(),
              ),
            );
          }
        },
        child: Text(
          _currentPage == 3 ? "Finish" : "Next",
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
      ),
    );
  }

  Widget Skip_button() {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 223, 223, 223),
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
      ),
      child: TextButton(
        onPressed: () {
          _pageController.animateToPage(
            3,
            duration: const Duration(milliseconds: 2500),
            curve: Curves.fastLinearToSlowEaseIn,
          );
        },
        child: const Text(
          "Skip",
          style: TextStyle(
              color: Color.fromARGB(255, 126, 126, 126), fontSize: 15),
        ),
      ),
    );
  }

  Widget GetStart_button() {
    return BottomAppBar(
        child: Container(
      height: 77,
      width: 100,
      decoration: BoxDecoration(
        color: Colors.deepOrange.shade600,
      ),
      child: TextButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => farmCard()));
        },
        child: Text("GET STARTED NOW.",
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                letterSpacing: 4,
                fontWeight: FontWeight.bold)),
      ),
    ));
  }

// Introduction & First time settings

  Widget Onboarding_Page0() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 60, 0, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //Image.network('https://t4.ftcdn.net/jpg/02/63/38/55/360_F_263385574_H7SxVE8PwEY6p3Ur32MI4CsdgwXhEoaM.jpg', fit: BoxFit.cover, width: double.infinity,),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade400,
                  blurRadius: 5,
                  offset: Offset(12, 12), // Shadow position
                ),
              ],
            ),
            child: const Image(
              image: AssetImage('assets/images/onboarding0.png'),
              fit: BoxFit.cover,
              width: 200,
            ),
          ),
          const SizedBox(height: 35),
          const Text(
            "Simple farm management",
            style: TextStyle(
              color: Colors.deepOrange,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 24,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: const Text(
              "         You can check the performance of each farm's devices, and you can also change farms if there are more than one farm at the Change Farm button.",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget Onboarding_Page1() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 60, 0, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //Image.network('https://t4.ftcdn.net/jpg/02/63/38/55/360_F_263385574_H7SxVE8PwEY6p3Ur32MI4CsdgwXhEoaM.jpg', fit: BoxFit.cover, width: double.infinity,),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 20,
                  offset: Offset(18, 18), // Shadow position
                ),
              ],
            ),
            child: const Image(
              image: AssetImage('assets/images/onboarding1.png'),
              fit: BoxFit.cover,
              width: 200,
            ),
          ),
          const SizedBox(height: 35),
          const Text(
            "Manage device",
            style: TextStyle(
              color: Colors.deepOrange,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 24,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: const Text(
              "         View various details of the device and also get graph values ​​to report. You can also be configured Threthold of the device as well.",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget Onboarding_Page2() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 60, 0, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //Image.network('https://t4.ftcdn.net/jpg/02/63/38/55/360_F_263385574_H7SxVE8PwEY6p3Ur32MI4CsdgwXhEoaM.jpg', fit: BoxFit.cover, width: double.infinity,),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 20,
                  offset: Offset(18, 18), // Shadow position
                ),
              ],
            ),
            child: const Image(
              image: AssetImage('assets/images/onboarding2.png'),
              fit: BoxFit.cover,
              width: 200,
            ),
          ),
          const SizedBox(height: 35),
          const Text(
            "Perfomance and create report",
            style: TextStyle(
              color: Colors.deepOrange,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: const Text(
              "         See the performance of each device in detail and also have Other filtering modes to make graphs easier to view and also to take graph values to create a report.",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget Onboarding_LastPage() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 60, 0, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //Image.network('https://t4.ftcdn.net/jpg/02/63/38/55/360_F_263385574_H7SxVE8PwEY6p3Ur32MI4CsdgwXhEoaM.jpg', fit: BoxFit.cover, width: double.infinity,),

          const Image(
            image: AssetImage('assets/images/onboarding_lastscreen.png'),
            fit: BoxFit.cover,
            //width: 200,
          ),

          const SizedBox(height: 35),
          const Text(
            "You are ready",
            style: TextStyle(
              color: Colors.deepOrange,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 24,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: const Text(
              "If there is a problem, please try contacting the administrator.",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),
          )
        ],
      ),
    );
  }
}
