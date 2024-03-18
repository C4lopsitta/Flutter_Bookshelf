import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  String _result = "";
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
      ),
      body: SingleChildScrollView(
        child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: SearchBar(
                  controller: _searchController,
                  hintText: "Search key...",
                  onSubmitted: (String key) { findBook(); },
                  leading: IconButton(onPressed: findBook, icon: const Icon(Icons.search),),
                ),
              ),
              if(_result.isNotEmpty && _books != null)
                Column(
                  children: _books!.map((book) =>
                    BookCard(bookData: book)
                  ).toList(),
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

  Future findBook() async {
    String key = _searchController.text;
    if(key.isEmpty) {
      setState(() {
        _books = [];
      });
      return;
    }

    setState(() { _hasSearched = true; _result = ""; });
    const domain = "www.googleapis.com";
    const path = "/books/v1/volumes";

    Map<String, dynamic> params = {'q': key};
    Uri uri = Uri.https(domain, path, params);

    http.get(uri).then((result) {
      setState(() {
        _result = result.body;

        Map<String, dynamic> dataset = jsonDecode(_result);

        List<dynamic> items = dataset["items"];

        List<BookData> books = [];

        items.forEach((element) {
          Map<String, dynamic> volumeInfo = element["volumeInfo"];

          books.add(BookData(
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
          ));
        });

        _books = books;
      });
    });
  }
}
