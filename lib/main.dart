import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';


void main() {
  runApp(const MyApp());
}

class Card {
  final String text;

  Card({required this.text});
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
  var data = {
    "counter": 0,
    "voc_unseen": {
      [
        {
          "chinese": "你好",
          "pinyin": "nihao",
          "english": "hallo1",
        },
        {
          "chinese": "你好",
          "pinyin": "nihao",
          "english": "hallo2",
        },
        {
          "chinese": "你好",
          "pinyin": "nihao",
          "english": "hallo3",
        },
      ],
    },
    "voc_seen": {},
  };

  @override
  void initState() {
    swipeEngine = MatchEngine(swipeItems: cards);
    addCard();
    addCard();
    super.initState();
  }

  void addCard() {
    setState(() {
      cards.add(SwipeItem(
        content: Card(text: "hi"),
        likeAction: () {
          print("ya");
          addCard();
        },
        nopeAction: () {
          print("nope");
          addCard();
        }
      ));
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
            child: Text(
              cards[index].content.text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                
                ),
                textAlign: TextAlign.center,
            )
          );
        },
        onStackFinished:() {},
        upSwipeAllowed: false,
        fillSpace: true,
      )
    );
  }
}
