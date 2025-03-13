import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() => runApp(CalculatriceApp());

class CalculatriceApp extends StatelessWidget {
  // Customization du theme par défaut dans un style "coloré"
  final ThemeData themeData = ThemeData.light().copyWith(
    colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.purple,
        surface: Colors.purple
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white
    ),
    scaffoldBackgroundColor: Colors.purple,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.cyan,
        foregroundColor: Colors.black
      )
    )
  );

  // Customization de certains boutons dérivant depuis la style par défaut
  static ButtonStyle operatorButtons() {
    return ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange);
  }

  static ButtonStyle calcButton() {
    return ElevatedButton.styleFrom(backgroundColor: Colors.green);
  }

  static ButtonStyle clearButton() {
    return ElevatedButton.styleFrom(backgroundColor: Colors.red);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Calculatrice(), theme: themeData);
  }
}

class Calculatrice extends StatefulWidget {
  @override
  _CalculatriceState createState() => _CalculatriceState();
}

class _CalculatriceState extends State<Calculatrice> {
  String output = "0";

  // Détermine si un calcul vient d'êtr exécuté : permet de réinitialiser la formule si l'utilisateur
  // appuie sur une chiffre après avoir calculé
  bool hasCalculated = false;

  // booléen pour l'animation du total
  bool animated = true;
  List<String> history = [];

  // Liste des opérateurs
  List<String> operators = ['/', '*', '-', '+'];
  
  void pressedButton (String button) {
    setState(() {
      // Gestion de la saisis utilisateur
      switch(button) {
        case "C":
          // Clear de la saisie
          output = "0";
        case "=":
          // Calcul de la formule en utilisant maths_expression
          // Et ajout de la ofrmule à l'historique
          ExpressionParser p = GrammarParser();
          Expression exp = p.parse(output);
          String historyLine = output;
          output = exp.evaluate(EvaluationType.REAL, ContextModel()).toString();
          history.add("$historyLine = $output");

          // Gestion du booléen hasCalculated
          hasCalculated = true;

          // Trigger de l'animation en changeant la valeur du booléen
          animated = !animated;
        default:
          // Par défaut, ajout de la saisie utilisateur à la formule
          // Gestion du booléen hasCalculated : si un calcul vient d'être fait et que l'utilisateur saisie un nouveau chiffre
          // -> reset de la formule
          if (hasCalculated && !operators.contains(button)) {
            output = "0";
            hasCalculated = false;
          }

          // Suppression du premier zéro inutile
          if (output == "0") {
            output = button;
          } else {
            output += button;
          }

          // Reset du booléen si il était à true
          hasCalculated = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Liste des boutons à afficher
    List<String> buttons = [
      '7', '8', '9', '/',
      '4', '5', '6', '*',
      '1', '2', '3', '-',
      'C', '0', '=', '+',
    ];

    return Scaffold(
      appBar: AppBar(title: Text('Flutteratrice by Quentin')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: AnimatedContainer(
              duration: Duration(seconds: 2),
              padding: EdgeInsets.all(12.0),
              alignment: animated ? Alignment.bottomRight : Alignment.bottomLeft,
              child: Text(
                output,
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: GridView.builder(
              itemCount: 16,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
              ),
              itemBuilder: (BuildContext context, int index) {
                final String value = buttons[index];
                // bouttons pour les opérateurs
                if (operators.contains(value)) {
                  return ElevatedButton(
                    style: CalculatriceApp.operatorButtons(),
                    onPressed: () {pressedButton(value);},
                    child: Text(value, style: TextStyle(fontSize: 24)),
                  );
                  // bouttons pour le signe égal
                } else if (value == "=") {
                  return ElevatedButton(
                    style: CalculatriceApp.calcButton(),
                    onPressed: () {pressedButton(value);},
                    child: Text(value, style: TextStyle(fontSize: 24)),
                  );
                  // bouttons pour vider la saisie
                } else if (value == "C") {
                  return ElevatedButton(
                    style: CalculatriceApp.clearButton(),
                    onPressed: () {pressedButton(value);},
                    child: Text(value, style: TextStyle(fontSize: 24)),
                  );
                } else {
                  // bouttons pour les chiffres
                  return ElevatedButton(
                    onPressed: () {
                      // Logique à ajouter pour gérer les boutons.
                      pressedButton(buttons[index]);
                    },
                    child: Text(buttons[index], style: TextStyle(fontSize: 24)),
                  );
                }
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: history.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  height: 20,
                  color: index.isEven ? Colors.yellow : Colors.amber,
                  child: Center(
                    child: Text(history[index]),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
