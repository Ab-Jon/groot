import 'package:flutter/material.dart';
import 'package:groot/authenticate/sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AgreementScreen extends StatefulWidget {
  @override
  _AgreementScreenState createState() => _AgreementScreenState();
}

class _AgreementScreenState extends State<AgreementScreen> {
  bool _isChecked = false;

  Future<void> saveAgreementAccepted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('agreementAccepted', true);
  }

  void onContinue() async {
    if (_isChecked) {
      await saveAgreementAccepted(); // Save agreement state
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignIn()), // Navigate to login
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please accept the agreement to continue")),
      );
    }
  }


  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      print("Could not launch $url");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User's Terms and Conditions", style: TextStyle(color: Colors.white),),backgroundColor: Colors.green,),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children:[ Text(
                          "G-root App Terms and Conditions\n Version: 1.0 \nEffective Date: 7 February 2025\n\n"
                          "1. Welcome to G-root, a technology extension of Excellent Solution and Strategy Providers Organisation (the “NGO”). G-root is designed to provide solutions to major societal challenges through political advocacy and humanitarian services."
                              "The app enables Principals engaging in political advocacy to monitor their support base growth across all political units, wards, cities, and states while also facilitating aid distribution for verified NGOs and government agencies.\n\n"
                              "Ownership and Management\n"
                              "\nExcellent Solution and Strategy Providers Organisation owns and manages the G-root application."
                              "Iboro Udofia retains full intellectual property rights over the technology behind G-root, including its software, trademarks, and content."
                              "G-root is registered under the NGO’s name in Firebase Storage and the Google Play Store but operates under a non-exclusive, revocable license from Iboro Udofia. "
                              "By using G-root, you agree to these Terms and Conditions and our Data Protection Policy. If you do not agree, please discontinue using the application.\n\n"
                          "2. Definitions\n"
                              "Principal – A political leader, candidate, or representative using G-root for political advocacy.\n"
                              "Follower – A user aligned with a Principal for political engagement.\n"
                              "NGO – Excellent Solution and Strategy Providers Organisation, the entity managing the app.\n"
                              "User – Any individual or organization using G-root.\n"
                              "Third Parties – Verified entities such as government bodies, humanitarian organizations, and political affiliates who may receive data for verification or service delivery\n\n"
                          "3. Services Provided\n\n"
                              "3.1 Political Advocacy & Principal-Follower Alignment\n"
                              "\nG-root is a digital platform developed to address challenges in political advocacy and humanitarian services by:\n"
                              "Enables Principals to track their support base growth across political units, wards, cities, and states."
                              "Provides real-time analytics on follower engagement and alignment.\n"
                              "\n3.2 Humanitarian Aid Distribution\n\n"
                              "Facilitates secure aid distribution for verified NGOs and government agencies."
                              "Stores and shares bank details with verified humanitarian service providers for legitimate aid disbursement.\n"
                              "\n3.3 Data Collection & Verification\n\n"
                              "Ensures identity verification through National Identification Number (NIN), Voter Identification Number (VINN), and other government-issued IDs."
                              "Supports secure data sharing with relevant entities for political and humanitarian purposes.\n\n"

                          "4. User Rights\n\n"
                              "Users of G-root have the following rights regarding their personal data:\n\n"
                              "4.1 Right to Rectification\n\n"
                              "Users can revisit and update inaccurate or incomplete personal data directly from their app dashboard under the Downlines tab for individual users and the Members tab for group users.\n\n"
                              "4.2 Right to Deletion\n\n"
                              "Users can delete their personal data and remove themselves from a Principal’s network directly from their app dashboard under the Downlines tab for individual users and the Members tab for group users.\n"
                              "Exceptions: Certain data may be retained where legally required.\n"
                              "For more details on how data is handled, refer to the Data Protection Policy.\n\n"
                          "5. User Accounts & Responsibilities\n\n"
                              "5.1 Eligibility\n\n"
                              "Be at least 18 years old or have parental/guardian consent.\n"
                              "Be a verified Principal or Follower engaged in political advocacy.\n"
                              "Be a verified entity (NGO or government agency) for humanitarian service access. \n\n"
                              "5.2 Account Security\n\n"
                              "Users must provide accurate, verifiable information upon registration.\n"
                              "Users are responsible for their login credentials.\n"
                              "Any suspicious activity must be reported immediately.\n\n"
                              "5.3 User Responsibilities\n\n"
                              "Users agree to:\n"
                              "Use the platform only for its intended political advocacy and humanitarian purposes.\n"
                              "Not engage in fraud, misinformation, hate speech, or illegal activities.\n"
                              "Not impersonate another person or entity.\n\n"
                          "6. Data Collection and Privacy\n\n"
                              "6.1 Personal Data Collected\n\n"
                              "As detailed in our Data Protection Policy, G-root collects and processes the following data:\n"
                              "Full Name, Profile Picture, Phone Number, and Location – Shared with Principals for political advocacy purposes.\n"
                              "\n6.2 Data Shared with Principals\n\n"
                              "Principals have access to:\n\n"
                              "Full Name, Profile Picture, Phone Number, and Location Data of their aligned followers.\n"
                              "\n6.3 Data Security & Storage\n\n"
                              "Data is stored securely and protected against unauthorized access.\n"
                              "Data collected is not transferred outside the country of collection unless required by law.\n"
                              "For more details, refer to the Data Protection Policy.\n\n"
                          "7. Intellectual Property Rights\n\n"
                              "Iboro Udofia retains full intellectual property rights over the technology behind G-root."
                              "The NGO manages the platform under a non-exclusive, revocable license."
                              "Any unauthorized use of G-root’s technology may result in legal action.\n\n"
                          "8. Prohibited Activities\n\n"
                              "Users must not:\n"
                              "Spread false information, hate speech, or incite violence.\n"
                              "Engage in fraudulent political activities or misuse humanitarian resources.\n"
                              "Disrupt, hack, or interfere with G-root’s security and operations.\n\n"
                          "9. Disclaimer & Limitation of Liability\n\n"
                              "G-root is provided as is, without warranties of any kind.\n"
                              "The NGO is not liable for:\n"
                              "Political outcomes resulting from the use of the app.\n"
                              "Data breaches outside our control.\n"
                              "Financial losses from unauthorized transactions.\n\n"
                          "10. Termination of Services\n\n"
                              "G-root reserves the right to suspend or terminate any account violating these terms.\n"
                              "Users may request account deletion directly from their app dashboard under the Down lines tab for individual users and the Members tab for group users.\n"
                          "\n11. Governing Law & Dispute Resolution\n\n"
                              "These terms shall be governed by the laws of Nigeria.\n"
                              "Disputes shall be resolved through arbitration or appropriate legal channels.\n\n"
                           "12. Changes to These Terms\n"
                              "We may update these Terms periodically.\n"
                              "Continued use of G-root after updates means you accept the revised Terms.\n\n"
                           "13. Contact Information\n"
                              "For inquiries or support, contact us at:\n"
                              "Excellent Solution and Strategy Providers Organisation\n"
                              "Address: No. 28 Idoro Road, Off Itam Junction, Itu LGA, Akwa Ibom State, Nigeria.\n"
                              "Email: excellentsolutionproviders1@gmail.com\n"
                              "Phone: +2349164101356\n",
                    style: TextStyle(fontSize: 16),
                  ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green
                      ),
                      onPressed: () => _launchURL("https://excellentsolutionproviders.org/data-protection"),
                      child: Text("Data Protection Policy", style: TextStyle(color: Colors.white),),
                    ),
        ]
                ),
              ),
            ),
            Row(
              children: [
                Checkbox(
                  checkColor: Colors.green,
                  value: _isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      _isChecked = value ?? false;
                    });
                  },
                ),
                Expanded(child: Text("I agree to the terms and conditions")),
              ],
            ),
            ElevatedButton(
              onPressed: _isChecked ? onContinue : null,
              child: Text("Continue"),
            ),
          ],
        ),
      ),
    );
  }
}

