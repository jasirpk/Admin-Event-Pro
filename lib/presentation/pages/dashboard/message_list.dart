import 'dart:developer' as developer;

import 'package:admineventpro/common/assigns.dart';
import 'package:admineventpro/data_layer/models/booking_customer.dart';
import 'package:admineventpro/data_layer/services/users/booking_index.dart';
import 'package:admineventpro/data_layer/services/users/chat_identity.dart';
import 'package:admineventpro/presentation/components/media/media_image.dart';
import 'package:admineventpro/presentation/pages/dashboard/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The entrepreneur's conversations.
///
/// Previously this listed `publicProfiles` — every consumer on the platform,
/// filtered to none, because nothing in any repository writes that
/// collection. It is now built from `entrepreneurBookings`, which already
/// holds exactly the right people: the customers this entrepreneur has work
/// with, owner-filtered by the same rule the Bookings screen relies on.
///
/// Conversations themselves are unchanged. Each row derives the existing
/// chat id for the pair, so history opens as it always did.
class MessageListScreen extends StatelessWidget {
  const MessageListScreen({super.key, this.service, this.customers});

  /// Overridden in tests. Defaults to the real Firestore-backed service.
  final BookingIndexService? service;

  /// Overridden in tests, in place of the Firestore stream.
  final Stream<List<BookingCustomer>>? customers;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    // An injected stream short-circuits the service entirely, so a test
    // never reaches Firebase.
    Stream<List<BookingCustomer>>? stream = customers;
    String? entrepreneurUid;

    final index = service ?? BookingIndexService();

    if (stream == null) {
      entrepreneurUid = index.currentEntrepreneurUid;
      stream = entrepreneurUid == null
          ? null
          : index.watchCustomers(entrepreneurUid);
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        title: Text(
          'Messages',
          style: TextStyle(
              color: Colors.white,
              fontSize: screenHeight * 0.028,
              letterSpacing: 1,
              fontWeight: FontWeight.w500),
        ),
      ),
      body: stream == null
          ? const _Message('Sign in to see your conversations.')
          : StreamBuilder<List<BookingCustomer>>(
              stream: stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return _Message(_errorText(snapshot.error!));
                }

                final people = snapshot.data ?? const <BookingCustomer>[];

                if (people.isEmpty) {
                  return const _Message(
                    'No conversations yet.\nCustomers who book you will '
                    'appear here.',
                  );
                }

                return ListView.builder(
                  itemCount: people.length,
                  itemBuilder: (context, i) => _CustomerTile(
                    customer: people[i],
                    service: index,
                  ),
                );
              },
            ),
    );
  }
}

class _CustomerTile extends StatefulWidget {
  const _CustomerTile({required this.customer, required this.service});

  final BookingCustomer customer;
  final BookingIndexService service;

  @override
  State<_CustomerTile> createState() => _CustomerTileState();
}

class _CustomerTileState extends State<_CustomerTile> {
  bool _opening = false;

  void _openChat() {
    if (_opening) return;

    // Always the signed-in entrepreneur, never a value carried by the row.
    final entrepreneurUid = widget.service.currentEntrepreneurUid;

    if (entrepreneurUid == null || entrepreneurUid.isEmpty) return;

    _opening = true;

    final name = widget.customer.name;

    Get.to(() => ChatScreen(
          chatId: chatIdFor(entrepreneurUid, widget.customer.customerUid),
          recipientId: widget.customer.customerUid,
          userName: name.isEmpty ? 'Customer' : name,
          imageUrl: widget.customer.imagePath,
        ))?.whenComplete(() => _opening = false);
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.customer.name;

    return InkWell(
      onTap: _openChat,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white12, borderRadius: BorderRadius.circular(20)),
          child: ListTile(
            // The index carries no customer avatar, so this is the booking's
            // image where there is one and the person placeholder otherwise.
            leading: MediaImage(
              imagePath: widget.customer.imagePath,
              placeholder: AssetImage(Assigns.personImage),
              builder: (context, image) => CircleAvatar(
                maxRadius: 30,
                backgroundImage: image,
              ),
            ),
            title: Text(
              name.isEmpty ? 'Customer' : name,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: MediaQuery.of(context).size.height * 0.024,
                  fontWeight: FontWeight.w500),
            ),
            // Deliberately not an email or phone number: the index holds
            // neither, and the Messages list is not where contact details
            // belong.
            subtitle: Text(
              'Tap to open the conversation',
              style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: MediaQuery.of(context).size.height * 0.018),
            ),
            trailing: IconButton(
              onPressed: _openChat,
              icon: Icon(CupertinoIcons.forward, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

/// What to say when the customer list will not load.
///
/// Only the error code and type are logged — never the message, which can
/// quote the query, and never anything about a customer.
String _errorText(Object error) {
  final String code = error is FirebaseException ? error.code : '';

  developer.log(
    'Customer list failed (code: ${code.isEmpty ? 'none' : code}, '
    'type: ${error.runtimeType})',
    name: 'Messages',
  );

  switch (code) {
    case 'permission-denied':
      return 'Your conversations could not be opened because access is '
          'blocked.\nPlease contact support.';

    case 'unavailable':
    case 'deadline-exceeded':
      return 'Could not reach the server. Check your connection and try '
          'again.';

    default:
      return 'Could not load your conversations. Please try again.';
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ),
    );
  }
}
