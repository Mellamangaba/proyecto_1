import 'package:flutter/material.dart';
import 'dart:math';

class HangmanGame {
  final List<String> _words = [
    'FLUTTER',
    'DART',
    'WIDGET',
    'MOBILE',
    'PROGRAMA',
    'ESTADO',
    'COLUMNA',
    'FILA'
  ];

  late String _wordToGuess;
  late Set<String> _guessedLetters;
  late int _wrongGuesses;

  String get wordToGuess => _wordToGuess;
  Set<String> get guessedLetters => _guessedLetters;
  int get wrongGuesses => _wrongGuesses;
  bool get isGameOver => _wrongGuesses >= 6;
  bool get isGameWon => _isWordGuessed();
  static const int maxWrongGuesses = 6;


  HangmanGame() {
    _initializeGame();
  }

  void _initializeGame() {
    final random = Random();
    _wordToGuess = _words[random.nextInt(_words.length)];
    _guessedLetters = {};
    _wrongGuesses = 0;
  }

  void guessLetter(String letter) {
    if (_guessedLetters.contains(letter) || isGameOver || isGameWon) {
      return;
    }

    _guessedLetters.add(letter);

    if (!_wordToGuess.contains(letter)) {
      _wrongGuesses++;
    }
  }

  String getDisplayWord() {
    String displayWord = '';
    for (int i = 0; i < _wordToGuess.length; i++) {
      String letter = _wordToGuess[i];
      if (_guessedLetters.contains(letter)) {
        displayWord += '$letter ';
      } else {
        displayWord += '_ ';
      }
    }
    return displayWord.trim();
  }

  bool _isWordGuessed() {
    for (int i = 0; i < _wordToGuess.length; i++) {
      if (!_guessedLetters.contains(_wordToGuess[i])) {
        return false;
      }
    }
    return true;
  }

  void reset() {
    _initializeGame();
  }
}


class Ahorcado extends StatefulWidget {
  const Ahorcado({super.key});

  @override
  State<Ahorcado> createState() => _AhorcadoState();
}

class _AhorcadoState extends State<Ahorcado> {
  final HangmanGame _game = HangmanGame();

  void _handleGuess(String letter) {
    setState(() {
      _game.guessLetter(letter);
    });
  }

  void _restartGame() {
    setState(() {
      _game.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Juego del Ahorcado'),
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildHangmanFigure(_game.wrongGuesses),
                    const SizedBox(height: 10),
                    Text(
                      'Intentos restantes: ${HangmanGame.maxWrongGuesses - _game.wrongGuesses}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _game.wrongGuesses > 3 ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            Text(
              _game.getDisplayWord(),
              style: const TextStyle(
                fontSize: 48,
                letterSpacing: 12,
                fontWeight: FontWeight.w900,
                fontFamily: 'RobotoMono',
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),


            _buildKeyboard(),


            if (_game.isGameWon || _game.isGameOver)
              _buildGameStatusArea(),
          ],
        ),
      ),
    );
  }
  Widget _buildHangmanFigure(int wrongGuesses) {

    String figure = '';
    if (wrongGuesses >= 1) figure += 'O\n'; // Cabeza
    if (wrongGuesses >= 2) figure += '|'; // Cuerpo
    if (wrongGuesses >= 3) figure = figure.replaceFirst('|', r'\|/'); // Brazo izquierdo
    if (wrongGuesses >= 4) figure = figure.replaceFirst('|', r'/|'); // Brazo derecho
    if (wrongGuesses >= 5) figure += '\n/'; // Pierna izquierda
    if (wrongGuesses >= 6) figure += ' \\'; // Pierna derecha

    // Si no hay errores, se muestra el poste
    if (wrongGuesses == 0) figure = '¡Adivina!';

    return Text(
      figure.replaceAll(r'\n', '\n').replaceAll(r'\', ''), // Reemplazar para mostrar bien el texto
      style: const TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.bold,
        height: 1.2,
      ),
      textAlign: TextAlign.center,
    );
  }


  // Widget para el área de mensajes de estado
  Widget _buildGameStatusArea() {
    String message;
    Color color;
    if (_game.isGameWon) {
      message = '¡Felicidades! Has ganado. ';
      color = Colors.green;
    } else {
      message = '¡perdiste! La palabra era: "${_game.wordToGuess}".';
      color = Colors.red;
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Text(
            message,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        ElevatedButton(
          onPressed: _restartGame,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlue,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text(
            'Jugar de Nuevo',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildKeyboard() {
    const String alphabet = 'ABCDEFGHIJKLMONPQRSTUVWXYZ';
    List<Widget> keyboardRows = [];
    List<String> rowsOfLetters = [
      alphabet.substring(0, 7),
      alphabet.substring(7, 14),
      alphabet.substring(14, 21),
      alphabet.substring(21, 26)
    ];

    for (String rowLetters in rowsOfLetters) {
      keyboardRows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: rowLetters.split('').map((letter) {
              return _buildKeyButton(letter);
            }).toList(),
          ),
        ),
      );
    }

    return Column(children: keyboardRows);
  }

  Widget _buildKeyButton(String letter) {
    bool isGuessed = _game.guessedLetters.contains(letter);
    bool isDisabled = _game.isGameOver || _game.isGameWon || isGuessed;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3.0),
        child: ElevatedButton(
          onPressed: isDisabled ? null : () => _handleGuess(letter),
          style: ElevatedButton.styleFrom(
            backgroundColor: isGuessed
                ? (_game.wordToGuess.contains(letter) ? Colors.green[400] : Colors.red[400])
                : Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 2,
            disabledBackgroundColor: isGuessed
                ? (_game.wordToGuess.contains(letter) ? Colors.green[300] : Colors.red[300])
                : Colors.grey,
          ),
          child: Text(
            letter,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
