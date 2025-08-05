import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
  String name = '';
  String category = '';
  double price = 0.0;
  File? imageFile;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      name = widget.product!.name;
      category = widget.product!.category;
      price = widget.product!.price;
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        bool success;
        if (widget.product == null) {
          success = await ApiService.addProduct(
            name,
            category,
            price,
            imageFile,
          );
        } else {
          success = await ApiService.updateProduct(
            widget.product!.id,
            name,
            category,
            price,
            imageFile,
          );
        }
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.product == null ? 'Product added' : 'Product updated',
              ),
            ),
          );
          Navigator.pop(context);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Failed to save product. Please check your connection.',
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Product' : 'Add Product'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Product Name
              TextFormField(
                initialValue: name,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  hintText: 'e.g., Teddy Bear',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) => name = val,
                validator:
                    (val) =>
                        val == null || val.isEmpty
                            ? 'Enter product name'
                            : null,
              ),
              const SizedBox(height: 12),

              // Category
              TextFormField(
                initialValue: category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  hintText: 'e.g., Toys',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) => category = val,
                validator:
                    (val) =>
                        val == null || val.isEmpty ? 'Enter category' : null,
              ),
              const SizedBox(height: 12),

              // Price
              TextFormField(
                initialValue: price == 0.0 ? '' : price.toString(),
                decoration: const InputDecoration(
                  labelText: 'Price',
                  hintText: 'e.g., 19.99',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (val) => price = double.tryParse(val.trim()) ?? 0.0,
                validator:
                    (val) =>
                        val == null || double.tryParse(val) == null
                            ? 'Enter a valid price'
                            : null,
              ),
              const SizedBox(height: 16),

              // Image Preview
              if (imageFile != null && !kIsWeb)
                Image.file(imageFile!, height: 180, fit: BoxFit.cover)
              else if (imageFile != null && kIsWeb)
                Image.network(
                 
                  '',
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 180,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Text(
                          'Image Selected\n(Preview not available on web)',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                )
              else if (isEdit && widget.product!.imageUrl.isNotEmpty)
                Image.network(
                  widget.product!.imageUrl,
                  height: 180,
                  fit: BoxFit.cover,
                )
              else
                const SizedBox(
                  height: 180,
                  child: Center(child: Text('No Image Selected')),
                ),

              const SizedBox(height: 8),

              // Pick Image Button
              TextButton.icon(
                icon: const Icon(Icons.image),
                label: const Text('Choose Image'),
                onPressed: _pickImage,
              ),
              const SizedBox(height: 20),

              // Submit Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _submit,
                child: Text(
                  isEdit ? 'Update Product' : 'Add Product',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
