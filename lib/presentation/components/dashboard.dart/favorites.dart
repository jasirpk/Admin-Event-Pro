import 'package:admineventpro/data_layer/services/sub_category.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:developer';

class FavoritePage extends StatefulWidget {
  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final subDbMethods =
      subDatabaseMethods(); // Assuming this is your database methods class
  late StreamController<List<DocumentSnapshot>> _favoritesController;
  late StreamSubscription _favoritesSubscription;

  @override
  void initState() {
    super.initState();
    _favoritesController = StreamController<List<DocumentSnapshot>>();
    _fetchFavorites();
  }

  @override
  void dispose() {
    _favoritesController.close();
    _favoritesSubscription.cancel();
    super.dispose();
  }

  final user = FirebaseAuth.instance.currentUser;
  void _fetchFavorites() {
    if (user != null) {
      String uid = user!.uid;
      _favoritesSubscription =
          subDbMethods.getFavoriteSubcategories(uid).listen((favorites) {
        _favoritesController.add(favorites);
      }, onError: (error) {
        log('Error fetching favorites: $error');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
      ),
      body: StreamBuilder<List<DocumentSnapshot>>(
        stream: _favoritesController.stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No favorites found.'));
          }
          List<DocumentSnapshot> favoriteSubcategories = snapshot.data!;
          return ListView.builder(
            itemCount: favoriteSubcategories.length,
            itemBuilder: (context, index) {
              DocumentSnapshot subcategory = favoriteSubcategories[index];
              // Check if the document has data and if it exists
              if (subcategory.data() != null && subcategory.exists) {
                // Get all fields dynamically
                Map<String, dynamic> data =
                    subcategory.data() as Map<String, dynamic>;

                // Example: Accessing fields dynamically
                String subCategoryName = data['subCategoryName'] ?? 'No Name';
                String about = data['about'] ?? 'No Description';

                // Add more fields as needed
                // Ensure to check for each field's existence before accessing
                return ListTile(
                  title: Text(subCategoryName),
                  subtitle: Text(about),
                  // Add more fields as needed
                );
              } else {
                return ListTile(
                  title: Text(
                    'Document is empty or fields are missing',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
