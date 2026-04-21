import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EventDetailsPage extends StatelessWidget {
  final Map event;

  const EventDetailsPage({super.key, required this.event});

  Future deleteEvent(BuildContext context) async {
    try {
      await http.post(
        Uri.parse("https://prakrutitech.xyz/ankita/delete_event.php"),
        body: {"id": event["id"].toString()},
      );

      Navigator.pop(context, true);
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = "";

    if (event["image"] != null && event["image"].toString().isNotEmpty) {
      imageUrl =
      "https://prakrutitech.xyz/ankita/uploads/events/${event["image"]}";
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 600,
              height: 700,
              color: Colors.grey.shade300,
              child: imageUrl.isEmpty
                  ? Center(
                      child: Icon(Icons.image_not_supported, size: 80),
                    )
                  : Image.network(
                      imageUrl,
                       fit: BoxFit.contain,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(Icons.broken_image, size: 80),
                        );
                      },
                    ),
            ),
            SizedBox(height: 20),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event["event_title"] ?? event["title"] ?? "",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: Colors.indigo,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        event["event_date"] ?? "No Date",
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),

                  SizedBox(height: 10),
                  Text(
                    event["description"] ??
                        event["event_description"] ??
                        "No Description",
                    style: const TextStyle(fontSize: 15, height: 1.5),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
