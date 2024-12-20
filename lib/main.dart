import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yemek Seçim Uygulaması',
      theme: ThemeData(
        primarySwatch: Colors.green, // Renk temasını değiştirdim
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FoodSelectionScreen(),
    );
  }
}

class FoodSelectionScreen extends StatefulWidget {
  const FoodSelectionScreen({super.key});

  @override
  _FoodSelectionScreenState createState() => _FoodSelectionScreenState();
}

class _FoodSelectionScreenState extends State<FoodSelectionScreen> {
  List<String> foodList = [];
  TextEditingController foodController = TextEditingController();

  void addFood(String food) {
    setState(() {
      foodList.add(food);
    });
    saveFoodList();
  }

  void removeFood(String food) {
    setState(() {
      foodList.remove(food);
    });
    saveFoodList();
  }

  String randomFood() {
    if (foodList.isNotEmpty) {
      final randomIndex = (foodList.length * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000).floor();
      return foodList[randomIndex];
    } else {
      return 'Yemek listesi boş!';
    }
  }

  Future<void> loadFoodList() async {
    final prefs = await SharedPreferences.getInstance();
    final savedList = prefs.getString('foodList');
    if (savedList != null) {
      final List<String> loadedFoodList = List<String>.from(json.decode(savedList));
      setState(() {
        foodList = loadedFoodList;
      });
    }
  }

  Future<void> saveFoodList() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('foodList', json.encode(foodList));
  }

  @override
  void initState() {
    super.initState();
    loadFoodList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yemek Seçim Uygulaması'),
        backgroundColor: Colors.green, // Başlık çubuğu rengini değiştirdim
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Yemek ekleme kısmı
            TextField(
              controller: foodController,
              decoration: InputDecoration(
                labelText: 'Yemek Adı',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                addFood(foodController.text);
                foodController.clear();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 14.0),
                textStyle: TextStyle(fontSize: 18),
              ),
              child: Text('Yemek Ekle'),
            ),
            SizedBox(height: 16),
            // Yemek listesi
            Expanded(
              child: ListView.builder(
                itemCount: foodList.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 4,
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                      title: Text(foodList[index], style: TextStyle(fontSize: 18)),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          removeFood(foodList[index]);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            // Rastgele yemek seçme
            ElevatedButton(
              onPressed: () {
                String selectedFood = randomFood();
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Rastgele Seçilen Yemek'),
                    content: Text(selectedFood, style: TextStyle(fontSize: 20)),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Kapat', style: TextStyle(fontSize: 18)),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                padding: EdgeInsets.symmetric(vertical: 14.0),
                textStyle: TextStyle(fontSize: 20),
              ),
              child: Text('Rastgele Yemek Seç', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}