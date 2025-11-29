import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/Reservation.dart';
import '../../providers/auth-provider.dart';
import '../../providers/reservation_provider.dart';
import 'package:intl/intl.dart';


class ReservationFormPage extends StatefulWidget {
  final String itemId;
  final String itemTitle;
  final double dailyPrice;
  final String ownerId;

  const ReservationFormPage({
    Key? key,
    required this.itemId,
    required this.itemTitle,
    required this.dailyPrice,
    required this.ownerId,
  }) : super(key: key);

  @override
  _ReservationFormPageState createState() => _ReservationFormPageState();
}

class _ReservationFormPageState extends State<ReservationFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  int _numberOfDays = 0;
  double _totalPrice = 0.0;

  void _calculateTotal() {
    if (_startDate != null && _endDate != null) {
      _numberOfDays = _endDate!.difference(_startDate!).inDays;
      if (_numberOfDays < 1) _numberOfDays = 1;
      _totalPrice = _numberOfDays * widget.dailyPrice;
      setState(() {});
    }
  }

  Future<void> _selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
        _calculateTotal();
      });
    }
  }

  void _submitReservation() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez sélectionner les dates')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final reservationProvider = Provider.of<ReservationProvider>(context, listen: false);

    final reservation = Reservation(
      id: '',
      itemId: widget.itemId,
      itemTitle: widget.itemTitle,
      ownerId: widget.ownerId,
      renterId: authProvider.appUser!.id,
      renterName: authProvider.appUser!.name,
      startDate: _startDate!,
      endDate: _endDate!,
      totalPrice: _totalPrice,
      message: _messageController.text.trim(),
      status: 'pending',
      createdAt: DateTime.now(),
    );

    final success = await reservationProvider.createReservation(reservation);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Réservation envoyée avec succès!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: L\'objet n\'est pas disponible pour ces dates')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Réserver ${widget.itemTitle}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Réserver: ${widget.itemTitle}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text('Prix journalier: ${widget.dailyPrice}€'),
              SizedBox(height: 20),

              // Date Selection
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text('Date de début'),
                      subtitle: Text(_startDate == null
                          ? 'Sélectionner'
                          : DateFormat('dd/MM/yyyy').format(_startDate!)),
                      onTap: () => _selectDate(true),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: Text('Date de fin'),
                      subtitle: Text(_endDate == null
                          ? 'Sélectionner'
                          : DateFormat('dd/MM/yyyy').format(_endDate!)),
                      onTap: () => _selectDate(false),
                    ),
                  ),
                ],
              ),

              if (_numberOfDays > 0) ...[
                SizedBox(height: 20),
                Text('Nombre de jours: $_numberOfDays'),
                Text('Prix total: ${_totalPrice.toStringAsFixed(2)}€'),
              ],

              SizedBox(height: 20),
              TextFormField(
                controller: _messageController,
                decoration: InputDecoration(
                  labelText: 'Message (optionnel)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),

              SizedBox(height: 30),
              Consumer<ReservationProvider>(
                builder: (context, reservationProvider, child) {
                  return reservationProvider.isLoading
                      ? Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                    onPressed: _submitReservation,
                    child: Text('Envoyer la réservation'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}