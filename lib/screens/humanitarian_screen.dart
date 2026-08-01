import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_state_city_pro/country_state_city_pro.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multiselect/multiselect.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import '../service/auth_service.dart';
import 'home_screen.dart';

class HumanitarianScreen extends StatefulWidget {
  const HumanitarianScreen({super.key});

  @override
  State<HumanitarianScreen> createState() => _HumanitarianScreenState();
}

class _HumanitarianScreenState extends State<HumanitarianScreen> {

  String? _imagePath;
  String? _uploadedImageUrl;
  bool _isUploading = false;
  String? selectedGender;
  String? selectedDisability;
  String? selectedEmployValue = 'Employed';

  Future<void> _selectImage(BuildContext context) async {
    final ImagePicker _picker = ImagePicker();
    File? imageFile;
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text("Take a Photo"),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
                  if (pickedFile == null) {
                    print("No image selected from Camera");
                    return;
                  }
                  imageFile = File(pickedFile.path);
                  setState(() {
                    _imagePath = imageFile!.path;
                  });
                  final AuthService _signInService = AuthService();
                  String userId = _signInService.getCurrentUserID(); // Replace with actual user ID retrieval logic
                  await _uploadVINImage(imageFile!, userId);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text("Choose from Gallery"),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile == null) {
                    print("No image selected from Gallery");
                    return;
                  }
                  imageFile = File(pickedFile.path);
                  setState(() {
                    _imagePath = imageFile!.path;
                  });
                  final AuthService _signInService = AuthService();
                  String userId = _signInService.getCurrentUserID(); // Replace with actual user ID retrieval logic
                  await _uploadVINImage(imageFile!, userId);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _uploadVINImage(File imageFile, String userId) async {
    if (userId.isEmpty) {
      print("Error: User ID is missing.");
      return;
    }

    try {
      final storageRef = FirebaseStorage.instance.ref().child('user_images/$userId.jpg');
      await storageRef.putFile(imageFile);
      final downloadURL = await storageRef.getDownloadURL();

      setState(() {
        _uploadedImageUrl = downloadURL;
      });

      await FirebaseFirestore.instance.collection('Humanitarian').doc(userId).set({
        'ImageUrl': downloadURL
      }, SetOptions(merge: true));

      print("Image uploaded successfully: $downloadURL");
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  TextEditingController fullNameCont = TextEditingController();
  TextEditingController ageCont = TextEditingController();
  TextEditingController handicapCont = TextEditingController();
  TextEditingController identityCont = TextEditingController();
  TextEditingController villageCont = TextEditingController();
  TextEditingController addressCont = TextEditingController();
  TextEditingController resAddressCont = TextEditingController();
  TextEditingController phoneCont = TextEditingController();
  TextEditingController basicCont = TextEditingController();
  TextEditingController longTermCont = TextEditingController();
  TextEditingController skillCont = TextEditingController();
  TextEditingController otherCont = TextEditingController();
  TextEditingController professionCont = TextEditingController();
  TextEditingController institutionCont = TextEditingController();
  TextEditingController regCont = TextEditingController();
  TextEditingController cgpaCont = TextEditingController();
  TextEditingController courseCont = TextEditingController();
  TextEditingController businessTypeCont = TextEditingController();
  TextEditingController businessNameCont = TextEditingController();
  TextEditingController locationCont = TextEditingController();
  TextEditingController durationCont = TextEditingController();
  TextEditingController challengeCont = TextEditingController();
  TextEditingController statusCont = TextEditingController();
  TextEditingController bankNameCont = TextEditingController();
  TextEditingController accountNameCont = TextEditingController();
  TextEditingController accountNumberCont = TextEditingController();

  final TextEditingController countryCont = TextEditingController();
  final TextEditingController stateCont = TextEditingController();
  final TextEditingController cityCont = TextEditingController();

  List<String> genderOptions = ['Male', 'Female'];
  List<String> statusOptions = ['Employed', 'Unemployed'];
  List<String> challengeOptions = ['Yes', 'No'];
  List<String> humanitarianOptions = ['Basic Need', 'Long-term Need', 'Skill', 'Business', 'Student', 'Profession'];
  List<String> basicOptions = ['Food and Water', 'Shelter', 'Healthcare', 'Safety and Security', 'Counseling', 'Electricity', 'Other'];
  List<String> longTermOptions = ['Road construction', 'Community development', 'Education', 'Rehabilitation of Infrastructure'];
  List<String> defaultOptions = [];
  List<String> selectedCheckBoxValue = [];
  List<String> selectedCheckBoxValue1 = [];
  List<String> selectedCheckBoxValue2 = [];
  List<String> selectedCheckBoxValue3 = [];
  List<String> selectedCheckBoxValue4 = [];
  List<String> selectedCheckBoxValue5 = [];
  Color myColor = const Color(0xff102FCE);
  String? _videoPath;
  String? _uploadedVideoUrl;

  bool _isChecked1 = false;
  bool _isChecked2 = false;


  Future<void> _selectImageAndVideo(BuildContext context) async {
    final ImagePicker _picker = ImagePicker();
    File? imageFile;
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text("Take a Photo"),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
                  if (pickedFile == null) {
                    print("No image selected from Camera");
                    return;
                  }
                  imageFile = File(pickedFile.path);
                  setState(() {
                    _videoPath = imageFile!.path;
                  });
                  final AuthService _signInService = AuthService();
                  String userId = _signInService.getCurrentUserID(); // Replace with actual user ID retrieval logic
                  await _uploadVideoImage(imageFile!, userId);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text("Choose from Gallery"),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile == null) {
                    print("No image selected from Gallery");
                    return;
                  }
                  imageFile = File(pickedFile.path);
                  setState(() {
                    _videoPath = imageFile!.path;
                  });
                  final AuthService _signInService = AuthService();
                  String userId = _signInService.getCurrentUserID(); // Replace with actual user ID retrieval logic
                  await _uploadVideoImage(imageFile!, userId);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _uploadVideoImage(File imageFile, String userId) async {
    if (userId.isEmpty) {
      print("Error: User ID is missing.");
      return;
    }

    try {
      final storageRef = FirebaseStorage.instance.ref().child('user_images/$userId.jpg');
      await storageRef.putFile(imageFile);
      final downloadURLVid = await storageRef.getDownloadURL();

      setState(() {
        _uploadedVideoUrl = downloadURLVid;
      });

      await FirebaseFirestore.instance.collection('Humanitarian').doc(userId).set({
        'VideoUrl': downloadURLVid
      }, SetOptions(merge: true));

      print("Image uploaded successfully: $downloadURLVid");
    } catch (e) {
      print('Error uploading image: $e');
    }
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(backgroundColor: Colors.green, title: Text('Humanitarian', style: TextStyle(color: Colors.white),),),
        body: ListView(
                  padding: EdgeInsets.all(8.0),
                  children: [
                  //  const SizedBox(height: 10.0,),
                    FormBuilderTextField(
                      name: 'Full Name',
                      controller: fullNameCont,
                      decoration: const InputDecoration(
                          labelText: 'Enter your full name',
                          border: OutlineInputBorder()
                      ),
                    ),
                    Text('* required', style: TextStyle(color: Colors.red),),
                   // const SizedBox(height: 10.0,),
                    DropdownButtonFormField(
                      value: selectedGender,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Select Gender',
                      ),
                      items: genderOptions.map((String item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          selectedGender = value;
                        });
                      },
                    ),

                    Text('* required', style: TextStyle(color: Colors.red),),
                   const SizedBox(height: 10.0,),
                    FormBuilderTextField(
                      name: 'Age',
                      controller: ageCont,
                      decoration: const InputDecoration(
                          labelText: 'Age',
                          border: OutlineInputBorder()
                      ),
                    ),
                    Text('* required', style: TextStyle(color: Colors.red),),
                   const SizedBox(height: 10.0,),
                    DropdownButtonFormField(
                      value: selectedDisability,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Disabled?'
                      ),
                      items: challengeOptions.map((String item){
                        return DropdownMenuItem<String>(
                            value: item,
                            child: Text(item));
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          selectedDisability = value;
                        });
                      },
                    ),
                    Text('* required', style: TextStyle(color: Colors.red),),
                  //  const SizedBox(height: 10.0,),
                    FormBuilderTextField(
                      name: 'Identification',
                      controller: identityCont,
                      decoration: const InputDecoration(
                          labelText: 'Means of ID eg. NIN, VIN',
                          border: OutlineInputBorder()
                      ),
                    ),
                    Text('* required', style: TextStyle(color: Colors.red),),
                  //  const SizedBox(height: 10.0,),
                    FormBuilderTextField(
                      name: 'Upload ID',
                      decoration: InputDecoration(
                          hintText: 'Upload Means of ID',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.upload),
                            onPressed: (){
                              _selectImage(context);
                            },
                          ),
                          suffix: _imagePath != null
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.file(File(_imagePath!),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,),) : null ),
                      controller: TextEditingController(),
                    ),
                    Text('* required', style: TextStyle(color: Colors.red),),
                  //  const SizedBox(height: 10.0,),
                    CountryStateCityPicker(
                      country: countryCont,
                      state: stateCont,
                      city: cityCont,
                      dialogColor: Colors.grey.shade200,
                      textFieldDecoration: const InputDecoration(
                          suffixIcon: Icon(Icons.arrow_drop_down_circle_outlined),
                          border: OutlineInputBorder()
                      ),),
                    Text('* required', style: TextStyle(color: Colors.red),),
                    const SizedBox(height: 10.0),
                    FormBuilderTextField(
                      controller: phoneCont,
                      name: 'Phone Number',
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder()
                    ),),
                    SizedBox(height: 10,),
                    FormBuilderTextField(
                      controller: addressCont,
                      name: 'address',
                      decoration: const InputDecoration(
                          labelText: 'Home Address',
                          border: OutlineInputBorder()
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    FormBuilderTextField(
                      name: 'Address',
                      controller: resAddressCont,
                      decoration: const InputDecoration(
                          labelText: 'Residential Address',
                          border: OutlineInputBorder()
                      ),
                    ),
                    Text('* required', style: TextStyle(color: Colors.red),),
                    const SizedBox(height: 10.0),
                    Card(
                        elevation: 5,
                        color: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        child: Text('Please select the category where you fall under for assistance',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white ),)),
                    const SizedBox(height: 10.0,),
                    Column(
                        children: <Widget>[
                          DropDownMultiSelect(
                            decoration: const InputDecoration(
                                labelText: 'Select Basic Need',
                                border: OutlineInputBorder()
                            ),
                            options: basicOptions,
                            selectedValues: selectedCheckBoxValue,
                            onChanged: (List<String> value) {
                              setState(() {
                                selectedCheckBoxValue;
                              });
                            }, whenEmpty: '',
                          ),
                          const SizedBox(height: 10.0,),
                          DropDownMultiSelect(
                            decoration: const InputDecoration(
                                labelText: 'Select Long-term Need',
                                border: OutlineInputBorder()
                            ),
                            options: longTermOptions,
                            selectedValues: selectedCheckBoxValue1,
                            onChanged: (List<String> value) {
                              setState(() {
                                selectedCheckBoxValue1;
                              });
                            }, whenEmpty: '',),
                          const SizedBox(height: 10,),
                          FormBuilderTextField(
                            name: 'Other Needs',
                            controller: otherCont,
                            decoration: const InputDecoration(
                                labelText: 'Other Personal or Community Need',
                                border: OutlineInputBorder()
                            ),
                          ),
                          const SizedBox(height: 10,),
                          FormBuilderTextField(
                            name: 'Skill',
                            controller: skillCont,
                            decoration: const InputDecoration(
                                labelText: 'Enter Skill/ Occupation',
                                border: OutlineInputBorder()
                            ),
                          ),
                          const SizedBox(height: 10,),
                          FormBuilderTextField(
                            name: 'Profession',
                            controller: professionCont,
                            decoration: const InputDecoration(
                                labelText: 'Enter Profession',
                                border: OutlineInputBorder()
                            ),
                          ),
                        ]
                    ),
                    const SizedBox(height: 10,),
                    Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text('Student', style: TextStyle(fontSize: 18,),),
                          Checkbox(value: _isChecked1,
                            onChanged: (bool? newValue) {
                              setState(() {
                                _isChecked1 = newValue!;
                              });
                            },
                            activeColor: Colors.green,
                            checkColor: Colors.yellow,
                          ),
                          _isChecked1? Expanded(
                            child: Column(
                                children: <Widget>[
                                  FormBuilderTextField(
                                    name: 'Institution',
                                    controller: institutionCont,
                                    decoration: const InputDecoration(
                                        labelText: 'Institution',
                                        border: OutlineInputBorder()
                                    ),),
                                  const SizedBox(height: 10,),
                                  FormBuilderTextField(
                                    name: 'Registration Number',
                                    controller: regCont,
                                    decoration: const InputDecoration(
                                        hintText: 'Registration Number',
                                        border: OutlineInputBorder()
                                    ),),
                                  const SizedBox(height: 10,),
                                  FormBuilderTextField(
                                    name: 'CGPA',
                                    controller: cgpaCont,
                                    decoration: const InputDecoration(
                                        hintText: 'CGPA',
                                        border: OutlineInputBorder()
                                    ),),
                                  const SizedBox(height: 10,),
                                  FormBuilderTextField(
                                    name: 'Course',
                                    controller: courseCont,
                                    decoration: const InputDecoration(
                                        hintText: 'Course of study',
                                        border: OutlineInputBorder()
                                    ),),
                                ]
                            ),
                          ): Container()
                        ]
                    ),
                    Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text('Business', style: TextStyle(fontSize: 18, ),),
                          Checkbox(value: _isChecked2,
                            onChanged: (bool? newValue) {
                              setState(() {
                                _isChecked2 = newValue!;
                              });
                            },
                            activeColor: Colors.green,
                            checkColor: Colors.yellow,
                          ),
                          _isChecked2? Expanded(
                            child: Column(
                                children: <Widget>[
                                  FormBuilderTextField(
                                    name: 'Type',
                                    controller: businessTypeCont,
                                    decoration: const InputDecoration(
                                      labelText: 'Business type',
                                      border: OutlineInputBorder()
                                  ),),
                                  const SizedBox(height: 10,),
                                  FormBuilderTextField(
                                    name: 'Name',
                                    controller: businessNameCont,
                                    decoration: const InputDecoration(
                                        hintText: 'Business Name',
                                        border: OutlineInputBorder()
                                    ),),
                                  const SizedBox(height: 10,),
                                  FormBuilderTextField(
                                    name: 'Location',
                                    controller: locationCont,
                                    decoration: const InputDecoration(
                                        hintText: 'Business Location',
                                        border: OutlineInputBorder()
                                    ),),
                                  const SizedBox(height: 10,),
                                  FormBuilderTextField(
                                    name: 'Duration',
                                    controller: durationCont,
                                    decoration: const InputDecoration(
                                        hintText: 'Duration of Business',
                                        border: OutlineInputBorder()
                                    ),),
                                  const SizedBox(height: 10,),
                                  FormBuilderTextField(
                                    name: 'Challenges',
                                    controller: challengeCont,
                                    decoration: const InputDecoration(
                                        hintText: 'Business need',
                                        border: OutlineInputBorder()
                                    ),),
                                ]
                            ),
                          ): Container()
                        ]
                    ),
                    const SizedBox(height: 10,),DropdownButtonFormField(
                      value: selectedEmployValue,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Select Employment Status',
                      ),
                      items: statusOptions.map((String item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          selectedEmployValue = value;
                        });
                      },
                      validator: (value) => null,
                    ),
                    const SizedBox(height: 10,),
                    FormBuilderTextField(
                      name: 'Bank',
                      controller: bankNameCont,
                      decoration: const InputDecoration(
                          labelText: 'Bank name (Optional)',
                          border: OutlineInputBorder()
                      ),),
                    const SizedBox(height: 10.0,),
                    FormBuilderTextField(
                      name: 'Account number',
                      controller: accountNumberCont,
                      decoration: const InputDecoration(
                          labelText: 'Account number (Optional)',
                          border: OutlineInputBorder()
                      ),),
                    const SizedBox(height: 10.0,),
                    FormBuilderTextField(
                      name: 'Account name',
                      controller: accountNameCont,
                      decoration: const InputDecoration(
                          labelText: 'Account name (Optional) ',
                          border: OutlineInputBorder()
                      ),),
                    const SizedBox(height: 10,),
                    FormBuilderTextField(
                      name: 'Upload Passport',
                      decoration: InputDecoration(
                          labelText: 'Upload Image',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.upload),
                            onPressed: (){
                              _selectImageAndVideo(context);
                            },
                          ),
                        suffix: _videoPath != null
                          ? ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.file(File(_videoPath!),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,),) : null ), controller: TextEditingController(),
                    ),
                    Text('* required', style: TextStyle(color: Colors.red),),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _isUploading
                          ? null
                          : () async {
                        // ✅ Check for null dropdowns before submit
                        if (selectedGender == null || selectedDisability == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Please select gender and disability")),
                          );
                          return;
                        }

                        setState(() {
                          _isUploading = true;
                        });

                        try {
                          await submitHumanitarianData(
                            context,
                            fullNameCont.text.toString(),
                            selectedGender!, // safe because we checked above
                            ageCont.text.toString(),
                            selectedDisability!, // safe
                            identityCont.text.toString(),
                            _imagePath ?? "",
                            countryCont.text.toString(),
                            stateCont.text.toString(),
                            cityCont.text.toString(),
                            phoneCont.text.toString(),
                            villageCont.text.toString(),
                            addressCont.text.toString(),
                            resAddressCont.text.toString(),
                            selectedCheckBoxValue.join(","),  // ✅ fixed list -> string
                            selectedCheckBoxValue1.join(","), // ✅ fixed list -> string
                            otherCont.text.toString(),
                            skillCont.text.toString(),
                            institutionCont.text.toString(),
                            regCont.text.toString(),
                            cgpaCont.text.toString(),
                            courseCont.text.toString(),
                            businessTypeCont.text.toString(),
                            businessNameCont.text.toString(),
                            locationCont.text.toString(),
                            durationCont.text.toString(),
                            challengeCont.text.toString(),
                            selectedEmployValue ?? "Unemployed", // ✅ fallback if null
                            bankNameCont.text.toString(),
                            accountNameCont.text.toString(),
                            accountNumberCont.text.toString(),
                            _videoPath ?? "",
                          );

                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const HomeScreen()),
                          );
                        } catch (error, stack) {
                          // ✅ show error instead of hiding it
                          print("❌ Submit error: $error\n$stack");
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Submission failed: $error")),
                          );
                        } finally {
                          setState(() {
                            _isUploading = false;
                          });
                        }
                      },
                      child: _isUploading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Submit"),
                    ),

                  ]
        ),
    );
  }
}
Future<void> submitHumanitarianData(
    BuildContext context,
    String fullNameValue,
    String genderValue,
    String ageValue,
    String disabledValue,
    String identifyValue,
    String imageValue,
    String countryValue,
    String stateValue,
    String lgaValue,
    String phoneValue,
    String villageValue,
    String addressValue,
    String resAddress,
    String basicValue,
    String longTermValue,
    String otherValue,
    String skillValue,
    String institutionValue,
    String regValue,
    String cgpaValue,
    String courseValue,
    String businessTypeValue,
    String businessNameValue,
    String locationValue,
    String durationValue,
    String challengesValue,
    String employValue,
    String bankNameValue,
    String accountNameValue,
    String accountNumberValue,
    String videoValue,
    ) async {
  User? user = FirebaseAuth.instance.currentUser;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('fullName', fullNameValue.trim().replaceAll(" ", "_"));
  final String fullName = fullNameValue.trim().replaceAll(" ", "_");

  if (user != null) {
    final collection = FirebaseFirestore.instance
        .collection('users')
        .doc(fullName)
        .collection('Humanitarian');

    // Step 2: Upload files
    try {
      final ninImageUrl = await uploadFileToFirebase(
        imageValue,
        'humanitarianNIN/${fullName}.jpg',
      );
      final imageUrl = await uploadFileToFirebase(
        imageValue,
        'humanitarianImages/${fullName}.jpg',
      );

      final videoValueUrl = await uploadFileToFirebase(
        videoValue,
        'humanitarianVideos/${fullName}.mp4',
      );


      // Step 1: Add initial doc
      await collection.add({
        'Full Name': fullNameValue,
        'Gender': genderValue,
        'Age': ageValue,
        'Disabled': disabledValue,
        'Identification': identifyValue,
        'ImageUrl': imageUrl, // placeholder until uploaded
        'Country': countryValue,
        'State': stateValue,
        'City': lgaValue,
        'Phone Number': phoneValue,
        'Community': villageValue,
        'Address': addressValue,
        'Residential Address': resAddress,
        'Basic Need': basicValue,
        'Long Term Need': longTermValue,
        'Other': otherValue,
        'Skill': skillValue,
        'Institution': institutionValue,
        'Registration Number': regValue,
        'CGPA': cgpaValue,
        'Course': courseValue,
        'Business Type': businessTypeValue,
        'Business Name': businessNameValue,
        'Location': locationValue,
        'Duration': durationValue,
        'Business Challenge': challengesValue,
        'Employment Status': employValue,
        'Bank Name': bankNameValue,
        'Account Name': accountNameValue,
        'Account Number': accountNumberValue,
        'videoUrl': videoValueUrl, // placeholder until uploaded
        'timestamp': FieldValue.serverTimestamp(),
      });
      // Step 4: Success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Submission Successful!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('❌ Error saving data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

    //print("✅ Data written to: users/$fullName/Humanitarian/${doc.id}");
Future<String> uploadFileToFirebase(String filePath, String storagePath) async {
  try {
    print('Attempting to upload file from: $filePath');

    File file = File(filePath);
    if (!file.existsSync()) {
      throw Exception("File does not exist at $filePath");
    }

    // Get temp directory for compressed file
    final tempDir = await getTemporaryDirectory();
    final targetPath = path.join(tempDir.path, 'compressed_${path.basename(filePath)}');

    // Compress the image
    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      filePath,
      targetPath,
      quality: 75,  // Reduce quality to 75% for smaller size
    );

    if (compressedFile == null) {
      throw Exception("Image compression failed");
    }

    // Upload the compressed file
    final storageRef = FirebaseStorage.instance.ref().child(storagePath);
    UploadTask uploadTask = storageRef.putFile(File(compressedFile.path));
    TaskSnapshot snapshot = await uploadTask.whenComplete(() => {});

    // Get the download URL
    String downloadURL = await snapshot.ref.getDownloadURL();
    print('Upload successful: $downloadURL');
    return downloadURL;
  } catch (e) {
    print('Error uploading file: $e');
    throw Exception('File upload failed: $e');
  }
}


// Function to compress image
Future<File?> compressImage(File file) async {
  final tempDir = await getTemporaryDirectory();
  final targetPath = '${tempDir.path}/${path.basename(file.path)}';

  var result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path, targetPath,
    quality: 70, // Adjust quality (1-100, lower means more compression)
    format: CompressFormat.jpeg, // Converts PNG/WebP to JPEG for better compression
  );

  return result != null ? File(result.path) : null;
}


