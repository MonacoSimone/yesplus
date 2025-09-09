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
	[ZAPPD_imei] [varchar](255) NOT NULL,
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

CREATE UNIQUE NONCLUSTERED INDEX IX_Z_APP_dispositivi_ZAPPD_imei
ON [dbo].[Z_APP_dispositivi] ([ZAPPD_imei])

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
<a name="Z_APP_DeletedRows"></a>
- Nella tabella **Z_APP_DeletedRows** vengono salvate i TIMESTAMP delle righe cancellate nelle altre tabelle

```
CREATE TABLE [dbo].[Z_APP_DeletedRows] (
    Z_IS_LastEditDate BIGINT NOT NULL PRIMARY KEY
);
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

<a name="timestamp_col"></a>
    - Inserire le colonne TIMESTAMP (alcune di queste colonne sono già presenti)
```
ALTER TABLE [dbo].[OC_Anag] ADD OCAN_IS_LastEditDate TIMESTAMP;
GO
ALTER TABLE [dbo].[BL_Anag] ADD BLAN_IS_LastEditDate TIMESTAMP;
GO
ALTER TABLE [dbo].[FT_Anag] ADD FTAN_IS_LastEditDate TIMESTAMP;
GO
ALTER TABLE [dbo].[Z_PrezziTv] ADD ZPTV_IS_LastEditDate TIMESTAMP;
GO
ALTER TABLE [dbo].[BL_Pagam] ADD BLPG_IS_LastEditDate TIMESTAMP;
GO
ALTER TABLE [dbo].[BL_Tipo] ADD BLTI_IS_LastEditDate TIMESTAMP;
GO
ALTER TABLE [dbo].[FT_Pagam] ADD FTPG_IS_LastEditDate TIMESTAMP;
GO
ALTER TABLE [dbo].[FT_Tipo] ADD FTTI_IS_LastEditDate TIMESTAMP;
GO
ALTER TABLE [dbo].[MB_Agenti] ADD MBAG_IS_LastEditDate TIMESTAMP;
GO
ALTER TABLE [dbo].[MB_Iva] ADD MBIV_IS_LastEditDate TIMESTAMP;
GO
ALTER TABLE [dbo].[MB_SolPag] ADD MBSP_IS_LastEditDate TIMESTAMP;
GO
ALTER TABLE [dbo].[MB_TipiArticoloVA] ADD MBTA_IS_LastEditDate TIMESTAMP;
GO
ALTER TABLE [dbo].[MB_TipoConto] ADD MBTC_IS_LastEditDate TIMESTAMP;
GO
ALTER TABLE [dbo].[MB_TipoPag] ADD MBTP_IS_LastEditDate TIMESTAMP;
GO
ALTER TABLE [dbo].[OC_Pagam] ADD OCPG_IS_LastEditDate TIMESTAMP;
GO
ALTER TABLE [dbo].[OC_Tipo] ADD OCTI_IS_LastEditDate TIMESTAMP;
GO
ALTER TABLE [dbo].[CA_Partite] ADD CAPA_IS_LastEditDate TIMESTAMP;
GO
ALTER TABLE [dbo].[MG_AnaArt] ADD MGAA_IS_LastEditDate TIMESTAMP;
GO
ALTER TABLE [dbo].[MB_Anagr] ADD MBAN_IS_LastEditDate TIMESTAMP;
GO
ALTER TABLE [dbo].[MB_CliForDestinatari] ADD MBDT_IS_LastEditDate TIMESTAMP;
GO
ALTER TABLE [dbo].[MB_CliFor] ADD MBCF_IS_LastEditDate TIMESTAMP;
GO
ALTER TABLE [dbo].[MB_CliForSconti] ADD MBSC_IS_LastEditDate TIMESTAMP;
GO
ALTER TABLE [dbo].[FT_Artic] ADD FTAR_IS_LastEditDate TIMESTAMP;
GO
ALTER TABLE [dbo].[OC_Artic] ADD OCAR_IS_LastEditDate TIMESTAMP;
GO
ALTER TABLE [dbo].[BL_Artic] ADD BLAR_IS_LastEditDate TIMESTAMP;
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
DROP PROCEDURE [dbo].[Z_APP_OC_Anag]
GO
```
* **Bolle**
```
DROP PROCEDURE [dbo].[Z_APP_BL_Anag]
GO
```
* **Fatture**
```
DROP PROCEDURE [dbo].[Z_APP_FT_Anag]
GO
```
* Creare I trigger per la cancellazione di Ordini/Bolle/Fatture da YES
```
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

DROP TRIGGER [dbo].[Z_APP_TR_OC_Anag];
GO
CREATE TRIGGER [dbo].[Z_APP_TR_OC_Anag]
ON [dbo].[OC_Anag]
FOR DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM [dbo].[Z_APP_DeletedRows] 
    WHERE Z_IS_LastEditDate IN (
        SELECT CAST(OCAN_IS_LastEditDate AS BIGINT) 
        FROM deleted
    );
    
    INSERT INTO [dbo].[Z_APP_DeletedRows] (Z_IS_LastEditDate)
    SELECT CAST(OCAN_IS_LastEditDate AS BIGINT)
    FROM deleted;
END
GO

DROP TRIGGER [dbo].[Z_APP_TR_BL_Anag];
GO
CREATE TRIGGER [dbo].[Z_APP_TR_BL_Anag]
ON [dbo].[BL_Anag]
FOR DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM [dbo].[Z_APP_DeletedRows] 
    WHERE Z_IS_LastEditDate IN (
        SELECT CAST(BLAN_IS_LastEditDate AS BIGINT) 
        FROM deleted
    );
    
    INSERT INTO [dbo].[Z_APP_DeletedRows] (Z_IS_LastEditDate)
    SELECT CAST(BLAN_IS_LastEditDate AS BIGINT)
    FROM deleted;
END
GO

DROP TRIGGER [dbo].[Z_APP_TR_FT_Anag];
GO
CREATE TRIGGER [dbo].[Z_APP_TR_FT_Anag] 
ON [dbo].[FT_Anag]
FOR DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM [dbo].[Z_APP_DeletedRows] 
    WHERE Z_IS_LastEditDate IN (
        SELECT CAST(FTAN_IS_LastEditDate AS BIGINT) 
        FROM deleted
    );
    
    INSERT INTO [dbo].[Z_APP_DeletedRows] (Z_IS_LastEditDate)
    SELECT CAST(FTAN_IS_LastEditDate AS BIGINT)
    FROM deleted;
END
GO

DROP TRIGGER [dbo].[Z_APP_Z_PrezziTv];
GO
CREATE TRIGGER [dbo].[Z_APP_Z_PrezziTv]
ON [dbo].[Z_PrezziTv]
FOR DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM [dbo].[Z_APP_DeletedRows] 
    WHERE Z_IS_LastEditDate IN (
        SELECT CAST(ZPTV_IS_LastEditDate AS BIGINT) 
        FROM deleted
    );
    
    INSERT INTO [dbo].[Z_APP_DeletedRows] (Z_IS_LastEditDate)
    SELECT CAST(ZPTV_IS_LastEditDate AS BIGINT)
    FROM deleted;
END
GO

DROP TRIGGER [dbo].[Z_APP_BL_Pagam]
GO
CREATE TRIGGER [dbo].[Z_APP_BL_Pagam]
ON [dbo].[BL_Pagam]
FOR DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM [dbo].[Z_APP_DeletedRows] 
    WHERE Z_IS_LastEditDate IN (
        SELECT CAST(BLPG_IS_LastEditDate AS BIGINT) 
        FROM deleted
    );
    
    INSERT INTO [dbo].[Z_APP_DeletedRows] (Z_IS_LastEditDate)
    SELECT CAST(BLPG_IS_LastEditDate AS BIGINT)
    FROM deleted;
END
GO

DROP TRIGGER [dbo].[Z_APP_BL_Tipo]
GO
CREATE TRIGGER [dbo].[Z_APP_BL_Tipo]
ON [dbo].[BL_Tipo]
FOR DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM [dbo].[Z_APP_DeletedRows] 
    WHERE Z_IS_LastEditDate IN (
        SELECT CAST(BLTI_IS_LastEditDate AS BIGINT) 
        FROM deleted
    );
    
    INSERT INTO [dbo].[Z_APP_DeletedRows] (Z_IS_LastEditDate)
    SELECT CAST(BLTI_IS_LastEditDate AS BIGINT)
    FROM deleted;
END
GO

DROP TRIGGER [dbo].[Z_APP_FT_Pagam]
GO
CREATE TRIGGER [dbo].[Z_APP_FT_Pagam]
ON [dbo].[FT_Pagam]
FOR DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM [dbo].[Z_APP_DeletedRows] 
    WHERE Z_IS_LastEditDate IN (
        SELECT CAST(FTPG_IS_LastEditDate AS BIGINT) 
        FROM deleted
    );
    
    INSERT INTO [dbo].[Z_APP_DeletedRows] (Z_IS_LastEditDate)
    SELECT CAST(FTPG_IS_LastEditDate AS BIGINT)
    FROM deleted;
END
GO

DROP TRIGGER [dbo].[Z_APP_FT_Tipo]
GO
CREATE TRIGGER [dbo].[Z_APP_FT_Tipo]
ON [dbo].[FT_Tipo]
FOR DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM [dbo].[Z_APP_DeletedRows] 
    WHERE Z_IS_LastEditDate IN (
        SELECT CAST(FTTI_IS_LastEditDate AS BIGINT) 
        FROM deleted
    );
    
    INSERT INTO [dbo].[Z_APP_DeletedRows] (Z_IS_LastEditDate)
    SELECT CAST(FTTI_IS_LastEditDate AS BIGINT)
    FROM deleted;
END
GO

DROP TRIGGER [dbo].[Z_APP_MB_Agenti]
GO
CREATE TRIGGER [dbo].[Z_APP_MB_Agenti]
ON [dbo].[MB_Agenti]
FOR DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM [dbo].[Z_APP_DeletedRows] 
    WHERE Z_IS_LastEditDate IN (
        SELECT CAST(MBAG_IS_LastEditDate AS BIGINT) 
        FROM deleted
    );
    
    INSERT INTO [dbo].[Z_APP_DeletedRows] (Z_IS_LastEditDate)
    SELECT CAST(MBAG_IS_LastEditDate AS BIGINT)
    FROM deleted;
END
GO

DROP TRIGGER [dbo].[Z_APP_MB_Iva]
GO
CREATE TRIGGER [dbo].[Z_APP_MB_Iva]
ON [dbo].[MB_Iva]
FOR DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM [dbo].[Z_APP_DeletedRows] 
    WHERE Z_IS_LastEditDate IN (
        SELECT CAST(MBIV_IS_LastEditDate AS BIGINT) 
        FROM deleted
    );
    
    INSERT INTO [dbo].[Z_APP_DeletedRows] (Z_IS_LastEditDate)
    SELECT CAST(MBIV_IS_LastEditDate AS BIGINT)
    FROM deleted;
END
GO

DROP TRIGGER [dbo].[Z_APP_MB_SolPag]
GO
CREATE TRIGGER [dbo].[Z_APP_MB_SolPag]
ON [dbo].[MB_SolPag]
FOR DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM [dbo].[Z_APP_DeletedRows] 
    WHERE Z_IS_LastEditDate IN (
        SELECT CAST(MBSP_IS_LastEditDate AS BIGINT) 
        FROM deleted
    );
    
    INSERT INTO [dbo].[Z_APP_DeletedRows] (Z_IS_LastEditDate)
    SELECT CAST(MBSP_IS_LastEditDate AS BIGINT)
    FROM deleted;
END
GO

DROP TRIGGER [dbo].[Z_APP_MB_TipiArticoloVA]
GO
CREATE TRIGGER [dbo].[Z_APP_MB_TipiArticoloVA]
ON [dbo].[MB_TipiArticoloVA]
FOR DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM [dbo].[Z_APP_DeletedRows] 
    WHERE Z_IS_LastEditDate IN (
        SELECT CAST(MBTA_IS_LastEditDate AS BIGINT) 
        FROM deleted
    );
    
    INSERT INTO [dbo].[Z_APP_DeletedRows] (Z_IS_LastEditDate)
    SELECT CAST(MBTA_IS_LastEditDate AS BIGINT)
    FROM deleted;
END
GO

DROP TRIGGER [dbo].[Z_APP_MB_TipoConto]
GO
CREATE TRIGGER [dbo].[Z_APP_MB_TipoConto]
ON [dbo].[MB_TipoConto]
FOR DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM [dbo].[Z_APP_DeletedRows] 
    WHERE Z_IS_LastEditDate IN (
        SELECT CAST(MBTC_IS_LastEditDate AS BIGINT) 
        FROM deleted
    );
    
    INSERT INTO [dbo].[Z_APP_DeletedRows] (Z_IS_LastEditDate)
    SELECT CAST(MBTC_IS_LastEditDate AS BIGINT)
    FROM deleted;
END
GO

DROP TRIGGER [dbo].[Z_APP_MB_TipoPag]
GO
CREATE TRIGGER [dbo].[Z_APP_MB_TipoPag]
ON [dbo].[MB_TipoPag]
FOR DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM [dbo].[Z_APP_DeletedRows] 
    WHERE Z_IS_LastEditDate IN (
        SELECT CAST(MBTP_IS_LastEditDate AS BIGINT) 
        FROM deleted
    );
    
    INSERT INTO [dbo].[Z_APP_DeletedRows] (Z_IS_LastEditDate)
    SELECT CAST(MBTP_IS_LastEditDate AS BIGINT)
    FROM deleted;
END
GO

DROP TRIGGER [dbo].[Z_APP_OC_Pagam]
GO
CREATE TRIGGER [dbo].[Z_APP_OC_Pagam]
ON [dbo].[OC_Pagam]
FOR DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM [dbo].[Z_APP_DeletedRows] 
    WHERE Z_IS_LastEditDate IN (
        SELECT CAST(OCPG_IS_LastEditDate AS BIGINT) 
        FROM deleted
    );
    
    INSERT INTO [dbo].[Z_APP_DeletedRows] (Z_IS_LastEditDate)
    SELECT CAST(OCPG_IS_LastEditDate AS BIGINT)
    FROM deleted;
END
GO

DROP TRIGGER [dbo].[Z_APP_OC_Tipo]
GO
CREATE TRIGGER [dbo].[Z_APP_OC_Tipo]
ON [dbo].[OC_Tipo]
FOR DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM [dbo].[Z_APP_DeletedRows] 
    WHERE Z_IS_LastEditDate IN (
        SELECT CAST(OCTI_IS_LastEditDate AS BIGINT) 
        FROM deleted
    );
    
    INSERT INTO [dbo].[Z_APP_DeletedRows] (Z_IS_LastEditDate)
    SELECT CAST(OCTI_IS_LastEditDate AS BIGINT)
    FROM deleted;
END
GO

DROP TRIGGER [dbo].[Z_APP_Partite]
GO
CREATE TRIGGER [dbo].[Z_APP_Partite]
ON [dbo].[CA_Partite]
FOR DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM [dbo].[Z_APP_DeletedRows] 
    WHERE Z_IS_LastEditDate IN (
        SELECT CAST(CAPA_IS_LastEditDate AS BIGINT) 
        FROM deleted
    );
    
    INSERT INTO [dbo].[Z_APP_DeletedRows] (Z_IS_LastEditDate)
    SELECT CAST(CAPA_IS_LastEditDate AS BIGINT)
    FROM deleted;
END
GO

DROP TRIGGER [dbo].[Z_APP_AnaArt]
GO
CREATE TRIGGER [dbo].[Z_APP_AnaArt]
ON [dbo].[MG_AnaArt]
FOR DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM [dbo].[Z_APP_DeletedRows] 
    WHERE Z_IS_LastEditDate IN (
        SELECT CAST(MGAA_IS_LastEditDate AS BIGINT) 
        FROM deleted
    );
    
    INSERT INTO [dbo].[Z_APP_DeletedRows] (Z_IS_LastEditDate)
    SELECT CAST(MGAA_IS_LastEditDate AS BIGINT)
    FROM deleted;
END
GO

DROP TRIGGER [dbo].[Z_APP_Anagr]
GO
CREATE TRIGGER [dbo].[Z_APP_Anagr]
ON [dbo].[MB_Anagr]
FOR DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM [dbo].[Z_APP_DeletedRows] 
    WHERE Z_IS_LastEditDate IN (
        SELECT CAST(MBAN_IS_LastEditDate AS BIGINT) 
        FROM deleted
    );
    
    INSERT INTO [dbo].[Z_APP_DeletedRows] (Z_IS_LastEditDate)
    SELECT CAST(MBAN_IS_LastEditDate AS BIGINT)
    FROM deleted;
END
GO

DROP TRIGGER [dbo].[Z_APP_CliForDestinatari]
GO
CREATE TRIGGER [dbo].[Z_APP_CliForDestinatari]
ON [dbo].[MB_CliForDestinatari]
FOR DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM [dbo].[Z_APP_DeletedRows] 
    WHERE Z_IS_LastEditDate IN (
        SELECT CAST(MBDT_IS_LastEditDate AS BIGINT) 
        FROM deleted
    );
    
    INSERT INTO [dbo].[Z_APP_DeletedRows] (Z_IS_LastEditDate)
    SELECT CAST(MBDT_IS_LastEditDate AS BIGINT)
    FROM deleted;
END
GO

DROP TRIGGER [dbo].[Z_APP_CliFor]
GO
CREATE TRIGGER [dbo].[Z_APP_CliFor]
ON [dbo].[MB_CliFor]
FOR DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM [dbo].[Z_APP_DeletedRows] 
    WHERE Z_IS_LastEditDate IN (
        SELECT CAST(MBCF_IS_LastEditDate AS BIGINT) 
        FROM deleted
    );
    
    INSERT INTO [dbo].[Z_APP_DeletedRows] (Z_IS_LastEditDate)
    SELECT CAST(MBCF_IS_LastEditDate AS BIGINT)
    FROM deleted;
END
GO

DROP TRIGGER [dbo].[Z_APP_CliForSconti]
GO
CREATE TRIGGER [dbo].[Z_APP_CliForSconti]
ON [dbo].[MB_CliForSconti]
FOR DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM [dbo].[Z_APP_DeletedRows] 
    WHERE Z_IS_LastEditDate IN (
        SELECT CAST(MBSC_IS_LastEditDate AS BIGINT) 
        FROM deleted
    );
    
    INSERT INTO [dbo].[Z_APP_DeletedRows] (Z_IS_LastEditDate)
    SELECT CAST(MBSC_IS_LastEditDate AS BIGINT)
    FROM deleted;
END
GO

DROP TRIGGER [dbo].[Z_APP_FT_Artic]
GO
CREATE TRIGGER [dbo].[Z_APP_FT_Artic]
ON [dbo].[FT_Artic]
FOR DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM [dbo].[Z_APP_DeletedRows] 
    WHERE Z_IS_LastEditDate IN (
        SELECT CAST(FTAR_IS_LastEditDate AS BIGINT) 
        FROM deleted
    );
    
    INSERT INTO [dbo].[Z_APP_DeletedRows] (Z_IS_LastEditDate)
    SELECT CAST(FTAR_IS_LastEditDate AS BIGINT)
    FROM deleted;
END
GO

DROP TRIGGER [dbo].[Z_APP_OC_Artic]
GO
CREATE TRIGGER [dbo].[Z_APP_OC_Artic]
ON [dbo].[OC_Artic]
FOR DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM [dbo].[Z_APP_DeletedRows] 
    WHERE Z_IS_LastEditDate IN (
        SELECT CAST(OCAR_IS_LastEditDate AS BIGINT) 
        FROM deleted
    );
    
    INSERT INTO [dbo].[Z_APP_DeletedRows] (Z_IS_LastEditDate)
    SELECT CAST(OCAR_IS_LastEditDate AS BIGINT)
    FROM deleted;
END
GO

DROP TRIGGER [dbo].[Z_APP_BL_Artic]
GO
CREATE TRIGGER [dbo].[Z_APP_BL_Artic]
ON [dbo].[BL_Artic]
FOR DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM [dbo].[Z_APP_DeletedRows] 
    WHERE Z_IS_LastEditDate IN (
        SELECT CAST(BLAR_IS_LastEditDate AS BIGINT) 
        FROM deleted
    );
    
    INSERT INTO [dbo].[Z_APP_DeletedRows] (Z_IS_LastEditDate)
    SELECT CAST(BLAR_IS_LastEditDate AS BIGINT)
    FROM deleted;
END
GO
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
ENABLE TRIGGER [dbo].[Z_APP_CliFor] ON [dbo].[MB_CliFor];
ENABLE TRIGGER [dbo].[Z_APP_CliForSconti] ON [dbo].[MB_CliForSconti];
ENABLE TRIGGER [dbo].[Z_APP_FT_Artic] ON [dbo].[FT_Artic];
ENABLE TRIGGER [dbo].[Z_APP_OC_Artic] ON [dbo].[OC_Artic];
ENABLE TRIGGER [dbo].[Z_APP_BL_Artic] ON [dbo].[BL_Artic];

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
DISABLE TRIGGER [dbo].[Z_APP_CliFor] ON [dbo].[MB_CliFor];
DISABLE TRIGGER [dbo].[Z_APP_CliForSconti] ON [dbo].[MB_CliForSconti];
DISABLE TRIGGER [dbo].[Z_APP_FT_Artic] ON [dbo].[FT_Artic];
DISABLE TRIGGER [dbo].[Z_APP_OC_Artic] ON [dbo].[OC_Artic];
DISABLE TRIGGER [dbo].[Z_APP_BL_Artic] ON [dbo].[BL_Artic];
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