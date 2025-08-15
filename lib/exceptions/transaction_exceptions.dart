import '../models/account.dart';

class SenderNotExistsException implements Exception {
  final String message;
  SenderNotExistsException({this.message = "Remetente não existe."});
}

class ReceiverNotExistsException implements Exception {
  final String message;
  ReceiverNotExistsException({this.message = "Destinatário não existe."});
}

class InsufficientFundsException implements Exception {
  String message;
  Account cause;
  double amount;
  double taxes;

  InsufficientFundsException({
    this.message = "Fundos insuficientes para a transacao.",
    required this.cause,
    required this.amount,
    required this.taxes,
  });
}
