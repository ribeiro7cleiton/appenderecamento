// ignore_for_file: non_constant_identifier_names, prefer_const_constructors, unnecessary_new, avoid_print, prefer_typing_uninitialized_variables, avoid_unnecessary_containers,Use key in widget constructors,, use_key_in_widget_constructors
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:enderecamento/controllers/registro_pendente.dart';
import 'package:enderecamento/services/data_base.dart';
import 'package:enderecamento/widgets/pendence-card.dart';
import 'package:enderecamento/controllers/retorno_json_padrao.dart';
import 'package:enderecamento/widgets/loading-button.dart';
import 'package:asuka/asuka.dart' as asuka;
import 'package:flutter/services.dart' show SystemChannels;
import 'package:http/http.dart' as http;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

class Endereco extends StatefulWidget {
  @override
  _EnderecoState createState() => _EnderecoState();
}

class _EnderecoState extends State<Endereco> {
  String aCodBar = '';
  String aAbrEnd = '';
  String aCodOri = 'CHA';
  String aCodEnd = '';
  String aDatEnt = '';
  String aHorEnt = '';
  String aNomAss = 'assets/images/chapa.png';
  List<String> LisEnd = [];
  List<String> LisCha = [];
  List<String> LisBob = [];
  List<String> LisEmb = [];
  DateTime data = DateTime.now();
  var str;
  var nQtdPen = 0;
  final codbar = TextEditingController();
  var busy = false;
  int nErrFor = 0;
  String aMsgFor = "";
  final FocusScopeNode _node = FocusScopeNode();

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  DatabaseHandler handler;

  @override
  void initState() {
    super.initState();
    handler = DatabaseHandler();
    handler.initializeDB().whenComplete(() async {
      RetQtdReg(handler).then((value) => setState(() {
            nQtdPen = value;
          }));
    });
  }

  @override
  Widget build(BuildContext context) {
    Map data = ModalRoute.of(context).settings.arguments;
    String tokenSopasta = data["tokenSopasta"];

    AtuLis(tokenSopasta, LisCha, 'CHA').then((value) => {
          if (value != null && value != [] && value != null)
            {
              LisCha = value,
            },
        });
    AtuLis(tokenSopasta, LisBob, 'BOB').then((value) => {
          if (value != null && value != []) {LisBob = value},
        });
    AtuLis(tokenSopasta, LisEmb, 'EMB').then((value) => {
          if (value != null && value != []) {LisEmb = value},
        });

    setState(() {});
    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            child: LayoutBuilder(builder: (_, constraints) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(constraints.maxWidth * 0.1),
                    child: Center(
                      child: Column(
                        children: [
                          Container(
                            padding:
                                EdgeInsets.all(constraints.maxWidth * 0.06),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                            ),
                            child: Column(
                              children: [
                                Container(
                                  height: 30,
                                  width: 150,
                                  child:
                                      Image.asset("assets/images/sopasta.png"),
                                  decoration: BoxDecoration(),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                RichText(
                                  text: TextSpan(
                                    text: 'ENDEREÇAMENTO',
                                    style: TextStyle(
                                      color: Colors.lightGreen,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'calibri',
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Image.asset(aNomAss),
                                ),
                                DropdownButton<String>(
                                  value: aCodOri,
                                  icon:
                                      const Icon(Icons.arrow_drop_down_circle),
                                  iconSize: 40,
                                  items: <String>['CHA', 'BOB', 'EMB']
                                      .map((String value) {
                                    return new DropdownMenuItem<String>(
                                      value: value,
                                      child: new Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (String newValue) {
                                    setState(() {
                                      aCodOri = newValue;
                                      switch (aCodOri) {
                                        case 'CHA':
                                          aNomAss = 'assets/images/chapa.png';
                                          LisEnd = LisCha;
                                          aCodEnd = LisEnd[0];
                                          break;
                                        case 'BOB':
                                          aNomAss = 'assets/images/papel.png';
                                          LisEnd = LisBob;
                                          aCodEnd = LisEnd[0];
                                          break;
                                        case 'EMB':
                                          aNomAss = 'assets/images/caixa.png';
                                          LisEnd = LisEmb;
                                          aCodEnd = LisEnd[0];
                                          break;
                                        default:
                                          aNomAss = 'assets/images/BOB.png';
                                      }
                                    });
                                  },
                                  style: TextStyle(
                                      fontSize: 25, color: Colors.green),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                DropdownButton<String>(
                                  value: aCodEnd,
                                  icon:
                                      const Icon(Icons.arrow_drop_down_circle),
                                  iconSize: 40,
                                  items: LisEnd.map((String valend) {
                                    return new DropdownMenuItem<String>(
                                      value: valend,
                                      child: new Text(valend),
                                    );
                                  }).toList(),
                                  onChanged: (String newValEnd) {
                                    setState(() {
                                      aCodEnd = newValEnd;
                                    });
                                  },
                                  style: TextStyle(
                                      fontSize: 25, color: Colors.green),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                FocusScope(
                                  node: _node,
                                  child: TextFormField(
                                    autofocus: true,
                                    maxLength: 30,
                                    onEditingComplete: () {
                                      SystemChannels.textInput
                                          .invokeMethod('TextInput.hide');
                                      aMsgFor =
                                          validaTexto(codbar.text, aCodEnd);
                                      if (aMsgFor != "") {
                                        asuka.AsukaSnackbar.alert(aMsgFor)
                                            .show();
                                      } else {
                                        setState(() {
                                          busy = true;
                                        });
                                        aCodBar = codbar.text;
                                        DateTime data = DateTime.now();
                                        aDatEnt = DateFormat("dd/MM/yyyy")
                                            .format(data);
                                        aHorEnt = ((int.parse((DateFormat("HH")
                                                        .format(data))) *
                                                    60) +
                                                (int.parse((DateFormat("mm")
                                                    .format(data)))))
                                            .toString();
                                        runApi(
                                                codbar.text,
                                                tokenSopasta,
                                                aCodOri,
                                                aCodEnd,
                                                aDatEnt,
                                                aHorEnt)
                                            .then((response) => {
                                                  setState(() {
                                                    busy = false;
                                                  }),
                                                  if (response.error == 1)
                                                    {
                                                      asuka.AsukaSnackbar.alert(
                                                              "Erro: " +
                                                                  response
                                                                      .message)
                                                          .show(),
                                                      addregistro(
                                                              Registro(
                                                                  codbar: codbar
                                                                      .text,
                                                                  codori:
                                                                      aCodOri,
                                                                  codend:
                                                                      aCodEnd,
                                                                  datent:
                                                                      aDatEnt,
                                                                  horent:
                                                                      aHorEnt),
                                                              handler)
                                                          .then((value) => {
                                                                RetQtdReg(
                                                                        handler)
                                                                    .then(
                                                                        (value) =>
                                                                            {
                                                                              setState(() {
                                                                                nQtdPen = value;
                                                                                codbar.clear();
                                                                              }),
                                                                            }),
                                                              }),
                                                    }
                                                  else
                                                    {
                                                      asuka.AsukaSnackbar
                                                              .success(response
                                                                  .message)
                                                          .show(),
                                                      codbar.clear(),
                                                    },
                                                  _node.requestFocus(),
                                                });
                                      }
                                    },
                                    style: new TextStyle(
                                        color: Colors.green,
                                        fontSize: 20,
                                        fontFamily: 'calibri'),
                                    decoration: InputDecoration(
                                      labelText: "Código de Barras",
                                      labelStyle:
                                          TextStyle(color: Colors.green),
                                      suffixIcon: IconButton(
                                          icon: Icon(Icons.add_a_photo),
                                          iconSize: 35,
                                          onPressed: () {
                                            readBarCode().then((value) => {
                                                  if (value != '-1')
                                                    {
                                                      codbar.text = value,
                                                      SystemChannels.textInput
                                                          .invokeMethod(
                                                              'TextInput.hide'),
                                                      aMsgFor = validaTexto(
                                                          codbar.text, aCodEnd),
                                                      if (aMsgFor != "")
                                                        {
                                                          asuka.AsukaSnackbar
                                                                  .alert(
                                                                      aMsgFor)
                                                              .show(),
                                                        }
                                                      else
                                                        {
                                                          setState(() {
                                                            busy = true;
                                                          }),
                                                          aCodBar = codbar.text,
                                                          aDatEnt = DateFormat(
                                                                  "dd/MM/yyyy")
                                                              .format(DateTime
                                                                  .now()),
                                                          aHorEnt = ((int.parse((DateFormat(
                                                                              "HH")
                                                                          .format(DateTime
                                                                              .now()))) *
                                                                      60) +
                                                                  (int.parse((DateFormat(
                                                                          "mm")
                                                                      .format(DateTime
                                                                          .now())))))
                                                              .toString(),
                                                          runApi(
                                                                  aCodBar,
                                                                  tokenSopasta,
                                                                  aCodOri,
                                                                  aCodEnd,
                                                                  aDatEnt,
                                                                  aHorEnt)
                                                              .then(
                                                                  (response) =>
                                                                      {
                                                                        setState(
                                                                            () {
                                                                          busy =
                                                                              false;
                                                                        }),
                                                                        if (response.error ==
                                                                            1)
                                                                          {
                                                                            asuka.AsukaSnackbar.alert("Erro: " + response.message).show(),
                                                                            addregistro(Registro(codbar: codbar.text, codori: aCodOri, codend: aCodEnd, datent: aDatEnt, horent: aHorEnt), handler).then((value) =>
                                                                                {
                                                                                  RetQtdReg(handler).then((value) => {
                                                                                        setState(() {
                                                                                          nQtdPen = value;
                                                                                          codbar.clear();
                                                                                        }),
                                                                                      }),
                                                                                }),
                                                                          }
                                                                        else
                                                                          {
                                                                            asuka.AsukaSnackbar.success(response.message).show(),
                                                                            codbar.clear(),
                                                                          }
                                                                      }),
                                                        }
                                                    },
                                                  SystemChannels.textInput
                                                      .invokeMethod(
                                                          'TextInput.hide'),
                                                  _node.requestFocus(),
                                                });
                                          }),
                                    ),
                                    controller: codbar,
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                LoadingButton(
                                  constraints: constraints,
                                  busy: busy,
                                  text: "Gravar",
                                  func: () {
                                    SystemChannels.textInput
                                        .invokeMethod('TextInput.hide');
                                    aMsgFor = validaTexto(codbar.text, aCodEnd);
                                    if (aMsgFor != "") {
                                      asuka.AsukaSnackbar.alert(aMsgFor).show();
                                    } else {
                                      setState(() {
                                        busy = true;
                                      });
                                      aCodBar = codbar.text;
                                      DateTime data = DateTime.now();
                                      aDatEnt =
                                          DateFormat("dd/MM/yyyy").format(data);
                                      aHorEnt = ((int.parse((DateFormat("HH")
                                                      .format(data))) *
                                                  60) +
                                              (int.parse((DateFormat("mm")
                                                  .format(data)))))
                                          .toString();
                                      runApi(codbar.text, tokenSopasta, aCodOri,
                                              aCodEnd, aDatEnt, aHorEnt)
                                          .then((response) => {
                                                setState(() {
                                                  busy = false;
                                                }),
                                                if (response.error == 1)
                                                  {
                                                    asuka.AsukaSnackbar.alert(
                                                            "Erro: " +
                                                                response
                                                                    .message)
                                                        .show(),
                                                    addregistro(
                                                            Registro(
                                                                codbar:
                                                                    codbar.text,
                                                                codori: aCodOri,
                                                                codend: aCodEnd,
                                                                datent: aDatEnt,
                                                                horent:
                                                                    aHorEnt),
                                                            handler)
                                                        .then((value) => {
                                                              RetQtdReg(handler)
                                                                  .then(
                                                                      (value) =>
                                                                          {
                                                                            setState(() {
                                                                              nQtdPen = value;
                                                                              codbar.clear();
                                                                            }),
                                                                          }),
                                                            }),
                                                  }
                                                else
                                                  {
                                                    asuka.AsukaSnackbar.success(
                                                            response.message)
                                                        .show(),
                                                    codbar.clear(),
                                                  }
                                              });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          CardPendence(
                              busy: busy,
                              func: () {
                                consultaregistros(handler).then((returnBD) => {
                                      for (final e in returnBD)
                                        {
                                          setState(() {
                                            busy = true;
                                          }),
                                          runApi(
                                                  e.codbar,
                                                  tokenSopasta,
                                                  e.codori,
                                                  e.codend,
                                                  e.datent,
                                                  e.horent)
                                              .then((response) => {
                                                    setState(() {
                                                      busy = false;
                                                    }),
                                                    if (response.error == 1)
                                                      {}
                                                    else
                                                      {
                                                        removeregistro(
                                                                handler, e.id)
                                                            .then((value) => {
                                                                  RetQtdReg(
                                                                          handler)
                                                                      .then(
                                                                          (value) =>
                                                                              {
                                                                                setState(() {
                                                                                  nQtdPen = value;
                                                                                }),
                                                                              }),
                                                                })
                                                      }
                                                  }),
                                        },
                                    });
                              },
                              constraints: constraints,
                              text: 'Atualizar !',
                              qtdpen: nQtdPen),
                        ],
                      ),
                    ),
                  )
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

Future<List> AtuLis(String tokenSopasta, List LisAtu, String aCodOri) async {
  //Cada vez que a origem é trocada, o app tenta atualizar, caso de erro, irá manter a ultima lista
  String aAbrEnd;
  var str;
  busEnd(tokenSopasta, aCodOri).then((response) => {
        if (response.error == 0)
          {
            aAbrEnd = response.message,
            aAbrEnd = aAbrEnd.replaceAll('[', ''),
            aAbrEnd = aAbrEnd.replaceAll(']', ''),
            aAbrEnd = aAbrEnd.replaceAll('"', ''),
            aAbrEnd = aAbrEnd.replaceAll('USU_CODEND', ''),
            aAbrEnd = aAbrEnd.replaceAll(' ', ''),
            aAbrEnd = aAbrEnd.replaceAll(':', ''),
            aAbrEnd = aAbrEnd.replaceAll('{', ''),
            aAbrEnd = aAbrEnd.replaceAll('}', ''),
            str = aAbrEnd.split(','),
            LisAtu.clear(),
            for (final e in str)
              {
                LisAtu.add(e),
              },
          }
      });

  return LisAtu;
}

Future<RetornoJson> busEnd(String tokenSopasta, String codori) async {
  var data = {"codori": codori};
  var url = "http://192.168.3.10:3335/getendereco";
  try {
    var response = await http
        .post(url,
            headers: {
              'Content-Type': 'application/json',
              'x-access-token': tokenSopasta
            },
            body: JsonEncoder().convert(data))
        .timeout(const Duration(seconds: 3));
    var json = jsonDecode(response.body);

    if ((response.statusCode == 500) || (response.statusCode == 401)) {
      return RetornoJson(
          message: 'Usuário não autenticado, verifique !', error: 1);
    } else {
      return RetornoJson(
          message: json['message'].toString(), error: json['error']);
    }
    // ignore: unused_catch_clause
  } on TimeoutException catch (e) {
    return RetornoJson(
        message: 'Servidor Indisponivel, tente novamente mais tarde !' +
            e.toString(),
        error: 1);
    // ignore: unused_catch_clause
  } on SocketException catch (e) {
    return RetornoJson(
        message: 'Servidor Indisponivel, tente novamente mais tarde !' +
            e.toString(),
        error: 1);
  }
}

Future<RetornoJson> runApi(String codbar, String tokenSopasta, String codori,
    String codend, String datent, String horent) async {
  var data = {
    "codemp": 1,
    "codfil": 1,
    "codbar": codbar,
    "codori": codori,
    "codend": codend,
    "datent": datent,
    "horent": horent
  };
  var url = "http://192.168.3.10:3335/enderecamento";
  //url = "http://svapps:3334/enviarregistro";
  try {
    var response = await http
        .post(url,
            headers: {
              'Content-Type': 'application/json',
              'x-access-token': tokenSopasta
            },
            body: JsonEncoder().convert(data))
        .timeout(const Duration(seconds: 3));
    var json = jsonDecode(response.body);

    if ((response.statusCode == 500) || (response.statusCode == 401)) {
      return RetornoJson(
          message: 'Usuário não autenticado, verifique !', error: 1);
    } else {
      return RetornoJson(message: json['message'], error: json['error']);
    }
    // ignore: unused_catch_clause
  } on TimeoutException catch (e) {
    return RetornoJson(
        message: 'Servidor Indisponivel, tente novamente mais tarde !' +
            e.toString(),
        error: 1);
    // ignore: unused_catch_clause
  } on SocketException catch (e) {
    return RetornoJson(
        message: 'Servidor Indisponivel, tente novamente mais tarde !' +
            e.toString(),
        error: 1);
  }
}

Future<String> readBarCode() async {
  String code = await FlutterBarcodeScanner.scanBarcode(
      "#00FF00", "", false, ScanMode.BARCODE);
  return code;
}

String validaTexto(String aCodBar, String aCodEnd) {
  String aMsgFor = "";
  if (aCodBar.length < 10) {
    aMsgFor = "Código de Barras deve ter no mínimo 10 caracteres !";
  }
  if (aCodBar.length > 30) {
    aMsgFor = "Código de Barras deve ter no máximo 30 caracteres !";
  }
  if (aCodBar == "") {
    aMsgFor = "Código de Barras não informado !";
  }
  if ((aCodEnd == '') || (aCodEnd == null) || (aCodEnd == ' ')) {
    aMsgFor = "Erro: Código do Endereço deve estar preenchido !";
  }
  return aMsgFor;
}

Future<int> RetQtdReg(DatabaseHandler handler) async {
  var QtdReg = 0;
  List<Registro> lista = await handler.retrieveUsers();

  // ignore: unused_local_variable
  for (final e in lista) {
    QtdReg++;
  }

  return QtdReg;
}

Future<int> addregistro(Registro registro, DatabaseHandler handler) async {
  return await handler.insertRegistro(registro);
}

Future<List> consultaregistros(DatabaseHandler handler) async {
  List<Registro> lista = await handler.retrieveUsers();
  return lista;
}

Future<int> removeregistro(DatabaseHandler handler, int id) async {
  var ret;
  ret = await handler.deleteRegistro(id);
  return ret;
}
