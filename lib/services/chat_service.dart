import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:relieflink/models/chat_message.dart';
import 'package:relieflink/models/nearby_user.dart';
import 'package:relieflink/services/mesh_service.dart';

class ChatService {
  static const String _messagesKey = 'chat_messages';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';

  final MeshService _meshService;
  final Function(List<ChatMessage>) onMessagesUpdated;

  List<ChatMessage> _messages = [];
  String? _currentUserId;
  String? _currentUserName;
  Timer? _syncTimer;
  bool _isActive = false;

  ChatService({
    required MeshService meshService,
    required this.onMessagesUpdated,
  }) : _meshService = meshService;

  bool get isActive => _isActive;
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  Future<void> initialize() async {
    await _loadUserInfo();
    await _loadMessages();
    _startSyncTimer();
    _isActive = true;
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId =
        prefs.getString(_userIdKey) ??
        'user_${DateTime.now().millisecondsSinceEpoch}';
    _currentUserName =
        prefs.getString(_userNameKey) ?? 'User ${_currentUserId!.substring(5)}';

    // Save if not exists
    if (prefs.getString(_userIdKey) == null) {
      await prefs.setString(_userIdKey, _currentUserId!);
      await prefs.setString(_userNameKey, _currentUserName!);
    }
  }

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = prefs.getStringList(_messagesKey) ?? [];

    _messages =
        messagesJson
            .map((json) => ChatMessage.fromJson(jsonDecode(json)))
            .toList();

    // Sort by timestamp
    _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    onMessagesUpdated(_messages);
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson =
        _messages.map((message) => jsonEncode(message.toJson())).toList();

    await prefs.setStringList(_messagesKey, messagesJson);
  }

  Future<void> sendMessage(
    String content, {
    String? recipientId,
    MessageType type = MessageType.text,
  }) async {
    if (_currentUserId == null) return;

    final message = ChatMessage(
      senderId: _currentUserId!,
      senderName: _currentUserName!,
      content: content,
      type: type,
      recipientId: recipientId,
      status: MessageStatus.sending,
    );

    _messages.add(message);
    await _saveMessages();
    onMessagesUpdated(_messages);

    // Simulate sending through mesh network
    _sendThroughMesh(message);
  }

  Future<void> _sendThroughMesh(ChatMessage message) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Update message status to sent
    final index = _messages.indexWhere((m) => m.id == message.id);
    if (index != -1) {
      _messages[index] = _messages[index].copyWith(status: MessageStatus.sent);
      await _saveMessages();
      onMessagesUpdated(_messages);
    }

    // Simulate message delivery to nearby users
    await Future.delayed(const Duration(seconds: 1));
    _simulateMessageDelivery(message);
  }

  void _simulateMessageDelivery(ChatMessage originalMessage) {
    // Create received messages for nearby users
    final nearbyUsers = _meshService.getNearbyUsers();

    for (final user in nearbyUsers) {
      if (user.id != _currentUserId) {
        final receivedMessage = ChatMessage(
          senderId: originalMessage.senderId,
          senderName: originalMessage.senderName,
          content: originalMessage.content,
          type: originalMessage.type,
          recipientId: originalMessage.recipientId,
          status: MessageStatus.delivered,
        );

        _messages.add(receivedMessage);
      }
    }

    _saveMessages();
    onMessagesUpdated(_messages);
  }

  void _startSyncTimer() {
    _syncTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_isActive) {
        _syncWithNearbyUsers();
      }
    });
  }

  void _syncWithNearbyUsers() {
    // Simulate receiving messages from nearby users
    final nearbyUsers = _meshService.getNearbyUsers();
    if (nearbyUsers.isEmpty) return;

    // Simulate random messages from nearby users
    final random = DateTime.now().millisecondsSinceEpoch % nearbyUsers.length;
    final randomUser = nearbyUsers[random];

    if (randomUser.id != _currentUserId && _messages.length % 5 == 0) {
      final simulatedMessages = [
        'Hello! How are you doing?',
        'Any updates on the situation?',
        'I\'m here to help if needed.',
        'Stay safe everyone!',
        'Emergency supplies available here.',
      ];

      final randomMessage =
          simulatedMessages[(random % simulatedMessages.length).toInt()];

      final receivedMessage = ChatMessage(
        senderId: randomUser.id,
        senderName: randomUser.name,
        content: randomMessage,
        type: MessageType.text,
        status: MessageStatus.delivered,
      );

      _messages.add(receivedMessage);
      _saveMessages();
      onMessagesUpdated(_messages);
    }
  }

  Future<void> sendEmergencyMessage(
    String emergencyType,
    String? additionalInfo,
  ) async {
    final content =
        'EMERGENCY: $emergencyType${additionalInfo != null ? ' - $additionalInfo' : ''}';
    await sendMessage(content, type: MessageType.emergency);
  }

  Future<void> sendLocationMessage(double latitude, double longitude) async {
    final content = 'Location: $latitude, $longitude';
    await sendMessage(content, type: MessageType.location);
  }

  Future<void> sendStatusMessage(String status) async {
    await sendMessage(status, type: MessageType.status);
  }

  List<ChatMessage> getMessagesForUser(String? userId) {
    if (userId == null) {
      // Return broadcast messages
      return _messages.where((m) => m.recipientId == null).toList();
    } else {
      // Return direct messages
      return _messages
          .where(
            (m) =>
                m.recipientId == userId ||
                (m.senderId == userId && m.recipientId == _currentUserId),
          )
          .toList();
    }
  }

  List<ChatMessage> getEmergencyMessages() {
    return _messages.where((m) => m.type == MessageType.emergency).toList();
  }

  Future<void> clearMessages() async {
    _messages.clear();
    await _saveMessages();
    onMessagesUpdated(_messages);
  }

  Future<void> deleteMessage(String messageId) async {
    _messages.removeWhere((m) => m.id == messageId);
    await _saveMessages();
    onMessagesUpdated(_messages);
  }

  void dispose() {
    _syncTimer?.cancel();
    _isActive = false;
  }
}
