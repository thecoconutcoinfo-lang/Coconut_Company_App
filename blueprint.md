# Project Blueprint

## Overview

This document outlines the project structure, features, and design of the Coconut Company application. It serves as a single source of truth for the application's current state and future development.

## Style, Design, and Features

### Initial Version

*   **Theme:** A simple theme with a primary color of `#34EB89`.
*   **Authentication:** A basic login screen.
*   **Firebase Integration:** The project is connected to Firebase.
*   **Firebase Services:**
    *   Firebase Authentication
    *   Cloud Firestore

### Login
*   **Login Screen:** A stateful login screen that handles user input, loading states, and error messages.
*   **Firebase Authentication:** The login screen uses `FirebaseAuth` to authenticate users with their email and password.
*   **Role-Based Navigation:** After a successful login, the application fetches the user's role from Cloud Firestore and navigates to the appropriate screen (`AdminMain` or `SellerMain`).

### Admin Dashboard V2 & Payment Flow

*   **Real-time Dashboard:** The `AdminDashboardScreen` now fetches data in real-time from a single Firestore document (`/dashboard/metrics`). This improves performance and scalability by avoiding client-side aggregation of the entire `sales` collection.
*   **Centralized Metrics:** The `payment_screen.dart` was updated to perform a transaction that atomically updates the central dashboard metrics (`total amount`, `total quantity`, `total UPI`, `total Cash`) upon successful payment. This ensures data consistency.
*   **Data Flow:** The `quantity` of an order is now passed through the entire seller flow: `OrderQuantityScreen` -> `CustomerDetailsScreen` -> `InvoiceScreen` -> `PaymentScreen`.

### Sales Tracking and User Order History

*   **Sales Collection**: On every successful payment, a new document is created in the `sales` collection. This document contains:
    *   `Customer Name`
    *   `Customer Mobile no`
    *   `Total Quantity Purchased`
    *   `Total Amount`
    *   `Seller Email ID`
    *   `timestamp`
*   **User Order History**: The document ID of each new sale is added to an `orders` array field in the corresponding seller's document within the `users` collection. This creates a reference to all sales made by a specific seller.
*   **Transactional Integrity**: The creation of a `sales` document, the update to the `dashboard/metrics` document, and the update to the seller's `orders` array are all performed within a single Firestore transaction to ensure data consistency.

## Current Plan

### Seller and Admin Customer Details

*   **Task:** Connect the `seller_customer_details_screen` and `admin_customer_details_screen` to Firebase to display real-time order data.
*   **Steps:**
    1.  **Seller Customer Details:**
        *   The `SellerCustomerDetailsScreen` now fetches and displays a list of orders made by the currently logged-in seller.
        *   It retrieves the `orders` array from the seller's document in the `users` collection and then fetches the corresponding order details from the `sales` collection.
        *   The UI has been updated to display detailed information for each order, including customer name, phone number, address, quantity, amount, payment method, and date.
    2.  **Admin Customer Details:**
        *   The `AdminCustomerDetailsScreen` now fetches and displays all orders from the `sales` collection, ordered by the most recent timestamp.
        *   The UI has been updated to display the same detailed order information as the seller's view, with the addition of the seller's email address for each order.
    3.  Both screens now use a `FutureBuilder` to handle loading and error states, providing a more robust user experience.
