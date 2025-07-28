import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/staff_location_service.dart';
import '../models/staff_location.dart';

class LocationUpdateWidget extends StatefulWidget {
  final int staffId;
  final String staffName;
  final VoidCallback? onLocationUpdated;

  const LocationUpdateWidget({
    super.key,
    required this.staffId,
    required this.staffName,
    this.onLocationUpdated,
  });

  @override
  State<LocationUpdateWidget> createState() => _LocationUpdateWidgetState();
}

class _LocationUpdateWidgetState extends State<LocationUpdateWidget> {
  bool _isUpdating = false;
  bool _isLoadingLocation = false;
  StaffLocation? _currentLocation;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _errorMessage = null;
    });

    try {
      final location = await StaffLocationService.getStaffLocation(widget.staffId);
      setState(() {
        _currentLocation = location;
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load current location: $e';
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _updateLocation() async {
    setState(() {
      _isUpdating = true;
      _errorMessage = null;
    });

    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'Location permission denied';
            _isUpdating = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'Location permissions are permanently denied';
          _isUpdating = false;
        });
        return;
      }

      // Get current position
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Update location on server
      final result = await StaffLocationService.updateLocation(
        staffId: widget.staffId,
        latitude: position.latitude,
        longitude: position.longitude,
        address: null, // You can add geocoding here if needed
      );

      if (result['success'] == true) {
        // Reload current location
        await _loadCurrentLocation();
        
        if (widget.onLocationUpdated != null) {
          widget.onLocationUpdated!();
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to update location';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error updating location: $e';
      });
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Location for ${widget.staffName}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Current location display
            if (_isLoadingLocation)
              const Center(child: CircularProgressIndicator())
            else if (_currentLocation != null)
              _buildLocationInfo(_currentLocation!)
            else
              const Text('No location data available'),
            
            const SizedBox(height: 16),
            
            // Error message
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red.shade600, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Update location button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isUpdating ? null : _updateLocation,
                icon: _isUpdating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location),
                label: Text(_isUpdating ? 'Updating...' : 'Update My Location'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Refresh button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isLoadingLocation ? null : _loadCurrentLocation,
                icon: _isLoadingLocation
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: Text(_isLoadingLocation ? 'Loading...' : 'Refresh Location'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfo(StaffLocation location) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Latitude', location.latitude.toStringAsFixed(6)),
        _buildInfoRow('Longitude', location.longitude.toStringAsFixed(6)),
        if (location.address != null)
          _buildInfoRow('Address', location.address!),
        if (location.lastUpdated != null)
          _buildInfoRow('Last Updated', _formatDateTime(location.lastUpdated!)),
        if (location.distance != null)
          _buildInfoRow('Distance', location.formattedDistance),
        _buildInfoRow('Status', location.statusDisplayName),
        _buildInfoRow('Availability', location.availabilityDisplayName),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeString;
    }
  }
} 