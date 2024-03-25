import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'bookdata.dart';
import 'dialogs.dart';

class BookDetailRoute extends StatefulWidget {
  const BookDetailRoute({super.key, required this.bookData});
  final BookData bookData;

  @override
  State<BookDetailRoute> createState() => _BookDetailRoute(bookData);
}

class _BookDetailRoute extends State<BookDetailRoute> {
  _BookDetailRoute(this.bookData);
  final BookData bookData;

  Widget label(String label) => Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w300));

  @override
  Widget build(BuildContext context) {
    final String _title = bookData.title ?? "";
    final String _description = bookData.description ?? "No description provided";
    final List<String> _authors = [];
    final NetworkImage _image = NetworkImage(bookData.images?["thumbnail"] ?? "");
    final String _publisher = bookData.publisher ?? "No publisher provided";
    final String _date = bookData.publishedDate ?? "no published date provided";

    bookData.authors?.forEach((element) { _authors.add(element); });


    List<Widget> isbns = bookData.isbns?.map((e) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(e["identifier"]),
        if(e["type"] == "ISBN_13")
          IconButton(onPressed: (){ Dialogs.isbnDialog(context, e); }, icon: const Icon(Icons.qr_code_scanner))
      ],
    )).toList() ?? [];





    List<Widget> scrollableViewList =
    _buildRatingItem((bookData.data["averageRating"] ?? -1) * 1.0) +
    [
      label((_authors.length == 1) ? "Author" : "Authors"),
      Text(_authors.join(", "), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),),



      const SizedBox(height: 12),
      if((bookData.data["maturityRating"] ?? "") == "MATURE")
        const Row(children:[
          SizedBox(width: 8),
          Icon(Icons.explicit, size: 16,),
          SizedBox(width: 4),
          Text("The book is explicit", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300))
        ]
      ),


      label("Description"),
      Text(_description),
      const SizedBox(height: 12,),


    ] + _buildGenreChips((bookData.data["categories"] ?? []).toList()) + [

      if((bookData.data["pageCount"] ?? -1) >= 0)
        Text("${bookData.data["pageCount"]} Pages"),
      const SizedBox(height: 12),
      label("Published by"),
      Text("$_publisher; $_date"),
      const SizedBox(height: 12),
      label("ISBN Codes")
    ] + isbns + [
      const SizedBox(height: 12),
      label("Google Books ID: ${bookData.identifier}"),
      const SizedBox(height: 64)
    ];

    void _shareBookDetails() {
      Share.share("$_title\n${_authors.join(", ")}\n${bookData.url}");
    }

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(bookData.title ?? "Invalid book title"),
          actions: [
            if(bookData.url != null)
              IconButton(onPressed: (){
                _launchURL(Uri.parse(bookData.url ?? ""));
              }, icon: const Icon(Icons.info)),
            if(bookData.url != null)
              IconButton(onPressed: (){
                _shareBookDetails();
              }, icon: const Icon(Icons.share))
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if(_image.url.isNotEmpty)
                Image(image: _image),
              const SizedBox(width: 12,),

              label("Title"),
              Text(_title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400)),

              Expanded( child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: scrollableViewList,
                )
              )),
            ],
          ),
        )
    );
  }

  List<Widget> _buildRatingItem(double rating) {
    if(rating < 0) return [];
    return [
      label("Rating"),
      RatingBarIndicator(
        rating: rating,
        itemBuilder: (context, index) => const Icon(Icons.star, color: Colors.amber),
        itemCount: 5,
        itemSize: 24,
        direction: Axis.horizontal,
      ),
    ];
  }

  Future<void> _launchURL(Uri url) async {
    if(!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception("Failed to launch url");
    }
  }

  List<Widget> _buildGenreChips(List<dynamic> genres) {
    if(genres.isEmpty) return [];
    return [
      label("Genres"),
      SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: genres.map((genre) {
          return Chip(label: Text(genre));
        }).toList(),
      ),),
      const SizedBox(height: 12)
    ];
  }
}
