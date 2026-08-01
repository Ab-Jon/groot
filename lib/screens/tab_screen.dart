import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:groot/registration/register_screen.dart';
import 'package:rxdart/rxdart.dart';

class TabulateScreen extends StatefulWidget {
  const TabulateScreen({super.key});

  @override
  State<TabulateScreen> createState() => _TabulateScreenState();
}

class _TabulateScreenState extends State<TabulateScreen> with SingleTickerProviderStateMixin{

  String? userRole;
  TabController? _tabController;
  bool _isLoading = true;
  String? loggedInPrincipal;
  late BehaviorSubject<QuerySnapshot> principalMembersSubject;
  late BehaviorSubject<QuerySnapshot> principalFollowersSubject;
  User? user = FirebaseAuth.instance.currentUser;
  String? state;


  // Fetch the tabs based on the role selected.
  Future<void> _fetchUserRole() async {
    User? user = FirebaseAuth.instance.currentUser;
    if(user != null){
      try {
        final userDoc = await FirebaseFirestore
            .instance
            .collection('users')
            .doc(user.uid).get();

        if (userDoc.exists) {
          setState(() {
            userRole = userDoc.get('Role');
            int tabCount = (userRole == 'Principal')? 11
                : (userRole == 'Up-line') ? 4
                : 5;
            _tabController = TabController(
                length: tabCount,
                vsync: this);
            _isLoading = false;
          });
        } else {
          setState(() {
            userRole = null;
            _isLoading = false;
          });
        }
      }catch (e){
        setState(() {
          _isLoading = false;
        });
        print("Error fetching....:$e");
      }
    }
  }

  Future<void> fetchPrincipalName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // ✅ Fetch from fixed 'profile' document
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('principals')
          .doc(user.uid)
          .collection('principalData')
          .doc('profile') // ✅ Always fetch from 'profile'
          .get();

      if (userDoc.exists) {
        String? principalName = userDoc.get('name');

        if (principalName != null) {
          print("✅ Principal Name Fetched: $principalName");

          setState(() {
            loggedInPrincipal = principalName;
          });

          // ✅ Now start the members stream
          startListeningToMembers();
        }
      } else {
        print("❌ No principalData found for UID: ${user.uid}");
      }
    } catch (e) {
      print("Error fetching principal name: $e");
    }
  }

  Stream<QuerySnapshot> getPrincipalMembers() {
    if (loggedInPrincipal == null) {
      print("⚠️ Attempted to fetch members before setting loggedInPrincipal!");
      return Stream.empty();
    }
    print("🔍 Fetching members where 'Principal Name' = $loggedInPrincipal");

    return FirebaseFirestore.instance
        .collectionGroup('members')
        .where('Principal Name', isEqualTo: loggedInPrincipal) // ✅ Ensure this field exists
        .snapshots()
        .asBroadcastStream();
  }

  Future<void> fetchPrincipalNameForFollowers() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // ✅ Fetch from fixed 'profile' document
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('principals')
          .doc(user.uid)
          .collection('principalData')
          .doc('profile') // ✅ Always fetch from 'profile'
          .get();

      if (userDoc.exists) {
        String? principalName = userDoc.get('name');

        if (principalName != null) {
          print("✅ Principal Name Fetched: $principalName");

          setState(() {
            loggedInPrincipal = principalName;
          });

          // ✅ Now start the members stream
          startListeningToFollowers();
        }
      } else {
        print("❌ No principalData found for UID: ${user.uid}");
      }
    } catch (e) {
      print("Error fetching principal name: $e");
    }
  }

  Stream<QuerySnapshot> getPrincipalFollowers() {
    if (loggedInPrincipal == null) {
      print("⚠️ Attempted to fetch members before setting loggedInPrincipal!");
      return Stream.empty();
    }
    print("🔍 Fetching followers where 'Principal Name' = $loggedInPrincipal");

    return FirebaseFirestore.instance
        .collectionGroup('followers')
        .where('Principal Name', isEqualTo: loggedInPrincipal) // ✅ Ensure this field exists
        .snapshots()
        .asBroadcastStream();
  }


  Stream<Map<String, int>> getStateCounts() {
    return FirebaseFirestore.instance.collectionGroup('members').where('Principal Name', isEqualTo: loggedInPrincipal).snapshots().map((snapshot) {
      Map<String, int> stateCounts = {};

      for (var doc in snapshot.docs) {
        String state = doc['State'] ?? 'Unknown';

        if (stateCounts.containsKey(state)) {
          stateCounts[state] = stateCounts[state]! + 1; // Increment count
        } else {
          stateCounts[state] = 1; // First occurrence
        }
      }
      return stateCounts;
    });
  }
  Stream<Map<String, int>> getStateCountsFollowers() {
    return FirebaseFirestore.instance.collectionGroup('followers').where('Principal Name', isEqualTo: loggedInPrincipal).snapshots().map((snapshot) {
      Map<String, int> stateCounts = {};

      for (var doc in snapshot.docs) {
        String state = doc['State'] ?? 'Unknown';

        if (stateCounts.containsKey(state)) {
          stateCounts[state] = stateCounts[state]! + 1; // Increment count
        } else {
          stateCounts[state] = 1; // First occurrence
        }
      }
      return stateCounts;
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 11, vsync: this);
    _fetchUserRole();

    principalFollowersSubject = BehaviorSubject<QuerySnapshot>();
    // ✅ Fetch principal name first, then fetch members
    fetchPrincipalNameForFollowers();

    principalMembersSubject = BehaviorSubject<QuerySnapshot>();
    // ✅ Fetch principal name first, then fetch members
    fetchPrincipalName();
  }

  void startListeningToFollowers() {
    print("🔄 Listening to Principal Followers Stream...");

    getPrincipalFollowers().listen((snapshot) {
      print("📡 New Data Received: ${snapshot.docs.length} members");
      principalFollowersSubject.add(snapshot);
    });
  }

  void startListeningToMembers() {
    print("🔄 Listening to Principal Members Stream...");

    getPrincipalMembers().listen((snapshot) {
      print("📡 New Data Received: ${snapshot.docs.length} members");
      principalMembersSubject.add(snapshot);
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }


  // This is the query for the up - line, down line and coordinators tab
  Stream<QuerySnapshot> getUpData (){
    User? user = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('data')
        .orderBy('count', descending: true)
        .snapshots();
  }

  // This is the query for the ward (Individual) tab
  Stream<QuerySnapshot> getWardData (){
    User? user = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('wards')
        .orderBy('count', descending: true)
        .snapshots();
  }

  // This is the query for the LGA (Individual) tab
  Stream<QuerySnapshot> getLGAData (){
    User? user = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('LGAs')
        .orderBy('count', descending: true)
        .snapshots();
  }

  // This is the query for the State (Individual) tab
  Stream<QuerySnapshot> getStateData (){
    User? user = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('state')
        .orderBy('count', descending: true)
        .snapshots();
  }

  // This is the query for the group name and group member tab
  Stream<QuerySnapshot> getGroupData(){
    print("📡 getGroupData() called!");
    User? user = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('Groups')
        .orderBy('count', descending: true)
        .snapshots();
  }

  // This is the query for the ward (Group) tab
  Stream<QuerySnapshot> getGroupWardData (){
    User? user = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('Groups')
        .orderBy('count', descending: true)
        .snapshots();
  }

  // This is the query for the LGA (Group) tab
  Stream<QuerySnapshot> getGroupLGAData (){
    User? user = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('Groups')
        .orderBy('count', descending: true)
        .snapshots();
  }

  // This is the query for the State (Group) tab
  Stream<QuerySnapshot> getGroupStateData (){
    User? user = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('Groups')
        .orderBy('count', descending: true)
        .snapshots();
  }

  Future<void> deleteUserData(String docIed) async {
    User? user = FirebaseAuth.instance.currentUser;

    try {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid).collection('up line').doc(docIed);

      await docRef.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User deleted successfully!"), backgroundColor: Colors.red),
      );
    } catch (e) {
      print("Error deleting user: $e");
    }
  }

  Future<void> updateUserData(String documentId, Map<String, dynamic> updatedData) async {
    User? user = FirebaseAuth.instance.currentUser;

    try {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('up line')
          .doc(documentId);

      await docRef.update(updatedData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User updated successfully!"), backgroundColor: Colors.green),
      );
    } catch (e) {
      print("Error updating user: $e");
    }
  }

  // Individual editing
  void showEditDialog(BuildContext context, String docId, Map<String, dynamic> data) {
    TextEditingController nameController = TextEditingController(text: data['Full Name']);
    TextEditingController ageController = TextEditingController(text: data['Age']);
    TextEditingController homeController = TextEditingController(text: data['Home Address']);
    TextEditingController residentController = TextEditingController(text: data['Residential Address']);
    TextEditingController countryController = TextEditingController(text: data['Country']);
    TextEditingController stateController = TextEditingController(text: data['State']);
    TextEditingController lgaController = TextEditingController(text: data['LGA']);
    TextEditingController phoneController = TextEditingController(text: data['Phone Number']);
    TextEditingController coordinatorController = TextEditingController(text: data['Coordinator']);
    TextEditingController unitController = TextEditingController(text: data['Unit']);
    TextEditingController villageController = TextEditingController(text: data['Village']);
    TextEditingController wardController = TextEditingController(text: data['Ward']);
    TextEditingController upLineController = TextEditingController(text: data['Up line']);
    Map<String, TextEditingController> principalControllers = {};
    data.forEach((key, value) {
      principalControllers[key] = TextEditingController(text: value.toString());
    });
    principalControllers['']?.text;
    TextEditingController occupationController = TextEditingController(text: data['Occupation']);
    TextEditingController voterIDController = TextEditingController(text: data['']);
    TextEditingController vinController = TextEditingController(text: data['']);
    TextEditingController uploadCardController = TextEditingController(text: data['']);
    TextEditingController uploadPassportController = TextEditingController(text: data['']);
    TextEditingController uploadUpController = TextEditingController(text: data['']);
    TextEditingController uploadCoController = TextEditingController(text: data['']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Data"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: "Name"),
                ),
                TextField(
                  controller: ageController,
                  decoration: InputDecoration(labelText: "Age"),
                ),
                TextField(
                  controller: homeController,
                  decoration: InputDecoration(labelText: "Home Address"),
                ),
                TextField(
                  controller: residentController,
                  decoration: InputDecoration(labelText: "Resident Address"),
                ),
                TextField(
                  controller: countryController,
                  decoration: InputDecoration(labelText: "Country"),
                ),
                TextField(
                  controller: stateController,
                  decoration: InputDecoration(labelText: "State"),
                ),
                TextField(
                  controller: lgaController,
                  decoration: InputDecoration(labelText: "City/LGA"),
                ),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: "Phone Number"),
                ),
                TextField(
                  controller: coordinatorController,
                  decoration: InputDecoration(labelText: "Coordinator"),
                ),
                TextField(
                  controller: unitController,
                  decoration: InputDecoration(labelText: "Unit"),
                ),
                TextField(
                  controller: villageController,
                  decoration: InputDecoration(labelText: "Village or Community"),
                ),
                TextField(
                  controller: wardController,
                  decoration: InputDecoration(labelText: "Ward"),
                ),
                TextField(
                  controller: upLineController,
                  decoration: InputDecoration(labelText: "Up line"),
                ),
                TextField(
                  controller: principalControllers['Principal Name'],
                  decoration: InputDecoration(
                    labelText: "Principal Name",
                  ),
                ),
                TextField(
                  controller: occupationController,
                  decoration: InputDecoration(labelText: "Occupation"),
                ),
                TextField(
                  controller: voterIDController,
                  decoration: InputDecoration(labelText: "Voter Identifier Name"),
                ),
                TextField(
                  controller: vinController,
                  decoration: InputDecoration(labelText: "Voter Identity Number"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                updateUserData(docId, {
                  'Up line': upLineController.text,
                  'Ward': wardController.text,
                  'Unit': unitController.text,
                  'Village': villageController.text,
                  'LGA': lgaController.text,
                  'Phone Number': phoneController.text,
                  'State': stateController.text,
                  'Full Name': nameController.text,
                  'Age': ageController.text,
                  'Home Address': homeController.text,
                  'Residential Address': residentController.text,
                  'Country': countryController.text,
                  'Coordinator': coordinatorController.text,
                  'Principal Role': principalControllers,
                  'Principal Name': principalControllers,
                  'Occupation': occupationController.text,
                  'timestamp': FieldValue.serverTimestamp(),
                });
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // Group editing
  void showEditDialogGroup(BuildContext context, String docId, Map<String, dynamic> data) {
    TextEditingController GNameController = TextEditingController(text: data['Group Name']);
    TextEditingController ownerController = TextEditingController(text: data['Owner Name']);
    TextEditingController coordinatorController = TextEditingController(text: data['Coordinator']);
    TextEditingController groupAddressController = TextEditingController(text: data['Group Address']);
    TextEditingController memberController = TextEditingController(text: data['Member Name']);
    TextEditingController memberAddressController = TextEditingController(text: data['Member Address']);
    TextEditingController ageController = TextEditingController(text: data['Age']);
    TextEditingController unitController = TextEditingController(text: data['Unit']);
    TextEditingController villageController = TextEditingController(text: data['Village']);
    TextEditingController wardController = TextEditingController(text: data['Ward']);
    TextEditingController countryController = TextEditingController(text: data['Country']);
    TextEditingController stateController = TextEditingController(text: data['State']);
    TextEditingController lgaController = TextEditingController(text: data['LGA']);
    TextEditingController phoneController = TextEditingController(text: data['Phone Number']);
    Map<String, TextEditingController> principalControllers = {};
    data.forEach((key, value) {
      principalControllers[key] = TextEditingController(text: value.toString());
    });
    principalControllers['']?.text;


    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Data"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: GNameController,
                  decoration: InputDecoration(labelText: "Group Name"),
                ),
                TextField(
                  controller: ownerController,
                  decoration: InputDecoration(labelText: "Owner Name"),
                ),
                TextField(
                  controller: coordinatorController,
                  decoration: InputDecoration(labelText: "Coordinator Name"),
                ),
                TextField(
                  controller: groupAddressController,
                  decoration: InputDecoration(labelText: "Group Address"),
                ),
                TextField(
                  controller: memberController,
                  decoration: InputDecoration(labelText: "Member Name"),
                ),
                TextField(
                  controller: memberAddressController,
                  decoration: InputDecoration(labelText: "Member Address"),
                ),
                TextField(
                  controller: ageController,
                  decoration: InputDecoration(labelText: "Age"),
                ),
                TextField(
                  controller: unitController,
                  decoration: InputDecoration(labelText: "Unit"),
                ),
                TextField(
                  controller: villageController,
                  decoration: InputDecoration(labelText: "Village or Community"),
                ),
                TextField(
                  controller: wardController,
                  decoration: InputDecoration(labelText: "Ward"),
                ),
                TextField(
                  controller: countryController,
                  decoration: InputDecoration(labelText: "Country"),
                ),
                TextField(
                  controller: stateController,
                  decoration: InputDecoration(labelText: "State"),
                ),
                TextField(
                  controller: lgaController,
                  decoration: InputDecoration(labelText: "City/LGA"),
                ),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: "Phone Number"),
                ),
                TextField(
                  controller: principalControllers['Principal Name'],
                  decoration: InputDecoration(
                    labelText: "Principal Name",
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                updateUserData(docId, {
                  'Group Name': GNameController.text,
                  'Owner Name': ownerController.text,
                  'Coordinator': coordinatorController.text,
                  'Group Address': groupAddressController.text,
                  'Member Name': memberController.text,
                  'Member Address': memberAddressController.text,
                  'Age': ageController.text,
                  'Unit': unitController.text,
                  'Village': villageController.text,
                  'Ward': wardController.text,
                  'Country': countryController.text,
                  'State': stateController.text,
                  'LGA': lgaController.text,
                  'Phone Number': phoneController.text,
                  'Principal Role': principalControllers,
                  'Principal Name': principalControllers,
                });
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }



  // These are the tabs
  final List<String> _tabs = ['Up-line', 'Down-line', 'Coordinators', 'Groups',
    'Group Members', 'Wards (Groups)', 'LGA (Group) ', 'State (Group)',
    'Ward (Individual)', 'LGA (Individual)', 'State (Individual)'];


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: _tabs.length,
        child: Scaffold(
          appBar: AppBar(
              automaticallyImplyLeading: false,
              title: _isLoading ? Center(child: CircularProgressIndicator(),)
                  : userRole == null
                  ? Center(child: Text('No role assigned'),)
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TabBar(
                    isScrollable: true,
                    tabs: userRole == 'Principal'
                        ? [
                      Tab(child: Text('Up-line')),
                      Tab(child: Text('Down-line')),
                      Tab(child: Text('Coordinators')),
                      Tab(child: Text('Groups')),
                      Tab(child: Text('Group Members')),
                      Tab(child: Text('Wards (Groups)')),
                      Tab(child: Text('LGA (Group)')),
                      Tab(child: Text('State (Group)')),
                      Tab(child: Text('Wards (Individual)')),
                      Tab(child: Text('LGA (Individual)')),
                      Tab(child: Text('State (Individual)')),
                    ] : userRole == 'Up-line'
                        ? [
                      Tab(child: Text('Down-line')),
                      Tab(child: Text('Wards (Individual)')),
                      Tab(child: Text('LGA (Individual)')),
                      Tab(child: Text('State (Individual)')),
                    ] : userRole == 'Group'
                        ? [
                      Tab(child: Text('Group')),
                      Tab(child: Text('Group Members')),
                      Tab(child: Text('Wards (Group)')),
                      Tab(child: Text('LGA (Group)')),
                      Tab(child: Text('State (Group)')),
                    ] : [],
                    labelStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              )
          ),
          body: _isLoading? Center(child: CircularProgressIndicator(),)
              : userRole == null? Center(child: Text('No role assigned'),)
              :Padding(
            padding: EdgeInsets.all(8.0),
            child: TabBarView(
                children: userRole! == 'Principal'?
                [
                  // Up-line tab
                  StreamBuilder(
                      stream: principalFollowersSubject.stream,
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
                        if (snapshot.hasData) {
                          var upLineUser = snapshot.data!.docs;
                          if (upLineUser.isEmpty) {
                            return Center(child: Text('No data Found'),);
                          }
                          return ListView.builder(
                              itemCount: upLineUser.length,
                              itemBuilder: (context, index) {
                                var upData = upLineUser[index].data() as Map<String, dynamic>;
                                final upUrl = upData['upImageUrl'] as String?;
                                return Column(
                                  children: [
                                    ListTile(
                                      title: Text(upData['Up line'] ?? '', style: TextStyle(
                                          fontSize: 15, fontWeight: FontWeight.bold),),
                                      trailing:  GestureDetector(
                                        onTap: (){
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                child: Container(
                                                  width: 300, // Define the width
                                                  height: 300, // Define the height
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image: upUrl != null
                                                          ? NetworkImage(upUrl)
                                                          : AssetImage('assets/placeholder.png') as ImageProvider,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          );

                                        },
                                        child: CircleAvatar(
                                          radius: 65,
                                          backgroundImage: upUrl != null
                                              ? NetworkImage(upUrl) // Use NetworkImage for online images
                                              : AssetImage('assets/placeholder.png') as ImageProvider,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Unit: ${upData['Unit'] ?? ''}'),
                                          Text('Ward: ${upData['Ward'] ?? ''}'),
                                          Text('City: ${upData['LGA'] ?? ''}'),
                                          Text('State: ${upData['State'] ?? ''}'),
                                          Text('Phone Number: ${upData['Phone Number'] ??''}'),
                                          Text('Down lines: ${upData['count'] ?? 0}'),
                                        ],
                                      ),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          side: BorderSide(width: 1)
                                      ),
                                    ),
                                    SizedBox(height: 10,)
                                  ],
                                );
                              });
                        } else if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else {
                          return Center(child: Text("Error: ${snapshot.error}"));
                        }
                      }
                  ),
                  //down-line tab
                  StreamBuilder(
                    stream: principalFollowersSubject.stream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        // Print error to the console for debugging
                        debugPrint("Firestore Stream Error: ${snapshot.error}");
                      }

                      if (snapshot.hasData) {
                        var submit = snapshot.data!.docs;
                        if (submit.isEmpty) {
                          return Center(child: Text('No data Found'));
                        }
                        return ListView.builder(
                          itemCount: submit.length,
                          itemBuilder: (context, index) {
                            var data = submit[index].data() as Map<String, dynamic>;
                            var userData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                            var docId = snapshot.data!.docs[index].id;  // Gets Firestore document ID
                            final imageUrl = data['profileImageUrl'] as String?;
                            return Column(
                              children: [
                                ListTile(
                                  title: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                child: Container(
                                                  width: 300,
                                                  height: 300,
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image: (imageUrl != null && imageUrl.isNotEmpty)
                                                          ? NetworkImage(imageUrl) as ImageProvider:
                                                      AssetImage('assets/placeholder.png'),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: CircleAvatar(
                                          radius: 30,
                                          backgroundImage: imageUrl != null
                                              ? NetworkImage(imageUrl) // Fixed image reference
                                              : AssetImage('assets/placeholder.png') as ImageProvider,
                                        ),
                                      ),
                                      const SizedBox(width: 145.0,),
                                      IconButton(
                                        icon: Icon(Icons.delete, color: Colors.red),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text("Confirm Deletion"),
                                                content: Text("Are you sure you want to delete this entry?"),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context),
                                                    child: Text("Cancel"),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      deleteUserData(docId); // Fixed docId reference
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text("Delete", style: TextStyle(color: Colors.red)),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['Full Name'] ?? '',
                                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                      ),
                                      Text('Unit: ${data['Unit'] ?? ''}'),
                                      Text('Community: ${data['Village'] ?? ''}'),
                                      Text('Ward: ${data['Ward'] ?? ''}'),
                                      Text('City: ${data['LGA'] ?? ''}'),
                                      Text('State: ${data['State'] ?? ''}'),
                                      Text('Phone: ${data['Phone Number'] ?? ''}'),
                                    ],
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(width: 1),
                                  ),
                                ),
                                SizedBox(height: 10),
                              ],
                            );
                          },
                        );
                      } else if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      }
                    },
                  ),

                  //coordinator tab
                  StreamBuilder(
                      stream: principalFollowersSubject.stream,
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
                        if (snapshot.hasData) {
                          var coordinatorUser = snapshot.data!.docs;
                          if (coordinatorUser.isEmpty) {
                            return Center(child: Text('No data found'),);
                          }
                          return ListView.builder(
                              itemCount: coordinatorUser.length,
                              itemBuilder: (context, index) {
                                var coData = coordinatorUser[index].data() as Map<String, dynamic>;
                                final coUrl = coData['coImageUrl'] as String?;
                                return Column(
                                  children: [
                                    ListTile(
                                      title: Text(coData['Coordinator'] ?? '',
                                        style: TextStyle(
                                            fontSize: 15, fontWeight: FontWeight.bold),),
                                      trailing: GestureDetector(
                                        onTap: (){
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                child: Container(
                                                  width: 300, // Define the width
                                                  height: 300, // Define the height
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image: coUrl != null
                                                          ? NetworkImage(coUrl)
                                                          : AssetImage('assets/placeholder.png') as ImageProvider,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          );

                                        },
                                        child: CircleAvatar(
                                          radius: 65,
                                          backgroundImage: coUrl != null
                                              ? NetworkImage(coUrl) // Use NetworkImage for online images
                                              : AssetImage('assets/placeholder.png') as ImageProvider,
                                        ),
                                      ),
                                      subtitle: SizedBox(
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Unit: ${coData['Unit'] ?? ''}'),
                                              SizedBox(width: 1,),
                                              Text('Ward: ${coData['Ward'] ?? ''}'),
                                              SizedBox(width: 1,),
                                              Text('City: ${coData['LGA'] ?? ''}'),
                                              SizedBox(width: 1,),
                                              Text('State: ${coData['State'] ?? ''}'),
                                              SizedBox(width: 1,),
                                            ]),
                                      ),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          side: BorderSide(width: 1)
                                      ),
                                    ),
                                    SizedBox(height: 10,)
                                  ],
                                );
                              });
                        } else if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else {
                          return Center(child: Text("Error: ${snapshot.error}"));
                        }
                      }
                  ),
                  //Group name tab
                  StreamBuilder(
                      stream: principalMembersSubject.stream,
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
                        if (snapshot.hasData) {
                          var groupUser = snapshot.data!.docs;
                          if (groupUser.isEmpty) {
                            return Center(child: Text('No User found.'),);
                          }
                          return ListView.builder(
                              itemCount: groupUser.length,
                              itemBuilder: (context, index) {
                                var groupData = groupUser[index].data() as Map<String, dynamic>;
                                return Column(
                                  children: [
                                    ListTile(
                                      title: Text(groupData['Group Name'] ?? '',
                                        style: TextStyle(fontSize: 15,
                                            fontWeight: FontWeight.bold),),
                                      subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(width: 1,),
                                            Text('Name: ${groupData['Owner Name'] ?? ''}'),
                                            Text('Unit: ${groupData['Unit'] ?? ''}'),
                                            SizedBox(width: 1,),
                                            Text('Ward: ${groupData['Ward'] ?? ''}'),
                                            SizedBox(width: 1,),
                                            Text('LGA: ${groupData['LGA'] ?? ''}'),
                                            SizedBox(width: 1,),
                                            Text('State: ${groupData['State'] ?? ''}'),
                                            SizedBox(width: 1,),
                                            Text('Phone Number: ${groupData['Phone Number'] ?? ''}'),
                                            SizedBox(width: 1,),
                                          ],
                                        ),
                                      trailing: Text('Members: ${groupData['count'] ?? ''}'),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          side: BorderSide(width: 1)
                                      ),
                                    ),
                                    SizedBox(height: 10,)
                                  ],
                                );
                              });
                        } else if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else {
                          return Center(child: Text("Error: ${snapshot.error}"));
                        }
                      }
                  ),
                  // Group member tab
                  StreamBuilder(
                      stream: principalMembersSubject.stream,
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
                        if (snapshot.hasData) {
                          var groupMember = snapshot.data!.docs;
                          if (groupMember.isEmpty) {
                            return Center(child: Text('No User found.'),);
                          }
                          return ListView.builder(
                              itemCount: groupMember.length,
                              itemBuilder: (context, index) {
                                var groupMemberData = groupMember[index].data() as Map<String, dynamic>;
                                final memberUrl = groupMemberData['memberImage'] as String?;
                                var docId = snapshot.data!.docs[index].id;
                                return Column(
                                    children: [
                                      ListTile(
                                        title: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            GestureDetector(
                                              onTap: (){
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return Dialog(
                                                      child: Container(
                                                        width: 300, // Define the width
                                                        height: 300, // Define the height
                                                        decoration: BoxDecoration(
                                                          image: DecorationImage(
                                                            fit: BoxFit.cover,
                                                            image: memberUrl != null
                                                                ? FileImage(File(memberUrl))
                                                                : AssetImage('assets/placeholder.png') as ImageProvider,
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              child: CircleAvatar(
                                                radius: 30,
                                                backgroundImage: memberUrl != null
                                                    ? FileImage(File(memberUrl)) // Use NetworkImage for online images
                                                    : AssetImage('assets/placeholder.png') as ImageProvider,
                                              ),
                                            ),
                                            const SizedBox(width: 145.0,),
                                            IconButton(
                                              icon: Icon(Icons.delete, color: Colors.red),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Text("Confirm Deletion"),
                                                      content: Text("Are you sure you want to delete this entry?"),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () => Navigator.pop(context),
                                                          child: Text("Cancel"),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            deleteUserData(docId); // Fixed docId reference
                                                            Navigator.pop(context);
                                                          },
                                                          child: Text("Delete", style: TextStyle(color: Colors.red)),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                        subtitle: SizedBox(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(width: 1,),
                                              Row(
                                                children: [
                                                  Text('Group Name: ',),
                                                  Text(groupMemberData['Group Name'] ?? '',
                                                      style: TextStyle(fontSize: 15,
                                                      fontWeight: FontWeight.bold, color: Colors.green),),
                                                ]
                                              ),
                                              Row(
                                                children:[
                                                  Text('Member Name: '),
                                                  Text(groupMemberData['Member Name'] ?? '',
                                                      style: TextStyle(fontSize: 15,
                                                      fontWeight: FontWeight.bold),)]
                                              ),
                                              Text('Unit: ${groupMemberData['Unit'] ?? ''}'),
                                              SizedBox(width: 1,),
                                              Text('Ward: ${groupMemberData['Ward'] ?? ''}'),
                                              SizedBox(width: 1,),
                                              Text('City: ${groupMemberData['LGA'] ?? ''}'),
                                              SizedBox(width: 1,),
                                              Text('State: ${groupMemberData['State'] ?? ''}'),
                                              SizedBox(width: 1,),
                                              Text('Phone Number: ${groupMemberData['Phone Number'] ?? ''}'),
                                              SizedBox(width: 1,),
                                            ],
                                          ),
                                        ),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            side: BorderSide(width: 1)
                                        ),
                                      ),
                                      SizedBox(height: 10,)
                                    ]
                                );
                              });
                        } else if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else {
                          return Center(child: Text("Error: ${snapshot.error}"));
                        }
                      }
                  ),
                  // Group (Ward) tab
                  StreamBuilder(
                      stream: principalMembersSubject.stream,
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
                        if (snapshot.hasData) {
                          var groupWard = snapshot.data!.docs;
                          if (groupWard.isEmpty) {
                            return Center(child: Text('No User found.'),);
                          }
                          return ListView.builder(
                              itemCount: groupWard.length,
                              itemBuilder: (context, index) {
                                var groupWardData = groupWard[index].data() as Map<String, dynamic>;
                                return Column(
                                  children: [
                                    ListTile(
                                      title: Text(groupWardData['Ward'] ?? '',
                                        style: TextStyle(fontSize: 15,
                                            fontWeight: FontWeight.bold),),
                                      subtitle: SizedBox(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(width: 1,),
                                            Text('City: ${groupWardData['LGA'] ?? ''}'),
                                            SizedBox(width: 1,),
                                            Text('State: ${groupWardData['State'] ?? ''}'),
                                            SizedBox(width: 1,),
                                          ],
                                        ),
                                      ),
                                      trailing: Text('Members: ${groupWardData['count'] ?? ''}'),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          side: BorderSide(width: 1)
                                      ),
                                    ),
                                    SizedBox(height: 10,)
                                  ],
                                );
                              });
                        } else if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else {
                          return Center(child: Text("Error: ${snapshot.error}"));
                        }
                      }
                  ),
                  // Group (LGA) tab
                  StreamBuilder(
                      stream: principalMembersSubject.stream,
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
                        if (snapshot.hasData) {
                          var groupLGA = snapshot.data!.docs;
                          if (groupLGA.isEmpty) {
                            return Center(child: Text('No User found.'),);
                          }
                          return ListView.builder(
                              itemCount: groupLGA.length,
                              itemBuilder: (context, index) {
                                var groupLGAData = groupLGA[index].data() as Map<String, dynamic>;
                                return Column(
                                  children: [
                                    ListTile(
                                      title: Text(groupLGAData['LGA'] ?? '',
                                        style: TextStyle(fontSize: 15,
                                            fontWeight: FontWeight.bold),),
                                      subtitle: SizedBox(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(width: 1,),
                                            Text('City: ${groupLGAData['LGA'] ?? ''}'),
                                            SizedBox(width: 1,),
                                            Text('State: ${groupLGAData['State'] ?? ''}'),
                                            SizedBox(width: 1,),
                                          ],
                                        ),
                                      ),
                                      trailing: Text('Members: ${groupLGAData['count'] ?? ''}'),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          side: BorderSide(width: 1)
                                      ),
                                    ),
                                    SizedBox(height: 10,)
                                  ],
                                );
                              });
                        } else if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else {
                          return Center(child: Text("Error: ${snapshot.error}"));
                        }
                      }
                  ),
                  // Group state tab
                  StreamBuilder(
                    stream: getStateCounts(), // Use the correct stream for state counts
                    builder: (BuildContext context, AsyncSnapshot<Map<String, int>> snapshot) {
                      if (snapshot.hasData) {
                        var stateCounts = snapshot.data!;

                        if (stateCounts.isEmpty) {
                          return Center(child: Text('No User found.'));
                        }

                        return ListView.builder(
                          itemCount: stateCounts.length,
                          itemBuilder: (context, index) {
                            String state = stateCounts.keys.elementAt(index);
                            int count = stateCounts[state] ?? 0;

                            return Column(
                              children: [
                                ListTile(
                                  title: Text(
                                    state,
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text('Country: Nigeria'), // Update if country is available
                                  trailing: Text('Members: $count'),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(width: 1),
                                  ),
                                ),
                                SizedBox(height: 10),
                              ],
                            );
                          },
                        );
                      } else if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      }
                    },
                  ),

                  // Individual ward tab
                  StreamBuilder(
                      stream: principalFollowersSubject.stream,
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
                        if (snapshot.hasData) {
                          var wardUsers = snapshot.data!.docs;
                          if (wardUsers.isEmpty) {
                            return Center(child: Text('No Users Found'),);
                          }
                          return ListView.builder(
                              itemCount: wardUsers.length,
                              itemBuilder: (context, index) {
                                var wardData = wardUsers[index].data() as Map<String, dynamic>;
                                return Column(
                                    children: [ ListTile(
                                      title: Text(wardData['Ward'] ?? '',
                                        style: TextStyle(fontSize: 15,
                                            fontWeight: FontWeight.bold),),
                                      subtitle: SizedBox(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('LGA: ${wardData['LGA'] ?? ''}'),
                                            SizedBox(width: 1,),
                                            Text('State: ${wardData['State'] ?? ''}'),
                                            SizedBox(width: 1,),
                                          ],
                                        ),
                                      ),
                                      trailing: Text('Total: ${wardData['count'] ?? ''}'),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          side: BorderSide(width: 1)
                                      ),
                                    ),
                                      SizedBox(height: 10,)
                                    ]
                                );
                              });
                        } else if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else {
                          return Center(child: Text("Error: ${snapshot.error}"));
                        }
                      }
                  ),
                  //Individual LGA tab
                  StreamBuilder(
                      stream: principalFollowersSubject.stream,
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
                        if (snapshot.hasData) {
                          var lgaUsers = snapshot.data!.docs;
                          if (lgaUsers.isEmpty) {
                            return Center(child: Text('No LGA found'),);
                          }
                          return ListView.builder(
                            itemCount: lgaUsers.length,
                            itemBuilder: (context, index) {
                              var lgaData = lgaUsers[index].data() as Map<String, dynamic>;
                              return Column(
                                children: [
                                  ListTile(
                                    title: Text(lgaData['LGA'] ?? '',
                                      style: TextStyle(fontSize: 15,
                                          fontWeight: FontWeight.bold),),
                                    subtitle: SizedBox(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('State: ${lgaData['State'] ?? ''}'),
                                          SizedBox(width: 1,),
                                        ],
                                      ),
                                    ),
                                    trailing: Text('Total: ${lgaData['count'] ?? 0}'),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: BorderSide(width: 1)),
                                  ),
                                  SizedBox(height: 10,)
                                ],
                              );
                            },);
                        } else if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else {
                          return Center(child: Text("Error: ${snapshot.error}"));
                        }
                      }
                  ),
                  //Individual state tab
                  StreamBuilder(
                      stream: getStateCountsFollowers(),
                      builder: (BuildContext context, AsyncSnapshot<Map<String, int>> snapshot) {
                        if (snapshot.hasData) {
                          var stateUsers = snapshot.data!;
                          if (stateUsers.isEmpty) {
                            return Center(child: Text('No Wards found'),);
                          }
                          return ListView.builder(
                            itemCount: stateUsers.length,
                            itemBuilder: (context, index) {
                              String state = stateUsers.keys.elementAt(index);
                              int count = stateUsers[state] ?? 0;

                              return Column(
                                children: [
                                  ListTile(
                                    title: Text(
                                      state,
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text('Country: Nigeria'), // Update if country is available
                                    trailing: Text('Members: $count'),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(width: 1),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                ],
                              );
                            },);
                        } else if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else {
                          return Center(child: Text("Error: ${snapshot.error}"));
                        }
                      }
                  ),
                ] : userRole == 'Up-line'
                    ?
                [
                  //down-line tab
                  StreamBuilder(
                      stream: getUpData(),
                      builder: (context, snapshot){
                        if(snapshot.hasData){
                          var submit = snapshot.data!.docs;
                          if(submit.isEmpty){
                            return Center(child: Text('No data Found'),);
                          }
                          return ListView.builder(
                              itemCount: submit.length,
                              itemBuilder: (context, index){
                                var data = submit[index].data() as Map<String, dynamic>;
                                final imageUrl = data['profileImageUrl'] as String?;
                                var docId = snapshot.data!.docs[index].id;
                                return Column(
                                  children: [
                                    ListTile(
                                      title: Text(data['Full Name'] ?? '',
                                        style: TextStyle(
                                            fontSize: 15, fontWeight: FontWeight.bold),),
                                      leading: GestureDetector(
                                        onTap: (){
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                child: Container(
                                                  width: 300, // Define the width
                                                  height: 300, // Define the height
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image: imageUrl != null
                                                          ? NetworkImage(imageUrl)
                                                          : AssetImage('assets/placeholder.png') as ImageProvider,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          );

                                        },
                                        child: CircleAvatar(
                                          radius: 65,
                                          backgroundImage: imageUrl != null
                                              ? NetworkImage(imageUrl) // Use NetworkImage for online images
                                              : AssetImage('assets/placeholder.png') as ImageProvider,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('LGA: ${data['LGA'] ?? ''}'),
                                          Text('State: ${data['State'] ?? ''}'),
                                          Text('Unit: ${data['Unit'] ?? ''}'),
                                          Text('Community: ${data['Village'] ?? ''}'),
                                          Text('Ward: ${data['Ward'] ?? ''}'),
                                          Text('Phone: ${data['Phone Number'] ?? ''}'),
                                        ],
                                      ),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          side: BorderSide(width: 1)
                                      ),
                                      trailing: SizedBox(
                                        width: 120, // Prevent overflow
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.edit, color: Colors.green),
                                              onPressed: () => showEditDialog(context, docId, data),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.delete, color: Colors.red),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Text("Confirm Deletion"),
                                                      content: Text("Are you sure you want to delete this entry?"),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () => Navigator.pop(context),
                                                          child: Text("Cancel"),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            deleteUserData(docId); // Fixed docId reference
                                                            Navigator.pop(context);
                                                          },
                                                          child: Text("Delete", style: TextStyle(color: Colors.red)),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),

                                    ),
                                    SizedBox(height: 10,)
                                  ],
                                );
                              });
                        }else if(snapshot.connectionState == ConnectionState.waiting){
                          return Center(child: CircularProgressIndicator());
                        }else {
                          return Center(child: Text("Error: ${snapshot.error}"));
                        }
                      }),
                  // Individual ward tab
                  StreamBuilder(
                      stream: getWardData(),
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
                        if (snapshot.hasData) {
                          var wardUsers = snapshot.data!.docs;
                          if (wardUsers.isEmpty) {
                            return Center(child: Text('No Users Found'),);
                          }
                          return ListView.builder(
                              itemCount: wardUsers.length,
                              itemBuilder: (context, index) {
                                var wardData = wardUsers[index].data() as Map<String, dynamic>;
                                return Column(
                                    children: [ ListTile(
                                      title: Text(wardData['Ward'] ?? '',
                                        style: TextStyle(fontSize: 15,
                                            fontWeight: FontWeight.bold),),
                                      subtitle: SizedBox(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start,
                                          children: [
                                            Text('LGA: ${wardData['LGA'] ?? ''}'),
                                            SizedBox(width: 1,),
                                            Text('State: ${wardData['State'] ?? ''}'),
                                            SizedBox(width: 1,),
                                          ],
                                        ),
                                      ),
                                      trailing: Text('Total: ${wardData['count'] ?? 0}'),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          side: BorderSide(width: 1)
                                      ),
                                    ),
                                      SizedBox(height: 10,)
                                    ]
                                );
                              });
                        } else if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else {
                          return Center(child: Text("Error: ${snapshot.error}"));
                        }
                      }
                  ),
                  //Individual LGA tab
                  StreamBuilder(
                      stream: getLGAData(),
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
                        if (snapshot.hasData) {
                          var lgaUsers = snapshot.data!.docs;
                          if (lgaUsers.isEmpty) {
                            return Center(child: Text('No LGA found'),);
                          }
                          return ListView.builder(
                            itemCount: lgaUsers.length,
                            itemBuilder: (context, index) {
                              var lgaData = lgaUsers[index].data() as Map<String, dynamic>;
                              return Column(
                                children: [
                                  ListTile(
                                    title: Text(lgaData['LGA'] ?? '',
                                      style: TextStyle(fontSize: 15,
                                          fontWeight: FontWeight.bold),),
                                    subtitle: SizedBox(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('State: ${lgaData['State'] ?? ''}'),
                                          SizedBox(width: 1,),
                                        ],
                                      ),
                                    ),
                                    trailing: Text('Total: ${lgaData['count'] ?? 0}'),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: BorderSide(width: 1)),
                                  ),
                                  SizedBox(height: 10,)
                                ],
                              );
                            },);
                        } else if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else {
                          return Center(child: Text("Error: ${snapshot.error}"));
                        }
                      }
                  ),
                  //Individual state tab
                  StreamBuilder(
                      stream: getStateData(),
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
                        if (snapshot.hasData) {
                          var stateUsers = snapshot.data!.docs;
                          if (stateUsers.isEmpty) {
                            return Center(child: Text('No Wards found'),);
                          }
                          return ListView.builder(
                            itemCount: stateUsers.length,
                            itemBuilder: (context, index) {
                              var stateData = stateUsers[index].data() as Map<String, dynamic>;
                              return Column(
                                children: [
                                  ListTile(
                                    title: Text(stateData['State'] ?? '',
                                      style: TextStyle(fontSize: 15,
                                          fontWeight: FontWeight.bold),),
                                    subtitle: SizedBox(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('State: ${stateData['State'] ?? ''}'),
                                          SizedBox(width: 1,),
                                        ],
                                      ),
                                    ),
                                    trailing: Text('Total: ${stateData['count'] ?? 0}'),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: BorderSide(width: 1)),
                                  ),
                                  SizedBox(height: 10,)
                                ],
                              );
                            },);
                        } else if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else {
                          return Center(child: Text("Error: ${snapshot.error}"));
                        }
                      }
                  ),
                ] : userRole == 'Group'
                    ? [
                  StreamBuilder(
                    stream: getGroupData(),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
                      if (snapshot.hasData) {
                        var groupUser = snapshot.data!.docs;

                        if (groupUser.isEmpty) {
                          return Center(child: Text('No User found.'));
                        }

                        // Group data by Group Name
                        Map<String, List<QueryDocumentSnapshot>> grouped = {};
                        for (var doc in groupUser) {
                          var data = doc.data() as Map<String, dynamic>;
                          String groupName = data['Group Name'] ?? 'Unknown Group';

                          if (!grouped.containsKey(groupName)) {
                            grouped[groupName] = [];
                          }
                          grouped[groupName]!.add(doc);
                        }

                        var uniqueGroups = grouped.keys.toList();

                        return ListView.builder(
                          itemCount: uniqueGroups.length,
                          itemBuilder: (context, index) {
                            String groupName = uniqueGroups[index];
                            List<QueryDocumentSnapshot> groupMembers = grouped[groupName]!;

                            // Use the first entry as the representative data
                            var groupData = groupMembers.first.data() as Map<String, dynamic>;

                            // Calculate total members from counts (or just count the list length)
                            int totalCount = 0;
                            for (var doc in groupMembers) {
                              final data = doc.data() as Map<String, dynamic>;
                              totalCount += int.tryParse(data['count'].toString()) ?? 0;
                            }
                            return Column(
                              children: [
                                ListTile(
                                  title: Text(
                                    groupName,
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Name: ${groupData['Owner Name'] ?? ''}'),
                                      Text('Unit: ${groupData['Unit'] ?? ''}'),
                                      Text('Ward: ${groupData['Ward'] ?? ''}'),
                                      Text('LGA: ${groupData['LGA'] ?? ''}'),
                                      Text('State: ${groupData['State'] ?? ''}'),
                                      Text('Phone Number: ${groupData['Phone Number'] ?? ''}'),
                                    ],
                                  ),
                                  trailing: Text('Members: $totalCount'),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(width: 1),
                                  ),
                                ),
                                SizedBox(height: 10),
                              ],
                            );
                          },
                        );
                      } else if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      }
                    },
                  ),

                  // Group member tab
                  StreamBuilder(
                      stream: getGroupData(),
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
                        if (snapshot.hasData) {
                          var groupMember = snapshot.data!.docs;
                          if (groupMember.isEmpty) {
                            return Center(child: Text('No User found.'),);
                          }
                          return ListView.builder(
                              itemCount: groupMember.length,
                              itemBuilder: (context, index) {
                                var groupMemberData = groupMember[index].data() as Map<String, dynamic>;
                                final memberUrl = groupMemberData['memberImage'] as String?;
                                var docId = snapshot.data!.docs[index].id;
                                return Column(
                                    children: [
                                      ListTile(
                                        title: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            GestureDetector(
                                              onTap: (){
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return Dialog(
                                                      child: Container(
                                                        width: 300, // Define the width
                                                        height: 300, // Define the height
                                                        decoration: BoxDecoration(
                                                          image: DecorationImage(
                                                            fit: BoxFit.cover,
                                                            image: memberUrl != null
                                                                ? NetworkImage(memberUrl)
                                                                : AssetImage('assets/placeholder.png') as ImageProvider,
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              child: CircleAvatar(
                                                radius: 30,
                                                backgroundImage: memberUrl != null
                                                    ? NetworkImage(memberUrl) // Use NetworkImage for online images
                                                    : AssetImage('assets/placeholder.png') as ImageProvider,
                                              ),
                                            ),
                                            const SizedBox(width: 145.0,),
                                            IconButton(
                                              icon: Icon(Icons.edit, color: Colors.green),
                                              onPressed: () => showEditDialogGroup(context, docId, groupMemberData),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.delete, color: Colors.red),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Text("Confirm Deletion"),
                                                      content: Text("Are you sure you want to delete this entry?"),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () => Navigator.pop(context),
                                                          child: Text("Cancel"),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            deleteUserData(docId); // Fixed docId reference
                                                            Navigator.pop(context);
                                                          },
                                                          child: Text("Delete", style: TextStyle(color: Colors.red)),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                        subtitle: SizedBox(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(width: 1,),
                                              Text('Group Name: ${groupMemberData['Group Name'] ?? ''}'),
                                              Text('LGA: ${groupMemberData['LGA'] ?? ''}'),
                                              SizedBox(width: 1,),
                                              Text('State: ${groupMemberData['State'] ?? ''}'),
                                              SizedBox(width: 1,),
                                              Text('Phone Number: ${groupMemberData['Phone Number'] ?? ''}'),
                                              SizedBox(width: 1,),
                                            ],
                                          ),
                                        ),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            side: BorderSide(width: 1)
                                        ),
                                      ),
                                      SizedBox(height: 10,)
                                    ]
                                );
                              });
                        } else if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else {
                          return Center(child: Text("Error: ${snapshot.error}"));
                        }
                      }
                  ),
                  StreamBuilder(
                      stream: getGroupWardData(),
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
                        if (snapshot.hasData) {
                          var groupWard = snapshot.data!.docs;
                          if (groupWard.isEmpty) {
                            return Center(child: Text('No User found.'),);
                          }

                          // Create a map to track the combination of Ward and LGA
                          Map<String, int> wardLgaCount = {};

                          // First, iterate through the documents and group by Ward and LGA
                          groupWard.forEach((doc) {
                            var groupWardData = doc.data() as Map<String, dynamic>;
                            String ward = groupWardData['Ward'] ?? '';
                            String lga = groupWardData['LGA'] ?? '';
                            String key = '$ward-$lga';

                            // Increment the count for this Ward and LGA combination
                            if (wardLgaCount.containsKey(key)) {
                              wardLgaCount[key] = wardLgaCount[key]! + 1;
                            } else {
                              wardLgaCount[key] = 1;
                            }
                          });

                          return ListView.builder(
                            itemCount: groupWard.length,
                            itemBuilder: (context, index) {
                              var groupWardData = groupWard[index].data() as Map<String, dynamic>;
                              String ward = groupWardData['Ward'] ?? '';
                              String lga = groupWardData['LGA'] ?? '';
                              String key = '$ward-$lga';

                              // Use the incremented count for this Ward and LGA
                              int memberCount = wardLgaCount[key] ?? 0;

                              return Column(
                                children: [
                                  ListTile(
                                    title: Text(groupWardData['Ward'] ?? '',
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: SizedBox(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(width: 1,),
                                          Text('LGA: ${groupWardData['LGA'] ?? ''}'),
                                          SizedBox(width: 1,),
                                          Text('State: ${groupWardData['State'] ?? ''}'),
                                          SizedBox(width: 1,),
                                        ],
                                      ),
                                    ),
                                    trailing: Text('Members: $memberCount'),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: BorderSide(width: 1)
                                    ),
                                  ),
                                  SizedBox(height: 10,)
                                ],
                              );
                            },
                          );
                        } else if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else {
                          return Center(child: Text("Error: ${snapshot.error}"));
                        }
                      }
                  ),
                  // Group (LGA) tab
                  StreamBuilder(
                    stream: getGroupLGAData(),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
                      if (snapshot.hasData) {
                        var groupLGADocs = snapshot.data!.docs;
                        if (groupLGADocs.isEmpty) {
                          return Center(child: Text('No User found.'));
                        }

                        // Group by LGA and count entries
                        Map<String, Map<String, dynamic>> groupedLGA = {};

                        for (var doc in groupLGADocs) {
                          var data = doc.data() as Map<String, dynamic>;
                          String lga = data['LGA'] ?? '';
                          String state = data['State'] ?? '';

                          if (groupedLGA.containsKey(lga)) {
                            groupedLGA[lga]!['count'] += 1;
                          } else {
                            groupedLGA[lga] = {
                              'LGA': lga,
                              'State': state,
                              'count': 1,
                            };
                          }
                        }

                        var lgaList = groupedLGA.values.toList();

                        return ListView.builder(
                          itemCount: lgaList.length,
                          itemBuilder: (context, index) {
                            var groupLGAData = lgaList[index];
                            return Column(
                              children: [
                                ListTile(
                                  title: Text(
                                    groupLGAData['LGA'] ?? '',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(width: 1),
                                      Text('LGA: ${groupLGAData['LGA'] ?? ''}'),
                                      Text('State: ${groupLGAData['State'] ?? ''}'),
                                    ],
                                  ),
                                  trailing: Text('Members: ${groupLGAData['count'] ?? ''}'),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(width: 1),
                                  ),
                                ),
                                SizedBox(height: 10),
                              ],
                            );
                          },
                        );
                      } else if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      }
                    },
                  ),

                  //State for group
                  StreamBuilder(
                    stream: getGroupStateData(),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
                      if (snapshot.hasData) {
                        var groupStateDocs = snapshot.data!.docs;
                        if (groupStateDocs.isEmpty) {
                          return Center(child: Text('No User found.'));
                        }

                        // Grouping by state and counting occurrences
                        Map<String, Map<String, dynamic>> groupedStates = {};

                        for (var doc in groupStateDocs) {
                          var data = doc.data() as Map<String, dynamic>;
                          String state = data['State'] ?? '';
                          String lga = data['LGA'] ?? '';

                          if (groupedStates.containsKey(state)) {
                            groupedStates[state]!['count'] += 1;
                          } else {
                            groupedStates[state] = {
                              'State': state,
                              'LGA': lga,
                              'count': 1,
                            };
                          }
                        }

                        var stateList = groupedStates.values.toList();

                        return ListView.builder(
                          itemCount: stateList.length,
                          itemBuilder: (context, index) {
                            var groupStateData = stateList[index];
                            return Column(
                              children: [
                                ListTile(
                                  title: Text(
                                    groupStateData['State'] ?? '',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(width: 1),
                                      Text('LGA: ${groupStateData['LGA'] ?? ''}'),
                                      Text('State: ${groupStateData['State'] ?? ''}'),
                                    ],
                                  ),
                                  trailing: Text('Members: ${groupStateData['count'] ?? ''}'),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(width: 1),
                                  ),
                                ),
                                SizedBox(height: 10),
                              ],
                            );
                          },
                        );
                      } else if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      }
                    },
                  ),
                ] : []
            ),
          ),
        )
    );
  }
}
