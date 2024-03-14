import 'package:flutter/material.dart';

import 'bookdata.dart';

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
            ],
          ),
        )
    );
  }
}
