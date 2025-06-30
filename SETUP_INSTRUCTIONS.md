# Proteq Mobile App - Login System Setup

## Overview
The login system has been fixed and now includes:
- Real API integration with the backend
- Form validation
- User authentication
- Session management
- Registration flow

## Backend Setup

### 1. Database Setup
1. Import the database schema from `backend/server/database/proteq_db.sql`
2. Update database credentials in `backend/server/config/database.php`

### 2. Start Backend Server
1. Navigate to the backend directory: `cd backend/server`
2. Start a PHP development server:
   ```bash
   php -S localhost:8000
   ```
   Or use the provided setup script:
   ```bash
   setup.bat
   ```

### 3. Test Backend API
Run the test script to verify API connectivity:
```bash
cd backend
./test_api.sh
```

## Flutter App Setup

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Configure API Base URL
Edit `lib/services/api_service.dart` and update the base URL:
- For Android emulator: `http://10.0.2.2:8000/api`
- For web: `http://localhost:8000/api`
- For physical device: `http://YOUR_COMPUTER_IP:8000/api`

### 3. Test API Connection
Run the test script:
```bash
dart test_api_connection.dart
```

## Features Implemented

### Login Screen (`lib/login_screens/login_screen.dart`)
- Email and password validation
- Real API authentication
- Loading states
- Error handling
- Automatic navigation based on user type

### Registration Flow
1. **Step 1** (`lib/login_screens/signup_step1.dart`)
   - Personal information collection
   - Form validation
   - Role selection (Student/Faculty/Employee)

2. **Step 2** (`lib/login_screens/signup_step2.dart`)
   - Password creation with validation
   - Password strength requirements
   - Security tips

3. **Step 3** (`lib/login_screens/signup_step3.dart`)
   - Information review
   - Privacy policy agreement
   - API registration

### API Service (`lib/services/api_service.dart`)
- User authentication (login/register)
- Session management
- User profile operations
- Location updates
- Staff/responder data

## API Endpoints Used

### Authentication
- `POST /api/users/login` - User login
- `POST /api/users/register` - User registration

### User Management
- `GET /api/users/{id}` - Get user profile
- `PUT /api/users/{id}` - Update user profile/location
- `GET /api/users/staff` - Get all staff/responders
- `GET /api/users/staff-locations` - Get staff locations

## User Types
- **STUDENT** - University students
- **FACULTY** - Teaching staff
- **UNIVERSITY_EMPLOYEE** - Administrative staff
- **STAFF** - Emergency responders

## Security Features
- Password hashing (backend)
- Form validation (frontend)
- Session management with SharedPreferences
- CORS handling
- Input sanitization

## Troubleshooting

### Common Issues

1. **Connection Error**
   - Ensure backend server is running
   - Check IP address configuration
   - Verify port 8000 is accessible

2. **Database Connection Error**
   - Check database credentials
   - Ensure MySQL/PostgreSQL is running
   - Verify database schema is imported

3. **CORS Issues**
   - Check .htaccess file is in place
   - Verify CORS headers are set correctly

4. **Flutter Dependencies**
   - Run `flutter pub get`
   - Check pubspec.yaml for correct versions

### Testing
1. Test API endpoints using the provided test script
2. Test registration flow with a new user
3. Test login with registered user
4. Verify user type-based navigation

## File Structure
```
lib/
├── login_screens/
│   ├── login_screen.dart (Updated)
│   ├── signup_step1.dart (Updated)
│   ├── signup_step2.dart (Updated)
│   └── signup_step3.dart (Updated)
├── services/
│   └── api_service.dart (New)
└── models/
    └── user.dart (New)

backend/server/
├── api/
│   └── users.php (Fixed)
├── config/
│   └── database.php
└── .htaccess (New)
```

## Next Steps
1. Test the complete registration and login flow
2. Implement logout functionality
3. Add password reset functionality
4. Implement user profile management
5. Add location services integration 