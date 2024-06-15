import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class AddEventPage extends StatefulWidget {
  const AddEventPage({super.key});
  @override
  _AddEventPageState createState() => _AddEventPageState();
}
class _AddEventPageState extends State<AddEventPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  Uint8List? _image;
  File? selectedImage;
  final User? user = FirebaseAuth.instance.currentUser;

  Future<void> _addEvent() async {
    String name = _nameController.text.trim();
    String description = _descriptionController.text.trim();
    String url = _urlController.text.trim();

    if (name.isNotEmpty && description.isNotEmpty && selectedImage != null) {
      String? imageUrl = await _uploadImageToFirebase(selectedImage!);
      if (user != null) {
        try {
          Map<String, dynamic> eventData = {
            'name': name,
            'description': description,
            'imageUrl': imageUrl,
            'createdAt': FieldValue.serverTimestamp(),
          };
          if (url.isNotEmpty) {
            eventData['url'] = url;
          }
          FirebaseFirestore.instance.collection('events').add(eventData).then((_) {
            Navigator.pop(context);
          }).catchError((error) {
            print('Failed to add event: $error');});
        } catch (error) {
          print('Failed to add event: $error');}
      } else {
        print('User not logged in');}
    } else {
      print('Please fill in all required fields and select an image');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('添加失敗'),
            content: const Text('請確認活動名稱與描述並選擇一張圖片',
                                 style: TextStyle(fontSize: 16)),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();},
                child: const Text('確定'),),
            ],
          );
        },
      );
    }
  }

  Future<String?> _uploadImageToFirebase(File image) async {
    try {
      String fileName = path.basename(image.path);
      Reference ref = FirebaseStorage.instance.ref().child('events/$fileName');
      UploadTask uploadTask = ref.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print('Failed to upload image: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('新增活動'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '活動名稱*',
                  labelStyle: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '活動描述*',
                  labelStyle: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: '活動連結',
                  labelStyle: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton.icon(
                icon: const Icon(
                  Icons.image,
                  color: Colors.black,
                ),
                label: const Text('添加圖片*',
                    style: TextStyle(fontSize: 15)),
                onPressed: () {
                  showImagePickerOption(context);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(130, 30),
                  padding: const EdgeInsets.symmetric(vertical: 15.0,
                      horizontal: 16.0),
                ),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _addEvent,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(150, 50),
                  padding: const EdgeInsets.symmetric(vertical: 12.0,
                      horizontal: 16.0),
                ),
                child: const Text('新增活動',
                    style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 20.0),
              _image != null
                  ? Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  image: DecorationImage(
                    image: MemoryImage(_image!),
                    fit: BoxFit.cover,),
                ),
              )
                  : Container(
                width: 200,
                height: 200,
                decoration: const BoxDecoration(
                  shape: BoxShape.rectangle,
                  image: DecorationImage(
                    image: NetworkImage(
                        'https://example.com/path/to/image.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void showImagePickerOption(BuildContext context) {
    showModalBottomSheet(
        backgroundColor: Colors.blue[100],
        context: context,
        builder: (builder) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 4.5,
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        _pickImageFromGallery();
                      },
                      child: const SizedBox(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image,
                              size: 70,
                            ),
                            Text("相簿"),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        _pickImageFromCamera();
                      },
                      child: const SizedBox(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 70,
                            ),
                            Text("相機"),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future _pickImageFromGallery() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage == null) return;
    setState(() {
      selectedImage = File(pickedImage.path);
      _image = File(pickedImage.path).readAsBytesSync();
    });
    Navigator.of(context).pop();
  }

  Future _pickImageFromCamera() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedImage == null) return;
    setState(() {
      selectedImage = File(pickedImage.path);
      _image = File(pickedImage.path).readAsBytesSync();
    });
    Navigator.of(context).pop();
  }
}