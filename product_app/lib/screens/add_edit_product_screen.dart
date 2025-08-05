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
        SnackBar(content: Text(widget.product == null ? 'Added' : 'Updated')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error saving product')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Product' : 'Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child:
                    _imageFile != null
                        ? Image.file(
                          _imageFile!,
                          height: 150,
                          fit: BoxFit.cover,
                        )
                        : widget.product != null &&
                            widget.product!.image.isNotEmpty
                        ? Image.network(
                          "http://10.0.2.2:8000/" + widget.product!.image,
                          height: 150,
                          fit: BoxFit.cover,
                        )
                        : Container(
                          height: 150,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image, size: 80),
                        ),
              ),

              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator:
                    (value) => value!.isEmpty ? 'Enter product name' : null,
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) => value!.isEmpty ? 'Enter category' : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator:
                    (value) =>
                        value!.isEmpty
                            ? 'Enter price'
                            : (double.tryParse(value) == null
                                ? 'Enter valid number'
                                : null),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveProduct,
                child: Text(isEditing ? 'Update' : 'Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
