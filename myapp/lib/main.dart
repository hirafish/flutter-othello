import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/gestures.dart';

final othelloProvider = StateProvider(
    (ref) => List.generate(8, (_) => List.generate(8, (_) => -1)));

final playerProvider = StateProvider((ref) => 1);

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
          appBar: AppBar(title: const Text('おせろだよ〜')),
          body: Column(
            children: [
              SizedBox(height: 16),
              playerName(ref.watch(playerProvider)),
              SizedBox(height: 16),
              for (int i = 0; i < 8; i++)
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  for (int j = 0; j < 8; j++)
                    GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          othelloFunction(
                              i, j, ref.watch(othelloProvider), player.state);
                          // playerの値を変更する
                          player.state = player.state * -1;
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 1),
                            color: Colors.green,
                          ),
                          child: pawnText(ref.watch(othelloProvider)[i][j]),
                        ))
                ])
            ],
          )),
    );
  }

  Widget playerName(int player) {
    var playerName = "";
    if (player == 1) {
      playerName = "黒";
    } else if (player == -1) {
      playerName = "白";
    }
    return Text("プレイヤー$playerNameの番です");
  }

  Widget pawnText(int value) {
    var pawnText = "";
    var textColor = Colors.black;
    if (value == 0) {
      pawnText = "";
    } else if (value == -1) {
      pawnText = "●";
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
      ),
    ));
  }

  void othelloFunction(int i, int j, List<List<int>> othelloArray, int player) {
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
    List<List<int>> othelloNext =
        List.generate(8, (_) => List.generate(8, (_) => 1));
    for (int k = 0; k < 8; k++) {
      int x = i;
      int y = j;
      while (true) {
        x += vecList[k][0];
        y += vecList[k][1];
        if (x < 0 || x > 7 || y < 0 || y > 7) {
          break;
        }
        if (othelloArray[x][y] == 0) {
          break;
        }
        if (othelloArray[x][y] == player) {
          for (int l = 0; l < 8; l++) {
            int x2 = i;
            int y2 = j;
            while (true) {
              x2 += vecList[l][0];
              y2 += vecList[l][1];
              if (x2 == x && y2 == y) {
                break;
              }
              othelloNext[x2][y2] = player;
            }
          }
          break;
        }
      }
    }
  }
}
