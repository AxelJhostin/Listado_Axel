import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationService {
  LocationService._();

  static Future<Position> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException(
        'Activa el GPS del celular para guardar la ubicación.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const LocationException(
        'Se necesita permiso de ubicación para guardar el punto GPS.',
      );
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
        'Permiso de ubicación bloqueado. Actívalo en Ajustes del celular.',
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
  }

  static Future<void> openInMaps({
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    final query = label != null && label.isNotEmpty
        ? Uri.encodeComponent('$label@$latitude,$longitude')
        : '$latitude,$longitude';

    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw const LocationException('No se pudo abrir el mapa.');
    }
  }

  static String formatCoordinates(double latitude, double longitude) {
    return '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';
  }
}

class LocationException implements Exception {
  const LocationException(this.message);

  final String message;

  @override
  String toString() => message;
}
