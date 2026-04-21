import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MaintenanceScreen extends StatefulWidget {
  @override
  _MaintenanceScreenState createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  List data = [];
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
      fetchMaintenance();
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchMaintenance() async {
    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("https://prakrutitech.xyz/ankita/get_maintenance.php"),
        body: {"user_id": userId},
      );

      final res = jsonDecode(response.body);

      if (res['status'] == "success") {
        setState(() {
          data = res['data'] ?? [];
        });
      }
    } catch (e) {
      print("Error: $e");
    }

    setState(() => isLoading = false);
  }

  Color getStatusColor(String status) {
    return status == "paid" ? Colors.green : Colors.red;
  }

  Color getStatusBgColor(String status) {
    return status == "paid"
        ? Colors.green.shade100
        : Colors.red.shade100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Maintenance"),
        centerTitle: true,
        backgroundColor: Colors.blue.shade100,
      ),
      body: RefreshIndicator(
        onRefresh: fetchMaintenance,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : data.isEmpty
            ? Center(child: Text("No Maintenance Found"))
            : ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            var item = data[index];

            String amount = item['amount'] ?? "0";
            String date = item['due_date']?.toString() ?? "";
                item['created_at'] ??
                item['payment_date'] ??
                "";

            String status =
            (item['status'] ?? "unpaid").toLowerCase();

            return Container(
              margin: EdgeInsets.symmetric(
                  horizontal: 15, vertical: 8),
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Amount",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "₹$amount",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      if (date.isNotEmpty)
                        Text(
                          "Due Date: ${date.split(" ")[0]}",
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.black54,
                          ),
                        ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.end,
                    children: [
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: getStatusBgColor(status),
                          borderRadius:
                          BorderRadius.circular(20),
                        ),
                        child: Text(
                          status == "paid"
                              ? "Paid"
                              : "Unpaid",
                          style: TextStyle(
                            color:
                            getStatusColor(status),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}