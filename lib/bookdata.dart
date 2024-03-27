class BookData {
  BookData(
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
  bool shouldLoadMoreBooks = false;
}
