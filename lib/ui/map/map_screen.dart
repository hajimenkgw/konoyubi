import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:konoyubi/analytics/analytics.dart';
import 'package:konoyubi/data/model/asobi.dart';
import 'package:konoyubi/ui/components/bottom_navigation.dart';
import 'package:konoyubi/ui/components/loading.dart';
import 'package:konoyubi/ui/map/show_asobi_description.dart';
import 'package:konoyubi/ui/utility/snapshot_error_handling.dart';
import 'package:konoyubi/ui/utility/use_firestore.dart';

final userLocationProvider = StateProvider<LatLng>(
    (ref) => const LatLng(35.659825668409056, 139.6987449178721));

class MapScreen extends StatelessWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: MapScreenView()),
      bottomNavigationBar: BottomNav(index: 1),
    );
  }
}

// TODO: データをコンテナ層に移行
class MapScreenView extends HookWidget {
  const MapScreenView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _markers = useState<Set<Marker>>({});
    final _mapController = useState<GoogleMapController?>(null);
    final activeAsobiList = useActiveAsobiList();
    final loc = useProvider(userLocationProvider);

    CameraPosition _initialPosition = CameraPosition(
      target: loc.state,
      zoom: 15,
    );

    Marker _buildMarker({
      required String id,
      required LatLng position,
      required String title,
      required Asobi asobi,
    }) {
      return Marker(
        markerId: MarkerId(id),
        position: position,
        infoWindow: InfoWindow(title: title),
        onTap: () async {
          await reportTapEvent('marker');

          showAsobiDescription(context: context, asobi: asobi);
        },
      );
    }

    void _onMapCreated(GoogleMapController controller) {
      _mapController.value = controller;
      final list = toAsobi(activeAsobiList.data!.docs);
      _markers.value.addAll(
        list.map(
          (asobi) {
            final id = asobi.id;
            final lat = asobi.position.latitude;
            final lng = asobi.position.longitude;
            return _buildMarker(
              id: id,
              position: LatLng(lat, lng),
              title: asobi.title,
              asobi: asobi,
            );
          },
        ),
      );
    }

    // ここから実行
    snapshotErrorHandling(activeAsobiList);

    if (!activeAsobiList.hasData) {
      return const Loading();
    } else {
      return GoogleMap(
        onMapCreated: _onMapCreated,
        markers: _markers.value,
        mapType: MapType.normal,
        initialCameraPosition: _initialPosition,
      );
    }
  }
}

Future<void> getLocation() async {
  Position position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
  final user = useProvider(userLocationProvider);
  user.state = LatLng(position.latitude, position.longitude);
}
