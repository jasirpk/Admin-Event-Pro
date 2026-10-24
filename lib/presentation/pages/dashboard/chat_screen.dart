import 'package:admineventpro/common/assigns.dart';
import 'package:admineventpro/common/style.dart';
import 'package:admineventpro/presentation/components/media/media_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String recipientId;
  final String userName;
  final String imageUrl;

  ChatScreen({
    required this.chatId,
    required this.recipientId,
    required this.userName,
    required this.imageUrl,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _firestore
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add({
        'text': _messageController.text,
        'createdAt': Timestamp.now(),
        'senderId': _auth.currentUser?.uid,

        // Written for parity with the consumer app, which has always sent it.
        // Nothing reads it: ordering stays on `createdAt`, so history and
        // existing messages are unaffected.
        'timestamp': FieldValue.serverTimestamp(),
      });

      // The send is awaited, so the screen may be gone by now — a user can
      // tap send and leave before Firestore answers.
      if (!mounted) return;

      _messageController.clear();
    }
  }

  /// A field from a message document, or null when it is absent.
  ///
  /// `DocumentSnapshot[]` throws on a missing field, so a single malformed
  /// message would otherwise take down the whole conversation. These
  /// documents are written by two separately released apps, so a surprise
  /// has to degrade one bubble rather than the screen.
  Object? _field(DocumentSnapshot message, String name) {
    final data = message.data();

    return data is Map<String, dynamic> ? data[name] : null;
  }

  Widget _buildMessageItem(DocumentSnapshot message) {
    bool isSender = _field(message, 'senderId') == _auth.currentUser?.uid;
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(10.0),
        margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: isSender ? Colors.blue : Colors.grey[700],
          borderRadius: isSender
              ? BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  bottomLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                )
              : BorderRadius.only(
                  topRight: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0),
                  topLeft: Radius.circular(10.0),
                ),
        ),
        child: Column(
          crossAxisAlignment:
              isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              _field(message, 'text') is String
                  ? _field(message, 'text') as String
                  : '',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 5.0),
            Text(
              _formatTimestamp(_field(message, 'createdAt')),
              style: TextStyle(color: Colors.white70, fontSize: 10.0),
            ),
          ],
        ),
      ),
    );
  }

  /// Accepts whatever the document held: a missing or unexpected value
  /// leaves the line blank instead of throwing mid-build.
  String _formatTimestamp(Object? raw) {
    if (raw is! Timestamp) return '';

    var date = raw.toDate();
    var formattedDate = DateFormat('dd MMM yyyy').format(date);
    var formattedTime = DateFormat.jm().format(date);
    return '$formattedDate at $formattedTime';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white38,
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.back,
            color: Colors.white,
          ),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text(
          widget.userName,
          style: TextStyle(fontFamily: 'JacquesFracois', color: Colors.white),
        ),
        actions: [
          // An avatar may be an R2 object key, a legacy URL, or absent.
          // MediaImage tells them apart; NetworkImage could not, and threw
          // on both a key and an empty string.
          MediaImage(
            imagePath: widget.imageUrl,
            placeholder: AssetImage(Assigns.personImage),
            builder: (context, image) => CircleAvatar(backgroundImage: image),
          ),
          sizedboxWidth
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return _buildMessageItem(message);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter a message',
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 15.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                SizedBox(width: 8.0),
                CircleAvatar(
                  radius: 25.0,
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
