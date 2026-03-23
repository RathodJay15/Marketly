import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iconoir_icons/iconoir_icons.dart';
import 'package:marketly/core/constants/app_constants.dart';
import 'package:marketly/data/models/address_model.dart';
import 'package:marketly/presentation/user/menu/address/address_form.dart';
import 'package:marketly/presentation/widgets/marketly_dialog.dart';

class MapScreen extends StatefulWidget {
  final AddressModel? address;
  MapScreen({super.key, this.address});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with WidgetsBindingObserver {
  LatLng? selectedLocation;
  String? selectedAddress;
  GoogleMapController? mapController;
  bool _isDialogOpen = false;
  bool _isLoadingCurLocation = true;
  MapType _mapType = MapType.normal;
  LatLng? _centerLatLng;

  CameraPosition get _initialCameraPosition {
    //  If editing address
    if (widget.address != null) {
      return CameraPosition(
        target: LatLng(widget.address!.lat, widget.address!.long),
        zoom: 20,
      );
    }

    //  If current location already fetched
    if (selectedLocation != null) {
      return CameraPosition(target: selectedLocation!, zoom: 20);
    }

    return const CameraPosition(
      target: LatLng(0, 0), // dummy (won’t be visible anyway)
      zoom: 1,
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    if (widget.address != null) {
      final latLng = LatLng(widget.address!.lat, widget.address!.long);

      selectedLocation = latLng;
      _centerLatLng = latLng;
      selectedAddress = widget.address!.address;

      // Move camera after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 20));
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _isLoadingCurLocation = true;
        });
        _getCurrentLocation();
      });
    }
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

      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(currentLatLng, 16),
        );
      }
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
          _map(),
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

  Widget _map() {
    if (_isLoadingCurLocation && selectedLocation == null) {
      return Expanded(
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.onInverseSurface,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: Theme.of(context).colorScheme.onInverseSurface,
              ),
              const SizedBox(height: 10),
              Text(
                AppConstants.fetchingCurrentLocation,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Expanded(
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
                initialCameraPosition: _initialCameraPosition,
                onMapCreated: (controller) {
                  mapController = controller;
                  if (selectedLocation != null) {
                    mapController!.animateCamera(
                      CameraUpdate.newLatLngZoom(selectedLocation!, 16),
                    );
                  }
                },
                myLocationEnabled: true, //  blue dot
                myLocationButtonEnabled: true,
                onCameraMove: (position) {
                  _centerLatLng = position.target;
                },

                onCameraIdle: () async {
                  if (_centerLatLng != null) {
                    setState(() {
                      _isLoadingCurLocation = true;
                      selectedLocation = _centerLatLng;
                    });
                    await Future.delayed(const Duration(milliseconds: 200));

                    await _getAddressFromLatLng(_centerLatLng!);

                    setState(() {
                      _isLoadingCurLocation = false;
                    });
                  }
                },
              ),
            ),
          ),

          Center(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: IgnorePointer(
                child: Icon(
                  Icons.location_on,
                  color: Theme.of(context).colorScheme.inversePrimary,
                  size: 40,
                ),
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
          if (_isLoadingCurLocation && widget.address == null)
            Positioned.fill(
              child: Container(
                height: 70,
                width: 70,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).colorScheme.onTertiary.withAlpha(95),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                      SizedBox(height: 10),
                      Text(
                        AppConstants.fetchingCurrentLocation,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
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
    );
  }

  Widget _addButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: 200,
        child: ElevatedButton(
          onPressed: () {
            if (_isLoadingCurLocation == true) return;
            if (widget.address != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddressForm(
                    lat: selectedLocation!.latitude,
                    long: selectedLocation!.longitude,
                    addressString: selectedAddress!,
                    address: widget.address,
                  ),
                ),
              );
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddressForm(
                  lat: selectedLocation!.latitude,
                  long: selectedLocation!.longitude,
                  addressString: selectedAddress!,
                  address: null,
                ),
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
