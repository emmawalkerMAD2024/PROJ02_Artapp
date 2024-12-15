import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditArtworkPage extends StatefulWidget {
  final String artworkId;

  EditArtworkPage({required this.artworkId});

  @override
  _EditArtworkPageState createState() => _EditArtworkPageState();
}

class _EditArtworkPageState extends State<EditArtworkPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _priceController;
  bool _availability = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchArtworkData();
  }

  Future<void> _fetchArtworkData() async {
    try {
      final artworkDoc = await FirebaseFirestore.instance
          .collection('artworks')
          .doc(widget.artworkId)
          .get();

      if (artworkDoc.exists) {
        final data = artworkDoc.data()!;
        _titleController = TextEditingController(text: data['title']);
        _priceController = TextEditingController(text: data['price'].toString());
        _availability = data['availability'];
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Artwork not found.')),
        );
        Navigator.pop(context);
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load artwork: $error')),
      );
      Navigator.pop(context);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateArtwork() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('artworks').doc(widget.artworkId).update({
          'title': _titleController.text,
          'price': double.parse(_priceController.text),
          'availability': _availability,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Artwork updated successfully!')),
        );
        Navigator.pop(context); // Return to the previous page
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update artwork: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Artwork'),
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
                        onPressed: _updateArtwork,
                        child: Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
