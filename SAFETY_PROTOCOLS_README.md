# Safety Protocols Feature

This document describes the Safety Protocols feature implementation for the Proteq Mobile App.

## Overview

The Safety Protocols feature provides users with access to emergency procedures and safety guidelines for various situations including fire, earthquake, medical emergencies, security breaches, and general safety protocols.

## Architecture

The feature follows the established project architecture with three main layers:

### 1. Models (`lib/models/safety_protocol.dart`)
- `SafetyProtocol` class that represents a safety protocol
- Includes fields for type, title, description, steps, attachments, and metadata
- Provides JSON serialization/deserialization methods
- Includes helper methods for icon and color mapping

### 2. API Layer (`lib/api/safety_protocols_api.dart`)
- `SafetyProtocolsApi` class handles all HTTP requests
- Uses the centralized `ApiClient` for authentication and error handling
- Supports CRUD operations, search, filtering, and statistics
- Includes emergency contacts management

### 3. Service Layer (`lib/services/safety_protocols_service.dart`)
- `SafetyProtocolsService` provides business logic and data processing
- Handles authentication errors and retry logic
- Includes filtering, sorting, and search functionality
- Provides fallback data when API calls fail

### 4. Backend Controller (`controller/SafetyProtocols.php`)
- PHP REST API controller with comprehensive CRUD operations
- Supports multiple actions via query parameters
- Includes input validation and error handling
- Manages both protocols and emergency contacts

## Database Schema

### safety_protocols Table
```sql
CREATE TABLE safety_protocols (
  protocol_id INT PRIMARY KEY AUTO_INCREMENT,
  type VARCHAR(50) NOT NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  steps JSON NOT NULL,
  attachment VARCHAR(255),
  attachment_url VARCHAR(500),
  priority INT DEFAULT 0,
  is_active TINYINT(1) DEFAULT 1,
  created_by VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### emergency_contacts Table
```sql
CREATE TABLE emergency_contacts (
  contact_id INT PRIMARY KEY AUTO_INCREMENT,
  contact_type VARCHAR(50) NOT NULL UNIQUE,
  contact_value VARCHAR(255) NOT NULL,
  description VARCHAR(255),
  is_active TINYINT(1) DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

## API Endpoints

### Safety Protocols
- `GET /controller/SafetyProtocols.php?action=get_all` - Get all active protocols
- `GET /controller/SafetyProtocols.php?action=get_by_type&type={type}` - Get protocols by type
- `GET /controller/SafetyProtocols.php?action=get_by_id&id={id}` - Get specific protocol
- `POST /controller/SafetyProtocols.php?action=create` - Create new protocol
- `PUT /controller/SafetyProtocols.php?action=update&id={id}` - Update protocol
- `DELETE /controller/SafetyProtocols.php?action=delete&id={id}` - Delete protocol
- `POST /controller/SafetyProtocols.php?action=toggle_status&id={id}` - Toggle active status
- `GET /controller/SafetyProtocols.php?action=search&query={query}` - Search protocols
- `GET /controller/SafetyProtocols.php?action=stats` - Get protocol statistics

### Emergency Contacts
- `GET /controller/SafetyProtocols.php?action=emergency_contacts` - Get emergency contacts
- `POST /controller/SafetyProtocols.php?action=update_emergency_contacts` - Update contacts

## Features

### Frontend Features
1. **Dynamic Protocol Loading** - Protocols are loaded from the API instead of hardcoded data
2. **Search Functionality** - Real-time search across protocol titles, descriptions, and types
3. **Filtering** - Filter protocols by type (Fire, Earthquake, Medical, etc.)
4. **Emergency Contacts** - Dynamic emergency contact display with appropriate icons
5. **Loading States** - Proper loading indicators and error handling
6. **Retry Mechanism** - Users can retry failed data loads
7. **Responsive Design** - Works on different screen sizes

### Backend Features
1. **RESTful API** - Standard HTTP methods for all operations
2. **Input Validation** - Server-side validation for all inputs
3. **Error Handling** - Comprehensive error messages and status codes
4. **Database Optimization** - Proper indexing for performance
5. **JSON Support** - Protocol steps stored as JSON for flexibility
6. **Soft Deletes** - Protocols can be deactivated instead of deleted
7. **Statistics** - Built-in analytics for protocol usage

## Usage Examples

### Creating a New Protocol
```dart
final protocol = SafetyProtocol(
  type: 'Fire',
  title: 'Fire Safety',
  description: 'Emergency procedures for fire situations',
  steps: ['Step 1', 'Step 2', 'Step 3'],
  priority: 5,
);

final result = await SafetyProtocolsService.createProtocol(protocol);
```

### Loading Protocols
```dart
final protocols = await SafetyProtocolsService.getAllProtocols();
final fireProtocols = await SafetyProtocolsService.getProtocolsByType('Fire');
```

### Searching Protocols
```dart
final searchResults = await SafetyProtocolsService.searchProtocols('emergency');
```

### Getting Emergency Contacts
```dart
final contacts = await SafetyProtocolsService.getEmergencyContacts();
```

## Setup Instructions

1. **Database Setup**
   ```bash
   # Run the SQL schema
   mysql -u root -p proteq_db < controller/safety_protocols_schema.sql
   ```

2. **PHP Controller**
   - Place `SafetyProtocols.php` in your web server's controller directory
   - Ensure PHP has PDO and MySQL extensions enabled
   - Update database credentials in the controller if needed

3. **Flutter Integration**
   - The models, API, and service files are already integrated
   - The UI screen has been updated to use the new API
   - No additional configuration required

## Security Considerations

1. **Authentication** - All API calls require valid authentication tokens
2. **Input Sanitization** - All user inputs are validated and sanitized
3. **SQL Injection Prevention** - Uses prepared statements for all database queries
4. **CORS Headers** - Proper CORS configuration for cross-origin requests
5. **Error Information** - Error messages don't expose sensitive system information

## Performance Optimizations

1. **Database Indexing** - Proper indexes on frequently queried columns
2. **JSON Storage** - Efficient storage of protocol steps as JSON
3. **Caching** - Consider implementing Redis caching for frequently accessed data
4. **Pagination** - Large datasets can be paginated for better performance
5. **Lazy Loading** - Protocols are loaded on-demand

## Future Enhancements

1. **Protocol Categories** - Hierarchical organization of protocols
2. **User Permissions** - Role-based access to protocol management
3. **Protocol Versioning** - Track changes and maintain history
4. **Multimedia Support** - Images and videos in protocols
5. **Offline Support** - Cache protocols for offline access
6. **Push Notifications** - Alert users about new or updated protocols
7. **Analytics Dashboard** - Detailed usage statistics and insights

## Troubleshooting

### Common Issues

1. **Database Connection Errors**
   - Verify database credentials in the PHP controller
   - Ensure MySQL service is running
   - Check network connectivity

2. **Authentication Errors**
   - Verify user session is valid
   - Check token expiration
   - Ensure proper headers are sent

3. **Empty Protocol Lists**
   - Check if protocols exist in the database
   - Verify `is_active` flag is set to 1
   - Check API endpoint accessibility

4. **Search Not Working**
   - Verify search query is properly encoded
   - Check database indexes are created
   - Ensure JSON steps field is properly formatted

### Debug Mode

Enable debug logging by adding this to the PHP controller:
```php
error_reporting(E_ALL);
ini_set('display_errors', 1);
```

## Support

For issues or questions regarding the Safety Protocols feature, please refer to the project documentation or contact the development team. 