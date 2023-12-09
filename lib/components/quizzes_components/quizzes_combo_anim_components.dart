import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'dart:math';

abstract class QuizzesComboAnimComponentsFunctions {
  static Future<void> run(BuildContext context, Function incrementFunction, int amount) async {
    OverlayEntry overlayEntry = OverlayEntry(builder: (context) {
      return IgnorePointer(ignoring: true, child: GameWidget.controlled(gameFactory: () => GameWorld(incrementFunc: incrementFunction, amount: amount)));
    });
    Overlay.of(context).insert(overlayEntry);
    await Future.delayed(const Duration(seconds: 3, milliseconds: 500));
    overlayEntry.remove();
  }
}

class GameWorld extends Forge2DGame {
  GameWorld({required this.incrementFunc, required this.amount})
      : super(
          gravity: Vector2(0, 100.0),
        );

  final Function incrementFunc;
  final int amount;

  DateTime creationTime = DateTime.now();

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    world.addAll(createBoundaries());
    world.addAll(List.generate(amount, (index) => Ball(incrementFunc: incrementFunc)));
  }

  List<Component> createBoundaries() {
    final visibleRect = camera.visibleWorldRect;
    final topLeft = visibleRect.topLeft.toVector2();
    final topRight = visibleRect.topRight.toVector2();
    final bottomRight = visibleRect.bottomRight.toVector2();
    final bottomLeft = visibleRect.bottomLeft.toVector2();

    return [
      Wall(topLeft, topRight),
      Wall(topRight, bottomRight),
      Wall(bottomLeft, bottomRight),
      Wall(topLeft, bottomLeft),
    ];
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    for (var component in world.children.whereType<Wall>()) {
      world.remove(component);
    }

    world.addAll(createBoundaries());
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (DateTime.now().difference(creationTime).inSeconds > 1.4) {
      //* Set all objects velocity to zero
      for (var element in world.physicsWorld.bodies) {
        element.linearVelocity = Vector2.zero();
      }
    }
  }
}

class Wall extends BodyComponent {
  final Vector2 start;
  final Vector2 end;

  Wall(this.start, this.end);

  @override
  Body createBody() {
    final shape = EdgeShape()..set(start, end);
    final fixtureDef = FixtureDef(shape)..friction = 0.4;

    final bodyDef = BodyDef()..position = Vector2.zero();
    body = world.createBody(bodyDef)..createFixture(fixtureDef);
    return world.createBody(BodyDef()..type = BodyType.static)..createFixtureFromShape(shape);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawLine(start.toOffset(), end.toOffset(), Paint()..color = Colors.green);
  }
}

class Ball extends BodyComponent {
  Ball({required this.incrementFunc}) : super();
  DateTime creationTime = DateTime.now();

  final Function incrementFunc;

  @override
  Body createBody() {
    final shape = CircleShape()..radius = 1;
    final fixtureDef = FixtureDef(shape)
      ..friction = 0.4
      ..restitution = 0.9
      ..filter.groupIndex = -1;
    final bodyDef = BodyDef()
      ..position = Vector2.zero()
      ..angularDamping = 0.8
      ..type = BodyType.dynamic;
    body = world.createBody(bodyDef)..createFixture(fixtureDef);
    body.applyLinearImpulse(Vector2(Random().nextInt(5001) - 2500, -500));
    return body;
  }

  double forceMultiplier = 0.5;
  bool beginForceMultiplier = false;

  @override
  void update(double dt) {
    super.update(dt);
    final visibleRect = camera.visibleWorldRect;
    if (beginForceMultiplier) forceMultiplier += 0.1;

    // Check if 2 seconds have passed since the creation of the ball
    if (DateTime.now().difference(creationTime).inSeconds > 1.5) {
      beginForceMultiplier = true;
      // Calculate the direction vector to the top left of the screen

      final direction = visibleRect.topLeft.toVector2() - body.position;

      // Normalize the direction vector
      direction.normalize();

      // Apply a force or an impulse to the ball in the direction of the vector
      body.applyForce(direction * 2500 * forceMultiplier);
    }

    // Check if the ball has reached the top left of the screen
    if (body.position.y < visibleRect.topLeft.toVector2().y + 2 && DateTime.now().difference(creationTime).inSeconds > 1.5) {
      // Destroy the ball
      incrementFunc();
      world.remove(this);
    }
  }
}
