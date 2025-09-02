--/**---------------------------------------------------------------------------------------
--/* Script		: grnts_views.sql
--/* Author		: Sridevi Tadisetti  
--/* Date		: 20/01/2025       
--/* Description: Script to grant required views to role
--/* RDBMS		: Postgres
--/* Variables		:
--/*		billadmin.VBIC_CHARGE_CODE		: The name of the View of Billadminschema  
--/*		wmwhse1							: The name of the Schema 		
--/*----------------------------------------------------------------------------------------
--/* Modified byDateDescription    
--/*----------------------------------------------------------------------------------------
--/*
--/*
--/*-------------------------------------------------------------------------------------------

-- The script should be run on Postgresql with Postgres user

GRANT SELECT ON TABLE billadmin.VBIC_CHARGE_CODE TO wmwhse1;

GRANT SELECT ON TABLE billadmin.VBIC_UOM TO wmwhse1;

GRANT SELECT ON TABLE billadmin.VBIC_CHARGE_CODE TO wmwhse2;

GRANT SELECT ON TABLE billadmin.VBIC_UOM TO wmwhse2;

GRANT SELECT ON TABLE billadmin.VBIC_CHARGE_CODE TO wmwhse3;

GRANT SELECT ON TABLE billadmin.VBIC_UOM TO wmwhse3;

GRANT SELECT ON TABLE billadmin.VBIC_CHARGE_CODE TO wmwhse4;

GRANT SELECT ON TABLE billadmin.VBIC_UOM TO wmwhse4;

GRANT SELECT ON TABLE billadmin.VBIC_CHARGE_CODE TO wmwhse5;

GRANT SELECT ON TABLE billadmin.VBIC_UOM TO wmwhse5;

GRANT SELECT ON TABLE wmwhse5.PBSRPT_REPORTS TO WMSADMIN;
