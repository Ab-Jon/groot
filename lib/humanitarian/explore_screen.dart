import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:groot/humanitarian/view_details_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  String? _selectedSortOption = 'Date Submitted';
  final List<String> _sortOptions = ['Date Submitted', 'Alphabetical Order'];

  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";
  bool _loading = false;
  List<Map<String, dynamic>> _results = [];

  Future<String?> getStoredFullName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fullName');
  }

  // Future<void> _searchData() async {
  //   String searchTerm = _searchController.text.trim();
  //   if (searchTerm.isEmpty) {
  //     setState(() {
  //       _results = [];
  //     });
  //     return;
  //   }
  //   setState(() => _loading = true);
  //
  //   final querySnapshot = await FirebaseFirestore.instance
  //       .collectionGroup('Humanitarian')
  //       .where('Full Name', isEqualTo: searchTerm)
  //       .get();
  //
  //   final querySnapshotCity = await FirebaseFirestore.instance
  //       .collectionGroup('Humanitarian')
  //       .where('City', isEqualTo: searchTerm)
  //       .get();
  //
  //   final querySnapshotCategory = await FirebaseFirestore.instance
  //       .collectionGroup('Humanitarian')
  //       .where('category', isEqualTo: searchTerm)
  //       .get();
  //
  //   // Merge results
  //   final allDocs = [
  //     ...querySnapshot.docs,
  //     ...querySnapshotCity.docs,
  //     ...querySnapshotCategory.docs,
  //   ];
  //
  //   // Remove duplicates
  //   final seen = <String>{};
  //   final uniqueResults = allDocs.where((doc) => seen.add(doc.id)).toList();
  //
  //   setState(() {
  //     _results = uniqueResults.map((doc) => doc.data()).toList();
  //     _loading = false;
  //   });
  // }
  Future<void> _searchData() async {
    String searchTerm = _searchController.text.trim().toLowerCase();

    if (searchTerm.isEmpty) {
      setState(() {
        _results = [];
        _loading = false;
      });
      return;
    }

    setState(() => _loading = true);

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collectionGroup('Humanitarian')
          .get();

      // Perform case-insensitive filtering locally
      final filtered = querySnapshot.docs.where((doc) {
        final data = doc.data();
        final name = (data['Full Name'] ?? '').toString().toLowerCase();
        final city = (data['City'] ?? '').toString().toLowerCase();
        final category = (data['category'] ?? '').toString().toLowerCase();

        return name.contains(searchTerm) ||
            city.contains(searchTerm) ||
            category.contains(searchTerm);
      }).toList();

      setState(() {
        _results = filtered.map((doc) => doc.data()).toList();
        _loading = false;
      });
    } catch (e) {
      print('❌ Error during search: $e');
      setState(() => _loading = false);
    }
  }


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchUserData() async {
    try {
      final collection = await FirebaseFirestore
          .instance
          .collectionGroup('Humanitarian')
          .get();

      return collection.docs;
    } catch (e) {
      print("Error fetching data: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () {}, icon: Icon(Icons.menu)),
        title: Text('Explore Needs'),
        centerTitle: true,
        elevation: 10.0,
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.person)),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Explore Needs',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Search and filter humanitarian need',
              style: TextStyle(fontSize: 13),
            ),
            SizedBox(height: 10),
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(
                      child: SearchBar(
                        controller: _searchController,
                        hintText: 'Search Needs',
                        elevation: WidgetStateProperty.all(0),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value.trim().toLowerCase();
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(onPressed: _searchData, child: Text('Filter')),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              const Text(
                'Sort By:',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {},
                child: DropdownButton<String>(
                  value: _selectedSortOption,
                  items: _sortOptions.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? value) {},
                ),
              ),
            ]),
            SizedBox(height: 15),
            _loading
                ? const Center(child: CircularProgressIndicator())
                : _results.isNotEmpty
                ? ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final data = _results[index];
                  return Card(
                    elevation: 3,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // Important!
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data['Full Name'] ?? 'No Name',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(height: 5),
                          Text("City: ${data['City'] ?? ''}"),
                          Text("Category: ${data['category'] ?? ''}"),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ViewDetailsScreen(
                                          docID: 'ID')),
                              );
                            },
                            child: Text('View Details'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                )
            : FutureBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
              future: fetchUserData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No records found"));
                }

                final docs = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data();

                    return Card(
                      elevation: 3,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min, // Important!
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['Full Name'] ?? 'No Name',
                                // data.containsKey('Full Name')
                                //     ? data['Full Name']
                                //     : data.toString(),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const Text('Individual', style: TextStyle(fontSize: 15)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    child: Text(data['Basic Need'] ?? 'No Need'),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    child: const Text('Immediate', style: TextStyle(color: Colors.white)),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    child: const Text('Pending', style: TextStyle(color: Colors.white)),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Text('Needs food supplies and clean water for family.'),
                            const SizedBox(height: 10),
                            Text('Date Submitted:  ' + DateTime.now().toString()),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ViewDetailsScreen(
                                          docID: docs[index].reference.path,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('View Details'),
                                ),
                                SizedBox(width: 10),
                                ElevatedButton(onPressed: () {}, child: const Text('Respond')),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}