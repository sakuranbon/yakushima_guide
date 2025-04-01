import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/post_model.dart';

class PostDetailScreen extends StatelessWidget {
  final PostModel post;
  const PostDetailScreen({Key? key, required this.post, required String postId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final visitedMonth = '${post.visitedAt.year}年${post.visitedAt.month}月';

    return Scaffold(
      appBar: AppBar(title: Text(post.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (post.imageUrls.isNotEmpty)
            SizedBox(
              height: 220,
              child: PageView.builder(
                itemCount: post.imageUrls.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(post.imageUrls[index]),
                        fit: BoxFit.contain,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children:
                post.categories.map((cat) => Chip(label: Text(cat))).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 18),
              const SizedBox(width: 8),
              Text('訪問時期：$visitedMonth'),
            ],
          ),
          const SizedBox(height: 12),
          Text(post.description, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(post.latitude, post.longitude),
                zoom: 14,
              ),
              markers: {
                Marker(
                  markerId: MarkerId(post.id),
                  position: LatLng(post.latitude, post.longitude),
                  infoWindow: InfoWindow(title: post.title),
                )
              },
              zoomControlsEnabled: false,
              myLocationEnabled: false,
            ),
          ),
        ],
      ),
    );
  }
}
