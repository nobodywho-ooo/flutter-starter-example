import 'package:nobodywho/nobodywho.dart' as nobodywho;

typedef AiChatModel = nobodywho.Model;
typedef AiEncoder = nobodywho.Encoder;
typedef AiCrossEncoder = nobodywho.CrossEncoder;
typedef AiTts = nobodywho.TextToSpeech;
typedef AiStt = nobodywho.SpeechToText;

typedef AiChat = nobodywho.Chat;

typedef AiMessage = nobodywho.Message;
typedef AiMessageContent = nobodywho.MessageContent;
typedef AiUserMessage = nobodywho.Message_User;
typedef AiAssistantMessage = nobodywho.Message_Assistant;
typedef AiSystemMessage = nobodywho.Message_System;
typedef AiToolMessage = nobodywho.Message_Tool;

typedef AiTool = nobodywho.Tool;
typedef AiToolCall = nobodywho.ToolCall;

AiMessageContent aiTextContent(String text) => nobodywho.textContent(text);

extension AiMessageContentText on AiMessageContent {
  String get text => nobodywho.MessageContentText(this).text;
}

typedef AiSamplerPresets = nobodywho.SamplerPresets;
typedef AiSamplerBuilder = nobodywho.SamplerBuilder;
typedef AiPrompt = nobodywho.Prompt;
typedef AiTextPart = nobodywho.TextPart;
typedef AiImagePart = nobodywho.ImagePart;
typedef AiAudioPart = nobodywho.AudioPart;
