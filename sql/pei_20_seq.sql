/*PEI V1.0*/
/*Creation des séquences intervenant dans l'incrémentation de certaines variables */
/* pei_20_seq.sql */
/*PostGIS*/

/* Propriétaire : GeoCompiegnois - http://geo.compiegnois.fr/ */
/* Auteur : FLorent Vanhoutte */
/* Participant : Grégory Bodet */


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
ALTER TABLE m_defense_incendie.lt_pei_id_contrat_seq
  OWNER TO sig_create;
GRANT ALL ON SEQUENCE m_defense_incendie.lt_pei_id_contrat_seq TO sig_create;
GRANT SELECT, USAGE ON SEQUENCE m_defense_incendie.lt_pei_id_contrat_seq TO public;


-- ################################################################# Séquence sur domaine valeur ouvert - marque  ###############################################

-- Sequence: m_defense_incendie.lt_pei_marque_seq

-- DROP SEQUENCE m_defense_incendie.lt_pei_marque_seq;

CREATE SEQUENCE m_defense_incendie.lt_pei_marque_seq
  INCREMENT 1
  MINVALUE 0
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;
ALTER TABLE m_defense_incendie.lt_pei_marque_seq
  OWNER TO sig_create;
GRANT ALL ON SEQUENCE m_defense_incendie.lt_pei_marque_seq TO sig_create;
GRANT SELECT, USAGE ON SEQUENCE m_defense_incendie.lt_pei_marque_seq TO public;


-- ################################################################# Séquence sur domaine valeur ouvert - délégataire  ###############################################

-- Sequence: m_defense_incendie.lt_pei_delegat_seq

-- DROP SEQUENCE m_defense_incendie.lt_pei_delegat_seq;

CREATE SEQUENCE m_defense_incendie.lt_pei_delegat_seq
  INCREMENT 1
  MINVALUE 0
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;
ALTER TABLE m_defense_incendie.lt_pei_delegat_seq
  OWNER TO sig_create;
GRANT ALL ON SEQUENCE m_defense_incendie.lt_pei_delegat_seq TO sig_create;
GRANT SELECT, USAGE ON SEQUENCE m_defense_incendie.lt_pei_delegat_seq TO public;


-- ################################################################# Séquence sur domaine valeur ouvert - raccord  ###############################################

-- Sequence: m_defense_incendie.lt_pei_raccord_seq

-- DROP SEQUENCE m_defense_incendie.lt_pei_raccord_seq;

CREATE SEQUENCE m_defense_incendie.lt_pei_raccord_seq
  INCREMENT 1
  MINVALUE 0
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;
ALTER TABLE m_defense_incendie.lt_pei_raccord_seq
  OWNER TO sig_create;
GRANT ALL ON SEQUENCE m_defense_incendie.lt_pei_raccord_seq TO sig_create;
GRANT SELECT, USAGE ON SEQUENCE m_defense_incendie.lt_pei_raccord_seq TO public;

-- ################################################################# Séquence sur table - geo_pei  ###############################################


-- Sequence: m_defense_incendie.geo_pei_id_seq

-- DROP SEQUENCE m_defense_incendie.geo_pei_id_seq;

CREATE SEQUENCE m_defense_incendie.geo_pei_id_seq
  INCREMENT 1
  MINVALUE 0
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;
ALTER TABLE m_defense_incendie.geo_pei_id_seq
  OWNER TO sig_create;
GRANT ALL ON SEQUENCE m_defense_incendie.geo_pei_id_seq TO sig_create;
GRANT SELECT, USAGE ON SEQUENCE m_defense_incendie.geo_pei_id_seq TO public;

-- ################################################################# Séquence sur table - log_pei  ###############################################


-- Sequence: m_defense_incendie.log_pei_id_seq

-- DROP SEQUENCE m_defense_incendie.log_pei_id_seq;

CREATE SEQUENCE m_defense_incendie.log_pei_id_seq
  INCREMENT 1
  MINVALUE 0
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;
ALTER TABLE m_defense_incendie.log_pei_id_seq
  OWNER TO sig_create;
GRANT ALL ON SEQUENCE m_defense_incendie.log_pei_id_seq TO sig_create;
GRANT SELECT, USAGE ON SEQUENCE m_defense_incendie.log_pei_id_seq TO public;


