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
import '../service/auth_service.dart';
import 'home_screen.dart';


class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  List<String> projectOptions = ['Presidency','Governorship', 'Senate',
    'House of Representatives', 'House of Assembly', 'Chairmanship', 'Councillorship', 'Other'];


  bool _isUploading = false;

  String? selectedValue;
  List<String> genderOptions = ['Male', 'Female'];

  TextEditingController countryCont = TextEditingController();
  TextEditingController stateCont = TextEditingController();
  TextEditingController cityCont = TextEditingController();
  TextEditingController nameCont = TextEditingController();
  TextEditingController projectCont = TextEditingController();
  TextEditingController otherCont = TextEditingController();
  TextEditingController officeCont = TextEditingController();
  TextEditingController senateCont = TextEditingController();
  TextEditingController constCont = TextEditingController();
  TextEditingController wardCont = TextEditingController();
  TextEditingController phoneCont = TextEditingController();

  String? _photoPath;
  String? _uploadedPhotoUrl;

  Future<void> _selectImagePrincipal(BuildContext context) async {
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
                    _photoPath = imageFile!.path;
                  });
                  final AuthService _signInService = AuthService();
                  String userId = _signInService.getCurrentUserID(); // Replace with actual user ID retrieval logic
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
                    _photoPath = imageFile!.path;
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
      final downloadURLPro = await storageRef.getDownloadURL();

      setState(() {
        _uploadedPhotoUrl = downloadURLPro;
      });

      await FirebaseFirestore.instance.collection('principals').doc(userId).set({
        'PhotoUrl': downloadURLPro
      }, SetOptions(merge: true));

      print("Image uploaded successfully: $downloadURLPro");
    } catch (e) {
      print('Error uploading image: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('Create Project', style: TextStyle(color: Colors.white),),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
              child: ListView(
                padding: EdgeInsets.all(8.0),
                children: <Widget>[
                  Card(
                    elevation: 4,
                    color: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    margin: EdgeInsets.only(bottom: 12),
                    child: Text('All the offices can equally be replaced by its equivalent.', style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),),
                  ),
                  FormBuilderTextField(
                    name: 'Name',
                    controller: nameCont,
                    decoration: InputDecoration(
                        labelText: 'Enter your name',
                        border: OutlineInputBorder()
                    ),),
                  SizedBox(height: 10,),
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
                      if (value != null){
                        selectedValue = value;
                      }
                    },
                  ),
                  SizedBox(height: 10,),
                  DropdownButtonFormField(
                    value: selectedValue,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Select Office'
                    ),
                    items: projectOptions.map((String item){
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
                  FormBuilderTextField(
                    controller: otherCont,
                    name: 'Other office',
                    decoration: InputDecoration(
                        labelText: 'Enter Office (Optional for other)',
                        border: OutlineInputBorder()
                    ),),
                  SizedBox(height: 10,),
                  CountryStateCityPicker(
                    country: countryCont,
                    state: stateCont,
                    city: cityCont,
                    textFieldDecoration: InputDecoration(
                        suffixIcon: Icon(Icons.arrow_drop_down_circle_outlined),
                        border: OutlineInputBorder()
                    ),
                  ),
                  SizedBox(height: 10,),
                  FormBuilderTextField(
                    name: 'Project Name',
                    controller: projectCont,
                    decoration: InputDecoration(
                        labelText: 'Enter Project Name',
                        border: OutlineInputBorder()
                    ),),
                  SizedBox(height: 10,),
                  FormBuilderTextField(
                    name: 'Senatorial District',
                    controller: senateCont,
                    decoration: InputDecoration(
                        labelText: 'Enter Senatorial District',
                        border: OutlineInputBorder()
                    ),),
                  SizedBox(height: 10,),
                  FormBuilderTextField(
                    name: 'Constituency Name',
                    controller: constCont,
                    decoration: InputDecoration(
                        labelText: 'Enter Constituency',
                        border: OutlineInputBorder()
                    ),),
                  SizedBox(height: 10,),
                  FormBuilderTextField(
                    name: 'Ward',
                    controller: wardCont,
                    decoration: InputDecoration(
                        labelText: 'Enter Ward',
                        border: OutlineInputBorder()
                    ),),
                  SizedBox(height: 10,),
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
                    name: 'Picture',
                    decoration: InputDecoration(
                      labelText: 'Upload Profile Photo',
                      suffixIcon: IconButton(
                          onPressed: (){
                            _selectImagePrincipal(context);
                          },
                          icon: Icon(Icons.upload)
                      ),
                      suffix: _photoPath != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.file(
                          File(_photoPath!),
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
                  SizedBox(height: 10,),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green
                      ),
                      onPressed: _isUploading ? null
                          : () async {
                        setState(() {
                          _isUploading = true;
                        });
                        try{
                          await addPrincipal(nameCont.text.toString(), selectedValue!, projectCont.text.toString(), otherCont.text.toString(), countryCont.text.toString(),
                              stateCont.text.toString(), cityCont.text.toString(),
                              senateCont.text.toString(), constCont.text.toString(),
                              wardCont.text.toString(), officeCont.text.toString(), phoneCont.text.toString(), _photoPath.toString()
                          );
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (
                              context) => const HomeScreen()));
                        }catch (error){

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
                          : const Text('Create', style: TextStyle(color: Colors.white),))
                ],
              ))
        ],
      ),
    );
  }
  Future<void> addPrincipal(
      String name,
      String genderValue,
      String office,
      String otherValue,
      String country,
      String state,
      String city,
      String projectName,
      String senatorialDistrict,
      String constName,
      String ward,
      String phoneNumber,
      String profilePicture,) async {

    User? user = FirebaseAuth.instance.currentUser;
    final String fullNameValue = name.trim().replaceAll(" ", "_");

    if (user != null) {
      final principalRef = FirebaseFirestore.instance
          .collection('principals')
          .doc(user.uid)
          .collection('principalData')
          .doc('profile');

// ✅ Check if the document already exists
      final docSnapshot = await principalRef.get();

      if (docSnapshot.exists && docSnapshot.data()?['name'] == name) {
        // ❌ Name already exists
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('The name is already used!'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        // ✅ Store the new principal data
        await principalRef.set({
          'name': name,
          'Gender': genderValue,
          'office': office,
          'other': otherValue,
          'country': country,
          'state': state,
          'city': city,
          'project name': projectName,
          'senatorial district': senatorialDistrict,
          'ward': ward,
          'phone number': phoneNumber,
          'PhotoUrl': profilePicture
        });

        print("✅ Principal data added successfully!");
      }

      String? vinImageURL;
      String? memberImage;

      // 🔹 Ensure VIN image is compulsory
      vinImageURL = await uploadFileToFirebase(
        profilePicture, // ✅ Fix: Pass file path
        'groupVinImages/${name.trim().replaceAll(" ", "_")}.jpg',
      );


      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Created Successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      return;
    }
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


