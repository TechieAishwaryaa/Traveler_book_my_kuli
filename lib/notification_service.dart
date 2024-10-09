import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationService {
  static Future<void> sendNotificationToKuli(String token, String title, String body) async {
    final response = await http.post(
      Uri.parse('https://your-backend-url/send-notification'), // Replace with your backend URL
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'token': token,
        'message': {
          'title': title,
          'body': body,
        },
      }),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully!');
    } else {
      print('Failed to send notification: ${response.body}');
    }
  }
}
