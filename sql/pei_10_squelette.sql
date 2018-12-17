/*PEI V1.0*/
/*Creation du squelette de la structure des données (table, séquence, trigger,...) */
/* pei_10_squelette.sql */
/*PostGIS*/

/* Propriétaire : GeoCompiegnois - http://geo.compiegnois.fr/ */
/* Auteur : FLorent Vanhoutte */
/* Participant : Grégory Bodet */

-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                SCHEMA                                                           ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################

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
 
 -- ################################################################# Séquence sur table - lt_pei_id_contrat  ###############################################

 
-- Sequence: m_defense_incendie.lt_pei_id_contrat_seq

-- DROP SEQUENCE m_defense_incendie.lt_pei_id_contrat_seq;

CREATE SEQUENCE m_defense_incendie.lt_pei_id_contrat_seq
  INCREMENT 1
  MINVALUE 0
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;
  
  
-- ################################################################# Séquence sur table - lt_pei_marque  ###############################################


-- Sequence: m_defense_incendie.lt_pei_marque_seq

-- DROP SEQUENCE m_defense_incendie.lt_pei_marque_seq;

CREATE SEQUENCE m_defense_incendie.lt_pei_marque_seq
  INCREMENT 1
  MINVALUE 0
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;

-- ################################################################# Séquence sur table - lt_pei_delegat  ###############################################


-- Sequence: m_defense_incendie.lt_pei_delegat_seq

-- DROP SEQUENCE m_defense_incendie.lt_pei_delegat_seq;

CREATE SEQUENCE m_defense_incendie.lt_pei_delegat_seq
  INCREMENT 1
  MINVALUE 0
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;
  
  
-- ################################################################# Séquence sur table - lt_pei_raccord  ###############################################


-- Sequence: m_defense_incendie.lt_pei_raccord_seq

-- DROP SEQUENCE m_defense_incendie.lt_pei_raccord_seq;

CREATE SEQUENCE m_defense_incendie.lt_pei_raccord_seq
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

COMMENT ON TABLE m_defense_incendie.lt_pei_type_pei
  IS 'Code permettant de décrire le type de point d''eau incendie';
COMMENT ON COLUMN m_defense_incendie.lt_pei_type_pei.code IS 'Code de la liste énumérée relative au type de PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_type_pei.valeur IS 'Valeur de la liste énumérée relative au type de PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_type_pei.affich IS 'Ordre d''affichage de la liste énumérée relative au type de PEI';

INSERT INTO m_defense_incendie.lt_pei_type_pei(
            code, valeur, affich)
    VALUES
    ('PI','Poteau d''incendie','1'),
    ('BI','Prise d''eau sous pression, notamment bouche d''incendie','2'),
    ('PA','Point d''aspiration aménagé (point de puisage)','3'),
    ('CI','Citerne aérienne ou enterrée','4'),  
    ('NR','Non renseigné','5');

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

COMMENT ON TABLE m_defense_incendie.lt_pei_diam_pei
  IS 'Code permettant de décrire le diamètre intérieur du point d''eau incendie (poteau ou bouche)';
COMMENT ON COLUMN m_defense_incendie.lt_pei_diam_pei.code IS 'Code de la liste énumérée relative au diamètre intérieur du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_diam_pei.valeur IS 'Valeur de la liste énumérée relative au diamètre intérieur du PEI';
   
INSERT INTO m_defense_incendie.lt_pei_diam_pei(
            code, valeur)
    VALUES
    ('80','80'),
    ('100','100'),
    ('150','150'),  
    ('0','Non renseigné');
    
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

COMMENT ON TABLE m_defense_incendie.lt_pei_source_pei
  IS 'Code permettant de décrire le type de source d''alimentation du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_source_pei.code IS 'Code de la liste énumérée relative au type de source d''alimentation du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_source_pei.valeur IS 'Valeur de la liste énumérée relative au type de source d''alimentation du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_source_pei.code_open IS 'Code pour les exports opendata de la liste énumérée relative au type de source d''alimentation du PEI';


INSERT INTO m_defense_incendie.lt_pei_source_pei(
            code, valeur, code_open)
    VALUES
    ('CI','Citerne','citerne'),
    ('PE','Plan d''eau','plan_eau'),
    ('PU','Puit','puits'),
    ('CE','Cours d''eau','cours_eau'),
    ('AEP','Réseau AEP','reseau_aep'),
    ('IRR','Réseau d''irrigation','reseau_irrigation'),
    ('PIS','Piscine','piscine'),      
    ('NR','Non renseigné',NULL);

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

COMMENT ON TABLE m_defense_incendie.lt_pei_statut
  IS 'Code permettant de décrire le statut juridique du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_statut.code IS 'Code de la liste énumérée relative au statut juridique du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_statut.valeur IS 'Valeur de la liste énumérée relative au statut juridique du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_statut.code_open IS 'Code pour les exports opendata de la liste énumérée relative au statut juridique du PEI';

INSERT INTO m_defense_incendie.lt_pei_statut(
            code, valeur, code_open)
    VALUES
    ('01','Public','public'),
    ('02','Privé','prive'),
    ('00','Non renseigné',NULL);

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


COMMENT ON TABLE m_defense_incendie.lt_pei_gestion
  IS 'Code permettant de décrire le gestionnaire du point d''eau incendie';
COMMENT ON COLUMN m_defense_incendie.lt_pei_gestion.code IS 'Code de la liste énumérée relative au gestionnaire du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_gestion.valeur IS 'Valeur de la liste énumérée relative au gestionnaire du PEI';

INSERT INTO m_defense_incendie.lt_pei_gestion(
            code, valeur)
    VALUES
    ('01','Etat'),
    ('02','Région'),
    ('03','Département'),
    ('04','Intercommunalité'),
    ('05','Commune'),
    ('06','Office HLM'),
    ('07','Privé'),
    ('99','Autre'), 
    ('ZZ','Non concerné'),  
    ('00','Non renseigné');

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


COMMENT ON TABLE m_defense_incendie.lt_pei_etat_pei
  IS 'Code permettant de décrire l''état d''actualité du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_etat_pei.code IS 'Code de la liste énumérée relative au etat_pei juridique du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_etat_pei.valeur IS 'Valeur de la liste énumérée relative au etat_pei juridique du PEI';

INSERT INTO m_defense_incendie.lt_pei_etat_pei(
            code, valeur)
    VALUES
    ('01','Projet'),
    ('02','Existant'),
    ('03','Supprimé'),
    ('00','Non renseigné');
    
    
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


COMMENT ON TABLE m_defense_incendie.lt_pei_cs_sdis
  IS 'Code permettant de décrire le nom du centre de secours de 1er appel du SDIS en charge du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_cs_sdis.code IS 'Code de la liste énumérée relative au nom du CS SDIS en charge du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_cs_sdis.valeur IS 'Valeur de la liste énumérée relative au nom du CS SDIS en charge du PEI';

INSERT INTO m_defense_incendie.lt_pei_cs_sdis(
            code, valeur)
    VALUES
    ('00000','Non renseigné'),
    ('60159','CS de Compiègne'),
    ('60068','CS de Béthisy-Saint-Pierre'),
    ('60636','CS de Thourotte'),
    ('60667','CS de Verberie'),
    ('60025','CS d''Attichy'),
    ('60223','CS d''Estrées-Saint-Denis'),
    ('60509','CS de Pont-Sainte-Maxence');

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


COMMENT ON TABLE m_defense_incendie.lt_pei_etat_boolean
  IS 'Code permettant de décrire l''état d''un attribut boolean';
COMMENT ON COLUMN m_defense_incendie.lt_pei_etat_boolean.code IS 'Code de la liste énumérée relative à l''état d''un attribut boolean';
COMMENT ON COLUMN m_defense_incendie.lt_pei_etat_boolean.valeur IS 'Valeur de la liste énumérée relative à l''état d''un attribut boolean';
COMMENT ON COLUMN m_defense_incendie.lt_pei_etat_boolean.code_open IS 'Code pour les exports opendata de la liste énumérée relative à l''état d''un attribut boolean';

INSERT INTO m_defense_incendie.lt_pei_etat_boolean(
            code, valeur, code_open)
    VALUES
    ('0','Non renseigné',NULL),
    ('t','Oui','1'),
    ('f','Non','0');

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


COMMENT ON TABLE m_defense_incendie.lt_pei_anomalie
  IS 'Liste des anomalies possibles pour un PEI et de leurs incidences sur la conformité';
COMMENT ON COLUMN m_defense_incendie.lt_pei_anomalie.code IS 'Code de la liste énumérée relative au type d''anomalie d''un PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_anomalie.valeur IS 'Valeur de la liste énumérée relative au type d''anomalie d''un PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_anomalie.csq_acces IS 'Impact de l''anomalie sur l''état de l''accessibilité du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_anomalie.csq_sign IS 'Impact de l''anomalie sur l''état de la signalisation du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_anomalie.csq_conf IS 'Impact de l''anomalie sur l''état de la conformité technique du PEI';

INSERT INTO m_defense_incendie.lt_pei_anomalie(
            code, valeur, csq_acces, csq_sign, csq_conf)
    VALUES
    ('01','Manque bouchon','0','0','0'),
    ('02','Manque capot ou capot HS','0','0','0'),
    ('03','Manque de débit ou volume','0','0','1'),
    ('04','Manque de signalisation','0','1','0'),
    ('05','Problème d''accès','1','0','1'),
    ('06','Ouverture point d''eau difficile','0','0','0'),
    ('07','Fuite hydrant','0','0','0'),
    ('08','Manque butée sur la vis d''ouverture','0','0','0'),
    ('09','Purge HS','0','0','0'),
    ('10','Pas d''écoulement d''eau','0','0','1'),
    ('11','Végétation génante','0','0','0'),
    ('12','Gêne accès extérieur','1','0','0'),
    ('13','Equipement à remplacer','0','0','0'),   
    ('14','Hors service','0','0','1'),
    ('15','Manque d''eau (uniquement citerne ou point d''aspiration)','0','0','1');


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

COMMENT ON TABLE m_defense_incendie.lt_pei_id_contrat
  IS 'Code permettant de décrire un contrat pour l''entretien et de contrôle de PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_id_contrat.code IS 'Code de la liste énumérée relative au numéro de contrat pour l''entretien et de contrôle de PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_id_contrat.valeur IS 'Valeur de la référence du marché du contrat pour l''entretien et de contrôle de PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_id_contrat.definition IS 'Definition du contrat pour l''entretien et de contrôle de PEI';

ALTER TABLE m_defense_incendie.lt_pei_id_contrat ALTER COLUMN code SET DEFAULT to_char(nextval('m_defense_incendie.lt_pei_id_contrat_seq'::regclass),'FM00');

INSERT INTO m_defense_incendie.lt_pei_id_contrat(
            code, valeur, definition)
    VALUES
    ('00','Non renseigné',NULL),
    ('ZZ','Non concerné',NULL),
    (to_char(nextval('m_defense_incendie.lt_pei_id_contrat_seq'::regclass),'FM00'),'Compiègne n°37/2018','Contrat PEI de la ville de Compiègne'),
    (to_char(nextval('m_defense_incendie.lt_pei_id_contrat_seq'::regclass),'FM00'),'ARC n°30/2018','Contrat PEI de l''Agglomération de Compiègne');


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

COMMENT ON TABLE m_defense_incendie.lt_pei_marque
  IS 'Code permettant de décrire la marque du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_marque.code IS 'Code de la liste énumérée relative à la marque du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_marque.valeur IS 'Valeur de la liste énumérée relative à la marque du PEI';

ALTER TABLE m_defense_incendie.lt_pei_marque ALTER COLUMN code SET DEFAULT to_char(nextval('m_defense_incendie.lt_pei_marque_seq'::regclass),'FM00');

INSERT INTO m_defense_incendie.lt_pei_marque(
            code, valeur)
    VALUES
    ('00','Non renseigné' ),
    (to_char(nextval('m_defense_incendie.lt_pei_marque_seq'::regclass),'FM00'),'Bayard'),
    (to_char(nextval('m_defense_incendie.lt_pei_marque_seq'::regclass),'FM00'),'Pont-à-Mousson'),
    (to_char(nextval('m_defense_incendie.lt_pei_marque_seq'::regclass),'FM00'),'AVK');


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

COMMENT ON TABLE m_defense_incendie.lt_pei_delegat
  IS 'Code permettant de décrire le délégataire du réseaux surlequel est lié un PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_delegat.code IS 'Code de la liste énumérée relative au délégataire du réseaux surlequel est lié un PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_delegat.valeur IS 'Valeur de la liste énumérée relative au délégataire du réseaux surlequel est lié un PEI';

ALTER TABLE m_defense_incendie.lt_pei_delegat ALTER COLUMN code SET DEFAULT to_char(nextval('m_defense_incendie.lt_pei_delegat_seq'::regclass),'FM00');

INSERT INTO m_defense_incendie.lt_pei_delegat(
            code, valeur)
    VALUES
    ('00','Non renseigné' ),
    (to_char(nextval('m_defense_incendie.lt_pei_delegat_seq'::regclass),'FM00'),'Suez'),
    (to_char(nextval('m_defense_incendie.lt_pei_delegat_seq'::regclass),'FM00'),'Saur'),
    (to_char(nextval('m_defense_incendie.lt_pei_delegat_seq'::regclass),'FM00'),'Veolia');

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


COMMENT ON TABLE m_defense_incendie.lt_pei_raccord
  IS 'Code permettant de décrire le type de raccord du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_raccord.code IS 'Code de la liste énumérée relative au type de raccord du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_raccord.valeur IS 'Valeur de la liste énumérée relative au type de raccord du PEI';

ALTER TABLE m_defense_incendie.lt_pei_raccord ALTER COLUMN code SET DEFAULT to_char(nextval('m_defense_incendie.lt_pei_raccord_seq'::regclass),'FM00');

INSERT INTO m_defense_incendie.lt_pei_raccord(
            code, valeur)
    VALUES
    ('00','Non renseigné' ),
    (to_char(nextval('m_defense_incendie.lt_pei_raccord_seq'::regclass),'FM00'),'1x100'),
    (to_char(nextval('m_defense_incendie.lt_pei_raccord_seq'::regclass),'FM00'),'1x65'),
    (to_char(nextval('m_defense_incendie.lt_pei_raccord_seq'::regclass),'FM00'),'1x100 - 2x65'),
    (to_char(nextval('m_defense_incendie.lt_pei_raccord_seq'::regclass),'FM00'),'2x100 - 1x65'),
    (to_char(nextval('m_defense_incendie.lt_pei_raccord_seq'::regclass),'FM00'),'3x100'),
    (to_char(nextval('m_defense_incendie.lt_pei_raccord_seq'::regclass),'FM00'),'1x65 - 2x40');

-- ################################################################# Domaine valeur - src_geom  ###############################################

-- Type d'énumération urbanisé et présent dans le schéma r_objet
-- Voir table r_objet.lt_src_geom

-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                TABLE                                                           ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################
















