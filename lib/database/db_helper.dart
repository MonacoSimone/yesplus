import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yesplus/models/destinatari.dart';
import '../models/sconto.dart';
import '../models/zprezzitv.dart';
import '../models/tipoArticolo.dart';
import '../models/tipoconto.dart';
import '../models/agenti.dart';
import '../models/anagrafica.dart';
import '../models/catalogo.dart';
import '../models/iva.dart';
import '../models/messaggio.dart';
import '../models/pagamenti.dart';
import '../models/partita.dart';
import '../models/righeOrdine.dart';
import '../models/righebolla.dart';
import '../models/rigafattura.dart';
import '../models/testatabolle.dart';
import '../models/testatafattura.dart';
import '../models/testataordine.dart';
import '../models/tipobolla.dart';
import '../models/tipofattura.dart';
import '../models/tipoordine.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:share_plus/share_plus.dart';

class DatabaseHelper {
  late Database _database;

  Future<Database> _currentDatabase() async {
    _database =
        await openDatabase(p.join(await getDatabasesPath(), 'order_entry.db'),
            onCreate: (database, version) async {
      debugPrint('createDatabase');
      const sqlMGAnaArt = """CREATE TABLE MG_AnaArt(
        "MGAA_ID" INTEGER NOT NULL,
        "MGAA_Descr" TEXT,
        "MGAA_Matricola" TEXT,
        "MGAA_MBIV_ID" INTEGER,
        "MGAA_MBDC_Classe" TEXT,
        "MGAA_MBUM_Codice" TEXT,
        "MGAA_Stato" INTEGER,
        "MGAA_PVendita" REAL,
        "Sconto1" REAL,
        "Sconto2" REAL,
        "Sconto3" REAL);""";
      const sqlPrezziTV = """ CREATE TABLE "Z_PrezziTV"(
                          "ZPTV_ID" INTEGER NOT NULL,
                          "ZPTV_MGAA_Id" INTEGER,
                          "ZPTV_MBPC_Id" INTEGER NULL,
                          "ZPTV_Prezzo" FLOAT,
                          "ZPTV_Sconto1" FLOAT,
                          "ZPTV_Sconto2" FLOAT,
                          "ZPTV_Sconto3" FLOAT);""";
      const sqlMBAnagr = """CREATE TABLE "MB_Anagr" (	
                            "MBPC_ID"	INTEGER NOT NULL,
                            "MBPC_Conto" TEXT,
                            "MBPC_SottoConto" TEXT,
                            "MBAN_RagSoc"	TEXT,	
                            "MBAN_Indirizzo"	TEXT,
                            "MBAN_Comune" TEXT,
                            "MBAN_Telefono"	TEXT,
                            "MBAN_EMail"	TEXT,
                            "MBAN_EMail2"	TEXT,
                            "MBAN_GPSE"	NUMERIC,
                            "MBAN_GPSN"	NUMERIC,
                            "MBAN_PartitaIVA"	TEXT,
                            "MBAN_CodFiscale"	TEXT,
                            "MBAN_LastUpdate"	INTEGER,
                            "MBAN_DataFineVal"	TEXT,
                            "MBAN_Sconto1" FLOAT,
                            "MBAN_Sconto2" FLOAT,
                            "MBAN_Sconto3" FLOAT,
                            "MBAN_ID"	INTEGER
                          )""";
      const sqlMBCliForDest = """CREATE TABLE "MB_CliForDest" (
                                "MBDT_ID" INTEGER NOT NULL,
                                "MBDT_Destinatario" TEXT,
                                "MBDT_MBAN_ID" INTEGER
                            )""";
      const sqlParam = """CREATE TABLE "SP_Param" (	
              "SPPA_ID"	INTEGER NOT NULL UNIQUE,
              "SPPA_IndirizzoServerAPI" TEXT,
              "SPPA_IndirizzoServerWSK" TEXT,
              "SPPA_IMEI" TEXT,
              "SPPA_Password"	TEXT,
              "SPPA_TipoConto"	INTEGER,
              "SPPA_FTTI_ID"	INTEGER,
              "SPPA_OCTI_ID"	INTEGER,
              "SPPA_BLTI_ID1"	INTEGER,
              "SPPA_BLTI_ID2"	INTEGER,
              "SPPA_MBAG_ID"	INTEGER,
              "SPPA_MODPrz"	INTEGER,
              "SPPA_MODSco"	INTEGER,
              "SPPA_ReOpenDocs"	INTEGER,
              "SPPA_PrintPreview"	INTEGER,
              "SPPA_CtrlGiac"	INTEGER,
              "SPPA_CarGra"	INTEGER,
              "SSPA_RagSoc" TEXT,
              "SPPA_Piva" TEXT,
              "SPPA_CF" TEXT,
              "SPPA_Tel" TEXT,
              "SPPA_SedeLegale" TEXT,
              "SPPA_DomFiscale" TEXT,
              "SPPA_MBDV_ID"	INTEGER,
              "SPPA_MBSC_ID"	INTEGER,
              "LastUpdate"	INTEGER,
              PRIMARY KEY("SPPA_ID" AUTOINCREMENT)
            ); """;
      const sqlArtic = """CREATE TABLE "MG_Artic" (
            "MGAA_ID"	INTEGER NOT NULL UNIQUE,
            "MGAA_Matricola"	TEXT,
            "MGAA_Descr"	TEXT,
            "MGAA_Classe"	TEXT,
            "MGAA_UnMis" TEXT,            
            "MGAA_Stato" INTEGER,
            "MGAA_Iva" INTEGER,
            "LastUpdate"	INTEGER); """;
      const sqlMBTipiArticoloVa = """CREATE TABLE "MB_TipiArticoloVA"(
            "MBTA_ID" INTEGER NOT NULL UNIQUE,
            "MBTA_Codice" INTEGER,
            "MBTA_Descr" TEXT);""";
      const sqlFTTipo = """CREATE TABLE "FT_Tipo" (	
            "FTTI_ID"	INTEGER NOT NULL UNIQUE,
            "FTTI_Descr"	TEXT,
            "FTTI_TipNum"	INTEGER,
            "FTTI_Tipo"	INTEGER,
            "FTTI_FattureInStatistica" INTEGER,
            "FTTI_NaturaFattura" INTEGER); """;
      const sqlBLTipo = """CREATE TABLE "BL_Tipo" (	
            "BLTI_ID"	INTEGER NOT NULL UNIQUE,
            "BLTI_Tipo"	INTEGER,
            "BLTI_Descr"	TEXT,
            "BLTI_TipNum"	INTEGER,
            "BLTI_NaturaDDT" INTEGER); """;
      const sqlOCTipo = """CREATE TABLE "OC_Tipo" (	
            "OCTI_ID"	INTEGER NOT NULL UNIQUE,
            "OCTI_Tipo"	INTEGER,
            "OCTI_Descr"	TEXT,
            "OCTI_TipNum"	INTEGER); """;
      const sqlMBAgente = """CREATE TABLE "MB_Agenti" (	
            "MBAG_ID"	INTEGER NOT NULL UNIQUE,
            "MBAG_MBAN_ID"	INTEGER,
            "MBAN_RagSoc"	TEXT); """;
      const sqlFTAnagr = """CREATE TABLE IF NOT EXISTS "FT_Anagr" (
            "FTAN_ID"	INTEGER NOT NULL UNIQUE,
            "FTAN_AnnoFatt"	INTEGER,
            "FTAN_FTTI_ID" INTEGER,
            "FTAN_NumFatt"	TEXT, 
            "FTAN_DataIns" TEXT, 
            "FTAN_MBPC_ID" INTEGER,
            "FTAN_Stamp" INTEGER,
            "FTAN_Contab" INTEGER,
            "FTAN_Scaric" INTEGER,
            "FTAN_TotFattura" REAL,
            "FTAN_Spese" REAL,
            "FTAN_DataCreate" Text,
            "FTAN_Destinat" TEXT,
            "FTAN_Destinaz" TEXT,
            "FTAN_APP_ID" TEXT);""";
      const sqlFTArtic = """CREATE TABLE "FT_Artic" (
            "FTAR_ID"	INTEGER NOT NULL UNIQUE,
            "FTAR_FTAN_ID"	INTEGER NOT NULL,
            "FTAR_NumRiga"	INTEGER,
            "FTAR_MGAA_ID" INTEGER,
            "FTAR_MBTA_Codice" INTEGER, 
            "FTAR_Descr" TEXT,
            "FTAR_Quantita" REAL, 
            "FTAR_MBUM_Codice" TEXT,
            "FTAR_Prezzo" REAL,
            "FTAR_TotSconti" REAL,
            "FTAR_ScontiFinali" REAL,
            "FTAR_Note" TEXT,
            "FTAR_DQTA" INTEGER,
            "FTAR_RivalsaIva" INTEGER,
            "FTAR_APP_ID" TEXT);""";
      const sqlOCAnagr = """CREATE TABLE "OC_Anag" (
            "OCAN_ID"	INTEGER,
            "OCAN_AnnoOrd"	INTEGER,
            "OCAN_OCTI_ID" INTEGER,
            "OCAN_NumOrd"	INTEGER, 
            "OCAN_DataIns" TEXT, 
            "OCAN_MBPC_ID" INTEGER,
            "OCAN_DataConf" TEXT,
            "OCAN_DataEvas" TEXT,            
            "OCAN_Stamp" INTEGER,
            "OCAN_Evaso" INTEGER,
            "OCAN_ParzEvaso" INTEGER,
            "OCAN_EvasoForz" INTEGER,
            "OCAN_NoteIniz" TEXT,
            "OCAN_NoteFin" TEXT,
            "OCAN_Destinat" TEXT,
            "OCAN_Destinaz" TEXT,
            "OCAN_TotOrdine" REAL,
            "OCAN_Dest_MBAN_ID" INTEGER,
            "OCAN_Desz_MBAN_ID" INTEGER,
            "OCAN_Confermato" INTEGER,
            "OCAN_DataCreate" TEXT,
            "OCAN_APP_ID" TEXT);""";
      const sqlOCArtic = """CREATE TABLE "OC_Artic" (
            "OCAR_ID"	INTEGER NOT NULL UNIQUE,
            "OCAR_OCAN_ID"	INTEGER NOT NULL,
            "OCAR_NumRiga"	INTEGER,
            "OCAR_MBTA_Codice" INTEGER,
            "OCAR_MGAA_ID" INTEGER,
            "OCAR_Quantita" REAL,
            "OCAR_MBUM_Codice" TEXT,
            "OCAR_Prezzo" REAL,
            "OCAR_DescrArt" TEXT,
            "OCAR_TotSconti" REAL,
            "OCAR_ScontiFinali" REAL,
            "OCAR_PrezzoListino" REAL,
            "OCAR_DQTA" REAL,
            "OCAR_EForz" INTEGER,
            "OCAR_APP_ID" TEXT);""";
      const sqlOcarAppId = """CREATE TABLE "OC_APP_ID" (
                      "APPR_ID" INTEGER,
                      "APPT_ID" INTEGER);""";

      const sqlPfId = """CREATE TABLE "PF_APP_ID" (
                      "APPT_ID" INTEGER,
                      "APPD_ID" INTEGER);""";

      const sqlBLAnagr = """CREATE TABLE "BL_Anag" (
            "BLAN_ID"	INTEGER NOT NULL,
            "BLAN_BLTI_ID"	INTEGER,
            "BLAN_AnnoBol" INTEGER,
            "BLAN_NumBol"	TEXT, 
            "BLAN_DataIns" TEXT, 
            "BLAN_MBPC_ID" INTEGER,    
            "BLAN_Stamp" INTEGER,
            "BLAN_Scaric" INTEGER,
            "BLAN_Valor" INTEGER,
            "BLAN_Destinat" TEXT,
            "BLAN_TotBolla" TEXT,          
            "BLAN_Dest_MBAN_ID" INTEGER,            
            "BLAN_DataCreate" TEXT);""";
      const sqlBLArtic = """CREATE TABLE "BL_Artic" (
            "BLAR_ID"	INTEGER NOT NULL,
            "BLAR_BLAN_ID"	INTEGER NOT NULL,
            "BLAR_NumRiga"	INTEGER,
            "BLAR_MBTA_Codice" INTEGER,
            "BLAR_MGAA_ID" INTEGER,
            "BLAR_Quantita" INTEGER,
            "BLAR_MBUM_Codice" TEXT,
            "BLAR_Prezzo" REAL,
            "BLAR_DescrArt" TEXT,
            "BLAR_TotSconti" REAL,
            "BLAR_ScontiFinali" REAL,
            "BLAR_DQTA" REAL);""";
      const sqlCAPartite = """CREATE TABLE "CA_Partite" (	
          "CAPA_RIF_FATT" TEXT,
          "CAPA_Id" INTEGER,
          "CAPA_CASP_Stato" INTEGER,
          "CAPA_MBPC_ID" INT,
          "CAPA_MBDI_ID" INT,
          "CAPA_MBTD_ID" INT,
          "CAPA_NumPart" INTEGER,
          "CAPA_AnnoPart" INTEGER,
          "CAPA_Scadenza" TEXT,
          "CAPA_DataVal" TEXT,
          "CAPA_DataDoc" TEXT,
          "CAPA_ImportoAvere" REAL,
          "CAPA_ImportoDare" REAL,
          "CAPA_Residuo" REAL,
          "CAPA_Pagamento" REAL,
          "CAPA_Cambio" INT,
          "CAPA_PagCreate" INTEGER,
          "CAPA_Selected" INTEGER,
          "CAPA_PagCnt" INTEGER,
          "CAPA_PagAss" INTEGER,
          "CAPA_PagTit" INTEGER);""";
      const sqlMessaggi = """CREATE TABLE "MessagesToSend" (	
          "METS_ID" INTEGER,
          "METS_Message" TEXT,
          "METS_DataSave" TEXT,
          PRIMARY KEY("METS_ID" AUTOINCREMENT));""";
      const sqlIva = """CREATE TABLE "MB_IVA" (
        "MBIV_ID" INTEGER NOT NULL UNIQUE,
        "MBIV_IVA" INTEGER,
        "MBIV_Descr" TEXT,
        "MBIV_Perc" INTEGER);""";
      const sqlTipoPag = """CREATE TABLE "MB_TipoPag" (
                      "MBTP_ID" INTEGER NOT NULL UNIQUE,
                      "MBTP_Pagamento" INTEGER,
                      "MBTP_Descr" TEXT,
                      "MBTP_Effetto" INTEGER);""";
      const sqlSolPag = """CREATE TABLE "MB_SolPag" (
                "MBSP_ID" INTEGER NOT NULL UNIQUE,
                "MBSP_Soluzione" INTEGER,
                "MBSP_Descr" TEXT,
                "MBSP_Code" INTEGER);""";
      const sqlBLPagam = """CREATE TABLE "BL_Pagam" (
              "BLPG_ID" INTEGER NOT NULL,
              "BLPG_BLAN_ID" INTEGER,
              "BLPG_MBTP_ID" INTEGER,
              "BLPG_MBSP_ID" INTEGER);""";
      const sqlOCPagam = """CREATE TABLE "OC_Pagam" (
                "OCPG_ID" INTEGER NOT NULL,
                "OCPG_OCAN_ID" INTEGER,
                "OCPG_MBTP_ID" INTEGER,
                "OCPG_MBSP_ID" INTEGER);""";
      const sqlFTPagam = """CREATE TABLE "FT_Pagam" (
                    "FTPG_ID" INTEGER NOT NULL,
                    "FTPG_FTAN_ID" INTEGER,
                    "FTPG_MBTP_ID" INTEGER,
                    "FTPG_MBSP_ID" INTEGER);""";
      const sqlMBTipoConto = """CREATE TABLE "MB_TipoConto"(
                    "MBTC_Id" INTEGER NOT NULL,
                    "MBTC_TipoConto" INTEGER,
                    "MBTC_Descr" TEXT,
                    "MBTC_Code" TEXT);""";

      await database.execute(sqlBLPagam);
      await database.execute(sqlOCPagam);
      await database.execute(sqlFTPagam);
      await database.execute(sqlSolPag);
      await database.execute(sqlTipoPag);
      await database.execute(sqlIva);
      await database.execute(sqlMGAnaArt);
      await database.execute(sqlMBAnagr);
      await database.execute(sqlMBCliForDest);
      await database.execute(sqlParam);
      await database.execute(sqlArtic);
      await database.execute(sqlFTTipo);
      await database.execute(sqlBLTipo);
      await database.execute(sqlOCTipo);
      await database.execute(sqlFTAnagr);
      await database.execute(sqlFTArtic);
      await database.execute(sqlOCAnagr);
      await database.execute(sqlOCArtic);
      await database.execute(sqlBLAnagr);
      await database.execute(sqlBLArtic);
      await database.execute(sqlCAPartite);
      await database.execute(sqlMessaggi);
      await database.execute(sqlMBAgente);
      await database.execute(sqlMBTipiArticoloVa);
      await database.execute(sqlMBTipoConto);
      await database.execute(sqlPrezziTV);
      await database.execute(sqlOcarAppId);
      await database.execute(sqlPfId);
      await database.rawQuery(
          "INSERT INTO SP_Param (SPPA_IndirizzoServerAPI) VALUES (null) ");
      await database
          .rawQuery("INSERT INTO OC_APP_ID (APPR_ID,APPT_ID) VALUES (0,0);");
      await database
          .rawQuery("INSERT INTO PF_APP_ID (APPT_ID,APPD_ID) VALUES (0,0);");
      //await database.rawQuery("UPDATE SP_Param SET SPPA_MBDV_ID=46");
      //await database.rawQuery("UPDATE SP_Param SET SPPA_MBSC_ID=38");
    }, version: 1);

    return _database;
  }

  Future<void> exportDatabase() async {
    // Ottieni la directory del database
    final dbPath = await getDatabasesPath();
    final dbFile = File(p.join(dbPath, 'order_entry.db'));

    // Ottieni la directory locale in cui esportare il database
    final Directory? directory = await path_provider.getDownloadsDirectory();
    //final exportPath = directory.path;

    // Crea una copia del database nella directory locale
    final File copiedDbFile =
        await dbFile.copy(p.join(directory!.path, 'order_entry.db'));

    // Invia un messaggio all'utente
    print('Database esportato in: ${copiedDbFile.path}');
  }

  Future<void> exportDatabase1() async {
    // Ottieni il percorso del database
    final dbPath = await getDatabasesPath();
    final dbFile = File(p.join(dbPath, 'order_entry.db'));

    // Ottieni la directory locale in cui esportare il database
    final Directory directory =
        await path_provider.getApplicationDocumentsDirectory();
    final exportPath = directory.path;

    // Crea una copia del database nella directory locale
    final File copiedDbFile =
        await dbFile.copy(p.join(exportPath, 'order_entry.db'));

    // Condividi il file esportato
    final result = await Share.shareXFiles([XFile(copiedDbFile.path)]);

    if (result.status == ShareResultStatus.success) {
      print('Thank you for sharing the picture!');
    }
  }

  Future<void> resetDatabase() async {
    Database db = await _currentDatabase();
    await db.rawQuery("DELETE FROM MB_Anagr");
    await db.rawQuery("DELETE FROM BL_Artic");
    await db.rawQuery("DELETE FROM BL_Anag");
    await db.rawQuery("DELETE FROM OC_Artic");
    await db.rawQuery("DELETE FROM OC_Anag");
    await db.rawQuery("DELETE FROM FT_Artic");
    await db.rawQuery("DELETE FROM FT_Anagr");
    await db.rawQuery("DELETE FROM SP_Param");
    await db.rawQuery("DELETE FROM MG_Artic");
    await db.rawQuery("DELETE FROM FT_Tipo");
    await db.rawQuery("DELETE FROM BL_Tipo");
    await db.rawQuery("DELETE FROM OC_Tipo");
    //db.close();
  }

  Future<void> clearMB_Anagr() async {
    Database db = await _currentDatabase();
    await db.rawQuery("DELETE FROM MB_Anagr");
  }

  Future<void> clearMB_CliForDest() async {
    Database db = await _currentDatabase();
    await db.rawQuery("DELETE FROM MB_CliForDest");
  }

  Future<void> clearCA_Partite() async {
    Database db = await _currentDatabase();
    await db.rawQuery("DELETE FROM CA_Partite");
  }

  Future<void> clearBL_Artic() async {
    Database db = await _currentDatabase();
    await db.rawQuery("DELETE FROM BL_Artic");
  }

  Future<void> clearBL_Anag() async {
    Database db = await _currentDatabase();
    await db.rawQuery("DELETE FROM BL_Anag");
  }

  Future<void> clearBL_Pagam() async {
    Database db = await _currentDatabase();
    await db.rawQuery("DELETE FROM BL_Pagam");
  }

  Future<void> clearOC_Artic() async {
    Database db = await _currentDatabase();
    await db.rawQuery("DELETE FROM OC_Artic");
  }

  Future<void> clearOC_Anag() async {
    Database db = await _currentDatabase();
    await db.rawQuery("DELETE FROM OC_Anag");
  }

  Future<void> clearOC_Pagam() async {
    Database db = await _currentDatabase();
    await db.rawQuery("DELETE FROM OC_Pagam");
  }

  Future<void> clearFT_Pagam() async {
    Database db = await _currentDatabase();
    await db.rawQuery("DELETE FROM FT_Pagam");
  }

  Future<void> clearFT_Artic() async {
    Database db = await _currentDatabase();
    await db.rawQuery("DELETE FROM FT_Artic");
  }

  Future<void> clearFT_Anagr() async {
    Database db = await _currentDatabase();
    await db.rawQuery("DELETE FROM FT_Anagr");
  }

  Future<void> clearSP_Param() async {
    Database db = await _currentDatabase();
    await db.rawQuery("DELETE FROM SP_Param");
  }

  Future<void> clearMG_Artic() async {
    Database db = await _currentDatabase();
    await db.rawQuery("DELETE FROM MG_Artic");
  }

  Future<void> clearZprezziTv() async {
    Database db = await _currentDatabase();
    await db.rawQuery("DELETE FROM Z_PrezziTV");
  }

  Future<void> clearFT_Tipo() async {
    Database db = await _currentDatabase();
    await db.rawQuery("DELETE FROM FT_Tipo");
  }

  Future<void> clearBL_Tipo() async {
    Database db = await _currentDatabase();
    await db.rawQuery("DELETE FROM BL_Tipo");
  }

  Future<void> clearOC_Tipo() async {
    Database db = await _currentDatabase();
    await db.rawQuery("DELETE FROM OC_Tipo");
  }

  Future<void> clearAgenti() async {
    Database db = await _currentDatabase();
    await db.rawQuery("DELETE FROM MB_Agenti");
  }

  Future<void> mod() async {
    Database db = await _currentDatabase();
    await db.rawQuery("""CREATE TABLE "OC_Artic" (
            "OCAR_ID"	INTEGER NOT NULL UNIQUE,
            "OCAR_OCAN_ID"	INTEGER NOT NULL,
            "OCAR_NumRiga"	INTEGER,
            "OCAR_MBTA_Codice" INTEGER,
            "OCAR_MGAA_ID" INTEGER,
            "OCAR_Quantita" REAL,
            "OCAR_MBUM_Codice" TEXT,
            "OCAR_Prezzo" REAL,
            "OCAR_DescrArt" TEXT,
            "OCAR_TotSconti" REAL,
            "OCAR_ScontiFinali" REAL,
            "OCAR_PrezzoListino" REAL,
            "OCAR_DQTA" REAL,
            "OCAR_EForz" INTEGER,
            "OCAR_APP_ID" TEXT);""");
  }

  Future<void> test() async {
    Database db = await _currentDatabase();

    final List<Map<String, dynamic>> map =
        await db.rawQuery("SELECT * FROM MB_Anagr");
    debugPrint(map.toString());
    //db.close();
  }

  Future<int> rawUpd(String query, List<dynamic> values) async {
    Database db = await _currentDatabase();
    try {
      int val = await db.rawUpdate(query, values);
      debugPrint('returm value from RawUpdate: $val');
      return val;
    } catch (e) {
      debugPrint('errore funzione RawUpdate: $e');
      return -1;
    }
  }

  Future<int> rawIns(String query, List<dynamic> values) async {
    Database db = await _currentDatabase();

    try {
      debugPrint('query da eseguire in insert: $query,[$values]');
      int val = await db.rawInsert(query, values);
      debugPrint('return value from rawInsert: $val');
      return val;
    } catch (e) {
      debugPrint('errore funzione RawInsert: $e');
      return -1;
    }
  }

  Future<int> rawDelete(String query, List<dynamic> values) async {
    Database db = await _currentDatabase();

    try {
      int val = await db.rawDelete(query, values);
      debugPrint('val Delete: $val');
      return val;
    } catch (e) {
      debugPrint('errore funzione RawDelete: $e');
      return -1;
    }
  }

  Future<int> deleteMessage(int id) async {
    Database db = await _currentDatabase();
    try {
      int val = await db
          .rawDelete("DELETE FROM MessagesToSend WHERE METS_ID =?", [id]);
      return val;
    } catch (e) {
      return -1;
    }
  }

  Future<int> deleteAllMessages() async {
    Database db = await _currentDatabase();
    try {
      int val = await db.rawDelete("DELETE FROM MessagesToSend ");
      return val;
    } catch (e) {
      return -1;
    }
  }

  Future<List<String>> getDestinatariByMBANId(int mbanId) async {
    final db = await _currentDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
      'MB_CliForDest',
      columns: ['MBDT_Destinatario'],
      where: 'MBDT_MBAN_ID = ?',
      whereArgs: [mbanId],
    );

    print(maps.toString());
    return List.generate(maps.length, (i) {
      return maps[i]['MBDT_Destinatario'].toString();
    });
  }

  Future<List<double?>> getScontiCliente(int clienteId, int prodottoId) async {
    Database db = await _currentDatabase();
    debugPrint(clienteId.toString() + '-' + prodottoId.toString());
    // Esegui la query per ottenere gli sconti del cliente e del prodotto
    final List<Map<String, dynamic>> result = await db.rawQuery("""SELECT
                      COALESCE(ptv.ZPTV_Sconto1, ac.MBAN_Sconto1) AS Sconto1,
                      COALESCE(ptv.ZPTV_Sconto2, ac.MBAN_Sconto2) AS Sconto2,
                      COALESCE(ptv.ZPTV_Sconto3, ac.MBAN_Sconto3) AS Sconto3
                  FROM
                      (SELECT  
                          ZPTV_Sconto1, 
                          ZPTV_Sconto2, 
                          ZPTV_Sconto3
                      FROM 
                          Z_PrezziTV
                      WHERE
                          ZPTV_MGAA_Id = ?
                          AND (ZPTV_MBPC_Id = ? OR ZPTV_MBPC_Id IS NULL)
                      ORDER BY
                          CASE 
                              WHEN ZPTV_MBPC_Id = ? THEN 1
                              ELSE 2
                          END
                      LIMIT 1) ptv
                  LEFT JOIN
                      MB_Anagr ac
                  ON
                      ac.MBPC_ID = ?;
""", [prodottoId, clienteId, clienteId, clienteId]);

    if (result.isNotEmpty) {
      debugPrint(jsonEncode(result));
      // Se ci sono risultati, restituisci i tre sconti, altrimenti restituisci una lista con null
      return [
        result[0]['Sconto1'] != null ? result[0]['Sconto1'] as double : null,
        result[0]['Sconto2'] != null ? result[0]['Sconto2'] as double : null,
        result[0]['Sconto3'] != null ? result[0]['Sconto3'] as double : null,
      ];
    } else {
      // Nessuno sconto trovato, ritorna una lista con null
      return [null, null, null];
    }
  }

  Future<int> getNumFatture(int tipo, int anno, int mbpcid) async {
    Database db = await _currentDatabase();

    final List<Map<String, dynamic>> map = await db.rawQuery(
        """SELECT COUNT(FTAN_ID) as num,substr(FTAN_DataIns,0,5) as anno FROM FT_Anagr WHERE substr(FTAN_DataIns,0,5)='$anno' AND  FTAN_MBPC_ID=$mbpcid""");

    return map[0]["num"];
  }

  Future<int> getNumOrdini(int tipo, int anno, int mbpcid) async {
    Database db = await _currentDatabase();

    final List<Map<String, dynamic>> map = await db.rawQuery(
        """SELECT COUNT(OCAN_ID) as num FROM OC_Anag WHERE  substr(OCAN_DataIns,0,5)='$anno' AND OCAN_MBPC_ID=$mbpcid""");

    return map[0]["num"];
  }

  Future<int> getNumBolla(int tipo, int anno, int mbpcid) async {
    Database db = await _currentDatabase();

    final List<Map<String, dynamic>> map = await db.rawQuery(
        """SELECT COUNT(BLAN_ID) as num FROM BL_Anag WHERE substr(BLAN_DataIns,0,5)='$anno' AND BLAN_MBPC_ID=$mbpcid""");

    return map[0]["num"];
  }

  /*PARAMETRI*/
  Future<List<Map<String, dynamic>>> getAgenti() async {
    Database db = await _currentDatabase();

    final List<Map<String, dynamic>> map =
        await db.rawQuery('SELECT MBAG_ID, MBAN_RagSoc FROM MB_Agenti');
    debugPrint(jsonEncode(map));
    return map;
  }

  Future<String> getCliente(int? mbpcId) async {
    Database db = await _currentDatabase();
    String where = ' 1=1 ';
    if (mbpcId != null) {
      where = ' MBPC_ID=$mbpcId ';
    }
    final List<Map<String, dynamic>> map =
        await db.rawQuery("SELECT MBAN_RagSoc FROM MB_Anagr WHERE $where ");
    return map[0]["MBAN_RagSoc"] ?? '0';
  }

  Future<String> getIndirizzo(int mbanId) async {
    Database db = await _currentDatabase();
    final List<Map<String, dynamic>> map = await db
        .rawQuery("SELECT MBAN_Indirizzo FROM MB_Anagr WHERE MBAN_ID=$mbanId ");
    return map[0]["MBAN_Indirizzo"] ?? '';
  }

  Future<int> getMBAGID() async {
    Database db = await _currentDatabase();
    final List<Map<String, dynamic>> map =
        await db.rawQuery("SELECT SPPA_MBAG_ID FROM SP_Param");
    debugPrint(map.toString());
    return map[0]["SPPA_MBAG_ID"] ?? 0;
  }

  Future<int> getMBDVID() async {
    Database db = await _currentDatabase();
    final List<Map<String, dynamic>> map =
        await db.rawQuery("SELECT SPPA_MBDV_ID FROM SP_Param");
    return map[0]["SPPA_MBDV_ID"] ?? 0;
  }

  Future<int> getMBSCID() async {
    Database db = await _currentDatabase();
    final List<Map<String, dynamic>> map =
        await db.rawQuery("SELECT SPPA_MBSC_ID FROM SP_Param");
    return map[0]["SPPA_MBSC_ID"] ?? 0;
  }

  Future<int> getTipoOrdine() async {
    Database db = await _currentDatabase();
    final List<Map<String, dynamic>> map =
        await db.rawQuery("SELECT SPPA_OCTI_ID FROM SP_Param");
    return map[0]["SPPA_OCTI_ID"] ?? 0;
  }

  Future<int> getTipoFattura() async {
    Database db = await _currentDatabase();
    final List<Map<String, dynamic>> map =
        await db.rawQuery("SELECT SPPA_FTTI_ID FROM SP_Param");
    return map[0]["SPPA_FTTI_ID"] ?? 0;
  }

  Future<int> getTipoBolla1() async {
    Database db = await _currentDatabase();
    final List<Map<String, dynamic>> map =
        await db.rawQuery("SELECT SPPA_BLTI_ID1 FROM SP_Param");

    return map[0]["SPPA_BLTI_ID1"] ?? 0;
  }

  Future<int> getTipoBolla2() async {
    Database db = await _currentDatabase();
    final List<Map<String, dynamic>> map =
        await db.rawQuery("SELECT SPPA_BLTI_ID2 FROM SP_Param");

    return map[0]["SPPA_BLTI_ID2"] ?? 0;
  }

  Future<String?> getPassword() async {
    Database db = await _currentDatabase();
    final List<Map<String, dynamic>> map =
        await db.rawQuery("SELECT SPPA_Password FROM SP_Param");
    return map[0]["SPPA_Password"];
  }

  Future<int> saveIMEI(String imei) async {
    Database db = await _currentDatabase();
    return await db.rawUpdate("UPDATE SP_Param SET SPPA_IMEI='$imei'");
  }

  Future<String> getIMEI() async {
    Database db = await _currentDatabase();
    final List<Map<String, dynamic>> map =
        await db.rawQuery("SELECT SPPA_IMEI FROM SP_Param");
    return map[0]["SPPA_IMEI"] ?? '';
  }

  Future<int> getIva(int id) async {
    Database db;
    try {
      db =
          await _currentDatabase(); // Assicurati che `_currentDatabase()` gestisca le proprie eccezioni.
      final List<Map<String, dynamic>> map =
          await db.rawQuery("SELECT MBIV_IVA FROM MB_IVA WHERE MBIV_ID=$id");
      if (map.isNotEmpty) {
        return map[0]["MBIV_IVA"] ?? 0;
      }
      return 0; // Nessun risultato trovato, restituisci default.
    } catch (e) {
      // Gestisce le eccezioni che potrebbero verificarsi durante la connessione al DB o la query.
      debugPrint('Errore durante il recupero dell\'IVA: $e');
      return 0; // Restituisce un valore di default in caso di errore.
    }
  }

  Future<int> saveParameters(String password, int octipo, int ageid,
      int bltipo1, int bltipo2, int fttipo, int tipoConto) async {
    Database db = await _currentDatabase();
    debugPrint('tipo fattura: $fttipo');
    return await db.rawUpdate(
        "UPDATE SP_Param SET SPPA_FTTI_ID = $fttipo, SPPA_OCTI_ID=$octipo, SPPA_BLTI_ID1 = $bltipo1,SPPA_BLTI_ID2=$bltipo2, SPPA_MBAG_ID=$ageid, SPPA_TipoConto=$tipoConto, SPPA_Password='$password';");
  }

  /*SERVER*/

  Future<int> saveServerAPI(String server) async {
    Database db = await _currentDatabase();
    return await db
        .rawUpdate("UPDATE SP_Param SET SPPA_IndirizzoServerAPI='$server'");
  }

  Future<String> getServerAPI() async {
    Database db = await _currentDatabase();
    final List<Map<String, dynamic>> map =
        await db.rawQuery("SELECT SPPA_IndirizzoServerAPI FROM SP_Param");
    if (map[0]["SPPA_IndirizzoServerAPI"] == null) {
      return "Server API";
    } else {
      return map[0]["SPPA_IndirizzoServerAPI"];
    }
  }

  Future<int> saveServerWSK(String server) async {
    Database db = await _currentDatabase();
    return await db
        .rawUpdate("UPDATE SP_Param SET SPPA_IndirizzoServerWSK='$server'");
  }

  Future<String> getServerWSK() async {
    Database db = await _currentDatabase();
    final List<Map<String, dynamic>> map =
        await db.rawQuery("SELECT SPPA_IndirizzoServerWSK FROM SP_Param");
    if (map[0]["SPPA_IndirizzoServerWSK"] == null) {
      return 'Server WSK';
    } else {
      return map[0]["SPPA_IndirizzoServerWSK"];
    }
  }
  /*MESSAGGI*/

  Future<String> saveMessage(Messaggio message) async {
    Database db = await _currentDatabase();

    return await db.transaction((txn) async {
      try {
        debugPrint('Salvataggio messaggio: ${message.toJson()}');
        await txn.insert('MessagesToSend', message.toJson());
        return 'ok';
      } catch (e) {
        debugPrint('Errore durante il salvataggio del messaggio: $e');
        return 'err: $e';
      }
    });
  }

/*   Future<int> countMessages() async {
    Database db = await _currentDatabase();
    return await db.transaction((txn) async {
      try {
        final List<Map<String, dynamic>> results =
            await txn.rawQuery('SELECT * FROM');
        //db.close();
        return Sqflite.firstIntValue(results) ?? 0;
      } catch (e) {
        debugPrint('err: $e');
        return 0;
      }
    });
  } */

  Future<List<Messaggio>> getMessages() async {
    Database db = await _currentDatabase();

    return await db.transaction((txn) async {
      try {
        final List<Map<String, dynamic>> results =
            await txn.rawQuery('SELECT * FROM MessagesToSend');
        //db.close();
        return List.generate(results.length, (i) {
          return Messaggio.fromJson(results[i]);
        });
      } catch (e) {
        debugPrint('err: $e');
        return [
          Messaggio(
              metsId: 0,
              metsMessage: "Errore getMessages: $e",
              metsDataSave: "metsDataSave")
        ];
      }
    });
  }

  /*ARTICOLI */

  Future<List<Prodotto>> getArticoli(int mbpcid) async {
    Database db = await _currentDatabase();
    final List<Map<String, dynamic>> map = await db.rawQuery("""SELECT 
                          ZPTV_MGAA_Id AS MGAA_ID,
                          ZPTV_Prezzo AS MGAA_PVendita,
                          MGAA_MBDC_Classe,
                          MGAA_Matricola,
                          MGAA_Descr,
                          MGAA_MBUM_Codice,
                          MGAA_MBIV_ID,
                          MGAA_Stato,
                          CASE WHEN ZPTV_Sconto1 is NULL THEN MBAN_Sconto1 ELSE ZPTV_Sconto1 END Sconto1,
                          CASE WHEN ZPTV_Sconto2 is NULL THEN MBAN_Sconto2 ELSE ZPTV_Sconto1 END Sconto2,
                          CASE WHEN ZPTV_Sconto3 is NULL THEN MBAN_Sconto3 ELSE ZPTV_Sconto1 END Sconto3
                        FROM Z_PrezziTV
                        LEFT JOIN MG_AnaArt ON MGAA_ID= ZPTV_MGAA_ID
                        JOIN MB_Anagr ON MBPC_ID= ZPTV_MBPC_ID
                        WHERE ZPTV_MBPC_Id = $mbpcid

                        UNION

                        SELECT 
                          ZPTV_MGAA_Id AS MGAA_ID,
                          ZPTV_Prezzo AS MGAA_PVendita,
                          MGAA_MBDC_Classe,
                          MGAA_Matricola,
                          MGAA_Descr,
                          MGAA_MBUM_Codice,
                          MGAA_MBIV_ID,
                          MGAA_Stato,
                          CASE  WHEN (ZPTV_Sconto1 IS NULL OR ZPTV_Sconto1 =0 ) THEN (SELECT MBAN_Sconto1 FROM MB_Anagr WHERE MBPC_ID=$mbpcid) ELSE ZPTV_Sconto1 END AS Sconto1,
						              CASE  WHEN (ZPTV_Sconto2 IS NULL OR ZPTV_Sconto2 =0 ) THEN (SELECT MBAN_Sconto2 FROM MB_Anagr WHERE MBPC_ID=$mbpcid) ELSE ZPTV_Sconto2 END AS Sconto2,
						              CASE  WHEN (ZPTV_Sconto3 IS NULL OR ZPTV_Sconto3 =0 )  THEN (SELECT MBAN_Sconto3 FROM MB_Anagr WHERE MBPC_ID=$mbpcid) ELSE ZPTV_Sconto3 END AS Sconto3
                        FROM Z_PrezziTV
                        LEFT JOIN MG_AnaArt ON MGAA_ID= ZPTV_MGAA_ID
                        WHERE ZPTV_MBPC_Id IS NULL
                        AND ZPTV_MGAA_Id NOT IN (SELECT ZPTV_MGAA_Id FROM Z_PrezziTV WHERE ZPTV_MBPC_Id = $mbpcid) AND MGAA_Stato=1;""");

    //db.close();
/*     debugPrint("""SELECT 
                          ZPTV_MGAA_Id AS MGAA_ID,
                          ZPTV_Prezzo AS MGAA_PVendita,
                          MGAA_MBDC_Classe,
                          MGAA_Matricola,
                          MGAA_Descr,
                          MGAA_MBUM_Codice,
                          MGAA_MBIV_ID,
                          MGAA_Stato,
                          CASE WHEN ZPTV_Sconto1 is NULL THEN MBAN_Sconto1 ELSE ZPTV_Sconto1 END Sconto1,
                          CASE WHEN ZPTV_Sconto2 is NULL THEN MBAN_Sconto2 ELSE ZPTV_Sconto1 END Sconto2,
                          CASE WHEN ZPTV_Sconto3 is NULL THEN MBAN_Sconto3 ELSE ZPTV_Sconto1 END Sconto3
                        FROM Z_PrezziTV
                        LEFT JOIN MG_AnaArt ON MGAA_ID= ZPTV_MGAA_ID
                        JOIN MB_Anagr ON MBPC_ID= ZPTV_MBPC_ID
                        WHERE ZPTV_MBPC_Id = $mbpcid

                        UNION

                        SELECT 
                          ZPTV_MGAA_Id AS MGAA_ID,
                          ZPTV_Prezzo AS MGAA_PVendita,
                          MGAA_MBDC_Classe,
                          MGAA_Matricola,
                          MGAA_Descr,
                          MGAA_MBUM_Codice,
                          MGAA_MBIV_ID,
                          MGAA_Stato,
                          CASE  WHEN (ZPTV_Sconto1 IS NULL OR ZPTV_Sconto1 =0 ) THEN (SELECT MBAN_Sconto1 FROM MB_Anagr WHERE MBPC_ID=$mbpcid) ELSE ZPTV_Sconto1 END AS Sconto1,
						              CASE  WHEN (ZPTV_Sconto2 IS NULL OR ZPTV_Sconto2 =0 ) THEN (SELECT MBAN_Sconto2 FROM MB_Anagr WHERE MBPC_ID=$mbpcid) ELSE ZPTV_Sconto2 END AS Sconto2,
						              CASE  WHEN (ZPTV_Sconto3 IS NULL OR ZPTV_Sconto3 =0 )  THEN (SELECT MBAN_Sconto3 FROM MB_Anagr WHERE MBPC_ID=$mbpcid) ELSE ZPTV_Sconto3 END AS Sconto3
                        FROM Z_PrezziTV
                        LEFT JOIN MG_AnaArt ON MGAA_ID= ZPTV_MGAA_ID
                        WHERE ZPTV_MBPC_Id IS NULL
                        AND ZPTV_MGAA_Id NOT IN (SELECT ZPTV_MGAA_Id FROM Z_PrezziTV WHERE ZPTV_MBPC_Id = $mbpcid) AND MGAA_Stato=1;"""); */
    return List.generate(map.length, (i) {
      //debugPrint(map[i].toString());
      return Prodotto.fromJson(map[i]);
    });
  }

  Future<String> initDbArticoli(Prodotto prodotto) async {
    Database db = await _currentDatabase();

    return await db.transaction((txn) async {
      try {
        await txn.insert('MG_AnaArt', prodotto.toJson(),
            conflictAlgorithm: ConflictAlgorithm.ignore);
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

  Future<String> initDbArticoliBatch(List<Prodotto> prodotti) async {
    Database db = await _currentDatabase();
    return await db.transaction((txn) async {
      try {
        for (Prodotto prodotto in prodotti) {
          await txn.insert('MG_AnaArt', prodotto.toJson());
        }
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

  /*PARTITE */
  Future<String> initDbPartite(Partita partita) async {
    Database db = await _currentDatabase();

    return await db.transaction((txn) async {
      try {
        await txn.insert('CA_Partite', partita.toJson(),
            conflictAlgorithm: ConflictAlgorithm.ignore);
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

  Future<String> initDbPartiteBatch(List<Partita> partite) async {
    Database db = await _currentDatabase();
    return await db.transaction((txn) async {
      try {
        for (Partita partita in partite) {
          await txn.insert('CA_Partite', partita.toJson());
        }
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

  Future<List<Partita>> getPartite(int MBPC_ID) async {
    Database db = await _currentDatabase();
    final List<Map<String, dynamic>> map = await db.rawQuery(
        "SELECT * FROM CA_Partite  WHERE CAPA_MBPC_ID =$MBPC_ID AND CAPA_CASP_Stato IN (1,2,4)");

    //db.close();
    return List.generate(map.length, (i) {
      //debugPrint(map[i].toString());
      return Partita.fromJson(map[i]);
    });
  }

  /*Anagrafiche Clienti */
  Future<String> initDbAnagClienti(Cliente cliente) async {
    Database db = await _currentDatabase();

    return await db.transaction((txn) async {
      try {
        await txn.insert('MB_Anagr', cliente.toJson());
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

  Future<String> initDbCliForDest(MbCliForDest dest) async {
    Database db = await _currentDatabase();

    return await db.transaction((txn) async {
      try {
        await txn.insert('MB_CliForDest', dest.toJson());
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

  Future<String> updateDbScontiBatch(List<Sconto> sconti) async {
    Database db = await _currentDatabase();

    return await db.transaction((txn) async {
      try {
        for (Sconto sconto in sconti) {
          debugPrint(
              'sconto: ${sconto.mbscProg}-${sconto.mbscPerc}-${sconto.mbpcId}');
          String scontoField;
          switch (sconto.mbscProg) {
            case 1:
              scontoField = 'MBAN_Sconto1';
              break;
            case 2:
              scontoField = 'MBAN_Sconto2';
              break;
            case 3:
              scontoField = 'MBAN_Sconto3';
              break;
            default:
              continue;
          }
          debugPrint('sconto field: $scontoField');
          await txn.update(
            'MB_Anagr',
            {scontoField: sconto.mbscPerc},
            where: 'MBPC_ID = ?',
            whereArgs: [sconto.mbpcId],
          );
        }
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

  Future<String> initDbAnagClientiBatch(List<Cliente> clienti) async {
    Database db = await _currentDatabase();
    return await db.transaction((txn) async {
      try {
        for (Cliente cliente in clienti) {
          await txn.insert('MB_Anagr', cliente.toJson());
        }
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

  Future<String> initDbMBCliForDestBatch(
      List<MbCliForDest> destinazioni) async {
    Database db = await _currentDatabase();
    return await db.transaction((txn) async {
      try {
        for (MbCliForDest dest in destinazioni) {
          await txn.insert('MB_CliForDest', dest.toJson());
        }
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

  Future<List<Cliente>> getAnagraficheClienti() async {
    Database db = await _currentDatabase();
    final List<Map<String, dynamic>> map = await db.rawQuery(
        "SELECT * FROM MB_Anagr WHERE MBAN_DataFineVal ='' ORDER BY MBAN_RagSoc ASC");

    //db.close();
    return List.generate(map.length, (i) {
      return Cliente.fromJson(map[i]);
    });
  }

  /*PAGAMENTI ODRINI/BOLLE/FATTURE */

  Future<String> updateOcanPagam(int oldOcanId, int newOcanId) async {
    Database db = await _currentDatabase();
    return await db.transaction((txn) async {
      try {
        // Aggiorna il campo OCPG_OCAN_ID dove OCPG_APP_ID è uguale a ocpgAppId
        await txn.update('OC_Pagam', {'OCPG_OCAN_ID': oldOcanId},
            where: 'OCPG_OCAN_ID = ?', whereArgs: [newOcanId]);
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

  Future<String> updateOcanArtic(int ocanid, int ocarAppId) async {
    Database db = await _currentDatabase();
    return await db.transaction((txn) async {
      try {
        // Aggiorna il campo OCAR_OCAN_ID dove OCAR_APP_ID è uguale a ocarAppId
        await txn.update('OC_Artic', {'OCAR_OCAN_ID': ocanid},
            where: 'OCAR_OCAN_ID = ?', whereArgs: [ocarAppId]);
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

  Future<String> updateOcanAnag(int ocanid, int ocarAppId) async {
    Database db = await _currentDatabase();
    return await db.transaction((txn) async {
      try {
        // Aggiorna il campo OCAR_OCAN_ID dove OCAR_APP_ID è uguale a ocarAppId
        await txn.update('OC_Anag', {'OCAN_ID': ocanid},
            where: 'OCAN_ID = ?', whereArgs: [ocarAppId]);
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

  Future<String> initDbBLPagameti(PagamentoBolla pagamento) async {
    Database db = await _currentDatabase();

    return await db.transaction((txn) async {
      try {
        await txn.insert('BL_Pagam', pagamento.toJson(),
            conflictAlgorithm: ConflictAlgorithm.ignore);
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

  Future<String> initDbBlPagamentiBatch(List<PagamentoBolla> pagamenti) async {
    Database db = await _currentDatabase();
    return await db.transaction((txn) async {
      try {
        for (PagamentoBolla pagamento in pagamenti) {
          await txn.insert('BL_Pagam', pagamento.toJson());
        }
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

  Future<String> initDbOCPagameti(PagamentoOrdine pagamento) async {
    Database db = await _currentDatabase();

    return await db.transaction((txn) async {
      try {
        await txn.insert('OC_Pagam', pagamento.toJson(),
            conflictAlgorithm: ConflictAlgorithm.ignore);
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

  Future<String> initDbOCPagametiBatch(List<PagamentoOrdine> pagamenti) async {
    Database db = await _currentDatabase();
    return await db.transaction((txn) async {
      try {
        for (PagamentoOrdine pagamento in pagamenti) {
          await txn.insert('OC_Pagam', pagamento.toJson());
        }
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

  Future<String> initDbFTPagameti(PagamentoFattura pagamento) async {
    Database db = await _currentDatabase();

    return await db.transaction((txn) async {
      try {
        await txn.insert('FT_Pagam', pagamento.toJson(),
            conflictAlgorithm: ConflictAlgorithm.ignore);
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

  Future<String> initDbFTPagametiBatch(List<PagamentoFattura> pagamenti) async {
    Database db = await _currentDatabase();
    return await db.transaction((txn) async {
      try {
        for (PagamentoFattura pagamento in pagamenti) {
          await txn.insert('FT_Pagam', pagamento.toJson());
        }
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

  Future<String> initDbPrezziTVBatch(List<PrezziTV> prezzi) async {
    Database db =
        await _currentDatabase(); // Assicurati di avere questa funzione definita per ottenere l'istanza del database
    return await db.transaction((txn) async {
      try {
        for (PrezziTV prezzo in prezzi) {
          await txn.insert('Z_PrezziTV', prezzo.toJson());
        }
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

  /*Tipi Documenti */

  Future<String> initDbTipoPag(TipoPagamento pagamento) async {
    Database db = await _currentDatabase();

    return await db.transaction((txn) async {
      try {
        await txn.insert('MB_TipoPag', pagamento.toJson(),
            conflictAlgorithm: ConflictAlgorithm.ignore);
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

  Future<String> initDbTipoPagBatch(List<TipoPagamento> pagamenti) async {
    Database db = await _currentDatabase();
    return await db.transaction((txn) async {
      try {
        for (TipoPagamento pagamento in pagamenti) {
          await txn.insert('MB_TipoPag', pagamento.toJson());
        }
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

  Future<String> initDbTipoArticoliBatch(List<TipoArticolo> pagamenti) async {
    Database db = await _currentDatabase();
    return await db.transaction((txn) async {
      try {
        for (TipoArticolo pagamento in pagamenti) {
          await txn.insert('MB_TipiArticoloVA', pagamento.toJson());
        }
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

  Future<String> initDbSolPag(SoluzionePagamento soluzione) async {
    Database db = await _currentDatabase();

    return await db.transaction((txn) async {
      try {
        await txn.insert('MB_SolPag', soluzione.toJson(),
            conflictAlgorithm: ConflictAlgorithm.ignore);
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

  Future<String> initDbSolPagBatch(List<SoluzionePagamento> soluzioni) async {
    Database db = await _currentDatabase();
    return await db.transaction((txn) async {
      try {
        for (SoluzionePagamento soluzione in soluzioni) {
          await txn.insert('MB_SolPag', soluzione.toJson());
        }
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

  Future<String> initMBIva(Iva iv) async {
    Database db = await _currentDatabase();
    return await db.transaction((txn) async {
      try {
        await txn.insert('MB_IVA', iv.toJson());
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

  Future<String> initMBIvaBatch(List<Iva> ive) async {
    Database db = await _currentDatabase();
    return await db.transaction((txn) async {
      try {
        for (Iva iva in ive) {
          await txn.insert('MB_IVA', iva.toJson());
        }
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

  Future<String> initFTTipo(TipoFattura tipo) async {
    Database db = await _currentDatabase();
    return await db.transaction((txn) async {
      try {
        await txn.insert('FT_Tipo', tipo.toJson());
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

  Future<String> initFTTipoBatch(List<TipoFattura> tipi) async {
    Database db = await _currentDatabase();
    return await db.transaction((txn) async {
      try {
        for (TipoFattura tipo in tipi) {
          await txn.insert('FT_Tipo', tipo.toJson());
        }
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

  Future<String> initMBAge(Agente ag) async {
    Database db = await _currentDatabase();
    return await db.transaction((txn) async {
      try {
        await txn.insert('MB_Agenti', ag.toJson());
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

  Future<List<Map<String, dynamic>>> getConti() async {
    Database db = await _currentDatabase();

    final List<Map<String, dynamic>> map = await db
        .rawQuery('SELECT MBTC_TipoConto, MBTC_Descr FROM MB_TipoConto');

    return map;
  }

  Future<String> initMBTipoConto(TipoConto tipo) async {
    Database db = await _currentDatabase();
    return await db.transaction((txn) async {
      try {
        await txn.insert('MB_TipoConto', tipo.toJson());
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

  Future<String> initMBTipoContoBatch(List<TipoConto> tipi) async {
    Database db = await _currentDatabase();
    return await db.transaction((txn) async {
      try {
        for (TipoConto tipo in tipi) {
          await txn.insert('MB_TipoConto', tipo.toJson());
        }
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

  Future<String> initBLTipo(TipoBolla tipo) async {
    Database db = await _currentDatabase();
    return await db.transaction((txn) async {
      try {
        await txn.insert('BL_Tipo', tipo.toJson());
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

  Future<String> initBLTipoBatch(List<TipoBolla> tipi) async {
    Database db = await _currentDatabase();
    return await db.transaction((txn) async {
      try {
        for (TipoBolla tipo in tipi) {
          await txn.insert('BL_Tipo', tipo.toJson());
        }
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

  Future<String> initOCTipo(TipoOrdine tipo) async {
    Database db = await _currentDatabase();
    return await db.transaction((txn) async {
      try {
        await txn.insert('OC_Tipo', tipo.toJson());
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

  Future<String> initOCTipoBatch(List<TipoOrdine> tipi) async {
    Database db = await _currentDatabase();
    return await db.transaction((txn) async {
      try {
        for (TipoOrdine tipo in tipi) {
          await txn.insert('BL_Tipo', tipo.toJson());
        }
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

  /*FATTURE */
  Future<List<Map<String, dynamic>>> getFTTipo() async {
    Database db = await _currentDatabase();

    final List<Map<String, dynamic>> map =
        await db.rawQuery('SELECT * FROM FT_Tipo');
    return map;
  }

  Future<String> initTestataFattura(TestataFattura testata) async {
    Database db = await _currentDatabase();
    return await db.transaction((txn) async {
      try {
        await txn.insert('FT_Anagr', testata.toJson());
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

  Future<String> initTestataFatturaBatch(List<TestataFattura> testate) async {
    Database db = await _currentDatabase();
    return await db.transaction((txn) async {
      try {
        for (TestataFattura testata in testate) {
          await txn.insert('FT_Anagr', testata.toJson());
        }
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

  Future<String> initRigaFattura(RigaFattura riga) async {
    Database db = await _currentDatabase();
    return await db.transaction((txn) async {
      try {
        await txn.insert('FT_Artic', riga.toJson());
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

  Future<String> initRigaFatturaBatch(List<RigaFattura> righe) async {
    Database db = await _currentDatabase();
    return await db.transaction((txn) async {
      try {
        for (RigaFattura riga in righe) {
          await txn.insert('FT_Artic', riga.toJson());
        }
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

  /*ORDINI */

  Future<String> updateDbApprId(int newApprId) async {
    Database db = await _currentDatabase();

    return await db.transaction((txn) async {
      try {
        await txn.update('OC_APP_ID', {'APPR_ID': newApprId});
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

  Future<String> updateDbApptId(int newApptId) async {
    Database db = await _currentDatabase();

    return await db.transaction((txn) async {
      try {
        await txn.update('OC_APP_ID', {'APPT_ID': newApptId});
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

  Future<String> updateDbIdTestatePagam(int newApptId) async {
    Database db = await _currentDatabase();

    return await db.transaction((txn) async {
      try {
        await txn.update('PF_APP_ID', {'APPT_ID': newApptId});
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

  Future<String> updateDbIdRighePagam(int newAppdId) async {
    Database db = await _currentDatabase();

    return await db.transaction((txn) async {
      try {
        await txn.update('PF_APP_ID', {'APPD_ID': newAppdId});
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

  Future<String> updateOcanId(int ocan_id, String ocan_app_id) async {
    Database db = await _currentDatabase();

    return await db.transaction((txn) async {
      try {
        // Esegui l'aggiornamento del campo OCAN_ID dove OCAN_APP_ID è uguale al valore fornito
        await txn.update(
            'OC_Anag', {'OCAN_ID': ocan_id}, // Aggiorna il campo OCAN_ID
            where: 'OCAN_APP_ID = ?', // Condizione per il match su OCAN_APP_ID
            whereArgs: [ocan_app_id] // Argomenti per la condizione WHERE
            );
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

  Future<String> getMediaOrdinato(int anno, int mbpcId) async {
    Database db = await _currentDatabase();
    final List<Map<String, dynamic>> map =
        await db.rawQuery("""SELECT IFNULL(ROUND(t1.tot/12,2),0) as media from (
      SELECT SUM((OCAR_Prezzo*OCAR_Quantita)-OCAR_TotSconti) as tot  FROM OC_Artic
      JOIN OC_Anag ON OCAR_OCAN_ID=OCAN_ID
      WHERE substr(OCAN_DataIns,0,5)='$anno' AND OCAN_MBPC_Id =$mbpcId 
      ) t1""");
    return map[0]["media"].toString();
  }

  Future<String> getMbumCodice(String tabella, String prefisso, int id) async {
    Database db = await _currentDatabase();
    final List<Map<String, dynamic>> map = await db.rawQuery(
        "SELECT ${prefisso}_MBUM_Codice FROM $tabella WHERE ${prefisso}_ID=$id");
    return map[0]["${prefisso}_MBUM_Codice"];
  }

  Future<List<Map<String, dynamic>>> getOCTipo() async {
    Database db = await _currentDatabase();

    final List<Map<String, dynamic>> map =
        await db.rawQuery('SELECT * FROM OC_Tipo');
    return map;
  }

  Future<String> initTestataOrdini(TestataOrdine testata) async {
    Database db = await _currentDatabase();
    return await db.transaction((txn) async {
      try {
        await txn.insert('OC_Anag', testata.toJson());
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

  Future<String> initTestataOrdiniBatch(List<TestataOrdine> testate) async {
    Database db = await _currentDatabase();
    return await db.transaction((txn) async {
      try {
        for (TestataOrdine testata in testate) {
          await txn.insert('OC_Anag', testata.toJson());
        }
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

  Future<int> initRigheOrdine(RigaOrdine riga) async {
    Database db = await _currentDatabase();
    return await db.transaction((txn) async {
      try {
        return await txn.insert('OC_Artic', riga.toJson());
      } catch (e) {
        return -1;
      }
    });
  }

  Future<String> initRigheOrdineBatch(List<RigaOrdine> righeOrdine) async {
    Database db = await _currentDatabase();
    return await db.transaction((txn) async {
      try {
        for (RigaOrdine riga in righeOrdine) {
          await txn.insert('OC_Artic', riga.toJson());
        }
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

//SELECT * FROM OC_Anag WHERE OCAN_APP_ID LIKE '423511011567811%'
  Future<int> getLastOrderNum() async {
    Database db = await _currentDatabase();
    final List<Map<String, dynamic>> map0 =
        await db.rawQuery("SELECT SPPA_OCTI_ID FROM SP_PARAM");
    final octi_id = map0[0]["SPPA_OCTI_ID"];
    final List<Map<String, dynamic>> map = await db.rawQuery(
        "SELECT MAX(OCAN_NumOrd) as OCAN_NumOrd FROM OC_Anag WHERE OCAN_OCTI_ID=$octi_id AND OCAN_AnnoOrd=${DateTime.now().year}");
    //debugPrint(map[0]["OCAN_NumOrd"].toString());
    return map[0]["OCAN_NumOrd"] ?? 0;
  }

  Future<int> getLastOcarId() async {
    Database db = await _currentDatabase();
    final List<Map<String, dynamic>> map =
        await db.rawQuery("SELECT MAX(OCAR_ID) as OCAR_ID FROM OC_Artic");
    debugPrint(map[0]["OCAR_ID"]);
    return map[0]["OCAR_ID"] ?? 0;
  }

  Future<int?> getOcanAppId() async {
    Database db = await _currentDatabase();
    final List<Map<String, dynamic>> map =
        await db.rawQuery("SELECT APPT_ID FROM OC_APP_ID");
    //debugPrint(map[0]["APPT_ID"] + 1);
    return map[0]["APPT_ID"] + 1;
  }

  Future<List<Map<String, dynamic>>> getPagamentiPerOcanId(int ocanId) async {
    Database db = await _currentDatabase();
    return await db.query(
      'OC_Pagam',
      where: 'OCPG_OCAN_Id = ?',
      whereArgs: [ocanId],
    );
  }

  Future<List<Map<String, dynamic>>> getArticoliPerOcanId(int ocanId) async {
    Database db = await _currentDatabase();
    return await db.query(
      'OC_Artic',
      where: 'OCAR_OCAN_Id = ?',
      whereArgs: [ocanId],
    );
  }

  Future<int?> getOcarAppId() async {
    Database db = await _currentDatabase();
    final List<Map<String, dynamic>> map =
        await db.rawQuery("SELECT APPR_ID FROM OC_APP_ID");
    //debugPrint(map[0]["APPR_ID"] + 1);
    return map[0]["APPR_ID"] + 1;
  }

  Future<int?> getPFARAppId() async {
    Database db = await _currentDatabase();
    final List<Map<String, dynamic>> map =
        await db.rawQuery("SELECT APPD_ID FROM PF_APP_ID");
    //debugPrint(map[0]["APPR_ID"] + 1);
    return map[0]["APPD_ID"] + 1;
  }

  Future<int?> getPFANAppId() async {
    Database db = await _currentDatabase();
    final List<Map<String, dynamic>> map =
        await db.rawQuery("SELECT APPT_ID FROM PF_APP_ID");
    //debugPrint(map[0]["APPR_ID"] + 1);
    return map[0]["APPT_ID"] + 1;
  }

  /*BOLLE */

  Future<List<Map<String, dynamic>>> getBLTipo() async {
    Database db = await _currentDatabase();

    final List<Map<String, dynamic>> map =
        await db.rawQuery('SELECT * FROM BL_Tipo');
    return map;
  }

  Future<String> initTestataBolle(TestataBolla testata) async {
    Database db = await _currentDatabase();
    return await db.transaction((txn) async {
      try {
        await txn.insert('BL_Anag', testata.toJson());
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

  Future<String> initTestataBolleBatch(List<TestataBolla> testate) async {
    Database db = await _currentDatabase();
    return await db.transaction((txn) async {
      try {
        for (TestataBolla testata in testate) {
          await txn.insert('BL_Anag', testata.toJson());
        }
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

  Future<String> initRigheBolle(RigaBolla riga) async {
    Database db = await _currentDatabase();
    return await db.transaction((txn) async {
      try {
        await txn.insert('BL_Artic', riga.toJson());
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

  Future<String> initRigheBolleBatch(List<RigaBolla> righeOrdine) async {
    Database db = await _currentDatabase();
    return await db.transaction((txn) async {
      try {
        for (RigaBolla riga in righeOrdine) {
          await txn.insert('BL_Artic', riga.toJson());
        }
        return 'ok';
      } catch (e) {
        return 'err: $e';
      }
    });
  }

  Future<List<Map<String, dynamic>>> getFatturatoMensilizzato(
      int anno, int mbpcId) async {
    Database db = await _currentDatabase();

    final List<Map<String, dynamic>> map = await db.rawQuery(
        """SELECT substr(FTAN_DataIns,6,2) as Mese, round(CASE WHEN (SUM((FTAR_Prezzo* CASE FTTI_NaturaFattura WHEN     3 THEN -FTAR_Quantita ELSE FTAR_Quantita END)+CASE FTTI_NaturaFattura WHEN 3 THEN FTAR_TotSconti ELSE -FTAR_TotSconti END))  IS NULL
                            THEN 0 ELSE (SUM((FTAR_Prezzo* CASE FTTI_NaturaFattura WHEN 3 THEN -FTAR_Quantita ELSE FTAR_Quantita END)+CASE FTTI_NaturaFattura WHEN 3 THEN FTAR_TotSconti ELSE -FTAR_TotSconti END)) END,2) AS FATT
                        FROM FT_Anagr 
                        JOIN FT_Tipo ON FTTI_Id=FTAN_FTTI_Id 
                        JOIN FT_Artic ON FTAR_FTAN_Id=FTAN_Id 
                        WHERE FTAN_NumFatt>0 
                        AND FTTI_FattureInStatistica<>0
                        AND FTAN_MBPC_ID=$mbpcId
                        AND substr(FTAN_DataIns,0,5)='$anno'                        
                        GROUP BY substr(FTAN_DataIns,6,2)
                        ORDER By substr(FTAN_DataIns,6,2)""");
    //debugdebugPrint(map.toString());
    /* debugPrint(
        'fatturato Mensilizzato di $mbpcId dell\'anno $anno: ${map.toString()}');*/
    return map;
  }

  Future<int> insertTestataOrdine(TestataOrdine testata) async {
    Database db = await _currentDatabase();
    return await db.insert('OC_Anag', testata.toJson());
  }

  Future<int> insertRigaOrdine(RigaOrdine riga) async {
    Database db = await _currentDatabase();
    return await db.insert('OC_Artic', riga.toJson());
  }

  Future<List<Map<String, dynamic>>> getFatturato(int anno, int mbpcId) async {
    Database db = await _currentDatabase();

    final List<Map<String, dynamic>> map = await db.rawQuery(
        """SELECT round(CASE WHEN (SUM((FTAR_Prezzo* CASE FTTI_NaturaFattura WHEN     3 THEN -FTAR_Quantita ELSE FTAR_Quantita END)+CASE FTTI_NaturaFattura WHEN 3 THEN FTAR_TotSconti ELSE -FTAR_TotSconti END))  IS NULL
                            THEN 0 ELSE (SUM((FTAR_Prezzo* CASE FTTI_NaturaFattura WHEN 3 THEN -FTAR_Quantita ELSE FTAR_Quantita END)+CASE FTTI_NaturaFattura WHEN 3 THEN FTAR_TotSconti ELSE -FTAR_TotSconti END)) END,2) AS FATT
                        FROM FT_Anagr 
                        JOIN FT_Tipo ON FTTI_Id=FTAN_FTTI_Id 
                        JOIN FT_Artic ON FTAR_FTAN_Id=FTAN_Id 
                        WHERE FTAN_NumFatt>0 
                        AND FTTI_FattureInStatistica<>0
                        AND FTAN_MBPC_ID=$mbpcId
                        AND substr(FTAN_DataIns,0,5)='$anno'            
                        ORDER By substr(FTAN_DataIns,6,2)""");
    //debugdebugPrint(map.toString());
    //debugPrint('fatturato MEDIO $mbpcId dell\'anno $anno: ${map.toString()}');
    return map;
  }

  Future<List<Map<String, dynamic>>> getOrdinato(int anno, int mbpcId) async {
    Database db = await _currentDatabase();

    final List<Map<String, dynamic>> map = await db.rawQuery(
        """SELECT round(SUM((OCAR_Prezzo*OCAR_Quantita)-OCAR_TotSconti),2)  as ORD     
                        FROM OC_Anag 
                        JOIN OC_Artic ON OCAR_OCAN_Id=OCAN_Id 
                        WHERE OCAN_NumOrd >0 
                        AND OCAN_Stamp = 1 AND OCAN_DataConf IS NOT NULL
                        AND OCAN_MBPC_ID=$mbpcId
                        AND substr(OCAN_DataIns,0,5)='$anno' 
                        """);
    //debugdebugPrint(map.toString());
    debugPrint('Ordinato MEDIO $mbpcId dell\'anno $anno: ${map.toString()}');
    return map;
  }

  Future<List<Map<String, dynamic>>> getOrdini(int anno, int mbpcId) async {
    Database db = await _currentDatabase();

    final List<Map<String, dynamic>> map =
        await db.rawQuery(""" SELECT COUNT(*) as Ordini FROM OC_Anag
                        WHERE OCAN_MBPC_ID=$mbpcId
                        AND substr(OCAN_DataIns,0,5)='$anno'""");
    //debugdebugPrint(map.toString());
    debugPrint('Ordinato MEDIO $mbpcId dell\'anno $anno: ${map.toString()}');
    return map;
  }

  Future<List<Map<String, dynamic>>> getFattureProdotto(
      int prodottoId, int mbpcId) async {
    Database db = await _currentDatabase();
    final List<Map<String, dynamic>> map = await db.rawQuery(
        """ SELECT FTAN_NumFatt , FTAN_DataIns,FTAR_quantita, ftar_quantita*FTAR_prezzo as prezzo, Ftar_prezzo as unitario FROM FT_Artic
JOIN FT_Anagr ON FTAR_FTAN_ID=FTAN_ID
WHERE FTAR_MGAA_ID=$prodottoId AND FTAN_MBPC_ID=$mbpcId AND substr(FTAN_DataIns,1,4)>='${DateTime.now().year - 2}' ORDER BY FTAN_DataIns DESC""");
    //debugdebugPrint(map.toString());
    //debugPrint(map.toString());
    //AND (substr(FTAN_DataIns,0,5)='${DateTime.now().year}' OR substr(FTAN_DataIns,0,5)='${DateTime.now().year - 1}')
    return map;
  }

  Future<List<Map<String, dynamic>>> getProdottiAcquistati(int mbpcId) async {
    Database db = await _currentDatabase();
    final List<Map<String, dynamic>> map =
        await db.rawQuery(""" SELECT DISTINCT FTAR_MGAA_ID FROM FT_Artic
JOIN FT_Anagr ON FTAR_FTAN_ID=FTAN_ID
WHERE FTAN_MBPC_ID=$mbpcId AND substr(FTAN_DataIns,1,4)>='${DateTime.now().year - 2}' ORDER BY FTAN_DataIns DESC""");
    //debugPrint(map.toString());
    //AND (substr(FTAN_DataIns,0,5)='${DateTime.now().year}' OR substr(FTAN_DataIns,0,5)='${DateTime.now().year - 1}')
    return map;
  }

  Future<List<Map<String, dynamic>>> getFatture(int anno, int mbpcId) async {
    Database db = await _currentDatabase();

    final List<Map<String, dynamic>> map =
        await db.rawQuery(""" SELECT COUNT(*) as Fatture FROM FT_Anagr
                        WHERE FTAN_MBPC_ID=$mbpcId
                        AND substr(FTAN_DataIns,1,4)='$anno'""");
    //debugdebugPrint(map.toString());
    debugPrint('Ordinato MEDIO $mbpcId dell\'anno $anno: ${map.toString()}');
    return map;
  }

  Future<String> getTipoBollaDescr(int tipobolla) async {
    Database db = await _currentDatabase();

    final List<Map<String, dynamic>> map =
        await db.rawQuery("""SELECT BLTI_Descr  FROM BL_Tipo 
                              WHERE BLTI_ID=$tipobolla
                              """);
    return map[0]['BLTI_Descr'];
  }

  Future<List<Map<String, dynamic>>> getMessaggiDaInviare() async {
    Database db = await _currentDatabase();
    final List<Map<String, dynamic>> map =
        await db.rawQuery("""SELECT * FROM MessagesToSend
                              """);
    //debugdebugPrint(map.toString());
    //debugPrint('REcupero Messaggi da Inviare: ${map.toString()}');
    return map;
  }

  Future<List<Map<String, dynamic>>> getBolle(int anno, int mbpcId) async {
    Database db = await _currentDatabase();

    final List<Map<String, dynamic>> map =
        await db.rawQuery("""SELECT BLTI_Descr, COUNT(*) AS NumBol FROM BL_Anag
                              LEFT JOIN BL_Tipo ON BLAN_BLTI_ID = BLTI_ID
                              WHERE BLAN_MBPC_ID=$mbpcId       
                              AND substr(BLAN_DataIns,0,5)='$anno'        
                              GROUP BY BLTI_Descr
                              """);
    //debugdebugPrint(map.toString());
    debugPrint('Bolle di $mbpcId dell\'anno $anno: ${map.toString()}');
    return map;
  }

  Future<List<Map<String, dynamic>>> getAgente() async {
    Database db = await _currentDatabase();

    final List<Map<String, dynamic>> map =
        await db.rawQuery("""SELECT MBAN_RagSoc FROM MB_Agenti
                              JOIN SP_Param ON SPPA_MBAG_ID=MBAG_ID
                              """);
    return map;
  }

  Future<int> getIdAgente() async {
    Database db = await _currentDatabase();

    final List<Map<String, dynamic>> map =
        await db.rawQuery("""SELECT SPPA_MBAG_ID FROM SP_Param""");
    return map[0]["SPPA_MBAG_ID"] ?? 0;
  }

  Future<int> getIdTipoConto() async {
    Database db = await _currentDatabase();

    final List<Map<String, dynamic>> map =
        await db.rawQuery("""SELECT SPPA_TipoConto FROM SP_Param""");
    debugPrint(jsonEncode(map));
    return map[0]["SPPA_TipoConto"] ?? 0;
  }

  Future<int> getIdOCTipo() async {
    Database db = await _currentDatabase();

    final List<Map<String, dynamic>> map =
        await db.rawQuery("""SELECT SPPA_OCTI_ID FROM SP_Param""");
    debugPrint(jsonEncode(map));
    return map[0]["SPPA_OCTI_ID"] ?? 0;
  }

  Future<int> getIdFTTipo() async {
    Database db = await _currentDatabase();

    final List<Map<String, dynamic>> map =
        await db.rawQuery("""SELECT SPPA_FTTI_ID FROM SP_Param""");
    debugPrint(jsonEncode(map));
    return map[0]["SPPA_FTTI_ID"] ?? 0;
  }

  Future<int> getIdBLTipo() async {
    Database db = await _currentDatabase();

    final List<Map<String, dynamic>> map =
        await db.rawQuery("""SELECT SPPA_BLTI_ID FROM SP_Param""");
    debugPrint(jsonEncode(map));
    return map[0]["SPPA_BLTI_ID"] ?? 0;
  }

  Future<List<Map<String, dynamic>>> getTestataDocumento(
      int docId, String prefDoc) async {
    debugPrint('docid: $docId, prefDoc: $prefDoc');
    Database db = await _currentDatabase();
    List<Map<String, dynamic>> map;
    switch (prefDoc) {
      case 'OCAN':
        map = await db.rawQuery("""SELECT OCAN_NumOrd,
                                    OCAN_DataIns, MBTP_Descr || ' ' || MBSP_Descr as pagamento,
                                    CASE WHEN OCAN_Destinaz IS NULL THEN OCAN_Destinat ELSE OCAN_Destinaz END AS Dest,
                                    MBPC_Conto || '-' || MBPC_SottoConto as Cod, MBAN_RagSoc, MBAN_Indirizzo, MBAN_Comune, MBAN_PArtitaIVA
                                    FROM OC_Anag 
                              JOIN MB_Anagr ON OCAN_MBPC_ID=MBPC_ID
                              JOIN OC_Pagam  ON OCPG_OCAN_ID=OCAN_ID
                              JOIN MB_TipoPag ON OCPG_MBTP_ID=MBTP_ID
                              JOIN MB_SolPag ON OCPG_MBSP_ID=MBSP_ID
                              WHERE OCAN_ID=$docId""");
        break;
      case 'FTAN':
        map = await db.rawQuery("""SELECT FTAN_NumFatt ,
                                    FTAN_DataIns, MBTP_Descr || ' ' || MBSP_Descr as pagamento,
                                    CASE WHEN FTAN_Destinaz IS NULL THEN FTAN_Destinat ELSE FTAN_Destinaz END AS Dest ,
                                    MBPC_Conto || '-' || MBPC_SottoConto as Cod, MBAN_RagSoc, MBAN_Indirizzo, MBAN_Comune, MBAN_PArtitaIVA
                                    FROM FT_Anagr 
                              JOIN MB_Anagr ON FTAN_MBPC_ID=MBPC_ID
                              JOIN FT_Pagam  ON FTPG_FTAN_ID=FTAN_ID
                              JOIN MB_TipoPag ON FTPG_MBTP_ID=MBTP_ID
                              JOIN MB_SolPag ON FTPG_MBSP_ID=MBSP_ID
                              WHERE FTAN_ID=$docId""");
        break;
      case 'BLAN':
        map = await db.rawQuery("""	SELECT BLAN_NumBol,
                                      BLAN_DataIns, MBTP_Descr || ' ' || MBSP_Descr as pagamento,
                                      BLAN_Destinat AS Dest,
                                      MBPC_Conto || '-' || MBPC_SottoConto as Cod, MBAN_RagSoc, MBAN_Indirizzo, MBAN_Comune, MBAN_PArtitaIVA
                                FROM BL_Anag 
                                JOIN MB_Anagr ON BLAN_MBPC_ID=MBPC_ID
                                JOIN BL_Pagam  ON BLPG_BLAN_ID=BLAN_ID
                                JOIN MB_TipoPag ON BLPG_MBTP_ID=MBTP_ID
                                JOIN MB_SolPag ON BLPG_MBSP_ID=MBSP_ID
                              WHERE BLAN_ID=$docId""");
        break;
      default:
        map = await db.rawQuery("""""");
        break;
    }
    return map;
  }

  Future<List<Map<String, dynamic>>> getRigheDocumento(
      int docId, String prefDoc) async {
    Database db = await _currentDatabase();

    List<Map<String, dynamic>> map;
    switch (prefDoc) {
      case 'OCAN':
        debugPrint('Eseguo OCAN:$docId');
        map = await db.rawQuery("""	SELECT OCAR_NumRiga,
                                    OCAR_MBTA_Codice,
                                    MGAA_Matricola,
                                    OCAR_Quantita,
                                    OCAR_MBUM_Codice,
                                    OCAR_Prezzo,
                                    MBIV_IVA,
                                    OCAR_DescrArt,
                                    OCAR_TotSconti,
                                    OCAR_ScontiFinali,
                                    OCAR_PrezzoListino
                                    FROM OC_Artic
                              JOIN MG_AnaArt ON OCAR_MGAA_ID=MGAA_Id 
                              join MB_IVA ON MGAA_MBIV_ID=MBIV_Id 
                              WHERE OCAR_OCAN_ID=$docId""");
        break;
      case 'FTAN':
        debugPrint('Eseguo FTAN');
        map = await db.rawQuery("""SELECT FTAR_NumRiga,
                                      FTAR_MBTA_Codice,
                                      MGAA_Matricola,
                                      FTAR_Quantita,
                                      FTAR_MBUM_Codice,
                                      FTAR_Prezzo,
                                      MBIV_IVA,
                                      FTAR_Descr,
                                      FTAR_TotSconti,
                                      FTAR_ScontiFinali
                                      FROM FT_Artic 
                                  JOIN MG_AnaArt ON FTAR_MGAA_ID=MGAA_Id 
                                  join MB_IVA ON MGAA_MBIV_ID=MBIV_Id 
                                  WHERE FTAR_FTAN_ID=$docId""");
        break;
      case 'BLAN':
        debugPrint('Eseguo BLAN');
        map = await db.rawQuery("""SELECT BLAR_NumRiga,
                                      BLAR_MBTA_Codice,
                                      MGAA_Matricola,
                                      BLAR_Quantita,
                                      BLAR_MBUM_Codice,
                                      BLAR_Prezzo,
                                      MBIV_IVA,
                                      BLAR_DescrArt,
                                      BLAR_TotSconti,
                                      BLAR_ScontiFinali
                                      FROM BL_Artic fa 
                                JOIN MG_AnaArt ON BLAR_MGAA_ID=MGAA_Id 
                                join MB_IVA ON MGAA_MBIV_ID=MBIV_Id 
                              WHERE BLAR_BLAN_ID=$docId""");
        break;
      default:
        debugPrint('Eseguo DEFAULT');
        map = await db.rawQuery("""	SELECT 1""");
        break;
    }
    return map;
  }

  Future<List<Map<String, dynamic>>> getDocumenti(
      String tipo, String numDoc, String data, int mbpcId) async {
    debugPrint(mbpcId.toString());
    Database db = await _currentDatabase();
    String tipoPrefix = '';
    String mbpcIdAnd = '';
    String mbpcIdAndGenerale = '';
    String dataFormattata =
        DateFormat('yyyy-MM-dd').format(DateTime.parse(data));
    debugPrint('data: $dataFormattata');
    String numDocAnd = ' AND 1 = 1 ';
    List<Map<String, dynamic>> map = [];

    int? numDocConv = int.tryParse(numDoc);

    switch (tipo) {
      case '':
        if (numDocConv != null) {
          numDocAnd = ' AND NUM_DOC=$numDocConv ';
        }
        break;
      case 'Ordine':
        tipoPrefix = 'OC';
        if (numDocConv != null) {
          numDocAnd = ' AND OCAN_NumOrd=$numDocConv ';
        }
        break;
      case 'Bolla':
        tipoPrefix = 'BL';
        if (numDocConv != null) {
          numDocAnd = ' AND BLAN_NumBol=$numDocConv ';
        }
        break;
      case 'Fattura':
        tipoPrefix = 'FT';
        if (numDocConv != null) {
          numDocAnd = ' AND FTAN_NumFatt=$numDocConv ';
        }
        break;
      default:
        break;
    }

    if (mbpcId == 0) {
      mbpcIdAnd = ' AND 1=1 ';
    } else {
      mbpcIdAnd = ' AND ${tipoPrefix}AN_MBPC_ID=$mbpcId ';
      mbpcIdAndGenerale = """ AND t1.ID_CLIENTE=$mbpcId""";
      debugPrint('mbpcid AND:' + mbpcIdAnd);
    }

    String queryOrdini =
        """SELECT 'OCAN' as PREF_DOC, OCTI_Descr as 'TIPO_DOC',OCAN_MBPC_ID as 'ID_CLIENTE', OCAN_ID AS 'ID_DOC', OCAN_NumOrd as 'NUM_DOC', OCAN_DataIns AS 'DATA_DOC', 
              CASE (OCAN_Evaso+(10*OCAN_ParzEvaso)+(100*OCAN_EvasoForz)) WHEN 0 THEN 'Non evaso' WHEN 1 THEN 'Evaso' WHEN 10 THEN 'Parz. evaso' WHEN 100 THEN 'Forz. evaso' WHEN 101 THEN 'Forz. evaso' WHEN 110 THEN 'Forz. evaso' END as 'STATO_DOC'
              FROM OC_Anag  
              JOIN OC_Tipo ON OCTI_ID=OCAN_OCTI_Id 
              WHERE 1=1 $mbpcIdAnd AND OCAN_DataIns>='$dataFormattata' $numDocAnd ORDER BY OCAN_DataIns DESC""";
    debugPrint('queryOrdini:' + queryOrdini);
    String queryFatture =
        """ SELECT 'FTAN' as PREF_DOC, FTTI_Descr as 'TIPO_DOC',FTAN_MBPC_ID as 'ID_CLIENTE', FTAN_ID AS 'ID_DOC', FTAN_NumFatt as 'NUM_DOC', FTAN_DataIns AS 'DATA_DOC', 
              CASE WHEN FTAN_Contab = 1 THEN 'Contabilizzata' ELSE 
                CASE WHEN FTAN_Scaric = 1 THEN 'Scaricata' ELSE
                  CASE  WHEN FTAN_Stamp = 1 THEN 'Stampata' ELSE 'Inserita'
                  END
                END
              END as 'STATO_DOC'
              FROM FT_Anagr
              JOIN FT_Tipo ON FTTI_ID=FTAN_FTTI_Id 
              WHERE 1=1 $mbpcIdAnd AND FTAN_DataIns>='$dataFormattata' $numDocAnd ORDER BY FTAN_DataIns DESC""";
    debugPrint('queryFatture:' + queryFatture);
    String queryBolle =
        """SELECT 'BLAN' as PREF_DOC, BLTI_Descr as 'TIPO_DOC',BLAN_MBPC_ID as 'ID_CLIENTE' , BLAN_Id as 'ID_DOC', BLAN_NumBol AS 'NUM_DOC', BLAN_DataIns as 'DATA_DOC', 
              CASE WHEN BLAN_Scaric = 1 THEN 'Scaricata' ELSE 
                CASE WHEN BLAN_Stamp = 1 THEN 'Stampata' ELSE 'Inserita' 
                END 
              END as 'STATO_DOC' 
              FROM BL_Anag  
              JOIN BL_tipo ON BLTI_ID=BLAN_BLTI_ID
              WHERE 1=1 $mbpcIdAnd AND BLAN_DataIns>='$dataFormattata' $numDocAnd ORDER BY BLAN_DataIns DESC""";
    String queryGenerale = """SELECT 1""";
    switch (tipo) {
      case '':
        //map = await db.rawQuery(queryGenerale);
        break;
      case 'Ordine':
        map = await db.rawQuery(queryOrdini);
        break;
      case 'Bolla':
        map = await db.rawQuery(queryBolle);
        break;
      case 'Fattura':
        map = await db.rawQuery(queryFatture);
        break;
      default:
        break;
    }
    return map;
  }

  Future<bool> recordExists(
      String tableName, String whereClause, List<dynamic> whereArgs) async {
    final db = await _currentDatabase(); // Ottieni l'istanza Database

    try {
      debugPrint(
          'recordExists: tableName=$tableName, whereClause=$whereClause, whereArgs=$whereArgs');
      final List<Map<String, dynamic>> result = await db.query(
        tableName,
        columns: [
          '1'
        ], // Puoi selezionare una qualsiasi colonna perché serve solo a verificare l'esistenza.
        where: whereClause,
        whereArgs: whereArgs,
        limit: 1,
      );

      // Se il risultato ha almeno un record, il record esiste
      return result.isNotEmpty;
    } catch (e) {
      debugPrint('Errore nella verifica dell\'esistenza del record: $e');
      return false;
    }
  }
}
