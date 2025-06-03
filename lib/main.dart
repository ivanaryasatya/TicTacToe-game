import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 60, 120, 180),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color.fromARGB(255, 60, 120, 180),
          secondary: const Color.fromARGB(255, 255, 180, 60),
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 141, 206, 214),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  List<String?> board = List.generate(9, (index) => null);
  String? currentPlayer = 'X';
  String? winner;
  bool gameEnded = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap(int index) {
    if (!gameEnded && board[index] == null) {
      setState(() {
        board[index] = currentPlayer;
        _controller.reset();
        _controller.forward().then((_) => _controller.reverse());
        _checkWinner();
        if (!gameEnded) {
          currentPlayer = (currentPlayer == 'X') ? 'O' : 'X';
          if (currentPlayer == 'O' && !gameEnded) {
            _computerMove();
          }
        }
      });
    }
  }

  void _computerMove() {
    // Algoritma AI sederhana untuk komputer
    List<int?> availableSpots() {
      List<int?> spots = [];
      for (int i = 0; i < 9; i++) {
        if (board[i] == null) {
          spots.add(i);
        }
      }
      return spots;
    }

    if (!gameEnded) {
      List<int?> available = availableSpots();
      if (available.isNotEmpty) {
        Random random = Random();
        int randomIndex = random.nextInt(available.length);
        Future.delayed(const Duration(milliseconds: 500), () {
          _handleTap(available[randomIndex]!);
        });
      }
    }
  }

  void _checkWinner() {
    const lines = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];
    for (final line in lines) {
      final a = board[line[0]];
      final b = board[line[1]];
      final c = board[line[2]];
      if (a != null && a == b && a == c) {
        setState(() {
          winner = a;
          gameEnded = true;
        });
        return;
      }
    }
    if (!board.contains(null)) {
      setState(() {
        gameEnded = true;
      });
    }
  }

  void _resetGame() {
    setState(() {
      board = List.generate(9, (index) => null);
      currentPlayer = 'X';
      winner = null;
      gameEnded = false;
    });
  }

  Color _getColor(String? player) {
    if (player == 'X') {
      return Colors.red.shade400;
    } else if (player == 'O') {
      return Colors.green.shade400;
    }
    return Colors.black38;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic Tac Toe!'),
        centerTitle: true,
      ),
      backgroundColor: const Color.fromARGB(255, 141, 206, 214),
      body: Stack(
        children: [
          // Gradasi lingkaran di bawah layar
          Positioned(
            left: -100,
            right: -100,
            bottom: -150,
            child: Container(
              height: 400,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color.fromARGB(255, 51, 96, 141),
                    Color.fromARGB(255, 141, 206, 214),
                  ],
                  center: Alignment.bottomCenter,
                  radius: 0.8,
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                    (() {
                    if (winner != null) {
                      return 'Pemenangnya adalah ${winner == 'X' ? 'Merah (X)' : 'Hijau (O)'}!';
                    } else if (gameEnded) {
                      return 'Seri!';
                    } else {
                      return 'Giliran: ${currentPlayer == 'X' ? 'Merah (X)' : 'Hijau (O)'}';
                    }
                    })(),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 50),
                GridView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _handleTap(index),
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.black12),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromARGB(255, 255, 254, 254).withOpacity(0.5),
                                blurRadius: 10,
                                offset: const Offset(2, 4),
                              ),
                            ],
                          ),
                          margin: const EdgeInsets.all(8),
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: _getColor(board[index]),
                              ),
                              child: Text(board[index] ?? ''),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _resetGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Mulai Ulang'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

