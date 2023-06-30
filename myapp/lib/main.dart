import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/gestures.dart';

final othelloProvider = StateProvider((ref) => [
      [0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, -1, 1, 0, 0, 0],
      [0, 0, 0, 1, -1, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0]
    ]);

final playerProvider = StateProvider((ref) => -1);

const int maxRange = 8;

void main() {
  runApp(
    // プロバイダをウィジェットで利用するには、アプリ全体を
    // `ProviderScope` ウィジェットで囲む必要があります。
    // ここに各プロバイダのステート（状態）・値が格納されていきます。
    ProviderScope(
      child: MyApp(),
    ),
  );
}

// StatelessWidget の代わりに Riverpod の ConsumerWidget を継承します。
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    StateController<List<List<int>>> othelloArray =
        ref.watch(othelloProvider.notifier);
    StateController<int> player = ref.watch(playerProvider.notifier);

    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
              backgroundColor: Color.fromARGB(255, 204, 150, 182),
              title: const Text('かわいいおせろだよ〜')),
          body: Column(
            children: [
              SizedBox(height: 16),
              playerName(ref.watch(playerProvider)),
              SizedBox(height: 16),
              for (int i = 0; i < maxRange; i++)
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  for (int j = 0; j < maxRange; j++)
                    GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () async {
                          // othelloArrayの値を変更する
                          othelloArray.state = await othelloFunction(
                              i, j, ref.watch(othelloProvider), player.state);
                          print(othelloArray.state);
                          // playerの値を変更する
                          player.state = player.state * -1;
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Color.fromARGB(255, 22, 71, 22),
                                width: 1),
                            color: Color.fromARGB(255, 138, 185, 141),
                          ),
                          child: pawnText(
                              i, j, ref.watch(othelloProvider), player.state),
                        ))
                ])
            ],
          )),
    );
  }

  Widget playerName(int player) {
    var playerName = "";
    if (player == 1) {
      playerName = "白";
    } else if (player == -1) {
      playerName = "桃";
    }
    return Text("プレイヤー$playerNameの番です");
  }

  canPutPawn(int i, int j, othelloArray, player) {
    var canPut = false;
    if (othelloArray[i][j] != 0) {
      return canPut;
    }
    List<List<int>> vecList = [
      [0, 1],
      [1, 1],
      [1, 0],
      [1, -1],
      [0, -1],
      [-1, -1],
      [-1, 0],
      [-1, 1]
    ];

    for (int k = 0; k < 8; k++) {
      int x = i;
      int y = j;
      while (true) {
        x += vecList[k][0];
        y += vecList[k][1];
        if (x < 0 || x > maxRange - 1 || y < 0 || y > maxRange - 1) {
          break;
        }
        if (othelloArray[x][y] == 0) {
          break;
        }
        if (othelloArray[x][y] == player) {
          canPut = true;
        }
      }
    }
    return canPut;
  }

  Widget pawnText(int i, int j, othelloArray, player) {
    var value = othelloArray[i][j];
    var pawnText = "";
    var textColor = Colors.black;
    if (value == 0) {
      if (canPutPawn(i, j, othelloArray, player)) {
        pawnText = "○";
      } else {
        pawnText = "";
      }
    } else if (value == -1) {
      pawnText = "●";
      textColor = Color.fromARGB(255, 205, 127, 153);
    } else if (value == 1) {
      pawnText = "●";
      textColor = Colors.white;
    }
    return Center(
        child: Text(
      pawnText,
      style: TextStyle(
        fontSize: 30,
        color: textColor,
        shadows: const [
          Shadow(
            blurRadius: 2,
            color: Color.fromARGB(255, 20, 38, 2),
            offset: Offset(1, 1),
          ),
        ],
      ),
    ));
  }

  othelloFunction(int i, int j, List<List<int>> othelloArray, int player) {
    if (othelloArray[i][j] != 0) {
      //
    }
    List<List<int>> vecList = [
      [0, 1],
      [1, 1],
      [1, 0],
      [1, -1],
      [0, -1],
      [-1, -1],
      [-1, 0],
      [-1, 1]
    ];
    //次の盤面
    List<List<int>> othelloNext = []
      ..addAll(othelloArray.map((e) => []..addAll(e)));
    othelloNext[i][j] = player;
    for (int k = 0; k < 8; k++) {
      int x = i;
      int y = j;
      while (true) {
        x += vecList[k][0];
        y += vecList[k][1];
        if (x < 0 || x > maxRange - 1 || y < 0 || y > maxRange - 1) {
          break;
        }
        if (othelloArray[x][y] == 0) {
          break;
        }
        if (othelloArray[x][y] == player) {
          while ((i != x) || (j != y)) {
            othelloNext[x][y] = player;
            x -= vecList[k][0];
            y -= vecList[k][1];
          }
          break;
        }
      }
    }

    return othelloNext;
  }
}
