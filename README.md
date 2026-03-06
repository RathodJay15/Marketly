# Marketly -- Flutter E-Commerce Application

A modern **Flutter-based E-Commerce mobile application** built with
**Firebase backend services**. Marketly allows users to browse products,
manage carts, place orders, and receive notifications, while admins can
manage products, categories, and orders through an integrated admin
system.

This project demonstrates **full-stack mobile development using
Flutter + Firebase** with scalable architecture.

------------------------------------------------------------------------

## Project Highlights

-   Full **E-Commerce workflow**
-   **Firebase backend integration**
-   **Admin management system**
-   **Real-time database updates**
-   **Cart expiration system**
-   **Push notifications**
-   **Theme customization**
-   **Scalable architecture**

------------------------------------------------------------------------

## Tech Stack

  Layer              Technology
  ------------------ ---------------------------
  Frontend           Flutter
  Database           Firebase Firestore
  Storage            Firebase Storage
  Authentication     Firebase Email & Password
  Notifications      Firebase Cloud Messaging
  State Management   Provider
  Backend Logic      Firebase Functions

------------------------------------------------------------------------

## User Features

### Authentication

-   Email & Password authentication
-   Register with **profile picture**
-   Secure login system

### Product Browsing

-   Browse products by category
-   Search products by **title or category**
-   View detailed product information
-   Product images stored in Firebase Storage

### Favorites

-   Add products to **favorites**
-   Quickly access liked products

### Cart Management

-   Add products to cart
-   Increase or decrease quantity
-   Remove items from cart
-   Clear entire cart
-   **Cart automatically expires after 1 hour**

### Checkout & Orders

-   Checkout and place orders (dummy checkout flow)
-   Order confirmation system
-   View **complete order history**
-   View **detailed order information**

### Address Management

-   Add multiple delivery addresses
-   Edit addresses
-   Set **default delivery address**

### Profile Management

-   View profile
-   Update profile information
-   Update profile picture

### Theme Customization

Users can switch between: - System Theme - Light Mode - Dark Mode

------------------------------------------------------------------------

## Notifications

Users receive notifications for:

-   **New product added**
-   **Cart expiration reminder**
-   **Order status updates**

Implemented using **Firebase Cloud Messaging (FCM)**.

------------------------------------------------------------------------

## Admin Features

### Secure Admin Login

-   Admin authentication system
-   Restricted admin access

### Category Management

Admins can: - Add categories - Update categories - Delete categories -
Activate / deactivate categories

### Product Management

Admins can: - Add new products - Upload multiple product images - Update
existing products - Delete products - Manage product stock

Product fields include: - Name - Price - Description - Category -
Images - Stock quantity

### User Management

-   View all registered users

### Order Management

Admins can: - View all orders - View detailed order information - Update
order status: - Pending - Shipped - Delivered

### Admin Dashboard

Dashboard displays: - Total Users - Total Orders - Total Revenue

------------------------------------------------------------------------

## Database Structure

Firestore collections:

    users
    products
    categories
    orders
    cart
    addresses

------------------------------------------------------------------------

## Architecture Overview

    Flutter App
         │
    Provider State Management
         │
    Firebase Services
     ├── Authentication
     ├── Firestore Database
     ├── Storage
     └── Cloud Messaging

------------------------------------------------------------------------

## Installation

### 1. Clone Repository

    git clone https://github.com/RathodJay15/marketly.git

### 2. Navigate to Project

    cd marketly

### 3. Install Dependencies

    flutter pub get

### 4. Configure Firebase

1.  Create a Firebase project
2.  Add Android app
3.  Download **google-services.json**
4.  Place it inside:

```{=html}
<!-- -->
```
    android/app/

### 5. Run the Application

    flutter run

------------------------------------------------------------------------

## Screenshots

(Add screenshots here)

Examples: - Home Screen - Product Details - Cart - Checkout - Admin
Dashboard

------------------------------------------------------------------------

## Upcoming Features

-   Razorpay Payment Gateway Integration

------------------------------------------------------------------------

## Developer

**Jay Rathod**\
Android & Flutter Developer

------------------------------------------------------------------------

## Project Status

The application is currently under **active development**.
