import 'dart:convert';
import 'dart:ui';
import 'package:digital_society/screens/profileScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Events/EventDetails.dart';
import '../maintenance/maintenance_screen.dart';
import '../notice/notice_detail.dart';
import '../problems/all_problems.dart';
import '../staff/staff_screen.dart';
import '../visitors/visitors_screen.dart';
import 'package:shimmer/shimmer.dart';

class UserDashboard extends StatefulWidget {
  final String name;

  const UserDashboard({Key? key, required this.name}) : super(key: key);

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int selectedIndex = 0;
  List events = [];
  bool isLoading = true;
  int eventCount = 0;
  int noticeCount = 0;
  int complaintCount = 0;
  List notices = [];
  bool isNoticeLoading = true;
  List maintenanceList = [];
  bool isMaintenanceLoading = true;
  String maintenanceAmount = "0";
  double totalDue = 0;
  bool allPaid = false;
  bool hasMaintenance = false;
  List problems = [];
  bool isProblemLoading = true;
  int todayVisitors = 0;
  bool isVisitorLoading = true;
  List<Color> eventColors = [
    Colors.purple.shade400,
    // Colors.blue,
    // Colors.green,
    // Colors.orange,
    // Colors.cyan,
    // Colors.pink,
  ];

  final List quickActions = [
    {"icon": Icons.notifications, "title": "Notices"},
    {"icon": Icons.payments, "title": "Maintenance"},
    {"icon": Icons.report_problem, "title": "Complaint"},
    {"icon": Icons.people, "title": "Visitors"},
  ];

  @override
  void initState() {
    super.initState();
    fetchEvents();
    fetchNotices();
    fetchMaintenance();
    fetchProblems();
    fetchTodayVisitors();
  }

  Future<void> fetchTodayVisitors() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('user_id') ?? "";

    try {
      final response = await http.post(
        Uri.parse("https://prakrutitech.xyz/ankita/get_visitors.php"),
        body: {"id": userId},
      );

      final res = jsonDecode(response.body);

      if (res['status'] == "success") {
        List allVisitors = res['data'] ?? [];

        String today = DateTime.now().toString().split(" ")[0]; // yyyy-MM-dd

        int count = 0;

        for (var v in allVisitors) {
          if (v['visit_date'] != null &&
              v['visit_date'].toString().startsWith(today)) {
            count++;
          }
        }

        setState(() {
          todayVisitors = count;
          isVisitorLoading = false;
        });
      } else {
        setState(() {
          todayVisitors = 0;
          isVisitorLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isVisitorLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to load visitors")));
    }
  }

  Future<void> fetchMaintenance() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('user_id') ?? "";

    var res = await http.post(
      Uri.parse(
        "https://prakrutitech.xyz/ankita/get_maintenance.php?time=${DateTime.now().millisecondsSinceEpoch}",
      ),
      body: {"user_id": userId},
    );

    var json = jsonDecode(res.body);

    if (json['status'] == "success") {
      List data = json['data'];

      bool hasUnpaid = false;
      bool tempHasMaintenance = data.isNotEmpty;

      for (var item in data) {
        String status = item['status'].toString().toLowerCase().trim();
        if (status != "paid") {
          hasUnpaid = true;
        }
      }

      setState(() {
        hasMaintenance = tempHasMaintenance;
        allPaid = !hasUnpaid;
        isMaintenanceLoading = false;
      });
    } else {
      setState(() {
        hasMaintenance = false;
        isMaintenanceLoading = false;
      });
    }
  }

  Future<void> fetchProblems() async {
    try {
      var response = await http.get(
        Uri.parse("https://prakrutitech.xyz/ankita/get_problems.php"),
      );

      var data = jsonDecode(response.body);

      if (data["status"] == "success" && data["data"] != null) {
        setState(() {
          problems = data["data"];
          complaintCount = problems.length;
          isProblemLoading = false;
        });
      } else {
        setState(() {
          problems = [];
          complaintCount = 0;
          isProblemLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isProblemLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to load Problems")));
    }
  }

  Future<void> fetchNotices() async {
    try {
      var response = await http.post(
        Uri.parse("https://prakrutitech.xyz/ankita/get_notices.php"),
      );

      var data = json.decode(response.body);

      if (data["status"] == "success" && data["data"] != null) {
        setState(() {
          notices = data["data"];
          noticeCount = notices.length;
          isNoticeLoading = false;
        });
      } else {
        setState(() {
          notices = [];
          isNoticeLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isNoticeLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to load Notices")));
    }
  }

  Future<void> fetchEvents() async {
    try {
      var response = await http.post(
        Uri.parse("https://prakrutitech.xyz/ankita/get_events.php"),
      );

      var data = json.decode(response.body);

      if (data["status"] == "success" && data["data"] != null) {
        setState(() {
          events = data["data"];
          eventCount = events.length;
          isLoading = false;
        });
      } else {
        setState(() {
          events = [];
          eventCount = 0;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to load events")));
    }
  }

  String formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      return "${parsedDate.day.toString().padLeft(2, '0')}-"
          "${parsedDate.month.toString().padLeft(2, '0')}-"
          "${parsedDate.year}";
    } catch (e) {
      return date;
    }
  }

  Widget mainDashboardUI() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade200],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await fetchEvents();
              await fetchNotices();
              await fetchMaintenance();
              await fetchProblems();
              await fetchTodayVisitors();
            },
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Hello, ${widget.name}",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, color: Colors.black),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        statCard(
                          "Notices",
                          noticeCount.toString(),
                          Colors.blue,
                        ),
                        statCard("Events", eventCount.toString(), Colors.green),
                        statCard(
                          "Complaints",
                          problems.length.toString(),
                          Colors.red,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),
                  sectionTitle("Quick Access"),

                  SizedBox(height: 20),

                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: quickActions.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(left: 19),
                          child: quickButton(
                            quickActions[index]["icon"],
                            quickActions[index]["title"],
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 20),
                  SizedBox(
                    height: 180,
                    child: isLoading
                        ? SizedBox(
                            height: 180,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: 3,
                              itemBuilder: (_, __) => Padding(
                                padding: EdgeInsets.only(left: 16),
                                child: Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    width: 160,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : events.isEmpty
                        ? Center(
                            child: Text(
                              "No Events",
                              style: TextStyle(color: Colors.black),
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: events.length,
                            itemBuilder: (context, index) {
                              var event = events[index];

                              Color color =
                                  eventColors[index % eventColors.length];

                              return eventCard(
                                event["event_name"] ??
                                    event["title"] ??
                                    event["name"] ??
                                    "No Title",
                                formatDate(event["event_date"] ?? ""),
                                color,
                                event,
                              );
                            },
                          ),
                  ),

                  SizedBox(height: 20),
                  sectionTitle("Recent Notices"),

                  Padding(
                    padding: EdgeInsets.all(16),
                    child: isNoticeLoading
                        ? Column(
                            children: List.generate(
                              3,
                              (index) => Padding(
                                padding: EdgeInsets.only(bottom: 10),
                                child: Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : notices.isEmpty
                        ? Text("No Notices")
                        : Column(
                            children: notices.map<Widget>((notice) {
                              return noticeCard(notice["title"] ?? "No Title");
                            }).toList(),
                          ),
                  ),

                  sectionTitle("Quick Info"),

                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: infoCard(
                            "Maintenance",
                            isMaintenanceLoading
                                ? "Loading..."
                                : !hasMaintenance
                                ? "No Maintenance"
                                : allPaid
                                ? "Paid"
                                : "Due Pending",
                            Colors.orange,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: infoCard(
                            "Visitors",
                            isVisitorLoading ? "..." : "$todayVisitors Today",
                            Colors.teal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent;

    if (selectedIndex == 0) {
      bodyContent = mainDashboardUI();
    } else if (selectedIndex == 1) {
      bodyContent = staff();
    } else {
      bodyContent = profile();
    }

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: bodyContent,

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: "staff"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget statCard(String title, String value, Color color) {
    return Container(
      width: 100,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(title, style: TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  Widget quickButton(IconData icon, String title) {
    return GestureDetector(
      onTap: () {
        if (title == "Notices") {
          Navigator.push(context, MaterialPageRoute(builder: (_) => Notice()));
        }

        if (title == "Complaint") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProblemScreen()),
          );
        }
        if (title == "Visitors") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => VisitorsScreen()),
          );
        }
        if (title == "Maintenance") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MaintenanceScreen()),
          );
        }
      },
      child: Container(
        width: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.indigo),
            SizedBox(height: 5),
            Text(title, style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget eventCard(String title, String date, Color color, Map eventData) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EventDetailsPage(event: eventData)),
        );
      },
      child: Container(
        width: 160,
        margin: EdgeInsets.only(left: 16),
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(colors: [color, color.withOpacity(0.6)]),
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              color: Colors.black12,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(date, style: TextStyle(color: Colors.white70, fontSize: 22)),
          ],
        ),
      ),
    );
  }

  Widget noticeCard(String text) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.notifications, color: Colors.indigo),
          SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget infoCard(String title, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: color)),
          SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}
