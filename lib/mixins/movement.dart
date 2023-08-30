import 'dart:math';

import 'package:bonfire/bonfire.dart';

/// Mixin responsible for adding movements
mixin Movement on GameComponent {
  static const diaginalReduction = 0.7853981633974483;
  static const speedDefault = 80.0;
  final Vector2 _acceleration = Vector2.all(0);

  double dtUpdate = 0;
  double speed = speedDefault;
  double _lastSpeed = speedDefault;
  double velocityRadAngle = 0.0;
  Vector2 lastDisplacement = Vector2.zero();
  Vector2 _velocity = Vector2.zero();
  Direction lastDirection = Direction.right;
  Direction lastDirectionHorizontal = Direction.right;
  Direction lastDirectionVertical = Direction.down;
  bool movementOnlyVisible = true;

  Vector2 get acceleration => velocity / dtUpdate;

  bool get isIdle => _velocity.isZero();
  Vector2 get velocity => _velocity;
  double get diagonalSpeed => speed * diaginalReduction;
  double get dtSpeed => speed * dtUpdate;
  double get dtDiagonalSpeed => diagonalSpeed * dtUpdate;
  set velocity(Vector2 velocity) {
    _velocity = velocity;
    _updateLastDirection(_velocity);
  }

  void setVelocityAxis({double? x, double? y}) {
    _velocity.x = x ?? _velocity.x;
    _velocity.y = y ?? _velocity.y;
  }

  /// You can override this method to listen the movement of this component
  void onMove(
    double speed,
    Vector2 displacement,
    Direction direction,
    double angle,
  ) {}

  Vector2 onApplyAcceleration(Vector2 acceleration, double dt) {
    return velocity..add(acceleration * dt);
  }

  void onApplyDisplacement(double dt) {
    position += lastDisplacement = onApplyAcceleration(_acceleration, dt) * dt;
    _updateLastDirection(lastDisplacement);
  }

  /// Method used to translate component
  void translate(Vector2 displacement) {
    lastDisplacement = displacement;
    _updateLastDirection(lastDisplacement);
    position.add(displacement);
  }

  void moveLeftOnce({double? speed}) {
    _lastSpeed = speed ?? this.speed;
    setVelocityAxis(x: -_lastSpeed);
    onApplyDisplacement(dtUpdate);
    _velocity.add(Vector2(_lastSpeed, 0));
    setVelocityAxis(x: 0);
  }

  void moveRightOnce({double? speed}) {
    _lastSpeed = speed ?? this.speed;
    setVelocityAxis(x: _lastSpeed);
    onApplyDisplacement(dtUpdate);
    setVelocityAxis(x: 0);
  }

  void moveUpOnce({double? speed}) {
    _lastSpeed = speed ?? this.speed;
    setVelocityAxis(y: -_lastSpeed);
    onApplyDisplacement(dtUpdate);
    setVelocityAxis(y: 0);
  }

  void moveDownOnce({double? speed}) {
    _lastSpeed = speed ?? this.speed;
    setVelocityAxis(y: _lastSpeed);
    onApplyDisplacement(dtUpdate);
    setVelocityAxis(y: 0);
  }

  void moveDownRightOnce({double? speed}) {
    _lastSpeed = (speed ?? this.speed) * diaginalReduction;
    setVelocityAxis(y: _lastSpeed, x: _lastSpeed);
    onApplyDisplacement(dtUpdate);
    setVelocityAxis(y: 0, x: 0);
  }

  void moveDownLeftOnce({double? speed}) {
    _lastSpeed = (speed ?? this.speed) * diaginalReduction;
    setVelocityAxis(y: _lastSpeed, x: -_lastSpeed);
    onApplyDisplacement(dtUpdate);
    setVelocityAxis(y: 0, x: 0);
  }

  void moveUpRightOnce({double? speed}) {
    _lastSpeed = (speed ?? this.speed) * diaginalReduction;
    setVelocityAxis(y: -_lastSpeed, x: _lastSpeed);
    onApplyDisplacement(dtUpdate);
    setVelocityAxis(y: 0, x: 0);
  }

  void moveUpLeftOnce({double? speed}) {
    _lastSpeed = (speed ?? this.speed) * diaginalReduction;
    setVelocityAxis(y: -_lastSpeed, x: -_lastSpeed);
    onApplyDisplacement(dtUpdate);
    setVelocityAxis(y: 0, x: 0);
  }

  /// Move player to Up
  void moveUp({double? speed}) {
    _lastSpeed = speed ?? this.speed;
    setVelocityAxis(y: -_lastSpeed);
  }

  /// Move player to Down
  void moveDown({double? speed, bool setZeroCrossVelocity = false}) {
    _lastSpeed = speed ?? this.speed;
    setVelocityAxis(y: _lastSpeed);
  }

  /// Move player to Left
  void moveLeft({double? speed, bool setZeroCrossVelocity = false}) {
    _lastSpeed = speed ?? this.speed;
    setVelocityAxis(x: -_lastSpeed);
  }

  /// Move player to Right
  void moveRight({double? speed, bool setZeroCrossVelocity = false}) {
    _lastSpeed = speed ?? this.speed;
    setVelocityAxis(x: _lastSpeed);
  }

  /// Move player to Up and Right
  void moveUpRight({double? speed}) {
    _lastSpeed = (speed ?? this.speed) * diaginalReduction;
    velocity = Vector2(_lastSpeed, -_lastSpeed);
  }

  /// Move player to Up and Left
  void moveUpLeft({double? speed}) {
    _lastSpeed = (speed ?? this.speed) * diaginalReduction;
    velocity = Vector2(-_lastSpeed, -_lastSpeed);
  }

  /// Move player to Down and Left
  void moveDownLeft({double? speed}) {
    _lastSpeed = (speed ?? this.speed) * diaginalReduction;
    velocity = Vector2(-_lastSpeed, _lastSpeed);
  }

  /// Move player to Down and Right
  void moveDownRight({double? speed}) {
    _lastSpeed = (speed ?? this.speed) * diaginalReduction;
    velocity = Vector2(_lastSpeed, _lastSpeed);
  }

  /// Move Player to direction by radAngle
  void moveFromAngle(double angle, {double? speed}) {
    _lastSpeed = speed ?? this.speed;
    velocity = BonfireUtil.vector2ByAngle(angle, intencity: _lastSpeed);
  }

  void stopMove({bool forceIdle = false, bool isX = true, bool isY = true}) {
    if (isIdle && !forceIdle) return;
    setZeroVelocity(isX: isX, isY: isY);
    idle();
  }

  void idle() {}

  void setZeroVelocity({bool isX = true, bool isY = true}) {
    _velocity = _velocity.copyWith(
      x: isX ? 0.0 : _velocity.x,
      y: isY ? 0.0 : _velocity.y,
    );
    if (isX && isY) {
      velocityRadAngle = 0.0;
    }
  }

  void stopFromCollision({bool isX = true, bool isY = true}) {
    setZeroVelocity(isX: isX, isY: isY);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isVisible || !movementOnlyVisible) {
      _updatePosition(dt);
    }
  }

  void moveFromDirection(
    Direction direction, {
    Vector2? speedVector,
    bool enabledDiagonal = true,
  }) {
    switch (direction) {
      case Direction.left:
        moveLeft();
        break;
      case Direction.right:
        moveRight();
        break;
      case Direction.up:
        moveUp();
        break;
      case Direction.down:
        moveDown();
        break;
      case Direction.upLeft:
        if (enabledDiagonal) {
          moveUpLeft();
        } else {
          moveRight();
        }
        break;
      case Direction.upRight:
        if (enabledDiagonal) {
          moveUpRight();
        } else {
          moveRight();
        }
        break;
      case Direction.downLeft:
        if (enabledDiagonal) {
          moveDownLeft();
        } else {
          moveLeft();
        }
        break;
      case Direction.downRight:
        if (enabledDiagonal) {
          moveDownRight();
        } else {
          moveRight();
        }
        break;
    }
  }

  void _updateLastDirection(Vector2 velocity) {
    if (velocity.isZero()) return;
    velocityRadAngle = atan2(velocity.y, velocity.x);

    if (velocity.x > 0) {
      lastDirectionHorizontal = Direction.right;
    } else if (velocity.x < 0) {
      lastDirectionHorizontal = Direction.left;
    }

    if (velocity.y > 0) {
      lastDirectionVertical = Direction.down;
    } else if (velocity.y < 0) {
      lastDirectionVertical = Direction.up;
    }

    if (velocity.y != 0 && velocity.x == 0) {
      if (velocity.y > 0) {
        lastDirection = Direction.down;
      } else if (velocity.y < 0) {
        lastDirection = Direction.up;
      }
      return;
    }
    if (velocity.x != 0 && velocity.y == 0) {
      if (velocity.x > 0) {
        lastDirection = Direction.right;
      } else if (velocity.x < 0) {
        lastDirection = Direction.left;
      }
      return;
    }

    if (velocity.x > 0 && velocity.y > 0) {
      lastDirection = Direction.downRight;
    } else if (velocity.x > 0 && velocity.y < 0) {
      lastDirection = Direction.upRight;
    } else if (velocity.x < 0 && velocity.y > 0) {
      lastDirection = Direction.downLeft;
    } else if (velocity.x < 0 && velocity.y < 0) {
      lastDirection = Direction.upLeft;
    }
  }

  void _requestUpdatePriority() {
    if (hasGameRef) {
      (gameRef as BonfireGame).requestUpdatePriority();
    }
  }

  void _updatePosition(double dt) {
    onApplyDisplacement(dt);
    dtUpdate = dt;
    if (!lastDisplacement.isZero()) {
      if (lastDirection == Direction.up || lastDirection == Direction.down) {
        _requestUpdatePriority();
      }
      onMove(_lastSpeed, lastDisplacement, lastDirection, velocityRadAngle);
    }
  }

  bool isStoped() {
    return velocity.x < 0.01 && velocity.y < 0.01;
  }

  // Move to position. return true whether move.
  bool moveToPosition(
    Vector2 position, {
    double? speed,
    bool useCenter = true,
  }) {
    double diagonalSpeed = (speed ?? this.speed) * diaginalReduction;
    double dtSpeed = (speed ?? this.speed) * dtUpdate;
    double dtDiagonalSpeed = diagonalSpeed * dtUpdate;

    double diffX =
        position.x - (useCenter ? absoluteCenter : absolutePosition).x;
    double diffY =
        position.y - (useCenter ? absoluteCenter : absolutePosition).y;

    if (diffX.abs() < dtSpeed && diffY.abs() < dtSpeed) {
      return false;
    } else {
      if (diffX.abs() > dtDiagonalSpeed && diffY.abs() > dtDiagonalSpeed) {
        if (diffX > 0 && diffY > 0) {
          if (diffX.abs() < dtDiagonalSpeed * 2) {
            moveRightOnce(speed: speed);
          } else if (diffY.abs() < dtDiagonalSpeed * 2) {
            moveDownOnce(speed: speed);
          } else {
            moveDownRight(speed: speed);
          }
        } else if (diffX < 0 && diffY > 0) {
          if (diffX.abs() < dtDiagonalSpeed * 2) {
            moveLeftOnce(speed: speed);
          } else if (diffY.abs() < dtDiagonalSpeed * 2) {
            moveDownOnce(speed: speed);
          } else {
            moveDownLeft(speed: speed);
          }
        } else if (diffX > 0 && diffY < 0) {
          if (diffX.abs() < dtDiagonalSpeed * 2) {
            moveRightOnce(speed: speed);
          } else if (diffY.abs() < dtDiagonalSpeed * 2) {
            moveUpOnce(speed: speed);
          } else {
            moveUpRight(speed: speed);
          }
        } else if (diffX < 0 && diffY < 0) {
          if (diffX.abs() < dtDiagonalSpeed * 2) {
            moveLeftOnce(speed: speed);
          } else if (diffY.abs() < dtDiagonalSpeed * 2) {
            moveUpOnce(speed: speed);
          } else {
            moveUpLeft(speed: speed);
          }
        }
      } else if (diffX.abs() > dtSpeed) {
        if (diffX > 0) {
          moveRight(speed: speed);
        } else if (diffX < 0) {
          moveLeft(speed: speed);
        }
      } else if (diffY.abs() > dtSpeed) {
        if (diffY > 0) {
          moveDown(speed: speed);
        } else if (diffY < 0) {
          moveUp(speed: speed);
        }
      } else {
        return false;
      }
      return true;
    }
  }
}
