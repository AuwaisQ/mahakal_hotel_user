class Video {
  final String videoId;
  final String title;
  final String thumbnailUrl;

  Video(
      {required this.videoId, required this.title, required this.thumbnailUrl});

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      videoId: json['snippet']['resourceId']['videoId'],
      title: json['snippet']['title'],
      thumbnailUrl: json['snippet']['thumbnails']['high']['url'],
    );
  }
}
