class BookModel {
  String name;
  String artUrl;
  int start;
  int end;

  BookModel(
    this.name,
    this.artUrl,
    this.start,
    this.end,
  );

  BookModel.fromJson(json)
      : name = json["name"],
        artUrl = json["artUrl"],
        start = json["start"],
        end = json["end"];

  toJson() {
    return {
      "name": this.name,
      "artUrl": this.artUrl,
      "start": this.start,
      "end": this.end,
    };
  }
}
