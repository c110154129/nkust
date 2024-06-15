// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetailPage extends StatelessWidget {
  final Map<String, dynamic> eventData;

  EventDetailPage(this.eventData);

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw '無法打開連結 $url';
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.outlineVariant,
        title: Text(eventData['name']),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(eventData['imageUrl']),
            SizedBox(height: 20),
            Text(eventData['description'], style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            if (eventData.containsKey('url') && eventData['url'].isNotEmpty)
              Center(
                child: ElevatedButton(
                  onPressed: () => _launchURL(eventData['url']),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(150, 50),
                  ),
                  child: Text('前往活動連結', style: TextStyle(fontSize: 18)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}