import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;

class MapSelectScreen extends StatefulWidget {
  const MapSelectScreen({super.key});

  @override
  State<MapSelectScreen> createState() => _MapSelectScreenState();
}

class _MapSelectScreenState extends State<MapSelectScreen> {
  latlng.LatLng _selectedPoint = latlng.LatLng(30.34, 130.53);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('地図でピンを立てる')),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              center: _selectedPoint,
              zoom: 10.5,
              onTap: (tapPosition, point) {
                setState(() => _selectedPoint = point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.yakushima_guide',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 40,
                    height: 40,
                    point: _selectedPoint,
                    child: const Icon(Icons.place, color: Colors.red, size: 36),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ElevatedButton.icon(
              onPressed: () {
                final converted = gmap.LatLng(
                  _selectedPoint.latitude,
                  _selectedPoint.longitude,
                );
                print("Navigator.popで返す型: ${converted.runtimeType}");
                Navigator.pop(context, converted);
              },
              icon: const Icon(Icons.check),
              label: const Text('この場所に決定'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
