import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/product.dart';
import '../services/api_service.dart';
import '../services/http_api_service.dart';
import '../widgets/product_table.dart';
import '../widgets/product_card_list.dart';
import '../widgets/product_grid_view.dart';

class ProductTablePage extends StatefulWidget {
  const ProductTablePage({super.key});

  @override
  State<ProductTablePage> createState() => _ProductTablePageState();
}

class _ProductTablePageState extends State<ProductTablePage> {
  final List<Product> _products = [];
  final _formKey = GlobalKey<FormState>();

  // 🔧 CONFIGURATION: Choose your data source
  // 'local' = In-memory storage (for testing)
  // 'backend' = Your external backend API
  final String _dataSource = 'backend'; // Now using real-time backend API
  late final dynamic _apiService;

  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _stockController = TextEditingController();

  dynamic _selectedImage;
  int? _editIndex;
  bool _isLoading = false;
  List<String> _categories = [];
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _initializeService();
    _loadProducts();
    _loadCategories();
  }

  void _initializeService() {
    if (_dataSource == 'backend') {
      _apiService = HttpApiService(); // Use your external backend
    } else {
      _apiService = ApiService(); // Use local storage for testing
    }
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final products = await _apiService.getProducts();
      setState(() {
        _products.clear();
        _products.addAll(products);
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load products: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _apiService.getCategories();
      setState(() => _categories = categories);
    } catch (e) {
      debugPrint('Failed to load categories: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      final Uint8List bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImage = kIsWeb ? bytes : File(pickedFile.path);
      });
    }
  }

  void _openProductDialog({int? index}) {
    if (index != null) {
      _editIndex = index;
      final product = _products[index];
      _nameController.text = product.name;
      _priceController.text = product.price.toString();
      _descriptionController.text = product.description ?? '';
      _stockController.text = product.stockQuantity.toString();
      _selectedImage = product.image;

      // Set category selection
      _selectedCategory = product.category;
      _categoryController.text = product.category;
    } else {
      // Reset form for new product
      _editIndex = null;
      _nameController.clear();
      _categoryController.clear();
      _priceController.clear();
      _descriptionController.clear();
      _stockController.text = '0';
      _selectedImage = null;
      _selectedCategory = null;
    }

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
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
                        child:
                            _selectedImage != null
                                ? (kIsWeb
                                    ? Image.memory(
                                      _selectedImage,
                                      fit: BoxFit.cover,
                                    )
                                    : Image.file(
                                      _selectedImage,
                                      fit: BoxFit.cover,
                                    ))
                                : (_editIndex != null &&
                                        _products[_editIndex!].imageUrl != null
                                    ? Image.network(
                                      _products[_editIndex!].imageUrl!,
                                      fit: BoxFit.cover,
                                    )
                                    : const Icon(
                                      Icons.add_a_photo,
                                      size: 40,
                                      color: Colors.grey,
                                    )),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: "Product Name *",
                      ),
                      validator:
                          (value) =>
                              value?.isEmpty == true
                                  ? "Enter product name"
                                  : null,
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: "Description",
                      ),
                      maxLines: 2,
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: "Category *",
                        hintText: "Select a category",
                      ),
                      items:
                          _categories
                              .map(
                                (category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                          _categoryController.text = value ?? '';
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please select a category";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: "Price *"),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty == true ||
                            double.tryParse(value!) == null) {
                          return "Enter a valid price";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _stockController,
                      decoration: const InputDecoration(
                        labelText: "Stock Quantity",
                      ),
                      keyboardType: TextInputType.number,
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
                onPressed: _isLoading ? null : () => _saveProduct(),
                child:
                    _isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : Text(_editIndex == null ? "Add" : "Update"),
              ),
            ],
          ),
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Store context before async operation
    final navigator = Navigator.of(context);

    try {
      final categoryText = _categoryController.text.trim();

      Product product;

      if (_editIndex != null) {
        // Update existing product
        product = await _apiService.updateProduct(
          id: _products[_editIndex!].id,
          name: _nameController.text,
          category: categoryText,
          price: double.parse(_priceController.text),
          description:
              _descriptionController.text.isEmpty
                  ? null
                  : _descriptionController.text,
          stockQuantity: int.tryParse(_stockController.text) ?? 0,
          image: _selectedImage,
        );

        setState(() => _products[_editIndex!] = product);
        _showSuccessSnackBar('Product updated successfully!');
      } else {
        // Create new product
        product = await _apiService.createProduct(
          name: _nameController.text,
          category: categoryText,
          price: double.parse(_priceController.text),
          description:
              _descriptionController.text.isEmpty
                  ? null
                  : _descriptionController.text,
          stockQuantity: int.tryParse(_stockController.text) ?? 0,
          image: _selectedImage,
        );

        setState(() => _products.add(product));
        _showSuccessSnackBar('Product created successfully!');
      }

      navigator.pop();
    } catch (e) {
      _showErrorSnackBar('Failed to save product: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _deleteProduct(int index) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Confirm Deletion"),
            content: const Text(
              "Are you sure you want to delete this product?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => _confirmDelete(index),
                child: const Text("Delete"),
              ),
            ],
          ),
    );
  }

  Future<void> _confirmDelete(int index) async {
    Navigator.pop(context); // Close dialog

    setState(() => _isLoading = true);
    try {
      final success = await _apiService.deleteProduct(_products[index].id);
      if (success) {
        setState(() => _products.removeAt(index));
        _showSuccessSnackBar('Product deleted successfully!');
      } else {
        _showErrorSnackBar('Failed to delete product');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to delete product: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Manager"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProducts,
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openProductDialog(),
        tooltip: 'Add Product',
        child: const Icon(Icons.add),
      ),
      body:
          _isLoading && _products.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : LayoutBuilder(
                builder: (context, constraints) {
                  // Responsive breakpoints
                  final isSmallScreen = constraints.maxWidth < 600;
                  final isMediumScreen =
                      constraints.maxWidth >= 600 &&
                      constraints.maxWidth < 1024;

                  if (isSmallScreen) {
                    // Mobile layout - Card view
                    return _products.isEmpty
                        ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              "No products added yet. Tap + to add one.",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        )
                        : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: ProductCardList(
                            products: _products,
                            onEdit: _openProductDialog,
                            onDelete: _deleteProduct,
                          ),
                        );
                  } else if (isMediumScreen) {
                    // Tablet layout - Grid view
                    return _products.isEmpty
                        ? const Center(
                          child: Text(
                            "No products added yet. Click + to add one.",
                            style: TextStyle(fontSize: 18),
                          ),
                        )
                        : Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ProductGridView(
                            products: _products,
                            onEdit: _openProductDialog,
                            onDelete: _deleteProduct,
                            crossAxisCount: 2,
                          ),
                        );
                  } else {
                    // Desktop layout - Table view
                    return _products.isEmpty
                        ? const Center(
                          child: Text(
                            "No products added yet. Click + to add one.",
                            style: TextStyle(fontSize: 18),
                          ),
                        )
                        : Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ProductTable(
                            products: _products,
                            onEdit: _openProductDialog,
                            onDelete: _deleteProduct,
                          ),
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
    _descriptionController.dispose();
    _stockController.dispose();
    super.dispose();
  }
}
