class Message {
  final String sender; // 'user' or 'ai'
  final String text;

  Message({required this.sender, required this.text});

  Map<String, dynamic> toJson() => {'sender': sender, 'text': text};
  factory Message.fromJson(Map<String, dynamic> json) =>
      Message(sender: json['sender'] as String, text: json['text'] as String);
}
