class VideoModel {
  final String title;
  final String description;
  final String thumbnailUrl;
  final String videoUrl;
  final String subject;

  const VideoModel({
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.subject,
  });
}

// Playgroup Videos
final List<VideoModel> playgroupVideoList = [
  VideoModel(
    title: "The ABC",
    description:
        "The ABC Song | Alphabet Song | First Step of English Phonics!",
    thumbnailUrl: "assets/video_images/ABC.png",
    videoUrl: "https://youtu.be/4QmjP020Sv8?si=Vs9jbl3xgvVTBYYa",
    subject: "English",
  ),
  VideoModel(
    title: "The ABC",
    description:
        "The ABC Song | Alphabet Song | First Step of English Phonics!",
    thumbnailUrl: "assets/video_images/ABC.png",
    videoUrl: "https://youtu.be/4QmjP020Sv8?si=Vs9jbl3xgvVTBYYa",
    subject: "English",
  ),
];

// Nursery Videos
final List<VideoModel> nurseryVideoList = [
  VideoModel(
    title: "Nursery Rhymes: Twinkle Twinkle",
    description: "Classic rhymes for nursery kids",
    thumbnailUrl: "assets/video_images/ABC.png",
    videoUrl: "https://www.youtube.com/watch?v=4QmjP020Sv8",
    subject: "Nursery",
  ),
];

// Prep Videos
final List<VideoModel> prepVideoList = [
  VideoModel(
    title: "Alphabet Song",
    description: "Learn ABCs with fun",
    thumbnailUrl: "assets/video_images/ABC.png",
    videoUrl: "https://www.youtube.com/watch?v=4QmjP020Sv8",
    subject: "English",
  ),
];

// Class 1 (1st) Videos
final List<VideoModel> class1VideoList = [
  VideoModel(
    title: "Basic Addition",
    description: "Learn to add numbers",
    thumbnailUrl: "https://img.youtube.com/vi/bAerID24QJ0/maxresdefault.jpg",
    videoUrl: "https://youtu.be/NUMz00m8ySk?si=HBTeWdRXbSTuUUP4",
    subject: "Mathematics",
  ),
];

// Class 2 (2nd) Videos
final List<VideoModel> class2VideoList = [
  VideoModel(
    title: "Introduction to Shapes",
    description: "Circle, Square, Triangle",
    thumbnailUrl: "https://img.youtube.com/vi/xCdxURXMdFY/maxresdefault.jpg",
    videoUrl: "https://www.youtube.com/watch?v=xCdxURXMdFY",
    subject: "Mathematics",
  ),
];

// Class 3 (3rd) Videos
final List<VideoModel> class3VideoList = [
  VideoModel(
    title: "Multiplication Tables",
    description: "Tables 2 to 10",
    thumbnailUrl: "https://img.youtube.com/vi/bAerID24QJ0/maxresdefault.jpg",
    videoUrl: "https://youtu.be/NUMz00m8ySk?si=HBTeWdRXbSTuUUP4",
    subject: "Mathematics",
  ),
];

// Class 4 (4th) Videos
final List<VideoModel> class4VideoList = [
  VideoModel(
    title: "Fractions Made Easy",
    description: "Understanding parts of a whole",
    thumbnailUrl: "https://img.youtube.com/vi/xCdxURXMdFY/maxresdefault.jpg",
    videoUrl: "https://www.youtube.com/watch?v=xCdxURXMdFY",
    subject: "Mathematics",
  ),
];

// Class 5 (5th) Videos
final List<VideoModel> class5VideoList = [
  VideoModel(
    title: "Introduction to Force",
    description: "Push and Pull",
    thumbnailUrl: "https://img.youtube.com/vi/kKKM8Y-u7ds/maxresdefault.jpg",
    videoUrl: "https://www.youtube.com/watch?v=kKKM8Y-u7ds",
    subject: "Science",
  ),
];

// Class 6 (6th) Videos
final List<VideoModel> class6VideoList = [
  VideoModel(
    title: "States of Matter",
    description: "Solid, Liquid, Gas",
    thumbnailUrl: "https://img.youtube.com/vi/0RRVV4Diomg/maxresdefault.jpg",
    videoUrl: "https://www.youtube.com/watch?v=0RRVV4Diomg",
    subject: "Science",
  ),
];

// Class 7 (7th) Videos
final List<VideoModel> class7VideoList = [
  VideoModel(
    title: "Laws of Motion",
    description: "Newton's First Law",
    thumbnailUrl: "https://img.youtube.com/vi/kKKM8Y-u7ds/maxresdefault.jpg",
    videoUrl: "https://www.youtube.com/watch?v=kKKM8Y-u7ds",
    subject: "Physics",
  ),
];

// Class 8 (8th) Videos
final List<VideoModel> class8VideoList = [
  VideoModel(
    title: "Atomic Structure",
    description: "Protons, Neutrons, Electrons",
    thumbnailUrl: "https://img.youtube.com/vi/0RRVV4Diomg/maxresdefault.jpg",
    videoUrl: "https://www.youtube.com/watch?v=0RRVV4Diomg",
    subject: "Chemistry",
  ),
];

// Class 9 (9th) Videos
final List<VideoModel> class9VideoList = [
  VideoModel(
    title: "Algebra Basics: Linear Equations",
    description: "Chapter 1 - Introduction to Algebra",
    thumbnailUrl: "https://img.youtube.com/vi/bAerID24QJ0/maxresdefault.jpg",
    videoUrl: "https://youtu.be/NUMz00m8ySk?si=HBTeWdRXbSTuUUP4",
    subject: "Mathematics",
  ),
  VideoModel(
    title: "Geometry: Area and Perimeter",
    description: "Chapter 3 - Shapes and Sizes",
    thumbnailUrl: "https://img.youtube.com/vi/xCdxURXMdFY/maxresdefault.jpg",
    videoUrl: "https://www.youtube.com/watch?v=xCdxURXMdFY",
    subject: "Mathematics",
  ),
  VideoModel(
    title: "Newton's Laws of Motion",
    description: "Chapter 2 - Force and Motion",
    thumbnailUrl: "https://img.youtube.com/vi/kKKM8Y-u7ds/maxresdefault.jpg",
    videoUrl: "https://www.youtube.com/watch?v=kKKM8Y-u7ds",
    subject: "Physics",
  ),
];

// Class 10 (10th) Videos
final List<VideoModel> class10VideoList = [
  VideoModel(
    title: "The Periodic Table",
    description: "Chapter 4 - Elements",
    thumbnailUrl: "https://img.youtube.com/vi/0RRVV4Diomg/maxresdefault.jpg",
    videoUrl: "https://www.youtube.com/watch?v=0RRVV4Diomg",
    subject: "Chemistry",
  ),
];

// Helper function to get videos by class
List<VideoModel> getVideosForClass(String className) {
  // Normalize string for comparison
  final normalizedClass = className.trim().toLowerCase();

  switch (normalizedClass) {
    case "playgroup":
      return playgroupVideoList;
    case "nursery":
      return nurseryVideoList;
    case "prep":
      return prepVideoList;
    case "1st":
    case "class 1":
    case "class1":
      return class1VideoList;
    case "2nd":
    case "class 2":
    case "class2":
      return class2VideoList;
    case "3rd":
    case "class 3":
    case "class3":
      return class3VideoList;
    case "4th":
    case "class 4":
    case "class4":
      return class4VideoList;
    case "5th":
    case "class 5":
    case "class5":
      return class5VideoList;
    case "6th":
    case "class 6":
    case "class6":
      return class6VideoList;
    case "7th":
    case "class 7":
    case "class7":
      return class7VideoList;
    case "8th":
    case "class 8":
    case "class8":
      return class8VideoList;
    case "9th":
    case "class 9":
    case "class9":
      return class9VideoList;
    case "10th":
    case "class 10":
    case "class10":
      return class10VideoList;
    default:
      return [];
  }
}
