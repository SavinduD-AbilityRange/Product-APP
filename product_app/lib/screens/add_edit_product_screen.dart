import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? product;
  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _categoryController.text = widget.product!.category;
      _priceController.text = widget.product!.price.toString();
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  void _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final product = Product(
      id: widget.product?.id,
      name: _nameController.text.trim(),
      category: _categoryController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      image: '',
      date: DateTime.now().toIso8601String(),
    );

    bool success;
    if (widget.product == null) {
      success = await ApiService.addProduct(product, _imageFile);
    } else {
      success = await ApiService.updateProduct(
        widget.product!.id!,
        product,
        _imageFile,
      );
    }

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.product == null ? '✅ Product Added' : '✅ Product Updated',
          ),
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('❌ Error saving product')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '✏️ Edit Product' : '➕ Add Product'),
        backgroundColor: Colors.teal,
        elevation: 3,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child:
                            _imageFile != null
                                ? Image.file(_imageFile!, fit: BoxFit.cover)
                                : widget.product != null &&
                                    widget.product!.image.isNotEmpty
                                ? Image.network(
                                  "http://10.0.2.2:8000/${widget.product!.image}",
                                  fit: BoxFit.cover,
                                )
                                : const Center(
                                  child: Icon(
                                    Icons.image,
                                    size: 60,
                                    color: Colors.grey,
                                  ),
                                ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Product Name
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Product Name',
                      prefixIcon: const Icon(Icons.shopping_bag),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator:
                        (value) =>
                            value!.isEmpty ? 'Please enter product name' : null,
                  ),
                  const SizedBox(height: 16),

                  // Category
                  TextFormField(
                    controller: _categoryController,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      prefixIcon: const Icon(Icons.category),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator:
                        (value) =>
                            value!.isEmpty ? 'Please enter category' : null,
                  ),
                  const SizedBox(height: 16),

                  // Price
                  TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: 'Price',
                      prefixIcon: const Icon(Icons.attach_money),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator:
                        (value) =>
                            value!.isEmpty
                                ? 'Please enter price'
                                : (double.tryParse(value) == null
                                    ? 'Enter a valid number'
                                    : null),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.teal,
                      ),
                      onPressed: _saveProduct,
                      icon: Icon(isEditing ? Icons.update : Icons.add),
                      label: Text(isEditing ? 'Update Product' : 'Add Product'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
