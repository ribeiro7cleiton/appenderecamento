class Registro {
  final String codori;
  final String codbar;
  final String codend;
  final String datent;
  final String horent;
  final int id;

  Registro(
      {this.codori,
      this.codbar,
      this.id,
      this.codend,
      this.datent,
      this.horent});

  Registro.fromMap(Map<String, dynamic> res)
      : codori = res["codori"],
        codbar = res["codbar"],
        id = res["id"],
        codend = res["codend"],
        datent = res["datent"],
        horent = res["horent"];

  Map<String, Object> toMap() {
    return {
      'codori': codori,
      'codbar': codbar,
      'id': id,
      'codend': codend,
      'datent': datent,
      'horent': horent
    };
  }
}
