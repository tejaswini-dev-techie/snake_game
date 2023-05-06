import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snake_game/Screens/GameScreen/widgets/blank_pixel.dart';
import 'package:snake_game/Screens/GameScreen/widgets/food_pixel.dart';
import 'package:snake_game/Screens/GameScreen/widgets/high_score_tile.dart';
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

  /* Game Settings */
  bool gameStarted = false;
  final TextEditingController nameController = TextEditingController();

  /* Snake Position */
  List<int> snakePosition = [0, 1, 2];

  /* Food Position */
  int foodPosition = 55;

  /* Initial Snake Direction */
  var currentDirection = snake_direction.RIGHT;

  /* High Score Details */
  List<String> highScoreIDs = [];
  late final Future? docIDs;

  @override
  void initState() {
    docIDs = getDocID();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void backAction() {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Text(
              "Are you sure you want to exit?",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false), // passing false
                child: const Text(
                  "No",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true), // passing true
                child: const Text(
                  "Yes",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          );
        }).then((exit) async {
      if (exit == null) return;

      if (exit) {
        // user pressed Yes button
        SystemNavigator.pop();
      } else {
        // user pressed No button
      }
    });
  }

  /* Get Doc ID */
  Future<void> getDocID() async {
    await FirebaseFirestore.instance
        .collection("highscores")
        .orderBy("score", descending: true)
        .limit(5)
        .get()
        .then(
          (value) => value.docs.forEach(
            (element) {
              highScoreIDs.add(element.reference.id);
            },
          ),
        );
  }

  /* Start Game */
  void startGame() {
    gameStarted = true;
    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        /* Snake keeps moving! */
        moveSnake();

        if (gameOver()) {
          timer.cancel();

          /* Display message to the user */
          displayGamerOverDialog();
        }
      });
    });
  }

  displayGamerOverDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: SizedBox(
              height: 200,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Game Over",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      "SCORE : $score",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter Your Name',
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    SizedBox(
                      width: 320.0,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          submitScore();
                          startNewGame();
                        },
                        child: const Text(
                          "SUBMIT",
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
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

  /* Submit Score */
  void submitScore() {
    /* Add to the Database */
    var database = FirebaseFirestore.instance;
    database.collection("highscores").add({
      "name": nameController.text,
      "score": score,
    });
  }

  /* New Game */
  Future<void> startNewGame() async {
    nameController.clear();
    highScoreIDs = [];
    await getDocID();
    setState(() {
      score = 0;

      gameStarted = false;

      /* Snake Position */
      snakePosition = [0, 1, 2];

      /* Food Position */
      foodPosition = 55;

      /* Snake Direction */
      currentDirection = snake_direction.RIGHT;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        backAction();
        return Future.value(false);
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.black,
          body: RawKeyboardListener(
            /* Physical Keyboard Input */
            focusNode: FocusNode(),
            autofocus: true,
            onKey: (event) {
              if (event.isKeyPressed(LogicalKeyboardKey.arrowDown) &&
                  (currentDirection != snake_direction.UP)) {
                currentDirection = snake_direction.DOWN;
              } else if (event.isKeyPressed(LogicalKeyboardKey.arrowUp) &&
                  (currentDirection != snake_direction.DOWN)) {
                currentDirection = snake_direction.UP;
              } else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight) &&
                  (currentDirection != snake_direction.LEFT)) {
                currentDirection = snake_direction.RIGHT;
              } else if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft) &&
                  (currentDirection != snake_direction.RIGHT)) {
                currentDirection = snake_direction.LEFT;
              }
            },
            child: SizedBox(
              width: screenWidth > 428 ? 428 : screenWidth,
              child: Column(
                children: [
                  /* High Score Panel */
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        /* User Score */
                        Expanded(
                          child: Column(
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
                        ),

                        /* High Score */
                        Expanded(
                          child: gameStarted
                              ? const SizedBox.shrink()
                              : FutureBuilder(
                                  future: docIDs,
                                  builder: (context, snapshot) {
                                    return ListView.builder(
                                      itemCount: highScoreIDs.length,
                                      itemBuilder: (context, index) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            (index == 0)
                                                ? const Padding(
                                                    padding: EdgeInsets.only(
                                                      top: 2.0,
                                                      bottom: 2.0,
                                                    ),
                                                    child: Text(
                                                      "Top 5 HIGH SCORERS",
                                                      style: TextStyle(
                                                        fontSize: 14.0,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  )
                                                : const SizedBox.shrink(),
                                            HighScoreTile(
                                              docID: highScoreIDs[index],
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                        ),
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
                        color: gameStarted ? Colors.grey : Colors.blue,
                        onPressed: gameStarted ? () {} : startGame,
                        child: const Text(
                          "PLAY",
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
