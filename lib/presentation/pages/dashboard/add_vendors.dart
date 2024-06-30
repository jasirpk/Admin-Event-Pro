import 'package:admineventpro/common/assigns.dart';
import 'package:admineventpro/common/style.dart';
import 'package:admineventpro/data_layer/generated/generated_bloc.dart';
import 'package:admineventpro/presentation/components/ui/component_detail.dart';
import 'package:admineventpro/presentation/components/ui/custom_appbar.dart';
import 'package:admineventpro/presentation/components/ui/custom_text_and_icon.dart';
import 'package:admineventpro/presentation/components/ui/custom_text_with_icons.dart';
import 'package:admineventpro/presentation/components/ui/custom_timeline.dart';
import 'package:admineventpro/presentation/components/ui/pushable_button.dart';
import 'package:admineventpro/presentation/components/ui/vendor_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddVendorsScreen extends StatelessWidget {
  const AddVendorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    TextEditingController nameEditingController = TextEditingController();
    List<Map<String, String>> names = [
      {'name': Assigns.dressCode},
      {'name': Assigns.styleAndTheme},
      {'name': Assigns.photography},
      {'name': Assigns.decoration},
      {'name': Assigns.djAndBands},
      {'name': Assigns.music},
      {'name': Assigns.catering},
      {'name': Assigns.venues},
    ];

    return Scaffold(
      appBar: CustomAppBarWithDivider(
        title: Assigns.vendorPreview,
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 18, horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Assigns.textPreview,
                style: TextStyle(
                  fontSize: screenHeight * 0.018,
                  fontWeight: FontWeight.w300,
                ),
              ),
              SizedBox(height: 8),
              Text(
                Assigns.vendorNames,
                style: TextStyle(
                  color: myColor,
                  fontFamily: 'JacquesFracois',
                  fontSize: screenHeight * 0.020,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1,
                ),
              ),
              Card(
                color: Colors.white24,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: Column(
                    children: [
                      VendorNmesWidget(
                          names: names,
                          nameEditingController: nameEditingController,
                          screenWidth: screenWidth,
                          screenHeight: screenHeight),
                      sizedbox,
                      TextFormField(
                        controller: nameEditingController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white54, width: 2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          labelText: 'Displayed Name',
                          labelStyle: TextStyle(
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              sizedbox,
              CustomTextWithIconsWidget(
                screenHeight: screenHeight,
                text: Assigns.essentialComponent,
                onAddpressed: () {
                  context.read<GeneratedBloc>().add(IncreamentEvent());
                },
                onRemovePressed: () {
                  context.read<GeneratedBloc>().add(DecrementEvent());
                },
              ),
              ComponentDetailWidget(
                  screenHeight: screenHeight, screenWidth: screenWidth),
              Text(
                Assigns.moreDetails,
                style: TextStyle(
                  color: myColor,
                  fontFamily: 'JacquesFracois',
                  fontSize: screenHeight * 0.020,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
                height: screenHeight * 0.2,
                child: Center(
                  child: Icon(
                    Icons.collections_bookmark,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'About',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                maxLines: 4,
              ),
              SizedBox(height: 10),
              CustomTextAndIconWidget(
                text: Assigns.location,
                icon: Icons.location_on,
                screenHeight: screenHeight,
              ),
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
                height: screenHeight * 0.2,
                child: Center(
                  child: Icon(
                    Icons.collections_bookmark,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              sizedbox,
              CustomTextWithIconsWidget(
                  screenHeight: screenHeight,
                  text: Assigns.timeline,
                  onAddpressed: () {
                    context.read<GeneratedBloc>().add(AddMoreTimeLineEvent());
                  },
                  onRemovePressed: () {
                    context.read<GeneratedBloc>().add(ReduceTimeLineField());
                  }),
              BlocBuilder<GeneratedBloc, GeneratedState>(
                builder: (context, state) {
                  int itemCount = 0;
                  if (state is GeneratedInitial) {
                    itemCount = state.timeLineCount;
                  }
                  return Card(
                    color: Colors.white38,
                    child: Container(
                      height: screenHeight * 0.2,
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: itemCount,
                        itemBuilder: (context, index) {
                          return customTimeLineWidget(screenWidth: screenWidth);
                        },
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 10),
              Text(
                Assigns.budget,
                style: TextStyle(
                  color: myColor,
                  fontFamily: 'JacquesFracois',
                  fontSize: screenHeight * 0.020,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(height: 10),
              Card(
                color: Colors.grey,
                child: Container(
                  height: screenHeight * 0.2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    fontWeight: FontWeight.w200,
                                    letterSpacing: 1),
                              ),
                              SizedBox(height: 10),
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
                                    borderSide: BorderSide(
                                        color: Colors.white54, width: 2),
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'To:',
                                style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    letterSpacing: 1),
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
                                    borderSide: BorderSide(
                                        color: Colors.white54, width: 2),
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
                  ),
                ),
              ),
              SizedBox(height: 10),
              PushableButton_widget(buttonText: 'Submit', onpressed: () {})
            ],
          ),
        ),
      ),
    );
  }
}
