/*PEI V1.0*/
/*Creation des tables contenant les listes des valeurs */
/* pei_20_listes.sql */
/*PostGIS*/

/* Propriétaire : GeoCompiegnois - http://geo.compiegnois.fr/ */
/* Auteur : FLorent Vanhoutte */
/* Participant : Grégory Bodet */

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

-- sequence
DROP SEQUENCE IF EXISTS m_defense_incendie.lt_pei_delegat_seq;
DROP SEQUENCE IF EXISTS m_defense_incendie.lt_pei_id_contrat_seq;
DROP SEQUENCE IF EXISTS m_defense_incendie.lt_pei_marque_seq;
DROP SEQUENCE IF EXISTS m_defense_incendie.lt_pei_raccord_seq;


-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                DOMAINES DE VALEURS                                                           ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################


-- ################################################################# Domaine valeur - type_pei  ###############################################

-- Table: m_defense_incendie.lt_pei_type_pei

-- DROP TABLE m_defense_incendie.lt_pei_type_pei;

CREATE TABLE m_defense_incendie.lt_pei_type_pei
(
  code character varying(2) NOT NULL,
  valeur character varying(80) NOT NULL,
  affich character varying(1) NOT NULL,
  CONSTRAINT lt_pei_type_pei_pkey PRIMARY KEY (code)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE m_defense_incendie.lt_pei_type_pei
  OWNER TO sig_create;
GRANT SELECT ON TABLE m_defense_incendie.lt_pei_type_pei TO read_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_defense_incendie.lt_pei_type_pei TO edit_sig;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_type_pei TO create_sig;

COMMENT ON TABLE m_defense_incendie.lt_pei_type_pei
  IS 'Code permettant de décrire le type de point d''eau incendie';
COMMENT ON COLUMN m_defense_incendie.lt_pei_type_pei.code IS 'Code de la liste énumérée relative au type de PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_type_pei.valeur IS 'Valeur de la liste énumérée relative au type de PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_type_pei.affich IS 'Ordre d''affichage de la liste énumérée relative au type de PEI';


-- ################################################################# Domaine valeur - diam_pei  ###############################################

-- Table: m_defense_incendie.lt_pei_diam_pei

-- DROP TABLE m_defense_incendie.lt_pei_diam_pei;

CREATE TABLE m_defense_incendie.lt_pei_diam_pei
(
  code integer NOT NULL,
  valeur character varying(80) NOT NULL,
  CONSTRAINT lt_pei_diam_pei_pkey PRIMARY KEY (code)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE m_defense_incendie.lt_pei_diam_pei
  OWNER TO sig_create;
GRANT SELECT ON TABLE m_defense_incendie.lt_pei_diam_pei TO read_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_defense_incendie.lt_pei_diam_pei TO edit_sig;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_diam_pei TO create_sig;

COMMENT ON TABLE m_defense_incendie.lt_pei_diam_pei
  IS 'Code permettant de décrire le diamètre intérieur du point d''eau incendie (poteau ou bouche)';
COMMENT ON COLUMN m_defense_incendie.lt_pei_diam_pei.code IS 'Code de la liste énumérée relative au diamètre intérieur du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_diam_pei.valeur IS 'Valeur de la liste énumérée relative au diamètre intérieur du PEI';
   

-- ################################################################# Domaine valeur - source_pei  ###############################################

-- Table: m_defense_incendie.lt_pei_source_pei

-- DROP TABLE m_defense_incendie.lt_pei_source_pei;

CREATE TABLE m_defense_incendie.lt_pei_source_pei
(
  code character varying(3) NOT NULL,
  valeur character varying(80) NOT NULL,
  code_open character varying(30),
  CONSTRAINT lt_pei_source_pei_pkey PRIMARY KEY (code)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE m_defense_incendie.lt_pei_source_pei
  OWNER TO sig_create;
GRANT SELECT ON TABLE m_defense_incendie.lt_pei_source_pei TO read_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_defense_incendie.lt_pei_source_pei TO edit_sig;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_source_pei TO create_sig;

COMMENT ON TABLE m_defense_incendie.lt_pei_source_pei
  IS 'Code permettant de décrire le type de source d''alimentation du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_source_pei.code IS 'Code de la liste énumérée relative au type de source d''alimentation du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_source_pei.valeur IS 'Valeur de la liste énumérée relative au type de source d''alimentation du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_source_pei.code_open IS 'Code pour les exports opendata de la liste énumérée relative au type de source d''alimentation du PEI';


-- ################################################################# Domaine valeur - statut_pei  ###############################################

-- Table: m_defense_incendie.lt_pei_statut

-- DROP TABLE m_defense_incendie.lt_pei_statut;

CREATE TABLE m_defense_incendie.lt_pei_statut
(
  code character varying(2) NOT NULL,
  valeur character varying(80) NOT NULL,
  code_open character varying(10),
  CONSTRAINT lt_pei_statut_pkey PRIMARY KEY (code)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE m_defense_incendie.lt_pei_statut
  OWNER TO sig_create;
GRANT SELECT ON TABLE m_defense_incendie.lt_pei_statut TO read_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_defense_incendie.lt_pei_statut TO edit_sig;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_statut TO create_sig;

COMMENT ON TABLE m_defense_incendie.lt_pei_statut
  IS 'Code permettant de décrire le statut juridique du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_statut.code IS 'Code de la liste énumérée relative au statut juridique du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_statut.valeur IS 'Valeur de la liste énumérée relative au statut juridique du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_statut.code_open IS 'Code pour les exports opendata de la liste énumérée relative au statut juridique du PEI';

   

-- ################################################################# Domaine valeur - gestionnaire  ###############################################

-- Table: m_defense_incendie.lt_pei_gestion

-- DROP TABLE m_defense_incendie.lt_pei_gestion;

CREATE TABLE m_defense_incendie.lt_pei_gestion
(
  code character varying(2) NOT NULL,
  valeur character varying(80) NOT NULL,
  CONSTRAINT lt_pei_gestion_pkey PRIMARY KEY (code)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE m_defense_incendie.lt_pei_gestion
  OWNER TO sig_create;
GRANT SELECT ON TABLE m_defense_incendie.lt_pei_gestion TO read_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_defense_incendie.lt_pei_gestion TO edit_sig;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_gestion TO create_sig;

COMMENT ON TABLE m_defense_incendie.lt_pei_gestion
  IS 'Code permettant de décrire le gestionnaire du point d''eau incendie';
COMMENT ON COLUMN m_defense_incendie.lt_pei_gestion.code IS 'Code de la liste énumérée relative au gestionnaire du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_gestion.valeur IS 'Valeur de la liste énumérée relative au gestionnaire du PEI';


-- ################################################################# Domaine valeur - etat_pei  ###############################################

-- Table: m_defense_incendie.lt_pei_etat_pei

-- DROP TABLE m_defense_incendie.lt_pei_etat_pei;

CREATE TABLE m_defense_incendie.lt_pei_etat_pei
(
  code character varying(2) NOT NULL,
  valeur character varying(80) NOT NULL,
  CONSTRAINT lt_pei_etat_pei_pkey PRIMARY KEY (code)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE m_defense_incendie.lt_pei_etat_pei
  OWNER TO sig_create;
GRANT SELECT ON TABLE m_defense_incendie.lt_pei_etat_pei TO read_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_defense_incendie.lt_pei_etat_pei TO edit_sig;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_etat_pei TO create_sig;

COMMENT ON TABLE m_defense_incendie.lt_pei_etat_pei
  IS 'Code permettant de décrire l''état d''actualité du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_etat_pei.code IS 'Code de la liste énumérée relative au etat_pei juridique du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_etat_pei.valeur IS 'Valeur de la liste énumérée relative au etat_pei juridique du PEI';

    
-- ################################################################# Domaine valeur - cs_sdis  ###############################################

-- Table: m_defense_incendie.lt_pei_cs_sdis

-- DROP TABLE m_defense_incendie.lt_pei_cs_sdis;

CREATE TABLE m_defense_incendie.lt_pei_cs_sdis
(
  code character varying(5) NOT NULL,
  valeur character varying(80) NOT NULL,
  CONSTRAINT lt_pei_cs_sdis_pkey PRIMARY KEY (code)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE m_defense_incendie.lt_pei_cs_sdis
  OWNER TO sig_create;
GRANT SELECT ON TABLE m_defense_incendie.lt_pei_cs_sdis TO read_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_defense_incendie.lt_pei_cs_sdis TO edit_sig;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_cs_sdis TO create_sig;

COMMENT ON TABLE m_defense_incendie.lt_pei_cs_sdis
  IS 'Code permettant de décrire le nom du centre de secours de 1er appel du SDIS en charge du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_cs_sdis.code IS 'Code de la liste énumérée relative au nom du CS SDIS en charge du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_cs_sdis.valeur IS 'Valeur de la liste énumérée relative au nom du CS SDIS en charge du PEI';



-- ################################################################# Domaine valeur - pei_etat_boolean  ###############################################

-- Table: m_defense_incendie.lt_pei_etat_boolean

-- DROP TABLE m_defense_incendie.lt_pei_etat_boolean;

CREATE TABLE m_defense_incendie.lt_pei_etat_boolean
(
  code character varying(1) NOT NULL,
  valeur character varying(80) NOT NULL,
  code_open character varying(1),
  CONSTRAINT lt_pei_etat_boolean_pkey PRIMARY KEY (code)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE m_defense_incendie.lt_pei_etat_boolean
  OWNER TO sig_create;
GRANT SELECT ON TABLE m_defense_incendie.lt_pei_etat_boolean TO read_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_defense_incendie.lt_pei_etat_boolean TO edit_sig;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_etat_boolean TO create_sig;

COMMENT ON TABLE m_defense_incendie.lt_pei_etat_boolean
  IS 'Code permettant de décrire l''état d''un attribut boolean';
COMMENT ON COLUMN m_defense_incendie.lt_pei_etat_boolean.code IS 'Code de la liste énumérée relative à l''état d''un attribut boolean';
COMMENT ON COLUMN m_defense_incendie.lt_pei_etat_boolean.valeur IS 'Valeur de la liste énumérée relative à l''état d''un attribut boolean';
COMMENT ON COLUMN m_defense_incendie.lt_pei_etat_boolean.code_open IS 'Code pour les exports opendata de la liste énumérée relative à l''état d''un attribut boolean';



-- ################################################################# Domaine valeur - anomalie  ###############################################

-- Table: m_defense_incendie.lt_pei_anomalie

-- DROP TABLE m_defense_incendie.lt_pei_anomalie;

CREATE TABLE m_defense_incendie.lt_pei_anomalie
(
  code character varying(2) NOT NULL,
  valeur character varying(80) NOT NULL,
  csq_acces character varying(1) NOT NULL,
  csq_sign character varying(1) NOT NULL,
  csq_conf character varying(1) NOT NULL,  
  CONSTRAINT lt_pei_anomalie_pkey PRIMARY KEY (code)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE m_defense_incendie.lt_pei_anomalie
  OWNER TO sig_create;
GRANT SELECT ON TABLE m_defense_incendie.lt_pei_anomalie TO read_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_defense_incendie.lt_pei_anomalie TO edit_sig;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_anomalie TO create_sig;

COMMENT ON TABLE m_defense_incendie.lt_pei_anomalie
  IS 'Liste des anomalies possibles pour un PEI et de leurs incidences sur la conformité';
COMMENT ON COLUMN m_defense_incendie.lt_pei_anomalie.code IS 'Code de la liste énumérée relative au type d''anomalie d''un PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_anomalie.valeur IS 'Valeur de la liste énumérée relative au type d''anomalie d''un PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_anomalie.csq_acces IS 'Impact de l''anomalie sur l''état de l''accessibilité du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_anomalie.csq_sign IS 'Impact de l''anomalie sur l''état de la signalisation du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_anomalie.csq_conf IS 'Impact de l''anomalie sur l''état de la conformité technique du PEI';




-- ################################################################# Domaine valeur ouvert - id_contrat  ###############################################

-- Table: m_defense_incendie.lt_pei_id_contrat

-- DROP TABLE m_defense_incendie.lt_pei_id_contrat;

CREATE TABLE m_defense_incendie.lt_pei_id_contrat
(
  code character varying(2) NOT NULL,
  valeur character varying(80) NOT NULL,
  definition character varying(254),
  CONSTRAINT lt_pei_id_contrat_pkey PRIMARY KEY (code)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE m_defense_incendie.lt_pei_id_contrat
  OWNER TO sig_create;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_id_contrat TO sig_create;
GRANT SELECT ON TABLE m_defense_incendie.lt_pei_id_contrat TO read_sig;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE m_defense_incendie.lt_pei_id_contrat TO edit_sig;
COMMENT ON TABLE m_defense_incendie.lt_pei_id_contrat
  IS 'Code permettant de décrire un contrat pour l''entretien et de contrôle de PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_id_contrat.code IS 'Code de la liste énumérée relative au numéro de contrat pour l''entretien et de contrôle de PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_id_contrat.valeur IS 'Valeur de la référence du marché du contrat pour l''entretien et de contrôle de PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_id_contrat.definition IS 'Definition du contrat pour l''entretien et de contrôle de PEI';




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
ALTER TABLE m_defense_incendie.lt_pei_id_contrat ALTER COLUMN code SET DEFAULT to_char(nextval('m_defense_incendie.lt_pei_id_contrat_seq'::regclass),'FM00');


-- ################################################################# Domaine valeur ouvert - marque  ###############################################

-- Table: m_defense_incendie.lt_pei_marque

-- DROP TABLE m_defense_incendie.lt_pei_marque;

CREATE TABLE m_defense_incendie.lt_pei_marque
(
  code character varying(2) NOT NULL,
  valeur character varying(80) NOT NULL,
  CONSTRAINT lt_pei_marque_pkey PRIMARY KEY (code)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE m_defense_incendie.lt_pei_marque
  OWNER TO sig_create;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_marque TO sig_create;
GRANT SELECT ON TABLE m_defense_incendie.lt_pei_marque TO read_sig;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE m_defense_incendie.lt_pei_marque TO edit_sig;
COMMENT ON TABLE m_defense_incendie.lt_pei_marque
  IS 'Code permettant de décrire la marque du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_marque.code IS 'Code de la liste énumérée relative à la marque du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_marque.valeur IS 'Valeur de la liste énumérée relative à la marque du PEI';



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
ALTER TABLE m_defense_incendie.lt_pei_marque ALTER COLUMN code SET DEFAULT to_char(nextval('m_defense_incendie.lt_pei_marque_seq'::regclass),'FM00');




-- ################################################################# Domaine valeur ouvert - delegataire  ###############################################

-- Table: m_defense_incendie.lt_pei_delegat

-- DROP TABLE m_defense_incendie.lt_pei_delegat;

CREATE TABLE m_defense_incendie.lt_pei_delegat
(
  code character varying(2) NOT NULL,
  valeur character varying(80) NOT NULL,
  CONSTRAINT lt_pei_delegat_pkey PRIMARY KEY (code)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE m_defense_incendie.lt_pei_delegat
  OWNER TO sig_create;
GRANT SELECT ON TABLE m_defense_incendie.lt_pei_delegat TO read_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_defense_incendie.lt_pei_delegat TO edit_sig;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_delegat TO create_sig;

COMMENT ON TABLE m_defense_incendie.lt_pei_delegat
  IS 'Code permettant de décrire le délégataire du réseaux surlequel est lié un PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_delegat.code IS 'Code de la liste énumérée relative au délégataire du réseaux surlequel est lié un PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_delegat.valeur IS 'Valeur de la liste énumérée relative au délégataire du réseaux surlequel est lié un PEI';


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
ALTER TABLE m_defense_incendie.lt_pei_delegat ALTER COLUMN code SET DEFAULT to_char(nextval('m_defense_incendie.lt_pei_delegat_seq'::regclass),'FM00');



-- ################################################################# Domaine valeur ouvert - raccord  ###############################################

-- Table: m_defense_incendie.lt_pei_raccord

-- DROP TABLE m_defense_incendie.lt_pei_raccord;

CREATE TABLE m_defense_incendie.lt_pei_raccord
(
  code character varying(2) NOT NULL,
  valeur character varying(80) NOT NULL,
  CONSTRAINT lt_pei_raccord_pkey PRIMARY KEY (code)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE m_defense_incendie.lt_pei_raccord
  OWNER TO sig_create;
GRANT SELECT ON TABLE m_defense_incendie.lt_pei_raccord TO read_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_defense_incendie.lt_pei_raccord TO edit_sig;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_raccord TO create_sig;

COMMENT ON TABLE m_defense_incendie.lt_pei_raccord
  IS 'Code permettant de décrire le type de raccord du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_raccord.code IS 'Code de la liste énumérée relative au type de raccord du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_raccord.valeur IS 'Valeur de la liste énumérée relative au type de raccord du PEI';


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

ALTER TABLE m_defense_incendie.lt_pei_raccord ALTER COLUMN code SET DEFAULT to_char(nextval('m_defense_incendie.lt_pei_raccord_seq'::regclass),'FM00');

-- ################################################################# Domaine valeur - src_geom  ###############################################

-- Type d'énumération urbanisé et présent dans le schéma r_objet
-- Voir table r_objet.lt_src_geom
