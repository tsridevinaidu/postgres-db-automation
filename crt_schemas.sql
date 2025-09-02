--/**---------------------------------------------------------------------------------------
--/* Script		: crt_schemas.sql
--/* Author		: Sridevi Tadisetti  
--/* Date		: 20/01/2025       
--/* Description: Creating Schemas and assigned to roles. 
--/* RDBMS		: Postgres
--/* Variables		:
--/*		WMSADMIN		: Name of the Schema 
--/*		WMSADMIN 		: Name of the Role 		
--/*----------------------------------------------------------------------------------------
--/* Modified byDateDescription    
--/*----------------------------------------------------------------------------------------
--/*
--/*
--/*-----------------------------------------------------------------------------------------

-- All Schemas will be created and authorized to users / roles 


--- Create crt_schemas.sql dynamically ---

    CREATE SCHEMA IF NOT EXISTS WMSADMIN AUTHORIZATION WMSADMIN;
    CREATE SCHEMA IF NOT EXISTS WMRPTUSER AUTHORIZATION WMRPTUSER;
    CREATE SCHEMA IF NOT EXISTS ENTERPRISE AUTHORIZATION ENTERPRISE;
    CREATE SCHEMA IF NOT EXISTS BILLADMIN AUTHORIZATION BILLADMIN;
    CREATE SCHEMA IF NOT EXISTS LABORADMIN AUTHORIZATION LABORADMIN;
    
	  
	  
   

