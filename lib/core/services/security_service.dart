import 'package:cloud_firestore/cloud_firestore.dart';

class SecurityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Revisa si el RUT está en la "lista negra" y si el tiempo aún no expira
  Future<bool> estaBloqueado(String rut) async {
    final doc = await _firestore.collection('bloqueos_seguridad').doc(rut).get();
    if (doc.exists) {
      final data = doc.data()!;
      Timestamp? bloqueadoHasta = data['bloqueadoHasta'];
      if (bloqueadoHasta != null && bloqueadoHasta.toDate().isAfter(DateTime.now())) {
        return true; // Sigue castigado
      }
    }
    return false;
  }

  // Suma un intento fallido y bloquea por 15 mins si llega a 5
  Future<int> registrarIntentoFallido(String rut) async {
    final docRef = _firestore.collection('bloqueos_seguridad').doc(rut);
    final doc = await docRef.get();

    int intentos = 1;
    if (!doc.exists) {
      await docRef.set({'intentos': 1, 'bloqueadoHasta': null});
    } else {
      intentos = (doc.data()!['intentos'] ?? 0) + 1;
      
      if (intentos >= 5) {
        // ¡Bloqueo activado por 15 minutos!
        await docRef.update({
          'intentos': intentos,
          'bloqueadoHasta': Timestamp.fromDate(DateTime.now().add(const Duration(minutes: 15))),
        });
      } else {
        await docRef.update({'intentos': intentos});
      }
    }
    return intentos;
  }

  // Si hace login con éxito, borramos su historial de fallos
  Future<void> resetearIntentos(String rut) async {
    await _firestore.collection('bloqueos_seguridad').doc(rut).delete().catchError((_) {});
  }
}