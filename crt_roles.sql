--*****************************************************
--	Create Roles
--/**---------------------------------------------------------------------------------------
--/* Script		: crt_roles.sql
--/* Author		: Sridevi Tadisetti  
--/* Date		: 20/01/2025       
--/* Description: Template for creating Roles With required access
--/* RDBMS		: Postgres
--/* Variables		:
--/*		WMSADMIN						: The name of the Role  
--/*		LOGIN CREATEDB CREATEROLE 		: Types of the Accesses 		
--/*----------------------------------------------------------------------------------------
--/* Modified byDateDescription    
--/*----------------------------------------------------------------------------------------
--/*
--/*
--/*-----------------------------------------------------------------------------------------

-- The query should be run at Postgresql

-- All roles will be created


DO $$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'wmsadmin') THEN
      CREATE ROLE wmsadmin WITH LOGIN CREATEDB CREATEROLE CONNECTION LIMIT -1;
   END IF;
END $$;

DO $$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'wmrptuser') THEN
      CREATE ROLE wmrptuser WITH LOGIN CREATEDB CREATEROLE CONNECTION LIMIT -1;
   END IF;
END $$;

DO $$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'enterprise') THEN
      CREATE ROLE enterprise WITH LOGIN CREATEDB CREATEROLE CONNECTION LIMIT -1;
   END IF;
END $$;

DO $$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'billadmin') THEN
      CREATE ROLE billadmin WITH LOGIN CREATEDB CREATEROLE CONNECTION LIMIT -1;
   END IF;
END $$;

DO $$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'laboradmin') THEN
      CREATE ROLE laboradmin WITH LOGIN CREATEDB CREATEROLE CONNECTION LIMIT -1;
   END IF;
END $$;

DO $$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'wmwhse1') THEN
      CREATE ROLE wmwhse1 WITH LOGIN CREATEDB CREATEROLE CONNECTION LIMIT -1;
   END IF;
END $$;

DO $$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'wmwhse2') THEN
      CREATE ROLE wmwhse2 WITH LOGIN CREATEDB CREATEROLE CONNECTION LIMIT -1;
   END IF;
END $$;

DO $$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'wmwhse3') THEN
      CREATE ROLE wmwhse3 WITH LOGIN CREATEDB CREATEROLE CONNECTION LIMIT -1;
   END IF;
END $$;

DO $$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'wmwhse4') THEN
      CREATE ROLE wmwhse4 WITH LOGIN CREATEDB CREATEROLE CONNECTION LIMIT -1;
   END IF;
END $$;

DO $$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'wmwhse5') THEN
      CREATE ROLE wmwhse5 WITH LOGIN CREATEDB CREATEROLE CONNECTION LIMIT -1;
   END IF;
END $$;
