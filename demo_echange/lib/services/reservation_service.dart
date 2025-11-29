import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/Reservation.dart';
import 'firebase-service.dart';

class ReservationService {
  final FirebaseFirestore _firestore = FirebaseService.firestore;

  Future<String> createReservation(Reservation reservation) async {
    try {
      final docRef = _firestore.collection('reservations').doc();
      final newReservation = reservation.copyWith(id: docRef.id);
      await docRef.set(newReservation.toMap());
      return docRef.id;
    } catch (e) {
      print('Error creating reservation: $e');
      rethrow;
    }
  }

  Stream<List<Reservation>> getReservationsByOwner(String ownerId) {
    return _firestore
        .collection('reservations')
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Reservation.fromMap(doc.data()))
        .toList());
  }

  Stream<List<Reservation>> getReservationsByRenter(String renterId) {
    return _firestore
        .collection('reservations')
        .where('renterId', isEqualTo: renterId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Reservation.fromMap(doc.data()))
        .toList());
  }

  Future<void> updateReservationStatus(String reservationId, String status) async {
    try {
      await _firestore.collection('reservations').doc(reservationId).update({
        'status': status,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      print('Error updating reservation: $e');
      rethrow;
    }
  }

  Future<bool> isItemAvailable(String itemId, DateTime startDate, DateTime endDate) async {
    try {
      final reservations = await _firestore
          .collection('reservations')
          .where('itemId', isEqualTo: itemId)
          .where('status', whereIn: ['pending', 'accepted'])
          .get();

      for (final doc in reservations.docs) {
        final reservation = Reservation.fromMap(doc.data());
        // Check for date overlap
        if (startDate.isBefore(reservation.endDate) && endDate.isAfter(reservation.startDate)) {
          return false;
        }
      }
      return true;
    } catch (e) {
      print('Error checking availability: $e');
      return false;
    }
  }
}