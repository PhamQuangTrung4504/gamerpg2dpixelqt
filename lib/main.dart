import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'game/survival_game.dart';
import 'ui/inventory/inventory_overlay.dart';
import 'ui/skills/skill_tree_overlay.dart';
import 'ui/stats/character_stats_overlay.dart';
import 'ui/tutorial/prologue_dialogue_overlay.dart';
import 'ui/tutorial/tutorial_hint_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khóa hướng màn hình ngang và kích hoạt chế độ toàn màn hình cho game RPG
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const GameApp());
}

class GameApp extends StatelessWidget {
  const GameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '2D Survival RPG',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        textTheme: GoogleFonts.vt323TextTheme(ThemeData.dark().textTheme),
      ),
      home: Scaffold(
        body: GameWidget<SurvivalGame>.controlled(
          gameFactory: SurvivalGame.new,
          overlayBuilderMap: {
            'inventory': (context, game) => InventoryOverlay(game: game),
            'StatsOverlay': (context, game) => CharacterStatsOverlay(game: game),
            'SkillOverlay': (context, game) => SkillTreeOverlay(game: game),
            'PrologueDialogueOverlay': (context, game) => PrologueDialogueOverlay(game: game),
            'TutorialHintOverlay': (context, game) => TutorialHintOverlay(game: game),
          },
        ),
      ),
    );
  }
}
