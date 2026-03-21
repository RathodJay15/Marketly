import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iconoir_icons/iconoir_icons.dart';
import 'package:marketly/core/constants/app_constants.dart';
import 'package:marketly/presentation/user/menu/address/address_form.dart';
import 'package:marketly/presentation/widgets/marketly_dialog.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with WidgetsBindingObserver {
  LatLng? selectedLocation;
  String? selectedAddress;
  GoogleMapController? mapController;
  bool _isDialogOpen = false;
  bool _isLoadingCurLocation = false;
  MapType _mapType = MapType.normal;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _getCurrentLocation();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await Future.delayed(const Duration(milliseconds: 500)); // wait

      if (!_isDialogOpen) {
        _getCurrentLocation();
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingCurLocation = true;
    });
    try {
      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();

      // If denied → request
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // If still denied
      if (permission == LocationPermission.denied) {
        _showError(AppConstants.locationPermissionDenied);
        return;
      }

      // If permanently denied
      if (permission == LocationPermission.deniedForever) {
        if (_isDialogOpen) return;

        _isDialogOpen = true;

        final choice = await MarketlyDialog.showMyDialog(
          context: context,
          title: AppConstants.permissionRequired,
          content: AppConstants.turnOnLocationMsg,
          actionYColor: Theme.of(context).colorScheme.onSecondary,
          actionY: AppConstants.openSettings,
          actionN: AppConstants.cancel,
        );

        _isDialogOpen = false;

        if (choice == true) {
          await Geolocator.openAppSettings();
        } else {
          _showError(AppConstants.turnOnLocationMsg);
          Navigator.pop(context);
        }
      }

      // If granted → get location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      LatLng currentLatLng = LatLng(position.latitude, position.longitude);
      setState(() {
        selectedLocation = currentLatLng;
        _isLoadingCurLocation = true;
      });

      await _getAddressFromLatLng(currentLatLng);
      setState(() {
        _isLoadingCurLocation = false;
      });

      mapController?.animateCamera(CameraUpdate.newLatLng(currentLatLng));
    } catch (e) {
      _showError(AppConstants.failedToLoadLocation);
    } finally {
      setState(() {
        _isLoadingCurLocation = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onInverseSurface,
          ),
        ),
      ),
    );
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks.first;

      String address =
          "${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country}, ${place.postalCode}";

      setState(() {
        selectedAddress = address;
      });
    } catch (e) {
      _showError(AppConstants.faildToGetAddress);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (mapController != null) mapController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              color: Theme.of(context).colorScheme.onInverseSurface,
              icon: Iconoir(IconoirIcons.navArrowLeft, size: 35),
            ),
            Text(
              AppConstants.selectLoction,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onInverseSurface,
                fontSize: 25,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.onInverseSurface,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: GoogleMap(
                      mapType: _mapType,
                      initialCameraPosition: const CameraPosition(
                        target: LatLng(22.3039, 70.8022),
                        zoom: 14,
                      ),
                      onMapCreated: (controller) {
                        mapController = controller;
                      },
                      myLocationEnabled: true, //  blue dot
                      myLocationButtonEnabled: true,
                      onTap: (LatLng position) async {
                        setState(() {
                          selectedLocation = position;
                          _isLoadingCurLocation = true;
                        });

                        await _getAddressFromLatLng(position);

                        setState(() {
                          _isLoadingCurLocation = false;
                        });
                        setState(() {
                          selectedLocation = position;
                        });
                      },

                      markers: selectedLocation == null
                          ? {}
                          : {
                              Marker(
                                markerId: const MarkerId("selected"),
                                position: selectedLocation!,
                              ),
                            },
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    onPressed: () {
                      setState(() {
                        _mapType = _mapType == MapType.normal
                            ? MapType.satellite
                            : MapType.normal;
                      });
                    },
                    child: Icon(
                      Icons.layers,
                      color: Theme.of(context).colorScheme.onInverseSurface,
                    ),
                  ),
                ),
                if (_isLoadingCurLocation)
                  Positioned.fill(
                    child: Container(
                      height: 70,
                      width: 70,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Theme.of(
                          context,
                        ).colorScheme.onTertiary.withAlpha(95),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              color: Theme.of(
                                context,
                              ).colorScheme.inversePrimary,
                            ),
                            SizedBox(height: 10),
                            Text(
                              AppConstants.fetchingCurrentLocation,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.inversePrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (selectedAddress != null)
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConstants.selectedAddress,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onInverseSurface,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Divider(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    thickness: 2,
                    radius: BorderRadius.circular(2),
                  ),
                  SizedBox(height: 5),
                  Text(
                    selectedAddress!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onInverseSurface,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          _addButton(),
        ],
      ),
    );
  }

  Widget _addButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: 200,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    AddressForm(title: AppConstants.addNewAdrs, address: null),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
            minimumSize: const Size(double.infinity, 50.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            AppConstants.contiueFillAddress,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
