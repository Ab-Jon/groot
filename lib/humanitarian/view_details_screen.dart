import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ViewDetailsScreen extends StatelessWidget {
  final String docID;

  const ViewDetailsScreen({super.key, required this.docID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('View Details')),
      body: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance
            .collectionGroup('Humanitarian')
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No details found"));
          }

          final data = snapshot.data!.docs.first.data();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Table(
                  border: TableBorder.all(color: Colors.grey),
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(3),
                  },
                  children: [
                    _buildRow('Full Name', data['Full Name'] ?? ''),
                    _buildRow('Gender', data['Gender'] ?? ''),
                    _buildRow('Age', data['Age']?.toString() ?? ''),
                    _buildRow('Disabled', data['Disabled'] ?? ''),
                    _buildRow('Identification', data['Identification'] ?? ''),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final pdf = pw.Document();

                      pdf.addPage(
                        pw.Page(
                          build: (pw.Context context) {
                            return pw.TableHelper.fromTextArray(
                              headers: ["Field", "Value"],
                              data: [
                                ["Full Name", data['Full Name'] ?? ""],
                                ["Gender", data['Gender'] ?? ""],
                                ["Age", data['Age']?.toString() ?? ""],
                                ["Disabled", data['Disabled'] ?? ""],
                                ["Identification", data['Identification'] ?? ""],
                              ],
                            );
                          },
                        ),
                      );

                      await Printing.layoutPdf(
                        onLayout: (format) async => pdf.save(),
                      );
                    },
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Export as PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  TableRow _buildRow(String key, String value) {
    return TableRow(children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(key, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(value),
      ),
    ]);
  }
}
