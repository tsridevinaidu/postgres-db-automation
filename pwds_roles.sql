--/**---------------------------------------------------------------------------------------
--/* Script		: pwds_roles.sql
--/* Author		: Sridevi Tadisetti  
--/* Date		: 20/01/2025       
--/* Description: Assigning Passwords for  Roles With Validity. 
--/* RDBMS		: Postgres
--/* Variables		:
--/*		WMSADMIN				: The name of the Role  
--/*		WMwmsSqlWMwmsSql1 		: Password of WMSADMIN 		
--/*----------------------------------------------------------------------------------------
--/* Modified byDateDescription    
--/*----------------------------------------------------------------------------------------
--/*
--/*
--/*-----------------------------------------------------------------------------------------

-- All roles will be ALTERED with password and password expiry - no

ALTER Role WMSADMIN WITH PASSWORD 'WMwmsSqlWMwmsSql1' VALID UNTIL 'infinity';
ALTER Role WMRPTUSER WITH PASSWORD 'WMrptSqlWMrptSql1' VALID UNTIL 'infinity';
ALTER Role ENTERPRISE WITH PASSWORD 'WMwhSqlWMwhSql0' VALID UNTIL 'infinity';
ALTER Role BILLADMIN WITH PASSWORD 'BillSqlBillSql1' VALID UNTIL 'infinity';
ALTER Role LABORADMIN WITH PASSWORD 'LaborSqlLaborSql1' VALID UNTIL 'infinity';
ALTER Role WMWHSE1 WITH PASSWORD 'WMwhSqlWMwhSql1' VALID UNTIL 'infinity';
ALTER Role WMWHSE2 WITH PASSWORD 'WMwhSqlWMwhSql2' VALID UNTIL 'infinity';
ALTER Role WMWHSE3 WITH PASSWORD 'WMwhSqlWMwhSql3' VALID UNTIL 'infinity';
ALTER Role WMWHSE4 WITH PASSWORD 'WMwhSqlWMwhSql4' VALID UNTIL 'infinity';
ALTER Role WMWHSE5 WITH PASSWORD 'WMwhSqlWMwhSql5' VALID UNTIL 'infinity';

