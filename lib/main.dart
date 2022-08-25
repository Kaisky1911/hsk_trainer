import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class Card {
  final String front;
  final String back1;
  final String back2;
  int level = 0;

  Card({required this.front, required this.back1, required this.back2});
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HSK Trainer',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: const MyHomePage(title: 'HSK Trainer'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<SwipeItem> cards = <SwipeItem>[];
  late MatchEngine swipeEngine;
  var rng = Random();
  int counter = -1;
  List<dynamic> cardsUnseen = [
    Card(front: "你好1", back1: "nihao", back2: "hallo1"),
    Card(front: "你好2", back1: "nihao", back2: "hallo1"),
    Card(front: "你好3", back1: "nihao", back2: "hallo1"),
    Card(front: "你好4", back1: "nihao", back2: "hallo1"),
  ];
  Map cardMap = {};

  @override
  void initState() {
    swipeEngine = MatchEngine(swipeItems: cards);
    addCard();
    addCard();
    super.initState();
  }

  void addCard() {
    setState(() {
      if (!cardMap.containsKey(counter + 1)) {
        if (cardsUnseen.length == 0) return;
        int idx = rng.nextInt(cardsUnseen.length);
        dynamic voc = cardsUnseen.removeAt(idx);
        cardMap[counter + 1] = voc;
      }

      cards.add(SwipeItem(
          content: cardMap[counter + 1],
          likeAction: () {
            print("ya");
            addCard();
          },
          nopeAction: () {
            print("nope");
            addCard();
          }));

      counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        backgroundColor: Colors.black87,
        body: SwipeCards(
          matchEngine: swipeEngine,
          itemBuilder: (BuildContext context, int index) {
            return Expanded(
                child: Container(
                    color: Colors.red,
                    child: Column(children: [
                      Text(
                        cards[index].content.front,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        cards[index].content.back1,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        cards[index].content.back2,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ])));
          },
          onStackFinished: () {},
          upSwipeAllowed: false,
          fillSpace: true,
        ));
  }
}
