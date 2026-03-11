class TodoTask {
  String? title;
  String? subTitle;
  bool? isDone;

  TodoTask({required this.title, this.isDone = false, required this.subTitle});

  Map<String, dynamic> toJson() => {
    'title': title,
    'subTitle': subTitle,
    'isDone': isDone,
  };

  factory TodoTask.fromJson(Map<String, dynamic> json) => TodoTask(
    title: json['title'],
    subTitle: json['subTitle'],
    isDone: json['isDone'],
  );

}
