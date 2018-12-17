/*PEI V1.0*/
/*Creation du squelette de la structure des données (table, séquence, trigger,...) */
/* pei_10_squelette.sql */
/*PostGIS*/

/* Propriétaire : GeoCompiegnois - http://geo.compiegnois.fr/ */
/* Auteur : FLorent Vanhoutte */
/* Participant : Grégory Bodet */

-- #################################################################### SCHEMA  ####################################################################

-- Schema: m_defense_incendie

-- DROP SCHEMA m_defense_incendie;
/*
CREATE SCHEMA m_defense_incendie
  AUTHORIZATION sig_create;

COMMENT ON SCHEMA m_defense_incendie
  IS 'Données géographiques métiers sur le thème de la défense incendie';
*/


-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                SEQUENCE                                                           ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################


DROP SEQUENCE IF EXISTS m_defense_incendie.geo_pei_id_seq;
DROP SEQUENCE IF EXISTS m_defense_incendie.log_pei_id_seq;
DROP SEQUENCE IF EXISTS m_defense_incendie.lt_pei_delegat_seq;
DROP SEQUENCE IF EXISTS m_defense_incendie.lt_pei_id_contrat_seq;
DROP SEQUENCE IF EXISTS m_defense_incendie.lt_pei_marque_seq;
DROP SEQUENCE IF EXISTS m_defense_incendie.lt_pei_raccord_seq;

-- ################################################################# Séquence sur domaine valeur ouvert - contrat  ###############################################


-- Sequence: m_defense_incendie.lt_pei_id_contrat_seq

-- DROP SEQUENCE m_defense_incendie.lt_pei_id_contrat_seq;

CREATE SEQUENCE m_defense_incendie.lt_pei_id_contrat_seq
  INCREMENT 1
  MINVALUE 0
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;




-- ################################################################# Séquence sur domaine valeur ouvert - marque  ###############################################

-- Sequence: m_defense_incendie.lt_pei_marque_seq

-- DROP SEQUENCE m_defense_incendie.lt_pei_marque_seq;

CREATE SEQUENCE m_defense_incendie.lt_pei_marque_seq
  INCREMENT 1
  MINVALUE 0
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;



-- ################################################################# Séquence sur domaine valeur ouvert - délégataire  ###############################################

-- Sequence: m_defense_incendie.lt_pei_delegat_seq

-- DROP SEQUENCE m_defense_incendie.lt_pei_delegat_seq;

CREATE SEQUENCE m_defense_incendie.lt_pei_delegat_seq
  INCREMENT 1
  MINVALUE 0
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;



-- ################################################################# Séquence sur domaine valeur ouvert - raccord  ###############################################

-- Sequence: m_defense_incendie.lt_pei_raccord_seq

-- DROP SEQUENCE m_defense_incendie.lt_pei_raccord_seq;

CREATE SEQUENCE m_defense_incendie.lt_pei_raccord_seq
  INCREMENT 1
  MINVALUE 0
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;


-- ################################################################# Séquence sur table - geo_pei  ###############################################


-- Sequence: m_defense_incendie.geo_pei_id_seq

-- DROP SEQUENCE m_defense_incendie.geo_pei_id_seq;

CREATE SEQUENCE m_defense_incendie.geo_pei_id_seq
  INCREMENT 1
  MINVALUE 0
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;


-- ################################################################# Séquence sur table - log_pei  ###############################################


-- Sequence: m_defense_incendie.log_pei_id_seq

-- DROP SEQUENCE m_defense_incendie.log_pei_id_seq;

CREATE SEQUENCE m_defense_incendie.log_pei_id_seq
  INCREMENT 1
  MINVALUE 0
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;
 

-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                DOMAINES DE VALEURS                                                           ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################


  -- fkey
ALTER TABLE m_defense_incendie.geo_pei DROP CONSTRAINT IF EXISTS lt_pei_type_pei_fkey;
ALTER TABLE m_defense_incendie.geo_pei DROP CONSTRAINT IF EXISTS lt_pei_diam_pei_fkey;
ALTER TABLE m_defense_incendie.geo_pei DROP CONSTRAINT IF EXISTS lt_pei_source_pei_fkey;
ALTER TABLE m_defense_incendie.geo_pei DROP CONSTRAINT IF EXISTS lt_pei_statut_fkey;
ALTER TABLE m_defense_incendie.geo_pei DROP CONSTRAINT IF EXISTS lt_pei_gestion_fkey;
ALTER TABLE m_defense_incendie.geo_pei DROP CONSTRAINT IF EXISTS lt_pei_etat_pei_fkey;
ALTER TABLE m_defense_incendie.geo_pei DROP CONSTRAINT IF EXISTS lt_pei_cs_sdis_fkey;
ALTER TABLE m_defense_incendie.geo_pei DROP CONSTRAINT IF EXISTS lt_pei_marque_fkey;
ALTER TABLE m_defense_incendie.geo_pei DROP CONSTRAINT IF EXISTS lt_pei_raccord_fkey;
ALTER TABLE m_defense_incendie.geo_pei DROP CONSTRAINT IF EXISTS lt_pei_delegat_fkey;
ALTER TABLE m_defense_incendie.geo_pei DROP CONSTRAINT IF EXISTS lt_pei_src_geom_fkey;
ALTER TABLE m_defense_incendie.an_pei_ctr DROP CONSTRAINT IF EXISTS lt_pei_id_contrat_fkey;
ALTER TABLE m_defense_incendie.an_pei_ctr DROP CONSTRAINT lt_pei_etat_anom_fkey;
ALTER TABLE m_defense_incendie.an_pei_ctr DROP CONSTRAINT lt_pei_etat_acces_fkey;
ALTER TABLE m_defense_incendie.an_pei_ctr DROP CONSTRAINT lt_pei_etat_sign_fkey;
ALTER TABLE m_defense_incendie.an_pei_ctr DROP CONSTRAINT lt_pei_etat_conf_fkey; 

-- domaine de valeur
DROP TABLE IF EXISTS m_defense_incendie.lt_pei_anomalie;
DROP TABLE IF EXISTS m_defense_incendie.lt_pei_cs_sdis;
DROP TABLE IF EXISTS m_defense_incendie.lt_pei_delegat;
DROP TABLE IF EXISTS m_defense_incendie.lt_pei_diam_pei;
DROP TABLE IF EXISTS m_defense_incendie.lt_pei_etat_boolean;
DROP TABLE IF EXISTS m_defense_incendie.lt_pei_etat_pei;
DROP TABLE IF EXISTS m_defense_incendie.lt_pei_gestion;
DROP TABLE IF EXISTS m_defense_incendie.lt_pei_id_contrat;
DROP TABLE IF EXISTS m_defense_incendie.lt_pei_marque;
DROP TABLE IF EXISTS m_defense_incendie.lt_pei_raccord;
DROP TABLE IF EXISTS m_defense_incendie.lt_pei_source_pei;
DROP TABLE IF EXISTS m_defense_incendie.lt_pei_statut;
DROP TABLE IF EXISTS m_defense_incendie.lt_pei_type_pei;



-- ################################################################# Domaine valeur - type_pei  ###############################################

-- Table: m_defense_incendie.lt_pei_type_pei

