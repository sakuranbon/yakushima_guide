import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:firebase_auth/firebase_auth.dart';

import '../../screens/map/map_select_screen.dart';
import '../../repositories/post_repository.dart';
import '../../models/post_model.dart';

class NewPostScreen extends StatefulWidget {
  const NewPostScreen({super.key});

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  DateTime? _visitedDate;
  final List<String> _selectedCategories = [];
  final List<String> _allCategories = [
    '自然スポット',
    'グルメ',
    '宿泊施設',
    '体験',
    'お土産',
    'その他',
  ];

  final List<XFile> _images = [];
  gmap.LatLng? _selectedLatLng;

  final _postRepo = PostRepository();

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(imageQuality: 80);
    if (pickedFiles.isNotEmpty) {
      setState(() {
        final remaining = 5 - _images.length;
        _images.addAll(pickedFiles.take(remaining));
        if (_images.length > 5) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('写真は最大5枚までです')),
          );
        }
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() &&
        _visitedDate != null &&
        _selectedCategories.isNotEmpty &&
        _images.isNotEmpty &&
        _selectedLatLng != null) {
      try {
        final userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';

        final post = PostModel(
          id: '',
          title: _titleController.text,
          description: _descController.text,
          imageUrls: [],
          visitedAt: _visitedDate!,
          categories: _selectedCategories,
          latitude: _selectedLatLng!.latitude,
          longitude: _selectedLatLng!.longitude,
          createdAt: DateTime.now(),
          userId: userId,
        );

        await _postRepo.uploadPost(post: post, imageFiles: _images);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('投稿が保存されました！')),
        );

        Navigator.pop(context); // 戻る
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存に失敗しました: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('すべての項目を正しく入力してください')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('新規投稿')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('写真（最大5枚）',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextButton.icon(
                      onPressed: _pickImages,
                      icon: const Icon(Icons.add_photo_alternate),
                      label: const Text('追加'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _images.length,
                    itemBuilder: (context, index) {
                      return FutureBuilder<Uint8List>(
                        future: _images[index].readAsBytes(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox(
                              width: 100,
                              height: 100,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          return Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: MemoryImage(snapshot.data!),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => _removeImage(index),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(Icons.close,
                                        size: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'スポット名',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'スポット名を入力してください' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: '紹介文（10〜100文字）',
                border: OutlineInputBorder(),
              ),
              maxLength: 100,
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().length < 10) {
                  return '10文字以上入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(
                _visitedDate == null
                    ? '訪問時期を選択'
                    : '${_visitedDate!.year}年${_visitedDate!.month}月',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final now = DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  initialDate: now,
                  firstDate: DateTime(2020),
                  lastDate: now,
                  locale: const Locale('ja'),
                );
                if (picked != null) {
                  setState(() => _visitedDate = picked);
                }
              },
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: _allCategories.map((category) {
                final isSelected = _selectedCategories.contains(category);
                return FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedCategories.add(category);
                      } else {
                        _selectedCategories.remove(category);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () async {
                final result = await Navigator.push<gmap.LatLng>(
                  context,
                  MaterialPageRoute(builder: (_) => const MapSelectScreen()),
                );

                print("Navigator.pushで受け取った型: ${result.runtimeType}");

                if (result != null) {
                  setState(() => _selectedLatLng = result);
                }
              },
              icon: const Icon(Icons.place),
              label: Text(
                _selectedLatLng == null
                    ? '地図でピンを立てる'
                    : '選択位置: (${_selectedLatLng!.latitude.toStringAsFixed(4)}, ${_selectedLatLng!.longitude.toStringAsFixed(4)})',
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('投稿する', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
