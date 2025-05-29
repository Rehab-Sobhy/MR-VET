class CourseModel {
  final String id;
  final String title;
  final String description;
  final int price;
  final String category;
  final String? courseImage;
  final String instructor;
  final DateTime createdAt;
  final DateTime updatedAt;

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    this.courseImage,
    required this.instructor,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      price: json['price'],
      category: json['category'],
      courseImage: json['courseImage'],
      instructor: json['instructor'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
