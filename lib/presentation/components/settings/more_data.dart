import 'package:admineventpro/common/style.dart';
import 'package:flutter/material.dart';

class MoreDataWidget extends StatelessWidget {
  const MoreDataWidget({
    super.key,
    required this.screenHeight,
    required this.website,
    required this.companyName,
    required this.links,
    required this.description,
  });

  final double screenHeight;
  final String website;
  final String companyName;
  final List links;
  final String description;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.only(left: 6, right: 260),
      leading: Icon(
        Icons.add,
        color: Colors.white,
      ),
      title: Text(
        'More',
        style: TextStyle(color: Colors.white, fontSize: screenHeight * 0.014),
      ),
      backgroundColor: Colors.black,
      children: <Widget>[
        ListTile(
          title: Row(
            children: [
              Icon(
                Icons.link,
                color: Colors.white,
              ),
              sizedboxWidth,
              Flexible(
                child: Text(
                  'Website: $website',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        ListTile(
          title: Row(
            children: [
              Icon(
                Icons.business,
                color: Colors.white,
              ),
              sizedboxWidth,
              Text(
                'Company: $companyName',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Text('Social Media Links:', style: TextStyle(color: Colors.white)),
          ],
        ),
        Container(
          height: 160,
          child: ListView.builder(
              itemCount: links.length,
              itemBuilder: (context, index) {
                var link = links[index];
                return Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Card(
                    child: ListTile(
                      leading: Icon(
                        Icons.link,
                      ),
                      title: Text(
                        link['link'] ?? '',
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: screenHeight * 0.014,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.blue),
                      ),
                    ),
                  ),
                );
              }),
        ),
        ListTile(
          title: Row(
            children: [
              Icon(
                Icons.info,
                color: Colors.white,
              ),
              sizedboxWidth,
              Flexible(
                child: Text(
                  'Additional Info: $description',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
