import 'package:flutter/material.dart';

class customTimeLineWidget extends StatelessWidget {
  const customTimeLineWidget({
    required this.screenWidth,
  });

  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          width: screenWidth * 0.4,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'From:',
                  style:
                      TextStyle(fontWeight: FontWeight.w200, letterSpacing: 1),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white54, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelText: '00:00',
                    prefixIcon: IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.alarm,
                          size: 20,
                          color: Colors.white,
                        )),
                    labelStyle: TextStyle(
                      color: Colors.white54,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          width: screenWidth * 0.4,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'To:',
                  style:
                      TextStyle(fontWeight: FontWeight.w300, letterSpacing: 1),
                ),
                SizedBox(height: 10),
                TextFormField(
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white54, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelText: '00:00',
                    prefixIcon: IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.alarm,
                          size: 20,
                          color: Colors.white,
                        )),
                    labelStyle: TextStyle(
                      color: Colors.white54,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
