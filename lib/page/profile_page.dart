import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}
class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  String? _displayName;
  String? _profileImageUrl;
  String? _email;
  File? _image;
  bool _isLoading = false;
  final String defaultAvatarUrl = 'https://firebasestorage.googleapis.com/v0/b/flutteremail-ab337.appspot.com/o/default%2Ff9cdf0993636856d581f8c272513e2a1.jpg?alt=media&token=1a9b2936-b683-45a3-b70a-08772e31ced3';

  @override
  void initState() {
    super.initState();
    _displayName = ""; //設定初始值
    _loadUserProfile(); // 加载用戶個人資料
    // 设置名称文本字段的初始值
    _nameController.text = _displayName ?? '';
    _email = FirebaseAuth.instance.currentUser?.email; // 確保所有的登入方式，電子郵件都能顯示
  }
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userData =
      await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();
        setState(() {
          _displayName = userData['name'];
          _profileImageUrl = userData['profileImageUrl'];
          _email = user.email;
          _nameController.text = _displayName ?? '';
        });
     } else {
      setState(() {
        _displayName = "未登入";
      });
    }
  }
  Future<void> _updateUserProfile(String name, String imageUrl) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (name.isEmpty) {
        name = _displayName ?? ''; // 如果名稱為空，則為空
      }

      // 檢查名稱是否已被使用
      QuerySnapshot nameQuery = await FirebaseFirestore.instance
          .collection('Users')
          .where('name', isEqualTo: name)
          .get();

      if (nameQuery.docs.isNotEmpty) {
        // 如果出現相同的用戶名稱，則顯示錯誤
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('名稱已存在，請更換名稱'),
          backgroundColor: Colors.red,
        ));
        setState(() {
          _isLoading = false;
        });
        return;
      }

      await FirebaseFirestore.instance.collection('Users').doc(user.uid).update({
        'name': name,
        'profileImageUrl': imageUrl,
      });

      setState(() {
        _displayName = name;
        _profileImageUrl = imageUrl;
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String> _uploadImage(File image) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) {
        try {
          await FirebaseStorage.instance.refFromURL(_profileImageUrl!).delete();
        } catch (e) {
          print('Failed to delete old image: $e');
        }
      }

      Reference storageRef = FirebaseStorage.instance.ref().child('users/${user.uid}/profile.jpg');
      UploadTask uploadTask = storageRef.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});
      return await taskSnapshot.ref.getDownloadURL();
    }
    return '';
  }

  void _showImagePickerOption(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (builder) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: MediaQuery.of(context).size.height / 4,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('相簿'),
                onTap: () => _pickImage(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('拍照'),
                onTap: () => _pickImage(ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.outlineVariant,
      appBar: AppBar(
        title: const Text('個人資料', style: TextStyle(color: Colors.black)),
        backgroundColor: Theme.of(context).colorScheme.outlineVariant,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(height: 50),
          GestureDetector(
            onTap: () => _showImagePickerOption(context),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.transparent,
              child: ClipOval(
                child: _image != null
                    ? Image.file(
                  _image!,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                )
                    : _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                    ? Image.network(
                  _profileImageUrl!,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                )
                    : Image.network(
                  defaultAvatarUrl,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(child: Text('電子信箱: ${_email ?? "無"}',
                              style: const TextStyle(fontSize: 16)
                              )),
          Center(child: Text('用戶名稱: ${_displayName ?? ""}',
                              style: const TextStyle(fontSize: 16)
                              )),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: '更改名稱'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              String newName = _nameController.text.trim();
              if (newName.isEmpty) {
                newName = _displayName ?? '';
              }
              setState(() {
                _isLoading = true;
              });
              if (_image != null) {
                try {
                  String imageUrl = await _uploadImage(_image!);
                  await _updateUserProfile(newName, imageUrl);
                } catch (e) {
                  setState(() {
                    _isLoading = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('更新失败，请重试'),
                    backgroundColor: Colors.red,
                  ));
                }
              } else {
                await _updateUserProfile(newName, _profileImageUrl ?? '');
              }
            },
            child: const Text('確認更新個人资料'),
          ),
        ],
      ),
    );
  }
}