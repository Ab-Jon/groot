import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_state_city_pro/country_state_city_pro.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../screens/home_screen.dart';
import '../service/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();

}

class _RegisterScreenState extends State<RegisterScreen> {

  String? _imagePath;
  String? _imagePathUp;
  String? _imagePathCo;
  String? _imagePathVIN;
  String? _uploadedImageUrl;
  String? _uploadedImageUrlUp;
  String? _uploadedImageUrlCo;
  String? _uploadedImageUrlVIN;

  bool _isUploading = false;
  bool _isChecked = false;
  bool _isChecked1 = false;
  bool _isChecked2 = false;
  bool _isChecked3 = false;
  bool _isChecked4 = false;
  bool _isChecked5 = false;
  bool _isChecked6 = false;
  bool _isChecked7 = false;

  String? selectedValue;

  List<String> genderOptions = ['Male', 'Female'];

  String get upLineValue => upLineValue;


  final List<String> principalRoles = [
    "Presidency",
    "Governorship",
    "Senate",
    "House of Reps",
    "House of Assembly",
    "Chairmanship",
    "Councillorship",
    "Other"
  ];

// Map to store text controllers for each role
  Map<String, TextEditingController> principalControllers = {};

  Map<String, String> getFormData() {
    return principalControllers.map(
          (key, controller) => MapEntry(key, controller.text),
    );
  }


  Future<void> _selectUploadImage(BuildContext context) async {
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

                  String userId = "YOUR_USER_ID"; // Replace with actual user ID retrieval logic
                  await _uploadImage(imageFile!, userId);
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
                  await _uploadImage(imageFile!, userId);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _uploadImage(File imageFile, String userId) async {
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

      await FirebaseFirestore.instance.collection('Individual').doc(userId).set({
        'profileImageUrl': downloadURL
      }, SetOptions(merge: true));

      print("Image uploaded successfully: $downloadURL");
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> _selectImageUp(BuildContext context) async {
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
                    _imagePathUp = imageFile!.path;
                  });

                  final AuthService _signInService = AuthService();
                  String userId = _signInService.getCurrentUserID(); // Replace with actual user ID retrieval logic
                  await _uploadUpImage(imageFile!, userId);
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
                    _imagePathUp = imageFile!.path;
                  });

                  final AuthService _signInService = AuthService();
                  String userId = _signInService.getCurrentUserID(); // Replace with actual user ID retrieval logic
                  await _uploadUpImage(imageFile!, userId);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _uploadUpImage(File imageFile, String userId) async {
    if (userId.isEmpty) {
      print("Error: User ID is missing.");
      return;
    }

    try {
      final storageRef = FirebaseStorage.instance.ref().child('user_images/$userId.jpg');
      await storageRef.putFile(imageFile);
      final downloadURLUp = await storageRef.getDownloadURL();

      setState(() {
        _uploadedImageUrlUp = downloadURLUp;
      });

      await FirebaseFirestore.instance.collection('Individual').doc(userId).set({
        'upImageUrl': downloadURLUp
      }, SetOptions(merge: true));

      print("Image uploaded successfully: $downloadURLUp");
    } catch (e) {
      print('Error uploading image: $e');
    }
  }
  Future<void> _selectImageCo(BuildContext context) async {
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
                    _imagePathCo = imageFile!.path;
                  });

                  final AuthService _signInService = AuthService();
                  String userId = _signInService.getCurrentUserID(); // Replace with actual user ID retrieval logic
                  await _uploadCoImage(imageFile!, userId);
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
                    _imagePathCo = imageFile!.path;
                  });

                  final AuthService _signInService = AuthService();
                  String userId = _signInService.getCurrentUserID(); // Replace with actual user ID retrieval logic
                  await _uploadCoImage(imageFile!, userId);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _uploadCoImage(File imageFile, String userId) async {
    if (userId.isEmpty) {
      print("Error: User ID is missing.");
      return;
    }

    try {
      final storageRef = FirebaseStorage.instance.ref().child('user_images/$userId.jpg');
      await storageRef.putFile(imageFile);
      final downloadURLCo = await storageRef.getDownloadURL();

      setState(() {
        _uploadedImageUrlCo = downloadURLCo;
      });

      await FirebaseFirestore.instance.collection('Individual').doc(userId).set({
        'coImageUrl': downloadURLCo
      }, SetOptions(merge: true));

      print("Image uploaded successfully: $downloadURLCo");
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> _selectVINImage(BuildContext context) async {
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
                    _imagePathVIN = imageFile!.path;
                  });

                  final AuthService _signInService = AuthService();
                  String userId = _signInService.getCurrentUserID(); // Replace with actual user ID retrieval logic
                  await _uploadVINImage(imageFile!, userId, full_name.text.trim(), vinCont.text.trim());
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
                    _imagePathVIN = imageFile!.path;
                  });

                  final AuthService _signInService = AuthService();
                  String userId = _signInService.getCurrentUserID(); // Replace with actual user ID retrieval logic
                  await _uploadVINImage(imageFile!, userId, full_name.text.trim(), vinCont.text.trim() );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _uploadVINImage(
      File imageFile,
      String userId,
      String typedName,
      String typedVIN,
      ) async {
    if (userId.isEmpty) {
      print("Error: User ID is missing.");
      return;
    }

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('voter_cards/$userId.jpg');

      // Upload with metadata (THIS is what Cloud Function reads)
      await storageRef.putFile(
        imageFile,
        SettableMetadata(
          contentType: "image/jpeg",
          customMetadata: {
            "typedName": typedName.trim(),
            "typedVIN": typedVIN.trim(),
            "userId": userId,
          },
        ),
      );

      final downloadURLVIN = await storageRef.getDownloadURL();

      setState(() {
        _uploadedImageUrlVIN = downloadURLVIN;
      });

      print("Image uploaded, waiting for validation...");

      // 🔥 Now wait for validation result from Firestore
      final validationRef = FirebaseFirestore.instance
          .collection("voter_validations")
          .doc(userId);

      // Listen for Cloud Function response (only once)
      final snap = await validationRef.get();

      if (!snap.exists) {
        print("No validation result yet.");
        return;
      }

      final isValid = snap.data()?["isValid"] ?? false;
      final reason = snap.data()?["reason"] ?? "Unknown reason";

      if (isValid) {
        print("VOTER CARD VALID");

        // Only now you save VIN to user profile
        await FirebaseFirestore.instance
            .collection('Individual')
            .doc(userId)
            .set({
          'VINImage': downloadURLVIN,
          'typedVIN': typedVIN,
          'typedName': typedName,
        }, SetOptions(merge: true));
      } else {
        print("INVALID VOTER CARD: $reason");
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }


  @override
  void initState() {
    super.initState();
    // Initialize controllers for each role
    for (var role in principalRoles) {
      principalControllers[role] = TextEditingController();
    }
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    principalControllers.forEach((key, controller) {
      controller.dispose();
    });
    super.dispose();
  }


  TextEditingController occupationCont = TextEditingController();
  TextEditingController vinCont = TextEditingController();
  TextEditingController uploadVinCont = TextEditingController();
  TextEditingController uploadPassportCont = TextEditingController();
  TextEditingController coordinatorCont = TextEditingController();
  TextEditingController unitCont = TextEditingController();
  TextEditingController villageCont = TextEditingController();
  TextEditingController wardCont = TextEditingController();
  TextEditingController up_lineCont = TextEditingController();
  TextEditingController presidentCont= TextEditingController();
  TextEditingController govCont = TextEditingController();
  TextEditingController senCont = TextEditingController();
  TextEditingController hoRCont = TextEditingController();
  TextEditingController hoACont = TextEditingController();
  TextEditingController chairCont = TextEditingController();
  TextEditingController councilCont = TextEditingController();
  TextEditingController otherCont = TextEditingController();
  TextEditingController countryCont = TextEditingController();
  TextEditingController stateCont = TextEditingController();
  TextEditingController cityCont = TextEditingController();
  TextEditingController vinName = TextEditingController();
  TextEditingController full_name = TextEditingController();
  TextEditingController age = TextEditingController();
  TextEditingController home_address = TextEditingController();
  TextEditingController resident_address = TextEditingController();
  TextEditingController phone_no = TextEditingController();

  void _clearForm(){
    occupationCont.clear();
    vinCont.clear();
    uploadVinCont.clear();
    uploadPassportCont.clear();
    coordinatorCont.clear();
    unitCont.clear();
    villageCont.clear();
    wardCont.clear();
    up_lineCont.clear();
    presidentCont.clear();
    govCont.clear();
    senCont.clear();
    hoRCont.clear();
    hoACont.clear();
    chairCont.clear();
    councilCont.clear();
    otherCont.clear();
    countryCont.clear();
    stateCont.clear();
    cityCont.clear();
    full_name.clear();
    age.clear();
    home_address.clear();
    resident_address.clear();
    phone_no.clear();

  }

  Future<void> _restrictUser() async {
    final vin = vinCont.text.trim();

    if(vin.isEmpty){
      throw Exception('This field is required');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.green ,title: const Text('Register as Individual', style: TextStyle(color: Colors.white),),),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8.0),
              children: <Widget>[
                const SizedBox(height: 10.0,),
                FormBuilderTextField(
                  name: 'Surname',
                  controller: full_name,
                  decoration: const InputDecoration(
                      labelText: 'full name',
                      border: OutlineInputBorder()
                  ),
                ),
                Text('* required', style: TextStyle(color: Colors.red),),
                const SizedBox(height: 10.0,),
                DropdownButtonFormField(
                    value: selectedValue,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Select Gender'
                    ),
                    items: genderOptions.map((String item){
                      return DropdownMenuItem<String>(
                          value: item,
                          child: Text(item));
                    }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      selectedValue = value;
                    });

                  },
                ),
                const SizedBox(height: 10.0,),
                FormBuilderTextField(
                  name: 'Age',
                  controller: age,
                  decoration: const InputDecoration(
                      labelText: 'age',
                      border: OutlineInputBorder()
                  ),),
                const SizedBox(height: 10.0,),
                FormBuilderTextField(
                  name: 'Home Address',
                  controller: home_address,
                  decoration: const InputDecoration(
                      labelText: 'Home Address',
                      border: OutlineInputBorder()
                  ),),
                const SizedBox(height: 10.0),
                FormBuilderTextField(
                  name: 'Residential Address',
                  controller: resident_address,
                  decoration: const InputDecoration(
                      labelText: 'Residential Address',
                      border: OutlineInputBorder()
                  ),
                ),
                const SizedBox(height: 10.0,),
                CountryStateCityPicker(
                  country: countryCont,
                  state: stateCont,
                  city: cityCont,
                  dialogColor: Colors.grey.shade200,
                  textFieldDecoration: const InputDecoration(
                      suffixIcon: Icon(Icons.arrow_drop_down_outlined),
                      border: OutlineInputBorder()
                  ),
                ),
                Text('* required', style: TextStyle(color: Colors.red),),
                const SizedBox(height: 10.0,),
                FormBuilderTextField(
                  controller: phone_no,
                  name: 'Phone Number',
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder()
                  ),),
                Text('* required', style: TextStyle(color: Colors.red),),
                const SizedBox(height: 10.0,),
                FormBuilderTextField(
                  name: 'Chapter Coordinator',
                  controller: coordinatorCont,
                  decoration: const InputDecoration(
                      labelText: 'Coordinator Name',
                      border: OutlineInputBorder()
                  ),
                ),
                const SizedBox(height: 10.0,),
                FormBuilderTextField(
                  name: 'Unit',
                  controller: unitCont,
                  decoration: const InputDecoration(
                      labelText: 'Unit',
                      border: OutlineInputBorder()
                  ),
                ),
                const SizedBox(height: 10.0,),
                FormBuilderTextField(
                  name: 'Village',
                  controller: villageCont,
                  decoration: const InputDecoration(
                      labelText: 'Community',
                      border: OutlineInputBorder()
                  ),
                ),
                const SizedBox(height: 10.0,),
                FormBuilderTextField(
                  name: 'Ward',
                  controller: wardCont,
                  decoration: const InputDecoration(
                      labelText: 'Ward',
                      border: OutlineInputBorder()
                  ),
                ),
                const SizedBox(height: 10.0,),
                FormBuilderTextField(
                  name: 'Up-line Name',
                  controller: up_lineCont,
                  decoration: const InputDecoration(
                      labelText: 'Up-line Name',
                      border: OutlineInputBorder()
                  ),
                ),
                const SizedBox(height: 10.0),
                Card(
                  elevation: 4,
                  color: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  margin: EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text('All the offices can equally be replaced by its equivalent.', style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),),
                  ),
                ),
                Column(
                  children: principalRoles.map((role) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextField(
                        controller: principalControllers[role],
                        decoration: InputDecoration(
                          labelText: "$role Name",
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10.0,),
                FormBuilderTextField(
                  name: 'Occupation',
                  controller: occupationCont,
                  decoration: const InputDecoration(
                      labelText: 'Occupation',
                      border: OutlineInputBorder()
                  ),
                ),
                const SizedBox(height: 10.0,),
                TextFormField(
                  controller: vinName,
                  decoration: const InputDecoration(
                      labelText: 'Voter Identifier Name e.g (VIN)',
                      border: OutlineInputBorder()
                  ),
                ),
                Text('* required', style: TextStyle(color: Colors.red),),
                const SizedBox(height: 10.0,),
                TextFormField(
                  controller: vinCont,
                  decoration: const InputDecoration(
                      labelText: 'Voter Identifier Number',
                      border: OutlineInputBorder()
                  ),
                ),
                Text('* required', style: TextStyle(color: Colors.red),),
                const SizedBox(height: 10,),
                FormBuilderTextField(
                  name: 'Upload VIN',
                  decoration: InputDecoration(
                      labelText: 'Upload Voter Card',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.upload),
                        onPressed: (){
                          _selectVINImage(context);
                        },
                      ),
                        suffix: _imagePathVIN != null
                        ? ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.file(File(_imagePathVIN!),
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,),) : null,), controller: TextEditingController(),),
                Text('* required', style: TextStyle(color: Colors.red),),
                const SizedBox(height: 10,),
                FormBuilderTextField(
                  name: 'Upload Passport',
                  decoration: InputDecoration(
                    labelText: 'Upload Profile Picture',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.upload),
                      onPressed: () { _selectUploadImage(context);},
                    ),
                    suffix: _imagePath != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.file(
                        File(_imagePath!),
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    )
                        : null,
                  ),
                  readOnly: true,
                  controller: TextEditingController(),
                ),
                Text('* required', style: TextStyle(color: Colors.red),),
                const SizedBox(height: 10,),
                FormBuilderTextField(
                  name: 'Upload Passport',
                  decoration: InputDecoration(
                    labelText: 'Upload passport (Up line)',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.upload),
                      onPressed: (){
                        _selectImageUp(context);
                      },
                    ),
                    suffix: _imagePathUp != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.file(
                        File(_imagePathUp!),
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    )
                        : null,
                  ),
                  readOnly: true,
                  controller: TextEditingController(),
                ),
                const SizedBox(height: 10,),
                FormBuilderTextField(
                  name: 'Upload Passport',
                  decoration: InputDecoration(
                    labelText: 'Upload passport (Coordinator) ',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.upload),
                      onPressed: (){
                        _selectImageCo(context);
                      },
                    ),
                    suffix: _imagePathCo != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.file(
                        File(_imagePathCo!),
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    )
                        : null,
                  ),
                  readOnly: true,
                  controller: TextEditingController(),
                ),
                const SizedBox(height: 10,),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Colors.green)
                        ),
                        onPressed: (){
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel', style: TextStyle(color: Colors.blueAccent),),),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          onPressed: _isUploading
                              ? null : () async {
                            setState(() {
                              _isUploading = true;
                            });
                            try{
                              Map<String, String> selectedPrincipals = {};

                              for (String role in principalRoles) {
                                String name = principalControllers[role]!.text.trim();
                                if (name.isNotEmpty) {
                                  selectedPrincipals[role] = name;
                                }
                              }
                              await submitData(context, full_name.text.toString(), selectedValue!, age.text.toString(), home_address.text.toString(),
                                  resident_address.text.toString(), countryCont.text.toString(), stateCont.text.toString(),
                                  cityCont.text.toString(), phone_no.text.toString(), coordinatorCont.text.toString(),
                                  unitCont.text.toString(), villageCont.text.toString(), wardCont.text.toString(),
                                  up_lineCont.text.toString(), getFormData(),
                                  occupationCont.text.toString(), vinName.text.toString(), vinCont.text.toString(),
                                  _imagePathVIN.toString(), _imagePath.toString(), _imagePathUp.toString(), _imagePathCo.toString());
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (
                                  context) => const HomeScreen()));
                              _clearForm();
                            } catch (error){

                            } finally{
                              setState(() {
                                _isUploading = false;
                              });
                            }
                          },
                          child: _isUploading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2,),
                          )
                              : const Text('Submit', style: TextStyle(
                              color: Colors.white),))

                    ],
                  ),

              ],
            ),
          ),
        ],

      ),
    );
  }
}
Future<void> submitData(
    BuildContext context,
    String full_nameValue,
    String genderValue,
    String ageValue,
    String h_addressValue,
    String r_addressValue,
    String countryValue,
    String stateValue,
    String lgaValue,
    String phoneValue,
    String coordinatorValue,
    String unitValue,
    String villageValue,
    String wardValue,
    String upLineValue,
    Map<String, String> selectedPrincipals,
    String occupationValue,
    String vinName,
    String vinValue,
    String vinImageFile, // Local file for VIN image
    String profileImageFile, // Local file for Profile image
    String upLineImageFile, // Local file for Up line image
    String coordinatorImageFile, // Local file for Coordinator image
    ) async {
  User? user = FirebaseAuth.instance.currentUser;
  final String fullNameValue = full_nameValue.trim().replaceAll(" ", "_");

  if (user != null) {
    final principals = FirebaseFirestore.instance.collection('principals').doc(user.uid).collection('followers');
    final collection = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('data');
    final vinRecords = FirebaseFirestore.instance.collection('vinRecords');

    if (vinValue.isEmpty || lgaValue.isEmpty
        || phoneValue.isEmpty || stateValue.isEmpty || full_nameValue.isEmpty ||
        ageValue.isEmpty
        || countryValue.isEmpty || profileImageFile.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You have omitted a required field!'),
          backgroundColor: Colors.red,
        ),
      );
    }

    final vinDoc = await vinRecords.doc(vinValue).get();
    if (vinDoc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('The VIN is already used!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }


    String? vinImageURL;
    String? profileImageURL;
    String? upLineImageURL;
    String? coordinatorImageURL;

    // 🔹 Ensure VIN image is compulsory
    vinImageURL = await uploadFileToFirebase(
      vinImageFile, // ✅ Fix: Pass file path
      'vinImages/${full_nameValue.trim().replaceAll(" ", "_")}.jpg',
    );

    // 🔹 Ensure Profile image is compulsory
    profileImageURL = await uploadFileToFirebase(
      profileImageFile, // ✅ Fix: Pass file path
      'profileImages/${full_nameValue.trim().replaceAll(" ", "_")}.jpg',
    );

    if (upLineImageFile.isNotEmpty) {
      try {
        upLineImageURL = await uploadFileToFirebase(
          upLineImageFile,
          'upLineImages/${full_nameValue}.jpg',
        );
        print("✅ Uploaded Successfully: $upLineImageURL");
      } catch (e) {
        print("❌ Upload Failed: $e");
      }
    } else {
      print("⚠️ No upLineImageFile provided, skipping upload.");
      upLineImageURL = null; // Explicitly set to null
    }

    if (coordinatorImageFile.isNotEmpty) {
      try {
        coordinatorImageURL = await uploadFileToFirebase(
          coordinatorImageFile,
          'coordinatorImages/${full_nameValue}.jpg',
        );
        print("✅ Uploaded Successfully: $coordinatorImageURL");
      } catch (e) {
        print("❌ Upload Failed: $e");
      }
    } else {
      print("⚠️ No upLineImageFile provided, skipping upload.");
      coordinatorImageURL = null; // Explicitly set to null
    }

    try {
      // Loop through each principal and save member data
      for (var entry in selectedPrincipals.entries) {
        String principalRole = entry.key; // e.g., "President"
        String principalName = entry.value;

          await FirebaseFirestore.instance.runTransaction((transaction) async {
            // Upload files to Firebase Storage and get their download URLs

            // Add VIN to vinRecords collection
            transaction.set(vinRecords.doc(vinValue), {
              'timestamp': FieldValue.serverTimestamp(),
            });

            // Add user data to their personal collection
            transaction.set(collection.doc(), {
              'Full Name': full_nameValue,
              'count': FieldValue.increment(1), // ✅ Auto-increments dynamically
              'Age': ageValue,
              'Gender': genderValue,
              'Home Address': h_addressValue,
              'Residential Address': r_addressValue,
              'Country': countryValue,
              'State': stateValue,
              'LGA': lgaValue,
              'Phone Number': phoneValue,
              'Coordinator': coordinatorValue,
              'Unit': unitValue,
              'Village': villageValue,
              'Ward': wardValue,
              'Up line': upLineValue,
              'Principal Role': principalRole,
              'Principal Name': principalName,
              'Occupation': occupationValue,
              'Vin Name': vinName,
              'Vin': vinValue,
              'VINImage': vinImageURL,
              'profileImageUrl': profileImageURL,
              'upImageUrl': upLineImageURL,
              'coImageUrl': coordinatorImageURL,
              'timestamp': FieldValue.serverTimestamp(),
            },SetOptions(merge: true));
            transaction.set(principals.doc(), {
              'Full Name': full_nameValue,
              'Age': ageValue,
              'Gender': genderValue,
              'Home Address': h_addressValue,
              'Residential Address': r_addressValue,
              'Country': countryValue,
              'State': stateValue,
              'LGA': lgaValue,
              'Phone Number': phoneValue,
              'Coordinator': coordinatorValue,
              'Unit': unitValue,
              'Village': villageValue,
              'Ward': wardValue,
              'Up line': upLineValue,
              'Principal Role': principalRole,
              'Principal Name': principalName,
              'Occupation': occupationValue,
              'Vin Name': vinName,
              'Vin': vinValue,
              'VINImage': vinImageURL,
              'profileImageUrl': profileImageURL,
              'upImageUrl': upLineImageURL,
              'coImageUrl': coordinatorImageURL,
              'timestamp': FieldValue.serverTimestamp(),
              'count': FieldValue.increment(1), // ✅ Auto-increments dynamically
            });
          });
        }
      } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    // final upCollection = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('up line');
    // final upQuerySnapshot = await upCollection.where('Up line', isEqualTo: upLineValue).get();
    // if (upQuerySnapshot.docs.isNotEmpty) {
    //   // Increment 'count' for existing Upline
    //   final docId = upQuerySnapshot.docs.first.id;
    //   await upCollection.doc(docId).update({
    //     'count': FieldValue.increment(1),
    //   });
    // } else {
    //   // Add new Upline entry
    //   await upCollection.add({
    //     'Up line': upLineValue,
    //     'count': 1,
    //     'Ward': wardValue,
    //     'Unit': unitValue,
    //     'Village': villageValue,
    //     'LGA': lgaValue,
    //     'Phone Number': phoneValue,
    //     'State': stateValue,
    //     'Full Name': full_nameValue,
    //     'Age': ageValue,
    //     'Home Address': h_addressValue,
    //     'Residential Address': r_addressValue,
    //     'Country': countryValue,
    //     'Coordinator': coordinatorValue,
    //     'Occupation': occupationValue,
    //     'Vin': vinValue,
    //     'VINImage': vinImageURL,
    //     'profileImageUrl': profileImageURL,
    //     'upImageUrl': upLineImageURL,
    //     'coImageUrl': coordinatorImageURL,
    //   });
    // }
    //
    // // 2. Handle Ward
    // final wardCollection = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('wards');
    // final wardQuerySnapshot = await wardCollection
    //     .where('Ward', isEqualTo: wardValue)
    //     .where('LGA', isEqualTo: lgaValue)
    //     .where('State', isEqualTo: stateValue).get();
    // if (wardQuerySnapshot.docs.isNotEmpty) {
    //   // Increment 'count' for existing Ward
    //   final docId = wardQuerySnapshot.docs.first.id;
    //   await wardCollection.doc(docId).update({
    //     'count': FieldValue.increment(1),
    //   });
    // } else {
    //   // Add new Ward entry
    //   await wardCollection.add({
    //     'Up line': upLineValue,
    //     'count': 1,
    //     'Ward': wardValue,
    //     'Unit': unitValue,
    //     'Village': villageValue,
    //     'LGA': lgaValue,
    //     'Phone Number': phoneValue,
    //     'State': stateValue,
    //     'Full Name': full_nameValue,
    //     'Age': ageValue,
    //     'Home Address': h_addressValue,
    //     'Residential Address': r_addressValue,
    //     'Country': countryValue,
    //     'Coordinator': coordinatorValue,
    //     'Occupation': occupationValue,
    //     'Vin': vinValue,
    //     'VINImage': vinImageURL,
    //     'profileImageUrl': profileImageURL,
    //     'upImageUrl': upLineImageURL,
    //     'coImageUrl': coordinatorImageURL,
    //   });
    // }
    //
    // // 3. Handle LGA
    // final lgaCollection = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('LGAs');
    // final lgaQuerySnapshot = await lgaCollection.where('LGA', isEqualTo: lgaValue).get();
    // if (lgaQuerySnapshot.docs.isNotEmpty) {
    //   // Increment 'count' for existing LGA
    //   final docId = lgaQuerySnapshot.docs.first.id;
    //   await lgaCollection.doc(docId).update({
    //     'count': FieldValue.increment(1),
    //   });
    // } else {
    //   // Add new LGA entry
    //   await lgaCollection.add({
    //     'Up line': upLineValue,
    //     'count': 1,
    //     'Ward': wardValue,
    //     'Unit': unitValue,
    //     'Village': villageValue,
    //     'LGA': lgaValue,
    //     'Phone Number': phoneValue,
    //     'State': stateValue,
    //     'Full Name': full_nameValue,
    //     'Age': ageValue,
    //     'Home Address': h_addressValue,
    //     'Residential Address': r_addressValue,
    //     'Country': countryValue,
    //     'Coordinator': coordinatorValue,
    //     'Occupation': occupationValue,
    //     'Vin': vinValue,
    //     'VINImage': vinImageURL,
    //     'profileImageUrl': profileImageURL,
    //     'upImageUrl': upLineImageURL,
    //     'coImageUrl': coordinatorImageURL,
    //   });
    // }
    //
    // // 4. Handle State
    // final stateCollection = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('state');
    // final stateQuerySnapshot = await stateCollection.where('State', isEqualTo: stateValue).get();
    // if (stateQuerySnapshot.docs.isNotEmpty) {
    //   // Increment 'count' for existing State
    //   final docId = stateQuerySnapshot.docs.first.id;
    //   await stateCollection.doc(docId).update({
    //     'count': FieldValue.increment(1),
    //   });
    // } else {
    //   // Add new State entry
    //   await stateCollection.add({
    //     'Up line': upLineValue,
    //     'count': 1,
    //     'Ward': wardValue,
    //     'Unit': unitValue,
    //     'Village': villageValue,
    //     'LGA': lgaValue,
    //     'Phone Number': phoneValue,
    //     'State': stateValue,
    //     'Full Name': full_nameValue,
    //     'Age': ageValue,
    //     'Home Address': h_addressValue,
    //     'Residential Address': r_addressValue,
    //     'Country': countryValue,
    //     'Coordinator': coordinatorValue,
    //     'Occupation': occupationValue,
    //     'Vin': vinValue,
    //     'VINImage': vinImageURL,
    //     'profileImageUrl': profileImageURL,
    //     'upImageUrl': upLineImageURL,
    //     'coImageUrl': coordinatorImageURL,
    //   });
    // }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Registration Successful!'),
        backgroundColor: Colors.green,
      ),
    );
    return;
  }
}

    Future<String> uploadFileToFirebase(String filePath, String storagePath) async {
      try {
        print('Attempting to upload file from: $filePath');

        File file = File(filePath);
        if (!file.existsSync()) {
          throw Exception("File does not exist at $filePath");
        }

        // Get temp directory for compressed file
        final tempDir = await getTemporaryDirectory();
        final targetPath = path.join(
            tempDir.path, 'compressed_${path.basename(filePath)}');

        // Compress the image
        final compressedFile = await FlutterImageCompress.compressAndGetFile(
          filePath,
          targetPath,
          quality: 75, // Reduce quality to 75% for smaller size
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
        format: CompressFormat
            .jpeg, // Converts PNG/WebP to JPEG for better compression
      );

      return result != null ? File(result.path) : null;
    }

