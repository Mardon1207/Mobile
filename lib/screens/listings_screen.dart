import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard functionality
import 'package:rentapp/screens/api_service.dart';
import 'package:rentapp/screens/comments_screen.dart';
import 'package:rentapp/screens/add_comment_screen.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import for SharedPreferences

class ListingsScreen extends StatefulWidget {
  final List<dynamic> myRentals; // Accept shared rentals list
  final bool showAppBar; // Control AppBar visibility

  ListingsScreen({required this.myRentals, this.showAppBar = true});

  @override
  _ListingsScreenState createState() => _ListingsScreenState();
}

class _ListingsScreenState extends State<ListingsScreen> {
  List<dynamic> listings = [];
  List<String> _categories = ["Barcha bo'limlar"];
  List<String> _categoryIds = [];
  Map<String, String> _categoryNamesById = {};
  bool _isLoading = true;
  String _selectedCategory = "Barcha bo'limlar";
  String _searchQuery = "";
  String? _userType; // Add user type

  @override
  void initState() {
    super.initState();
    fetchListings();
    fetchCategories();
    fetchUserType(); // Fetch user type
  }

  Future<void> fetchListings() async {
    try {
      var data = await ApiService.fetchListings();
      setState(() {
        listings = data;
        _isLoading = false;
      });
    } catch (e) {
      print("Xatolik: $e");
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("E’lonlarni yuklashda xatolik yuz berdi!")),
      );
    }
  }

  Future<void> fetchCategories() async {
    try {
      List<String> names = await ApiService.fetchCategories();
      List<String> ids = await ApiService.fetchCategoriesId();
      _categoryNamesById.clear();
      List<String> categoryNames = ["Barcha bo'limlar"];
      for (int i = 0; i < ids.length; i++) {
        _categoryNamesById[ids[i]] = names[i];
        categoryNames.add(names[i]);
      }
      setState(() {
        _categories = categoryNames;
        _categoryIds = ids;
        if (!_categories.contains(_selectedCategory)) {
          _selectedCategory = "Barcha bo'limlar";
        }
      });
    } catch (e) {
      print("Kategoriyalarni yuklashda xatolik: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Kategoriyalarni yuklashda xatolik yuz berdi!")),
      );
    }
  }

  Future<void> fetchUserType() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _userType = prefs.getString('user_type') ?? "unknown"; // Fetch user type
    } catch (e) {
      print("User type fetch error: $e");
      _userType = "unknown"; // Default to unknown if fetch fails
    }
    setState(() {}); // Update UI after fetching user type
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          widget.showAppBar
              ? AppBar(
                backgroundColor: Colors.teal,
                elevation: 0,
                title: Text(
                  "E’lonlar",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              )
              : null, // Hide AppBar if showAppBar is false
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade50, Colors.teal.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Material(
                      elevation: 2,
                      borderRadius: BorderRadius.circular(12),
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: "Qidiruv",
                          labelStyle: TextStyle(color: Colors.teal.shade700),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(Icons.search, color: Colors.teal),
                          filled: true,
                          fillColor: Colors.white,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.teal,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 16,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal.shade100,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        dropdownColor: Colors.white,
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.teal,
                        ),
                        style: TextStyle(
                          color: Colors.teal.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                        items:
                            _categories
                                .map(
                                  (category) => DropdownMenuItem<String>(
                                    value: category,
                                    child: Text(category),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: fetchListings, // Pull-to-refresh functionality
                child:
                    _isLoading
                        ? Center(
                          child: CircularProgressIndicator(
                            color: Colors.teal,
                            strokeWidth: 4,
                          ),
                        )
                        : listings.isEmpty
                        ? Center(
                          child: Text(
                            "E’lonlar mavjud emas.",
                            style: TextStyle(
                              color: Colors.teal.shade700,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                        : ListView.builder(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          itemCount: listings.length,
                          itemBuilder: (context, index) {
                            try {
                              var listing = listings[index];
                              final categoryId =
                                  listing['category']?.toString();
                              final categoryName =
                                  _categoryNamesById[categoryId] ??
                                  categoryId ??
                                  '';
                              if (_selectedCategory != "Barcha bo'limlar" &&
                                  categoryName != _selectedCategory) {
                                return SizedBox.shrink();
                              }
                              if (_searchQuery.isNotEmpty &&
                                  !(categoryName.toLowerCase().contains(
                                    _searchQuery.toLowerCase(),
                                  )) &&
                                  !(listing['title']
                                          ?.toString()
                                          .toLowerCase()
                                          .contains(
                                            _searchQuery.toLowerCase(),
                                          ) ??
                                      false) &&
                                  !(listing['description']
                                          ?.toString()
                                          .toLowerCase()
                                          .contains(
                                            _searchQuery.toLowerCase(),
                                          ) ??
                                      false)) {
                                return SizedBox.shrink();
                              }
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => ListingDetailsScreen(
                                            listing: listing,
                                            categoryName: categoryName,
                                          ),
                                    ),
                                  );
                                },
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 200),
                                  margin: EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.teal.withOpacity(0.08),
                                        blurRadius: 12,
                                        offset: Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(18),
                                        ),
                                        child:
                                            listing['image'] != null &&
                                                    listing['image']
                                                        .toString()
                                                        .isNotEmpty
                                                ? FadeInImage.assetNetwork(
                                                  placeholder:
                                                      'assets/placeholder.png',
                                                  image:
                                                      listing['image']
                                                          .toString(),
                                                  width: double.infinity,
                                                  height: 200,
                                                  fit: BoxFit.cover,
                                                  imageErrorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) => Container(
                                                        color:
                                                            Colors
                                                                .grey
                                                                .shade200,
                                                        height: 200,
                                                        child: Icon(
                                                          Icons.broken_image,
                                                          color: Colors.red,
                                                          size: 60,
                                                        ),
                                                      ),
                                                )
                                                : Container(
                                                  color: Colors.grey.shade200,
                                                  height: 200,
                                                  width: double.infinity,
                                                  child: Icon(
                                                    Icons.image_not_supported,
                                                    color: Colors.grey,
                                                    size: 60,
                                                  ),
                                                ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    listing['title'] ??
                                                        "No title available",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20,
                                                      color:
                                                          Colors.teal.shade800,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.teal.shade50,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    categoryName,
                                                    style: TextStyle(
                                                      color:
                                                          Colors.teal.shade700,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 10),
                                            Text(
                                              (listing['price']?.toString() ??
                                                      "0") +
                                                  " so‘m",
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.teal.shade700,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              listing['description'] ??
                                                  "No description available",
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.black87,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 14),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.star_rounded,
                                                  color: Colors.amber,
                                                  size: 22,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  (() {
                                                    final rating =
                                                        listing['averageRating'];
                                                    if (rating == null)
                                                      return "0.0";
                                                    if (rating is double)
                                                      return rating
                                                          .toStringAsFixed(1);
                                                    if (rating is int)
                                                      return rating
                                                          .toDouble()
                                                          .toStringAsFixed(1);
                                                    if (rating is String) {
                                                      final parsed =
                                                          double.tryParse(
                                                            rating,
                                                          );
                                                      return parsed
                                                              ?.toStringAsFixed(
                                                                1,
                                                              ) ??
                                                          "0.0";
                                                    }
                                                    return "0.0";
                                                  })(),
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.teal.shade700,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                SizedBox(width: 6),
                                                Text(
                                                  (() {
                                                    final count =
                                                        listing['reviewCount'];
                                                    if (count == null)
                                                      return "(0 ta sharh)";
                                                    if (count is int)
                                                      return "(${count} ta sharh)";
                                                    if (count is String) {
                                                      final parsed =
                                                          int.tryParse(count);
                                                      return "(${parsed ?? 0} ta sharh)";
                                                    }
                                                    return "(0 ta sharh)";
                                                  })(),
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 14),
                                            if (_userType == "renter")
                                              ElevatedButton(
                                                onPressed: () {
                                                  setState(() {
                                                    widget.myRentals.add(
                                                      listing,
                                                    ); // Add to shared list
                                                  });
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        "Ijaralarimga qo'shildi!",
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Text(
                                                  "Ijaralarimga qo'shish",
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.teal,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } catch (e, stack) {
                              print("Listing rendering error: $e");
                              print("Stacktrace: $stack");
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Kategoriya yoki listingda xatolik: ${e.toString()}",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              });
                              return SizedBox.shrink();
                            }
                          },
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ListingDetailsScreen extends StatelessWidget {
  final dynamic listing;
  final String? categoryName;

  ListingDetailsScreen({required this.listing, this.categoryName});

  void _sendMessage(BuildContext context) {
    TextEditingController messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Xabar yuborish"),
          content: TextField(
            controller: messageController,
            decoration: InputDecoration(
              labelText: "Xabar matni",
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Bekor qilish"),
            ),
            ElevatedButton(
              onPressed: () {
                String message = messageController.text.trim();
                if (message.isNotEmpty) {
                  // Xabarni yuborish funksiyasi
                  print("Xabar yuborildi: $message");
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Xabar yuborildi!")));
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Xabar matni bo'sh bo'lmasligi kerak!"),
                    ),
                  );
                }
              },
              child: Text("Yuborish"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print("Rasm URL: ${listing['image']}");

    return Scaffold(
      appBar: AppBar(
        title: Text(listing['title'] ?? "Tafsilotlar"),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade50, Colors.teal.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (listing['image'] != null &&
                  listing['image'].toString().isNotEmpty)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: FadeInImage.assetNetwork(
                      placeholder: 'assets/placeholder.png',
                      image: listing['image'].toString(),
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      imageErrorBuilder: (context, error, stackTrace) {
                        print("Failed to load image: $error");
                        return Container(
                          color: Colors.grey.shade200,
                          height: 220,
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.red,
                            size: 60,
                          ),
                        );
                      },
                    ),
                  ),
                )
              else
                Center(
                  child: Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                      size: 60,
                    ),
                  ),
                ),
              SizedBox(height: 20),
              Text(
                listing['title'] ?? "No title available",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade800,
                ),
              ),
              SizedBox(height: 10),
              if (categoryName != null && categoryName!.isNotEmpty)
                Text(
                  "Kategoriya: $categoryName",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.teal.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              SizedBox(height: 10),
              Text(
                (listing['price']?.toString() ?? "0") + " so‘m",
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.teal.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 18),
              Text(
                listing['description'] ?? "No description available",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 22),
              Row(
                children: [
                  Icon(Icons.star_rounded, color: Colors.amber, size: 24),
                  SizedBox(width: 6),
                  Text(
                    (listing['averageRating']?.toStringAsFixed(1) ?? "0.0"),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.teal.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "(${listing['reviewCount'] ?? 0} ta sharh)",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              SizedBox(height: 28),
              Text(
                "Bog'lanish ma'lumotlari",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade800,
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.phone, color: Colors.teal, size: 28),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            listing['creatorPhone'] ?? "+998915551207",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.teal.shade800,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.copy, color: Colors.teal),
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(
                                text:
                                    listing['creatorPhone'] ?? "+998915551207",
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Telefon raqam nusxalandi!"),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        _sendMessage(context);
                      },
                      icon: Icon(Icons.send, color: Colors.white),
                      label: Text("Xabar yuborish"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        elevation: 2,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => AddCommentScreen(
                                listingId: listing['id'], // Pass listing ID
                              ),
                        ),
                      );
                    },
                    icon: Icon(Icons.add_comment, color: Colors.white),
                    label: Text("Sharh yozish"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      elevation: 2,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => CommentsScreen(
                                listingId: listing['id'], // Pass listing ID
                              ),
                        ),
                      );
                    },
                    icon: Icon(Icons.comment, color: Colors.white),
                    label: Text("Sharhlarni ko'rish"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade700,
                      padding: EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      elevation: 2,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
