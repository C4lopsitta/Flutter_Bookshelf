import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:visibility_detector/visibility_detector.dart';
import 'dart:convert';

import 'bookcard.dart';
import 'bookdata.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orangeAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Bookshelf'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String _domain = "www.googleapis.com";
  final String _path = "/books/v1/volumes";
  final Random random = Random(DateTime.now().microsecondsSinceEpoch);

  String _result = "";
  String _lastSearchKey = "";
  int _alreadyReadBooks = 0;
  bool _hasSearched = false;
  List<BookData>? _books;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: (){},
            icon: const Icon(Icons.vertical_align_top_outlined)
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: SearchBar(
                  controller: _searchController,
                  hintText: "Search key...",
                  onSubmitted: (String key) { _findBook(); },
                  leading: IconButton(onPressed: _findBook, icon: const Icon(Icons.search),),
                ),
              ),
              if(_result.isNotEmpty && _books != null)
                Column(
                  children: _buildMainColumn()
                )
              else
                if(_hasSearched)
                  Container(
                    alignment: Alignment.center,
                    height: MediaQuery.sizeOf(context).height - 64,
                    child: const CircularProgressIndicator(),
                  )
                else
                  const Center(
                    child: Text("Start by searching for a book")
                  )
            ],

          ),
        )
    );
  }

  List<BookData> _decodeBooksFromJson(List<dynamic> items) {
    List<BookData> books = [];
    int iterator = 0;

    items.forEach((element) {
      Map<String, dynamic> volumeInfo = element["volumeInfo"];

      BookData tempData = BookData(
          volumeInfo["title"],
          volumeInfo["description"],
          volumeInfo["infoLink"],
          volumeInfo["authors"],
          element["id"],
          volumeInfo["industryIdentifiers"]?.toList() ?? [],
          volumeInfo["publisher"],
          volumeInfo["publishedDate"],
          volumeInfo["imageLinks"],
          volumeInfo
      );

      if(iterator == 7) tempData.shouldLoadMoreBooks = true;

      books.add(tempData);
      iterator++;
    });

    return books;
  }

  Future _findBook() async {
    _lastSearchKey = _searchController.text;
    if (_lastSearchKey.isEmpty) {
      setState(() {
        _books = [];
      });
      return;
    }

    setState(() {
      _hasSearched = true;
      _result = "";
    });

    Map<String, dynamic> params = {'q': _lastSearchKey};
    Uri uri = Uri.https(_domain, _path, params);

    http.get(uri).then((result) {
      setState(() {
        _result = result.body;

        Map<String, dynamic> dataset = jsonDecode(_result);
        List<dynamic> items = dataset["items"];
        List<BookData> books = _decodeBooksFromJson(items);

        _books = books;
        _alreadyReadBooks = books.length;
      });
    });
  }

  Future _getMore() async {
    print("Triggered _getMore() with offset ${_alreadyReadBooks}");
    Map<String, dynamic> params = {
      'q': _lastSearchKey,
      'startIndex': _alreadyReadBooks.toString(),
    };
    Uri uri = Uri.https(_domain, _path, params);
    print("URI is ${uri.path} ${uri.query}");

    if(_books == null) return;

    http.get(uri).then((result) {
      setState(() {
        _result = result.body;

        Map<String, dynamic> dataset = jsonDecode(_result);
        List<dynamic> items = dataset["items"];
        List<BookData> books = _decodeBooksFromJson(items);

        _books = (_books! + books);
        _alreadyReadBooks += items.length;
      });
    });
  }

  List<Widget> _buildMainColumn() {
    List<Widget> list = _books!.map<Widget>((book) =>
        VisibilityDetector(
            key: Key("${book.identifier}${random.nextDouble()}"),
            onVisibilityChanged: (info){
              if(!book.shouldLoadMoreBooks) return;
              if(info.visibleFraction > 0.1) {
                book.shouldLoadMoreBooks = false;
                _getMore();
              }
            },
            child: BookCard(bookData: book)
        )
    ).toList();
    list.add(
      const Center(
        heightFactor: 3,
        child: CircularProgressIndicator()
      )
    );
    return list;
  }
}
