import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'notification_service.dart'; // Assuming this is for handling notifications

class KuliDetailsPage extends StatefulWidget {
  final Map<String, dynamic> kuli;
  final Map<String, dynamic> travelerData;
  final String? travelerImageUrl;
  final String? travelerId;

  const KuliDetailsPage({
    super.key,
    required this.kuli,
    required this.travelerData,
    this.travelerImageUrl,
    this.travelerId,
  });

  @override
  _KuliDetailsPageState createState() => _KuliDetailsPageState();
}

class _KuliDetailsPageState extends State<KuliDetailsPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Base URL for Firebase Storage
  final String baseImageUrl = 'https://firebasestorage.googleapis.com/v0/b/book-my-coolie-82e3c.appspot.com/o/';

  @override
  Widget build(BuildContext context) {
    // Construct the image URL and get the image name
    String? imageUrl;
    String? imageName;

    if (widget.kuli['profileImage'] != null) {
      // Getting the full image URL from the document
      String fullImageUrl = widget.kuli['profileImage'];

      // Check if the URL has the expected format
      if (fullImageUrl.contains('firebasestorage.googleapis.com')) {
        // Extracting the image name from the provided URL using RegExp
        RegExp regExp = RegExp(r'(?<=o/)[^?]+');
        Match? match = regExp.firstMatch(fullImageUrl);

        if (match != null) {
          imageName = match.group(0); // Get the matched group
          imageUrl = '$baseImageUrl$imageName?alt=media';
          print('Profile Image URL: $imageUrl');
        }
      }
    } else {
      print('No Profile Image URL found.');
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrangeAccent[100],
        title: Text(widget.kuli['name'] ?? 'Kuli Details'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the Kuli's image using Image.network with a fallback for errors or missing image
            Center(
              child: imageUrl != null
                  ? ClipOval(
                      child: Image.network(
                        imageUrl,
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // If image loading fails, show default avatar
                          return Image.asset(
                            'assets/default_avatar.png',
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    )
                  : Image.asset(
                      'assets/default_avatar.png', // Default image if no profileImage is provided
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(height: 20),

            // Display the Profile Image URL
            if (imageUrl != null)
              Text('Profile Image URL: $imageUrl', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),

            // Display the Image Name
            if (imageName != null)
              Text('Image Name: $imageName', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),

            // Kuli's details
            _buildKuliDetailText('Name', widget.kuli['name']),
            _buildKuliDetailText('Age', widget.kuli['age']),
            _buildKuliDetailText('Email', widget.kuli['email']),
            _buildKuliDetailText('Phone', widget.kuli['phone']),
            _buildKuliDetailText('Experience', widget.kuli['experience']),
            _buildKuliDetailText('Rating', widget.kuli['rating']),
            _buildKuliDetailText('Station', widget.kuli['station']),
            _buildKuliDetailText('Address', widget.kuli['address']),
            const SizedBox(height: 20),

            // Confirm selection button
            ElevatedButton(
              onPressed: () {
                _storeBookingData();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrangeAccent[400],
              ),
              child: const Text('Confirm Booking'),
            ),
          ],
        ),
      ),
    );
  }

  // Function to build Kuli detail text widgets
  Widget _buildKuliDetailText(String label, dynamic value) {
    return Text(
      '$label: ${value ?? 'N/A'}',
      style: const TextStyle(fontSize: 18),
    );
  }

  // Function to store booking in Firestore
  Future<void> _storeBookingData() async {
    try {
      // Generate timestamps for creation
      Timestamp createdAt = Timestamp.now();

      // Prepare the booking data
      Map<String, dynamic> bookingData = {
        'createdAt': createdAt,
        'kuli': {
          'name': widget.kuli['name'] ?? '',
          'phone': widget.kuli['phone'] ?? '',
          'profileImage': widget.kuli['profileImage'] ?? '',
          'station': widget.kuli['station'] ?? '',
          'kuliId': widget.kuli['id'] ?? '', // Assuming 'id' exists in kuli data
        },
        'traveler': {
          'current_location': widget.travelerData['current_location'],
          'destination': widget.travelerData['destination'],
          'name': widget.travelerData['name'],
          'phone_number': widget.travelerData['phone_number'],
          'photo_url': widget.travelerImageUrl ?? '',
          'travelerId': widget.travelerId, // Assuming 'id' exists in travelerData
        },
        'status': 'pending', // Initial status of booking
      };

      // Add the booking data to the 'bookings' collection in Firestore
      await firestore.collection('bookings').add(bookingData);

      print("Booking data stored successfully!");
    } catch (e) {
      print("Failed to store booking: $e");
    }
  }
}
