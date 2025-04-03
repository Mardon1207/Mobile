import 'package:flutter/material.dart';
import 'package:rentapp/screens/api_service.dart';

class ListingsScreen extends StatefulWidget {
  @override
  _ListingsScreenState createState() => _ListingsScreenState();
}

class _ListingsScreenState extends State<ListingsScreen> {
  List<dynamic> listings = [];

  @override
  void initState() {
    super.initState();
    fetchListings();
  }

  Future<void> fetchListings() async {
    var data = await ApiService.fetchListings();
    setState(() {
      listings = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: listings.length,
      itemBuilder: (context, index) {
        var listing = listings[index];
        return Card(
          child: ListTile(
            title: Text(listing['title']),
            subtitle: Text(listing['price'].toString() + " so‘m"),
            leading: Image.network(listing['image_url'], width: 50, height: 50, fit: BoxFit.cover),
          ),
        );
      },
    );
  }
}
