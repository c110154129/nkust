

class Links {
  static late List<Map<String, String>> links = [
    {'url': 'https://www.youtube.com', 'text': 'youtube','image': 'lib/images/Youtube.png'},
    {'url': 'https://elearning.nkust.edu.tw/mooc/index.php', 'text': '高科大教學平台','image': 'lib/images/apple.png'},
    {'url': 'https://mail.google.com/mail','text': 'Gmail','image': 'lib/images/apple.png'},
    {'url': 'https://music.youtube.com/','text': 'YT音樂','image': 'lib/images/apple.png'},
    {'url': 'https://www.flutter.dev','text': 'Flutter1','image': 'lib/images/apple.png'},
    {'url': 'https://www.flutter.dev','text': 'Flutter2','image': 'lib/images/apple.png'},
    {'url': 'https://www.flutter.dev','text': 'Flutter3','image': 'lib/images/apple.png'},
    {'url': 'https://www.flutter.dev','text': 'Flutter4','image': 'lib/images/apple.png'},
    {'url': 'https://www.flutter.dev','text': 'Flutter5','image': 'lib/images/apple.png'},
    {'url': 'https://www.flutter.dev','text': 'Flutter6','image': 'lib/images/apple.png'},
    {'url': 'https://www.flutter.dev','text': 'Flutter7','image': 'lib/images/apple.png'},
    {'url': 'https://www.flutter.dev','text': 'Flutter8','image': 'lib/images/apple.png'},
    {'url': 'https://www.flutter.dev','text': 'Flutter9','image': 'lib/images/apple.png'},
    {'url': 'https://www.flutter.dev','text': 'Flutter10','image': 'lib/images/apple.png'},

  ];

  static String getImage(int index) {
    return links[index]['image']!;
  }

  static String getUrl(int index) {
    return links[index]['url']!;
  }

  static String getText(int index) {
    return links[index]['text']!;
  }
}