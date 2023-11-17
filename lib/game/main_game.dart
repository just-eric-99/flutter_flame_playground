import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter_flame_playground/game/flame_isometric.dart';
import 'package:tiled/tiled.dart';

enum ObjectType {
  BUILDINGS('buildings');

  final String value;

  const ObjectType(this.value);
}

class MainGame extends FlameGame with HasGameRef, DragCallbacks {
  List<IsometricTileMapComponent> tileMapComponents = [];
  List<SpriteComponent> spriteComponents = [];
  List<TappableSpriteComponent> tappableSpriteComponents = [];
  Vector2 velocity = Vector2.zero();

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final gameSize = gameRef.size;
    FlameIsometric flameIsometric = await FlameIsometric.create(
      tileMap: 'tilemap.png',
      tmx: 'tiles/tilemap.tmx',
    );

    var verticalTileNumber = flameIsometric.matrixList[0].length;
    var heightPerTile = flameIsometric.tileHeight.toDouble();
    var widthPerTile = flameIsometric.tileWidth.toDouble();
    var totalHeight = verticalTileNumber * heightPerTile;
    var padding = gameSize.y - (totalHeight - 6 * heightPerTile);
    var initialPosition = Vector2(gameSize.x / 2, padding);

    for (var i = 0; i < flameIsometric.layerLength; i++) {
      tileMapComponents.add(
        IsometricTileMapComponent(
          flameIsometric.tileset,
          flameIsometric.matrixList[i],
          destTileSize: flameIsometric.srcTileSize,
          position: initialPosition,
        ),
      );
    }

    for (var i = 0; i < tileMapComponents.length; i++) {
      add(tileMapComponents[i]);
    }

    final objectGroup =
        flameIsometric.tileMapTmx.layers.whereType<ObjectGroup>();
    print(objectGroup);

    final building = await Flame.images.load('building2.png');

    const buildingSize = 400.0;
    for (var element in objectGroup) {
      if (element.name == ObjectType.BUILDINGS.value) {
        for (var object in element.objects) {
          print(object.name);
          var cartX = object.x.toDouble();
          var cartY = object.y.toDouble();
          var isoX = -cartY + cartX;
          var isoY = (cartX + cartY) / 2;

          tappableSpriteComponents.add(
            TappableSpriteComponent(
              name: object.name,
              size: Vector2.all(buildingSize),
              position: initialPosition + Vector2(isoX, isoY),
              sprite: Sprite(building),
            ),
          );
        }
      }
    }

    for (var i = 0; i < tappableSpriteComponents.length; i++) {
      add(tappableSpriteComponents[i]);
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    velocity = Vector2.zero();
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    velocity = event.velocity;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    for (var tileMap in tileMapComponents) {
      tileMap.position += event.delta / 2;
    }
    for (var tappableSprite in tappableSpriteComponents) {
      tappableSprite.position += event.delta / 2;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    for (var tileMap in tileMapComponents) {
      tileMap.position += velocity * dt;
    }

    for (var tappableSprite in tappableSpriteComponents) {
      tappableSprite.position += velocity * dt;
    }

    velocity = velocity * 0.9;

    if (velocity.y * velocity.y < 0.001) {
      velocity = Vector2.zero();
    }
  }

  @override
  void onDispose() {
    if (tileMapComponents.isNotEmpty) {
      for (var i = 0; i < tileMapComponents.length; i++) {
        remove(tileMapComponents[i]);
      }
    }

    super.onDispose();
  }
}

class TappableSpriteComponent extends SpriteComponent with TapCallbacks {
  final String name;

  TappableSpriteComponent({
    required this.name,
    required Vector2 position,
    required Vector2 size,
    required Sprite sprite,
  }) : super(
          position: position,
          size: size,
          sprite: sprite,
        );
  @override
  void onTapDown(TapDownEvent event) {
    print('tapped $name');
    super.onTapDown(event);
  }
}
