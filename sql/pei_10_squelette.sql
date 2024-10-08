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
DROP SEQUENCE IF EXISTS m_defense_incendie.lt_pei_marque_seq;
DROP SEQUENCE IF EXISTS m_defense_incendie.lt_pei_raccord_seq;

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
    ('f','Non','0'),
    ('z','Non concerné',NULL);

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


-- ################################################################# Domaine valeur - lt_pei_materiau  ###############################################

-- Table: m_defense_incendie.lt_pei_materiau

-- DROP TABLE m_defense_incendie.lt_pei_materiau;

CREATE TABLE m_defense_incendie.lt_pei_materiau
(
  code character varying(2) NOT NULL,
  valeur character varying(80) NOT NULL,
  CONSTRAINT lt_pei_materiau_pkey PRIMARY KEY (code)
)
WITH (
  OIDS=FALSE
);


COMMENT ON TABLE m_defense_incendie.lt_pei_materiau
  IS 'Code permettant de décrire les types de matériaux des canalisations reliés au PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_materiau.code IS 'Code du matériau';
COMMENT ON COLUMN m_defense_incendie.lt_pei_materiau.valeur IS 'Valeur du matériau';

INSERT INTO m_defense_incendie.lt_pei_materiau(
            code, valeur)
    VALUES
    ('00','Non renseigné'),
    ('10','Fonte intdéterminée'),
    ('11','Acier'),
    ('12','Fonte grise'),
    ('13','Fonte bluetop'),
    ('14','Fonte ductile'),
    ('20','PVC indéterminé'),
    ('21','PVC'),
    ('22','PE noir'),
    ('23','PE bandes bleues'),
    ('ZZ','Non concerné');

-- ################################################################# Domaine valeur - lt_pei_diam_materiau  ###############################################

-- Table: m_defense_incendie.lt_pei_diam_materiau

-- DROP TABLE m_defense_incendie.lt_pei_diam_materiau;

CREATE TABLE m_defense_incendie.lt_pei_diam_materiau
(
  code character varying(2) NOT NULL,
  valeur character varying(80) NOT NULL
)
WITH (
  OIDS=FALSE
);


COMMENT ON TABLE m_defense_incendie.lt_pei_diam_materiau
  IS 'Code permettant de décrire les diamètres des matériaux des canalisations reliés au PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_diam_materiau.code IS 'Code du diamètre';
COMMENT ON COLUMN m_defense_incendie.lt_pei_diam_materiau.valeur IS 'Valeur du diamètre';
COMMENT ON COLUMN m_defense_incendie.lt_pei_diam_materiau.typ IS 'Type de matériau (permettant de faire des listes imbriquées dans GEO)';

INSERT INTO m_defense_incendie.lt_pei_diam_materiau(
            code, valeur,typ)
    VALUES
    ('00','Non renseigné','00'),
    ('01','<60','10'),
    ('01','<60','11'),
    ('01','<60','12'),
    ('01','<60','13'),
    ('01','<60','14'),
    ('02','60','10'),
    ('02','60','11'),
    ('02','60','12'),
    ('02','60','13'),
    ('02','60','14'),
    ('03','80','10'),
    ('03','80','11'),
    ('03','80','12'),
    ('03','80','13'),
    ('03','80','14'),
    ('04','100','10'),
    ('04','100','11'),
    ('04','100','12'),
    ('04','100','13'),
    ('04','100','14'),  
    ('05','125','10'),
    ('05','125','11'),
    ('05','125','12'),
    ('05','125','13'),
    ('05','125','14'),    
    ('06','150','10'),
    ('06','150','11'),
    ('06','150','12'),
    ('06','150','13'),
    ('06','150','14'),    
    ('07','200','10'),
    ('07','200','11'),
    ('07','200','12'),
    ('07','200','13'),
    ('07','200','14'),      
    ('08','250','10'),
    ('08','250','11'),
    ('08','250','12'),
    ('08','250','13'),
    ('08','250','14'),        
    ('09','300','10'),
    ('09','300','11'),
    ('09','300','12'),
    ('09','300','13'),
    ('09','300','14'),          
    ('10','350','10'),
    ('10','350','11'),
    ('10','350','12'),
    ('10','350','13'),
    ('10','350','14'),            
    ('11','400','10'),
    ('11','400','11'),
    ('11','400','12'),
    ('11','400','13'),
    ('11','400','14'),              
    ('12','450','10'),
    ('12','450','11'),
    ('12','450','12'),
    ('12','450','13'),
    ('12','450','14'),                
    ('13','500','10'),
    ('13','500','11'),
    ('13','500','12'),
    ('13','500','13'),
    ('13','500','14'),                  
    ('14','600','10'),
    ('14','600','11'),
    ('14','600','12'),
    ('14','600','13'),
    ('14','600','14'),                    
    ('15','<63','20'),
    ('15','<63','21'),
    ('15','<63','22'),
    ('15','63','23'),
    ('16','63','20'),
    ('16','63','21'),
    ('16','63','22'),
    ('16','63','23'),
    ('17','90','20'),
    ('17','90','21'),
    ('17','90','22'),
    ('17','90','23'),
    ('18','110','20'),
    ('18','110','21'),
    ('18','110','22'),
    ('18','110','23'),  
    ('19','160','20'),
    ('19','160','21'),
    ('19','160','22'),
    ('19','160','23'),    
    ('20','180','20'),
    ('20','180','21'),
    ('20','180','22'),
    ('20','180','23'),      
    ('21','335','20'),
    ('21','335','21'),
    ('21','335','22'),
    ('21','335','23'),        
    ('ZZ','Non concerné','ZZ');

-- ################################################################# Domaine valeur - src_geom  ###############################################

-- Type d'énumération urbanisé et présent dans le schéma r_objet
-- Voir table r_objet.lt_src_geom

-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                TABLE                                                           ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################


DROP TABLE IF EXISTS m_defense_incendie.an_pei_ctr;
DROP TABLE IF EXISTS m_defense_incendie.geo_pei;
DROP TABLE IF EXISTS m_defense_incendie.log_pei;

-- #################################################################### Point d'eau incendie ####################################################  
  
-- Table: m_defense_incendie.geo_pei

-- DROP TABLE m_defense_incendie.geo_pei;

CREATE TABLE m_defense_incendie.geo_pei
(
  id_pei bigint NOT NULL, 
  id_sdis character varying(254),
  verrou boolean NOT NULL DEFAULT false,
  ref_terr character varying(254), 
  insee character varying(5) NOT NULL, 
  type_pei character varying(2) NOT NULL,
  type_rd character varying(254),
  diam_pei integer,
  raccord character varying(2),
  marque character varying(2),
  source_pei character varying(3),
  debit_r_ci real,
  volume integer,
  mate_cana varchar(2),
  diam_cana varchar(2),
  etat_pei character varying(2),
  statut character varying(2),
  nom_etab character varying(254),
  gestion character varying(2), 
  delegat character varying(2),
  cs_sdis character varying(5),
  situation character varying(254),
  observ character varying(254),
  photo_url character varying(254),
  src_pei character varying(254),
  x_l93 numeric(8,2) NOT NULL,
  y_l93 numeric(9,2) NOT NULL,
  src_geom character varying(2) NOT NULL DEFAULT '00' ::bpchar,
  src_date character varying(4) NOT NULL DEFAULT '0000' ::bpchar,
  prec character varying(5) NOT NULL,
  ope_sai character varying(254),
  date_sai timestamp without time zone NOT NULL DEFAULT now(),  
  date_maj timestamp without time zone,
  geom geometry(Point,2154),
  geom1 geometry(Polygon,2154),

  CONSTRAINT geo_pei_pkey PRIMARY KEY (id_pei),
  CONSTRAINT geo_sdis_ukey UNIQUE (id_sdis)
)
WITH (
  OIDS=FALSE
);

COMMENT ON TABLE m_defense_incendie.geo_pei
  IS 'Classe décrivant un point d''eau incendie';
COMMENT ON COLUMN m_defense_incendie.geo_pei.id_pei IS 'Identifiant unique du PEI';
COMMENT ON COLUMN m_defense_incendie.geo_pei.id_sdis IS 'Identifiant unique du PEI du SDIS';
COMMENT ON COLUMN m_defense_incendie.geo_pei.verrou IS 'Entitée figée en modification';
COMMENT ON COLUMN m_defense_incendie.geo_pei.ref_terr IS 'Référence du PEI sur le terrain';
COMMENT ON COLUMN m_defense_incendie.geo_pei.insee IS 'Code INSEE';
COMMENT ON COLUMN m_defense_incendie.geo_pei.type_pei IS 'Type de PEI';
COMMENT ON COLUMN m_defense_incendie.geo_pei.type_rd IS 'Type de PEI selon la nomenclature du réglement départemental';
COMMENT ON COLUMN m_defense_incendie.geo_pei.diam_pei IS 'Diamètre intérieur du PEI (PI et BI)';
COMMENT ON COLUMN m_defense_incendie.geo_pei.raccord IS 'Descriptif des raccords de sortie du PEI (nombre et diamètres exprimés en mm)';
COMMENT ON COLUMN m_defense_incendie.geo_pei.marque IS 'Marque du fabriquant du PEI';
COMMENT ON COLUMN m_defense_incendie.geo_pei.source_pei IS 'Source du point d''eau';
COMMENT ON COLUMN m_defense_incendie.geo_pei.volume IS 'Capacité volumique utile de la source d''eau en m3/h. Si la source est inépuisable (cour d''eau ou plan d''eau pérenne), l''information est nulle';
COMMENT ON COLUMN m_defense_incendie.geo_pei.debit_r_ci IS 'Valeur de débit de remplissage pour les CI en m3/h';
COMMENT ON COLUMN m_defense_incendie.geo_pei.diam_cana IS 'Diamètre de la canalisation desservant le PEI exprimé en mm pour les PI et BI';
COMMENT ON COLUMN m_defense_incendie.geo_pei.mate_cana IS 'Matériau de la canalisation desservant le PEI pour les PI et BI';
COMMENT ON COLUMN m_defense_incendie.geo_pei.etat_pei IS 'Etat d''actualité du PEI';
COMMENT ON COLUMN m_defense_incendie.geo_pei.statut IS 'Statut juridique';
COMMENT ON COLUMN m_defense_incendie.geo_pei.nom_etab IS 'Dans le cas d''un PEI de statut privé, nom de l''établissement propriétaire';
COMMENT ON COLUMN m_defense_incendie.geo_pei.gestion IS 'Gestionnaire du PEI';
COMMENT ON COLUMN m_defense_incendie.geo_pei.delegat IS 'Délégataire du réseau pour les PI et BI';
COMMENT ON COLUMN m_defense_incendie.geo_pei.cs_sdis IS 'Code INSEE du centre de secours du SDIS en charge du volet opérationnel';
COMMENT ON COLUMN m_defense_incendie.geo_pei.situation IS 'Adresse ou information permettant de faciliter la localisation du PEI sur le terrain';
COMMENT ON COLUMN m_defense_incendie.geo_pei.observ IS 'Observations';
COMMENT ON COLUMN m_defense_incendie.geo_pei.photo_url IS 'Lien vers une photo du PEI';                                                                                                 
COMMENT ON COLUMN m_defense_incendie.geo_pei.src_pei IS 'Organisme source de l''information PEI';
COMMENT ON COLUMN m_defense_incendie.geo_pei.x_l93 IS 'Coordonnée X en mètre';
COMMENT ON COLUMN m_defense_incendie.geo_pei.y_l93 IS 'Coordonnée Y en mètre';
COMMENT ON COLUMN m_defense_incendie.geo_pei.src_geom IS 'Référentiel de saisie';
COMMENT ON COLUMN m_defense_incendie.geo_pei.src_date IS 'Année du millésime du référentiel de saisie';
COMMENT ON COLUMN m_defense_incendie.geo_pei.prec IS 'Précision cartographique exprimée en cm';
COMMENT ON COLUMN m_defense_incendie.geo_pei.ope_sai IS 'Opérateur de la dernière saisie en base de l''objet';
COMMENT ON COLUMN m_defense_incendie.geo_pei.date_sai IS 'Horodatage de l''intégration en base de l''objet';
COMMENT ON COLUMN m_defense_incendie.geo_pei.date_maj IS 'Horodatage de la mise à jour en base de l''objet';
COMMENT ON COLUMN m_defense_incendie.geo_pei.geom IS 'Géomètrie ponctuelle de l''objet';
COMMENT ON COLUMN m_defense_incendie.geo_pei.geom1 IS 'Géomètrie de la zone de defense incendie de l''objet PEI';

ALTER TABLE m_defense_incendie.geo_pei ALTER COLUMN id_pei SET DEFAULT nextval('m_defense_incendie.geo_pei_id_seq'::regclass);

-- ####################################################################  Mesures et controles des points d'eau incendie ####################################################  
  
-- Table: m_defense_incendie.an_pei_ctr

-- DROP TABLE m_defense_incendie.an_pei_ctr;

CREATE TABLE m_defense_incendie.an_pei_ctr
(
  id_pei bigint NOT NULL, 
  id_sdis character varying(254),
  id_contrat character varying(2),
  press_stat real,
  press_dyn real,
  debit real,
  debit_max real,
  etat_anom character varying(1) NOT NULL,
  lt_anom character varying(254),
  etat_acces character varying(1) NOT NULL,
  etat_sign character varying(1) NOT NULL,
  etat_conf character varying(1) NOT NULL,
  date_mes date,
  date_ct date,
  ope_ct character varying(254),
  date_ro date,
CONSTRAINT an_pei_ctr_pkey PRIMARY KEY (id_pei),
  CONSTRAINT an_pei_ctr_ukey UNIQUE (id_sdis)
)
WITH (
  OIDS=FALSE
);

COMMENT ON TABLE m_defense_incendie.an_pei_ctr
  IS 'Classe décrivant le contrôle d''un point d''eau incendie';
COMMENT ON COLUMN m_defense_incendie.an_pei_ctr.id_pei IS 'Identifiant unique du PEI';
COMMENT ON COLUMN m_defense_incendie.an_pei_ctr.id_sdis IS 'Identifiant unique du PEI du SDIS';
COMMENT ON COLUMN m_defense_incendie.an_pei_ctr.id_contrat IS 'Référence du contrat de prestation pour le contrôle technique du PEI';
COMMENT ON COLUMN m_defense_incendie.an_pei_ctr.press_stat IS 'Pression statique en bar à un débit de 0 m3/h';
COMMENT ON COLUMN m_defense_incendie.an_pei_ctr.press_dyn IS 'Pression dynamique résiduelle en bar à un débit de 60 m3/h';
COMMENT ON COLUMN m_defense_incendie.an_pei_ctr.debit IS 'Valeur de débit mesuré exprimé en m3/h sous une pression de 1 bar';
COMMENT ON COLUMN m_defense_incendie.an_pei_ctr.debit_max IS 'Valeur de débit maximal à gueule bée mesuré exprimé en m3/h';
COMMENT ON COLUMN m_defense_incendie.an_pei_ctr.etat_anom IS 'Etat d''anomalies du PEI';
COMMENT ON COLUMN m_defense_incendie.an_pei_ctr.lt_anom IS 'Liste des anomalies du PEI';
COMMENT ON COLUMN m_defense_incendie.an_pei_ctr.etat_acces IS 'Etat de l''accessibilité du PEI';
COMMENT ON COLUMN m_defense_incendie.an_pei_ctr.etat_sign IS 'Etat de la signalisation du PEI';
COMMENT ON COLUMN m_defense_incendie.an_pei_ctr.etat_conf IS 'Etat de la conformité technique du PEI';
COMMENT ON COLUMN m_defense_incendie.an_pei_ctr.date_mes IS 'Date de mise en service du PEI (correspond à la date du premier contrôle débit-pression effectué sur le terrain)';
COMMENT ON COLUMN m_defense_incendie.an_pei_ctr.date_ct IS 'Date du dernier contrôle';
COMMENT ON COLUMN m_defense_incendie.an_pei_ctr.ope_ct IS 'Opérateur du dernier contrôle';
COMMENT ON COLUMN m_defense_incendie.an_pei_ctr.date_ro IS 'Date de la dernière reconnaissance opérationnelle';                                                                                                   



-- #################################################################### LOG BASE DE DONNEES PEI ####################################################  
  
-- Table: m_defense_incendie.log_pei

-- DROP TABLE m_defense_incendie.log_pei;

CREATE TABLE m_defense_incendie.log_pei
(
  id_audit bigint NOT NULL,
  type_ope text NOT NULL,
  ope_sai character varying(254),
  id_pei bigint NOT NULL,
  date_maj timestamp without time zone NOT NULL,

  CONSTRAINT log_pei_pkey PRIMARY KEY (id_audit)
)
WITH (
  OIDS=FALSE
);

COMMENT ON TABLE m_defense_incendie.log_pei
  IS 'Table d''audit des opérations sur la base de données PEI';
COMMENT ON COLUMN m_defense_incendie.log_pei.id_audit IS 'Identifiant unique de l''opération de base PEI';
COMMENT ON COLUMN m_defense_incendie.log_pei.type_ope IS 'Type d''opération intervenue sur la base PEI';
COMMENT ON COLUMN m_defense_incendie.log_pei.ope_sai IS 'Utilisateur ayant effectuée l''opération sur la base PEI';
COMMENT ON COLUMN m_defense_incendie.log_pei.id_pei IS 'Identifiant du PEI concerné par l''opération sur la base PEI';
COMMENT ON COLUMN m_defense_incendie.log_pei.date_maj IS 'Horodatage de l''opération sur la base PEI';

ALTER TABLE m_defense_incendie.log_pei ALTER COLUMN id_audit SET DEFAULT nextval('m_defense_incendie.log_pei_id_seq'::regclass);


-- #################################################################### ERREUR MESSAGE PEI ####################################################  
  

-- Table: x_apps.xapps_geo_v_pei_ctr_erreur

-- DROP TABLE x_apps.xapps_geo_v_pei_ctr_erreur;

CREATE TABLE x_apps.xapps_geo_v_pei_ctr_erreur
(
  gid integer NOT NULL, -- Identifiant unique
  id_pei integer, -- Identifiant du PEI
  erreur character varying(500), -- Message
  horodatage timestamp without time zone, -- Date (avec heure) de génération du message (ce champ permet de filtrer l'affichage < x seconds dans GEo)
  CONSTRAINT xapps_geo_v_pei_ctr_erreur_pkey PRIMARY KEY (gid)
)
WITH (
  OIDS=FALSE
);

COMMENT ON TABLE x_apps.xapps_geo_v_pei_ctr_erreur
  IS 'Table gérant les messages d''erreurs de sécurité remontés dans GEO suite à des enregistrements de contrôle PEI';
COMMENT ON COLUMN x_apps.xapps_geo_v_pei_ctr_erreur.gid IS 'Identifiant unique';
COMMENT ON COLUMN x_apps.xapps_geo_v_pei_ctr_erreur.id_pei IS 'Identifiant du PEI';
COMMENT ON COLUMN x_apps.xapps_geo_v_pei_ctr_erreur.erreur IS 'Message';
COMMENT ON COLUMN x_apps.xapps_geo_v_pei_ctr_erreur.horodatage IS 'Date (avec heure) de génération du message (ce champ permet de filtrer l''affichage < x seconds dans GEo)';

    

-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                        FKEY                                                                  ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################


-- ************ GEO_PEI ************ 

-- Foreign Key: m_defense_incendie.lt_pei_type_pei_fkey

-- ALTER TABLE m_defense_incendie.geo_pei DROP CONSTRAINT lt_pei_type_pei_fkey;

ALTER TABLE m_defense_incendie.geo_pei
  ADD CONSTRAINT lt_pei_type_pei_fkey FOREIGN KEY (type_pei)
      REFERENCES m_defense_incendie.lt_pei_type_pei (code) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;


-- Foreign Key: m_defense_incendie.lt_pei_diam_pei_fkey

-- ALTER TABLE m_defense_incendie.geo_pei DROP CONSTRAINT lt_pei_diam_pei_fkey;

ALTER TABLE m_defense_incendie.geo_pei
  ADD CONSTRAINT lt_pei_diam_pei_fkey FOREIGN KEY (diam_pei)
      REFERENCES m_defense_incendie.lt_pei_diam_pei (code) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;
      
      
-- Foreign Key: m_defense_incendie.lt_pei_source_pei_fkey

-- ALTER TABLE m_defense_incendie.geo_pei DROP CONSTRAINT lt_pei_source_pei_fkey;

ALTER TABLE m_defense_incendie.geo_pei
  ADD CONSTRAINT lt_pei_source_pei_fkey FOREIGN KEY (source_pei)
      REFERENCES m_defense_incendie.lt_pei_source_pei (code) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;


-- Foreign Key: m_defense_incendie.lt_pei_statut_fkey

-- ALTER TABLE m_defense_incendie.geo_pei DROP CONSTRAINT lt_pei_statut_fkey;

ALTER TABLE m_defense_incendie.geo_pei
  ADD CONSTRAINT lt_pei_statut_fkey FOREIGN KEY (statut)
      REFERENCES m_defense_incendie.lt_pei_statut (code) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;              


-- Foreign Key: m_defense_incendie.lt_pei_gestion_fkey

-- ALTER TABLE m_defense_incendie.geo_pei DROP CONSTRAINT lt_pei_gestion_fkey;

ALTER TABLE m_defense_incendie.geo_pei
  ADD CONSTRAINT lt_pei_gestion_fkey FOREIGN KEY (gestion)
      REFERENCES m_defense_incendie.lt_pei_gestion (code) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;  

-- Foreign Key: m_defense_incendie.lt_pei_etat_pei_fkey

-- ALTER TABLE m_defense_incendie.geo_pei DROP CONSTRAINT lt_pei_etat_pei_fkey;

ALTER TABLE m_defense_incendie.geo_pei
  ADD CONSTRAINT lt_pei_etat_pei_fkey FOREIGN KEY (etat_pei)
      REFERENCES m_defense_incendie.lt_pei_etat_pei (code) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;
      
-- Foreign Key: m_defense_incendie.lt_pei_cs_sdis_fkey

-- ALTER TABLE m_defense_incendie.geo_pei DROP CONSTRAINT lt_pei_cs_sdis_fkey;

ALTER TABLE m_defense_incendie.geo_pei
  ADD CONSTRAINT lt_pei_cs_sdis_fkey FOREIGN KEY (cs_sdis)
      REFERENCES m_defense_incendie.lt_pei_cs_sdis (code) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;
      
-- Foreign Key: m_defense_incendie.lt_pei_marque_fkey

-- ALTER TABLE m_defense_incendie.geo_pei DROP CONSTRAINT lt_pei_marque_fkey;

ALTER TABLE m_defense_incendie.geo_pei
  ADD CONSTRAINT lt_pei_marque_fkey FOREIGN KEY (marque)
      REFERENCES m_defense_incendie.lt_pei_marque (code) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;
      
      
-- Foreign Key: m_defense_incendie.lt_pei_raccord_fkey

-- ALTER TABLE m_defense_incendie.geo_pei DROP CONSTRAINT lt_pei_raccord_fkey;

ALTER TABLE m_defense_incendie.geo_pei
  ADD CONSTRAINT lt_pei_raccord_fkey FOREIGN KEY (raccord)
      REFERENCES m_defense_incendie.lt_pei_raccord (code) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;
      
-- Foreign Key: m_defense_incendie.lt_pei_delegat_fkey

-- ALTER TABLE m_defense_incendie.geo_pei DROP CONSTRAINT lt_pei_delegat_fkey;

ALTER TABLE m_defense_incendie.geo_pei
  ADD CONSTRAINT lt_pei_delegat_fkey FOREIGN KEY (delegat)
      REFERENCES m_defense_incendie.lt_pei_delegat (code) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;            


-- Foreign Key: m_defense_incendie.lt_pei_src_geom_fkey

-- ALTER TABLE m_defense_incendie.geo_pei DROP CONSTRAINT lt_pei_src_geom_fkey;

ALTER TABLE m_defense_incendie.geo_pei
  ADD CONSTRAINT lt_pei_src_geom_fkey FOREIGN KEY (src_geom)
      REFERENCES r_objet.lt_src_geom (code) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;


-- ************ AN_PEI_CTR ************ 


-- Foreign Key: m_defense_incendie.lt_pei_id_contrat_fkey

-- ALTER TABLE m_defense_incendie.an_pei_ctr DROP CONSTRAINT lt_pei_id_contrat_fkey;

ALTER TABLE m_defense_incendie.an_pei_ctr
  ADD CONSTRAINT lt_pei_id_contrat_fkey FOREIGN KEY (id_contrat)
      REFERENCES r_objet.lt_contrat (code) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

-- Foreign Key: m_defense_incendie.lt_pei_etat_anom_fkey

-- ALTER TABLE m_defense_incendie.an_pei_ctr DROP CONSTRAINT lt_pei_etat_anom_fkey;

ALTER TABLE m_defense_incendie.an_pei_ctr
  ADD CONSTRAINT lt_pei_etat_anom_fkey FOREIGN KEY (etat_anom)
      REFERENCES m_defense_incendie.lt_pei_etat_boolean (code) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION; 
      
-- Foreign Key: m_defense_incendie.lt_pei_etat_acces_fkey

-- ALTER TABLE m_defense_incendie.an_pei_ctr DROP CONSTRAINT lt_pei_etat_acces_fkey;

ALTER TABLE m_defense_incendie.an_pei_ctr
  ADD CONSTRAINT lt_pei_etat_acces_fkey FOREIGN KEY (etat_acces)
      REFERENCES m_defense_incendie.lt_pei_etat_boolean (code) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;
      
      
-- Foreign Key: m_defense_incendie.lt_pei_etat_sign_fkey

-- ALTER TABLE m_defense_incendie.an_pei_ctr DROP CONSTRAINT lt_pei_etat_sign_fkey;

ALTER TABLE m_defense_incendie.an_pei_ctr
  ADD CONSTRAINT lt_pei_etat_sign_fkey FOREIGN KEY (etat_sign)
      REFERENCES m_defense_incendie.lt_pei_etat_boolean (code) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;    

-- Foreign Key: m_defense_incendie.lt_pei_etat_conf_fkey

-- ALTER TABLE m_defense_incendie.an_pei_ctr DROP CONSTRAINT lt_pei_etat_conf_fkey;

ALTER TABLE m_defense_incendie.an_pei_ctr
  ADD CONSTRAINT lt_pei_etat_conf_fkey FOREIGN KEY (etat_conf)
      REFERENCES m_defense_incendie.lt_pei_etat_boolean (code) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION; 

-- ALTER TABLE m_defense_incendie.geo_pei DROP CONSTRAINT geo_pei_materiau_fkey;

ALTER TABLE m_defense_incendie.geo_pei 
  ADD CONSTRAINT geo_pei_materiau_fkey FOREIGN KEY (mate_cana) 
  REFERENCES m_defense_incendie.lt_pei_materiau(code)
  ON UPDATE NO ACTION ON DELETE NO ACTION; 

-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                INDEX                                                           ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################


-- Index: m_defense_incendie.geo_pei_geom

-- DROP INDEX m_defense_incendie.geo_pei_geom;

CREATE INDEX sidx_geo_pei_geom
  ON m_defense_incendie.geo_pei
  USING gist
  (geom);

-- Index: m_defense_incendie.geo_pei_geom1

-- DROP INDEX m_defense_incendie.geo_pei_geom1;

CREATE INDEX sidx_geo_pei_geom1
  ON m_defense_incendie.geo_pei
  USING gist
  (geom1);










