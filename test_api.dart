import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🔍 Testing FastAPI Server Connection...\n');

  // Test health endpoint
  try {
    print('Testing health endpoint...');
    final healthResponse = await http.get(
      Uri.parse('http://10.0.2.2:8000/health'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 5));

    if (healthResponse.statusCode == 200) {
      print('✅ Health check passed!');
      print('Response: ${healthResponse.body}\n');
    } else {
      print('❌ Health check failed: ${healthResponse.statusCode}');
      return;
    }
  } catch (e) {
    print('❌ Health check failed: $e');
    print('💡 Make sure your FastAPI server is running on port 8000\n');
    return;
  }

  // Test search endpoint
  try {
    print('Testing search endpoint...');
    final searchResponse = await http.post(
      Uri.parse('http://10.0.2.2:8000/search'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'meal_type': 'breakfast',
        'target_calories': 500,
        'top_k': 3,
      }),
    ).timeout(const Duration(seconds: 10));

    if (searchResponse.statusCode == 200) {
      final data = jsonDecode(searchResponse.body);
      print('✅ Search API working!');
      print('Found ${data['count']} recipes for breakfast');
      if (data['results'].isNotEmpty) {
        print('Sample recipe: ${data['results'][0]['recipe_name']}');
        print('Calories: ${data['results'][0]['nutrition']['calories']}');
      }
    } else {
      print('❌ Search API failed: ${searchResponse.statusCode}');
      print('Response: ${searchResponse.body}');
    }
  } catch (e) {
    print('❌ Search API failed: $e');
  }

  print('\n🎉 Server connection test complete!');
  print('If tests passed, your Flutter app should now show recipes!');
}