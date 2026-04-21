import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StaffTaskScreen extends StatefulWidget {
  final String staffId;
  final String staffName;

  const StaffTaskScreen({
    super.key,
    required this.staffId,
    required this.staffName,
  });

  @override
  State<StaffTaskScreen> createState() => _StaffTaskScreenState();
}

class _StaffTaskScreenState extends State<StaffTaskScreen> {
  List tasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getTasks();
  }

  Future getTasks() async {
    var response = await http.post(
      Uri.parse("https://prakrutitech.xyz/ankita/get_staff_tasks.php"),
      body: {
        "staff_id": widget.staffId,
      },
    );

    var data = jsonDecode(response.body);

    if (data["status"] == "success") {
      setState(() {
        tasks = data["data"];
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.staffName + " Tasks"),
        backgroundColor: Colors.blue.shade100,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : tasks.isEmpty
          ? Center(child: Text("No Tasks Found"))
          : ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          var task = tasks[index];

          return Card(
            margin: EdgeInsets.all(10),
            elevation: 3,
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task["task"] ?? "No task",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(task["description"] ?? ""),
                  SizedBox(height: 6),
                  Text(
                    "Status: ${task["status"]}",
                    style: TextStyle(color: Colors.green),
                  ),
                  SizedBox(height: 6),
                  Text(
                    task["created_at"],
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}