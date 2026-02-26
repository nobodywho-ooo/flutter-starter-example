// Delete <think> / </think> tags and everything in between
Stream<String> skipThinkingTags(Stream<String> source) async* {
  bool inThink = false;
  String buffer = '';

  await for (final chunk in source) {
    buffer += chunk;

    while (buffer.isNotEmpty) {
      if (inThink) {
        final endIdx = buffer.indexOf('</think>');
        if (endIdx == -1) {
          buffer = '';
          break;
        }
        buffer = buffer.substring(endIdx + '</think>'.length);
        inThink = false;
      } else {
        final startIdx = buffer.indexOf('<think>');
        if (startIdx == -1) {
          yield buffer;
          buffer = '';
          break;
        }
        if (startIdx > 0) {
          yield buffer.substring(0, startIdx);
        }
        buffer = buffer.substring(startIdx + '<think>'.length);
        inThink = true;
      }
    }
  }

  if (!inThink && buffer.isNotEmpty) {
    yield buffer;
  }
}
