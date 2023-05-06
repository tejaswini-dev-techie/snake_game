import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:snake_game/Screens/GameScreen/widgets/blank_pixel.dart';
import 'package:snake_game/Screens/GameScreen/widgets/food_pixel.dart';
import 'package:snake_game/Screens/GameScreen/widgets/snake_pixel.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

enum snake_direction { UP, DOWN, RIGHT, LEFT }

class _GameScreenState extends State<GameScreen> {
  /* Grid Dimensions */
  int totalGridCount = 100;
  int rowSize = 10;

  /* User Score */
  int score = 0;

  /* Snake Position */
  List<int> snakePosition = [0, 1, 2];

  /* Food Position */
  int foodPosition = 55;

  /* Initial Snake Direction */
  var currentDirection = snake_direction.RIGHT;

  /* Start Game */
  void startGame() {
    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        /* Snake keeps moving! */
        moveSnake();

        if (gameOver()) {
          timer.cancel();

          /* Display message to the user */
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Game Over"),
                content: Text("Score: $score"),
              );
            },
          );
        }
      });
    });
  }

  void eatFood() {
    score++;
    /* Generates random food position */
    while (snakePosition.contains(foodPosition)) {
      foodPosition = Random().nextInt(totalGridCount);
    }
  }

  void moveSnake() {
    switch (currentDirection) {
      case snake_direction.UP:
        {
          /* Add new head */
          if (snakePosition.last < rowSize) {
            snakePosition.add(snakePosition.last - rowSize + totalGridCount);
          } else {
            snakePosition.add(snakePosition.last - rowSize);
          }
        }
        break;
      case snake_direction.DOWN:
        {
          /* Add new head */
          if (snakePosition.last + rowSize > totalGridCount) {
            snakePosition.add(snakePosition.last + rowSize - totalGridCount);
          } else {
            snakePosition.add(snakePosition.last + rowSize);
          }
        }
        break;
      case snake_direction.RIGHT:
        {
          /* Add new head */
          /* If Snake is to Right Wall, need to be re adjusted */
          if (snakePosition.last % rowSize == 9) {
            snakePosition.add(snakePosition.last + 1 - rowSize);
          } else {
            snakePosition.add(snakePosition.last + 1);
          }
        }
        break;
      case snake_direction.LEFT:
        {
          /* Add new head */
          /* If Snake is to Left Wall, need to be re adjusted */
          if (snakePosition.last % rowSize == 0) {
            snakePosition.add(snakePosition.last - 1 + rowSize);
          } else {
            snakePosition.add(snakePosition.last - 1);
          }
        }
        break;
      default:
    }

    /* Snake eating food! */
    if (snakePosition.last == foodPosition) {
      eatFood();
    } else {
      /* Remove tail */
      snakePosition.removeAt(0);
    }
  }

  /* Game Over */
  bool gameOver() {
    /* When Snake hits itself the Game is over */
    /* This occurs when body of snake i.e snakePosition has duplicates */

    /* Snake Body Length excluding Head */
    List<int> snakeBody = snakePosition.sublist(0, snakePosition.length - 1);
    if (snakeBody.contains(snakePosition.last)) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            /* High Score Panel */
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /* User Score */
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "YOUR SCORE",
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "$score",
                        style: const TextStyle(
                          fontSize: 24.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  // /* High Score */
                  // const Text(
                  //   "HIGH SCORE",
                  //   style: TextStyle(
                  //     fontSize: 16.0,
                  //     color: Colors.white,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                ],
              ),
            ),

            /* Grid */
            Expanded(
              flex: 3,
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  if (details.delta.dy > 0 &&
                      (currentDirection != snake_direction.UP)) {
                    currentDirection = snake_direction.DOWN;
                  } else if (details.delta.dy < 0 &&
                      (currentDirection != snake_direction.DOWN)) {
                    currentDirection = snake_direction.UP;
                  }
                },
                onHorizontalDragUpdate: (details) {
                  if (details.delta.dx > 0 &&
                      (currentDirection != snake_direction.LEFT)) {
                    currentDirection = snake_direction.RIGHT;
                  } else if (details.delta.dx < 0 &&
                      (currentDirection != snake_direction.RIGHT)) {
                    currentDirection = snake_direction.LEFT;
                  }
                },
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: rowSize,
                  ),
                  itemCount: totalGridCount,
                  itemBuilder: (context, index) {
                    if (snakePosition.contains(index)) {
                      return const SnakePixel();
                    } else if (foodPosition == index) {
                      return const FoodPixel();
                    } else {
                      return const BlankPixel();
                    }
                  },
                ),
              ),
            ),

            /* Play Button */
            Expanded(
              child: Center(
                child: MaterialButton(
                  color: Colors.blue,
                  onPressed: startGame,
                  child: const Text(
                    "PLAY",
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
