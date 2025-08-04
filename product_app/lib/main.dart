import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ProductTablePage(),
  ));
}

class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final dynamic image; // Can be File (mobile) or Uint8List (web)
  final String date;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.image,
    required this.date,
  });
}

class ProductTablePage extends StatefulWidget {
  const ProductTablePage({Key? key}) : super(key: key);

  @override
  _ProductTablePageState createState() => _ProductTablePageState();
}

class _ProductTablePageState extends State<ProductTablePage> {
  final List<Product> _products = [];
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();

  dynamic _selectedImage; // Can be File or Uint8List
  int? _editIndex;

  final Uuid _uuid = const Uuid();

  void _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final Uint8List bytes = await pickedFile.readAsBytes();
      setState(() {
        if (kIsWeb) {
          _selectedImage = bytes; // Web: store as bytes
        } else {
          _selectedImage = File(pickedFile.path); // Mobile: store as File
        }
      });
    }
  }

  void _openProductDialog({int? index}) {
    if (index != null) {
      _editIndex = index;
      final product = _products[index];
      _nameController.text = product.name;
      _categoryController.text = product.category;
      _priceController.text = product.price.toString();
      _selectedImage = product.image;
    } else {
      _editIndex = null;
      _nameController.clear();
      _categoryController.clear();
      _priceController.clear();
      _selectedImage = null;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_editIndex == null ? "Add Product" : "Edit Product"),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _selectedImage != null
                        ? (kIsWeb)
                            ? Image.memory(_selectedImage, fit: BoxFit.cover)
                            : Image.file(_selectedImage, fit: BoxFit.cover)
                        : const Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Product Name"),
                  validator: (value) => value?.isEmpty == true ? "Enter product name" : null,
                ),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: "Category"),
                  validator: (value) => value?.isEmpty == true ? "Enter category" : null,
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: "Price"),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty == true || double.tryParse(value!) == null) {
                      return "Enter a valid price";
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final name = _nameController.text;
                final category = _categoryController.text;
                final price = double.parse(_priceController.text);
                final now = DateFormat('yyyy-MM-dd').format(DateTime.now());

                final product = Product(
                  id: _editIndex != null ? _products[_editIndex!].id : _uuid.v4().substring(0, 8),
                  name: name,
                  category: category,
                  price: price,
                  image: _selectedImage,
                  date: now,
                );

                if (_editIndex != null) {
                  _products[_editIndex!] = product;
                } else {
                  _products.add(product);
                }

                setState(() {});
                Navigator.pop(context);
              }
            },
            child: Text(_editIndex == null ? "Add" : "Update"),
          ),
        ],
      ),
    );
  }

  void _deleteProduct(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: const Text("Are you sure you want to delete this product?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _products.removeAt(index));
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCards() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            leading: product.image != null
                ? (kIsWeb)
                    ? Image.memory(product.image, width: 60, height: 60, fit: BoxFit.cover)
                    : Image.file(product.image, width: 60, height: 60, fit: BoxFit.cover)
                : const Icon(Icons.image, size: 60, color: Colors.grey),
            title: Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("ID: ${product.id}", style: const TextStyle(fontSize: 12)),
                  Text("Category: ${product.category}", style: const TextStyle(fontSize: 12)),
                  Text("Price: \$${product.price.toStringAsFixed(2)}", style: const TextStyle(fontSize: 12)),
                  Text("Date: ${product.date}", style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange, size: 20),
                  onPressed: () => _openProductDialog(index: index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () => _deleteProduct(index),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 24,
        headingRowHeight: 48,
        dataRowHeight: 64,
        columns: const [
          DataColumn(label: Text("Image")),
          DataColumn(label: Text("Product ID")),
          DataColumn(label: Text("Name")),
          DataColumn(label: Text("Category")),
          DataColumn(label: Text("Price")),
          DataColumn(label: Text("Date")),
          DataColumn(label: Text("Actions")),
        ],
        rows: _products.asMap().entries.map((entry) {
          final index = entry.key;
          final product = entry.value;
          return DataRow(
            cells: [
              DataCell(
                product.image != null
                    ? (kIsWeb)
                        ? Image.memory(product.image, width: 50, height: 50, fit: BoxFit.cover)
                        : Image.file(product.image, width: 50, height: 50, fit: BoxFit.cover)
                    : const Icon(Icons.image, size: 30),
              ),
              DataCell(Text(product.id, style: const TextStyle(fontSize: 14))),
              DataCell(Text(product.name)),
              DataCell(Text(product.category)),
              DataCell(Text('\$${product.price.toStringAsFixed(2)}')),
              DataCell(Text(product.date)),
              DataCell(Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () => _openProductDialog(index: index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteProduct(index),
                  ),
                ],
              )),
            ],
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Manager"),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openProductDialog(),
        tooltip: 'Add Product',
        child: const Icon(Icons.add),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            // Mobile: Cards
            return _products.isEmpty
                ? const Center(child: Text("No products added yet. Tap + to add one."))
                : _buildProductCards();
          } else {
            // Desktop/Tablet: Table
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: _products.isEmpty
                  ? const Center(child: Text("No products added yet."))
                  : _buildProductTable(),
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}