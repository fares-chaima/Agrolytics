import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CropRecommendationScreen extends StatefulWidget {
  @override
  _CropRecommendationScreenState createState() => _CropRecommendationScreenState();
}

class _CropRecommendationScreenState extends State<CropRecommendationScreen> {
  List<dynamic> _crops = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    fetchRecommendations();
  }

  Future<void> fetchRecommendations() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.1.9:8000/agriculture/recommendations/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _crops = data['recommended_crops'];
          _loading = false;
        });
      } else {
        throw Exception('Failed to load crops');
      }
    } catch (e) {
      setState(() {
        _loading = false;
      });
      print("Error: $e");
    }
  }

  Widget buildCropCard(Map<String, dynamic> crop) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                crop['name'] ?? "Unknown Crop",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[900]),
              ),
              SizedBox(height: 8),
              Text(
                crop['detail'] ?? "",
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: (crop['badges'] as List<dynamic>?)
                        ?.map((badge) => Chip(
                              label: Text(badge['text']),
                              backgroundColor: badge['type'] == 'optimal'
                                  ? Colors.green[100]
                                  : Colors.grey[300],
                              labelStyle: TextStyle(
                                color: Colors.green[800],
                                fontWeight: FontWeight.w500,
                              ),
                            ))
                        .toList() ??
                    [],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F9F5),
      appBar: AppBar(
        title: Text(
          'Crop Recommendations',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[800],
        elevation: 0,
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            )
          : RefreshIndicator(
              onRefresh: fetchRecommendations,
              color: Colors.green,
              child: ListView(
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Top 4 recommended crops for your field:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.green[900]),
                    ),
                  ),
                  ..._crops.map((crop) => buildCropCard(crop)).toList(),
                  SizedBox(height: 16),
                ],
              ),
            ),
    );
  }
}
