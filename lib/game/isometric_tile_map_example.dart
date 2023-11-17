import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/sprite.dart';

class IsometricTileMapExample extends FlameGame
    with
        MouseMovementDetector,
        MultiTouchTapDetector,
        HasGameRef,
        DragCallbacks {
  static const String description = '''
    Shows an example of how to use the `IsometricTileMapComponent`.\n\n
    Move the mouse over the board to see a selector appearing on the tiles.
  ''';

  var topLeft = Vector2.all(0);
  var actualPosition = Vector2.all(0);

  static const scale = 2.0;
  static const srcTileSize = 32.0;
  static const destTileSize = scale * srcTileSize;

  static const halfSize = false;
  static const tileHeight = scale * (halfSize ? 8.0 : 16.0);
  static const suffix = halfSize ? '-short' : '';

  final originColor = Paint()..color = const Color(0xFFFF00FF);
  final originColor2 = Paint()..color = const Color(0xFFAA55FF);

  late IsometricTileMapComponent base;
  late Selector selector;

  IsometricTileMapExample();

  @override
  Future<void> onLoad() async {
    topLeft = Vector2(gameRef.size.x / 2, gameRef.size.y);
    actualPosition = game.size - topLeft - Vector2(0, destTileSize * 40);

    final tilesetImage = await images.load('tile_maps/tiles$suffix.png');
    final tileset = SpriteSheet(
      image: tilesetImage,
      srcSize: Vector2.all(srcTileSize),
    );

    // var matrix = List.generate(
        // 100, (_) => List.generate(100, (_) => Random().nextInt(4)));
    var matrix = List.generate(
        100, (_) => List.generate(100, (_) => -1));
    add(
      base = IsometricTileMapComponent(
        tileset,
        matrix,
        destTileSize: Vector2.all(destTileSize),
        tileHeight: tileHeight,
        position: actualPosition,
      ),
    );

    add(SpriteComponent(
      sprite: Sprite(await images.load('building.jpeg')),
      size: Vector2.all(500),
      position: topLeft,
      scale: Vector2.all(5),
    ));

    // add(IsometricTileMapComponent(
    //   tileset,
    //   matrix,
    //   destTileSize: Vector2.all(destTileSize),
    //   tileHeight: tileHeight,
    //   position: topLeft + Vector2(0, -destTileSize * 2),
    // ));

    final selectorImage = await images.load('tile_maps/selector$suffix.png');
    add(selector = Selector(destTileSize, selectorImage));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.renderPoint(actualPosition, size: 5, paint: originColor);
    canvas.renderPoint(
      actualPosition.clone()..y -= tileHeight,
      size: 5,
      paint: originColor2,
    );
  }

  @override
  void onMouseMove(PointerHoverInfo info) {
    final screenPosition = info.eventPosition.widget;
    final block = base.getBlock(screenPosition);
    selector.show = base.containsBlock(block);
    selector.position
        .setFrom(actualPosition + base.getBlockRenderPosition(block));
  }

  @override
  void onTapDown(int pointerId, TapDownInfo info) {
    final screenPosition = info.eventPosition.widget;
    final block = base.getBlock(screenPosition);
    base.setBlockValue(block, Random().nextInt(3));
    selector.show = base.containsBlock(block);
    selector.position
        .setFrom(actualPosition + base.getBlockRenderPosition(block));
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    topLeft += event.delta;
    if (topLeft.x < 0) {
      topLeft.x = 0;
    }
    selector.show = false;
    base.position += event.delta;
    actualPosition += event.delta;
  }
}

class Selector extends SpriteComponent {
  bool show = true;

  Selector(double s, Image image)
      : super(
          sprite: Sprite(image, srcSize: Vector2.all(32.0)),
          size: Vector2.all(s),
        );

  @override
  void render(Canvas canvas) {
    if (!show) {
      return;
    }

    super.render(canvas);
  }
}


// cretae a 10x10 matrix where number inside is randam and range from 0 to 3 inclusive 
/**
 [
  
 ]
 */