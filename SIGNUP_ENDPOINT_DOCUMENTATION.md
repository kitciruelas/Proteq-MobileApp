# Signup Endpoint Documentation

## New Signup Endpoint

**URL:** `POST /controller/User/Signup.php`

**Base URL:** `http://localhost/proteq-backend/api/controller/User/Signup.php`

## Request Format

### Headers
```
Content-Type: application/json
Accept: application/json
```

### Request Body (JSON)
```json
{
    "first_name": "John",
    "last_name": "Doe", 
    "email": "john.doe@example.com",
    "password": "SecurePassword123",
    "user_type": "STUDENT",
    "department": "ICT",
    "college": "BSIT"
}
```

### Required Fields
- `first_name` (string): User's first name
- `last_name` (string): User's last name  
- `email` (string): Valid email address
- `password` (string): Minimum 8 characters
- `user_type` (string): "STUDENT", "FACULTY", or "UNIVERSITY EMPLOYEE"
- `department` (string): Department name
- `college` (string): College/Course name

## Response Format

### Success Response (HTTP 201)
```json
{
    "success": true,
    "message": "User registered successfully",
    "user": {
        "user_id": 123,
        "first_name": "John",
        "last_name": "Doe",
        "email": "john.doe@example.com",
        "user_type": "STUDENT",
        "department": "ICT",
        "college": "BSIT",
        "status": 1
    }
}
```

### Error Response (HTTP 400)
```json
{
    "success": false,
    "message": "Error description"
}
```

## Common Error Messages

- `"Missing required field: [field_name]"`
- `"Invalid email format"`
- `"Password must be at least 8 characters long"`
- `"User with this email already exists"`
- `"Invalid JSON data provided"`

## Flutter Integration

The Flutter app has been updated to use this new endpoint. The `ApiService` class now includes a `signup()` method:

```dart
final result = await ApiService.signup(userData);
```

## Testing

Use the provided test file `test_new_signup_endpoint.php` to test the endpoint:

```bash
php test_new_signup_endpoint.php
```

## Database Schema

The endpoint inserts data into the `general_users` table with the following structure:

```sql
CREATE TABLE general_users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    user_type VARCHAR(50) NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    department VARCHAR(255) NOT NULL,
    college VARCHAR(255) NOT NULL,
    status TINYINT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## Security Features

- Password hashing using PHP's `password_hash()` function
- Input validation for all required fields
- Email format validation
- Password strength validation (minimum 8 characters)
- Duplicate email checking
- SQL injection prevention using prepared statements
- CORS headers for cross-origin requests

## File Location

The endpoint is located at:
```
backend/server/api/controller/User/Signup.php
```

## Dependencies

- PHP 7.4 or higher
- MySQL/MariaDB database
- PDO extension for database connectivity
- JSON extension for JSON processing 