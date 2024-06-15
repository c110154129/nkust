import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_auth/firebase_auth.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  Uint8List? _image;
  File? selectedImage;
  final User? user = FirebaseAuth.instance.currentUser;

  Future<void> _addBookToFirestore() async {
    String title = _titleController.text.trim();
    String author = _authorController.text.trim();
    String year = _yearController.text.trim();
    String description = _descriptionController.text.trim();
    int? yearInt = int.tryParse(year);

    if (title.isNotEmpty &&
        author.isNotEmpty &&
        year.isNotEmpty &&
        description.isNotEmpty &&
        selectedImage != null &&
        yearInt != null) {
      String? imageUrl = await _uploadImageToFirebase(selectedImage!);

      if (user != null) {
        try {
          DocumentReference docRef = await FirebaseFirestore.instance.collection('books').add({
            'title': title,
            'author': author,
            'year': yearInt,
            'description': description,
            'imageUrl': imageUrl,
            'userEmail': user!.email,
            'userUID': user!.uid,
            'createdAt': FieldValue.serverTimestamp(),
          });

          String bookId = docRef.id; // 获取文档ID

          Navigator.pop(context);

          // Show successful message or navigate to detail screen with book ID
        } catch (error) {
          print('Failed to add book: $error');
        }
      } else {
        print('User not logged in');
      }
    } else {
      print('Please fill in all required fields and select an image');
      // 添加失敗的消息
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('添加失敗'),
            content: const Text('請確認所有必填字段、年份為數字並選擇一張圖片'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('確定'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<String?> _uploadImageToFirebase(File image) async {
    try {
      String fileName = path.basename(image.path);
      Reference ref = FirebaseStorage.instance.ref().child('book_images/$fileName');
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
        title: const Text('添加書籍'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '書名*',
                  labelStyle: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
              TextField(
                controller: _authorController,
                decoration: const InputDecoration(
                  labelText: '作者*',
                  labelStyle: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
              TextField(
                controller: _yearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '年份*',
                  labelStyle: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '描述*',
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
                  showImagePickerOption(context);},
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(130, 30),
                  padding: const EdgeInsets.symmetric(
                      vertical: 15.0,
                      horizontal: 16.0),),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _addBookToFirestore,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(150, 50),
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 16.0),),
                child: const Text('添加',
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
                    fit: BoxFit.cover,
                  ),
                ),
              )
                  : Container(
                width: 200,
                height: 200,
                decoration: const BoxDecoration(
                  shape: BoxShape.rectangle,
                  image: DecorationImage(
                    image: NetworkImage(
                        'https://example.com/path/to/image.jpg'
                    ),
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
                        _pickImageFromGallery();},
                      child: const SizedBox(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image, size: 70,),
                            Text("圖庫")],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {_pickImageFromCamera();},
                      child: const SizedBox(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Icon(Icons.camera_alt, size: 70,),
                            Text("相機")],
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