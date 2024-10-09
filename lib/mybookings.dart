import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart';
class MyBookingsPage extends StatelessWidget {
  final String? travelerId;

  const MyBookingsPage({Key? key, this.travelerId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Bookings'),
        backgroundColor: Colors.deepOrangeAccent[100],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut(); // Sign out user
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginPage()), // Redirect to LoginPage after sign out
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('traveler.travelerId', isEqualTo: travelerId) // Fetch bookings for this traveler
            .where('status', isEqualTo: 'confirmed') // Only fetch confirmed bookings
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final bookings = snapshot.data!.docs;

          if (bookings.isEmpty) {
            return const Center(child: Text('No bookings found.'));
          }

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(booking['kuli']['name']),
                subtitle: Text('Status: ${booking['status']}'),
                trailing: Text('Kuli ID: ${booking['kuli']['kuliId']}'),
                onTap: () {
                  // Handle booking details or edit
                },
              );
            },
          );
        },
      ),
    );
  }
}
