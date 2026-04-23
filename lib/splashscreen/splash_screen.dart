import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import '../Onboarding screen/Onboarding Screen.dart';
import '../signup/login_screen.dart';
import '../screens/user_dashboard.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkconnectivity();
  }

  void checkconnectivity() async {
    var connectivityresult = await Connectivity().checkConnectivity();

    if (connectivityresult != ConnectivityResult.none) {
      bool hasInternet = await checkInternetAccess();

      if (hasInternet) {
        checkNavigation();
      } else {
        shownetworkerrordialog();
      }
    } else {
      shownetworkerrordialog();
    }
  }

  Future<bool> checkInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  void checkNavigation() async {
    await Future.delayed(Duration(seconds:4));

    SharedPreferences prefs = await SharedPreferences.getInstance();

    bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isFirstTime) {
      await prefs.setBool('isFirstTime', false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => OnboardingScreen()),
      );
    } else {
      if (isLoggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => UserDashboard(name: "")),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => userLoginScreen()),
        );
      }
    }
  }

  void shownetworkerrordialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: const [
              Icon(Icons.wifi_off, color: Colors.red),
              SizedBox(width: 8),
              Text("No Internet"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset("assets/error.png", height: 120),
              SizedBox(height: 15),
              Text(
                "No internet connection.\nPlease check your network.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                checkconnectivity();
              },
              child: Text("Retry"),
            ),
            ElevatedButton(
              onPressed: () {
                exit(0);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text("Exit"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: Colors.black.withOpacity(0.5)),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(color: Colors.blue.shade50),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/no1.png", height: 250),
                SizedBox(height: 20),
                Text(
                  "Smart Society",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
