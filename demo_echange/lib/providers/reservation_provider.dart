import 'package:flutter/foundation.dart';
import '../models/Reservation.dart';
import '../services/reservation_service.dart';

class ReservationProvider with ChangeNotifier {
  final ReservationService _reservationService = ReservationService();
  List<Reservation> _reservations = [];
  List<Reservation> _receivedReservations = [];
  bool _isLoading = false;

  List<Reservation> get reservations => _reservations;
  List<Reservation> get receivedReservations => _receivedReservations;
  bool get isLoading => _isLoading;

  void loadUserReservations(String userId) {
    _reservationService.getReservationsByRenter(userId).listen((reservations) {
      _reservations = reservations;
      notifyListeners();
    });
  }

  void loadOwnerReservations(String ownerId) {
    _reservationService.getReservationsByOwner(ownerId).listen((reservations) {
      _receivedReservations = reservations;
      notifyListeners();
    });
  }

  Future<bool> createReservation(Reservation reservation) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check if item is available for the selected dates
      final isAvailable = await _reservationService.isItemAvailable(
        reservation.itemId,
        reservation.startDate,
        reservation.endDate,
      );

      if (!isAvailable) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await _reservationService.createReservation(reservation);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateReservationStatus(String reservationId, String status) async {
    try {
      await _reservationService.updateReservationStatus(reservationId, status);
      return true;
    } catch (e) {
      return false;
    }
  }
}