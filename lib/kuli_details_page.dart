import 'package:flutter/material.dart';

class KuliDetailsPage extends StatelessWidget {
  final Map<String, dynamic> kuli;

  const KuliDetailsPage({super.key, required this.kuli});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrangeAccent[100],
        title: Text(kuli['name'] ?? 'Kuli Details'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${kuli['name'] ?? 'N/A'}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Age: ${kuli['age'] ?? 'N/A'}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Email: ${kuli['email'] ?? 'N/A'}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Phone: ${kuli['phone'] ?? 'N/A'}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Experience: ${kuli['experience'] ?? 'N/A'}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Rating: ${kuli['rating'] ?? 'N/A'}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Station: ${kuli['station'] ?? 'N/A'}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Address: ${kuli['address'] ?? 'N/A'}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement confirmation logic here (e.g., update the Kuli's status in Firestore)
                _confirmSelection(kuli);
                Navigator.pop(context); // Go back to the previous page
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrangeAccent[400],
              ),
              child: const Text('Confirm Selection'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmSelection(Map<String, dynamic> kuli) {
    // Handle confirmation logic (e.g., update Firestore)
    print('Confirmed selection for Kuli: ${kuli['name']}');
  }
}
