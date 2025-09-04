# YES+
Applicazione Mobile per integrazione gestionale YES

# Indice

* [Installazione APP](#Installazione-APP)
* [Installazione Server](#Installazione-Server)
* [Preparazione DB](#Preparazione-DB)


## Installazione APP

passaggi per l'installazione dell'app

## Installazione Server

## Preparazione DB 
* [Abilitazione SP_OACreate](#SP_OACreate)
* [Creazione Tabelle](#Creare-le-tabelle-necessarie)
	- [Z_APP_dispositivi](#Z_APP_dispositivi)
 	- [Z_APP_Messaggi](#Z_APP_Messaggi)
  	- [Z_APP_aggiorna_dispositivi](#Z_APP_aggiorna_dispositivi)
  	- [Z_APP_AG_DI](#Z_APP_AG_DI)
  	- [Z_APP_LOG](#Z_APP_LOG)
  	- [Z_APP_Info](#Z_APP_Info)
  	- [Z_PrezziTV](#Z_PrezziTV)
  	- [ENABLE/DISABLE Trigger](#ed_Trigger)
* [Modifiche Tabelle Esistenti](#Modifiche-Tabelle-Esistenti)

* ### Abilitazione SP_OACreate
<a name="SP_OACreate"></a>
   	- Abilitare nel databse le funziona avanzate per effettuare la chiamata alle api.
```
sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
sp_configure 'Ole Automation Procedures', 1;
GO
RECONFIGURE;
GO
```

* ### Creare le tabelle necessarie
	<a name="Z_APP_dispositivi"></a>
	- La tabella **Z_APP_dispositivi** salva l'associazione id tablet con parametri salvati sul dispositivo, quali Agente, Tipo Ordine, Tipo Fattura, Tipo Bolla, Tipo Conto...
   	Inoltre alla connessione e alla disconnessione del dispositivo aggiorna lo stato in connesso/disconnesso.  	
```
/****** Object:  Table [dbo].[Z_APP_dispositivi]    Script Date: 11/13/2024 16:42:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[Z_APP_dispositivi](
	[ZAPPD_ID] [int] IDENTITY(0,1) NOT NULL,
	[ZAPPD_device_id] [varchar](255) NULL,
	[ZAPPD_stato] [varchar](100) NOT NULL,
	[ZAPPD_ultimaConnessione] [datetime] NULL,
	[ZAPPD_imei] [varchar](255) NULL,
	[ZAPPD_OCTI_ID] [int] NULL,
	[ZAPPD_FTTI_ID] [int] NULL,
	[ZAPPD_BLTI_ID1] [int] NULL,
	[ZAPPD_BLTI_ID2] [int] NULL,
	[ZAPPD_MBTC_ID] [int] NULL,
	[ZAPPD_Init_Status] [int] NOT NULL,
	[ZAPPD_MBAG_ID] [int] NULL,
 CONSTRAINT [Z_APP_dispositivi_PK] PRIMARY KEY CLUSTERED 
(
	[ZAPPD_ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[Z_APP_dispositivi] ADD  DEFAULT ((0)) FOR [ZAPPD_Init_Status]
GO
```
<a name="Z_APP_Messaggi"></a>
- Nella tabella **Z_APP_Messaggi** vengono salvati quei messaggi che i trigger o le procedure non riescono, per qualche motivo, ad inviare al server, quindi quando la chiamata `http://indirizzo/trigger` risponde `ko`

```
/****** Object:  Table [dbo].[Z_APP_Messaggi]    Script Date: 11/13/2024 16:43:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[Z_APP_Messaggi](
	[ZAPP_ID] [int] IDENTITY(0,1) NOT NULL,
	[ZAPP_Messaggio] [varchar](8000) NOT NULL,
	[ZAPP_DataCreate] [datetime] NOT NULL,
	[ZAPP_DataEsec] [datetime] NULL,
 CONSTRAINT [Z_APP_Messaggi_PK] PRIMARY KEY CLUSTERED 
(
	[ZAPP_ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[Z_APP_Messaggi] ADD  DEFAULT (getdate()) FOR [ZAPP_DataCreate]
GO

ALTER TABLE [dbo].[Z_APP_Messaggi] ADD  DEFAULT (NULL) FOR [ZAPP_DataEsec]
GO
```

<a name="Z_APP_aggiorna_dispositivi"></a>
- Nella tabella **Z_APP_aggiorna_dispositivi** vengono inseriti i messaggi inviati dai trigger e dalle procedure, prima di essere smistati ai dispositivi.

```
/****** Object:  Table [dbo].[Z_APP_aggiorna_dispositivi]    Script Date: 11/13/2024 16:41:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[Z_APP_aggiorna_dispositivi](
	[ZAPPAD_ID] [int] IDENTITY(0,1) NOT NULL,
	[ZAPPAD_messaggio] [varchar](max) NOT NULL,
	[ZAPPAD_creato] [datetime] NULL,
 CONSTRAINT [Z_APP_aggiorna_dispositivi_PK] PRIMARY KEY CLUSTERED 
(
	[ZAPPAD_ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[Z_APP_aggiorna_dispositivi] ADD  CONSTRAINT [DF__Z_APP_agg__ZAPPA__54575AEB]  DEFAULT (getdate()) FOR [ZAPPAD_creato]
GO
```

<a name="Z_APP_AG_DI"></a>
- Nella tabella **Z_APP_AG_DI** vengono inserite le relazioni tra la tabella `Z_APP_aggiorna_dispositivi` e la tabella `Z_APP_dispositivi`, quindi il messaggio salvato sulla tabella `Z_APP_Messaggi` viene ripetuto e associato ad ogni dispositivo necessario. Se la tabella da aggiornare è una di quelle per cui ci sono i parametri nella tabella `Z_APP_aggiorna_dispositivi` allora verra inserita una riga solo per i dispositivi per cui l'aggiornamento è effettivamente diretto, altrimenti viene inserita una riga per ogni dispositivo.

```
/****** Object:  Table [dbo].[Z_APP_AG_DI]    Script Date: 11/13/2024 16:40:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Z_APP_AG_DI](
	[ZAPPRAD_ID] [int] IDENTITY(0,1) NOT NULL,
	[ZAPPRAD_AGDI_ID] [int] NULL,
	[ZAPPRAD_DISP_ID] [int] NULL,
	[ZAPPRAD_DataIns] [datetime] NULL,
	[ZAPPRAD_DataEsec] [datetime] NULL,
	[ZAPPRAD_Stato] [int] NULL,
	[ZAPPRAD_DebugFlag] [bit] NULL,
	[ZAPPRAD_Locked] [bit] NULL,
 CONSTRAINT [Z_APP_AG_DI_PK] PRIMARY KEY CLUSTERED 
(
	[ZAPPRAD_ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[Z_APP_AG_DI] ADD  DEFAULT (getdate()) FOR [ZAPPRAD_DataIns]
GO

ALTER TABLE [dbo].[Z_APP_AG_DI] ADD  DEFAULT ((0)) FOR [ZAPPRAD_Stato]
GO

ALTER TABLE [dbo].[Z_APP_AG_DI] ADD  DEFAULT ((0)) FOR [ZAPPRAD_DebugFlag]
GO
```

<a name="Z_APP_LOG"></a>
- Nella tabella **Z_APP_LOG** vengono salvati i log delle esecuzioni di trigger e procedure

```
/****** Object:  Table [dbo].[Z_APP_LOG]    Script Date: 11/13/2024 16:43:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[Z_APP_LOG](
	[ZALO_ID] [int] IDENTITY(1,1) NOT NULL,
	[ZALO_Messaggio] [varchar](max) NULL,
	[ZALO_provenienza] [varchar](50) NULL,
	[ZALO_DataIns] [datetime] NULL,
 CONSTRAINT [PK_Z_APP_LOG] PRIMARY KEY CLUSTERED 
(
	[ZALO_ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[Z_APP_LOG] ADD  CONSTRAINT [DF_Z_APP_LOG_ZALO_DataIns]  DEFAULT (getdate()) FOR [ZALO_DataIns]
GO
```
<a name="Z_APP_Info"></a>
- Nella tabella **Z_APP_Info** sono salvate info varie dell'app, al momento l'unica info necessaria è l'indirizzo del server API a cui inviare la richiesta `/trigger` dalle procedure e dai trigger

```
/****** Object:  Table [dbo].[Z_APP_Info]    Script Date: 11/13/2024 16:44:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[Z_APP_Info](
	[ZIAP_ID] [int] NOT NULL,
	[ZIAP_IndirizzoServer] [varchar](100) NULL,
 CONSTRAINT [Z_APP_Info_PK] PRIMARY KEY CLUSTERED 
(
	[ZIAP_ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO
```
<a name="Z_PrezziTV"></a>
- Nella tabella **Z_PrezziTV** vengono salvate da una stored programmata tutte le combinazioni di Prodotti - Prezzi e Sconti generici e per cliente.

```
CREATE TABLE dbo.Z_PrezziTV
	(
	ZPTV_Id int NOT NULL IDENTITY (1, 1),
	ZPTV_MGAA_Id int NOT NULL,
	ZPTV_MBPC_Id int NULL,
	ZPTV_Prezzo decimal(28, 15) NOT NULL,
	ZPTV_Sconto1 decimal(28, 15) NULL,
	ZPTV_Sconto2 decimal(28, 15) NULL,
	ZPTV_Sconto3 decimal(28, 15) NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.Z_PrezziTV ADD CONSTRAINT
	PK_Z_PrezziTV PRIMARY KEY CLUSTERED 
	(
	ZPTV_Id
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
```
* ### Modifiche Tabelle Esistenti
	- Modificare le tabelle aggiungendo il campo XXXX_APP_ID
```
      ALTER TABLE FT_Anag
  ADD FTAN_APP_ID VARCHAR(50);
  
    ALTER TABLE BL_Anag
  ADD BLAN_APP_ID VARCHAR(50);
  
    ALTER TABLE FT_Artic
  ADD FTAR_APP_ID VARCHAR(50);
  
    ALTER TABLE BL_Artic
  ADD BLAR_APP_ID VARCHAR(50);
  
    ALTER TABLE OC_Anag
  ADD OCAN_APP_ID VARCHAR(50);
  
    ALTER TABLE OC_Artic
  ADD OCAR_APP_ID VARCHAR(50);
```

* Inserire nella tabella Z_APP_info l'indirizzo del server API con la chiamata **/trigger**
```
INSERT INTO [dbo].[Z_APP_Info]
           ([ZIAP_ID]
           ,[ZIAP_IndirizzoServer])
     VALUES
           (0
           ,'HTTP://127.0.0.1:5000/trigger')
GO
```

* Creare le procedure per l'aggiornamento di Ordini/Bolle/Fatture Inserite da YES e l'aggiornamento serale dei prezzi
  * **Aggiornamento Prezzi**
```
CREATE PROCEDURE Z_AggiornaPrzTV
AS
DELETE FROM Z_PrezziTV WHERE ZPTV_Id IN
(
	SELECT ZPTV_Id FROM Z_PrezziTV
	LEFT JOIN 
	(
		SELECT LVAR_ID,LVAR_MGAA_Id,LVAN_MBPC_Id,LVAR_Prezzo,(SELECT LVSC_Perc FROM LV_Sconti WHERE LVSC_LVAR_Id=LVAR_Id AND LVSC_NumOrd=1) AS SC1,
		(SELECT LVSC_Perc FROM LV_Sconti WHERE LVSC_LVAR_Id=LVAR_Id AND LVSC_NumOrd=2) AS SC2,
		(SELECT LVSC_Perc FROM LV_Sconti WHERE LVSC_LVAR_Id=LVAR_Id AND LVSC_NumOrd=3) AS SC3  
		FROM LV_Anagr JOIN LV_Arti ON LVAN_Id=LVAR_LVAN_Id 
		WHERE ISNULL(LVAN_DtValDa,'19000101')<=dbo.Date_TruncateTime(GETDATE())
		AND ISNULL(LVAN_DtValA,'20790101')>=dbo.Date_TruncateTime(GETDATE()) 
	) T ON LVAR_MGAA_Id=ZPTV_MGAA_Id AND ISNULL(LVAN_MBPC_Id,0)=ISNULL(ZPTV_MBPC_Id,0)
	AND ZPTV_Prezzo=LVAR_Prezzo AND ISNULL(SC1,0.0)=ISNULL(ZPTV_Sconto1,0.0)
	AND ISNULL(SC2,0.0)=ISNULL(ZPTV_Sconto2,0.0)
	AND ISNULL(SC3,0.0)=ISNULL(ZPTV_Sconto3,0.0)
	WHERE LVAR_Id IS NULL
)



INSERT INTO Z_PrezziTV(ZPTV_MGAA_Id,ZPTV_MBPC_Id,ZPTV_Prezzo,ZPTV_Sconto1,ZPTV_Sconto2,ZPTV_Sconto3)
SELECT LVAR_MGAA_Id,LVAN_MBPC_Id,LVAR_Prezzo,SC1,SC2,SC3 FROM
(
	SELECT LVAR_MGAA_Id,LVAN_MBPC_Id,LVAR_Prezzo,(SELECT LVSC_Perc FROM LV_Sconti WHERE LVSC_LVAR_Id=LVAR_Id AND LVSC_NumOrd=1) AS SC1,
	(SELECT LVSC_Perc FROM LV_Sconti WHERE LVSC_LVAR_Id=LVAR_Id AND LVSC_NumOrd=2) AS SC2,
	(SELECT LVSC_Perc FROM LV_Sconti WHERE LVSC_LVAR_Id=LVAR_Id AND LVSC_NumOrd=3) AS SC3  
	FROM LV_Anagr JOIN LV_Arti ON LVAN_Id=LVAR_LVAN_Id 
	WHERE ISNULL(LVAN_DtValDa,'19000101')<=dbo.Date_TruncateTime(GETDATE())
	AND ISNULL(LVAN_DtValA,'20790101')>=dbo.Date_TruncateTime(GETDATE()) 
) T	
LEFT JOIN Z_PrezziTV ON LVAR_MGAA_Id=ZPTV_MGAA_Id AND ISNULL(LVAN_MBPC_Id,0)=ISNULL(ZPTV_MBPC_Id,0)
	AND ZPTV_Prezzo=LVAR_Prezzo AND ISNULL(SC1,0.0)=ISNULL(ZPTV_Sconto1,0.0)
	AND ISNULL(SC2,0.0)=ISNULL(ZPTV_Sconto2,0.0)
	AND ISNULL(SC3,0.0)=ISNULL(ZPTV_Sconto3,0.0) WHERE ZPTV_Id IS NULL
```  
  * **Ordini**
```
/****** Object:  StoredProcedure [dbo].[Z_APP_OC_Anag]    Script Date: 11/13/2024 16:48:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Z_APP_OC_Anag]
    @OCAN INT,
    @CLOSE INT,
    @MSG VARCHAR(1024) OUTPUT,
    @LOCK INT OUTPUT
AS
BEGIN
   IF @CLOSE=1
    BEGIN
		PRINT 'ESEGUO PROCEDURA OC_Anag';
		SET @MSG = 'ESEGUO PROCEDURA OC_Anag: ' + CAST(ISNULL(@OCAN, 0) AS VARCHAR) + ' - CLOSE (0-salvataggio | 1-chiusura): '+CAST(ISNULL(@CLOSE, 0) AS VARCHAR);
		INSERT INTO Z_APP_LOG (ZALO_Messaggio, ZALO_Provenienza) VALUES (@MSG,'Procedura: Z_APP_OC_Anag');
		SET NOCOUNT ON;

		DECLARE @URL NVARCHAR(MAX);
		SELECT @URL =  ZIAP_IndirizzoServer FROM Z_APP_info;

		DECLARE @Object AS INT;
		DECLARE @ResponseText AS VARCHAR(8000);
		DECLARE @OperationType VARCHAR(10) = 'ORDINE';
		DECLARE @OCAN_NumOrd AS VARCHAR(50);
		DECLARE @OCAN_OCTI_Id AS INT;
		DECLARE @OCAN_AnnoOrd AS INT;
		DECLARE @OCAN_DataIns AS SMALLDATETIME;
		DECLARE @OCAN_MBPC_Id AS INT;	
		DECLARE @OCAN_TotOrdine AS DECIMAL(18,2);
		DECLARE @OCAN_Dest_MBAN_Id AS INT;
		DECLARE @OCAN_Desz_MBAN_Id AS INT;
		DECLARE @OCAN_APP_ID AS INT;
		DECLARE @OCAN_ID AS INT;
		DECLARE @OCAN_Confermato AS BIT;
		DECLARE @OCAN_Evaso AS INT;
        DECLARE @OCAN_ParzEvaso AS INT;
        DECLARE @OCAN_EvasoForz AS INT;
        	    
		DECLARE @OCAR_Id AS INT;
		DECLARE @OCAR_OCAN_Id AS INT;
		DECLARE @OCAR_NumRiga AS FLOAT;
		DECLARE @OCAR_MGAA_Id AS INT;
		DECLARE @OCAR_Quantita AS DECIMAL(18,2);
		DECLARE @OCAR_MBUM_Codice AS CHAR(10);
		DECLARE @OCAR_DescrArt AS CHAR(50);
		DECLARE @OCAR_Prezzo AS DECIMAL(18,2);
		DECLARE @OCAR_TotSconti AS DECIMAL(18,2);
		DECLARE @OCAR_ScontiFinali AS DECIMAL(18,2);
		DECLARE @OCAR_PrezzoListino AS DECIMAL(18,2);
		DECLARE @OCAR_DQTA AS DECIMAL(18,2);
		DECLARE @OCAR_EForz AS SMALLINT;
		DECLARE @OCAR_MBTA_Codice AS SMALLINT;
		DECLARE @OCAR_APP_ID AS VARCHAR(100);


		DECLARE @OCPG_ID as INT;
		DECLARE @OCPG_OCAN_ID as INT;
   		DECLARE @OCPG_MBTP_ID as INT;
		DECLARE @OCPG_MBSP_ID as INT;
	    
		SELECT 
			@OCAN_ID = OCAN_Id,
			@OCAN_NumOrd = OCAN_NumOrd,
			@OCAN_OCTI_Id = OCAN_OCTI_Id,
			@OCAN_AnnoOrd = OCAN_AnnoOrd,
			@OCAN_DataIns = OCAN_DataIns,
			@OCAN_MBPC_Id = OCAN_MBPC_Id,
			@OCAN_TotOrdine = OCAN_TotOrdine,
			@OCAN_Dest_MBAN_Id = OCAN_Dest_MBAN_Id,
			@OCAN_Desz_MBAN_Id = OCAN_Desz_MBAN_Id,
			@OCAN_APP_ID = OCAN_APP_ID,
			@OCAN_Confermato = OCAN_Confermato,
			@OCAN_Evaso = OCAN_Evaso,
			@OCAN_ParzEvaso = OCAN_ParzEvaso,
			@OCAN_EvasoForz = OCAN_EvasoForz
		FROM OC_Anag
		WHERE OCAN_ID = @OCAN;

		-- Solo se il record Ë stato trovato
		IF @OCAN_ID IS NOT NULL
		BEGIN
			-- Creazione del messaggio JSON
			DECLARE @body AS NVARCHAR(MAX) = '{
			   "QUERY":"PROC",
			   "TABLE":"OC_Anag",
			   "DATA":{
					"OCAN_ID": "' + CAST(ISNULL(@OCAN_ID, 0) AS VARCHAR) + '",
					"OCAN_APP_ID":"' + CAST(ISNULL(@OCAN_APP_ID, '') AS VARCHAR) + '",
					"OCAN_NumOrd": "' + ISNULL(@OCAN_NumOrd, '') + '",
					"OCAN_OCTI_Id": "' + CAST(ISNULL(@OCAN_OCTI_Id, 0) AS VARCHAR) + '",
					"OCAN_AnnoOrd": "' + CAST(ISNULL(@OCAN_AnnoOrd, 0) AS VARCHAR) + '",
					"OCAN_DataIns": "' + ISNULL(CONVERT(VARCHAR, @OCAN_DataIns,120), '') + '",
					"OCAN_MBPC_Id": "' + CAST(ISNULL(@OCAN_MBPC_Id, 0) AS VARCHAR) + '",
					"OCAN_TotOrdine": "' + CAST(ISNULL(@OCAN_TotOrdine, 0) AS VARCHAR) + '",
					"OCAN_Dest_MBAN_Id": "' + CAST(ISNULL(@OCAN_Dest_MBAN_Id, 0) AS VARCHAR) + '",
					"OCAN_Desz_MBAN_Id": "' + CAST(ISNULL(@OCAN_Desz_MBAN_Id, 0) AS VARCHAR) + '",
					"OCAN_Confermato": "' + CAST(ISNULL(@OCAN_Confermato, 0) AS VARCHAR) + '",
					"OCAN_Evaso": "' + CAST(ISNULL(@OCAN_Evaso, 0) AS VARCHAR) + '",
					"OCAN_ParzEvaso": "' + CAST(ISNULL(@OCAN_ParzEvaso, 0) AS VARCHAR) + '",
					"OCAN_EvasoForz": "' + CAST(ISNULL(@OCAN_EvasoForz, 0) AS VARCHAR) + '"
				}
			}';

			-- Esecuzione della chiamata HTTP POST
			EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;
			EXEC sp_OAMethod @Object, 'open', NULL, 'post', @URL, 'false';
			EXEC sp_OAMethod @Object, 'setRequestHeader', NULL, 'Content-Type', 'application/json';
			EXEC sp_OAMethod @Object, 'send', NULL, @body;
			EXEC sp_OAMethod @Object, 'responseText', @ResponseText OUTPUT;

			PRINT @ResponseText;

			-- Gestione degli errori nella risposta
			IF CHARINDEX('ko', @ResponseText) > 0
			BEGIN
				INSERT INTO Z_APP_LOG (ZALO_Messaggio, ZALO_Provenienza) VALUES (@body, 'Procedura: Z_APP_OC_Anag');
				INSERT INTO Z_APP_LOG (ZALO_Messaggio, ZALO_Provenienza) VALUES ('Risposta SP_OACreate: ' + @ResponseText, 'Procedura: Z_APP_OC_Anag');
				INSERT INTO dbo.Z_APP_Messaggi (ZAPP_Messaggio) VALUES (@body);		
			END
		    
			-- Distruzione dell'oggetto COM
			IF @Object IS NOT NULL
			BEGIN
				EXEC sp_OADestroy @Object;
			END
		END
	    
	    
		DECLARE cursore_righe CURSOR FOR 
		SELECT OCAR_Id, OCAR_OCAN_Id, OCAR_NumRiga, OCAR_MGAA_Id, OCAR_Quantita, OCAR_MBUM_Codice, OCAR_Prezzo, 
				OCAR_TotSconti, OCAR_ScontiFinali, OCAR_PrezzoListino, OCAR_DQTA, OCAR_EForz, OCAR_MBTA_Codice, OCAR_APP_ID, OCAR_DescrArt
			FROM OC_Artic
		WHERE OCAR_OCAN_ID = @OCAN;
	    
		OPEN cursore_righe;
		FETCH NEXT FROM cursore_righe INTO 
			@OCAR_Id, @OCAR_OCAN_Id, @OCAR_NumRiga, @OCAR_MGAA_Id, @OCAR_Quantita, @OCAR_MBUM_Codice, @OCAR_Prezzo, 
			@OCAR_TotSconti, @OCAR_ScontiFinali, @OCAR_PrezzoListino, @OCAR_DQTA, @OCAR_EForz, @OCAR_MBTA_Codice, @OCAR_APP_ID,@OCAR_DescrArt;

		WHILE @@FETCH_STATUS = 0
		BEGIN
			DECLARE @bodyRighe AS NVARCHAR(MAX) ='{
							"QUERY":"PROC",
							"TABLE":"OC_Artic",
							"DATA":{
								"OCAR_Id": "' + CAST(ISNULL(@OCAR_Id, 0) AS VARCHAR) + '",
								"OCAR_OCAN_Id": "' + CAST(ISNULL(@OCAR_OCAN_Id, 0) AS VARCHAR) + '",
								"OCAR_NumRiga": "' + CAST(ISNULL(@OCAR_NumRiga, 0) AS VARCHAR) + '",
								"OCAR_MGAA_Id": "' + CAST(ISNULL(@OCAR_MGAA_Id, 0) AS VARCHAR) + '",
								"OCAR_Quantita": "' + CAST(ISNULL(@OCAR_Quantita, 0) AS VARCHAR) + '",
								"OCAR_MBUM_Codice": "' + ISNULL(@OCAR_MBUM_Codice, '') + '",
								"OCAR_Prezzo": "' + CAST(ISNULL(@OCAR_Prezzo, 0) AS VARCHAR) + '",
								"OCAR_TotSconti": "' + CAST(ISNULL(@OCAR_TotSconti, 0) AS VARCHAR) + '",
								"OCAR_ScontiFinali": "' + CAST(ISNULL(@OCAR_ScontiFinali, 0) AS VARCHAR) + '",
								"OCAR_PrezzoListino": "' + CAST(ISNULL(@OCAR_PrezzoListino, 0) AS VARCHAR) + '",
								"OCAR_DQTA": "' + CAST(ISNULL(@OCAR_DQTA, 0) AS VARCHAR) + '",
								"OCAR_EForz": "' + CAST(ISNULL(@OCAR_EForz, 0) AS VARCHAR) + '",
								"OCAR_MBTA_Codice": "' + CAST(ISNULL(@OCAR_MBTA_Codice, 0) AS VARCHAR) + '",
								"OCAR_APP_ID": "' + ISNULL(@OCAR_APP_ID, '') + '",
								"OCAR_DescrArt": "' + ISNULL(@OCAR_DescrArt, '') + '"
							}
						}';
			 -- Chiamata HTTP POST
			EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;
			EXEC sp_OAMethod @Object, 'open', NULL, 'post', @URL, 'false';
			EXEC sp_OAMethod @Object, 'setRequestHeader', NULL, 'Content-Type', 'application/json';
			EXEC sp_OAMethod @Object, 'send', NULL, @bodyRighe;
			EXEC sp_OAMethod @Object, 'responseText', @ResponseText OUTPUT;

			PRINT @ResponseText;

			IF CHARINDEX('ko', (SELECT @ResponseText)) > 0
			BEGIN
			INSERT INTO Z_APP_LOG (ZALO_Messaggio, ZALO_Provenienza) VALUES (@bodyRighe,'Procedura: Z_APP_OC_Anag');
			INSERT INTO Z_APP_LOG (ZALO_Messaggio, ZALO_Provenienza) VALUES ('Risposta SP_OACreate: '+@ResponseText,'Procedura: Z_APP_OC_Anag');
				INSERT INTO dbo.Z_APP_Messaggi
						(ZAPP_Messaggio)
						VALUES('{
							"QUERY":"PROC",
							"TABLE":"OC_Artic",
							"DATA":{
								"OCAR_Id": "' + CAST(ISNULL(@OCAR_Id, 0) AS VARCHAR) + '",
								"OCAR_OCAN_Id": "' + CAST(ISNULL(@OCAR_OCAN_Id, 0) AS VARCHAR) + '",
								"OCAR_NumRiga": "' + CAST(ISNULL(@OCAR_NumRiga, 0) AS VARCHAR) + '",
								"OCAR_MGAA_Id": "' + CAST(ISNULL(@OCAR_MGAA_Id, 0) AS VARCHAR) + '",
								"OCAR_Quantita": "' + CAST(ISNULL(@OCAR_Quantita, 0) AS VARCHAR) + '",
								"OCAR_MBUM_Codice": "' + ISNULL(@OCAR_MBUM_Codice, '') + '",
								"OCAR_Prezzo": "' + CAST(ISNULL(@OCAR_Prezzo, 0) AS VARCHAR) + '",
								"OCAR_TotSconti": "' + CAST(ISNULL(@OCAR_TotSconti, 0) AS VARCHAR) + '",
								"OCAR_ScontiFinali": "' + CAST(ISNULL(@OCAR_ScontiFinali, 0) AS VARCHAR) + '",
								"OCAR_PrezzoListino": "' + CAST(ISNULL(@OCAR_PrezzoListino, 0) AS VARCHAR) + '",
								"OCAR_DQTA": "' + CAST(ISNULL(@OCAR_DQTA, 0) AS VARCHAR) + '",
								"OCAR_EForz": "' + CAST(ISNULL(@OCAR_EForz, 0) AS VARCHAR) + '",
								"OCAR_MBTA_Codice": "' + CAST(ISNULL(@OCAR_MBTA_Codice, 0) AS VARCHAR) + '",
								"OCAR_APP_ID": "' + ISNULL(@OCAR_APP_ID, '') + '",
								"OCAR_DescrArt": "' + ISNULL(@OCAR_DescrArt, '') + '"
							}
						}');
			END
			
			EXEC sp_OADestroy @Object;
			FETCH NEXT FROM cursore_righe INTO 
				@OCAR_Id, @OCAR_OCAN_Id, @OCAR_NumRiga, @OCAR_MGAA_Id, @OCAR_Quantita, @OCAR_MBUM_Codice, @OCAR_Prezzo, 
				@OCAR_TotSconti, @OCAR_ScontiFinali, @OCAR_PrezzoListino, @OCAR_DQTA, @OCAR_EForz, @OCAR_MBTA_Codice, @OCAR_APP_ID,@OCAR_DescrArt;
	        
		END
		CLOSE cursore_righe;
		DEALLOCATE cursore_righe;
	    

		DECLARE cursore_pagam CURSOR FOR 
		SELECT OCPG_ID, OCPG_OCAN_ID, OCPG_MBTP_ID,OCPG_MBSP_ID FROM OC_Pagam WHERE OCPG_OCAN_ID=@OCAN;
	    
		OPEN cursore_pagam;
		FETCH NEXT FROM cursore_pagam INTO 
         @OCPG_ID, @OCPG_OCAN_ID, @OCPG_MBTP_ID, @OCPG_MBSP_ID;
         
         WHILE @@FETCH_STATUS = 0
         BEGIN
			DECLARE @body_pagam AS VARCHAR(8000) = '{
	           "QUERY":"PROC",
	           "TABLE":"OC_Pagam",
	           "DATA":{
	                "OCPG_ID": "' + CAST(ISNULL(@OCPG_ID, 0) AS VARCHAR) + '",
	                "OCPG_OCAN_ID": "' + CAST(ISNULL(@OCPG_OCAN_ID, 0) AS VARCHAR) + '",
					"OCPG_MBTP_ID": "' + CAST(ISNULL(@OCPG_MBTP_ID, 0) AS VARCHAR) + '",				
	                "OCPG_MBSP_ID": "' + CAST(ISNULL(@OCPG_MBSP_ID, 0) AS VARCHAR) +'"
	            }
	        }' -- JSON body for HTTP POST similar to the first trigger
		
	        EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;
	        EXEC sp_OAMethod @Object, 'open', NULL, 'post', @URL, 'false';
	        EXEC sp_OAMethod @Object, 'setRequestHeader', NULL, 'Content-Type', 'application/json';
	        EXEC sp_OAMethod @Object, 'send', NULL, @body_pagam;
	        EXEC sp_OAMethod @Object, 'responseText', @ResponseText OUTPUT;
	        
	        PRINT @ResponseText;
	        
	        IF CHARINDEX('ko',(SELECT @ResponseText)) > 0
			BEGIN
				INSERT INTO Z_APP_LOG (ZALO_Messaggio, ZALO_Provenienza) VALUES (@body_pagam,'Procedura: Z_APP_OC_Anag');
				INSERT INTO Z_APP_LOG (ZALO_Messaggio, ZALO_Provenienza) VALUES ('Risposta SP_OACreate: '+@ResponseText,'Procedura: Z_APP_OC_Anag');
				INSERT INTO dbo.Z_APP_Messaggi
					(ZAPP_Messaggio)
					VALUES('{
					   "QUERY":"' + @OperationType + '",
					   "TABLE":"OC_Pagam",
					   "DATA":{
							"OCPG_ID": "' + CAST(ISNULL(@OCPG_ID, 0) AS VARCHAR) + '",
							"OCPG_OCAN_ID": "' + CAST(ISNULL(@OCPG_OCAN_ID, 0) AS VARCHAR) + '",
							"OCPG_MBTP_ID": "' + CAST(ISNULL(@OCPG_MBTP_ID, 0) AS VARCHAR) + '",				
							"OCPG_MBSP_ID": "' + CAST(ISNULL(@OCPG_MBSP_ID, 0) AS VARCHAR) +'"
						}
					}');
			END
			
			EXEC sp_OADestroy @Object
					
			FETCH NEXT FROM cursore_pagam INTO 
				@OCPG_ID, @OCPG_OCAN_ID, @OCPG_MBTP_ID, @OCPG_MBSP_ID;
		END
		CLOSE cursore_pagam;
		DEALLOCATE cursore_pagam;
		
		IF @Object IS NOT NULL
		BEGIN
			EXEC sp_OADestroy @Object;
		END
   END
END;
```
* **Bolle**
```

CREATE PROCEDURE [dbo].[Z_APP_BL_Anag]
    @BLAN INT,
    @CLOSE INT,
    @MSG VARCHAR(1024) OUTPUT,
    @LOCK INT OUTPUT
AS
BEGIN
    IF @CLOSE = 1
    BEGIN
        PRINT 'ESEGUO PROCEDURA BL_Anag';
        SET @MSG = 'ESEGUO PROCEDURA BL_Anag: ' + CAST(ISNULL(@BLAN, 0) AS VARCHAR) + ' - CLOSE (0-salvataggio | 1-chiusura): ' + CAST(ISNULL(@CLOSE, 0) AS VARCHAR);
        INSERT INTO Z_APP_LOG (ZALO_Messaggio, ZALO_Provenienza) VALUES (@MSG, 'Procedura: Z_APP_BL_Anag');
        SET NOCOUNT ON;

        DECLARE @URL NVARCHAR(MAX);
        SELECT @URL = ZIAP_IndirizzoServer FROM Z_APP_info;

        DECLARE @Object AS INT;
        DECLARE @ResponseText AS VARCHAR(8000);
        DECLARE @OperationType VARCHAR(10) = 'BOLLA';

        -- Variabili per la prima tabella (BL_Anag)
        DECLARE @BLAN_ID AS INT;
        DECLARE @BLAN_BLTI_ID AS INT;
        DECLARE @BLAN_AnnoBol AS INT;
        DECLARE @BLAN_NumBol AS VARCHAR(50);
        DECLARE @BLAN_DataIns AS DATETIME;
        DECLARE @BLAN_MBPC_ID AS INT;
        DECLARE @BLAN_Stamp AS INT;
        DECLARE @BLAN_Scaric AS INT;
        DECLARE @BLAN_Valor AS INT;
        DECLARE @BLAN_Destinat AS VARCHAR(1000);
        DECLARE @BLAN_TotBolla AS DECIMAL(18,2);
        DECLARE @BLAN_Dest_MBAN_ID AS INT;
        DECLARE @BLAN_DataCreate AS SMALLDATETIME;
        DECLARE @BLAN_APP_ID AS VARCHAR(50);

        -- Variabili per la seconda tabella (BL_Artic)
        DECLARE @BLAR_ID AS INT;
        DECLARE @BLAR_BLAN_ID AS INT;
        DECLARE @BLAR_NumRiga AS INT;
        DECLARE @BLAR_MBTA_Codice AS INT;
        DECLARE @BLAR_MGAA_ID AS INT;
        DECLARE @BLAR_Quantita AS INT;
        DECLARE @BLAR_MBUM_Codice AS VARCHAR(10);
        DECLARE @BLAR_Prezzo AS DECIMAL(18,2);
        DECLARE @BLAR_DescrArt AS VARCHAR(100);
        DECLARE @BLAR_TotSconti AS DECIMAL(18,2);
        DECLARE @BLAR_ScontiFinali AS DECIMAL(18,2);
        DECLARE @BLAR_DQTA AS DECIMAL(18,2);
        DECLARE @BLAR_APP_ID AS VARCHAR(50);

        -- Variabili per la terza tabella (BL_Pagam)
        DECLARE @BLPG_ID AS INT;
        DECLARE @BLPG_BLAN_ID AS INT;
        DECLARE @BLPG_MBTP_ID AS INT;
        DECLARE @BLPG_MBSP_ID AS INT;

        -- Selezione dei dati della prima tabella (BL_Anag)
        SELECT 
            @BLAN_ID = BLAN_ID,
            @BLAN_BLTI_ID = BLAN_BLTI_ID,
            @BLAN_AnnoBol = BLAN_AnnoBol,
            @BLAN_NumBol = BLAN_NumBol,
            @BLAN_DataIns = BLAN_DataIns,
            @BLAN_MBPC_ID = BLAN_MBPC_ID,
            @BLAN_Stamp = BLAN_Stamp,
            @BLAN_Scaric = BLAN_Scaric,
            @BLAN_Valor = BLAN_Valor,
            @BLAN_Destinat = BLAN_Destinat,
            @BLAN_TotBolla = CAST(BLAN_TotBolla AS DECIMAL(18,2)),
            @BLAN_Dest_MBAN_ID = BLAN_Dest_MBAN_ID,
            @BLAN_DataCreate = BLAN_DataCreate
        FROM BL_Anag
        WHERE BLAN_ID = @BLAN;

        -- Solo se il record Ë stato trovato
        IF @BLAN_ID IS NOT NULL
        BEGIN
            -- Pulizia dei campi testo
            SET @BLAN_Destinat = REPLACE(REPLACE(REPLACE(@BLAN_Destinat, CHAR(10), ''), CHAR(13), ''), CHAR(9), '');

            -- Creazione del messaggio JSON
            DECLARE @body AS NVARCHAR(MAX) = '{
                "QUERY":"PROC",
                "TABLE":"BL_Anag",
                "DATA":{
                    "BLAN_ID": "' + CAST(ISNULL(@BLAN_ID, 0) AS VARCHAR) + '",
                    "BLAN_BLTI_ID": "' + CAST(ISNULL(@BLAN_BLTI_ID, 0) AS VARCHAR) + '",
                    "BLAN_AnnoBol": "' + CAST(ISNULL(@BLAN_AnnoBol, 0) AS VARCHAR) + '",
                    "BLAN_NumBol": "' + ISNULL(@BLAN_NumBol, '') + '",
                    "BLAN_DataIns": "' + ISNULL(CONVERT(VARCHAR, @BLAN_DataIns, 120), '') + '",
                    "BLAN_MBPC_ID": "' + CAST(ISNULL(@BLAN_MBPC_ID, 0) AS VARCHAR) + '",
                    "BLAN_Stamp": "' + CAST(ISNULL(@BLAN_Stamp, 0) AS VARCHAR) + '",
                    "BLAN_Scaric": "' + CAST(ISNULL(@BLAN_Scaric, 0) AS VARCHAR) + '",
                    "BLAN_Valor": "' + CAST(ISNULL(@BLAN_Valor, 0) AS VARCHAR) + '",
                    "BLAN_Destinat": "' + ISNULL(@BLAN_Destinat, '') + '",
                    "BLAN_TotBolla": "' + CAST(ISNULL(@BLAN_TotBolla, 0) AS VARCHAR) + '",
                    "BLAN_Dest_MBAN_ID": "' + CAST(ISNULL(@BLAN_Dest_MBAN_ID, 0) AS VARCHAR) + '",
                    "BLAN_DataCreate": "' + ISNULL(CONVERT(VARCHAR, @BLAN_DataCreate, 120), '') + '"
                }
            }';

            -- Log del messaggio JSON
            INSERT INTO Z_APP_LOG (ZALO_Messaggio, ZALO_Provenienza) VALUES (@body, 'Procedura: Z_APP_BL_Anag');

            -- Esecuzione della chiamata HTTP POST
            EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;
            EXEC sp_OAMethod @Object, 'open', NULL, 'post', @URL, 'false';
            EXEC sp_OAMethod @Object, 'setRequestHeader', NULL, 'Content-Type', 'application/json';
            EXEC sp_OAMethod @Object, 'send', NULL, @body;
            EXEC sp_OAMethod @Object, 'responseText', @ResponseText OUTPUT;

            PRINT @ResponseText;

            -- Gestione degli errori nella risposta
            IF CHARINDEX('ko', @ResponseText) > 0
            BEGIN
                INSERT INTO Z_APP_LOG (ZALO_Messaggio, ZALO_Provenienza) VALUES (@body, 'Procedura: Z_APP_BL_Anag');
                INSERT INTO Z_APP_LOG (ZALO_Messaggio, ZALO_Provenienza) VALUES ('Risposta SP_OACreate: ' + @ResponseText, 'Procedura: Z_APP_BL_Anag');
                INSERT INTO dbo.Z_APP_Messaggi (ZAPP_Messaggio) VALUES (@body);        
            END
            
            -- Distruzione dell'oggetto COM
            IF @Object IS NOT NULL
            BEGIN
                EXEC sp_OADestroy @Object;
            END
        END

        -- Selezione dei dati della seconda tabella (BL_Artic)
        DECLARE cursore_righe CURSOR FOR 
        SELECT BLAR_ID, BLAR_BLAN_ID, BLAR_NumRiga, BLAR_MBTA_Codice, BLAR_MGAA_ID, 
               BLAR_Quantita, BLAR_MBUM_Codice, BLAR_Prezzo, BLAR_DescrArt, 
               BLAR_TotSconti, BLAR_ScontiFinali, BLAR_DQTA
        FROM BL_Artic
        WHERE BLAR_BLAN_ID = @BLAN;

        OPEN cursore_righe;
        FETCH NEXT FROM cursore_righe INTO 
            @BLAR_ID, @BLAR_BLAN_ID, @BLAR_NumRiga, @BLAR_MBTA_Codice, @BLAR_MGAA_ID, 
            @BLAR_Quantita, @BLAR_MBUM_Codice, @BLAR_Prezzo, @BLAR_DescrArt, 
            @BLAR_TotSconti, @BLAR_ScontiFinali, @BLAR_DQTA;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            DECLARE @bodyRighe AS NVARCHAR(MAX) = '{
                "QUERY":"PROC",
                "TABLE":"BL_Artic",
                "DATA":{
                    "BLAR_ID": "' + CAST(ISNULL(@BLAR_ID, 0) AS VARCHAR) + '",
                    "BLAR_BLAN_ID": "' + CAST(ISNULL(@BLAR_BLAN_ID, 0) AS VARCHAR) + '",
                    "BLAR_NumRiga": "' + CAST(ISNULL(@BLAR_NumRiga, 0) AS VARCHAR) + '",
                    "BLAR_MBTA_Codice": "' + CAST(ISNULL(@BLAR_MBTA_Codice, 0) AS VARCHAR) + '",
                    "BLAR_MGAA_ID": "' + CAST(ISNULL(@BLAR_MGAA_ID, 0) AS VARCHAR) + '",
                    "BLAR_Quantita": "' + CAST(ISNULL(@BLAR_Quantita, 0) AS VARCHAR) + '",
                    "BLAR_MBUM_Codice": "' + ISNULL(@BLAR_MBUM_Codice, '') + '",
                    "BLAR_Prezzo": "' + CAST(ISNULL(@BLAR_Prezzo, 0) AS VARCHAR) + '",
                    "BLAR_DescrArt": "' + ISNULL(@BLAR_DescrArt, '') + '",
                    "BLAR_TotSconti": "' + CAST(ISNULL(@BLAR_TotSconti, 0) AS VARCHAR) + '",
                    "BLAR_ScontiFinali": "' + CAST(ISNULL(@BLAR_ScontiFinali, 0) AS VARCHAR) + '",
                    "BLAR_DQTA": "' + CAST(ISNULL(@BLAR_DQTA, 0) AS VARCHAR) + '"
                }
            }';

            -- Invio della richiesta HTTP POST per BL_Artic
            EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;
            EXEC sp_OAMethod @Object, 'open', NULL, 'post', @URL, 'false';
            EXEC sp_OAMethod @Object, 'setRequestHeader', NULL, 'Content-Type', 'application/json';
            EXEC sp_OAMethod @Object, 'send', NULL, @bodyRighe;
            EXEC sp_OAMethod @Object, 'responseText', @ResponseText OUTPUT;

            PRINT @ResponseText;

            IF CHARINDEX('ko', @ResponseText) > 0
            BEGIN
                INSERT INTO Z_APP_LOG (ZALO_Messaggio, ZALO_Provenienza) VALUES (@bodyRighe, 'Procedura: Z_APP_BL_Anag');
                INSERT INTO Z_APP_LOG (ZALO_Messaggio, ZALO_Provenienza) VALUES ('Risposta SP_OACreate: ' + @ResponseText, 'Procedura: Z_APP_BL_Anag');
                INSERT INTO dbo.Z_APP_Messaggi (ZAPP_Messaggio) VALUES (@bodyRighe);
            END

            EXEC sp_OADestroy @Object;

            FETCH NEXT FROM cursore_righe INTO 
                @BLAR_ID, @BLAR_BLAN_ID, @BLAR_NumRiga, @BLAR_MBTA_Codice, @BLAR_MGAA_ID, 
                @BLAR_Quantita, @BLAR_MBUM_Codice, @BLAR_Prezzo, @BLAR_DescrArt, 
                @BLAR_TotSconti, @BLAR_ScontiFinali, @BLAR_DQTA;
        END
        CLOSE cursore_righe;
        DEALLOCATE cursore_righe;

        -- Selezione dei dati della terza tabella (BL_Pagam)
        DECLARE cursore_pagam CURSOR FOR 
        SELECT BLPG_ID, BLPG_BLAN_ID, BLPG_MBTP_ID, BLPG_MBSP_ID 
        FROM BL_Pagam 
        WHERE BLPG_BLAN_ID = @BLAN;
        
        OPEN cursore_pagam;
        FETCH NEXT FROM cursore_pagam INTO 
            @BLPG_ID, @BLPG_BLAN_ID, @BLPG_MBTP_ID, @BLPG_MBSP_ID;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            DECLARE @body_pagam AS NVARCHAR(MAX) = '{
                "QUERY":"PROC",
                "TABLE":"BL_Pagam",
                "DATA":{
                    "BLPG_ID": "' + CAST(ISNULL(@BLPG_ID, 0) AS VARCHAR) + '",
                    "BLPG_BLAN_ID": "' + CAST(ISNULL(@BLPG_BLAN_ID, 0) AS VARCHAR) + '",
                    "BLPG_MBTP_ID": "' + CAST(ISNULL(@BLPG_MBTP_ID, 0) AS VARCHAR) + '",
                    "BLPG_MBSP_ID": "' + CAST(ISNULL(@BLPG_MBSP_ID, 0) AS VARCHAR) + '"
                }
            }';

            EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;
            EXEC sp_OAMethod @Object, 'open', NULL, 'post', @URL, 'false';
            EXEC sp_OAMethod @Object, 'setRequestHeader', NULL, 'Content-Type', 'application/json';
            EXEC sp_OAMethod @Object, 'send', NULL, @body_pagam;
            EXEC sp_OAMethod @Object, 'responseText', @ResponseText OUTPUT;

            PRINT @ResponseText;

            IF CHARINDEX('ko', @ResponseText) > 0
            BEGIN
                INSERT INTO Z_APP_LOG (ZALO_Messaggio, ZALO_Provenienza) VALUES (@body_pagam, 'Procedura: Z_APP_BL_Anag');
                INSERT INTO Z_APP_LOG (ZALO_Messaggio, ZALO_Provenienza) VALUES ('Risposta SP_OACreate: ' + @ResponseText, 'Procedura: Z_APP_BL_Anag');
                INSERT INTO dbo.Z_APP_Messaggi (ZAPP_Messaggio) VALUES (@body_pagam);
            END

            EXEC sp_OADestroy @Object;

            FETCH NEXT FROM cursore_pagam INTO 
                @BLPG_ID, @BLPG_BLAN_ID, @BLPG_MBTP_ID, @BLPG_MBSP_ID;
        END
        CLOSE cursore_pagam;
        DEALLOCATE cursore_pagam;

        IF @Object IS NOT NULL
        BEGIN
            EXEC sp_OADestroy @Object;
        END
    END
END;
GO
```

* **Fatture**
```
/****** Object:  StoredProcedure [dbo].[Z_APP_FT_Anag]    Script Date: 11/13/2024 10:03:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Z_APP_FT_Anag]
    @FTAN INT,
    @CLOSE INT,
    @MSG VARCHAR(1024) OUTPUT,
    @LOCK INT OUTPUT
AS
BEGIN
    IF @CLOSE = 1
    BEGIN
        PRINT 'ESEGUO PROCEDURA FT_Anag';
        SET @MSG = 'ESEGUO PROCEDURA FT_Anag: ' + CAST(ISNULL(@FTAN, 0) AS VARCHAR) + ' - CLOSE (0-salvataggio | 1-chiusura): ' + CAST(ISNULL(@CLOSE, 0) AS VARCHAR);
        INSERT INTO Z_APP_LOG (ZALO_Messaggio, ZALO_Provenienza) VALUES (@MSG, 'Procedura: Z_APP_FT_Anag');
        SET NOCOUNT ON;

        DECLARE @URL NVARCHAR(MAX);
        SELECT @URL = ZIAP_IndirizzoServer FROM Z_APP_info;

        DECLARE @Object AS INT;
        DECLARE @ResponseText AS VARCHAR(8000);
        DECLARE @OperationType VARCHAR(10) = 'FATTURA';
        
        -- Variabili per la prima tabella (FT_Anag)
        DECLARE @FTAN_ID AS INT;
        DECLARE @FTAN_AnnoFatt AS INT;
        DECLARE @FTAN_FTTI_ID AS INT;
        DECLARE @FTAN_NumFatt AS VARCHAR(50);
        DECLARE @FTAN_DataIns AS DATETIME;
        DECLARE @FTAN_MBPC_ID AS INT;
        DECLARE @FTAN_Stamp AS INT;
        DECLARE @FTAN_Contab AS INT;
        DECLARE @FTAN_Scaric AS INT;
        DECLARE @FTAN_TotFattura AS DECIMAL(18,2);
        DECLARE @FTAN_Spese AS DECIMAL(18,2);
        DECLARE @FTAN_DataCreate AS SMALLDATETIME;
        DECLARE @FTAN_Destinat AS VARCHAR(1000);
        DECLARE @FTAN_Destinaz AS VARCHAR(1000);
        DECLARE @FTAN_APP_ID AS VARCHAR(50);

        -- Variabili per la seconda tabella (FT_Artic)
        DECLARE @FTAR_ID AS INT;
        DECLARE @FTAR_FTAN_ID AS INT;
        DECLARE @FTAR_NumRiga AS INT;
        DECLARE @FTAR_MGAA_ID AS INT;
        DECLARE @FTAR_MBTA_Codice AS INT;
        DECLARE @FTAR_Descr AS VARCHAR(100);
        DECLARE @FTAR_Quantita AS DECIMAL(18,2);
        DECLARE @FTAR_MBUM_Codice AS VARCHAR(10);
        DECLARE @FTAR_Prezzo AS DECIMAL(18,2);
        DECLARE @FTAR_TotSconti AS DECIMAL(18,2);
        DECLARE @FTAR_ScontiFinali AS DECIMAL(18,2);
        DECLARE @FTAR_Note AS VARCHAR(8000);
        DECLARE @FTAR_DQTA AS INT;
        DECLARE @FTAR_RivalsaIva AS INT;
        DECLARE @FTAR_APP_ID AS VARCHAR(100);

        -- Variabili per la terza tabella (FT_Pagam)
        DECLARE @FTPG_ID AS INT;
        DECLARE @FTPG_FTAN_ID AS INT;
        DECLARE @FTPG_MBTP_ID AS INT;
        DECLARE @FTPG_MBSP_ID AS INT;

        -- Selezione dei dati della prima tabella (FT_Anag)
        SELECT 
            @FTAN_ID = FTAN_ID,
            @FTAN_AnnoFatt = FTAN_AnnoFatt,
            @FTAN_FTTI_ID = FTAN_FTTI_ID,
            @FTAN_NumFatt = FTAN_NumFatt,
            @FTAN_DataIns = FTAN_DataIns,
            @FTAN_MBPC_ID = FTAN_MBPC_ID,
            @FTAN_Stamp = FTAN_Stamp,
            @FTAN_Contab = FTAN_Contab,
            @FTAN_Scaric = FTAN_Scaric,
            @FTAN_TotFattura = FTAN_TotFattura,
            @FTAN_Spese = FTAN_Spese,
            @FTAN_DataCreate = FTAN_DataCreate,
            @FTAN_Destinat = FTAN_Destinat,
            @FTAN_Destinaz = FTAN_Destinaz,
            @FTAN_APP_ID = FTAN_APP_ID
        FROM FT_Anag
        WHERE FTAN_ID = @FTAN;

        -- Solo se il record Ë stato trovato
        IF @FTAN_ID IS NOT NULL
        BEGIN
        SET @FTAN_Destinat = REPLACE(REPLACE(REPLACE(@FTAN_Destinat, CHAR(10), ''), CHAR(13), ''), CHAR(9), '');
		SET @FTAN_Destinaz = REPLACE(REPLACE(REPLACE(@FTAN_Destinaz, CHAR(10), ''), CHAR(13), ''), CHAR(9), '');
        INSERT INTO Z_APP_LOG (ZALO_Messaggio, ZALO_Provenienza) VALUES ('FTAN_ID IS NOT NULL URL: '+@URL, 'Procedura: Z_APP_FT_Anag');
            -- Creazione del messaggio JSON
            DECLARE @body AS NVARCHAR(MAX) = '{
               "QUERY":"PROC",
               "TABLE":"FT_Anagr",
               "DATA":{
                    "FTAN_ID": "' + CAST(ISNULL(@FTAN_ID, 0) AS VARCHAR) + '",
                    "FTAN_AnnoFatt": "' + CAST(ISNULL(@FTAN_AnnoFatt, 0) AS VARCHAR) + '",
                    "FTAN_FTTI_ID": "' + CAST(ISNULL(@FTAN_FTTI_ID, 0) AS VARCHAR) + '",
                    "FTAN_NumFatt": "' + ISNULL(@FTAN_NumFatt, '') + '",
                    "FTAN_DataIns": "' + ISNULL(CONVERT(VARCHAR, @FTAN_DataIns,120), '') + '",
                    "FTAN_MBPC_ID": "' + CAST(ISNULL(@FTAN_MBPC_ID, 0) AS VARCHAR) + '",
                    "FTAN_Stamp": "' + CAST(ISNULL(@FTAN_Stamp, 0) AS VARCHAR) + '",
                    "FTAN_Contab": "' + CAST(ISNULL(@FTAN_Contab, 0) AS VARCHAR) + '",
                    "FTAN_Scaric": "' + CAST(ISNULL(@FTAN_Scaric, 0) AS VARCHAR) + '",
                    "FTAN_TotFattura": "' + CAST(ISNULL(@FTAN_TotFattura, 0) AS VARCHAR) + '",
                    "FTAN_Spese": "' + CAST(ISNULL(@FTAN_Spese, 0) AS VARCHAR) + '",
                    "FTAN_DataCreate": "' + ISNULL(CONVERT(VARCHAR, @FTAN_DataCreate,120), '') + '",
                    "FTAN_Destinat": "' + ISNULL(@FTAN_Destinat, '') + '",
                    "FTAN_Destinaz": "' + ISNULL(@FTAN_Destinaz, '') + '",
                    "FTAN_APP_ID": "' +CAST(ISNULL(@FTAN_APP_ID, 0) AS VARCHAR) + '"
                }
            }';
            
            INSERT INTO Z_APP_LOG (ZALO_Messaggio, ZALO_Provenienza) VALUES (@body, 'Procedura: Z_APP_FT_Anag');

            -- Esecuzione della chiamata HTTP POST
            EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;
            EXEC sp_OAMethod @Object, 'open', NULL, 'post', @URL, 'false';
            EXEC sp_OAMethod @Object, 'setRequestHeader', NULL, 'Content-Type', 'application/json';
            EXEC sp_OAMethod @Object, 'send', NULL, @body;
            EXEC sp_OAMethod @Object, 'responseText', @ResponseText OUTPUT;

            PRINT @ResponseText;
             INSERT INTO Z_APP_LOG (ZALO_Messaggio, ZALO_Provenienza) VALUES ('response text: '+@ResponseText, 'Procedura: Z_APP_FT_Anag');

            -- Gestione degli errori nella risposta
            IF CHARINDEX('ko', @ResponseText) > 0
            BEGIN
                INSERT INTO Z_APP_LOG (ZALO_Messaggio, ZALO_Provenienza) VALUES (@body, 'Procedura: Z_APP_FT_Anag');
                INSERT INTO Z_APP_LOG (ZALO_Messaggio, ZALO_Provenienza) VALUES ('Risposta SP_OACreate: ' + @ResponseText, 'Procedura: Z_APP_FT_Anag');
                INSERT INTO dbo.Z_APP_Messaggi (ZAPP_Messaggio) VALUES (@body);        
            END
            
            -- Distruzione dell'oggetto COM
            IF @Object IS NOT NULL
            BEGIN
                EXEC sp_OADestroy @Object;
            END
        END
        
        -- Selezione dei dati della seconda tabella (FT_Artic)
        DECLARE cursore_righe CURSOR FOR 
        SELECT FTAR_ID, FTAR_FTAN_ID, FTAR_NumRiga, FTAR_MGAA_ID, FTAR_MBTA_Codice, FTAR_Descr, 
               FTAR_Quantita, FTAR_MBUM_Codice, FTAR_Prezzo, FTAR_TotSconti, FTAR_ScontiFinali, 
               FTAR_Note, FTAR_DQTA, FTAR_RivalsaIva, FTAR_APP_ID
        FROM FT_Artic
        WHERE FTAR_FTAN_ID = @FTAN;

        OPEN cursore_righe;
        FETCH NEXT FROM cursore_righe INTO 
            @FTAR_ID, @FTAR_FTAN_ID, @FTAR_NumRiga, @FTAR_MGAA_ID, @FTAR_MBTA_Codice, @FTAR_Descr, 
            @FTAR_Quantita, @FTAR_MBUM_Codice, @FTAR_Prezzo, @FTAR_TotSconti, @FTAR_ScontiFinali, 
            @FTAR_Note, @FTAR_DQTA, @FTAR_RivalsaIva, @FTAR_APP_ID;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            DECLARE @bodyRighe AS NVARCHAR(MAX) = '{
                "QUERY":"PROC",
                "TABLE":"FT_Artic",
                "DATA":{
                    "FTAR_ID": "' + CAST(ISNULL(@FTAR_ID, 0) AS VARCHAR) + '",
                    "FTAR_FTAN_Id": "' + CAST(ISNULL(@FTAR_FTAN_ID, 0) AS VARCHAR) + '",
                    "FTAR_NumRiga": "' + CAST(ISNULL(@FTAR_NumRiga, 0) AS VARCHAR) + '",
                    "FTAR_MGAA_ID": "' + CAST(ISNULL(@FTAR_MGAA_ID, 0) AS VARCHAR) + '",
                    "FTAR_MBTA_Codice": "' + CAST(ISNULL(@FTAR_MBTA_Codice, 0) AS VARCHAR) + '",
                    "FTAR_Descr": "' + ISNULL(@FTAR_Descr, '') + '",
                    "FTAR_Quantita": "' + CAST(ISNULL(@FTAR_Quantita, 0) AS VARCHAR) + '",
                    "FTAR_MBUM_Codice": "' + ISNULL(@FTAR_MBUM_Codice, '') + '",
                    "FTAR_Prezzo": "' + CAST(ISNULL(@FTAR_Prezzo, 0) AS VARCHAR) + '",
                    "FTAR_TotSconti": "' + CAST(ISNULL(@FTAR_TotSconti, 0) AS VARCHAR) + '",
                    "FTAR_ScontiFinali": "' + CAST(ISNULL(@FTAR_ScontiFinali, 0) AS VARCHAR) + '",
                    "FTAR_Note": "' + ISNULL(@FTAR_Note, '') + '",
                    "FTAR_DQTA": "' + CAST(ISNULL(@FTAR_DQTA, 0) AS VARCHAR) + '",
                    "FTAR_RivalsaIva": "' + CAST(ISNULL(@FTAR_RivalsaIva, 0) AS VARCHAR) + '",
                    "FTAR_APP_ID": "' + ISNULL(@FTAR_APP_ID, '') + '"
                }
            }';

            -- Invio della richiesta HTTP POST per FT_Artic
            EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;
            EXEC sp_OAMethod @Object, 'open', NULL, 'post', @URL, 'false';
            EXEC sp_OAMethod @Object, 'setRequestHeader', NULL, 'Content-Type', 'application/json';
            EXEC sp_OAMethod @Object, 'send', NULL, @bodyRighe;
            EXEC sp_OAMethod @Object, 'responseText', @ResponseText OUTPUT;

            PRINT @ResponseText;

            IF CHARINDEX('ko', @ResponseText) > 0
            BEGIN
                INSERT INTO Z_APP_LOG (ZALO_Messaggio, ZALO_Provenienza) VALUES (@bodyRighe, 'Procedura: Z_APP_FT_Anag');
                INSERT INTO Z_APP_LOG (ZALO_Messaggio, ZALO_Provenienza) VALUES ('Risposta SP_OACreate: ' + @ResponseText, 'Procedura: Z_APP_FT_Anag');
                INSERT INTO dbo.Z_APP_Messaggi (ZAPP_Messaggio) VALUES (@bodyRighe);
            END

            EXEC sp_OADestroy @Object;

            FETCH NEXT FROM cursore_righe INTO 
                @FTAR_ID, @FTAR_FTAN_ID, @FTAR_NumRiga, @FTAR_MGAA_ID, @FTAR_MBTA_Codice, @FTAR_Descr, 
                @FTAR_Quantita, @FTAR_MBUM_Codice, @FTAR_Prezzo, @FTAR_TotSconti, @FTAR_ScontiFinali, 
                @FTAR_Note, @FTAR_DQTA, @FTAR_RivalsaIva, @FTAR_APP_ID;
        END
        CLOSE cursore_righe;
        DEALLOCATE cursore_righe;

        -- Selezione dei dati della terza tabella (FT_Pagam)
        DECLARE cursore_pagam CURSOR FOR 
        SELECT FTPG_ID, FTPG_FTAN_ID, FTPG_MBTP_ID, FTPG_MBSP_ID 
        FROM FT_Pagam 
        WHERE FTPG_FTAN_ID = @FTAN;
        
        OPEN cursore_pagam;
        FETCH NEXT FROM cursore_pagam INTO 
            @FTPG_ID, @FTPG_FTAN_ID, @FTPG_MBTP_ID, @FTPG_MBSP_ID;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            DECLARE @body_pagam AS VARCHAR(8000) = '{
                "QUERY":"PROC",
                "TABLE":"FT_Pagam",
                "DATA":{
                    "FTPG_ID": "' + CAST(ISNULL(@FTPG_ID, 0) AS VARCHAR) + '",
                    "FTPG_FTAN_ID": "' + CAST(ISNULL(@FTPG_FTAN_ID, 0) AS VARCHAR) + '",
                    "FTPG_MBTP_ID": "' + CAST(ISNULL(@FTPG_MBTP_ID, 0) AS VARCHAR) + '",
                    "FTPG_MBSP_ID": "' + CAST(ISNULL(@FTPG_MBSP_ID, 0) AS VARCHAR) + '"
                }
            }';

            EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;
            EXEC sp_OAMethod @Object, 'open', NULL, 'post', @URL, 'false';
            EXEC sp_OAMethod @Object, 'setRequestHeader', NULL, 'Content-Type', 'application/json';
            EXEC sp_OAMethod @Object, 'send', NULL, @body_pagam;
            EXEC sp_OAMethod @Object, 'responseText', @ResponseText OUTPUT;

            PRINT @ResponseText;

            IF CHARINDEX('ko', @ResponseText) > 0
            BEGIN
                INSERT INTO Z_APP_LOG (ZALO_Messaggio, ZALO_Provenienza) VALUES (@body_pagam, 'Procedura: Z_APP_FT_Anag');
                INSERT INTO Z_APP_LOG (ZALO_Messaggio, ZALO_Provenienza) VALUES ('Risposta SP_OACreate: ' + @ResponseText, 'Procedura: Z_APP_FT_Anag');
                INSERT INTO dbo.Z_APP_Messaggi (ZAPP_Messaggio) VALUES (@body_pagam);
            END

            EXEC sp_OADestroy @Object;

            FETCH NEXT FROM cursore_pagam INTO 
                @FTPG_ID, @FTPG_FTAN_ID, @FTPG_MBTP_ID, @FTPG_MBSP_ID;
        END
        CLOSE cursore_pagam;
        DEALLOCATE cursore_pagam;

        IF @Object IS NOT NULL
        BEGIN
            EXEC sp_OADestroy @Object;
        END
    END
END;
```
* Creare I trigger per la cancellazione di Ordini/Bolle/Fatture da YES
  * Ordini
```
/****** Object:  Trigger [dbo].[Z_APP_TR_OC_Anag]    Script Date: 11/13/2024 16:53:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--DROP TRIGGER  [dbo].[Z_APP_OC_Anag];
CREATE TRIGGER [dbo].[Z_APP_TR_OC_Anag] 
ON [dbo].[OC_Anag]
AFTER DELETE
AS
DECLARE @URL NVARCHAR(MAX);
SELECT @URL =  ZIAP_IndirizzoServer FROM Z_APP_info;
DECLARE @body AS VARCHAR(MAX);
DECLARE @OCAN_ID AS INT;
DECLARE @OCAN_OCTI_ID AS INT;
DECLARE @Object AS INT;
DECLARE @ResponseText AS VARCHAR(8000);
BEGIN
		IF EXISTS (SELECT * FROM Z_APP_dispositivi
			WHERE ZAPPD_OCTI_ID IN (SELECT OCAN_OCTI_ID FROM deleted)
			)
		BEGIN
			SET @OCAN_ID= (SELECT OCAN_ID FROM deleted);
			SET @OCAN_OCTI_ID=(SELECT OCAN_OCTI_ID FROM deleted);
			INSERT INTO Z_APP_LOG (ZALO_Messaggio, ZALO_Provenienza) VALUES ('ESEGUO TRIGGER DELETE OC_Anag: '+CAST(ISNULL(@OCAN_ID, 0) AS VARCHAR),'TRIGGER: Z_APP_TR_OC_Anag');
			SET @body  = '{
			   "QUERY":"DELETE",
			   "TABLE":"OC_Anag",
			   "DATA":{
					"OCAN_ID": "' + CAST(ISNULL(@OCAN_ID, 0) AS VARCHAR) + '",
					"OCAN_OCTI_Id": "' + CAST(ISNULL(@OCAN_OCTI_ID, 0) AS VARCHAR) + '"
				}
			}';
			
			
			
			EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;
			EXEC sp_OAMethod @Object, 'open', NULL, 'post', @URL, 'false';
			EXEC sp_OAMethod @Object, 'setRequestHeader', NULL, 'Content-Type', 'application/json';
			EXEC sp_OAMethod @Object, 'send', NULL, @body;
			EXEC sp_OAMethod @Object, 'responseText', @ResponseText OUTPUT;
			
			
			IF CHARINDEX('ko', (SELECT @ResponseText)) > 0
			BEGIN
				INSERT INTO dbo.Z_APP_Messaggi (ZAPP_Messaggio)
			    VALUES (@body);
		        
		        INSERT INTO dbo.Z_APP_LOG (ZALO_Messaggio,ZALO_provenienza)
		        VALUES (@ResponseText+'-'+@body,'TRIGGER: Z_APP_TR_OC_Anag');
			END;
		END;
END;
GO
```
  * Bolle
```
/****** Object:  Trigger [dbo].[Z_APP_TR_BL_Anag]    Script Date: 11/13/2024 16:54:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--DROP TRIGGER  [dbo].[Z_APP_OC_Anag];
CREATE TRIGGER [dbo].[Z_APP_TR_BL_Anag] 
ON [dbo].[BL_Anag]
AFTER DELETE
AS
DECLARE @URL NVARCHAR(MAX);
SELECT @URL =  ZIAP_IndirizzoServer FROM Z_APP_info;
DECLARE @body AS VARCHAR(MAX);
DECLARE @BLAN_ID AS INT;
DECLARE @BLAN_BLTI_ID AS INT;
DECLARE @Object AS INT;
DECLARE @ResponseText AS VARCHAR(8000);
BEGIN
		IF EXISTS (SELECT * FROM Z_APP_dispositivi
			WHERE ZAPPD_BLTI_ID1 IN (SELECT BLAN_BLTI_ID FROM deleted) OR ZAPPD_BLTI_ID2 IN (SELECT BLAN_BLTI_ID FROM deleted)
			)
		BEGIN
			SET @BLAN_ID= (SELECT BLAN_ID FROM deleted);
			SET @BLAN_BLTI_ID=(SELECT BLAN_BLTI_ID FROM deleted);
			INSERT INTO Z_APP_LOG (ZALO_Messaggio, ZALO_Provenienza) VALUES ('ESEGUO TRIGGER DELETE BL_Anag: '+CAST(ISNULL(@BLAN_ID, 0) AS VARCHAR),'TRIGGER: Z_APP_TR_BL_Anag');
			SET @body  = '{
			   "QUERY":"DELETE",
			   "TABLE":"BL_Anag",
			   "DATA":{
					"BLAN_ID": "' + CAST(ISNULL(@BLAN_ID, 0) AS VARCHAR) + '",
					"BLAN_BLTI_Id": "' + CAST(ISNULL(@BLAN_BLTI_ID, 0) AS VARCHAR) + '"
				}
			}';
			
			
			
			EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;
			EXEC sp_OAMethod @Object, 'open', NULL, 'post', @URL, 'false';
			EXEC sp_OAMethod @Object, 'setRequestHeader', NULL, 'Content-Type', 'application/json';
			EXEC sp_OAMethod @Object, 'send', NULL, @body;
			EXEC sp_OAMethod @Object, 'responseText', @ResponseText OUTPUT;
			
			
			IF CHARINDEX('ko', (SELECT @ResponseText)) > 0
			BEGIN
				INSERT INTO dbo.Z_APP_Messaggi (ZAPP_Messaggio)
			    VALUES (@body);
		        
		        INSERT INTO dbo.Z_APP_LOG (ZALO_Messaggio,ZALO_provenienza)
		        VALUES (@ResponseText+'-'+@body,'TRIGGER: Z_APP_TR_FT_Anag');
			END;
		END;
END;
GO
```

  * Fatture
```
/****** Object:  Trigger [dbo].[Z_APP_TR_FT_Anag]    Script Date: 11/13/2024 16:56:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--DROP TRIGGER  [dbo].[Z_APP_OC_Anag];
CREATE TRIGGER [dbo].[Z_APP_TR_FT_Anag] 
ON [dbo].[FT_Anag]
AFTER DELETE
AS
DECLARE @URL NVARCHAR(MAX);
SELECT @URL =  ZIAP_IndirizzoServer FROM Z_APP_info;
DECLARE @body AS VARCHAR(MAX);
DECLARE @FTAN_ID AS INT;
DECLARE @FTAN_FTTI_ID AS INT;
DECLARE @Object AS INT;
DECLARE @ResponseText AS VARCHAR(8000);
BEGIN
		IF EXISTS (SELECT * FROM Z_APP_dispositivi
			WHERE ZAPPD_FTTI_ID IN (SELECT FTAN_FTTI_ID FROM deleted)
			)
		BEGIN
			SET @FTAN_ID= (SELECT FTAN_ID FROM deleted);
			SET @FTAN_FTTI_ID=(SELECT FTAN_FTTI_ID FROM deleted);
			INSERT INTO Z_APP_LOG (ZALO_Messaggio, ZALO_Provenienza) VALUES ('ESEGUO TRIGGER DELETE FT_Anag: '+CAST(ISNULL(@FTAN_ID, 0) AS VARCHAR),'TRIGGER: Z_APP_TR_FT_Anag');
			SET @body  = '{
			   "QUERY":"DELETE",
			   "TABLE":"FT_Anagr",
			   "DATA":{
					"FTAN_ID": "' + CAST(ISNULL(@FTAN_ID, 0) AS VARCHAR) + '",
					"FTAN_FTTI_Id": "' + CAST(ISNULL(@FTAN_FTTI_ID, 0) AS VARCHAR) + '"
				}
			}';
			
			
			
			EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;
			EXEC sp_OAMethod @Object, 'open', NULL, 'post', @URL, 'false';
			EXEC sp_OAMethod @Object, 'setRequestHeader', NULL, 'Content-Type', 'application/json';
			EXEC sp_OAMethod @Object, 'send', NULL, @body;
			EXEC sp_OAMethod @Object, 'responseText', @ResponseText OUTPUT;
			
			
			IF CHARINDEX('ko', (SELECT @ResponseText)) > 0
			BEGIN
				INSERT INTO dbo.Z_APP_Messaggi (ZAPP_Messaggio)
			    VALUES (@body);
		        
		        INSERT INTO dbo.Z_APP_LOG (ZALO_Messaggio,ZALO_provenienza)
		        VALUES (@ResponseText+'-'+@body,'TRIGGER: Z_APP_TR_FT_Anag');
			END;
		END;
END;
GO
```
* Creare Trigger Per Aggiornamento Altre Tabelle
  * Z_PrezziTv
```
--DROP TRIGGER [dbo].[Z_APP_Z_PrezziTv] ;
CREATE TRIGGER [dbo].[Z_APP_Z_PrezziTv] ON [dbo].[Z_PrezziTv]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    INSERT INTO Z_APP_LOG (ZALO_Messaggio, ZALO_Provenienza) VALUES ('ESEGUO TRIGGER DELETE Z_PrezziTv','TRIGGER: Z_APP_Z_PrezziTv');
    SET NOCOUNT ON;

    DECLARE @URL NVARCHAR(MAX);
    SELECT @URL = ZIAP_IndirizzoServer FROM Z_APP_info;
    DECLARE @Object AS INT;
    DECLARE @ResponseText AS VARCHAR(8000);
    DECLARE @OperationType VARCHAR(10);
    DECLARE @query AS VARCHAR(5000);    
    DECLARE @ZPTV_ID as INT;
    DECLARE @ZPTV_MGAA_ID as INT;
    DECLARE @ZPTV_MBPC_ID as INT;
    DECLARE @ZPTV_Prezzo AS DECIMAL(18,2);
    DECLARE @ZPTV_Sconto1 as DECIMAL(18,2);
    DECLARE @ZPTV_Sconto2 as DECIMAL(18,2);
    DECLARE @ZPTV_Sconto3 as DECIMAL(18,2);


    DECLARE @DettagliModifiche TABLE (
        ZPTV_ID INT,
        ZPTV_MGAA_ID INT,
        ZPTV_MBPC_ID INT,
        ZPTV_Prezzo DECIMAL(18,2),
        ZPTV_Sconto1 DECIMAL(18,2),
        ZPTV_Sconto2 DECIMAL(18,2),
        ZPTV_Sconto3 DECIMAL(18,2),
        OperationType VARCHAR(10)
    );

    IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO @DettagliModifiche
        SELECT 
            ZPTV_ID, ZPTV_MGAA_ID, ZPTV_MBPC_ID, ZPTV_Prezzo, ZPTV_Sconto1,ZPTV_Sconto2, ZPTV_Sconto3,
            'INSERT'
        FROM inserted;
    END

    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO @DettagliModifiche
        SELECT 
            i.ZPTV_ID, i.ZPTV_MGAA_ID, i.ZPTV_MBPC_ID, i.ZPTV_Prezzo, i.ZPTV_Sconto1,i.ZPTV_Sconto2, i.ZPTV_Sconto3, 'UPDATE'
        FROM inserted i
        JOIN deleted d ON i.ZPTV_ID = d.ZPTV_ID;
    END

    IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted)
    BEGIN
        INSERT INTO @DettagliModifiche
        SELECT 
            ZPTV_ID, ZPTV_MGAA_ID, ZPTV_MBPC_ID, ZPTV_Prezzo, ZPTV_Sconto1,ZPTV_Sconto2, ZPTV_Sconto3, 'DELETE'
        FROM deleted;
    END

    DECLARE cursore CURSOR FOR 
    SELECT * FROM @DettagliModifiche;

    OPEN cursore;
    FETCH NEXT FROM cursore INTO 
        @ZPTV_ID, @ZPTV_MGAA_ID, @ZPTV_MBPC_ID, @ZPTV_Prezzo, @ZPTV_Sconto1, @ZPTV_Sconto2, @ZPTV_Sconto3,
        @OperationType;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @body AS VARCHAR(8000) = '{
           "QUERY":"' + @OperationType + '",
           "TABLE":"Z_PrezziTv",
           "DATA":{
                "ZPTV_ID": "' + CAST(ISNULL(@ZPTV_ID, 0) AS VARCHAR) + '",
                "ZPTV_MGAA_ID": "' + CAST(ISNULL(@ZPTV_MGAA_ID, 0) AS VARCHAR) + '",
                "ZPTV_MBPC_ID": "' + CAST(ISNULL(@ZPTV_MBPC_ID, 0) AS VARCHAR) + '",
                "ZPTV_Prezzo": "' + CAST(ISNULL(@ZPTV_Prezzo, 0) AS VARCHAR) + '",
                "ZPTV_Sconto1": "' + CAST(ISNULL(@ZPTV_Sconto1, 0) AS VARCHAR) + '",
                "ZPTV_Sconto2": "' + CAST(ISNULL(@ZPTV_Sconto2, 0) AS VARCHAR) + '",
                "ZPTV_Sconto3": "' + CAST(ISNULL(@ZPTV_Sconto3, 0) AS VARCHAR) + '"
            }
        }' -- JSON body for HTTP POST similar to the first trigger
		print(@body);
        EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;
        EXEC sp_OAMethod @Object, 'open', NULL, 'post', @URL, 'false';
        EXEC sp_OAMethod @Object, 'setRequestHeader', NULL, 'Content-Type', 'application/json';
        EXEC sp_OAMethod @Object, 'send', NULL, @body;
        EXEC sp_OAMethod @Object, 'responseText', @ResponseText OUTPUT;

        

		--INSERT INTO Z_APP_LOG (ZALO_Messaggio, ZALO_Provenienza) VALUES ('Z_APP_Z_PrezziTv - ResponseText'+@ResponseText,'TRIGGER: Z_APP_Z_PrezziTv');       IF CHARINDEX('ko',(SELECT @ResponseText)) > 0
		BEGIN
			INSERT INTO dbo.Z_APP_Messaggi
				(ZAPP_Messaggio)
				VALUES('{
           "QUERY":"' + @OperationType + '",
           "TABLE":"Z_PrezziTv",
           "DATA":{
                "ZPTV_ID": "' + CAST(ISNULL(@ZPTV_ID, 0) AS VARCHAR) + '",
                "ZPTV_MGAA_ID": "' + CAST(ISNULL(@ZPTV_MGAA_ID, 0) AS VARCHAR) + '",
                "ZPTV_MBPC_ID": "' + CAST(ISNULL(@ZPTV_MBPC_ID, 0) AS VARCHAR) + '",
                "ZPTV_Prezzo": "' + CAST(ISNULL(@ZPTV_Prezzo, 0) AS VARCHAR) + '",
                "ZPTV_Sconto1": "' + CAST(ISNULL(@ZPTV_Sconto1, 0) AS VARCHAR) + '",
                "ZPTV_Sconto2": "' + CAST(ISNULL(@ZPTV_Sconto2, 0) AS VARCHAR) + '",
                "ZPTV_Sconto3": "' + CAST(ISNULL(@ZPTV_Sconto3, 0) AS VARCHAR) + '"
	            }
	        }');
		 SELECT @ResponseText As 'Message'--Creare una tabella messaggi ed aggiungere qui i messaggi da inserire che non sono passati,
		 --se ritorna ko vuol dire che non è stato salvato il messaggio per nessun dispositivo, quindi quando si collega un client 
		 --va fatto il controllo sulla tabella messaggi e se sono presenti si esegue la funzione che inserisce un messaggio per ogni device
		 --e prova ad inviarli.
		END
		EXEC sp_OADestroy @Object
	       
	    FETCH NEXT FROM cursore INTO 
	        @ZPTV_ID, @ZPTV_MGAA_ID, @ZPTV_MBPC_ID, @ZPTV_Prezzo, @ZPTV_Sconto1, @ZPTV_Sconto2, @ZPTV_Sconto3,
        	@OperationType;
    END;

    CLOSE cursore;
    DEALLOCATE cursore;

    IF @Object IS NOT NULL
	BEGIN
	    EXEC sp_OADestroy @Object;
	END
END;
```
  * Pagamenti Bolle
```
CREATE TRIGGER [dbo].[Z_APP_BL_Pagam] ON [dbo].[BL_Pagam]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    PRINT 'ESEGUO TRIGGER';
    SET NOCOUNT ON;

    DECLARE @URL NVARCHAR(MAX);
    SELECT @URL = ZIAP_IndirizzoServer FROM Z_APP_info;
    DECLARE @Object AS INT;
    DECLARE @ResponseText AS VARCHAR(8000);
	DECLARE @query AS VARCHAR(5000);
    DECLARE @OperationType VARCHAR(10);
    DECLARE @BLPG_ID as INT;
    DECLARE @BLPG_BLAN_ID as INT;
   	DECLARE @BLPG_MBTP_ID as INT;
    DECLARE @BLPG_MBSP_ID as INT;

    DECLARE @DettagliModifiche TABLE (
        BLPG_ID INT,
        BLPG_BLAN_ID INT,
        BLPG_MBTP_ID INT,
        BLPG_MBSP_ID INT,
        OperationType VARCHAR(10)
    );

    IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO @DettagliModifiche
        SELECT 
            BLPG_ID, BLPG_BLAN_ID, BLPG_MBTP_ID,BLPG_MBSP_ID,'INSERT'
        FROM inserted;
    END

    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO @DettagliModifiche
        SELECT 
           i.BLPG_ID, i.BLPG_BLAN_ID, i.BLPG_MBTP_ID, i.BLPG_MBSP_ID,'UPDATE'
        FROM inserted i
        JOIN deleted d ON i.BLPG_ID = d.BLPG_ID;
    END

    IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted)
    BEGIN
        INSERT INTO @DettagliModifiche
        SELECT 
            BLPG_ID, BLPG_BLAN_ID, BLPG_MBTP_ID,BLPG_MBSP_ID,'DELETE'
        FROM deleted;
    END

    DECLARE cursore CURSOR FOR 
    SELECT * FROM @DettagliModifiche;

    OPEN cursore;
    FETCH NEXT FROM cursore INTO 
         @BLPG_ID, @BLPG_BLAN_ID, @BLPG_MBTP_ID, @BLPG_MBSP_ID, @OperationType;

    WHILE @@FETCH_STATUS = 0
    BEGIN
		IF EXISTS (
			SELECT * FROM Z_APP_dispositivi
				WHERE ZAPPD_BLTI_ID1 IN (
					SELECT BLAN_BLTI_ID FROM BL_Pagam 
					JOIN BL_anag ON BLPG_BLAN_Id = BLAN_ID
					WHERE BLPG_ID=@BLPG_ID
				) OR  ZAPPD_BLTI_ID2 IN (
					SELECT BLAN_BLTI_ID FROM BL_Pagam 
					JOIN BL_anag ON BLPG_BLAN_Id = BLAN_ID
					WHERE BLPG_ID=@BLPG_ID
				)
		)
       	BEGIN 
	       	PRINT('SONO DENTRO IL CURSORE');
		   
	        DECLARE @body AS VARCHAR(8000) = '{
	           "QUERY":"' + @OperationType + '",
	           "TABLE":"BL_Pagam",
	           "DATA":{
	                "BLPG_ID": "' + CAST(ISNULL(@BLPG_ID, 0) AS VARCHAR) + '",
	                "BLPG_BLAN_ID": "' + CAST(ISNULL(@BLPG_BLAN_ID, 0) AS VARCHAR) + '",
					"BLPG_MBTP_ID": "' + CAST(ISNULL(@BLPG_MBTP_ID, 0) AS VARCHAR) + '",				
	                "BLPG_MBSP_ID": "' + CAST(ISNULL(@BLPG_MBSP_ID, 0) AS VARCHAR) +'"
	            }
	        }' -- JSON body for HTTP POST similar to the first trigger
			print(@body);
	        EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;
	        EXEC sp_OAMethod @Object, 'open', NULL, 'post', @URL, 'false';
	        EXEC sp_OAMethod @Object, 'setRequestHeader', NULL, 'Content-Type', 'application/json';
	        EXEC sp_OAMethod @Object, 'send', NULL, @body;
	        EXEC sp_OAMethod @Object, 'responseText', @ResponseText OUTPUT;
	
	        PRINT @ResponseText;
	
	       IF CHARINDEX('ko',(SELECT @ResponseText)) > 0
			BEGIN
				INSERT INTO dbo.Z_APP_Messaggi
					(ZAPP_Messaggio)
					VALUES('{
	           "QUERY":"' + @OperationType + '",
	           "TABLE":"BL_Pagam",
	           "DATA":{
	                "BLPG_ID": "' + CAST(ISNULL(@BLPG_ID, 0) AS VARCHAR) + '",
	                "BLPG_BLAN_ID": "' + CAST(ISNULL(@BLPG_BLAN_ID, 0) AS VARCHAR) + '",
					"BLPG_MBTP_ID": "' + CAST(ISNULL(@BLPG_MBTP_ID, 0) AS VARCHAR) + '",				
	                "BLPG_MBSP_ID": "' + CAST(ISNULL(@BLPG_MBSP_ID, 0) AS VARCHAR) +'"
	            }
	        }');
			 SELECT @ResponseText As 'Message'--Creare una tabella messaggi ed aggiungere qui i messaggi da inserire che non sono passati,
			 --se ritorna ko vuol dire che non è stato salvato il messaggio per nessun dispositivo, quindi quando si collega un client 
			 --va fatto il controllo sulla tabella messaggi e se sono presenti si esegue la funzione che inserisce un messaggio per ogni device
			 --e prova ad inviarli.
			END
			ELSE
			BEGIN
			 --SELECT @ResponseText As 'Employee Details'
				print @query;
			END
			EXEC sp_OADestroy @Object

       	END
       	
        FETCH NEXT FROM cursore INTO 
             @BLPG_ID, @BLPG_BLAN_ID, @BLPG_MBTP_ID, @BLPG_MBSP_ID, @OperationType;
    END

    CLOSE cursore;
    DEALLOCATE cursore;

    IF @Object IS NOT NULL
	BEGIN
	    EXEC sp_OADestroy @Object;
	END

END;
```

  * Tipo Bolle
```
CREATE TRIGGER [dbo].[Z_APP_BL_Tipo] ON [dbo].[BL_Tipo]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    PRINT 'ESEGUO TRIGGER';
    SET NOCOUNT ON;

    DECLARE @URL NVARCHAR(MAX);
    SELECT @URL = ZIAP_IndirizzoServer FROM Z_APP_info;
    DECLARE @Object AS INT;
    DECLARE @ResponseText AS VARCHAR(8000);
	DECLARE @query AS VARCHAR(5000);
    DECLARE @OperationType VARCHAR(10);
    DECLARE @BLTI_ID as INT;
    DECLARE @BLTI_TipNum as INT;
   	DECLARE @BLTI_Tipo as INT;
  	DECLARE @BLTI_NaturaDDT as INT;
    DECLARE @BLTI_Descr as VARCHAR(255);

    DECLARE @DettagliModifiche TABLE (
        BLTI_ID INT,
        BLTI_TipNum INT,
        BLTI_Tipo INT,
        BLTI_NaturaDDT INT,
        BLTI_Descr VARCHAR(255),
        OperationType VARCHAR(10)
    );

    IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO @DettagliModifiche
        SELECT 
            BLTI_ID, BLTI_TipNum, BLTI_Tipo,BLTI_NaturaDDT,BLTI_Descr,'INSERT'
        FROM inserted;
    END

    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO @DettagliModifiche
        SELECT 
            i.BLTI_ID, i.BLTI_TipNum, i.BLTI_Tipo, i.BLTI_NaturaDDT, i.BLTI_Descr,'UPDATE'
        FROM inserted i
        JOIN deleted d ON i.BLTI_ID = d.BLTI_ID;
    END

    IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted)
    BEGIN
        INSERT INTO @DettagliModifiche
        SELECT 
            BLTI_ID, BLTI_TipNum, BLTI_Tipo,BLTI_NaturaDDT,BLTI_Descr, 'DELETE'
        FROM deleted;
    END

    DECLARE cursore CURSOR FOR 
    SELECT * FROM @DettagliModifiche;

    OPEN cursore;
    FETCH NEXT FROM cursore INTO 
        @BLTI_ID, @BLTI_TipNum, @BLTI_Tipo, @BLTI_NaturaDDT, @BLTI_Descr, @OperationType;

    WHILE @@FETCH_STATUS = 0
    BEGIN
	    PRINT('SONO DENTRO IL CURSORE');
	   
        DECLARE @body AS VARCHAR(8000) = '{
           "QUERY":"' + @OperationType + '",
           "TABLE":"BL_Tipo",
           "DATA":{
                "BLTI_ID": "' + CAST(ISNULL(@BLTI_ID, 0) AS VARCHAR) + '",
                "BLTI_TipNum": "' + CAST(ISNULL(@BLTI_TipNum, 0) AS VARCHAR) + '",
				"BLTI_Tipo": "' + CAST(ISNULL(@BLTI_Tipo, 0) AS VARCHAR) + '",
				"BLTI_NaturaDDT": "' + CAST(ISNULL(@BLTI_NaturaDDT, 0) AS VARCHAR) + '",				
                "BLTI_Descr": "' + ISNULL(@BLTI_Descr, '') +'"
            }
        }' -- JSON body for HTTP POST similar to the first trigger
		print(@body);
        EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;
        EXEC sp_OAMethod @Object, 'open', NULL, 'post', @URL, 'false';
        EXEC sp_OAMethod @Object, 'setRequestHeader', NULL, 'Content-Type', 'application/json';
        EXEC sp_OAMethod @Object, 'send', NULL, @body;
        EXEC sp_OAMethod @Object, 'responseText', @ResponseText OUTPUT;

        PRINT @ResponseText;

       IF CHARINDEX('ko',(SELECT @ResponseText)) > 0
		BEGIN
			INSERT INTO dbo.Z_APP_Messaggi
				(ZAPP_Messaggio)
				VALUES('{
           "QUERY":"' + @OperationType + '",
           "TABLE":"BL_Tipo",
           "DATA":{
                "BLTI_ID": "' + CAST(ISNULL(@BLTI_ID, 0) AS VARCHAR) + '",
                "BLTI_TipNum": "' + CAST(ISNULL(@BLTI_TipNum, 0) AS VARCHAR) + '",
				"BLTI_Tipo": "' + CAST(ISNULL(@BLTI_Tipo, 0) AS VARCHAR) + '",
				"BLTI_NaturaDDT": "' + CAST(ISNULL(@BLTI_NaturaDDT, 0) AS VARCHAR) + '",				
                "BLTI_Descr": "' + ISNULL(@BLTI_Descr, '') +'"
            }
        }');
		 SELECT @ResponseText As 'Message'--Creare una tabella messaggi ed aggiungere qui i messaggi da inserire che non sono passati,
		 --se ritorna ko vuol dire che non è stato salvato il messaggio per nessun dispositivo, quindi quando si collega un client 
		 --va fatto il controllo sulla tabella messaggi e se sono presenti si esegue la funzione che inserisce un messaggio per ogni device
		 --e prova ad inviarli.
		END
		ELSE
		BEGIN
		 --SELECT @ResponseText As 'Employee Details'
			print @query;
		END
		EXEC sp_OADestroy @Object
       
        FETCH NEXT FROM cursore INTO 
             @BLTI_ID, @BLTI_TipNum, @BLTI_Tipo, @BLTI_NaturaDDT, @BLTI_Descr, @OperationType;
    END

    CLOSE cursore;
    DEALLOCATE cursore;

    EXEC sp_OADestroy @Object;
END;
```

  * Pagamenti Fatture
```
CREATE TRIGGER [dbo].[Z_APP_FT_Pagam] ON [dbo].[FT_Pagam]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    PRINT 'ESEGUO TRIGGER';
    SET NOCOUNT ON;

    DECLARE @URL NVARCHAR(MAX);
    SELECT @URL = ZIAP_IndirizzoServer FROM Z_APP_info;
    DECLARE @Object AS INT;
    DECLARE @ResponseText AS VARCHAR(8000);
	DECLARE @query AS VARCHAR(5000);
    DECLARE @OperationType VARCHAR(10);
    DECLARE @FTPG_ID as INT;
    DECLARE @FTPG_FTAN_ID as INT;
   	DECLARE @FTPG_MBTP_ID as INT;
    DECLARE @FTPG_MBSP_ID as INT;

    DECLARE @DettagliModifiche TABLE (
        FTPG_ID INT,
        FTPG_FTAN_ID INT,
        FTPG_MBTP_ID INT,
        FTPG_MBSP_ID INT,
        OperationType VARCHAR(10)
    );

    IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO @DettagliModifiche
        SELECT 
            FTPG_ID, FTPG_FTAN_ID, FTPG_MBTP_ID,FTPG_MBSP_ID,'INSERT'
        FROM inserted;
    END

    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO @DettagliModifiche
        SELECT 
           i.FTPG_ID, i.FTPG_FTAN_ID, i.FTPG_MBTP_ID, i.FTPG_MBSP_ID,'UPDATE'
        FROM inserted i
        JOIN deleted d ON i.FTPG_ID = d.FTPG_ID;
    END

    IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted)
    BEGIN
        INSERT INTO @DettagliModifiche
        SELECT 
            FTPG_ID, FTPG_FTAN_ID, FTPG_MBTP_ID,FTPG_MBSP_ID,'DELETE'
        FROM deleted;
    END

    DECLARE cursore CURSOR FOR 
    SELECT * FROM @DettagliModifiche;

    OPEN cursore;
    FETCH NEXT FROM cursore INTO 
         @FTPG_ID, @FTPG_FTAN_ID, @FTPG_MBTP_ID, @FTPG_MBSP_ID, @OperationType;

    WHILE @@FETCH_STATUS = 0
    BEGIN
	    
	    IF EXISTS (SELECT * FROM Z_APP_dispositivi
			WHERE ZAPPD_FTTI_ID IN (
				SELECT FTAN_FTTI_ID FROM FT_pagam
				JOIN FT_Anag ON FTPG_FTAN_ID=FTAN_ID
				WHERE FTPG_ID=@FTPG_ID	
			)
		)
		BEGIN 
				
			PRINT('SONO DENTRO IL CURSORE');
		   
	        DECLARE @body AS VARCHAR(8000) = '{
	           "QUERY":"' + @OperationType + '",
	           "TABLE":"FT_Pagam",
	           "DATA":{
	                "FTPG_ID": "' + CAST(ISNULL(@FTPG_ID, 0) AS VARCHAR) + '",
	                "FTPG_FTAN_ID": "' + CAST(ISNULL(@FTPG_FTAN_ID, 0) AS VARCHAR) + '",
					"FTPG_MBTP_ID": "' + CAST(ISNULL(@FTPG_MBTP_ID, 0) AS VARCHAR) + '",				
	                "FTPG_MBSP_ID": "' + CAST(ISNULL(@FTPG_MBSP_ID, 0) AS VARCHAR) +'"
	            }
	        }' -- JSON body for HTTP POST similar to the first trigger
			print(@body);
	        EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;
	        EXEC sp_OAMethod @Object, 'open', NULL, 'post', @URL, 'false';
	        EXEC sp_OAMethod @Object, 'setRequestHeader', NULL, 'Content-Type', 'application/json';
	        EXEC sp_OAMethod @Object, 'send', NULL, @body;
	        EXEC sp_OAMethod @Object, 'responseText', @ResponseText OUTPUT;
	
	        PRINT @ResponseText;
	
	       IF CHARINDEX('ko',(SELECT @ResponseText)) > 0
			BEGIN
				INSERT INTO dbo.Z_APP_Messaggi
					(ZAPP_Messaggio)
					VALUES('{
	           "QUERY":"' + @OperationType + '",
	           "TABLE":"FT_Pagam",
	           "DATA":{
	                "FTPG_ID": "' + CAST(ISNULL(@FTPG_ID, 0) AS VARCHAR) + '",
	                "FTPG_FTAN_ID": "' + CAST(ISNULL(@FTPG_FTAN_ID, 0) AS VARCHAR) + '",
					"FTPG_MBTP_ID": "' + CAST(ISNULL(@FTPG_MBTP_ID, 0) AS VARCHAR) + '",				
	                "FTPG_MBSP_ID": "' + CAST(ISNULL(@FTPG_MBSP_ID, 0) AS VARCHAR) +'"
	            }
	        }');
			 SELECT @ResponseText As 'Message'--Creare una tabella messaggi ed aggiungere qui i messaggi da inserire che non sono passati,
			 --se ritorna ko vuol dire che non è stato salvato il messaggio per nessun dispositivo, quindi quando si collega un client 
			 --va fatto il controllo sulla tabella messaggi e se sono presenti si esegue la funzione che inserisce un messaggio per ogni device
			 --e prova ad inviarli.
			END
			ELSE
			BEGIN
			 --SELECT @ResponseText As 'Employee Details'
				print @query;
			END
			EXEC sp_OADestroy @Object

		END
		
       
        FETCH NEXT FROM cursore INTO 
             @FTPG_ID, @FTPG_FTAN_ID, @FTPG_MBTP_ID, @FTPG_MBSP_ID, @OperationType;
    END

    CLOSE cursore;
    DEALLOCATE cursore;

    IF @Object IS NOT NULL
	BEGIN
	    EXEC sp_OADestroy @Object;
	END

END;
```

  * Tipo Fatture
```
CREATE TRIGGER [dbo].[Z_APP_FT_Tipo] ON [dbo].[FT_Tipo]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    PRINT 'ESEGUO TRIGGER';
    SET NOCOUNT ON;

    DECLARE @URL NVARCHAR(MAX);
    SELECT @URL = ZIAP_IndirizzoServer FROM Z_APP_info;
    DECLARE @Object AS INT;
    DECLARE @ResponseText AS VARCHAR(8000);
	DECLARE @query AS VARCHAR(5000);
    DECLARE @OperationType VARCHAR(10);
    DECLARE @FTTI_ID as INT;
    DECLARE @FTTI_TipNum as INT;
   	DECLARE @FTTI_Tipo as INT;
  	DECLARE @FTTI_FattureInStatistica as INT;
  	DECLARE @FTTI_NaturaFattura as INT;
    DECLARE @FTTI_Descr as VARCHAR(255);

    DECLARE @DettagliModifiche TABLE (
        FTTI_ID INT,
        FTTI_TipNum INT,
        FTTI_Tipo INT,
        FTTI_FattureInStatistica INT,
        FTTI_NaturaFattura INT,
        FTTI_Descr VARCHAR(255),
        OperationType VARCHAR(10)
    );

    IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO @DettagliModifiche
        SELECT 
            FTTI_ID, FTTI_TipNum, FTTI_Tipo,FTTI_FattureInStatistica,FTTI_NaturaFattura,FTTI_Descr,'INSERT'
        FROM inserted;
    END

    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO @DettagliModifiche
        SELECT 
            i.FTTI_ID, i.FTTI_TipNum, i.FTTI_Tipo, i.FTTI_FattureInStatistica, i.FTTI_NaturaFattura, i.FTTI_Descr,'UPDATE'
        FROM inserted i
        JOIN deleted d ON i.FTTI_ID = d.FTTI_ID;
    END

    IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted)
    BEGIN
        INSERT INTO @DettagliModifiche
        SELECT 
            FTTI_ID, FTTI_TipNum, FTTI_Tipo,FTTI_FattureInStatistica,FTTI_NaturaFattura,FTTI_Descr, 'DELETE'
        FROM deleted;
    END

    DECLARE cursore CURSOR FOR 
    SELECT * FROM @DettagliModifiche;

    OPEN cursore;
    FETCH NEXT FROM cursore INTO 
        @FTTI_ID, @FTTI_TipNum, @FTTI_Tipo, @FTTI_FattureInStatistica, @FTTI_NaturaFattura, @FTTI_Descr, @OperationType;

    WHILE @@FETCH_STATUS = 0
    BEGIN
	    PRINT('SONO DENTRO IL CURSORE');
	   
        DECLARE @body AS VARCHAR(8000) = '{
           "QUERY":"' + @OperationType + '",
           "TABLE":"FT_Tipo",
           "DATA":{
                "FTTI_ID": "' + CAST(ISNULL(@FTTI_ID, 0) AS VARCHAR) + '",
                "FTTI_TipNum": "' + CAST(ISNULL(@FTTI_TipNum, 0) AS VARCHAR) + '",
				"FTTI_Tipo": "' + CAST(ISNULL(@FTTI_Tipo, 0) AS VARCHAR) + '",
				"FTTI_FattureInStatistica": "' + CAST(ISNULL(@FTTI_FattureInStatistica, 0) AS VARCHAR) + '",
				"FTTI_NaturaFattura": "' + CAST(ISNULL(@FTTI_NaturaFattura, 0) AS VARCHAR) + '",
                "FTTI_Descr": "' + ISNULL(@FTTI_Descr, '') +'"
            }
        }' -- JSON body for HTTP POST similar to the first trigger
		print(@body);
        EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;
        EXEC sp_OAMethod @Object, 'open', NULL, 'post', @URL, 'false';
        EXEC sp_OAMethod @Object, 'setRequestHeader', NULL, 'Content-Type', 'application/json';
        EXEC sp_OAMethod @Object, 'send', NULL, @body;
        EXEC sp_OAMethod @Object, 'responseText', @ResponseText OUTPUT;

        PRINT @ResponseText;

       IF CHARINDEX('ko',(SELECT @ResponseText)) > 0
		BEGIN
			INSERT INTO dbo.Z_APP_Messaggi
				(ZAPP_Messaggio)
				VALUES('{
           "QUERY":"' + @OperationType + '",
           "TABLE":"FT_Tipo",
           "DATA":{
                "FTTI_ID": "' + CAST(ISNULL(@FTTI_ID, 0) AS VARCHAR) + '",
                "FTTI_TipNum": "' + CAST(ISNULL(@FTTI_TipNum, 0) AS VARCHAR) + '",
				"FTTI_Tipo": "' + CAST(ISNULL(@FTTI_Tipo, 0) AS VARCHAR) + '",
				"FTTI_FattureInStatistica": "' + CAST(ISNULL(@FTTI_FattureInStatistica, 0) AS VARCHAR) + '",
				"FTTI_NaturaFattura": "' + CAST(ISNULL(@FTTI_NaturaFattura, 0) AS VARCHAR) + '",
                "FTTI_Descr": "' + ISNULL(@FTTI_Descr, '') +'"
            }
        }');
		 SELECT @ResponseText As 'Message'--Creare una tabella messaggi ed aggiungere qui i messaggi da inserire che non sono passati,
		 --se ritorna ko vuol dire che non è stato salvato il messaggio per nessun dispositivo, quindi quando si collega un client 
		 --va fatto il controllo sulla tabella messaggi e se sono presenti si esegue la funzione che inserisce un messaggio per ogni device
		 --e prova ad inviarli.
		END
		ELSE
		BEGIN
		 --SELECT @ResponseText As 'Employee Details'
			print @query;
		END
		EXEC sp_OADestroy @Object
       
        FETCH NEXT FROM cursore INTO 
             @FTTI_ID, @FTTI_TipNum, @FTTI_Tipo, @FTTI_FattureInStatistica, @FTTI_NaturaFattura, @FTTI_Descr, @OperationType;
    END

    CLOSE cursore;
    DEALLOCATE cursore;

    EXEC sp_OADestroy @Object;
END;
```

  * Anagrafiche Agenti
```
CREATE TRIGGER [dbo].[Z_APP_MB_Agenti] ON [dbo].[MB_Agenti]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    PRINT 'ESEGUO TRIGGER';
    SET NOCOUNT ON;

    DECLARE @URL NVARCHAR(MAX);
    SELECT @URL = ZIAP_IndirizzoServer FROM Z_APP_info;
    DECLARE @Object AS INT;
    DECLARE @ResponseText AS VARCHAR(8000);
	DECLARE @query AS VARCHAR(5000);
    DECLARE @OperationType VARCHAR(10);
    DECLARE @MBAG_ID as INT;
    DECLARE @MBAG_MBAN_ID as INT;
    DECLARE @MBAN_RagSoc as VARCHAR(255);

    DECLARE @DettagliModifiche TABLE (
        MBAG_ID INT,
        MBAG_MBAN_ID INT,
        MBAN_RagSoc VARCHAR(255),
        OperationType VARCHAR(10)
    );

    IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
    BEGIN
	    
	    SELECT @MBAN_RagSoc=MBAN_RagSoc FROM MB_Anagr WHERE MBAN_ID = (SELECT MBAG_MBAN_ID FROM inserted);
        INSERT INTO @DettagliModifiche
        SELECT 
            MBAG_ID, MBAG_MBAN_ID, @MBAN_RagSoc,'INSERT'
        FROM inserted;
    END

    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
	    SELECT @MBAN_RagSoc=MBAN_RagSoc FROM MB_Anagr WHERE MBAN_ID = 
	    (SELECT i.MBAG_MBAN_ID FROM inserted i
        	JOIN deleted d ON i.MBAG_ID = d.MBAG_ID);
        INSERT INTO @DettagliModifiche
        SELECT 
            i.MBAG_ID, i.MBAG_MBAN_ID,@MBAN_RagSoc,'UPDATE'
        FROM inserted i
        JOIN deleted d ON i.MBAG_ID = d.MBAG_ID;
    END

    IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted)
    BEGIN
	    SELECT @MBAN_RagSoc=MBAN_RagSoc FROM MB_Anagr WHERE MBAN_ID = (SELECT MBAG_MBAN_ID FROM inserted);
        INSERT INTO @DettagliModifiche
        SELECT 
             MBAG_ID, MBAG_MBAN_ID, @MBAN_RagSoc, 'DELETE'
        FROM deleted;
    END

    DECLARE cursore CURSOR FOR 
    SELECT * FROM @DettagliModifiche;

    OPEN cursore;
    FETCH NEXT FROM cursore INTO 
        @MBAG_ID, @MBAG_MBAN_ID, @MBAN_RagSoc, @OperationType;

    WHILE @@FETCH_STATUS = 0
    BEGIN
	    PRINT('SONO DENTRO IL CURSORE');
	   
        DECLARE @body AS VARCHAR(8000) = '{
           "QUERY":"' + @OperationType + '",
           "TABLE":"MB_Agenti",
           "DATA":{
                "MBAG_ID": "' + CAST(ISNULL(@MBAG_ID, 0) AS VARCHAR) + '",
                "MBAG_MBAN_ID": "' + CAST(ISNULL(@MBAG_MBAN_ID, 0) AS VARCHAR) + '",		
                "MBAN_RagSoc": "' + ISNULL(@MBAN_RagSoc, '') +'"
            }
        }' -- JSON body for HTTP POST similar to the first trigger
		print(@body);
        EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;
        EXEC sp_OAMethod @Object, 'open', NULL, 'post', @URL, 'false';
        EXEC sp_OAMethod @Object, 'setRequestHeader', NULL, 'Content-Type', 'application/json';
        EXEC sp_OAMethod @Object, 'send', NULL, @body;
        EXEC sp_OAMethod @Object, 'responseText', @ResponseText OUTPUT;

        PRINT @ResponseText;

       IF CHARINDEX('ko',(SELECT @ResponseText)) > 0
		BEGIN
			INSERT INTO dbo.Z_APP_Messaggi
				(ZAPP_Messaggio)
				VALUES('{
           "QUERY":"' + @OperationType + '",
           "TABLE":"MB_Agenti",
           "DATA":{
                "MBAG_ID": "' + CAST(ISNULL(@MBAG_ID, 0) AS VARCHAR) + '",
                "MBAG_MBAN_ID": "' + CAST(ISNULL(@MBAG_MBAN_ID, 0) AS VARCHAR) + '",		
                "MBAN_RagSoc": "' + ISNULL(@MBAN_RagSoc, '') +'"
            }
        }' );
		 SELECT @ResponseText As 'Message'--Creare una tabella messaggi ed aggiungere qui i messaggi da inserire che non sono passati,
		 --se ritorna ko vuol dire che non è stato salvato il messaggio per nessun dispositivo, quindi quando si collega un client 
		 --va fatto il controllo sulla tabella messaggi e se sono presenti si esegue la funzione che inserisce un messaggio per ogni device
		 --e prova ad inviarli.
		END
		ELSE
		BEGIN
		 --SELECT @ResponseText As 'Employee Details'
			print @query;
		END
		EXEC sp_OADestroy @Object
       
        FETCH NEXT FROM cursore INTO 
              @MBAG_ID, @MBAG_MBAN_ID, @MBAN_RagSoc, @OperationType;
    END

    CLOSE cursore;
    DEALLOCATE cursore;

    EXEC sp_OADestroy @Object;
END;
```

  * IVA
```
CREATE TRIGGER [dbo].[Z_APP_MB_Iva] ON [dbo].[MB_Iva]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    PRINT 'ESEGUO TRIGGER';
    SET NOCOUNT ON;

    DECLARE @URL NVARCHAR(MAX);
    SELECT @URL = ZIAP_IndirizzoServer FROM Z_APP_info;
    DECLARE @Object AS INT;
    DECLARE @ResponseText AS VARCHAR(8000);
	DECLARE @query AS VARCHAR(5000);
    DECLARE @OperationType VARCHAR(10);
    DECLARE @MBIV_ID as INT;
    DECLARE @MBIV_IVA as INT;
   	DECLARE @MBIV_Perc as INT;
    DECLARE @MBIV_Descr as VARCHAR(255);

    DECLARE @DettagliModifiche TABLE (
        MBIV_ID INT,
        MBIV_IVA INT,
        MBIV_Perc INT,
        MBIV_Descr VARCHAR(255),
        OperationType VARCHAR(10)
    );

    IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO @DettagliModifiche
        SELECT 
            MBIV_Id, MBIV_IVA, MBIV_Perc,MBIV_Descr,'INSERT'
        FROM inserted;
    END

    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO @DettagliModifiche
        SELECT 
            i.MBIV_Id, i.MBIV_IVA,i.MBIV_Perc,i.MBIV_Descr,'UPDATE'
        FROM inserted i
        JOIN deleted d ON i.MBIV_ID = d.MBIV_ID;
    END

    IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted)
    BEGIN
        INSERT INTO @DettagliModifiche
        SELECT 
            MBIV_Id, MBIV_IVA, MBIV_Perc,MBIV_Descr,'DELETE'
        FROM deleted;
    END

    DECLARE cursore CURSOR FOR 
    SELECT * FROM @DettagliModifiche;

    OPEN cursore;
    FETCH NEXT FROM cursore INTO 
        @MBIV_ID, @MBIV_IVA, @MBIV_Perc, @MBIV_Descr, @OperationType;

    WHILE @@FETCH_STATUS = 0
    BEGIN
	    PRINT('SONO DENTRO IL CURSORE');
	   
        DECLARE @body AS VARCHAR(8000) = '{
           "QUERY":"' + @OperationType + '",
           "TABLE":"MB_IVA",
           "DATA":{
                "MBIV_ID": "' + CAST(ISNULL(@MBIV_ID, 0) AS VARCHAR) + '",
                "MBIV_IVA": "' + CAST(ISNULL(@MBIV_IVA, 0) AS VARCHAR) + '",
				"MBIV_Perc": "' + CAST(ISNULL(@MBIV_Perc, 0) AS VARCHAR) + '",				
                "MBIV_Descr": "' + ISNULL(@MBIV_Descr, '') +'"
            }
        }' -- JSON body for HTTP POST similar to the first trigger
		print(@body);
        EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;
        EXEC sp_OAMethod @Object, 'open', NULL, 'post', @URL, 'false';
        EXEC sp_OAMethod @Object, 'setRequestHeader', NULL, 'Content-Type', 'application/json';
        EXEC sp_OAMethod @Object, 'send', NULL, @body;
        EXEC sp_OAMethod @Object, 'responseText', @ResponseText OUTPUT;

        PRINT @ResponseText;

       IF CHARINDEX('ko',(SELECT @ResponseText)) > 0
		BEGIN
			INSERT INTO dbo.Z_APP_Messaggi
				(ZAPP_Messaggio)
				VALUES('{
           "QUERY":"' + @OperationType + '",
           "TABLE":"MB_IVA",
           "DATA":{
                "MBIV_ID": "' + CAST(ISNULL(@MBIV_ID, 0) AS VARCHAR) + '",
                "MBIV_IVA": "' + CAST(ISNULL(@MBIV_IVA, 0) AS VARCHAR) + '",
				"MBIV_Perc": "' + CAST(ISNULL(@MBIV_Perc, 0) AS VARCHAR) + '",				
                "MBIV_Descr": "' + ISNULL(@MBIV_Descr, '') +'"
            }
        }');
		 SELECT @ResponseText As 'Message'--Creare una tabella messaggi ed aggiungere qui i messaggi da inserire che non sono passati,
		 --se ritorna ko vuol dire che non è stato salvato il messaggio per nessun dispositivo, quindi quando si collega un client 
		 --va fatto il controllo sulla tabella messaggi e se sono presenti si esegue la funzione che inserisce un messaggio per ogni device
		 --e prova ad inviarli.
		END
		ELSE
		BEGIN
		 --SELECT @ResponseText As 'Employee Details'
			print @query;
		END
		EXEC sp_OADestroy @Object
       
        FETCH NEXT FROM cursore INTO 
              @MBIV_ID, @MBIV_IVA, @MBIV_Perc, @MBIV_Descr, @OperationType;
    END

    CLOSE cursore;
    DEALLOCATE cursore;

    EXEC sp_OADestroy @Object;
END;
```

  * Soluzioni Pagamento
```
CREATE TRIGGER [dbo].[Z_APP_MB_SolPag] ON [dbo].[MB_SolPag]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    PRINT 'ESEGUO TRIGGER';
    SET NOCOUNT ON;

    DECLARE @URL NVARCHAR(MAX);
    SELECT @URL = ZIAP_IndirizzoServer FROM Z_APP_info;
    DECLARE @Object AS INT;
    DECLARE @ResponseText AS VARCHAR(8000);
	DECLARE @query AS VARCHAR(5000);
    DECLARE @OperationType VARCHAR(10);
    DECLARE @MBSP_ID as INT;
    DECLARE @MBSP_Soluzione as INT;
   	DECLARE @MBSP_Code as INT;
    DECLARE @MBSP_Descr as VARCHAR(255);

    DECLARE @DettagliModifiche TABLE (
        MBSP_ID INT,
        MBSP_Soluzione INT,
        MBSP_Code INT,
        MBSP_Descr VARCHAR(255),
        OperationType VARCHAR(10)
    );

    IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO @DettagliModifiche
        SELECT 
            MBSP_ID, MBSP_Soluzione, MBSP_Code,MBSP_Descr,'INSERT'
        FROM inserted;
    END

    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO @DettagliModifiche
        SELECT 
            i.MBSP_ID, i.MBSP_Soluzione, i.MBSP_Code, i.MBSP_Descr,'UPDATE'
        FROM inserted i
        JOIN deleted d ON i.MBSP_ID = d.MBSP_ID;
    END

    IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted)
    BEGIN
        INSERT INTO @DettagliModifiche
        SELECT 
            MBSP_ID, MBSP_Soluzione, MBSP_Code,MBSP_Descr,'DELETE'
        FROM deleted;
    END

    DECLARE cursore CURSOR FOR 
    SELECT * FROM @DettagliModifiche;

    OPEN cursore;
    FETCH NEXT FROM cursore INTO 
         @MBSP_ID, @MBSP_Soluzione, @MBSP_Code, @MBSP_Descr, @OperationType;

    WHILE @@FETCH_STATUS = 0
    BEGIN
	    PRINT('SONO DENTRO IL CURSORE');
	   
        DECLARE @body AS VARCHAR(8000) = '{
           "QUERY":"' + @OperationType + '",
           "TABLE":"MB_SolPag",
           "DATA":{
                "MBSP_ID": "' + CAST(ISNULL(@MBSP_ID, 0) AS VARCHAR) + '",
                "MBSP_Soluzione": "' + CAST(ISNULL(@MBSP_Soluzione, 0) AS VARCHAR) + '",
				"MBSP_Code": "' + CAST(ISNULL(@MBSP_Code, 0) AS VARCHAR) + '",				
                "MBSP_Descr": "' + ISNULL(@MBSP_Descr, '') +'"
            }
        }' -- JSON body for HTTP POST similar to the first trigger
		print(@body);
        EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;
        EXEC sp_OAMethod @Object, 'open', NULL, 'post', @URL, 'false';
        EXEC sp_OAMethod @Object, 'setRequestHeader', NULL, 'Content-Type', 'application/json';
        EXEC sp_OAMethod @Object, 'send', NULL, @body;
        EXEC sp_OAMethod @Object, 'responseText', @ResponseText OUTPUT;

        PRINT @ResponseText;

       IF CHARINDEX('ko',(SELECT @ResponseText)) > 0
		BEGIN
			INSERT INTO dbo.Z_APP_Messaggi
				(ZAPP_Messaggio)
				VALUES('{
           "QUERY":"' + @OperationType + '",
           "TABLE":"MB_SolPag",
           "DATA":{
                "MBSP_ID": "' + CAST(ISNULL(@MBSP_ID, 0) AS VARCHAR) + '",
                "MBSP_Soluzione": "' + CAST(ISNULL(@MBSP_Soluzione, 0) AS VARCHAR) + '",
				"MBSP_Code": "' + CAST(ISNULL(@MBSP_Code, 0) AS VARCHAR) + '",				
                "MBSP_Descr": "' + ISNULL(@MBSP_Descr, '') +'"
            }
        }');
		 SELECT @ResponseText As 'Message'--Creare una tabella messaggi ed aggiungere qui i messaggi da inserire che non sono passati,
		 --se ritorna ko vuol dire che non è stato salvato il messaggio per nessun dispositivo, quindi quando si collega un client 
		 --va fatto il controllo sulla tabella messaggi e se sono presenti si esegue la funzione che inserisce un messaggio per ogni device
		 --e prova ad inviarli.
		END
		ELSE
		BEGIN
		 --SELECT @ResponseText As 'Employee Details'
			print @query;
		END
		EXEC sp_OADestroy @Object
       
        FETCH NEXT FROM cursore INTO 
              @MBSP_ID, @MBSP_Soluzione, @MBSP_Code, @MBSP_Descr, @OperationType;
    END

    CLOSE cursore;
    DEALLOCATE cursore;

    EXEC sp_OADestroy @Object;
END;
```

  * Tipo Articolo VA
```
CREATE TRIGGER [dbo].[Z_APP_MB_TipiArticoloVA] ON [dbo].[MB_TipiArticoloVA]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    PRINT 'ESEGUO TRIGGER';
    SET NOCOUNT ON;

    DECLARE @URL NVARCHAR(MAX);
    SELECT @URL = ZIAP_IndirizzoServer FROM Z_APP_info;
    DECLARE @Object AS INT;
    DECLARE @ResponseText AS VARCHAR(8000);
	DECLARE @query AS VARCHAR(5000);
    DECLARE @OperationType VARCHAR(10);
    DECLARE @MBTA_ID as INT;
    DECLARE @MBTA_Codice as INT;
    DECLARE @MBTA_Descr as VARCHAR(255);

    DECLARE @DettagliModifiche TABLE (
        MBTA_ID INT,
        MBTA_Codice INT,
        MBTA_Descr VARCHAR(255),
        OperationType VARCHAR(10)
    );

    IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO @DettagliModifiche
        SELECT 
            MBTA_ID, MBTA_Codice, MBTA_Descr, 'INSERT'
        FROM inserted;
    END

    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO @DettagliModifiche
        SELECT 
            i.MBTA_ID, i.MBTA_Codice, i.MBTA_Descr,'UPDATE'
        FROM inserted i
        JOIN deleted d ON i.MBTA_ID = d.MBTA_ID;
    END

    IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted)
    BEGIN
        INSERT INTO @DettagliModifiche
        SELECT 
            MBTA_ID, MBTA_Codice, MBTA_Descr, 'DELETE'
        FROM deleted;
    END

    DECLARE cursore CURSOR FOR 
    SELECT * FROM @DettagliModifiche;

    OPEN cursore;
    FETCH NEXT FROM cursore INTO 
        @MBTA_ID, @MBTA_Codice, @MBTA_Descr,  @OperationType;

    WHILE @@FETCH_STATUS = 0
    BEGIN
	    PRINT('SONO DENTRO IL CURSORE');
	   
        DECLARE @body AS VARCHAR(8000) = '{
           "QUERY":"' + @OperationType + '",
           "TABLE":"MB_TipiArticoloVA",
           "DATA":{
                "MBTA_ID": "' + CAST(ISNULL(@MBTA_ID, 0) AS VARCHAR) + '",
                "MBTA_Codice": "' + CAST(ISNULL(@MBTA_Codice, 0) AS VARCHAR) + '",
                "MBTA_Descr": "' + ISNULL(@MBTA_Descr, '') +'"
            }
        }' -- JSON body for HTTP POST similar to the first trigger
		print(@body);
        EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;
        EXEC sp_OAMethod @Object, 'open', NULL, 'post', @URL, 'false';
        EXEC sp_OAMethod @Object, 'setRequestHeader', NULL, 'Content-Type', 'application/json';
        EXEC sp_OAMethod @Object, 'send', NULL, @body;
        EXEC sp_OAMethod @Object, 'responseText', @ResponseText OUTPUT;

        PRINT @ResponseText;

       IF CHARINDEX('ko',(SELECT @ResponseText)) > 0
		BEGIN
			INSERT INTO dbo.Z_APP_Messaggi
				(ZAPP_Messaggio)
				VALUES('{
           "QUERY":"' + @OperationType + '",
           "TABLE":"MB_TipiArticoloVA",
           "DATA":{
                "MBTA_ID": "' + CAST(ISNULL(@MBTA_ID, 0) AS VARCHAR) + '",
                "MBTA_Codice": "' + CAST(ISNULL(@MBTA_Codice, 0) AS VARCHAR) + '",
                "MBTA_Descr": "' + ISNULL(@MBTA_Descr, '') +'"
            }
        }');
		 SELECT @ResponseText As 'Message'--Creare una tabella messaggi ed aggiungere qui i messaggi da inserire che non sono passati,
		 --se ritorna ko vuol dire che non è stato salvato il messaggio per nessun dispositivo, quindi quando si collega un client 
		 --va fatto il controllo sulla tabella messaggi e se sono presenti si esegue la funzione che inserisce un messaggio per ogni device
		 --e prova ad inviarli.
		END
		ELSE
		BEGIN
		 --SELECT @ResponseText As 'Employee Details'
			print @query;
		END
		EXEC sp_OADestroy @Object
       
        FETCH NEXT FROM cursore INTO 
            @MBTA_ID, @MBTA_Codice, @MBTA_Descr,  @OperationType;
    END

    CLOSE cursore;
    DEALLOCATE cursore;

    EXEC sp_OADestroy @Object;
END;

```
  * Tipo Conto
```
CREATE TRIGGER [dbo].[Z_APP_MB_TipoConto] ON [dbo].[MB_TipoConto]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    PRINT 'ESEGUO TRIGGER';
    SET NOCOUNT ON;

    DECLARE @URL NVARCHAR(MAX);
    SELECT @URL = ZIAP_IndirizzoServer FROM Z_APP_info;
    DECLARE @Object AS INT;
    DECLARE @ResponseText AS VARCHAR(8000);
	DECLARE @query AS VARCHAR(5000);
    DECLARE @OperationType VARCHAR(10);
    DECLARE @MBTC_Id as INT;
    DECLARE @MBTC_TipoConto as INT;
   	DECLARE @MBTC_Descr as VARCHAR(255);
    DECLARE @MBTC_Code as VARCHAR(255);

    DECLARE @DettagliModifiche TABLE (
        MBTC_Id INT,
        MBTC_TipoConto INT,
        MBTC_Descr VARCHAR(255),
        MBTC_Code VARCHAR(255),
        OperationType VARCHAR(10)
    );

    IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO @DettagliModifiche
        SELECT 
            MBTC_Id, MBTC_TipoConto, MBTC_Descr,MBTC_Code,'INSERT'
        FROM inserted;
    END

    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO @DettagliModifiche
        SELECT 
           i.MBTC_Id, i.MBTC_TipoConto, i.MBTC_Descr, i.MBTC_Code,'UPDATE'
        FROM inserted i
        JOIN deleted d ON i.MBTC_Id = d.MBTC_Id;
    END

    IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted)
    BEGIN
        INSERT INTO @DettagliModifiche
        SELECT 
            MBTC_Id, MBTC_TipoConto, MBTC_Descr,MBTC_Code,'DELETE'
        FROM deleted;
    END

    DECLARE cursore CURSOR FOR 
    SELECT * FROM @DettagliModifiche;

    OPEN cursore;
    FETCH NEXT FROM cursore INTO 
         @MBTC_Id, @MBTC_TipoConto, @MBTC_Descr, @MBTC_Code, @OperationType;

    WHILE @@FETCH_STATUS = 0
    BEGIN
	    PRINT('SONO DENTRO IL CURSORE');
	   
        DECLARE @body AS VARCHAR(8000) = '{
           "QUERY":"' + @OperationType + '",
           "TABLE":"MB_TipoConto",
           "DATA":{
                "MBTC_Id": "' + CAST(ISNULL(@MBTC_Id, 0) AS VARCHAR) + '",
                "MBTC_TipoConto": "' + CAST(ISNULL(@MBTC_TipoConto, 0) AS VARCHAR) + '",
				"MBTC_Descr": "' + ISNULL(@MBTC_Descr, '') + '",				
                "MBTC_Code": "' + ISNULL(@MBTC_Code, '') +'"
            }
        }' -- JSON body for HTTP POST similar to the first trigger
		print(@body);
        EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;
        EXEC sp_OAMethod @Object, 'open', NULL, 'post', @URL, 'false';
        EXEC sp_OAMethod @Object, 'setRequestHeader', NULL, 'Content-Type', 'application/json';
        EXEC sp_OAMethod @Object, 'send', NULL, @body;
        EXEC sp_OAMethod @Object, 'responseText', @ResponseText OUTPUT;

        PRINT @ResponseText;

       IF CHARINDEX('ko',(SELECT @ResponseText)) > 0
		BEGIN
			INSERT INTO dbo.Z_APP_Messaggi
				(ZAPP_Messaggio)
				VALUES('{
           "QUERY":"' + @OperationType + '",
           "TABLE":"MB_TipoConto",
           "DATA":{
                "MBTC_Id": "' + CAST(ISNULL(@MBTC_Id, 0) AS VARCHAR) + '",
                "MBTC_TipoConto": "' + CAST(ISNULL(@MBTC_TipoConto, 0) AS VARCHAR) + '",
				"MBTC_Descr": "' + ISNULL(@MBTC_Descr, '') + '",				
                "MBTC_Code": "' + ISNULL(@MBTC_Code, '') +'"
            }
        }');
		 SELECT @ResponseText As 'Message'--Creare una tabella messaggi ed aggiungere qui i messaggi da inserire che non sono passati,
		 --se ritorna ko vuol dire che non è stato salvato il messaggio per nessun dispositivo, quindi quando si collega un client 
		 --va fatto il controllo sulla tabella messaggi e se sono presenti si esegue la funzione che inserisce un messaggio per ogni device
		 --e prova ad inviarli.
		END
		ELSE
		BEGIN
		 --SELECT @ResponseText As 'Employee Details'
			print @query;
		END
		EXEC sp_OADestroy @Object
       
        FETCH NEXT FROM cursore INTO 
             @MBTC_Id, @MBTC_TipoConto, @MBTC_Descr, @MBTC_Code, @OperationType;
    END

    CLOSE cursore;
    DEALLOCATE cursore;

    EXEC sp_OADestroy @Object;
END;
```
  * Tipo Pagamento
```
CREATE TRIGGER [dbo].[Z_APP_MB_TipoPag] ON [dbo].[MB_TipoPag]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    PRINT 'ESEGUO TRIGGER';
    SET NOCOUNT ON;

    DECLARE @URL NVARCHAR(MAX);
    SELECT @URL = ZIAP_IndirizzoServer FROM Z_APP_info;
    DECLARE @Object AS INT;
    DECLARE @ResponseText AS VARCHAR(8000);
	DECLARE @query AS VARCHAR(5000);
    DECLARE @OperationType VARCHAR(10);
    DECLARE @MBTP_ID as INT;
    DECLARE @MBTP_Pagamento as INT;
   	DECLARE @MBTP_Effetto as INT;
    DECLARE @MBTP_Descr as VARCHAR(255);

    DECLARE @DettagliModifiche TABLE (
        MBTP_ID INT,
        MBTP_Pagamento INT,
        MBTP_Effetto INT,
        MBTP_Descr VARCHAR(255),
        OperationType VARCHAR(10)
    );

    IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO @DettagliModifiche
        SELECT 
            MBTP_ID, MBTP_Pagamento, MBTP_Effetto,MBTP_Descr,'INSERT'
        FROM inserted;
    END

    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO @DettagliModifiche
        SELECT 
            i.MBTP_ID, i.MBTP_Pagamento, i.MBTP_Effetto, i.MBTP_Descr,'UPDATE'
        FROM inserted i
        JOIN deleted d ON i.MBTP_ID = d.MBTP_ID;
    END

    IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted)
    BEGIN
        INSERT INTO @DettagliModifiche
        SELECT 
            MBTP_ID, MBTP_Pagamento, MBTP_Effetto,MBTP_Descr,'DELETE'
        FROM deleted;
    END

    DECLARE cursore CURSOR FOR 
    SELECT * FROM @DettagliModifiche;

    OPEN cursore;
    FETCH NEXT FROM cursore INTO 
         @MBTP_ID, @MBTP_Pagamento, @MBTP_Effetto, @MBTP_Descr, @OperationType;

    WHILE @@FETCH_STATUS = 0
    BEGIN
	    PRINT('SONO DENTRO IL CURSORE');
	   
        DECLARE @body AS VARCHAR(8000) = '{
           "QUERY":"' + @OperationType + '",
           "TABLE":"MB_TipoPag",
           "DATA":{
                "MBTP_ID": "' + CAST(ISNULL(@MBTP_ID, 0) AS VARCHAR) + '",
                "MBTP_Pagamento": "' + CAST(ISNULL(@MBTP_Pagamento, 0) AS VARCHAR) + '",
				"MBTP_Effetto": "' + CAST(ISNULL(@MBTP_Effetto, 0) AS VARCHAR) + '",				
                "MBTP_Descr": "' + ISNULL(@MBTP_Descr, '') +'"
            }
        }' -- JSON body for HTTP POST similar to the first trigger
		print(@body);
        EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;
        EXEC sp_OAMethod @Object, 'open', NULL, 'post', @URL, 'false';
        EXEC sp_OAMethod @Object, 'setRequestHeader', NULL, 'Content-Type', 'application/json';
        EXEC sp_OAMethod @Object, 'send', NULL, @body;
        EXEC sp_OAMethod @Object, 'responseText', @ResponseText OUTPUT;

        PRINT @ResponseText;

       IF CHARINDEX('ko',(SELECT @ResponseText)) > 0
		BEGIN
			INSERT INTO dbo.Z_APP_Messaggi
				(ZAPP_Messaggio)
				VALUES('{
           "QUERY":"' + @OperationType + '",
           "TABLE":"MB_TipoPag",
           "DATA":{
                "MBTP_ID": "' + CAST(ISNULL(@MBTP_ID, 0) AS VARCHAR) + '",
                "MBTP_Pagamento": "' + CAST(ISNULL(@MBTP_Pagamento, 0) AS VARCHAR) + '",
				"MBTP_Effetto": "' + CAST(ISNULL(@MBTP_Effetto, 0) AS VARCHAR) + '",				
                "MBTP_Descr": "' + ISNULL(@MBTP_Descr, '') +'"
            }
        }');
		 SELECT @ResponseText As 'Message'--Creare una tabella messaggi ed aggiungere qui i messaggi da inserire che non sono passati,
		 --se ritorna ko vuol dire che non è stato salvato il messaggio per nessun dispositivo, quindi quando si collega un client 
		 --va fatto il controllo sulla tabella messaggi e se sono presenti si esegue la funzione che inserisce un messaggio per ogni device
		 --e prova ad inviarli.
		END
		ELSE
		BEGIN
		 --SELECT @ResponseText As 'Employee Details'
			print @query;
		END
		EXEC sp_OADestroy @Object
       
        FETCH NEXT FROM cursore INTO 
              @MBTP_ID, @MBTP_Pagamento, @MBTP_Effetto, @MBTP_Descr, @OperationType;
    END

    CLOSE cursore;
    DEALLOCATE cursore;

    EXEC sp_OADestroy @Object;
END;
```
  * Pagamenti Ordine
```
CREATE TRIGGER [dbo].[Z_APP_OC_Pagam] ON [dbo].[OC_Pagam]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    PRINT 'ESEGUO TRIGGER';
    SET NOCOUNT ON;

    DECLARE @URL NVARCHAR(MAX);
    SELECT @URL = ZIAP_IndirizzoServer FROM Z_APP_info;
    DECLARE @Object AS INT;
    DECLARE @ResponseText AS VARCHAR(8000);
	DECLARE @query AS VARCHAR(5000);
    DECLARE @OperationType VARCHAR(10);
    DECLARE @OCPG_ID as INT;
    DECLARE @OCPG_OCAN_ID as INT;
   	DECLARE @OCPG_MBTP_ID as INT;
    DECLARE @OCPG_MBSP_ID as INT;

    DECLARE @DettagliModifiche TABLE (
        OCPG_ID INT,
        OCPG_OCAN_ID INT,
        OCPG_MBTP_ID INT,
        OCPG_MBSP_ID INT,
        OperationType VARCHAR(10)
    );

    IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO @DettagliModifiche
        SELECT 
            OCPG_ID, OCPG_OCAN_ID, OCPG_MBTP_ID,OCPG_MBSP_ID,'INSERT'
        FROM inserted;
    END

    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO @DettagliModifiche
        SELECT 
           i.OCPG_ID, i.OCPG_OCAN_ID, i.OCPG_MBTP_ID, i.OCPG_MBSP_ID,'UPDATE'
        FROM inserted i
        JOIN deleted d ON i.OCPG_ID = d.OCPG_ID;
    END

    IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted)
    BEGIN
        INSERT INTO @DettagliModifiche
        SELECT 
            OCPG_ID, OCPG_OCAN_ID, OCPG_MBTP_ID,OCPG_MBSP_ID,'DELETE'
        FROM deleted;
    END

    DECLARE cursore CURSOR FOR 
    SELECT * FROM @DettagliModifiche;

    OPEN cursore;
    FETCH NEXT FROM cursore INTO 
         @OCPG_ID, @OCPG_OCAN_ID, @OCPG_MBTP_ID, @OCPG_MBSP_ID, @OperationType;

    WHILE @@FETCH_STATUS = 0
    BEGIN
	    IF EXISTS (SELECT * FROM Z_APP_dispositivi
			WHERE ZAPPD_OCTI_ID IN (
				SELECT OCAN_OCTI_ID FROM OC_pagam
				JOIN OC_Anag ON OCPG_OCAN_ID=OCAN_ID
				WHERE OCPG_ID=@OCPG_ID	
			)
		)
		BEGIN
			
			PRINT('SONO DENTRO IL CURSORE');
		   
	        DECLARE @body AS VARCHAR(8000) = '{
	           "QUERY":"' + @OperationType + '",
	           "TABLE":"OC_Pagam",
	           "DATA":{
	                "OCPG_ID": "' + CAST(ISNULL(@OCPG_ID, 0) AS VARCHAR) + '",
	                "OCPG_OCAN_ID": "' + CAST(ISNULL(@OCPG_OCAN_ID, 0) AS VARCHAR) + '",
					"OCPG_MBTP_ID": "' + CAST(ISNULL(@OCPG_MBTP_ID, 0) AS VARCHAR) + '",				
	                "OCPG_MBSP_ID": "' + CAST(ISNULL(@OCPG_MBSP_ID, 0) AS VARCHAR) +'"
	            }
	        }' -- JSON body for HTTP POST similar to the first trigger
			print(@body);
	        EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;
	        EXEC sp_OAMethod @Object, 'open', NULL, 'post', @URL, 'false';
	        EXEC sp_OAMethod @Object, 'setRequestHeader', NULL, 'Content-Type', 'application/json';
	        EXEC sp_OAMethod @Object, 'send', NULL, @body;
	        EXEC sp_OAMethod @Object, 'responseText', @ResponseText OUTPUT;
	
	        PRINT @ResponseText;
	
	       IF CHARINDEX('ko',(SELECT @ResponseText)) > 0
			BEGIN
				INSERT INTO dbo.Z_APP_Messaggi
					(ZAPP_Messaggio)
					VALUES('{
	           "QUERY":"' + @OperationType + '",
	           "TABLE":"OC_Pagam",
	           "DATA":{
	                "OCPG_ID": "' + CAST(ISNULL(@OCPG_ID, 0) AS VARCHAR) + '",
	                "OCPG_OCAN_ID": "' + CAST(ISNULL(@OCPG_OCAN_ID, 0) AS VARCHAR) + '",
					"OCPG_MBTP_ID": "' + CAST(ISNULL(@OCPG_MBTP_ID, 0) AS VARCHAR) + '",				
	                "OCPG_MBSP_ID": "' + CAST(ISNULL(@OCPG_MBSP_ID, 0) AS VARCHAR) +'"
	            }
	        }');
			 SELECT @ResponseText As 'Message'--Creare una tabella messaggi ed aggiungere qui i messaggi da inserire che non sono passati,
			 --se ritorna ko vuol dire che non è stato salvato il messaggio per nessun dispositivo, quindi quando si collega un client 
			 --va fatto il controllo sulla tabella messaggi e se sono presenti si esegue la funzione che inserisce un messaggio per ogni device
			 --e prova ad inviarli.
			END
			ELSE
			BEGIN
			 --SELECT @ResponseText As 'Employee Details'
				print @query;
			END
			EXEC sp_OADestroy @Object
		END
		
       
        FETCH NEXT FROM cursore INTO 
             @OCPG_ID, @OCPG_OCAN_ID, @OCPG_MBTP_ID, @OCPG_MBSP_ID, @OperationType;
    END

    CLOSE cursore;
    DEALLOCATE cursore;

    IF @Object IS NOT NULL
	BEGIN
	    EXEC sp_OADestroy @Object;
	END

END;
```
  * Tipo Ordine
```
CREATE TRIGGER [dbo].[Z_APP_OC_Tipo] ON [dbo].[OC_Tipo]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    PRINT 'ESEGUO TRIGGER';
    SET NOCOUNT ON;

    DECLARE @URL NVARCHAR(MAX);
    SELECT @URL = ZIAP_IndirizzoServer FROM Z_APP_info;
    DECLARE @Object AS INT;
    DECLARE @ResponseText AS VARCHAR(8000);
	DECLARE @query AS VARCHAR(5000);
    DECLARE @OperationType VARCHAR(10);
    DECLARE @OCTI_ID as INT;
    DECLARE @OCTI_TipNum as INT;
   	DECLARE @OCTI_Tipo as INT;
    DECLARE @OCTI_Descr as VARCHAR(255);

    DECLARE @DettagliModifiche TABLE (
        OCTI_ID INT,
        OCTI_TipNum INT,
        OCTI_Tipo INT,
        OCTI_Descr VARCHAR(255),
        OperationType VARCHAR(10)
    );

    IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO @DettagliModifiche
        SELECT 
            OCTI_ID, OCTI_TipNum, OCTI_Tipo,OCTI_Descr,'INSERT'
        FROM inserted;
    END

    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO @DettagliModifiche
        SELECT 
            i.OCTI_ID, i.OCTI_TipNum,i.OCTI_Tipo,i.OCTI_Descr,'UPDATE'
        FROM inserted i
        JOIN deleted d ON i.OCTI_ID = d.OCTI_ID;
    END

    IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted)
    BEGIN
        INSERT INTO @DettagliModifiche
        SELECT 
            OCTI_ID, OCTI_TipNum, OCTI_Tipo,OCTI_Descr, 'DELETE'
        FROM deleted;
    END

    DECLARE cursore CURSOR FOR 
    SELECT * FROM @DettagliModifiche;

    OPEN cursore;
    FETCH NEXT FROM cursore INTO 
        @OCTI_ID, @OCTI_TipNum, @OCTI_Tipo, @OCTI_Descr, @OperationType;

    WHILE @@FETCH_STATUS = 0
    BEGIN
	    PRINT('SONO DENTRO IL CURSORE');
	   
        DECLARE @body AS VARCHAR(8000) = '{
           "QUERY":"' + @OperationType + '",
           "TABLE":"OC_Tipo",
           "DATA":{
                "OCTI_ID": "' + CAST(ISNULL(@OCTI_ID, 0) AS VARCHAR) + '",
                "OCTI_TipNum": "' + CAST(ISNULL(@OCTI_TipNum, 0) AS VARCHAR) + '",
				"OCTI_Tipo": "' + CAST(ISNULL(@OCTI_Tipo, 0) AS VARCHAR) + '",				
                "OCTI_Descr": "' + ISNULL(@OCTI_Descr, '') +'"
            }
        }' -- JSON body for HTTP POST similar to the first trigger
		print(@body);
        EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;
        EXEC sp_OAMethod @Object, 'open', NULL, 'post', @URL, 'false';
        EXEC sp_OAMethod @Object, 'setRequestHeader', NULL, 'Content-Type', 'application/json';
        EXEC sp_OAMethod @Object, 'send', NULL, @body;
        EXEC sp_OAMethod @Object, 'responseText', @ResponseText OUTPUT;

        PRINT @ResponseText;

       IF CHARINDEX('ko',(SELECT @ResponseText)) > 0
		BEGIN
			INSERT INTO dbo.Z_APP_Messaggi
				(ZAPP_Messaggio)
				VALUES('{
           "QUERY":"' + @OperationType + '",
           "TABLE":OC_AgeArtic oaa _Tipo",
           "DATA":{
                "OCTI_ID": "' + CAST(ISNULL(@OCTI_ID, 0) AS VARCHAR) + '",
                "OCTI_TipNum": "' + CAST(ISNULL(@OCTI_TipNum, 0) AS VARCHAR) + '",
				"OCTI_Tipo": "' + CAST(ISNULL(@OCTI_Tipo, 0) AS VARCHAR) + '",				
                "OCTI_Descr": "' + ISNULL(@OCTI_Descr, '') +'"
            }
        }');
		 SELECT @ResponseText As 'Message'--Creare una tabella messaggi ed aggiungere qui i messaggi da inserire che non sono passati,
		 --se ritorna ko vuol dire che non è stato salvato il messaggio per nessun dispositivo, quindi quando si collega un client 
		 --va fatto il controllo sulla tabella messaggi e se sono presenti si esegue la funzione che inserisce un messaggio per ogni device
		 --e prova ad inviarli.
		END
		ELSE
		BEGIN
		 --SELECT @ResponseText As 'Employee Details'
			print @query;
		END
		EXEC sp_OADestroy @Object
       
        FETCH NEXT FROM cursore INTO 
             @OCTI_ID, @OCTI_TipNum, @OCTI_Tipo, @OCTI_Descr, @OperationType;
    END

    CLOSE cursore;
    DEALLOCATE cursore;

    EXEC sp_OADestroy @Object;
END;
```
  * Partite
```
CREATE TRIGGER [dbo].[Z_APP_Partite]
ON [dbo].[CA_Partite]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
PRINT 'ESEGUO TRIGGER';
	SET NOCOUNT ON;
	DECLARE @URL NVARCHAR(MAX);
	SELECT @URL=ZIAP_IndirizzoServer FROM Z_APP_info;
	DECLARE @Object AS INT;
	DECLARE @ResponseText AS VARCHAR(8000);
	DECLARE @query AS VARCHAR(5000);
	DECLARE @CAPA_ID as INT;
	DECLARE @CAPA_CASP_Stato as INT;
	DECLARE @CAPA_MBPC_ID as INT;
	DECLARE @CAPA_MBDI_ID as INT;
	DECLARE @CAPA_MBTD_ID as INT;
	DECLARE @CAPA_NumPart as INT;
	DECLARE @CAPA_AnnoPart as INT;
	DECLARE @CAPA_Scadenza as datetime;
	DECLARE @CAPA_DataVal as datetime;
	DECLARE @CAPA_DataDoc as datetime;
	DECLARE @CAPA_ImportoDare as DECIMAL(28,2);
	DECLARE @CAPA_ImportoAvere as DECIMAL(28,2);
	DECLARE @CAPA_Residuo as DECIMAL(28,2);
	DECLARE @CAPA_Cambio as INT
	DECLARE @OperationType VARCHAR(10);
	
	DECLARE @DettagliModifiche TABLE (
        CAPA_ID INT,
        CAPA_CASP_Stato INT,
        CAPA_MBPC_ID INT,
        CAPA_MBDI_ID INT,
        CAPA_MBTD_ID INT,
        CAPA_NumPart INT,
        CAPA_AnnoPart INT,
        CAPA_Scadenza datetime,
        CAPA_DataVal datetime,
        CAPA_DataDoc datetime,
        CAPA_ImportoDare DECIMAL(28,2),
        CAPA_ImportoAvere DECIMAL(28,2),
        CAPA_Residuo DECIMAL(28,2),
        CAPA_Cambio INT,
        OperationType VARCHAR(10)
	    );
	   
    -- Handle INSERT
    IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
  	BEGIN
	 	
	
	    -- Inserisci le righe inserite nella variabile di tipo tabella
	    INSERT INTO @DettagliModifiche
	    SELECT 
	        CAPA_ID, CAPA_CASP_Stato, CAPA_MBPC_ID, CAPA_MBDI_ID, CAPA_MBTD_ID,
	        CAPA_NumPart, CAPA_AnnoPart,CAPA_Scadenza, 
	         CAPA_DataVal,CAPA_DataDoc,
	        CAPA_ImportoDare, CAPA_ImportoAvere, CAPA_Residuo, CAPA_Cambio,'INSERT'
	    FROM inserted;   

        -- Esempio: Invio di un'email per l'inserimento
    END
    -- Handle UPDATE
    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
      INSERT INTO @DettagliModifiche
        SELECT 
            i.CAPA_ID, i.CAPA_CASP_Stato, i.CAPA_MBPC_ID, i.CAPA_MBDI_ID, i.CAPA_MBTD_ID,
            i.CAPA_NumPart, i.CAPA_AnnoPart, i.CAPA_Scadenza, i.CAPA_DataVal, i.CAPA_DataDoc,
            i.CAPA_ImportoDare, i.CAPA_ImportoAvere, i.CAPA_Residuo, i.CAPA_Cambio,
            'UPDATE'
        FROM inserted i
        JOIN deleted d ON i.CAPA_ID = d.CAPA_ID
        WHERE i.CAPA_CASP_Stato != d.CAPA_CASP_Stato 
           OR i.CAPA_MBPC_ID != d.CAPA_MBPC_ID
           OR i.CAPA_MBDI_ID != d.CAPA_MBDI_ID
           OR i.CAPA_MBTD_ID != d.CAPA_MBTD_ID
           OR i.CAPA_NumPart != d.CAPA_NumPart
           OR i.CAPA_AnnoPart != d.CAPA_AnnoPart
           OR i.CAPA_Scadenza != d.CAPA_Scadenza
           OR i.CAPA_DataVal != d.CAPA_DataVal
           OR i.CAPA_DataDoc != d.CAPA_DataDoc
           OR i.CAPA_ImportoDare != d.CAPA_ImportoDare
           OR i.CAPA_ImportoAvere != d.CAPA_ImportoAvere
           OR i.CAPA_Residuo != d.CAPA_Residuo
           OR i.CAPA_Cambio != d.CAPA_Cambio
    END
    -- Handle DELETE
    IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted)
    BEGIN
        -- Qui puoi gestire il DELETE
        -- Esempio: Archiviazione dei dati cancellati
	    INSERT INTO @DettagliModifiche
        SELECT 
            CAPA_ID, CAPA_CASP_Stato, CAPA_MBPC_ID, CAPA_MBDI_ID, CAPA_MBTD_ID,
            CAPA_NumPart, CAPA_AnnoPart, CAPA_Scadenza, CAPA_DataVal, CAPA_DataDoc,
            CAPA_ImportoDare, CAPA_ImportoAvere, CAPA_Residuo, CAPA_Cambio,
            'DELETE'
        FROM deleted;
    END
    
    DECLARE cursore CURSOR FOR 
    SELECT ISNULL(CAPA_ID,-1) as CAPA_ID, ISNULL(CAPA_CASP_Stato,-1) as CAPA_CASP_Stato, ISNULL(CAPA_MBPC_ID,-1) as CAPA_MBPC_ID, ISNULL(CAPA_MBDI_ID,-1) as CAPA_MBDI_ID, 
    ISNULL(CAPA_MBTD_ID,-1) as CAPA_MBTD_ID, ISNULL(CAPA_NumPart,-1) as CAPA_NumPart, ISNULL(CAPA_AnnoPart,-1) as CAPA_AnnoPart, ISNULL(CAPA_Scadenza,-1) as CAPA_Scadenza, 
    ISNULL(CAPA_DataVal,0) as CAPA_DataVal, ISNULL(CAPA_DataDoc,0) as CAPA_DataDoc,ISNULL(CAPA_ImportoDare,1.1) as CAPA_ImportoDare, ISNULL(CAPA_ImportoAvere,1.1) as CAPA_ImportoAvere, 
    ISNULL(CAPA_Residuo,1.1) as CAPA_Residuo, ISNULL(CAPA_Cambio,-1) as CAPA_Cambio, ISNULL(OperationType,'null') as OperationType
    FROM @DettagliModifiche;
   
   	OPEN cursore;
    FETCH NEXT FROM cursore INTO @CAPA_ID, @CAPA_CASP_Stato, @CAPA_MBPC_ID, @CAPA_MBDI_ID, @CAPA_MBTD_ID,
        @CAPA_NumPart, @CAPA_AnnoPart, @CAPA_Scadenza, @CAPA_DataVal, @CAPA_DataDoc,
        @CAPA_ImportoDare, @CAPA_ImportoAvere, @CAPA_Residuo, @CAPA_Cambio, @OperationType;
   
   WHILE @@FETCH_STATUS = 0
   
   BEGIN
	    DECLARE @body AS VARCHAR(8000) =
		'{

			   "QUERY":"'+@OperationType+'",
			   "TABLE":"CA_Partite",
			   "DATA":{
					"CAPA_Id": "' + CAST(@CAPA_ID AS VARCHAR) + '",
					"CAPA_CASP_Stato": "' + CAST(@CAPA_CASP_Stato AS VARCHAR) + '",
					"CAPA_MBPC_ID": "' + CAST(@CAPA_MBPC_ID AS VARCHAR) + '",
					"CAPA_MBDI_ID": "' + CAST(@CAPA_MBDI_ID AS VARCHAR) + '",
					"CAPA_MBTD_ID": "' + CAST(@CAPA_MBTD_ID AS VARCHAR) + '",
					"CAPA_NumPart": "' + CAST(@CAPA_NumPart AS VARCHAR) + '",
					"CAPA_AnnoPart": "' + CAST(@CAPA_AnnoPart AS VARCHAR) + '",
					"CAPA_Scadenza": "'+CONVERT(VARCHAR, @CAPA_Scadenza,120)+'",
					"CAPA_DataVal": "'+CONVERT(VARCHAR, @CAPA_DataVal,120)+'",
					"CAPA_DataDoc": "'+CONVERT(VARCHAR, @CAPA_DataDoc,120)+'",
					"CAPA_ImportoDare": "' + CAST(@CAPA_ImportoDare AS VARCHAR) + '",
					"CAPA_ImportoAvere": "' + CAST(@CAPA_ImportoAvere AS VARCHAR) + '",
					"CAPA_Residuo": "' + CAST(@CAPA_Residuo AS VARCHAR) + '",
					"CAPA_Cambio": "' + CAST(@CAPA_Cambio AS VARCHAR) + '"
					}
		}'
			
		PRINT @body;
		EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;
		EXEC sp_OAMethod @Object, 'open', NULL, 'post',
		                 @URL,
		                 'false'
		EXEC sp_OAMethod @Object, 'setRequestHeader', null, 'Content-Type', 'application/json'
		EXEC sp_OAMethod @Object, 'send', null, @body
		EXEC sp_OAMethod @Object, 'responseText', @ResponseText OUTPUT
		PRINT @Responsetext
		IF CHARINDEX('ko',(SELECT @ResponseText)) > 0
		BEGIN
			INSERT INTO dbo.Z_APP_Messaggi
				(ZAPP_Messaggio)
				VALUES('{

			   "QUERY":"'+@OperationType+'",
			   "TABLE":"CA_Partite",
			   "DATA":{
					"CAPA_Id": "' + CAST(@CAPA_ID AS VARCHAR) + '",
					"CAPA_CASP_Stato": "' + CAST(@CAPA_CASP_Stato AS VARCHAR) + '",
					"CAPA_MBPC_ID": "' + CAST(@CAPA_MBPC_ID AS VARCHAR) + '",
					"CAPA_MBDI_ID": "' + CAST(@CAPA_MBDI_ID AS VARCHAR) + '",
					"CAPA_MBTD_ID": "' + CAST(@CAPA_MBTD_ID AS VARCHAR) + '",
					"CAPA_NumPart": "' + CAST(@CAPA_NumPart AS VARCHAR) + '",
					"CAPA_AnnoPart": "' + CAST(@CAPA_AnnoPart AS VARCHAR) + '",
					"CAPA_Scadenza": "'+CONVERT(VARCHAR, @CAPA_Scadenza,120)+'",
					"CAPA_DataVal": "'+CONVERT(VARCHAR, @CAPA_DataVal,120)+'",
					"CAPA_DataDoc": "'+CONVERT(VARCHAR, @CAPA_DataDoc,120)+'",
					"CAPA_ImportoDare": "' + CAST(@CAPA_ImportoDare AS VARCHAR) + '",
					"CAPA_ImportoAvere": "' + CAST(@CAPA_ImportoAvere AS VARCHAR) + '",
					"CAPA_Residuo": "' + CAST(@CAPA_Residuo AS VARCHAR) + '",
					"CAPA_Cambio": "' + CAST(@CAPA_Cambio AS VARCHAR) + '"
					}
		}');
		 SELECT @ResponseText As 'Message'--Creare una tabella messaggi ed aggiungere qui i messaggi da inserire che non sono passati,
		 --se ritorna ko vuol dire che non è stato salvato il messaggio per nessun dispositivo, quindi quando si collega un client 
		 --va fatto il controllo sulla tabella messaggi e se sono presenti si esegue la funzione che inserisce un messaggio per ogni device
		 --e prova ad inviarli.
		END
		ELSE
		BEGIN
		 --SELECT @ResponseText As 'Employee Details'
			print @query;
		END
		EXEC sp_OADestroy @Object
	   FETCH NEXT FROM cursore INTO @CAPA_ID, @CAPA_CASP_Stato, @CAPA_MBPC_ID, @CAPA_MBDI_ID, @CAPA_MBTD_ID,
        @CAPA_NumPart, @CAPA_AnnoPart, @CAPA_Scadenza, @CAPA_DataVal, @CAPA_DataDoc,
        @CAPA_ImportoDare, @CAPA_ImportoAvere, @CAPA_Residuo, @CAPA_Cambio, @OperationType;
   END
   CLOSE cursore;
   DEALLOCATE cursore;
END;
```
  * Anagrafiche Articoli
```
CREATE TRIGGER [dbo].[Z_APP_AnaArt] ON [dbo].[MG_AnaArt]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    INSERT INTO Z_APP_LOG (ZALO_Messaggio, ZALO_Provenienza) VALUES ('ESEGUO TRIGGER Aggiornamento Anagrafiche Articoli','TRIGGER: MG_AnaArt');
    SET NOCOUNT ON;

    DECLARE @URL NVARCHAR(MAX);
    SELECT @URL = ZIAP_IndirizzoServer FROM Z_APP_info;
    DECLARE @Object AS INT;
    DECLARE @ResponseText AS VARCHAR(8000);
	DECLARE @query AS VARCHAR(5000);
    DECLARE @OperationType AS VARCHAR(10);
    DECLARE @MGAA_ID AS INT;
    DECLARE @MGAA_Descr AS VARCHAR(100);
    DECLARE @MGAA_Matricola AS VARCHAR(50);
    DECLARE @MGAA_MBIV_ID AS INT
    DECLARE @MGAA_MBDC_Classe AS VARCHAR(50);
    DECLARE @MGAA_MBUM_Codice AS VARCHAR(10);
    DECLARE @MGAA_Stato AS INT;
    DECLARE @MGAA_PVendita AS DECIMAL(18,2);


    DECLARE @DettagliModifiche TABLE (
        MGAA_ID INT,
        MGAA_Descr VARCHAR(100),
        MGAA_Matricola VARCHAR(50),
        MGAA_MBIV_ID INT,
        MGAA_MBDC_Classe VARCHAR(50),
        MGAA_MBUM_Codice varchar(10),
        MGAA_Stato INT,
        MGAA_PVendita DECIMAL(18,2),
        OperationType VARCHAR(10)
    );

    IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO @DettagliModifiche
        SELECT 
            MGAA_ID, MGAA_Descr, MGAA_Matricola, MGAA_MBIV_ID, MGAA_MBDC_Classe,MGAA_MBUM_Codice, MGAA_Stato,
            MGAA_PVendita, 'INSERT'
        FROM inserted;
    END

    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO @DettagliModifiche
        SELECT 
            i.MGAA_ID, i.MGAA_Descr, i.MGAA_Matricola, i.MGAA_MBIV_ID, i.MGAA_MBDC_Classe,i.MGAA_MBUM_Codice, i.MGAA_Stato,
            i.MGAA_PVendita, 'UPDATE'
        FROM inserted i
        JOIN deleted d ON i.MGAA_ID = d.MGAA_ID;
    END

    IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted)
    BEGIN
        INSERT INTO @DettagliModifiche
        SELECT 
            MGAA_ID, MGAA_Descr, MGAA_Matricola, MGAA_MBIV_ID, MGAA_MBDC_Classe,MGAA_MBUM_Codice, MGAA_Stato,
            MGAA_PVendita, 'DELETE'
        FROM deleted;
    END

    DECLARE cursore CURSOR FOR 
    SELECT * FROM @DettagliModifiche;

    OPEN cursore;
    FETCH NEXT FROM cursore INTO 
        @MGAA_ID, @MGAA_Descr, @MGAA_Matricola, @MGAA_MBIV_ID, @MGAA_MBDC_Classe, @MGAA_MBUM_Codice, @MGAA_Stato,
            @MGAA_PVendita, @OperationType;

    WHILE @@FETCH_STATUS = 0
    BEGIN
	        DECLARE @body AS VARCHAR(8000) = '{
	           "QUERY":"' + @OperationType + '",
	           "TABLE":"MG_AnaArt",
	           "DATA":{
	                "MGAA_ID": "' + CAST(ISNULL(@MGAA_ID, 0) AS VARCHAR) + '",
	                "MGAA_Descr": "' + ISNULL(@MGAA_Descr, '') + '",
	                "MGAA_Matricola": "' + ISNULL(@MGAA_Matricola, '')+ '",
	                "MGAA_MBIV_ID": "' + CAST(ISNULL(@MGAA_MBIV_ID, 0) AS VARCHAR) + '",
	                "MGAA_MBDC_Classe": "' + ISNULL(@MGAA_MBDC_Classe, '') + '",
	                "MGAA_MBUM_Codice": "' + ISNULL(@MGAA_MBUM_Codice, '') + '",
	                "MGAA_Stato": "' + CAST(ISNULL(@MGAA_Stato, 0) AS VARCHAR) + '",
	                "MGAA_PVendita": "' + ISNULL(CAST(@MGAA_PVendita AS VARCHAR),0) + '"
	            }
	        }' -- JSON body for HTTP POST similar to the first trigger
			print(@body);
	        EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;
	        EXEC sp_OAMethod @Object, 'open', NULL, 'post', @URL, 'false';
	        EXEC sp_OAMethod @Object, 'setRequestHeader', NULL, 'Content-Type', 'application/json';
	        EXEC sp_OAMethod @Object, 'send', NULL, @body;
	        EXEC sp_OAMethod @Object, 'responseText', @ResponseText OUTPUT;
	
	
	       IF CHARINDEX('ko',(SELECT @ResponseText)) > 0
			BEGIN
				INSERT INTO dbo.Z_APP_Messaggi
					(ZAPP_Messaggio)
					VALUES('{
	           "QUERY":"' + @OperationType + '",
	           "TABLE":"MG_AnaArt",
	           "DATA":{
	                "MGAA_ID": "' + CAST(ISNULL(@MGAA_ID, 0) AS VARCHAR) + '",
	                "MGAA_Descr": "' + ISNULL(@MGAA_Descr, '') + '",
	                "MGAA_Matricola": "' + ISNULL(@MGAA_Matricola, '')+ '",
	                "MGAA_MBIV_ID": "' + CAST(ISNULL(@MGAA_MBIV_ID, 0) AS VARCHAR) + '",
	                "MGAA_MBDC_Classe": "' + ISNULL(@MGAA_MBDC_Classe, '') + '",
	                "MGAA_MBUM_Codice": "' + ISNULL(@MGAA_MBUM_Codice, '') + '",
	                "MGAA_Stato": "' + CAST(ISNULL(@MGAA_Stato, 0) AS VARCHAR) + '",
	                "MGAA_PVendita": "' + ISNULL(CAST(@MGAA_PVendita AS VARCHAR),0) + '"
	            }
	        }');		
			END
			EXEC sp_OADestroy @Object
		
		
	       
	    FETCH NEXT FROM cursore INTO 
	        @MGAA_ID, @MGAA_Descr, @MGAA_Matricola, @MGAA_MBIV_ID, @MGAA_MBDC_Classe, @MGAA_MBUM_Codice, @MGAA_Stato,
            @MGAA_PVendita, @OperationType;
    END

    CLOSE cursore;
    DEALLOCATE cursore;

    IF @Object IS NOT NULL
	BEGIN
	    EXEC sp_OADestroy @Object;
	END
END;
```
<a name="ed_Trigger"></a>
  * ENABLE/DISABLE Trigger
```
ENABLE TRIGGER [dbo].[Z_APP_TR_OC_Anag] ON [dbo].[OC_Anag];
ENABLE TRIGGER [dbo].[Z_APP_TR_BL_Anag] ON [dbo].[BL_Anag];
ENABLE TRIGGER [dbo].[Z_APP_TR_FT_Anag] ON [dbo].[FT_Anag];
ENABLE TRIGGER [dbo].[Z_APP_Z_PrezziTv] ON [dbo].[Z_PrezziTv];
ENABLE TRIGGER [dbo].[Z_APP_BL_Pagam] ON [dbo].[BL_Pagam];
ENABLE TRIGGER [dbo].[Z_APP_BL_Tipo] ON [dbo].[BL_Tipo];
ENABLE TRIGGER [dbo].[Z_APP_FT_Pagam] ON [dbo].[FT_Pagam];
ENABLE TRIGGER [dbo].[Z_APP_FT_Tipo] ON [dbo].[FT_Tipo];
ENABLE TRIGGER [dbo].[Z_APP_MB_Agenti] ON [dbo].[MB_Agenti];
ENABLE TRIGGER [dbo].[Z_APP_MB_Iva] ON [dbo].[MB_Iva];
ENABLE TRIGGER [dbo].[Z_APP_MB_SolPag] ON [dbo].[MB_SolPag];
ENABLE TRIGGER [dbo].[Z_APP_MB_TipiArticoloVA] ON [dbo].[MB_TipiArticoloVA];
ENABLE TRIGGER [dbo].[Z_APP_MB_TipoConto] ON [dbo].[MB_TipoConto];
ENABLE TRIGGER [dbo].[Z_APP_MB_TipoPag] ON [dbo].[MB_TipoPag];
ENABLE TRIGGER [dbo].[Z_APP_OC_Pagam] ON [dbo].[OC_Pagam];
ENABLE TRIGGER [dbo].[Z_APP_OC_Tipo] ON [dbo].[OC_Tipo];
ENABLE TRIGGER [dbo].[Z_APP_Partite] ON [dbo].[CA_Partite];
ENABLE TRIGGER [dbo].[Z_APP_AnaArt] ON [dbo].[MG_AnaArt];
ENABLE TRIGGER [dbo].[Z_APP_Anagr] ON [dbo].[MB_Anagr];

DISABLE TRIGGER [dbo].[Z_APP_TR_OC_Anag] ON [dbo].[OC_Anag];
DISABLE TRIGGER [dbo].[Z_APP_TR_BL_Anag] ON [dbo].[BL_Anag];
DISABLE TRIGGER [dbo].[Z_APP_TR_FT_Anag] ON [dbo].[FT_Anag];
DISABLE TRIGGER [dbo].[Z_APP_Z_PrezziTv] ON [dbo].[Z_PrezziTv];
DISABLE TRIGGER [dbo].[Z_APP_BL_Pagam] ON [dbo].[BL_Pagam];
DISABLE TRIGGER [dbo].[Z_APP_BL_Tipo] ON [dbo].[BL_Tipo];
DISABLE TRIGGER [dbo].[Z_APP_FT_Pagam] ON [dbo].[FT_Pagam];
DISABLE TRIGGER [dbo].[Z_APP_FT_Tipo] ON [dbo].[FT_Tipo];
DISABLE TRIGGER [dbo].[Z_APP_MB_Agenti] ON [dbo].[MB_Agenti];
DISABLE TRIGGER [dbo].[Z_APP_MB_Iva] ON [dbo].[MB_Iva];
DISABLE TRIGGER [dbo].[Z_APP_MB_SolPag] ON [dbo].[MB_SolPag];
DISABLE TRIGGER [dbo].[Z_APP_MB_TipiArticoloVA] ON [dbo].[MB_TipiArticoloVA];
DISABLE TRIGGER [dbo].[Z_APP_MB_TipoConto] ON [dbo].[MB_TipoConto];
DISABLE TRIGGER [dbo].[Z_APP_MB_TipoPag] ON [dbo].[MB_TipoPag];
DISABLE TRIGGER [dbo].[Z_APP_OC_Pagam] ON [dbo].[OC_Pagam];
DISABLE TRIGGER [dbo].[Z_APP_OC_Tipo] ON [dbo].[OC_Tipo];
DISABLE TRIGGER [dbo].[Z_APP_Partite] ON [dbo].[CA_Partite];
DISABLE TRIGGER [dbo].[Z_APP_AnaArt] ON [dbo].[MG_AnaArt];
DISABLE TRIGGER [dbo].[Z_APP_Anagr] ON [dbo].[MB_Anagr];
```
  * trigger
```
```
  * trigger
```
```
  * trigger
```
```
* Aggiungere le seguenti funzioni
```
/****** Object:  UserDefinedFunction [dbo].[Z_APP_Disponibilita]    Script Date: 11/13/2024 17:04:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[Z_APP_Disponibilita] (@MGAA_ID INT) RETURNS FLOAT
AS
BEGIN
DECLARE @GIAC DECIMAL(28,15),@IMP DECIMAL(28,15),@DISP INT
declare @DataChiusura datetime
	set @DataChiusura=NULL
	SELECT TOP 1 @DataChiusura=MGPA_DataUltChiusura FROM MG_Parametri WHERE MGPA_Anno=YEAR(GETDATE())

	set @GIAC= (SELECT SUM(ISNULL(MGMV_Quantita,0.0))
			FROM MG_Movimenti JOIN MG_registrazioni ON MGRG_Id=MGMV_MGRG_Id
			WHERE 	MGRG_Data > ISNULL(@DataChiusura,'01/01/1900')
				AND MGRG_MBMG_Id=53 AND mgmv_mgaa_id=@MGAA_ID)
	
	set @IMP= isnull((
			select sum(OCAR_DQta)
			from   	OC_Artic join OC_Anag on 
				OCAR_OCAN_Id=OCAN_Id JOIN OC_Tipo ON OCTI_Id=OCAN_OCTI_Id
			where  	OCAN_NumOrd>0 AND
				OCAN_EvasoForz=0 /*and OCAN_DataConf IS NOT NULL and OCAN_Stamp<>0*/ AND
				OCAR_MGAA_Id =@MGAA_ID and 
				OCAR_EForz=0 AND OCAR_MBMG_Id=53 AND OCAR_DQta>0
			),0)
	
	SELECT @DISP=ISNULL(@GIAC,0)-ISNULL(@IMP,0)
RETURN @DISP
END
GO
```

```
/****** Object:  UserDefinedFunction [dbo].[Z_APP_ProssimoNumeroORdine]    Script Date: 11/13/2024 17:04:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

	CREATE FUNCTION [dbo].[Z_APP_ProssimoNumeroORdine] (@OCAN_OCTI_ID INT)
RETURNS INT
AS
BEGIN
    DECLARE @NextOrderNumber INT;

    -- Calcola il massimo valore di OCAN_NumOrd per il dato OCAN_OCTI_ID e aggiungi 1
    SELECT @NextOrderNumber = COALESCE(MAX(CAST(OCAN_NumOrd AS INT)), 0) + 1
    FROM OC_Anag
    WHERE OCAN_OCTI_ID = @OCAN_OCTI_ID AND OCAN_AnnoOrd=YEAR(GETDATE());

    -- Restituisce il valore calcolato
    RETURN @NextOrderNumber;
END;
GO
```
* Schedulare con SQLServerAgent la procedura per aggiornamento prezzi.
  
## Modifiche su YES

* Aggiungere su TipiBolla, TipiOrdine e TipiFattura la stored corrispondente in chiusura.


## Usare questa query per controlare su un database di produzione es. gelomare quali sono effettivamente le tabelle le funzioni e i trigger 
```
/* ============================================================
   CONTEX: Database di lavoro
   ============================================================ */
USE [TestVendite];
/* niente GO qui, cosÏ la @patterns resta valida per tutto lo script */

/* ============================================================
   Prefissi da cercare nei N O M I (underscore come carattere)
   ============================================================ */
DECLARE @patterns TABLE (pattern sysname NOT NULL);
INSERT INTO @patterns(pattern)
VALUES (N'Z[_]APP%'), (N'ZAPP[_]%');

/* ============================================================
   A) Oggetti IL CUI NOME inizia con Z_APP o ZAPP_
   (tabelle, viste, procedure, funzioni, trigger DML/DDL)
   ============================================================ */
SELECT 'TABLE' AS kind, s.name AS [schema], t.name AS object_name
FROM sys.tables AS t
JOIN sys.schemas AS s ON s.schema_id = t.schema_id
WHERE EXISTS (SELECT 1 FROM @patterns p WHERE t.name LIKE p.pattern)

UNION ALL
SELECT 'VIEW', s.name, v.name
FROM sys.views AS v
JOIN sys.schemas AS s ON s.schema_id = v.schema_id
WHERE EXISTS (SELECT 1 FROM @patterns p WHERE v.name LIKE p.pattern)

UNION ALL
SELECT 'FUNCTION', s.name, o.name
FROM sys.objects AS o
JOIN sys.schemas AS s ON s.schema_id = o.schema_id
WHERE o.type IN ('FN','IF','TF','FS','FT')  -- scalar, inline TVF, TVF, CLR scalar, CLR TVF
  AND EXISTS (SELECT 1 FROM @patterns p WHERE o.name LIKE p.pattern)

UNION ALL
-- Trigger DML (su tabelle/viste)
SELECT 'TRIGGER (DML)',
       OBJECT_SCHEMA_NAME(tr.parent_id) AS [schema],
       tr.name AS object_name
FROM sys.triggers AS tr
WHERE tr.parent_class_desc = 'OBJECT_OR_COLUMN'
  AND EXISTS (SELECT 1 FROM @patterns p WHERE tr.name LIKE p.pattern)
```