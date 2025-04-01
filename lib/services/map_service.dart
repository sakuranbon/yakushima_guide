import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/post_model.dart';

class MapService {
  Set<Marker> generateMarkersFromPosts(List<PostModel> posts) {
    return posts.map((post) {
      return Marker(
        markerId: MarkerId(post.id),
        position: LatLng(post.latitude, post.longitude),
        infoWindow: InfoWindow(
          title: post.title,
          snippet: post.categories.join(', '),
        ),
      );
    }).toSet();
  }

  CameraPosition getInitialCameraPosition() {
    return const CameraPosition(
      target: LatLng(30.335, 130.525),
      zoom: 11.0,
    );
  }
}
