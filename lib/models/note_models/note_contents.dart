class BaseContentTypes {}

class TextContent extends BaseContentTypes {
  TextContent({required this.text});
  final String text;
}

enum ImageContentTypes {
  local,
  link,
  empty
}

class ImageContent extends BaseContentTypes {
  ImageContent({required this.type, required this.image});
  final ImageContentTypes type;
  final String? image;
}
