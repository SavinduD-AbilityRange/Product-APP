import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(MaterialApp(home: ProductTablePage()));
}

class Product {
  String id;
  String name;
  String category;
  double price;
  File? image;
  String date;

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
  const ProductTablePage({super.key});

  @override
  _ProductTablePageState createState() => _ProductTablePageState();
}

class _ProductTablePageState extends State<ProductTablePage> {
  final List<Product> _products = [];
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();

  File? _selectedImage;
  int? _editIndex;

  void _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _selectedImage = File(pickedFile.path));
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
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: _selectedImage != null
                      ? Image.file(_selectedImage!, height: 100)
                      : Container(
                          height: 100,
                          color: Colors.grey[300],
                          child: Icon(Icons.add_a_photo),
                        ),
                ),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: "Product Name"),
                  validator: (value) => value!.isEmpty ? "Enter product name" : null,
                ),
                TextFormField(
                  controller: _categoryController,
                  decoration: InputDecoration(labelText: "Category"),
                  validator: (value) => value!.isEmpty ? "Enter category" : null,
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(labelText: "Price"),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty || double.tryParse(value) == null ? "Enter valid price" : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final name = _nameController.text;
                final category = _categoryController.text;
                final price = double.parse(_priceController.text);
                final now = DateFormat('yyyy-MM-dd').format(DateTime.now());

                if (_editIndex != null) {
                  _products[_editIndex!] = Product(
                    id: _products[_editIndex!].id,
                    name: name,
                    category: category,
                    price: price,
                    image: _selectedImage,
                    date: now,
                  );
                } else {
                  _products.add(Product(
                    id: Uuid().v4().substring(0, 8),
                    name: name,
                    category: category,
                    price: price,
                    image: _selectedImage,
                    date: now,
                  ));
                }

                setState(() {});
                Navigator.pop(context);
              }
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  void _deleteProduct(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Confirm Deletion"),
        content: Text("Are you sure you want to delete this product?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() => _products.removeAt(index));
              Navigator.pop(context);
            },
            child: Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Product Manager")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openProductDialog(),
        child: Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 16,
          columns: const [
            DataColumn(label: Text("Image")),
            DataColumn(label: Text("Product ID")),
            DataColumn(label: Text("Name")),
            DataColumn(label: Text("Category")),
            DataColumn(label: Text("Price")),
            DataColumn(label: Text("Date")),
            DataColumn(label: Text("Actions")),
          ],
          rows: _products
              .asMap()
              .entries
              .map((entry) {
                final index = entry.key;
                final product = entry.value;
                return DataRow(cells: [
                  DataCell(product.image != null
                      ? Image.file(product.image!, width: 50, height: 50)
                      : Icon(Icons.image)),
                  DataCell(Text(product.id)),
                  DataCell(Text(product.name)),
                  DataCell(Text(product.category)),
                  DataCell(Text(product.price.toStringAsFixed(2))),
                  DataCell(Text(product.date)),
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => _openProductDialog(index: index),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteProduct(index),
                      ),
                    ],
                  )),
                ]);
              })
              .toList(),
        ),
      ),
    );
  }
}
