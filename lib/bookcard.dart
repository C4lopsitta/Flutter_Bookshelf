import 'package:flutter/material.dart';

import 'bookdata.dart';
import 'bookdetail.dart';

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
