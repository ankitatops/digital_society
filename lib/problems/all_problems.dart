import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'add_problem_screen.dart';

class ProblemScreen extends StatefulWidget {
  const ProblemScreen({super.key});

  @override
  State<ProblemScreen> createState() => _ProblemScreenState();
}

class _ProblemScreenState extends State<ProblemScreen> {

  List allProblems = [];
  List solvedProblems = [];
  List pendingProblems = [];

  bool loading = true;

  String getUrl = "https://prakrutitech.xyz/ankita/get_problems.php";

  @override
  void initState() {
    super.initState();
    getProblems();
  }

  Future<void> getProblems() async {
    setState(() {
      loading = true;
    });

    var response = await http.get(Uri.parse(getUrl));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      List temp = data["data"];

      setState(() {
        allProblems = temp;
        solvedProblems = temp.where((p) {
          String status = p["status"].toString().trim().toLowerCase();
          return status == "closed" || status == "";
        }).toList();
        pendingProblems = temp.where((p) {
          String status = p["status"].toString().trim().toLowerCase();
          return status == "open" || status == "pending";
        }).toList();

        loading = false;
      });
    }
  }

  Future deleteProblem(String id, String userId) async {

    var url = Uri.parse("https://prakrutitech.xyz/ankita/delete_problem.php");

    var response = await http.post(url, body: {
      "id": id,
      "user_id": userId,
    });

    var data = jsonDecode(response.body);

    if (data["status"] == "success") {

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"]))
      );

      getProblems();

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"]))
      );
    }
  }

  Widget buildList(List list) {
    if (list.isEmpty) {
      return const Center(child: Text("No Data"));
    }

    return RefreshIndicator(
      onRefresh: getProblems,
      child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          var problem = list[index];

          String status =
          problem["status"].toString().trim().toLowerCase();

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0,3),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  problem["problem"],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text("User ID : ${problem["user_id"]}"),

                const SizedBox(height: 5),

                Text(
                  "Status : $status",
                  style: TextStyle(
                    color: (status == "closed" || status == "solved")
                        ? Colors.green
                        : Colors.red,
                  ),
                ),

                SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Delete Problem"),
                            content: const Text("Are you sure?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  deleteProblem(
                                    problem["id"].toString(),
                                    problem["user_id"].toString(),
                                  );
                                },
                                child: const Text(
                                  "Delete",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey.shade200,

        appBar: AppBar(
          title: const Text("Problems List"),
          backgroundColor: Colors.blue.shade100,
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: "All"),
              Tab(text: "Solved"),
              Tab(text: "Pending"),
            ],
          ),
        ),

        body: loading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
          children: [
            buildList(allProblems),
            buildList(solvedProblems),
            buildList(pendingProblems),
          ],
        ),

        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue.shade100,
          child: const Icon(Icons.add),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddProblemPage()),
            );
            getProblems();
          },
        ),
      ),
    );
  }
}