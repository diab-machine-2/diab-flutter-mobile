import 'package:flutter/material.dart';
import 'package:medical/src/utils/navigator_name.dart';

class Conversations extends StatefulWidget {
  const Conversations({Key? key}) : super(key: key);

  @override
  _ConversationsState createState() => _ConversationsState();
}

class _ConversationsState extends State<Conversations> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: ButtonTheme(
            child:
                ElevatedButton(onPressed: () {
                  Navigator.pushNamed(context, NavigatorName.conversation_chatbot_ai);
                }, child: Text('Conversations'))),
      ),
    );
  }
}
