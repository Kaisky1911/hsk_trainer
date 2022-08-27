import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(const MyApp());
}

class Card {
  final String hanzi;
  final List<String> pinyin;
  final List<String> english;
  int level = 0;

  Card({required this.hanzi, required this.pinyin, required this.english});
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
  int counter = -2;
  List<dynamic> cardsUnseen = [];
  Map cardMap = {};
  bool loaded = false;
  bool shown = false;

  @override
  void initState() {
    swipeEngine = MatchEngine(swipeItems: cards);
    rootBundle.loadString('hsk.json').then((dataText) => loadDone(dataText));
    super.initState();
  }

  void loadDone(dataText) {
    dynamic data = jsonDecode(dataText);
    data["vocabulary"].forEach((entry) => loadEntry(entry));
    addCard();
    addCard();
    loaded = true;
  }

  void loadEntry(entry) {
    String hanzi = entry["hanzi"];
    List<String> pinyin = [];
    List<String> english = [];
    for (int i = 0; i < entry["translations"].length; i++) {
      pinyin.add(entry["translations"][i]["pinyin"].join(""));
      for (int j = 0; j < entry["translations"][i]["english"].length; j++) {
        english.add(entry["translations"][i]["english"][j]);
      }
    }
    cardsUnseen.add(Card(hanzi: hanzi, pinyin: pinyin, english: english));
  }

  void addCard() {
    setState(() {
      if (!cardMap.containsKey(counter + 2)) {
        if (cardsUnseen.isEmpty) return;
        int idx = rng.nextInt(cardsUnseen.length);
        dynamic voc = cardsUnseen.removeAt(idx);
        cardMap[counter + 2] = voc;
      }

      cards.add(SwipeItem(
          content: cardMap[counter + 2],
          likeAction: () {
            shown = false;
            addCard();
          },
          nopeAction: () {
            shown = false;
            addCard();
          }));

      counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return loaded
        ? SwipeCards(
            matchEngine: swipeEngine,
            itemBuilder: (BuildContext context, int index) {
              return Column(children: [
                Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: const Color.fromARGB(255, 58, 58, 58),
                    child: Column(children: [
                      Text(
                        cards[index].content.hanzi,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      counter == index && shown
                          ? Text(
                              cards[index].content.pinyin.join(", "),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                              ),
                              textAlign: TextAlign.center,
                            )
                          : const Text(""),
                      counter == index && shown
                          ? Text(
                              cards[index].content.english.join(", "),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                              ),
                              textAlign: TextAlign.center,
                            )
                          : const Text(""),
                    ])),
                TextButton(
                  onPressed: () {
                    setState(() {
                      shown = true;
                    });
                  },
                  child: const Text("Show"),
                ),
              ]);
            },
            onStackFinished: () {},
            upSwipeAllowed: false,
            fillSpace: true,
          )
        : const Text("loading");
  }
}
