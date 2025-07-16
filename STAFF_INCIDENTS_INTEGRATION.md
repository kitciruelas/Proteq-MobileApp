# StaffIncidents API Integration

This document describes the integration of the StaffIncidents API with the Flutter mobile app's responder home tab.

## Overview

The integration allows staff responders to:
- View incidents assigned to them
- See real-time statistics and response metrics
- Update their location for distance calculations
- Filter and sort incidents by priority and distance
- Accept and manage incident assignments

## Files Created/Modified

### New Files
1. **`lib/api/staff_incidents_api.dart`** - API client for staff incidents
2. **`lib/models/assigned_incident.dart`** - Enhanced incident model with staff assignment data
3. **`lib/services/staff_incidents_service.dart`** - Service layer for staff incidents
4. **`test/staff_incidents_service_test.dart`** - Unit tests for the service
5. **`STAFF_INCIDENTS_INTEGRATION.md`** - This documentation

### Modified Files
1. **`lib/responders_screen/responder_home_tab.dart`** - Updated to use real API data

## API Endpoints

### Get Assigned Incidents
- **Endpoint**: `GET /controller/StaffIncidents.php`
- **Query Parameters**:
  - `status` (optional): Filter by incident status
  - `priority_level` (optional): Filter by priority level
  - `incident_type` (optional): Filter by incident type
- **Response**: List of assigned incidents with distance calculations

### Update Staff Location
- **Endpoint**: `POST /controller/StaffIncidents.php?action=location`
- **Body**: `{"latitude": double, "longitude": double}`
- **Response**: Success/failure status

## Features Implemented

### 1. Real-time Response Overview
- Active incidents count
- Critical incidents count
- Nearby incidents (within 1km)
- Resolved incidents today
- Total assigned incidents

### 2. Dynamic Incident List
- Shows up to 3 most relevant incidents
- Sorted by priority and distance
- Color-coded by priority level
- Shows distance and time information
- Tap to view incident details

### 3. Interactive Features
- Pull-to-refresh functionality
- Emergency call button (updates location)
- Refresh button to reload data
- Incident detail dialogs
- Accept incident functionality

### 4. Error Handling
- Authentication error handling
- Network error handling
- Loading states
- User-friendly error messages

## Data Flow

1. **Initial Load**: App loads staff data and assigned incidents
2. **Location Update**: Staff location is updated for distance calculations
3. **Data Processing**: Incidents are sorted by priority and distance
4. **Statistics Calculation**: Response metrics are calculated
5. **UI Update**: Real-time data is displayed in the UI

## Usage

### For Staff Responders
1. Open the responder home tab
2. View real-time incident statistics
3. See nearby incidents with distance information
4. Tap on incidents to view details
5. Use emergency call or refresh buttons as needed

### For Developers
1. The integration uses the existing authentication system
2. All API calls are authenticated automatically
3. Error handling is built into the service layer
4. The UI gracefully handles loading and error states

## Testing

Run the unit tests:
```bash
flutter test test/staff_incidents_service_test.dart
```

## Future Enhancements

1. **GPS Integration**: Replace mock coordinates with real GPS data
2. **Push Notifications**: Real-time incident notifications
3. **Map Integration**: Show incidents on a map view
4. **Status Updates**: Allow staff to update incident status
5. **Team Coordination**: Multi-staff incident management

## Dependencies

- Flutter framework
- HTTP client for API calls
- Path provider for session storage
- Existing authentication system

## Security

- All API calls require authentication
- Session management is handled automatically
- Location data is transmitted securely
- Error messages don't expose sensitive information 