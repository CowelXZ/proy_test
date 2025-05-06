import 'package:flutter/material.dart';
import 'package:proy_test/Vistas/Taquilla/MenuTaquilla.dart';

import 'package:pdf/widgets.dart' as pw;

import 'package:printing/printing.dart';
//import 'package:proyecto_cine_equipo3/Vista/Taquilla/MenuTaquilla.dart';

class TicketCompra extends StatelessWidget {
  final String titulo;
  final String fecha;
  final String horario;
  final String sala;
  final String boletos;
  final String asientos;
  final double total;

  const TicketCompra({
    super.key,
    required this.titulo,
    required this.fecha,
    required this.horario,
    required this.sala,
    required this.boletos,
    required this.asientos,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF081C42),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      content: Container(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              '🎟️ TICKET DE COMPRA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _datoTicket('🎬 Película:', titulo),
            _datoTicket('📅 Fecha:', fecha),
            _datoTicket('🕒 Hora:', horario),
            _datoTicket('🏢 Sala:', sala),
            _datoTicket('🎟️ Boletos:', boletos),
            _datoTicket('💺 Asientos:', asientos),
            const SizedBox(height: 20),
            Text(
              '💵 Total: \$${total.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.greenAccent,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final pdf = await _generarTicketPDF(
                  titulo: titulo,
                  fecha: fecha,
                  horario: horario,
                  sala: sala,
                  boletos: boletos,
                  asientos: asientos,
                  total: total,
                );
                await Printing.layoutPdf(onLayout: (format) => pdf.save());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff14AE5C),
              ),
              child: const Text('Descargar Ticket PDF'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const MenuTaquilla()),
                  (route) => false,
                );
              },
              child: const Text(
                'Volver al Menú Principal',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _datoTicket(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        '$label $valor',
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Future<pw.Document> _generarTicketPDF({
    required String titulo,
    required String fecha,
    required String horario,
    required String sala,
    required String boletos,
    required String asientos,
    required double total,
  }) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('🎟️ TICKET DE COMPRA',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('🎬 Película: $titulo'),
              pw.Text('📅 Fecha: $fecha'),
              pw.Text('🕒 Hora: $horario'),
              pw.Text('🏢 Sala: $sala'),
              pw.Text('🎟️ Boletos: $boletos'),
              pw.Text('💺 Asientos: $asientos'),
              pw.SizedBox(height: 20),
              pw.Text('💵 Total Pagado: \$${total.toStringAsFixed(2)}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ],
          );
        },
      ),
    );
    return pdf;
  }
}
