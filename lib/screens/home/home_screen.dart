import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:yakushima_guide/providers/post_provider.dart';
import 'package:yakushima_guide/widgets/post_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _goToNewPost(BuildContext context) {
    context.push('/new');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('屋久島ガイド'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.map), text: 'マップ'),
            Tab(icon: Icon(Icons.list), text: 'リスト'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _MapTab(onAddPressed: () => _goToNewPost(context)),
          const _ListTab(),
        ],
      ),
    );
  }
}

class _ListTab extends ConsumerWidget {
  const _ListTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsync = ref.watch(postListProvider);

    return postAsync.when(
      data: (posts) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: posts.length,
        itemBuilder: (context, index) => PostCard(post: posts[index]),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('エラー: $e')),
    );
  }
}

class _MapTab extends ConsumerWidget {
  final VoidCallback onAddPressed;
  const _MapTab({Key? key, required this.onAddPressed}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsync = ref.watch(postListProvider);

    return postAsync.when(
      data: (posts) {
        final markers = posts.map((post) {
          return Marker(
            width: 40,
            height: 40,
            point: LatLng(post.latitude, post.longitude),
            child: const Icon(Icons.location_on, color: Colors.red, size: 30),
          );
        }).toList();

        return Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                center: LatLng(30.34, 130.53),
                zoom: 10.5,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.yakushima_guide',
                ),
                MarkerLayer(markers: markers),
              ],
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: onAddPressed,
                child: const Icon(Icons.add),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('地図の読み込みに失敗しました: $e')),
    );
  }
}
