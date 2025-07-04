import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:relieflink/models/chat_message.dart';
import 'package:relieflink/models/nearby_user.dart';
import 'package:relieflink/models/user_status.dart';
import 'package:relieflink/services/chat_service.dart';
import 'package:relieflink/services/mesh_service.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String? selectedUserId; // null for broadcast chat
  final String? selectedUserName;

  const ChatScreen({super.key, this.selectedUserId, this.selectedUserName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  ChatService? _chatService;
  List<ChatMessage> _messages = [];
  List<NearbyUser> _nearbyUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _chatService?.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    // This would be passed from the parent widget in a real implementation
    // For now, we'll create a mock mesh service
    final meshService = MeshService(
      onUsersUpdated: (users) {
        if (mounted) setState(() => _nearbyUsers = users);
      },
    );

    _chatService = ChatService(
      meshService: meshService,
      onMessagesUpdated: (messages) {
        if (mounted) {
          setState(() => _messages = messages);
          _scrollToBottom();
        }
      },
    );

    await _chatService!.initialize();

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();
    await _chatService?.sendMessage(
      message,
      recipientId: widget.selectedUserId,
    );
  }

  Future<void> _sendEmergencyMessage() async {
    final emergencyTypes = [
      'Medical Emergency',
      'Fire',
      'Flood',
      'Earthquake',
      'Other',
    ];

    final selectedType = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Select Emergency Type'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  emergencyTypes
                      .map(
                        (type) => ListTile(
                          title: Text(type),
                          onTap: () => Navigator.pop(context, type),
                        ),
                      )
                      .toList(),
            ),
          ),
    );

    if (selectedType != null) {
      final additionalInfo = await showDialog<String>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Additional Information'),
              content: TextField(
                decoration: const InputDecoration(
                  hintText: 'Enter additional details...',
                ),
                maxLines: 3,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, ''),
                  child: const Text('Send'),
                ),
              ],
            ),
      );

      await _chatService?.sendEmergencyMessage(selectedType, additionalInfo);
    }
  }

  Future<void> _sendLocationMessage() async {
    // In a real implementation, this would get the current location
    await _chatService?.sendLocationMessage(0.0, 0.0);
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isMe =
        message.senderId ==
        _chatService?.messages
            .firstWhere(
              (m) => m.senderId == message.senderId,
              orElse: () => message,
            )
            .senderId;

    final messageColor =
        message.type == MessageType.emergency
            ? Colors.red[100]
            : isMe
            ? Colors.blue[100]
            : Colors.grey[100];

    final textColor =
        message.type == MessageType.emergency
            ? Colors.red[900]
            : Colors.black87;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: messageColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isMe) ...[
              Text(
                message.senderName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              message.content,
              style: TextStyle(color: textColor, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('HH:mm').format(message.timestamp),
                  style: TextStyle(color: Colors.grey[600], fontSize: 10),
                ),
                const SizedBox(width: 4),
                if (isMe) ...[
                  Icon(
                    message.status == MessageStatus.sent
                        ? Icons.done
                        : message.status == MessageStatus.delivered
                        ? Icons.done_all
                        : Icons.schedule,
                    size: 12,
                    color:
                        message.status == MessageStatus.delivered
                            ? Colors.blue
                            : Colors.grey,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.selectedUserName ?? 'Broadcast Chat',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFE31837),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Nearby Users'),
                      content: SizedBox(
                        width: double.maxFinite,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _nearbyUsers.length,
                          itemBuilder: (context, index) {
                            final user = _nearbyUsers[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue,
                                child: Text(user.name[0]),
                              ),
                              title: Text(user.name),
                              subtitle: Text(
                                '${user.distance.toStringAsFixed(2)} km away',
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(user.status),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  user.status.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // Connection status
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    color:
                        _chatService?.isActive == true
                            ? Colors.green[50]
                            : Colors.grey[50],
                    child: Row(
                      children: [
                        Icon(
                          _chatService?.isActive == true
                              ? Icons.bluetooth_connected
                              : Icons.bluetooth_disabled,
                          color:
                              _chatService?.isActive == true
                                  ? Colors.green
                                  : Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _chatService?.isActive == true
                              ? 'Connected to ${_nearbyUsers.length} nearby users'
                              : 'Disconnected from mesh network',
                          style: TextStyle(
                            color:
                                _chatService?.isActive == true
                                    ? Colors.green[700]
                                    : Colors.grey[700],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Messages
                  Expanded(
                    child:
                        _messages.isEmpty
                            ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.chat_bubble_outline,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No messages yet',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Start a conversation!',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(8),
                              itemCount: _messages.length,
                              itemBuilder: (context, index) {
                                return _buildMessageBubble(_messages[index]);
                              },
                            ),
                  ),
                  // Input area
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.location_on),
                          onPressed: _sendLocationMessage,
                          color: Colors.grey[600],
                        ),
                        IconButton(
                          icon: const Icon(Icons.warning),
                          onPressed: _sendEmergencyMessage,
                          color: Colors.red,
                        ),
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            maxLines: null,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: _sendMessage,
                          color: const Color(0xFFE31837),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  Color _getStatusColor(UserStatus status) {
    switch (status) {
      case UserStatus.safe:
        return Colors.green;
      case UserStatus.needsHelp:
        return Colors.orange;
      case UserStatus.needsHelp:
        return Colors.orange;
      case UserStatus.unknown:
        return Colors.grey;
    }
  }
}
