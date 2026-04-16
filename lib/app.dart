import 'package:flutter/material.dart';
import 'package:flutter_starter_example/screens/screens.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

enum Screen {
  chat('Chat', LucideIcons.messageCircle),
  embeddings('Embeddings', LucideIcons.search),
  rag('Rag', LucideIcons.file),
  vision('Vision', LucideIcons.image),
  hearing('Hearing', LucideIcons.audioLines);

  final String name;
  final IconData icon;
  const Screen(this.name, this.icon);
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  Screen currentScreen = Screen.chat;

  Widget _buildListTile(Screen screen, ShadTextTheme textTheme) {
    return ListTile(
      leading: Icon(screen.icon),
      title: Text(screen.name, style: textTheme.h4),
      onTap: () => _selectScreen(screen),
    );
  }

  void _selectScreen(Screen screen) {
    Navigator.pop(context);
    setState(() {
      currentScreen = screen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(currentScreen.name, style: theme.textTheme.h4),
        backgroundColor: theme.colorScheme.background,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      backgroundColor: theme.colorScheme.background,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(child: Text('NobodyWho', style: textTheme.h4)),
            for (final screen in Screen.values)
              _buildListTile(screen, textTheme),
          ],
        ),
      ),
      body: SafeArea(
        child: switch (currentScreen) {
          Screen.chat => ChatScreen(),
          Screen.embeddings => EmbeddingsScreen(),
          Screen.rag => RagScreen(),
          Screen.vision => VisionScreen(),
          Screen.hearing => HearingScreen(),
        },
      ),
    );
  }
}
