import 'package:admineventpro/common/style.dart';
import 'package:flutter/material.dart';

class SilverAppBarWidget extends StatelessWidget {
  const SilverAppBarWidget({
    super.key,
    required this.screenHeight,
  });

  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar.large(
      actions: [
        Transform.rotate(
          angle: 5.5,
          child: IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.send_sharp,
              )),
        ),
        IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.notifications,
            )),
        sizedboxWidth
      ],
      expandedHeight: 150,
      flexibleSpace: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/cover_img_1.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.3), BlendMode.darken))),
        child: Padding(
          padding: EdgeInsets.only(left: 8),
          child: Column(
            children: [
              SizedBox(
                height: 40,
              ),
              Row(
                children: [
                  Text(
                    'Hey! Pk Events',
                    style: TextStyle(
                      fontSize: screenHeight * 0.020,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      fontFamily: 'JacquesFracois',
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'Welcome to Admin Event Pro',
                    style: TextStyle(
                        fontSize: screenHeight * 0.018,
                        fontWeight: FontWeight.w300,
                        fontFamily: 'JacquesFracois'),
                  ),
                ],
              ),
              sizedbox,
              Padding(
                padding: EdgeInsets.only(right: 8),
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: TextFormField(
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        labelText: 'Search Your Category Template',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 20),
                        floatingLabelBehavior: FloatingLabelBehavior.never),
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
