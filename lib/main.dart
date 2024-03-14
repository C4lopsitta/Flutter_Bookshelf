import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
                padding: EdgeInsets.all(12),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    label: const Text("Search Key"),
                    hintText: "Book title...",
                    border: const OutlineInputBorder(),
                    suffix: IconButton(
                      onPressed: findBook,
                      icon: const Icon(Icons.search),
                    )
                  ),
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
                  const Center(
                    heightFactor: 1,
                    child: CircularProgressIndicator(),
                  )
            ],

          ),
        )
    );
  }

  Future findBook() async {
    setState(() { _hasSearched = true; _result = ""; });
    const domain = "www.googleapis.com";
    const path = "/books/v1/volumes";

    String key = _searchController.text;

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
            volumeInfo["industryIdentifiers"],
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

class BookDetailRoute extends StatefulWidget {
  const BookDetailRoute({super.key, required this.bookData});
  final BookData bookData;

  @override
  State<BookDetailRoute> createState() => _BookDetailRoute(bookData);
}

class _BookDetailRoute extends State<BookDetailRoute> {
  _BookDetailRoute(this.bookData);
  final BookData bookData;

  @override
  Widget build(BuildContext context) {
    final String _title = bookData.title ?? "";
    final String _description = bookData.description ?? "No description provided";
    final List<String> _authors = [];
    final NetworkImage _image = NetworkImage(bookData.images?["thumbnail"] ?? "");
    final String _publisher = bookData.publisher ?? "No publisher provided";
    final String _date = bookData.publishedDate ?? "no published date provided";

    bookData.authors?.forEach((element) { _authors.add(element); });

    Widget label(String label) => Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w300));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(bookData.title ?? "Invalid book title"),
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if(_image.url.isNotEmpty)
              Image(image: _image)
            else
              const Center(heightFactor: 200, child: Text("No image"),),
            const SizedBox(width: 12,),

            label("Title"),
            Text(_title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400)),
            label((_authors.length == 1) ? "Author" : "Authors"),
            Text(_authors.join(", "), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),),
            const SizedBox(height: 12,),
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    label("Description"),
                    Text(_description),
                    SizedBox(height: 12,),
                    label("Published by"),
                    Text("$_publisher; $_date"),
                  ],
                )
              ),
            )

            // CustomScrollView(
            //   slivers: [
            //     SliverFillRemaining(
            //       hasScrollBody: false,
            //       child: Expanded( child :Column(
            //         children: [
            //
            //           Expanded(child: Text(_description))
            //
            //         ],
            //       )),
            //     )
            //   ],
            // )
          ],
        ),
      )
    );
  }
}

class BookData {
  const BookData(
    this.title,
    this.description,
    this.url,
    this.authors,
    this.identifier,
    this.isbns,
    this.publisher,
    this.publishedDate,
    this.images,
    this.data
  );

  final String? title;
  final String? description;
  final String? publishedDate;
  final String? publisher;
  final List<dynamic>? authors;
  final String? identifier;
  final List<dynamic>? isbns;
  final String? url;
  final Map<String, dynamic>? images;
  final Map<String, dynamic> data;
}

class BookCard extends StatefulWidget {
  const BookCard({super.key, required this.bookData});
  final BookData bookData;

  @override
  State<StatefulWidget> createState() => _BookCard(bookData);
}

class _BookCard extends State<BookCard> {
  _BookCard(this.bookData);

  final BookData bookData;

  @override
  Widget build(BuildContext context) {
    String title = bookData.title ?? "";
    String authors = bookData.authors?.join(", ") ?? "";
    String imageURL = bookData.images?["smallThumbnail"] ?? "";

    NetworkImage image = NetworkImage(imageURL);

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => BookDetailRoute(bookData: bookData)));
      },
      child : Card(
        margin: EdgeInsets.all(12),
        child: Row(
          children: [
            Image(image: image, height: MediaQuery.sizeOf(context).height * 0.2),
            SizedBox(width: 12,),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    title.trim(),
                    softWrap: true
                  ),
                  Text(authors,
                    softWrap: true,
                    style: TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis
                  )
                ],
              )
            )
          ],
        ),
      )
    );
  }
}