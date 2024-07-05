import 'package:flutter/material.dart';

class Budget_widget extends StatelessWidget {
  const Budget_widget({
    super.key,
    required this.screenHeight,
    required this.screenWidth,
    required this.FromBudgetController,
    required this.ToBudgetController,
  });

  final double screenHeight;
  final double screenWidth;
  final TextEditingController FromBudgetController;
  final TextEditingController ToBudgetController;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white38,
      child: Container(
        height: screenHeight * (140 / screenHeight),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: screenWidth * 0.4,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'From:',
                      style: TextStyle(
                          fontWeight: FontWeight.w200, letterSpacing: 1),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: FromBudgetController,
                      keyboardType: TextInputType.datetime,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelText: '₹',
                        prefixIcon: IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.currency_rupee,
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'To:',
                      style: TextStyle(
                          fontWeight: FontWeight.w300, letterSpacing: 1),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: ToBudgetController,
                      keyboardType: TextInputType.datetime,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelText: '₹',
                        prefixIcon: IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.currency_rupee,
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
        ),
      ),
    );
  }
}
