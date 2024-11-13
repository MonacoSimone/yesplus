# YES+

Applicazione Mobile per integrazione gestionale YES

## Installazione APP

passaggi per l'installazione dell'app

## Installazione Server

## Aggiornamenti DB

* Creare le tabelle necessarie
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
* Inserire nella tabella Z_APP_info l'indirizzo del server API con la chiamata **/trigger**
```
INSERT INTO [TestTrigger].[dbo].[Z_APP_Info]
           ([ZIAP_ID]
           ,[ZIAP_IndirizzoServer])
     VALUES
           (0
           ,'HTTP://127.0.0.1:5000/trigger')
GO
```
* Aggiornare le tabelle FT_Anag, OC_Anag, BL_Anag, FT_Artic, OC_Artic, BL_Artic come segue
```
  ALTER TABLE FT_Anag
  ALTER COLUMN FTAN_APP_ID VARCHAR(50);
```
```
  ALTER TABLE OC_Anag
  ALTER COLUMN OCAN_APP_ID VARCHAR(50);
```
```
  ALTER TABLE BL_Anag
  ALTER COLUMN BLAN_APP_ID VARCHAR(50);
```
```
  ALTER TABLE FT_Artic
  ALTER COLUMN FTAR_APP_ID VARCHAR(50);
```
```
  ALTER TABLE OC_Artic
  ALTER COLUMN OCAR_APP_ID VARCHAR(50);
```
```
  ALTER TABLE BL_Artic
  ALTER COLUMN BLAR_APP_ID VARCHAR(50);
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
USE [TestTrigger]
GO

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
