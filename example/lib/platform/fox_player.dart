import 'package:bonfire/bonfire.dart';
import 'package:example/platform/platform_spritesheet.dart';
import 'package:flutter/services.dart';

class FoxPlayer extends PlatformPlayer with HandleForces {
  FoxPlayer({
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2.all(33),
          speed: 50,
          animation: PlatformAnimations(
            idleRight: PlatformSpritesheet.playerIdleRight,
            runRight: PlatformSpritesheet.playerRunRight,
            jump: PlatformJumpAnimations(
              jumpUpRight: PlatformSpritesheet.playerJumpUp,
              jumpDownRight: PlatformSpritesheet.playerJumpDown,
            ),
          ),
        );

  @override
  void joystickChangeDirectional(JoystickDirectionalEvent event) {
    if (event.directional == JoystickMoveDirectional.MOVE_LEFT ||
        event.directional == JoystickMoveDirectional.MOVE_RIGHT ||
        event.directional == JoystickMoveDirectional.IDLE) {
      super.joystickChangeDirectional(event);
    }
  }

  @override
  void joystickAction(JoystickActionEvent event) {
    if (event.event == ActionEvent.DOWN &&
        (event.id == LogicalKeyboardKey.space.keyId || event.id == 1)) {
      jump(speed: 200);
    }
    super.joystickAction(event);
  }

  @override
  Future<void> onLoad() {
    add(
      RectangleHitbox(
        size: size / 2,
        position: Vector2(size.x / 4, size.y / 2),
        isSolid: true,
      ),
    );
    return super.onLoad();
  }
}
