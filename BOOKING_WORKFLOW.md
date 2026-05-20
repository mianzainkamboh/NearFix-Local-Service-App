# Booking Workflow Documentation

## Booking Status Flow

The booking system follows a clear status progression:

```
1. PENDING → 2. ACCEPTED → 3. IN_PROGRESS → 4. COMPLETED
                    ↓
                REJECTED
```

### Status Definitions

1. **PENDING** (Yellow/Warning)
   - Initial state when user creates a booking
   - Provider receives notification
   - Provider can Accept or Reject

2. **ACCEPTED** (Blue/Info)
   - Provider has accepted the booking
   - Service is scheduled
   - Provider can start the service

3. **IN_PROGRESS** (Blue/Info)
   - Provider has started working on the service
   - Service is actively being performed
   - Provider can mark as completed

4. **COMPLETED** (Green/Success)
   - Service has been finished
   - User can leave a review
   - Provider earnings are updated

5. **REJECTED** (Red/Error)
   - Provider declined the booking
   - User is notified with reason

6. **CANCELLED** (Red/Error)
   - User cancelled the booking
   - Can only be done when status is PENDING

## User Actions

### Creating a Booking
1. User selects provider/service
2. Chooses date (today or future)
3. Selects time slot (past times are disabled)
4. Enters service address
5. Adds optional notes
6. Selects payment method
7. Confirms booking → Status: **PENDING**

### Viewing Bookings
- User can see all their bookings in "My Bookings"
- Each booking shows:
  - Service name
  - Provider name
  - Date and time
  - Price
  - Current status
  - Action buttons (based on status)

### Cancelling Booking
- Only available when status is **PENDING**
- User clicks "Cancel Booking"
- Confirms cancellation
- Status changes to **CANCELLED**

### Leaving Review
- Available when status is **COMPLETED**
- User can rate provider (1-5 stars)
- Write review text
- Submit review

## Provider Actions

### Managing Bookings
Provider sees bookings in 4 tabs:
1. **Pending** - New booking requests
2. **Accepted** - Confirmed bookings
3. **In Progress** - Active services
4. **Completed** - Finished services

### Accepting/Rejecting Booking
When status is **PENDING**:
- Provider sees "Accept" and "Reject" buttons
- **Accept** → Status changes to **ACCEPTED**
- **Reject** → Status changes to **REJECTED**
- User receives notification

### Starting Service
When status is **ACCEPTED**:
- Provider sees "Start Service" button
- Clicks to begin work
- Status changes to **IN_PROGRESS**
- User receives notification

### Completing Service
When status is **IN_PROGRESS**:
- Provider sees "Mark Completed" button
- Clicks when service is finished
- Status changes to **COMPLETED**
- Provider stats updated:
  - `completedBookings` +1
  - `totalEarnings` + booking price
- User receives notification to leave review

## Admin View

Admin can see all bookings with filters:
- All bookings
- Pending
- Accepted
- In Progress
- Completed

Each booking shows:
- User name
- Provider name
- Service details
- Date, time, price
- Current status

## Past Time Prevention

### Date Selection
- User can only select today or future dates
- Date picker starts from today
- Maximum 30 days in advance

### Time Slot Selection
- If selected date is **today**:
  - Past time slots are disabled
  - Shown with strikethrough
  - Grayed out appearance
  - Cannot be clicked
- If selected date is **future**:
  - All time slots are available

### Validation
- When user clicks "Confirm Booking"
- System double-checks if time is in past
- Shows error: "Cannot book a time slot in the past"
- Prevents booking creation

### Time Slot Reset
- When user changes date
- Selected time slot is cleared
- User must select new time slot
- Ensures no invalid selection

## Notifications

Users and providers receive notifications for:

### User Notifications
- Booking accepted by provider
- Booking rejected by provider
- Service started (in progress)
- Service completed (with review prompt)

### Provider Notifications
- New booking request
- Booking cancelled by user

## Database Structure

### Booking Document
```json
{
  "id": "booking_id",
  "userId": "user_uid",
  "providerId": "provider_uid",
  "serviceId": "service_id",
  "serviceName": "Service Name",
  "date": "25/12/2024",
  "timeSlot": "10:00 AM",
  "address": "User's address",
  "notes": "Optional notes",
  "price": 500,
  "paymentMethod": "cash",
  "status": "pending",
  "createdAt": 1234567890,
  "updatedAt": 1234567890,
  "rejectionReason": "Optional reason if rejected",
  "isReviewed": false
}
```

## Status Colors

- **Pending**: Yellow (#F59E0B)
- **Accepted**: Blue (#3B82F6)
- **In Progress**: Blue (#3B82F6)
- **Completed**: Green (#10B981)
- **Cancelled**: Red (#EF4444)
- **Rejected**: Red (#EF4444)

## UI Components

### StatusChip Widget
- Displays booking status
- Color-coded background
- Border with transparency
- Rounded corners
- Handles all status types

### Booking Cards
- Show in lists (user/provider/admin)
- Display key information
- Status chip in top-right
- Action buttons based on status
- Tap to view details

### Booking Detail Screen
- Full booking information
- Large status indicator with icon
- Service details section
- Location section
- Action buttons (cancel/review)

## Business Logic

### Provider Stats Update
When booking is completed:
```dart
completedBookings = completedBookings + 1
totalEarnings = totalEarnings + booking.price
```

### Review Eligibility
- User can review only if:
  - Status is COMPLETED
  - isReviewed is false
- After review submitted:
  - isReviewed set to true
  - Review button hidden

## Error Handling

### Past Time Booking
- Error message shown
- Booking not created
- User must select valid time

### Missing Information
- Time slot required
- Address required
- Validation before submission

### Network Errors
- Error messages displayed
- User can retry
- Loading states shown

## Testing Checklist

- [ ] User can create booking with future date/time
- [ ] User cannot select past time slots
- [ ] Past time slots are visually disabled
- [ ] Booking starts with PENDING status
- [ ] Provider can accept booking → ACCEPTED
- [ ] Provider can reject booking → REJECTED
- [ ] Provider can start service → IN_PROGRESS
- [ ] Provider can complete service → COMPLETED
- [ ] User can cancel PENDING booking
- [ ] User can review COMPLETED booking
- [ ] Notifications sent at each status change
- [ ] Provider stats updated on completion
- [ ] All screens show correct status
- [ ] Status colors are consistent
- [ ] Time slot resets when date changes
