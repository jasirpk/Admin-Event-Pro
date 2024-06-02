import 'package:admineventpro/common/style.dart';
import 'package:admineventpro/entities/models/carousal_list.dart';
import 'package:admineventpro/presentation/pages/auth/sign_in.dart';
import 'package:admineventpro/presentation/components/pushable_button.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CarousalWelcome extends StatelessWidget {
  final List<Category> Categries = [
    Category(image: 'assets/images/login_background_img.jpg'),
    Category(image: 'assets/images/catering_img.jpg'),
    Category(image: 'assets/images/coktail_category.jpg'),
    Category(image: 'assets/images/outdoor_venue.jpg'),
    Category(image: 'assets/images/venue_decoration_img.jpg'),
    Category(image: 'assets/images/easter_gardengala.jpg'),
    Category(image: 'assets/images/drone_photography.jpg'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints:
              BoxConstraints(minHeight: MediaQuery.of(context).size.height),
          child: Padding(
            padding: EdgeInsets.only(
              top: 60,
              left: 8,
              right: 8,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: CarouselSlider.builder(
                    itemCount: Categries.length,
                    itemBuilder: (context, itemIndex, pageIndex) {
                      final categroy = Categries[itemIndex];
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            categroy.image,
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.high,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      );
                    },
                    options: CarouselOptions(
                        height: 250,
                        aspectRatio: 16 / 9,
                        reverse: false,
                        viewportFraction: 0.55,
                        autoPlayCurve: Curves.fastOutSlowIn,
                        autoPlay: true,
                        autoPlayInterval: Duration(seconds: 3),
                        autoPlayAnimationDuration: Duration(seconds: 1),
                        enlargeCenterPage: true,
                        scrollDirection: Axis.horizontal),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Text(
                        '''Fulfill your Business\nwith Admin Event Pro''',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            fontFamily: 'JacquesFracois'),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        '''Seamlessly manage events, vendors, and analytics for ultimate event success''',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 1),
                      ),
                    ),
                    sizedbox,
                    Padding(
                      padding: const EdgeInsets.only(bottom: 68),
                      child: PushableButton_widget(
                        buttonText: 'Next',
                        onpressed: () {
                          Get.to(() => GoogleAuthScreen());
                        },
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
