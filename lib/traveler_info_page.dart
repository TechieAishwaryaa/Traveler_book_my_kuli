import 'dart:typed_data'; // Import for Uint8List
import 'dart:io'; // Import for File
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart'; // Form builder
import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storage
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore for saving form data
import 'package:image_picker/image_picker.dart'; // For picking images
// For file paths
import 'kuli_info_page.dart'; // Import Kuli Info Page

class TravelerInfoPage extends StatefulWidget {
  const TravelerInfoPage({super.key});

  @override
  State<TravelerInfoPage> createState() => _TravelerInfoPageState();
}

class _TravelerInfoPageState extends State<TravelerInfoPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  Uint8List? _imageBytes; // To store picked image bytes
  File? _imageFile; // Store the picked image as a file
  String? _uploadedImageUrl; // Store the uploaded image URL
  bool isLoading = false;

  /// Method to pick an image (either as bytes or file)
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Depending on the use case, you can either store the image as a File or Uint8List bytes.
      Uint8List imageBytes = await image.readAsBytes();
      File imageFile = File(image.path);

      setState(() {
        _imageBytes = imageBytes; // Set image bytes
        _imageFile = imageFile; // Set image file
      });
    }
  }

  /// Method to upload image data to Firebase Storage
  Future<String?> _uploadImage(Uint8List imageBytes) async {
    try {
      // Create a reference to Firebase Storage
      Reference storageReference = FirebaseStorage.instance.ref().child('traveler_photos');

      // Generate a unique filename for the image
      String fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference fileReference = storageReference.child(fileName);

      // Upload image bytes using putData
      UploadTask uploadTask = fileReference.putData(imageBytes);

      // Wait for the upload to complete
      TaskSnapshot snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        // Get the image download URL
        String downloadUrl = await fileReference.getDownloadURL();
        return downloadUrl;
      }
      return null;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  /// Method to save form data and image URL to Firestore
 Future<void> _saveDataToFirestore(Map<String, dynamic> formData, String? imageUrl) async {
  try {
    await FirebaseFirestore.instance.collection('traveler').add({
      'name': formData['name'],
      'current_location': formData['current_location'],
      'destination': formData['destination'],
      'phone_number': formData['phone_number'],
      'photo_url': imageUrl ?? '', // Save the download URL
      'timestamp': FieldValue.serverTimestamp(),
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Traveler data saved successfully')),
    );

    // Navigate to Kuli Info Page after successful form submission
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KuliInfoPage(
          travelerDestination: formData['destination'],
        ),
      ),
    );
  } catch (e) {
    print("Error saving data to Firestore: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to save data')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrangeAccent[100],
        title: const Text('Traveler Information',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color:Colors.white,
        ),),
        centerTitle: true,
        elevation: 10,

      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo.png',
                  height:120,
                ),
                FormBuilderTextField(
                  name: 'name',
                  decoration: InputDecoration(
                    labelText: 'Name',
                    filled: true,
                    fillColor: Colors.orange[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    labelStyle: const TextStyle(
                      color: Colors.deepOrangeAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Please enter your name' : null,
                ),
                const SizedBox(height: 20),
                FormBuilderTextField(
                  name: 'current_location',
                  decoration: InputDecoration(
                    labelText: 'Current Location',
                    filled: true,
                    fillColor: Colors.orange[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    labelStyle: const TextStyle(
                      color: Colors.deepOrangeAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter your current location'
                      : null,
                ),
                const SizedBox(height: 20),
                FormBuilderTextField(
                  name: 'destination',
                  decoration: InputDecoration(
                    labelText: 'Destination',
                    filled: true,
                    fillColor: Colors.orange[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    labelStyle: const TextStyle(
                      color: Colors.deepOrangeAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Please enter your destination' : null,
                ),
                const SizedBox(height: 20),
                FormBuilderTextField(
                  name: 'phone_number',
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    filled: true,
                    fillColor: Colors.orange[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    labelStyle: const TextStyle(
                      color: Colors.deepOrangeAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Please enter your phone number' : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('Upload Image'),
                ),
                const SizedBox(height: 20),
                if (_imageBytes != null) // Display the image if selected
                  Image.memory(_imageBytes!, height: 100),
                if (_imageFile != null) // Display the image if selected
                  Image.file(_imageFile!, height: 100),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState?.saveAndValidate() ?? false) {
                      setState(() {
                        isLoading = true;
                      });
                      final formData = _formKey.currentState!.value; // Get form data

                      if (_imageBytes != null) {
                        // Upload image bytes
                        _uploadedImageUrl = await _uploadImage(_imageBytes!);
                      }

                      await _saveDataToFirestore(formData, _uploadedImageUrl);
                      
                      setState(() {
                        isLoading = false;
                      });
                    }
                  },
                  child: const Text('Submit'),
                ),
                if (isLoading) const CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
