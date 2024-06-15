import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nkust/page/home_page.dart';

class EditBookScreen extends StatefulWidget {
  final Map<String, dynamic> bookData;

  const EditBookScreen({super.key, required this.bookData});

  @override
  State<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  late Map<String, dynamic> _bookData;

  @override
  void initState() {
    super.initState();
    _bookData = widget.bookData;
    _titleController.text = _bookData['title'];
    _authorController.text = _bookData['author'];
    _yearController.text = _bookData['year'].toString();
    _descriptionController.text = _bookData['description'];
  }

  Future<void> _updateBook() async {
    String title = _titleController.text.trim();
    String author = _authorController.text.trim();
    String year = _yearController.text.trim();
    String description = _descriptionController.text.trim();
    String id = _bookData['id'];
    String imageUrl = _bookData['imageUrl'];  // 確保保留圖片 URL
    String userEmail = _bookData['userEmail'];  // 確保保留賣家郵件

    if (title.isNotEmpty &&
        author.isNotEmpty &&
        year.isNotEmpty &&
        description.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('books').doc(id).update({
          'title': title,
          'author': author,
          'year': int.tryParse(year) ?? 0,
          'description': description,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        Map<String, dynamic> updatedBookData = {
          'id': id,
          'title': title,
          'author': author,
          'year': int.tryParse(year) ?? 0,
          'description': description,
          'imageUrl': imageUrl,  // 保留圖片 URL
          'userEmail': userEmail,  // 保留賣家郵件
          'userUID': _bookData['userUID'],  // 保留賣家 UID
        };

        Navigator.pop(context, updatedBookData); // 返回更新的書籍數據到上一個屏幕
      } catch (error) {
        _showErrorDialog('更新失敗', '請檢查網絡連接並重試');
      }
    } else {
      _showErrorDialog('更新失敗', '所有字段必須填寫');
    }
  }

  Future<void> _confirmDelete() async {
    bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('刪除書籍'),
          content: Text('確定要刪除這本書嗎？'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Return false on cancel
              },
              child: Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Return true on confirm
              },
              child: Text('確定'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      try {
        String id = _bookData['id'];

        await FirebaseFirestore.instance.collection('books').doc(id).delete();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Homepage(initialTabIndex: 1)), // 假设二手书籍标签的索引是 2
              (Route<dynamic> route) => false,
        );
      } catch (error) {
        _showErrorDialog('刪除失敗', '請檢查網絡連接並重試');
      }
    }
  }

  void _showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('編輯書籍'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 將對齊方式設置為開始
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: '書名'),
            ),
            TextField(
              controller: _authorController,
              decoration: InputDecoration(labelText: '作者'),
            ),
            TextField(
              controller: _yearController,
              decoration: InputDecoration(labelText: '年份'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: '描述'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateBook,
              child: Text('更新書籍'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _confirmDelete,
        tooltip: '刪除書籍',
        child: Icon(Icons.delete),
        backgroundColor: Colors.red,
      ),
    );
  }
}