import 'dart:io'; // For File class
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'kuli_details_page.dart';
import 'traveler.dart';

class KuliInfoPage extends StatefulWidget {
  final String travelerDestination; // Destination of the traveler
  final File? uploadedPhoto; // Optional uploaded photo
  final String? travelerImageUrl;
  final String? travelerId;
  final Map<String, dynamic> travelerData;

  const KuliInfoPage({
    super.key,
    required this.travelerDestination,
    this.uploadedPhoto,
    required this.travelerData,
    this.travelerImageUrl,
    this.travelerId,
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
          // Add the document data along with the document ID to the profiles list
          filteredProfiles.add({
            ...doc.data(),
            'id': doc.id, // Add document ID to the profile map
          });
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
            // Show Traveler ID
            widget.travelerId != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Traveler ID: ${widget.travelerId!}', // Display traveler ID
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                  )
                : const SizedBox.shrink(), // Display nothing if travelerId is null
            const SizedBox(height: 10),
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
                                    backgroundImage: kuli['profileImage'] != null
                                        ? NetworkImage(kuli['profileImage']) // Display the image from Firebase
                                        : const AssetImage('assets/default_avatar.png')
                                            as ImageProvider, // Fallback to default if no URL
                                    radius: 30,
                                    onBackgroundImageError: (exception, stackTrace) {
                                      print('Image load failed: $exception');
                                    },
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
                                      // Navigate to the KuliDetailsPage and pass the selected Kuli profile along with the ID
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => KuliDetailsPage(
                                            kuli: kuli, // Pass the selected Kuli data (including 'id')
                                            travelerData: widget.travelerData, // Pass the traveler data
                                            travelerImageUrl: widget.travelerImageUrl, // Pass the traveler image URL
                                            travelerId: widget.travelerId, // Pass traveler ID
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
