import 'package:bonfire/bonfire.dart';
import 'package:example/manual_map/dungeon_map.dart';
import 'package:example/random_map/map_generator.dart';
import 'package:flutter/material.dart';

///
/// Created by
///
/// ─▄▀─▄▀
/// ──▀──▀
/// █▀▀▀▀▀█▄
/// █░░░░░█─█
/// ▀▄▄▄▄▄▀▀
///
/// Rafaelbarbosatec
/// on 31/05/22

class RandomMapGame extends StatefulWidget {
  final Vector2 size;
  const RandomMapGame({Key? key, required this.size}) : super(key: key);

  @override
  State<RandomMapGame> createState() => _RandomMapGameState();
}

class _RandomMapGameState extends State<RandomMapGame> {
  late MapGenerator _mapGenerator;

  @override
  void initState() {
    _mapGenerator = MapGenerator(widget.size, DungeonMap.tileSize);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MapGenerated>(
      future: _mapGenerator.buildMap(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Material(
            color: Colors.black,
            child: Center(
              child: Text(
                'Generation nouse...',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          );
        }
        MapGenerated result = snapshot.data!;
        return BonfireWidget(
          joystick: Joystick(
            keyboardConfig: KeyboardConfig(),
            directional: JoystickDirectional(
              size: 100,
              isFixed: false,
            ),
          ),
          player: result.player,
          cameraConfig: CameraConfig(
            moveOnlyMapArea: true,
            zoom:
                MediaQuery.of(context).size.width / (DungeonMap.tileSize * 20),
          ),
          map: result.map,
          components: result.components,
          delayToHideProgress: const Duration(milliseconds: 500),
        );
      },
    );
  }
}
