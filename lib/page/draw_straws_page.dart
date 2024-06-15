import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';


class LotteryScreen extends StatefulWidget {
  const LotteryScreen({Key? key});
  @override
  State<LotteryScreen> createState() => _LotteryScreenState();
}
class _LotteryScreenState extends State<LotteryScreen>
    with TickerProviderStateMixin {
  bool isShaking = false;
  String currentItem = '';
  String newItem = '';
  final TextEditingController _textEditingController = TextEditingController();
  List<String> items = [];
  void addItem(String item) {
    setState(() {
      items.add(item);
      newItem = '';
    });}
  void deleteItem(String item) {
    setState(() {
      items.remove(item);
    });}
  void resetItems() {
    setState(() {
      items.clear();
    });}
  String getRandomItem() {
    if (items.isEmpty) return '';
    final random = Random();
    return items[random.nextInt(items.length)];}
  void startShakeAnimation() {
    setState(() {
      isShaking = true;
    });
    int count = 0;
    Timer.periodic(const Duration(milliseconds: 125), (timer) {
      if (count >= 16) {
        timer.cancel();
        setState(() {
          isShaking = false;
          currentItem = getRandomItem();
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('命不由我，命由籤'),
                content: Text(currentItem.isNotEmpty ? currentItem : '無'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('確定'),
                  ),
                ],
              );
            },
          );
        });
      } else {
        count++;
        setState(() {
          isShaking = !isShaking;
        });
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              AnimatedBuilder(
                animation: Tween(
                    begin: -20.0, end: 20.0
                ).animate(
                  CurvedAnimation(
                    parent: AnimationController(
                      vsync: this,
                      duration: const Duration(
                          milliseconds: 250),
                    ),
                    curve: Curves.easeInOut,
                  ),
                ),
                builder: (context, child) {
                  return Transform.rotate(
                    angle: isShaking
                        ? Tween(
                        begin: -20.0, end: 20.0
                    ).evaluate(
                        CurvedAnimation(
                      parent: AnimationController(
                        vsync: this,
                        duration: const Duration(
                            milliseconds: 250),
                      ),
                      curve: Curves.easeInOut,
                    ))
                        : 0,
                    child: Container(
                      width: 160,
                      height: 160,
                      color: Colors.red,
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: () {
                          startShakeAnimation();
                        },
                        child: const Text('抽籤'),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              Column(
                children: [
                  SizedBox(
                    width: 300,
                    child: KeyboardListener(
                      focusNode: FocusNode(),
                      onKeyEvent: (KeyEvent event) {
                        if (event is KeyDownEvent &&
                            event.logicalKey == LogicalKeyboardKey.enter) {
                          addItem(newItem);
                          _textEditingController.clear();
                        }
                      },
                      child: TextField(
                        controller: _textEditingController,
                        onChanged: (value) {
                          newItem = value;
                        },
                        decoration: const InputDecoration(
                          labelText: '輸入美食',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          addItem(newItem);
                          _textEditingController.clear();
                        },
                        child: const Text('新增'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: resetItems,
                        child: const Text('重置'),),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                '已輸入的美食',
                style: TextStyle(fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Container(
                height: MediaQuery.of(context).size.height * 0.5, // 設定一個高度
                child: Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    shrinkWrap: false,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(items[index]),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            deleteItem(items[index]);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}