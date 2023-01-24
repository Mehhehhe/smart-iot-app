import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingPage();
}

class _SettingPage extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: ListView(
        children: [
          Text("Settings"),
          Divider(),
          if (kDebugMode) _showOnboarding()
        ],
      )),
    );
  }

  Widget _showOnboarding() {
    return Row(
      children: [
        Text("Reset Onboarding"),
        ElevatedButton(
            onPressed: _resetOnboarding,
            child: const Text("Reset Onboarding Completed"))
      ],
    );
  }

  _isOnboardingCompleted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding') ?? false;
  }

  _resetOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('onboarding');
  }
}
