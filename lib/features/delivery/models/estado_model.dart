class EstadoModel {
  final int id;
  final String estado;

  EstadoModel({
    required this.id,
    required this.estado,
  });

  factory EstadoModel.fromJson(Map<String, dynamic> json) {
    return EstadoModel(
      id: json['id'],
      estado: json['estado'],
    );
  }
}
