import 'package:demo_echange/services/auth_fixed.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/Item.dart';
import '../../providers/item_provider.dart';

class AddItemPage extends StatefulWidget {
  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String _selectedCategory = 'Électronique';
  final List<String> _categories = [
    'Électronique',
    'Maison',
    'Sport',
    'Véhicules',
    'Immobilier',
    'Loisirs',
    'Autre'
  ];

  @override
  Widget build(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context);
    final currentUser = AuthFixed.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter un objet'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Titre*',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un titre';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description*',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description';
                  }
                  if (value.length < 10) {
                    return 'La description doit contenir au moins 10 caractères';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Price Field
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Prix journalier (TND)*',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un prix';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price <= 0) {
                    return 'Veuillez entrer un prix valide';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Catégorie*',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner une catégorie';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Location Field
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Lieu*',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un lieu';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),

              // Submit Button
              ElevatedButton(
                onPressed: itemProvider.isLoading
                    ? null
                    : () => _submitForm(currentUser?.uid ?? ''),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                child: itemProvider.isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                  'Publier l\'objet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm(String ownerId) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final newItem = Item(
      id: '', // Will be generated by Firestore
      ownerId: ownerId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      imageUrls: [], // Empty list for now since we're not using images
      dailyPrice: double.parse(_priceController.text),
      category: _selectedCategory,
      location: _locationController.text.trim(),
      isAvailable: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      rating: 0.0,
      totalReviews: 0,
    );

    final itemProvider = Provider.of<ItemProvider>(context, listen: false);
    final success = await itemProvider.createItem(newItem);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Objet publié avec succès!')),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la publication')),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}