import 'dart:io'; // For File class
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'kuli_details_page.dart';

class KuliInfoPage extends StatefulWidget {
  final String travelerDestination; // Destination of the traveler
   // Traveler's data
  final File? uploadedPhoto; // Optional uploaded photo

  const KuliInfoPage({
    super.key,
    required this.travelerDestination,
    this.uploadedPhoto,
  });

  @override
  _KuliInfoPageState createState() => _KuliInfoPageState();
}

class _KuliInfoPageState extends State<KuliInfoPage> {
  List<Map<String, dynamic>> kuliProfiles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchKuliProfiles();
  }

  Future<void> fetchKuliProfiles() async {
    setState(() {
      isLoading = true; // Start loading
    });

    try {
      // Reference to the Firestore collection
      final kuliCollection = FirebaseFirestore.instance.collection('kuli');

      // Fetch documents from the collection
      final snapshot = await kuliCollection.get();
      final List<Map<String, dynamic>> filteredProfiles = [];

      // Filter Kuli profiles by travelerDestination
      for (var doc in snapshot.docs) {
        if (doc.data()['station'] == widget.travelerDestination) {
          filteredProfiles.add(doc.data());
        }
      }

      setState(() {
        kuliProfiles = filteredProfiles;
        isLoading = false; // Stop loading
      });
    } catch (error) {
      print('Error fetching data: $error');
      setState(() {
        isLoading = false; // Stop loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrangeAccent[100],
        title: const Text(
          'Available Kuli Profiles',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 10,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: CircleAvatar(
                radius: 75,
                backgroundImage: const AssetImage('assets/logo.png'), // Load image from assets
                backgroundColor: Colors.grey[200],
              ),
            ),
            isLoading
                ? const CircularProgressIndicator()
                : Expanded(
                    child: kuliProfiles.isEmpty
                        ? const Text('No Kuli available at this destination.')
                        : ListView.builder(
                            itemCount: kuliProfiles.length,
                            itemBuilder: (context, index) {
                              final kuli = kuliProfiles[index];
                              return Card(
                                elevation: 5,
                                margin: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16.0),
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(kuli['profileImage'] ?? ''),
                                    radius: 30,
                                  ),
                                  title: Text(
                                    kuli['name'] ?? 'Unknown Kuli',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.deepOrangeAccent,
                                    ),
                                  ),
                                  subtitle: Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        kuli['rating']?.toString() ?? 'N/A',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.deepOrangeAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => KuliDetailsPage(
                                            kuli: kuli, // Pass the selected Kuli data
                                             // Pass the traveler data
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepOrangeAccent[400],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text('Select'),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ],
        ),
      ),
    );
  }
}
