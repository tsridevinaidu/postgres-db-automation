--/**---------------------------------------------------------------------------------------
--/* Script		: grnt_roles.sql
--/* Author		: Sridevi Tadisetti  
--/* Date		: 20/01/2025       
--/* Description: Script to grant on Schemas to Roles
--/* RDBMS		: Postgres
--/* Variables		:
--/*		WMSADMIN				: The name of the Role  
--/*		WMSADMIN				: The name of the Schema 		
--/*----------------------------------------------------------------------------------------
--/* Modified byDateDescription    
--/*----------------------------------------------------------------------------------------
--/*
--/*
--/*-------------------------------------------------------------------------------------------

-- The script should be run on Postgresql with Postgres user

GRANT USAGE ON SCHEMA billadmin TO billadmin;
GRANT SELECT ON ALL TABLES IN SCHEMA billadmin TO billadmin;
GRANT USAGE ON SCHEMA laboradmin TO laboradmin;
GRANT SELECT ON ALL TABLES IN SCHEMA laboradmin TO laboradmin;


GRANT USAGE ON SCHEMA enterprise TO enterprise;
GRANT SELECT ON ALL TABLES IN SCHEMA enterprise TO enterprise;
GRANT USAGE ON SCHEMA wmsadmin TO wmsadmin;
GRANT SELECT ON ALL TABLES IN SCHEMA wmsadmin TO wmsadmin;

GRANT USAGE ON SCHEMA wmwhse1 TO wmwhse1;
GRANT SELECT ON ALL TABLES IN SCHEMA wmwhse1 TO wmwhse1;
GRANT USAGE ON SCHEMA wmwhse2 TO wmwhse2;
GRANT SELECT ON ALL TABLES IN SCHEMA wmwhse2 TO wmwhse2;

GRANT USAGE ON SCHEMA wmwhse3 TO wmwhse3;
GRANT SELECT ON ALL TABLES IN SCHEMA wmwhse3 TO wmwhse3;
GRANT USAGE ON SCHEMA wmwhse4 TO wmwhse4;
GRANT SELECT ON ALL TABLES IN SCHEMA wmwhse4 TO wmwhse4;

GRANT USAGE ON SCHEMA wmwhse5 TO wmwhse5;
GRANT SELECT ON ALL TABLES IN SCHEMA wmwhse5 TO wmwhse5;
