import 'dart:convert';
import 'package:digital_society/staff/staff_task_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class staff extends StatefulWidget {
  const staff({super.key});

  @override
  State<staff> createState() => _staffState();
}

class _staffState extends State<staff> {
  List staff = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getstaff();
  }

  Future getstaff() async {
    var response = await http.get(
      Uri.parse("https://prakrutitech.xyz/ankita/get_all_staff.php"),
    );

    var data = jsonDecode(response.body);

    if (data["status"] == "success") {
      setState(() {
        staff = data["data"];
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Staff"),
        centerTitle: true,
        backgroundColor: Colors.blue.shade100,
      ),
      body: RefreshIndicator(
        onRefresh: getstaff,
        child: Padding(
          padding: EdgeInsets.all(14),
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: staff.length,
                  itemBuilder: (context, index) {
                    var data = staff[index];

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StaffTaskScreen(
                              staffId: data["id"].toString(),
                              staffName: data["name"],
                            ),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 4,
                        margin: EdgeInsets.only(bottom: 14),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.blue.shade100,
                                    child: Text(
                                      data["id"].toString(),
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    data["name"],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(data["role"]),
                                  SizedBox(height: 10),
                                  Text(
                                    data["created_at"],
                                    style: TextStyle(color: Colors.indigo),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
