# Booking Flow State Machine

## Status

Proposed client-side flow. There is no booking backend or booking feature in
the current scaffold. The server must remain authoritative for availability,
price, acceptance, and reservation creation.

## State Model

The form state describes the client's request lifecycle, not the final booking
status. A possible Dart model is:

```dart
sealed class BookingFormState {
  const BookingFormState();
}

final class BookingEditing extends BookingFormState {
  const BookingEditing();
}

final class BookingSubmitting extends BookingFormState {
  const BookingSubmitting();
}

final class BookingSubmitted extends BookingFormState {
  const BookingSubmitted(this.bookingId);

  final String bookingId;
}

final class BookingRejected extends BookingFormState {
  const BookingRejected(this.message);

  final String message;
}
```

This is illustrative and should be refined with typed error codes and form data
when the actual API contract is defined. The booking entity itself needs
separate server-defined statuses, such as requested, accepted, declined,
cancelled, or completed; do not conflate those with form submission states.

## Allowed Transitions

```text
Editing -> Submitting
Submitting -> Submitted
Submitting -> Rejected
Rejected -> Editing
Submitted -> terminal for this submission flow
```

Submission must be guarded so repeated taps cannot start parallel requests for
the same user action. Disable the submit control while submitting, but do not
rely on the UI guard for correctness. Use a server-supported idempotency key
where available; enforce availability and duplicate-request constraints on the
backend.

## Riverpod Integration

When Riverpod is introduced, use an annotated generated notifier to own form
state and invoke a booking repository. Widgets render the exhaustive state and
send intent; they do not call HTTP. Keep pricing and availability checks
server-validated immediately before accepting a reservation.

## Acceptance Checks

- State transitions are exhaustive and invalid transitions are rejected or
  made impossible by the controller API.
- Repeated submit attempts create at most one logical booking request.
- Network timeout and server rejection allow a safe retry without claiming the
  booking succeeded.
- Tests cover transition behavior, duplicate taps, timeout, rejection, and
  server-confirmed success.
