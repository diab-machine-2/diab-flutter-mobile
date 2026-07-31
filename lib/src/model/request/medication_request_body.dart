class MedicationRequestBody {
  final String ocrType;
  final String? prescriptionName;
  final String? medicationName;
  final String? quantity;
  final String? diagnose;
  final String? servicesRequest;
  final String? gptParsedResult;
  final String? imageUrl;
  final int isSuccess;
  final String? note;

  const MedicationRequestBody({
    required this.ocrType,
    this.prescriptionName,
    this.medicationName,
    this.quantity,
    this.diagnose,
    this.servicesRequest,
    this.gptParsedResult,
    this.imageUrl,
    this.isSuccess = 1,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'ocrType': ocrType,
        if (prescriptionName != null) 'prescriptionName': prescriptionName,
        if (medicationName != null) 'medicationName': medicationName,
        if (quantity != null) 'quantity': quantity,
        if (diagnose != null) 'diagnose': diagnose,
        if (servicesRequest != null) 'servicesRequest': servicesRequest,
        if (gptParsedResult != null) 'gptParsedResult': gptParsedResult,
        if (imageUrl != null) 'imageUrl': imageUrl,
        'isSuccess': isSuccess,
        if (note != null && note!.isNotEmpty) 'note': note,
      };
}
