class Links {
  final String download;
  final String downloadLocation;
  final String html;
  final String likes;
  final String photos;
  final String portfolio;
  final String self;

  Links(
      {this.download,
      this.downloadLocation,
      this.html,
      this.likes,
      this.photos,
      this.portfolio,
      this.self});

  factory Links.fromJson(Map<String, dynamic> json) {
    return Links(
      download: json['download'],
      downloadLocation: json['download_location'],
      html: json['html'],
      likes: json['likes'],
      photos: json['photos'],
      portfolio: json['portfolio'],
      self: json['self'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['download'] = this.download;
    data['download_location'] = this.downloadLocation;
    data['html'] = this.html;
    data['likes'] = this.likes;
    data['photos'] = this.photos;
    data['portfolio'] = this.portfolio;
    data['self'] = this.self;
    return data;
  }
}

class Urls {
  final String full;
  final String raw;
  final String regular;
  final String small;
  final String thumb;

  Urls({this.full, this.raw, this.regular, this.small, this.thumb});

  factory Urls.fromJson(Map<String, dynamic> json) {
    return Urls(
      full: json['full'],
      raw: json['raw'],
      regular: json['regular'],
      small: json['small'],
      thumb: json['thumb'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['full'] = this.full;
    data['raw'] = this.raw;
    data['regular'] = this.regular;
    data['small'] = this.small;
    data['thumb'] = this.thumb;
    return data;
  }
}

class Photo {
  final String color;
  final String createdAt;
  final List<CurrentUserCollection> currentUserCollections;
  final String description;
  final int height;
  final String id;
  final bool likedByUser;
  final int likes;
  final Links links;
  final String updatedAt;
  final Urls urls;
  final User user;
  final int width;

  Photo(
      {this.color,
      this.createdAt,
      this.currentUserCollections,
      this.description,
      this.height,
      this.id,
      this.likedByUser,
      this.likes,
      this.links,
      this.updatedAt,
      this.urls,
      this.user,
      this.width});

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      color: json['color'],
      createdAt: json['created_at'],
      currentUserCollections: json['current_user_collections'] != null
          ? (json['current_user_collections'] as List)
              .map((i) => CurrentUserCollection.fromJson(i))
              .toList()
          : null,
      description: json['description'],
      height: json['height'],
      id: json['id'],
      likedByUser: json['liked_by_user'],
      likes: json['likes'],
      links: json['links'] != null ? Links.fromJson(json['links']) : null,
      updatedAt: json['updated_at'],
      urls: json['urls'] != null ? Urls.fromJson(json['urls']) : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      width: json['width'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['color'] = this.color;
    data['created_at'] = this.createdAt;
    data['description'] = this.description;
    data['height'] = this.height;
    data['id'] = this.id;
    data['liked_by_user'] = this.likedByUser;
    data['likes'] = this.likes;
    data['updated_at'] = this.updatedAt;
    data['width'] = this.width;
    if (this.currentUserCollections != null) {
      data['current_user_collections'] =
          this.currentUserCollections.map((v) => v.toJson()).toList();
    }
    if (this.links != null) {
      data['links'] = this.links.toJson();
    }
    if (this.urls != null) {
      data['urls'] = this.urls.toJson();
    }
    if (this.user != null) {
      data['user'] = this.user.toJson();
    }
    return data;
  }
}

class CurrentUserCollection {
  final Photo coverPhoto;
  final int id;
  final String publishedAt;
  final String title;
  final String updatedAt;
  final User user;

  CurrentUserCollection(
      {this.coverPhoto,
      this.id,
      this.publishedAt,
      this.title,
      this.updatedAt,
      this.user});

  factory CurrentUserCollection.fromJson(Map<String, dynamic> json) {
    return CurrentUserCollection(
      coverPhoto: json['cover_photo'] != null
          ? Photo.fromJson(json['cover_photo'])
          : null,
      id: json['id'],
      publishedAt: json['published_at'],
      title: json['title'],
      updatedAt: json['updated_at'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['published_at'] = this.publishedAt;
    data['title'] = this.title;
    data['updated_at'] = this.updatedAt;
    if (this.coverPhoto != null) {
      data['cover_photo'] = this.coverPhoto.toJson();
    }
    if (this.user != null) {
      data['user'] = this.user.toJson();
    }
    return data;
  }
}

class User {
  final String bio;
  final String id;
  final String instagramUsername;
  final Links links;
  final String location;
  final String name;
  final String portfolioUrl;
  final ProfileImage profileImage;
  final int totalCollections;
  final int totalLikes;
  final int totalPhotos;
  final String twitterUsername;
  final String username;

  User(
      {this.bio,
      this.id,
      this.instagramUsername,
      this.links,
      this.location,
      this.name,
      this.portfolioUrl,
      this.profileImage,
      this.totalCollections,
      this.totalLikes,
      this.totalPhotos,
      this.twitterUsername,
      this.username});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      bio: json['bio'],
      id: json['id'],
      instagramUsername: json['instagram_username'],
      links: json['links'] != null ? Links.fromJson(json['links']) : null,
      location: json['location'],
      name: json['name'],
      portfolioUrl: json['portfolio_url'],
      profileImage: json['profile_image'] != null
          ? ProfileImage.fromJson(json['profile_image'])
          : null,
      totalCollections: json['total_collections'],
      totalLikes: json['total_likes'],
      totalPhotos: json['total_photos'],
      twitterUsername: json['twitter_username'],
      username: json['username'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['bio'] = this.bio;
    data['id'] = this.id;
    data['instagram_username'] = this.instagramUsername;
    data['location'] = this.location;
    data['name'] = this.name;
    data['portfolio_url'] = this.portfolioUrl;
    data['total_collections'] = this.totalCollections;
    data['total_likes'] = this.totalLikes;
    data['total_photos'] = this.totalPhotos;
    data['twitter_username'] = this.twitterUsername;
    data['username'] = this.username;
    if (this.links != null) {
      data['links'] = this.links.toJson();
    }
    if (this.profileImage != null) {
      data['profile_image'] = this.profileImage.toJson();
    }
    return data;
  }
}

class ProfileImage {
  final String large;
  final String medium;
  final String small;

  ProfileImage({this.large, this.medium, this.small});

  factory ProfileImage.fromJson(Map<String, dynamic> json) {
    return ProfileImage(
      large: json['large'],
      medium: json['medium'],
      small: json['small'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['large'] = this.large;
    data['medium'] = this.medium;
    data['small'] = this.small;
    return data;
  }
}
