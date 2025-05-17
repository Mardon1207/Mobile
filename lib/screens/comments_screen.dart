import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Add for date formatting

class CommentsScreen extends StatefulWidget {
  final int listingId;

  CommentsScreen({required this.listingId});

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  List<dynamic> comments = [];
  Map<int, String> userCache = {}; // Cache for user IDs and usernames
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchComments();
  }

  Future<void> fetchComments() async {
    final url =
        "https://thawing-island-81474-bbf58f5cbf05.herokuapp.com/reviews/${widget.listingId}/";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          comments = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to load comments");
      }
    } catch (e) {
      print("Error fetching comments: $e");
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to load comments")));
    }
  }

  Future<String> fetchUsername(int userId) async {
    if (userCache.containsKey(userId)) {
      return userCache[userId]!;
    }
    final url =
        "https://thawing-island-81474-bbf58f5cbf05.herokuapp.com/users/$userId/";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final username = data['username'] ?? "Anonymous";
        userCache[userId] = username; // Cache the username
        return username;
      } else {
        throw Exception("Failed to load username");
      }
    } catch (e) {
      print("Error fetching username for user $userId: $e");
      return "Anonymous";
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    } catch (_) {
      return "Unknown";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Comments",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      backgroundColor: Color(0xFFF7F9FA),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator(color: Colors.teal))
              : comments.isEmpty
              ? Center(
                child: Text(
                  "No comments available.",
                  style: TextStyle(
                    color: Colors.teal,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
              : ListView.separated(
                padding: EdgeInsets.all(20.0),
                separatorBuilder: (_, __) => SizedBox(height: 10),
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  var comment = comments[index];
                  return FutureBuilder<String>(
                    future: fetchUsername(comment['user'] ?? 0),
                    builder: (context, snapshot) {
                      final username =
                          snapshot.connectionState == ConnectionState.done
                              ? snapshot.data ?? "Anonymous"
                              : "Loading...";
                      final initials =
                          username.isNotEmpty
                              ? username
                                  .trim()
                                  .split(' ')
                                  .map((e) => e[0])
                                  .take(2)
                                  .join()
                                  .toUpperCase()
                              : "?";
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 3,
                        shadowColor: Colors.teal.withOpacity(0.08),
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.teal.shade100,
                                child: Text(
                                  initials,
                                  style: TextStyle(
                                    color: Colors.teal.shade800,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                radius: 22,
                              ),
                              SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          username,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.teal.shade900,
                                          ),
                                        ),
                                        Spacer(),
                                        Row(
                                          children: List.generate(
                                            5,
                                            (starIndex) => Icon(
                                              Icons.star_rounded,
                                              color:
                                                  starIndex <
                                                          (comment['rating'] ??
                                                                  0)
                                                              .toInt()
                                                      ? Colors.amber
                                                      : Colors.grey.shade300,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      (comment['comment'] ?? "").toString(),
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 14,
                                          color: Colors.grey.shade400,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          "Created: ${_formatDate((comment['created_at'] ?? "").toString())}",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
