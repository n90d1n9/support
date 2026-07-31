import 'package:flutter/material.dart';

enum CommChannel {
  inAppChat,
  email,
  phone,
  whatsApp,
  sms,
  facebookMessenger,
  twitter,
  telegram,
  line,
  weChat,
  viber,
  skype,
  slack,
  microsoftTeams,
  webChat,
  voiceCall,
  videoCall,
  internalNote,
}

extension CommChannelX on CommChannel {
  String get label {
    switch (this) {
      case CommChannel.inAppChat:
        return 'In-App Chat';
      case CommChannel.email:
        return 'Email';
      case CommChannel.phone:
        return 'Phone';
      case CommChannel.whatsApp:
        return 'WhatsApp';
      case CommChannel.sms:
        return 'SMS';
      case CommChannel.facebookMessenger:
        return 'Facebook Messenger';
      case CommChannel.twitter:
        return 'Twitter/X';
      case CommChannel.telegram:
        return 'Telegram';
      case CommChannel.line:
        return 'LINE';
      case CommChannel.weChat:
        return 'WeChat';
      case CommChannel.viber:
        return 'Viber';
      case CommChannel.skype:
        return 'Skype';
      case CommChannel.slack:
        return 'Slack';
      case CommChannel.microsoftTeams:
        return 'Microsoft Teams';
      case CommChannel.webChat:
        return 'Web Chat';
      case CommChannel.voiceCall:
        return 'Voice Call';
      case CommChannel.videoCall:
        return 'Video Call';
      case CommChannel.internalNote:
        return 'Internal Note';
    }
  }

  /// Get icon data for each channel
  IconData get icon {
    switch (this) {
      case CommChannel.inAppChat:
        return Icons.chat_outlined;
      case CommChannel.email:
        return Icons.email_outlined;
      case CommChannel.phone:
        return Icons.phone_outlined;
      case CommChannel.whatsApp:
        return Icons.chat_outlined; // WhatsApp icon would need custom icon
      case CommChannel.sms:
        return Icons.sms_outlined;
      case CommChannel.facebookMessenger:
        return Icons.message_outlined;
      case CommChannel.twitter:
        return Icons.alternate_email;
      case CommChannel.telegram:
        return Icons.send_outlined;
      case CommChannel.line:
        return Icons.chat_bubble_outline;
      case CommChannel.weChat:
        return Icons.wechat;
      case CommChannel.viber:
        return Icons.phone_in_talk_outlined;
      case CommChannel.skype:
        return Icons.video_call_outlined;
      case CommChannel.slack:
        return Icons.business_center_outlined;
      case CommChannel.microsoftTeams:
        return Icons.groups_outlined;
      case CommChannel.webChat:
        return Icons.public_outlined;
      case CommChannel.voiceCall:
        return Icons.call_outlined;
      case CommChannel.videoCall:
        return Icons.videocam_outlined;
      case CommChannel.internalNote:
        return Icons.note_alt_outlined;
    }
  }

  /// Color associated with each channel for visual distinction
  int get colorValue {
    switch (this) {
      case CommChannel.inAppChat:
        return 0xFF2196F3; // Blue
      case CommChannel.email:
        return 0xFFEA4335; // Red
      case CommChannel.phone:
        return 0xFF34A853; // Green
      case CommChannel.whatsApp:
        return 0xFF25D366; // WhatsApp Green
      case CommChannel.sms:
        return 0xFFFFC107; // Amber
      case CommChannel.facebookMessenger:
        return 0xFF0084FF; // Messenger Blue
      case CommChannel.twitter:
        return 0xFF1DA1F2; // Twitter Blue
      case CommChannel.telegram:
        return 0xFF0088CC; // Telegram Blue
      case CommChannel.line:
        return 0xFF00C300; // LINE Green
      case CommChannel.weChat:
        return 0xFF07C160; // WeChat Green
      case CommChannel.viber:
        return 0xFF7360F2; // Viber Purple
      case CommChannel.skype:
        return 0xFF00AFF0; // Skype Blue
      case CommChannel.slack:
        return 0xFF4A154B; // Slack Purple
      case CommChannel.microsoftTeams:
        return 0xFF6264A7; // Teams Purple
      case CommChannel.webChat:
        return 0xFF5F6368; // Gray
      case CommChannel.voiceCall:
        return 0xFF34A853; // Green
      case CommChannel.videoCall:
        return 0xFF0F9D58; // Green
      case CommChannel.internalNote:
        return 0xFF9E9E9E; // Grey
    }
  }

  /// Check if channel is external (customer-facing)
  bool get isExternal => this != CommChannel.internalNote;

  /// Check if channel supports real-time communication
  bool get isRealTime => [
        CommChannel.inAppChat,
        CommChannel.phone,
        CommChannel.whatsApp,
        CommChannel.facebookMessenger,
        CommChannel.twitter,
        CommChannel.telegram,
        CommChannel.line,
        CommChannel.weChat,
        CommChannel.viber,
        CommChannel.skype,
        CommChannel.slack,
        CommChannel.microsoftTeams,
        CommChannel.webChat,
        CommChannel.voiceCall,
        CommChannel.videoCall,
      ].contains(this);

  /// Check if channel supports attachments
  bool get supportsAttachments =>
      this != CommChannel.phone &&
      this != CommChannel.voiceCall &&
      this != CommChannel.videoCall &&
      this != CommChannel.internalNote;

  /// Check if channel is text-based
  bool get isTextBased => [
        CommChannel.inAppChat,
        CommChannel.email,
        CommChannel.whatsApp,
        CommChannel.sms,
        CommChannel.facebookMessenger,
        CommChannel.twitter,
        CommChannel.telegram,
        CommChannel.line,
        CommChannel.weChat,
        CommChannel.viber,
        CommChannel.slack,
        CommChannel.microsoftTeams,
        CommChannel.webChat,
        CommChannel.internalNote,
      ].contains(this);

  /// Check if channel is voice-based
  bool get isVoice =>
      this == CommChannel.phone || this == CommChannel.voiceCall;

  /// Check if channel supports video
  bool get supportsVideo =>
      this == CommChannel.skype ||
      this == CommChannel.microsoftTeams ||
      this == CommChannel.videoCall;

  /// Parse from string label
  static CommChannel fromLabel(String label) {
    return CommChannel.values.firstWhere(
      (e) => e.label.toLowerCase() == label.toLowerCase(),
      orElse: () => CommChannel.inAppChat,
    );
  }
}
