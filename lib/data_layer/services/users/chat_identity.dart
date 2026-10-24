/// The identity of a one-to-one conversation.
///
/// A chat has no document of its own — `chats/{chatId}` is never written, and
/// the security rules deny it outright. Participants are recovered by parsing
/// the id, so the id *is* the conversation: the same pair always derives the
/// same one, which is what makes a thread reusable and duplicates impossible.
///
/// The ordering below is deliberately left exactly as the Messages list has
/// always computed it. A different ordering would derive different ids and
/// strand every message already sent, so this must not be "improved" without
/// a migration and a simultaneous release of both apps.
String chatIdFor(String user1, String user2) {
  return user1.hashCode <= user2.hashCode
      ? '${user1}_$user2'
      : '${user2}_$user1';
}
