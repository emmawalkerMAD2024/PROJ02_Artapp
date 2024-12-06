import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddArtworkPage extends StatefulWidget {
  final String artistId; // The ID of the logged-in artist

  AddArtworkPage({required this.artistId});

  @override
  _AddArtworkPageState createState() => _AddArtworkPageState();
}

class _AddArtworkPageState extends State<AddArtworkPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  bool _availability = true;
  bool _isLoading = false;

  Future<void> _addArtwork() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseFirestore.instance.collection('artworks').add({
          'artistId': widget.artistId, // Assign the artist's ID
          'title': _titleController.text,
          'price': double.parse(_priceController.text),
          'imageUrl': _imageUrlController.text,
          'availability': _availability,
          'createdAt': FieldValue.serverTimestamp(), // Add timestamp for sorting
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Artwork added successfully!')),
        );
        Navigator.pop(context); // Return to the previous page
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add artwork: $error')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Artwork'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: InputDecoration(
                        labelText: 'Image URL',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an image URL';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Availability',
                          style: TextStyle(fontSize: 16),
                        ),
                        Switch(
                          value: _availability,
                          onChanged: (value) {
                            setState(() {
                              _availability = value;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: _addArtwork,
                        child: Text('Add Artwork'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
