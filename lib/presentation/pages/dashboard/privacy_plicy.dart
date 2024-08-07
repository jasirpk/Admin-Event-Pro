import 'package:admineventpro/common/style.dart';
import 'package:admineventpro/presentation/components/privacy_policy/bullets.dart';
import 'package:admineventpro/presentation/components/privacy_policy/rich_text.dart';
import 'package:admineventpro/presentation/components/ui/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPlicy extends StatelessWidget {
  const PrivacyPlicy({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: CustomAppBarWithDivider(title: 'Privacy Policy'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Last updated: July 31,2024',
                    style: myTextStyle(screenHeight * 0.018, myColor)),
                SizedBox(height: 10),
                Text(
                    "This Privacy Policy describes Our policies and procedures on the collection, use and disclosure of Your information when You use the Service and tells You about Your privacy rights and how the law protects You."),
                SizedBox(height: 10),
                Text(
                    "We use Your Personal data to provide and improve the Service. By using the Service, You agree to the collection and use of information in accordance with this Privacy Policy. This Privacy Policy has been created with the help of the Privacy Policy Generator."),
                SizedBox(height: 10),
                Text('Interpretation and Definition',
                    style: myTextStyle(screenHeight * 0.022, myColor)),
                sizedbox,
                Text('Interpretation',
                    style: myTextStyle(screenHeight * 0.018, myColor)),
                SizedBox(height: 10),
                Text(
                    'The words of which the initial letter is capitalized have meanings defined under the following conditions. The following definitions shall have the same meaning regardless of whether they appear in singular or in plural.'),
                SizedBox(height: 10),
                Text('Definitions',
                    style: myTextStyle(screenHeight * 0.018, myColor)),
                SizedBox(height: 10),
                Text('For the purposes of this Privacy Policy:'),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichTextWidget(
                        screenHeight: screenHeight,
                        headline: 'Account',
                        text:
                            'means a unique account created for You to access our Service or parts of our Service.',
                      ),
                      SizedBox(height: 10),
                      RichTextWidget(
                        screenHeight: screenHeight,
                        headline: 'Country ',
                        text: 'refers to: Kerala, India',
                      ),
                      SizedBox(height: 10),
                      RichTextWidget(
                        screenHeight: screenHeight,
                        headline: 'Affiliate',
                        text:
                            'means an entity that controls, is controlled by or is under common control with a party, where "control" means ownership of 50% or more of the shares, equity interest or other securities entitled to vote for election of directors or other managing authority.',
                      ),
                      SizedBox(height: 10),
                      RichTextWidget(
                          screenHeight: screenHeight,
                          headline: 'Application ',
                          text:
                              'refers to Admin Event pro, the software program provided by the Company.'),
                      SizedBox(height: 10),
                      RichTextWidget(
                          screenHeight: screenHeight,
                          headline: 'Company ',
                          text:
                              '(referred to as either "the Company", "We", "Us" or "Our" in this Agreement) refers to Admin Event pro.'),
                      SizedBox(height: 10),
                      RichTextWidget(
                        screenHeight: screenHeight,
                        headline: 'Device ',
                        text:
                            'means any device that can access the Service such as a computer, a cellphone or a digital tablet.',
                      ),
                      SizedBox(height: 10),
                      RichTextWidget(
                        screenHeight: screenHeight,
                        headline: 'Personal Data',
                        text:
                            'is any information that relates to an identified or identifiable individual.',
                      ),
                      SizedBox(height: 10),
                      RichTextWidget(
                        screenHeight: screenHeight,
                        headline: 'Service ',
                        text: ' refers to the Application.',
                      ),
                      SizedBox(height: 10),
                      RichTextWidget(
                        screenHeight: screenHeight,
                        headline: 'Affiliate',
                        text:
                            'means an entity that controls, is controlled by or is under common control with a party, where "control" means ownership of 50% or more of the shares, equity interest or other securities entitled to vote for election of directors or other managing authority.',
                      ),
                      SizedBox(height: 10),
                      RichTextWidget(
                        screenHeight: screenHeight,
                        headline: 'Service Provider',
                        text:
                            'means any natural or legal person who processes the data on behalf of the Company. It refers to third-party companies or individuals employed by the Company to facilitate the Service, to provide the Service on behalf of the Company, to perform services related to the Service or to assist the Company in analyzing how the Service is used.',
                      ),
                      SizedBox(height: 10),
                      RichTextWidget(
                        screenHeight: screenHeight,
                        headline: 'Third-party Social Media Service',
                        text:
                            'refers to any website or any social network website through which a User can log in or create an account to use the Service.',
                      ),
                      SizedBox(height: 10),
                      RichTextWidget(
                        screenHeight: screenHeight,
                        headline: 'Usage Data',
                        text:
                            'refers to data collected automatically, either generated by the use of the Service or from the Service infrastructure itself (for example, the duration of a page visit).',
                      ),
                      SizedBox(height: 10),
                      RichTextWidget(
                        screenHeight: screenHeight,
                        headline: 'You',
                        text:
                            'means the individual accessing or using the Service, or the company, or other legal entity on behalf of which such individual is accessing or using the Service, as applicable.',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Text('Collecting and Using Your Personal Data',
                    style: myTextStyle(screenHeight * 0.022, myColor)),
                SizedBox(height: 10),
                Text('Types of Data Collected',
                    style: myTextStyle(screenHeight * 0.022, myColor)),
                SizedBox(height: 10),
                Text('Personal Data',
                    style: myTextStyle(screenHeight * 0.018, myColor)),
                SizedBox(height: 10),
                Text(
                    'While using Our Service, We may ask You to provide Us with certain personally identifiable information that can be used to contact or identify You. Personally identifiable information may include, but is not limited to:'),
                SizedBox(height: 10),
                privacyBullets(screenHeight: screenHeight),
                SizedBox(height: 10),
                Text('Usage Data',
                    style: myTextStyle(screenHeight * 0.018, myColor)),
                SizedBox(height: 10),
                Text(
                    'Usage Data is collected automatically when using the Service.'),
                SizedBox(height: 10),
                Text(
                    '''Usage Data may include information such as Your Device's Internet Protocol address (e.g. IP address), browser type, browser version, the pages of our Service that You visit, the time and date of Your visit, the time spent on those pages, unique device identifiers and other diagnostic data.'''),
                SizedBox(height: 10),
                Text(
                    '''When You access the Service by or through a mobile device, We may collect certain information automatically, including, but not limited to, the type of mobile device You use, Your mobile device unique ID, the IP address of Your mobile device, Your mobile operating system, the type of mobile Internet browser You use, unique device identifiers and other diagnostic data.'''),
                SizedBox(height: 10),
                Text(
                    'We may also collect information that Your browser sends whenever You visit our Service or when You access the Service by or through a mobile device.'),
                SizedBox(height: 10),
                Text('Information from Third-Party Social Media Services',
                    style: myTextStyle(screenHeight * 0.018, myColor)),
                SizedBox(height: 20),
                Text(
                    'The Company allows You to create an account and log in to use the Service through the following Third-party Social Media Services:'),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichTextWidget(
                          screenHeight: screenHeight, headline: 'Google'),
                      SizedBox(height: 10),
                      RichTextWidget(
                          screenHeight: screenHeight, headline: 'Facebook'),
                      SizedBox(height: 10),
                      RichTextWidget(
                          screenHeight: screenHeight, headline: 'Instagram'),
                      SizedBox(height: 10),
                      RichTextWidget(
                          screenHeight: screenHeight, headline: 'Twitter'),
                      SizedBox(height: 10),
                      RichTextWidget(
                          screenHeight: screenHeight, headline: 'LinkedIn'),
                    ],
                  ),
                ),
                Text(
                    '''If You decide to register through or otherwise grant us access to a Third-Party Social Media Service, We may collect Personal data that is already associated with Your Third-Party Social Media Service's account, such as Your name, Your email address, Your activities or Your contact list associated with that account.'''),
                SizedBox(height: 10),
                Text(
                    '''You may also have the option of sharing additional information with the Company through Your Third-Party Social Media Service's account. If You choose to provide such information and Personal Data, during registration or otherwise, You are giving the Company permission to use, share, and store it in a manner consistent with this Privacy Policy.'''),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    // ignore: deprecated_member_use
                    launch(
                        'https://www.termsfeed.com/live/46514c80-92de-4865-9c6b-bfa8a201122a');
                  },
                  child: Text(
                    'More about Privacy Policy, Check the link..',
                    style: TextStyle(
                        fontSize: screenHeight * 0.024,
                        letterSpacing: 1,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.blue),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
