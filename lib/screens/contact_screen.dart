import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';


class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final String phoneNumber = "+2349164101356";
  final String email = "excellentserviceproviders1@gmail.com";

  Future<void> _makePhoneCall() async {
    final Uri callUri = Uri.parse("tel:$phoneNumber");
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      throw "Could not launch $callUri";
    }
  }

  Future<void> _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: Uri.encodeFull("subject=Hello&body=Hi, I wanted to reach out..."),
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw "Could not launch $emailUri";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              const Text('You can get in touch with us through below platforms. '
                  'Our team will reach out to you as soon as it is possible.',
                style: TextStyle(fontWeight: FontWeight.bold),),
              const SizedBox(height: 30.0,),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(color: Colors.green, onPressed: _makePhoneCall, icon: Icon(Icons.call, size: 50,),),
                          Column(
                            children:[ const Text(
                              'Contact Number', style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                            ),
                              const Text(
                                '+(234) 9164101356', style: TextStyle(
                                fontSize: 16.0,
                              ),
                              )
                            ]
                          ),
                          const SizedBox(width: 10.0,),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(color: Colors.green, onPressed: _sendEmail, icon: Icon(Icons.email, size: 50),),
                          Column(
                            children:[
                              const Text(
                              'Email Address', style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                            ),
                              const Text(
                                'esspo@gmail.com', style: TextStyle(
                                fontSize: 16.0,
                              ),
                              )
                            ]
                          )
                        ],
                      )
                      ]
                                ),
                )
              ),
              SizedBox(height: 30,),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                    const Text('Social Media', style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),),
                      SizedBox(height: 10,),
                      Row(
                        children: [
                          const FaIcon(FontAwesomeIcons.instagram, size: 50,),
                          SizedBox(width: 10,),
                          const Text(
                              'Instagram', style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                          ),
                          ]
                            ),
                      SizedBox(height: 10,),
                      Row(
                          children: [
                            const FaIcon(FontAwesomeIcons.facebook, size: 50,),
                            SizedBox(width: 10,),
                            const Text(
                                'Facebook', style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                            ),
                          ]
                      ),
                      SizedBox(height: 10,),
                      Row(
                          children: [
                            const FaIcon(FontAwesomeIcons.twitter, size: 50,),
                            SizedBox(width: 10,),
                            const Text(
                                'X', style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                            ),
                          ]
                      ),
                      ]
                          ),
                ),
      ),
    ]
    )
    )
      )
    );

  }
}
