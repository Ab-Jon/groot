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

class GroupRegister extends StatefulWidget {
  const GroupRegister({super.key});

  @override
  State<GroupRegister> createState() => _GroupRegisterState();
}

class _GroupRegisterState extends State<GroupRegister> {
  String? _imagePathMember;
  String? _uploadedImageUrlMember;
  String? _vinImage;
  String? _vinImagePath;
  String? _uploadedVinImageUrl;
  bool isLoading = false;

  String? selectedValue;
  List<String> genderOptions = ['Male', 'Female'];

  // List of principal roles
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


  // Function for selection of member profile picture
  Future<void> _selectImageMember(BuildContext context) async {
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
                    _imagePathMember = imageFile!.path;
                  });

                  final AuthService _signInService = AuthService();
                  String userId = _signInService.getCurrentUserID(); // Replace with actual user ID retrieval logic
                  await _uploadMemberImage(imageFile!, userId);
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
                    _imagePathMember = imageFile!.path;
                  });

                  final AuthService _signInService = AuthService();
                  String userId = _signInService.getCurrentUserID(); // Replace with actual user ID retrieval logic
                  await _uploadMemberImage(imageFile!, userId);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  //Function for uploading of member image
  Future<void> _uploadMemberImage(File imageFile, String userId) async {
    if (userId.isEmpty) {
      print("Error: User ID is missing.");
      return;
    }
    try {
      final storageRef = FirebaseStorage.instance.ref().child('user_images/$userId.jpg');
      await storageRef.putFile(imageFile);
      final downloadURLCo = await storageRef.getDownloadURL();

      setState(() {
        _uploadedImageUrlMember = downloadURLCo;
      });

      await FirebaseFirestore.instance.collection('Individual').doc(userId).set({
        'memberImageUrl': downloadURLCo
      }, SetOptions(merge: true));

      print("Image uploaded successfully: $downloadURLCo");
    } catch (e) {
      print('Error uploading image: $e');
    }
  }


  // Function for selection of member vin image
  Future<void> _selectVinImage(BuildContext context) async {
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
                    _vinImagePath = imageFile!.path;
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
                    _vinImagePath = imageFile!.path;
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

  //Function for uploading of member vin image
  Future<void> _uploadVINImage(File imageFile, String userId) async {
    if (userId.isEmpty) {
      print("Error: User ID is missing.");
      return;
    }

    try {
      final storageRef = FirebaseStorage.instance.ref().child('user_images/$userId.jpg');
      await storageRef.putFile(imageFile);
      final downloadURLVin = await storageRef.getDownloadURL();

      setState(() {
        _uploadedVinImageUrl = downloadURLVin;
      });

      await FirebaseFirestore.instance.collection('Individual').doc(userId).set({
        'vinImageUrl': downloadURLVin
      }, SetOptions(merge: true));

      print("Image uploaded successfully: $downloadURLVin");
    } catch (e) {
      print('Error uploading image: $e');
    }
  }


  TextEditingController countryCont = TextEditingController();
  TextEditingController stateCont = TextEditingController();
  TextEditingController cityCont = TextEditingController();
  TextEditingController groupCont = TextEditingController();
  TextEditingController ownerCont = TextEditingController();
  TextEditingController cordCont = TextEditingController();
  TextEditingController gAddressCont = TextEditingController();
  TextEditingController mNameCont = TextEditingController();
  TextEditingController mAddressCont = TextEditingController();
  TextEditingController ageCont = TextEditingController();
  TextEditingController unitCont = TextEditingController();
  TextEditingController villageCont = TextEditingController();
  TextEditingController wardCont = TextEditingController();
  TextEditingController phoneCont = TextEditingController();
  TextEditingController vinCont = TextEditingController();
  TextEditingController vinIdCont = TextEditingController();

  void _clearForm() {
    vinCont.clear();
    ownerCont.clear();
    groupCont.clear();
    cordCont.clear();
    unitCont.clear();
    villageCont.clear();
    wardCont.clear();
    countryCont.clear();
    stateCont.clear();
    cityCont.clear();
    mNameCont.clear();
    ageCont.clear();
    mAddressCont.clear();
    gAddressCont.clear();
    phoneCont.clear();
  }


  bool _isChecked = false;
  bool _isChecked1 = false;
  bool _isChecked2 = false;
  bool _isChecked3 = false;
  bool _isChecked4 = false;
  bool _isChecked5 = false;
  bool _isChecked6 = false;
  bool _isChecked7 = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.green,
        title: const Text(
          'Register as Group', style: TextStyle(color: Colors.white),),),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8.0),
              children: <Widget>[
                const SizedBox(height: 10.0,),
                FormBuilderTextField(
                  name: 'Group Name',
                  controller: groupCont,
                  decoration: const InputDecoration(
                      labelText: 'Group Name',
                      border: OutlineInputBorder()
                  ),
                ),
                Text('* required', style: TextStyle(color: Colors.red),),
                const SizedBox(height: 10.0,),
                FormBuilderTextField(
                  name: 'Owner name',
                  controller: ownerCont,
                  decoration: const InputDecoration(
                      labelText: 'Group Owner Name',
                      border: OutlineInputBorder()
                  ),
                ),
                Text('* required', style: TextStyle(color: Colors.red),),
                const SizedBox(height: 10.0,),
                FormBuilderTextField(
                  name: 'coordinator name',
                  controller: cordCont,
                  decoration: const InputDecoration(
                      labelText: 'Group Coordinator Name',
                      border: OutlineInputBorder()
                  ),
                ),
                const SizedBox(height: 10.0,),
                FormBuilderTextField(
                  name: 'Group address',
                  controller: gAddressCont,
                  decoration: const InputDecoration(
                      labelText: 'Group Address',
                      border: OutlineInputBorder()
                  ),
                ),
                const SizedBox(height: 10.0,),
                FormBuilderTextField(
                  name: 'Member Name',
                  controller: mNameCont,
                  decoration: const InputDecoration(
                      labelText: 'Name of Member',
                      border: OutlineInputBorder()
                  ),),
                Text('* required', style: TextStyle(color: Colors.red),),
                const SizedBox(height: 10.0,),
                FormBuilderTextField(
                  name: 'Member Address',
                  controller: mAddressCont,
                  decoration: const InputDecoration(
                      labelText: 'Member Address',
                      border: OutlineInputBorder()
                  ),
                ),
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
                SizedBox(height: 10,),
                const SizedBox(height: 10.0,),
                FormBuilderTextField(
                  name: 'Age',
                  controller: ageCont,
                  decoration: const InputDecoration(
                      labelText: 'age',
                      border: OutlineInputBorder()
                  ),),
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
                  controller: vinIdCont,
                  name: 'Voter Identifier',
                  decoration: const InputDecoration(
                      labelText: 'Voter Identifier Name e.g (VIN)',
                      border: OutlineInputBorder()
                  ),
                ),
                Text('* required', style: TextStyle(color: Colors.red),),
                const SizedBox(height: 10,),
                FormBuilderTextField(
                  name: 'VIN',
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
                      hintText: 'Upload Voter Card',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.upload),
                        onPressed: (){
                          _selectVinImage(context);
                        }
                      ),
                  suffix: _vinImagePath != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.file(
                      File(_vinImagePath!),
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  )
                      : null,
                ),
            readOnly: true,
                ),
                Text('* required', style: TextStyle(color: Colors.red),),
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
                  controller: phoneCont,
                  name: 'Phone Number',
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder()
                  ),),
                Text('* required', style: TextStyle(color: Colors.red),),
                const SizedBox(height: 10,),
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
                const SizedBox(height: 10,),
                FormBuilderTextField(
                  name: 'Upload Passport',
                  decoration: InputDecoration(
                      labelText: 'Upload passport',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.upload),
                        onPressed: (){
                          _selectImageMember(context);
                        }
                      ),
                    suffix: _imagePathMember != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.file(
                        File(_imagePathMember!),
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    )
                        : null,
                  ),
                  readOnly: true,
                ),
                Text('* required', style: TextStyle(color: Colors.red),),
                const SizedBox(height: 10,),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Colors.green)
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel', style: TextStyle(
                            color: Colors.blueAccent),),),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          onPressed: isLoading
                              ? null : () async {
                            setState(() {
                              isLoading = true;
                            });
                            try {
                              // Convert all entered principal names into a Map<String, String>
                              Map<String, String> selectedPrincipals = {};

                              for (String role in principalRoles) {
                                String name = principalControllers[role]!.text.trim();
                                if (name.isNotEmpty) {
                                  selectedPrincipals[role] = name;
                                }
                              }

                              await submitGroupData(context, groupCont.text.toString(), ownerCont.text.toString(), cordCont.text.toString(), gAddressCont.text.toString(),
                                mNameCont.text.toString(), mAddressCont.text.toString(), selectedValue!, ageCont.text.toString(),
                                unitCont.text.toString(), villageCont.text.toString(), wardCont.text.toString(),
                                countryCont.text.toString(), stateCont.text.toString(),
                                cityCont.text.toString(), vinIdCont.text.toString(), vinCont.text.toString(), _vinImagePath.toString(), phoneCont.text.toString(), getFormData(), _imagePathMember.toString()
                              );
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (
                                  context) => const HomeScreen()));
                              _clearForm();
                            } catch (error){

                            } finally{
                              setState(() {
                                isLoading = false;
                              });
                            }
                            },
                          child: isLoading
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

Future<void> submitGroupData(BuildContext context, String groupNameValue, String ownerValue, String coordinatorValue, String g_addressValue,
    String memberNameValue, String m_addressValue, String genderValue, String ageValue, String unitValue, String villageValue,
    String wardValue, String countryValue, String stateValue, String lgaValue, String vinIdentify, String vinValue, String vinImageUrl, String phoneValue,
    Map<String, String> selectedPrincipals, String memberImageValue) async {


  User? user = FirebaseAuth.instance.currentUser;
  final String fullNameValue = memberNameValue.trim().replaceAll(" ", "_");


  if (user != null) {
    final principals = FirebaseFirestore.instance.collection('principals').doc(user.uid).collection('members');
    final groupCollection = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('Groups');
    final groupNameCollection = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('Group Name');
    final vinQuerySnapshot = await groupCollection.where('Vin', isEqualTo: vinValue).get();
    if (vinQuerySnapshot.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('The VIN is already used!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if ( groupNameValue.isEmpty || wardValue.isEmpty || unitValue.isEmpty || lgaValue.isEmpty
        || ownerValue.isEmpty || phoneValue.isEmpty || stateValue.isEmpty
        || memberNameValue.isEmpty || ageValue.isEmpty || countryValue.isEmpty
        || coordinatorValue.isEmpty || vinImageUrl.isEmpty || memberImageValue.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You have omitted a required field!'),
          backgroundColor: Colors.red,
        ),
      );
    }

    final vinDoc = await FirebaseHelper.vinRecords.doc(vinValue).get();
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
    String? memberImage;

    // 🔹 Ensure VIN image is compulsory
    vinImageURL = await uploadFileToFirebase(
      vinImageUrl, // ✅ Fix: Pass file path
      'groupVinImages/${memberNameValue.trim().replaceAll(" ", "_")}.jpg',
    );

    // 🔹 Ensure Profile image is compulsory
    memberImage = await uploadFileToFirebase(
      memberImageValue, // ✅ Fix: Pass file path
      'memberImages/${memberNameValue.trim().replaceAll(" ", "_")}.jpg',
    );


    try {

      // Loop through each principal and save member data
      for (var entry in selectedPrincipals.entries) {
        String principalRole = entry.key; // e.g., "President"
        String principalName = entry.value;

        await FirebaseFirestore.instance.runTransaction((transaction) async {
          // Add VIN to vinRecords collection
          transaction.set(FirebaseHelper.vinRecords.doc(vinValue), {
            'timestamp': FieldValue.serverTimestamp(),
          });

          // Add user data to their personal collection
          transaction.set(groupCollection.doc(), {
            'Group Name': groupNameValue,
            'count': 1,
            'Owner Name': ownerValue,
            'Coordinator': coordinatorValue,
            'Group Address': g_addressValue,
            'Member Name': memberNameValue,
            'Member Address': m_addressValue,
            'Gender': genderValue,
            'Age': ageValue,
            'Unit': unitValue,
            'Village': villageValue,
            'Ward': wardValue,
            'Country': countryValue,
            'State': stateValue,
            'LGA': lgaValue,
            'Vin Identifier': vinIdentify,
            'Vin': vinValue,
            'vinImageUrl': vinImageUrl,
            'Phone Number': phoneValue,
            'Principal Role': principalRole,
            'Principal Name': principalName,
            'memberImage': memberImageValue,
            'timestamp': FieldValue.serverTimestamp(),
          });

          transaction.set(principals.doc(), {
            'Group Name': groupNameValue,
            'count': 1,
            'Owner Name': ownerValue,
            'Coordinator': coordinatorValue,
            'Group Address': g_addressValue,
            'Member Name': memberNameValue,
            'Member Address': m_addressValue,
            'Gender': genderValue,
            'Age': ageValue,
            'Unit': unitValue,
            'Village': villageValue,
            'Ward': wardValue,
            'Country': countryValue,
            'State': stateValue,
            'LGA': lgaValue,
            'Vin': vinValue,
            'vinImageUrl': vinImageUrl,
            'Phone Number': phoneValue,
            'Principal Role': principalRole,
            'Principal Name': principalName,
            'memberImage': memberImageValue,
            'timestamp': FieldValue.serverTimestamp(),

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

    final groupQuerySnapshot = await groupCollection.where('Group Name', isEqualTo: groupNameValue).get();
    if (groupQuerySnapshot.docs.isNotEmpty) {
      // Increment 'count' for existing Upline
      final docId = groupQuerySnapshot.docs.first.id;
      await groupCollection.doc(docId).update({
        'count': FieldValue.increment(1),
      });
    } else {
      // Add new entry
      await groupCollection.add({
        'Group Name': groupNameValue,
        'count': 1,
        'Owner Name': ownerValue,
        'Coordinator': coordinatorValue,
        'Group Address': g_addressValue,
        'Member Name': memberNameValue,
        'Member Address': m_addressValue,
        'Gender': genderValue,
        'Age': ageValue,
        'Unit': unitValue,
        'Village': villageValue,
        'Ward': wardValue,
        'Country': countryValue,
        'State': stateValue,
        'LGA': lgaValue,
        'Vin': vinValue,
        'vinImageUrl': vinImageUrl,
        'Phone Number': phoneValue,
        'memberImage': memberImageValue,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

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
