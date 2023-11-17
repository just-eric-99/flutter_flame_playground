import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flame_playground/game/isometric_tile_map_example.dart';
import 'package:flutter_flame_playground/game/main_game.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GameWidget(
      game: IsometricTileMapExample(),
    );

    // MaterialApp(
    //   home: Scaffold(
    //     body: Center(
    //       child: SizedBox(
    //         width: MediaQuery.of(context).size.width,
    //         height: MediaQuery.of(context).size.height,
    //         child: GameWidget(
    //           game: MainGame(),
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}
