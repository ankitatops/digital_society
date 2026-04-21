import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Notice extends StatefulWidget {
  const Notice({super.key});

  @override
  State<Notice> createState() => _NoticeState();
}

class _NoticeState extends State<Notice> {
  List notice = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getNotice();
  }

  Future getNotice() async {
    var response = await http.get(
      Uri.parse("https://prakrutitech.xyz/ankita/get_notices.php"),
    );

    var data = jsonDecode(response.body);

    if (data["status"] == "success") {
      setState(() {
        notice = data["data"];
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Future deleteNotice(String id) async {
    var response = await http.post(
      Uri.parse("https://prakrutitech.xyz/ankita/delete_notice.php"),
      body: {"id": id},
    );

    var data = jsonDecode(response.body);

    if (data["status"] == "success") {
      getNotice();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Notice Deleted")));
    }
  }

  void showDeleteDialog(String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Notice"),
          content: Text("Are you sure you want to delete this notice?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                deleteNotice(id);
                Navigator.pop(context);
              },
              child: Text("Delete",style: TextStyle(color: Colors.white),),
            ),
          ],
        );
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notice Board", style: TextStyle(color: Colors.black),),
        centerTitle: true,
        backgroundColor: Colors.blue.shade100,
      ),
      body: RefreshIndicator(
        onRefresh: getNotice,
        child: Padding(
          padding: EdgeInsets.all(14),
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
            itemCount: notice.length,
            itemBuilder: (context, index) {
              var data = notice[index];

              return Card(
                elevation: 4,
                margin: EdgeInsets.only(bottom: 14),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data["title"],
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(data["message"]),
                      SizedBox(height: 8),
                      Text(
                        data["created_at"],
                        style: TextStyle(color: Colors.indigo),
                      ),

                    ],
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