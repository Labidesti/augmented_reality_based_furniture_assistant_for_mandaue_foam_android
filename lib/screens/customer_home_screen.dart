import 'package:flutter/material.dart';
import '../services/category_service.dart';

class CustomerHomeScreen extends StatefulWidget {
  @override
  _CustomerHomeScreenState createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  Map<String, dynamic>? categories;
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data = await CategoryService.loadCategories();
    setState(() {
      categories = data;
      selectedCategory = categories!.keys.first; // default select first
    });
  }

  @override
  Widget build(BuildContext context) {
    if (categories == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Mandaue Foam")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mandaue Foam"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Category Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories!.keys.map((mainCategory) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = mainCategory;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: selectedCategory == mainCategory
                          ? Colors.blue
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      mainCategory,
                      style: TextStyle(
                        color: selectedCategory == mainCategory
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const Divider(),

          // Subcategories List
          Expanded(
            child: ListView(
              children: (categories![selectedCategory] as Map<String, dynamic>)
                  .keys
                  .map<Widget>((subCategory) {
                return ExpansionTile(
                  title: Text(
                    subCategory,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  children: (categories![selectedCategory]![subCategory] as List)
                      .map<Widget>((item) => ListTile(
                    title: Text(item),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Navigate to product detail
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(
                            category: subCategory,
                            product: item,
                          ),
                        ),
                      );
                    },
                  ))
                      .toList(),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductDetailScreen extends StatelessWidget {
  final String category;
  final String product;

  const ProductDetailScreen({
    Key? key,
    required this.category,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Placeholder(
              fallbackHeight: 200,
              fallbackWidth: double.infinity,
            ),
            const SizedBox(height: 16),
            Text(
              product,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text("Category: $category"),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, "/ar"); // open AR screen
              },
              icon: const Icon(Icons.view_in_ar),
              label: const Text("View in AR"),
            )
          ],
        ),
      ),
    );
  }
}
