// lib/admin_home_screen.dart

import 'package:flutter/material.dart';
import 'auth_service.dart';

// A simple data model for your products
class Product {
  final String name;
  int quantity;
  final String category;

  Product({required this.name, required this.quantity, required this.category});
}

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  // Dummy data - later you will fetch this from Firebase
  final List<Product> _products = [
    Product(name: 'Modern Sofa', quantity: 15, category: 'Sofas'),
    Product(name: 'Oak Dining Table', quantity: 8, category: 'Tables'),
    Product(name: 'Leather Armchair', quantity: 22, category: 'Chairs'),
  ];

  void _logout() async {
    await AuthService().signOut();
    // The AuthWrapper in main.dart will handle navigation
  }

  void _editProduct(Product product) {
    // TODO: Implement the logic to edit a product.
    // This could open a new screen or a dialog.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editing ${product.name}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel - Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Category: ${product.category}\nQuantity: ${product.quantity}'),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _editProduct(product),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement the logic to add a new product.
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}