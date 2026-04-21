import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class VisitorsScreen extends StatefulWidget {
  @override
  _VisitorsScreenState createState() => _VisitorsScreenState();
}

class _VisitorsScreenState extends State<VisitorsScreen> {
  List visitors = [];
  bool isLoading = true;
  String userId = "";

  @override
  void initState() {
    super.initState();
    loadUserId();
  }

  Future<void> loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('user_id') ?? "";

    if (userId.isNotEmpty) {
      fetchVisitors();
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchVisitors() async {
    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("https://prakrutitech.xyz/ankita/get_visitors.php"),
        body: {"id": userId},
      );

      final res = jsonDecode(response.body);

      if (res['status'] == "success") {
        setState(() {
          visitors = res['data'] ?? [];
        });
      } else {
        visitors = [];
      }
    } catch (e) {
      print("Error: $e");
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.blue.shade100,
        title: Text("Visitors"),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: fetchVisitors,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : visitors.isEmpty
            ? Center(
          child: Text(
            "No Visitors Found",
            style: TextStyle(fontSize: 16),
          ),
        )
            : ListView.builder(
          itemCount: visitors.length,
          itemBuilder: (context, index) {
            final v = visitors[index];
            return Container(
              margin:
              EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.person, color: Colors.blue.shade50),
                  ),
                  title: Text(
                    v['name'] ?? "No Name",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(" ${v['mobile'] ?? "-"}"),
                        Text(" ${v['visit_date'] ?? "-"}"),
                        Text(" ${v['purpose'] ?? "-"}"),
                      ],
                    ),
                  ),
                  isThreeLine: true,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}