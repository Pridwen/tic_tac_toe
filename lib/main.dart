// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tic_tac_toe/utils.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static const String title = 'X & O:The War';

  @override
  Widget build(BuildContext context) => const MaterialApp(
        debugShowCheckedModeBanner: true,
        title: title,
        home: MainPage(title: title),
      );
}

class MainPage extends StatefulWidget {
  final String title;

  const MainPage({
    required this.title,
  });

  @override
  _MainPageState createState() => _MainPageState();
}

class Player {
  static const none = '';
  static const X = 'X';
  static const O = 'O';
}

class _MainPageState extends State<MainPage> {
  static const counterXY = 3;
  static const double size = 70;

  String lastMove = Player.none;
  late List<List<String>> board;

  @override
  void initState() {
    super.initState();
    reset();
  }

  void reset() => setState(() => board = List.generate(
        counterXY,
        (_) => List.generate(counterXY, (_) => Player.none),
      ));

  Color getBackgroundColor() {
    return const Color.fromARGB(255, 90, 7, 1);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: getBackgroundColor(),
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: Utils.modelBuilder(board, (x, value) => buildRow(x)),
        ),
      );

  Widget buildRow(int x) {
    final values = board[x];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: Utils.modelBuilder(
        values,
        (y, value) => buildField(x, y),
      ),
    );
  }

  Color getFieldColor(String value) {
    switch (value) {
      case Player.O:
        return const Color.fromARGB(255, 1, 4, 87);
      case Player.X:
        return const Color.fromARGB(255, 2, 75, 31);
      default:
        return Colors.white;
    }
  }

  Widget buildField(int x, int y) {
    final value = board[x][y];
    final color = getFieldColor(value);

    return Container(
      margin: const EdgeInsets.all(11),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(size, size),
          primary: color,
        ),
        child: Text(value, style: const TextStyle(fontSize: 33)),
        onPressed: () => selectField(value, x, y),
      ),
    );
  }

  void selectField(String value, int x, int y) {
    if (value == Player.none) {
      final newValue = lastMove == Player.X ? Player.O : Player.X;

      setState(() {
        lastMove = newValue;
        board[x][y] = newValue;
      });

      if (win(x, y)) {
        endText('Player $newValue has bested their foe');
      } else if (end()) {
        endText('None emerged triumphant!');
      }
    }
  }

  bool end() =>
      board.every((values) => values.every((value) => value != Player.none));

  bool win(int x, int y) {
    var col = 0, row = 0, diag = 0, rdiag = 0;
    final player = board[x][y];
    const n = counterXY;

    for (int i = 0; i < n; i++) {
      if (board[x][i] == player) col++;
      if (board[i][y] == player) row++;
      if (board[i][i] == player) diag++;
      if (board[i][n - i - 1] == player) rdiag++;
    }

    return row == n || col == n || diag == n || rdiag == n;
  }

  Future endText(String title) => showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: const Text('And so the war ends, for now...'),
          actions: [
            ElevatedButton(
              onPressed: () {
                reset();
                Navigator.of(context).pop();
              },
              child: const Text('Go Agane'),
            )
          ],
        ),
      );
}
