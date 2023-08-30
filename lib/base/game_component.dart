import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/mixins/pointer_detector.dart';
import 'package:flutter/widgets.dart';

/// Base of the all components in the Bonfire
abstract class GameComponent extends PositionComponent
    with
        BonfireHasGameRef,
        PointerDetectorHandler,
        InternalChecker,
        HasPaint,
        CollisionCallbacks {
  final String _keyIntervalCheckIsVisible = "CHECK_VISIBLE";
  final int _intervalCheckIsVisible = 100;
  Map<String, dynamic>? properties;

  /// When true this component render above all components in game.
  bool aboveComponents = false;

  /// Param checks if this component is visible on the screen
  bool isVisible = false;

  bool enabledCheckIsVisible = true;

  /// Get BuildContext
  BuildContext get context => gameRef.context;

  Rect? _rectCollision;

  @override
  int get priority {
    if (aboveComponents && hasGameRef) {
      return LayerPriority.getAbovePriority(gameRef.highestPriority);
    }
    return LayerPriority.getComponentPriority(_getBottomPriority());
  }

  int _getBottomPriority() {
    return toAbsoluteRect().bottom.round();
  }

  @override
  @mustCallSuper
  void update(double dt) {
    super.update(dt);
    _checkIsVisible(dt);
  }

  void _checkIsVisible(double dt) {
    if (!enabledCheckIsVisible) return;
    if (checkInterval(
      _keyIntervalCheckIsVisible,
      _intervalCheckIsVisible,
      dt,
    )) {
      _onSetIfVisible();
    }
  }

  /// Return screen position of this component.
  Vector2 screenPosition() {
    if (hasGameRef) {
      return gameRef.worldToScreen(
        position,
      );
    }
    return Vector2.zero();
  }

  /// Method that checks if this component is visible on the screen
  @mustCallSuper
  bool isVisibleInCamera() {
    return hasGameRef ? gameRef.isVisibleInCamera(this) : false;
  }

  @override
  @mustCallSuper
  void onRemove() {
    (gameRef as BonfireGame).removeVisible(this);
    super.onRemove();
  }

  void _onSetIfVisible() {
    bool nowIsVisible = isVisibleInCamera();
    if (isHud) {
      nowIsVisible = true;
      enabledCheckIsVisible = false;
    }
    if (nowIsVisible && !isVisible) {
      (gameRef as BonfireGame).addVisible(this);
    }
    if (!nowIsVisible && isVisible) {
      (gameRef as BonfireGame).removeVisible(this);
    }
    isVisible = nowIsVisible;
  }

  @override
  Future<void> addAll(Iterable<Component> components) {
    components.forEach(_confHitBoxRender);
    return super.addAll(components);
  }

  @override
  FutureOr<void> add(Component component) async {
    _confHitBoxRender(component);
    if (component is ShapeHitbox) {
      _rectCollision = null;
    }
    return super.add(component);
  }

  void onGameDetach() {}

  void _confHitBoxRender(Component component) {
    if (component is ShapeHitbox) {
      if (gameRef.showCollisionArea) {
        var paintCollition = Paint()
          ..color = gameRef.collisionAreaColor ?? const Color(0xffffffff);
        if (component is Sensor) {
          paintCollition.color = sensorColor;
        }
        component.paint = paintCollition;
        component.renderShape = true;
      }
    }
  }

  bool get isCollision {
    return children.query<ShapeHitbox>().isNotEmpty;
  }

  Rect get rectCollision {
    if (_rectCollision == null) {
      var list = children.query<ShapeHitbox>();
      if (list.isNotEmpty) {
        _rectCollision = children.query<ShapeHitbox>().fold(
          list.first.toRect(),
          (previousValue, element) {
            return previousValue!.expandToInclude(element.toRect());
          },
        );
      }
    }
    var absoluteRect = toAbsoluteRect();

    if (_rectCollision == null) {
      return absoluteRect;
    }

    return _rectCollision!.translate(absoluteRect.left, absoluteRect.top);
  }

  RaycastResult<ShapeHitbox>? raycast(
    Vector2 direction, {
    Vector2? origin,
    double? maxDistance,
    List<ShapeHitbox> ignoreHitboxes = const [],
  }) {
    var sensorHitBox = <ShapeHitbox>[];
    gameRef.query<Sensor>(onlyVisible: true).forEach((e) {
      sensorHitBox.addAll(e.children.query<ShapeHitbox>());
    });
    return gameRef.raycast(
      Ray2(origin: origin ?? absoluteCenter, direction: direction),
      maxDistance: maxDistance,
      ignoreHitboxes: [
        ...children.query<ShapeHitbox>(),
        ...sensorHitBox,
        ...ignoreHitboxes,
      ],
    );
  }
}
