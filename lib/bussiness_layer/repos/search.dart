import 'package:admineventpro/data_layer/services/sub_category.dart';
import 'package:admineventpro/presentation/pages/dashboard/add_vendors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admineventpro/presentation/components/media/media_image.dart';
import 'package:flutter/material.dart';

class DataSearch extends SearchDelegate<String> {
  final subDatabaseMethods databaseMethods = subDatabaseMethods();
  final String categoryId;

  DataSearch(
      {super.searchFieldLabel,
      super.searchFieldStyle,
      super.searchFieldDecorationTheme,
      super.keyboardType,
      super.textInputAction,
      required this.categoryId});
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // Leading icon on the left of the search bar
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: databaseMethods.searchSubcategories(categoryId, query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No results found for "$query"',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        var documents = snapshot.data!.docs;
        return ListView.builder(
          itemCount: documents.length,
          itemBuilder: (context, index) {
            var document = documents[index];
            var data = document.data() as Map<String, dynamic>;
            String imagePath = data['imagePath'];
            String subCategoryId = document.id;
            return Card(
              color: Colors.black,
              child: Container(
                child: ListTile(
                  // A sub-category's imagePath is an R2 object key since the
                  // catalogue migration. `startsWith('http')` sent that down
                  // the AssetImage branch, asking Flutter for a bundled asset
                  // named "subcategory_images/...", which throws. MediaImage
                  // signs the key through the media API instead, and shows the
                  // placeholder rather than throwing when it cannot.
                  leading: MediaImage(
                    imagePath: imagePath,
                    placeholder: kMediaPlaceholderImage,
                    builder: (context, image) => Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                          image: image == null
                              ? null
                              : DecorationImage(
                                  image: image, fit: BoxFit.cover)),
                    ),
                  ),
                  title: Text(
                    data['subCategoryName'],
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    data['about'],
                    style: TextStyle(fontSize: 14.0, color: Colors.white),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddVendorsScreen(
                          categoryId: categoryId,
                          subCategoryId: subCategoryId,
                          categoryName: data['subCategoryName'],
                          categoryDescription: data['about'],
                          imagePath: data['imagePath'],
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Suggestions that appear while typing in the search bar
    return Center(
      child: Text(
        'Searching...',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
