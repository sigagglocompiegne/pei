/*Détection des réseaux*/
/*Creation du squelette de la structure des données (table, séquence, trigger,...) */
/*init_bd_res_detec_10_squelette.sql */
/*PostGIS*/

/* GeoCompiegnois - http://geo.compiegnois.fr/ */
/* Auteur : Florent Vanhoutte */


/* TO DO

enveloppes (lien avec objet du réseau, vue, trigger ...)
chk relation spatiale insee, verif point, noeud, troncon dans peri de l'opération

*/


-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                        DROP                                                                  ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################


-- trigger

DROP TRIGGER IF EXISTS t_t1_geo_v_detec_noeud_res ON m_reseau_detection.geo_v_detec_noeud_res;
DROP TRIGGER IF EXISTS t_t1_geo_v_detec_troncon_res ON m_reseau_detection.geo_v_detec_troncon_res;

-- fonction trigger

DROP FUNCTION IF EXISTS m_reseau_detection.ft_m_geo_v_detec_noeud_res();
DROP FUNCTION IF EXISTS m_reseau_detection.ft_m_geo_v_detec_troncon_res();

-- vue

DROP VIEW IF EXISTS m_reseau_detection.geo_v_detec_troncon_res;
DROP VIEW IF EXISTS m_reseau_detection.geo_v_detec_noeud_res;

-- fkey

ALTER TABLE IF EXISTS m_reseau_detection.geo_detec_noeud DROP CONSTRAINT IF EXISTS idresdetec_fkey;
ALTER TABLE IF EXISTS m_reseau_detection.geo_detec_troncon DROP CONSTRAINT IF EXISTS idresdetec_fkey;
ALTER TABLE IF EXISTS m_reseau_detection.geo_detec_point DROP CONSTRAINT IF EXISTS lt_clprec_xy_fkey;
ALTER TABLE IF EXISTS m_reseau_detection.geo_detec_point DROP CONSTRAINT IF EXISTS lt_clprec_z_fkey;
ALTER TABLE IF EXISTS m_reseau_detection.an_detec_reseau DROP CONSTRAINT IF EXISTS lt_clprec_xy_fkey;
ALTER TABLE IF EXISTS m_reseau_detection.an_detec_reseau DROP CONSTRAINT IF EXISTS lt_clprec_z_fkey;
ALTER TABLE IF EXISTS m_reseau_detection.geo_detec_point DROP CONSTRAINT IF EXISTS lt_natres_fkey;
ALTER TABLE IF EXISTS m_reseau_detection.an_detec_reseau DROP CONSTRAINT IF EXISTS lt_natres_fkey;
ALTER TABLE IF EXISTS m_reseau_detection.geo_detec_point DROP CONSTRAINT IF EXISTS refope_fkey;
ALTER TABLE IF EXISTS m_reseau_detection.an_detec_reseau DROP CONSTRAINT IF EXISTS refope_fkey;


-- classe

DROP TABLE IF EXISTS m_reseau_detection.geo_detec_operation;
DROP TABLE IF EXISTS m_reseau_detection.geo_detec_point;
DROP TABLE IF EXISTS m_reseau_detection.an_detec_reseau;
DROP TABLE IF EXISTS m_reseau_detection.geo_detec_troncon;
DROP TABLE IF EXISTS m_reseau_detection.geo_detec_noeud;
DROP TABLE IF EXISTS m_reseau_detection.geo_detec_enveloppe;


-- domaine de valeur

DROP TABLE IF EXISTS m_reseau_detection.lt_natres;
DROP TABLE IF EXISTS m_reseau_detection.lt_clprec;


-- sequence

DROP SEQUENCE IF EXISTS m_reseau_detection.geo_detec_operation_id_seq;
DROP SEQUENCE IF EXISTS m_reseau_detection.geo_detec_point_id_seq;
DROP SEQUENCE IF EXISTS m_reseau_detection.an_detec_reseau_id_seq;

-- schema

DROP SCHEMA IF EXISTS m_reseau_detection;


-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                       SCHEMA                                                                 ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################

-- Schema: m_reseau_detection

-- DROP SCHEMA m_reseau_detection;

CREATE SCHEMA m_reseau_detection;

COMMENT ON SCHEMA m_reseau_detection
  IS 'Détection/géoréférencement des réseaux (DT-DICT)';


-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                DOMAINES DE VALEURS                                                           ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################


-- ### domaine de valeur hérité du standard StaR-DT

-- Table: m_reseau_detection.lt_natres

-- DROP TABLE m_reseau_detection.lt_natres;

CREATE TABLE m_reseau_detection.lt_natres
(
  code character varying(7) NOT NULL,
  valeur character varying(80) NOT NULL,
  couleur character varying(7) NOT NULL,
  CONSTRAINT lt_natres_pkey PRIMARY KEY (code)
)
WITH (
  OIDS=FALSE
);

COMMENT ON TABLE m_reseau_detection.lt_natres
  IS 'Type de réseau conformément à la liste des réseaux de la NF P98-332';
COMMENT ON COLUMN m_reseau_detection.lt_natres.code IS 'Code de la liste énumérée relative à la nature du réseau';
COMMENT ON COLUMN m_reseau_detection.lt_natres.valeur IS 'Valeur de la liste énumérée relative à la nature du réseau';
COMMENT ON COLUMN m_reseau_detection.lt_natres.couleur IS 'Code couleur (hexadecimal) des réseaux enterrés selon la norme NF P 98-332';

INSERT INTO m_reseau_detection.lt_natres(
            code, valeur, couleur)
    VALUES
('00','Non défini','#FFFFFF'),
('ELEC','Electricité','#FF0000'),
('ELECECL','Eclairage public','#FF0000'),
('ELECSLT','Signalisation lumineuse tricolore','#FF0000'),
('ELECTRD','Eléctricité transport/distribution','#FF0000'),
('GAZ','Gaz','#FFFF00'),
('CHIM','Produits chimiques','#F99707'),
('AEP','Eau potable','#00B0F0'),
('ASS','Assainissement et pluvial','#663300'),
('ASSEP','Eaux pluviales','#663300'),
('ASSEU','Eaux usées','#663300'),
('ASSUN','Réseau unitaire','#663300'),
('CHAU','Chauffage et climatisation','#7030A0'),
('COM','Télécom','#00FF00'),
('DECH','Déchets','#663300'),
('INCE','Incendie','#00B0F0'),
('PINS','Protection Inondation-Submersion','#663300'),
('MULT','Multi réseaux','#FF00FF');


-- ### domaine de valeur hérité du standard StaR-DT

-- Table: m_reseau_detection.lt_clprec

-- DROP TABLE m_reseau_detection.lt_clprec;

CREATE TABLE m_reseau_detection.lt_clprec
(
  code character varying(1) NOT NULL,
  valeur character varying(80) NOT NULL,
  definition character varying(255),
  CONSTRAINT lt_clprec_pkey PRIMARY KEY (code)
)
WITH (
  OIDS=FALSE
);

COMMENT ON TABLE m_reseau_detection.lt_clprec
  IS 'Classe de précision au sens de l''arrêté interministériel du 15 février 2012 modifié (DT-DICT)';
COMMENT ON COLUMN m_reseau_detection.lt_clprec.code IS 'Code de la liste énumérée relative à la classe de précision au sens de l''arrêté interministériel du 15 février 2012 modifié (DT-DICT)';
COMMENT ON COLUMN m_reseau_detection.lt_clprec.valeur IS 'Valeur de la liste énumérée relative à la classe de précision au sens de l''arrêté interministériel du 15 février 2012 modifié (DT-DICT)';
COMMENT ON COLUMN m_reseau_detection.lt_clprec.definition IS 'Définition de la liste énumérée relative à la classe de précision au sens de l''arrêté interministériel du 15 février 2012 modifié (DT-DICT)';

INSERT INTO m_reseau_detection.lt_clprec(
            code, valeur, definition)
    VALUES
('A','Classe A','Classe de précision inférieure 40 cm'),
('B','Classe B','Classe de précision supérieure à 40 cm et inférieure à 1,50 m'),
('C','Classe C','Classe de précision supérieure à 1,50 m');




-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                     SEQUENCE                                                                 ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################


-- Sequence: m_reseau_detection.geo_detec_operation_id_seq

-- DROP SEQUENCE m_reseau_detection.geo_detec_operation_id_seq;

CREATE SEQUENCE m_reseau_detection.geo_detec_operation_id_seq
  INCREMENT 1
  MINVALUE 0
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;

-- Sequence: m_reseau_detection.geo_detec_point_id_seq

-- DROP SEQUENCE m_reseau_detection.geo_detec_point_id_seq;

CREATE SEQUENCE m_reseau_detection.geo_detec_point_id_seq
  INCREMENT 1
  MINVALUE 0
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;
  
-- Sequence: m_reseau_detection.an_detec_reseau_id_seq

-- DROP SEQUENCE m_reseau_detection.an_detec_reseau_id_seq;

CREATE SEQUENCE m_reseau_detection.an_detec_reseau_id_seq
  INCREMENT 1
  MINVALUE 0
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;
  
-- sequence enveloppe ??    
  

-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                  CLASSE OBJET                                                                ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################


-- #################################################################### CLASSE OPERATION DE DETECTION ###############################################



-- Table: m_reseau_detection.geo_detec_operation

-- DROP TABLE m_reseau_detection.geo_detec_operation;

CREATE TABLE m_reseau_detection.geo_detec_operation
(
  idopedetec character varying(254) NOT NULL,
  refope character varying(254) NOT NULL, -- fkey vers classe opedetec
  natres character varying(7) NOT NULL, -- fkey vers domaine de valeur lt_natres
  mouvrage character varying(80) NOT NULL,
  presta character varying(80) NOT NULL,
-- voir pour préciser le contexte (IC ou OL)
  dateope date NOT NULL,
  nomplan character varying(80),
  urlplan character varying(254),
  date_sai timestamp without time zone NOT NULL DEFAULT now(),  
  date_maj timestamp without time zone,
  geom geometry(MultiPolygon,2154) NOT NULL,
  CONSTRAINT geo_detec_operation_pkey PRIMARY KEY (idopedetec),
  CONSTRAINT refope_ukey UNIQUE (refope) 
)
WITH (
  OIDS=FALSE
);

COMMENT ON TABLE m_reseau_detection.geo_detec_operation
  IS 'Opération de détection de réseaux';
COMMENT ON COLUMN m_reseau_detection.geo_detec_operation.idopedetec IS 'Identifiant unique de l''opération de détection dans la base de données';
COMMENT ON COLUMN m_reseau_detection.geo_detec_operation.refope IS 'Référence de l''opération de détection';
COMMENT ON COLUMN m_reseau_detection.geo_detec_operation.natres IS 'Nature du réseau faisant l''objet de l''opération de détection';
COMMENT ON COLUMN m_reseau_detection.geo_detec_operation.presta IS 'Prestataire de l''opération de détection';
-- ctx IC ou OL
COMMENT ON COLUMN m_reseau_detection.geo_detec_operation.nomplan IS 'Nom du fichier du plan';
COMMENT ON COLUMN m_reseau_detection.geo_detec_operation.urlplan IS 'Lien vers le fichier du plan';
COMMENT ON COLUMN m_reseau_detection.geo_detec_operation.mouvrage IS 'Maitre d''ouvrage de l''opération de détection';
COMMENT ON COLUMN m_reseau_detection.geo_detec_operation.dateope IS 'Date de l''opération de détection';
COMMENT ON COLUMN m_reseau_detection.geo_detec_operation.date_sai IS 'Horodatage de l''intégration en base de l''objet';
COMMENT ON COLUMN m_reseau_detection.geo_detec_operation.date_maj IS 'Horodatage de la mise à jour en base de l''objet';
COMMENT ON COLUMN m_reseau_detection.geo_detec_operation.geom IS 'Géométrie de l''objet';


ALTER TABLE m_reseau_detection.geo_detec_operation ALTER COLUMN idopedetec SET DEFAULT nextval('m_reseau_detection.geo_detec_operation_id_seq'::regclass);


-- #################################################################### CLASSE POINT DE DETECTION/GEOREF ###############################################

-- ## revoir cette classe par rapport à celle du PCRS


-- Table: m_reseau_detection.geo_detec_point

-- DROP TABLE m_reseau_detection.geo_detec_point;

CREATE TABLE m_reseau_detection.geo_detec_point
(
  idptdetec character varying(254) NOT NULL,
  refope character varying(254) NOT NULL, -- fkey vers classe opedetec
  numptope character varying(30) NOT NULL,  -- voir si conserver
  insee character varying(5) NOT NULL,
  typedetec character varying(2) NOT NULL, -- fkey vers domaine de valeur
  methode character varying(80) NOT NULL,  
  natres character varying(7) NOT NULL, -- fkey vers domaine de valeur lt_natres  
  x numeric(10,3) NOT NULL,
  y numeric(11,3) NOT NULL,
  z_gn numeric (7,3) NOT NULL,
  z numeric (7,3),
  p_gn numeric (5,3),
  prec_xy numeric (7,3) NOT NULL,
  prec_z_gn numeric (7,3) NOT NULL,
  clprecxy character varying (1) NOT NULL DEFAULT 'C',  -- voir pour renommer différemment ex : clprecxy
  clprecz character varying (1) NOT NULL DEFAULT 'C', -- voir pour renommer différemment ex : clprecz
  horodatage timestamp without time zone NOT NULL,
  date_sai timestamp without time zone NOT NULL DEFAULT now(),  
  date_maj timestamp without time zone,
  geom geometry(PointZ,2154) NOT NULL,
  CONSTRAINT geo_detec_point_pkey PRIMARY KEY (idptdetec) 
)
WITH (
  OIDS=FALSE
);

COMMENT ON TABLE m_reseau_detection.geo_detec_point
  IS 'Point de détection/géoréférencement d''un réseau';
COMMENT ON COLUMN m_reseau_detection.geo_detec_point.idptdetec IS 'Identifiant unique du point de détection dans la base de données';
COMMENT ON COLUMN m_reseau_detection.geo_detec_point.refope IS 'Référence de l''opération de détection';
COMMENT ON COLUMN m_reseau_detection.geo_detec_point.numptope IS 'Numéro du point dans l''opération de détection';
COMMENT ON COLUMN m_reseau_detection.geo_detec_point.insee IS 'Code INSEE de la commmune';
COMMENT ON COLUMN m_reseau_detection.geo_detec_point.typedetec IS 'Type de ';
COMMENT ON COLUMN m_reseau_detection.geo_detec_point.methode IS 'Méthode employée pour la détection';
COMMENT ON COLUMN m_reseau_detection.geo_detec_point.natres IS 'Nature du réseau détecté';
COMMENT ON COLUMN m_reseau_detection.geo_detec_point.x IS 'Coordonnée X Lambert 93 (en mètres)';
COMMENT ON COLUMN m_reseau_detection.geo_detec_point.y IS 'Coordonnée X Lambert 93 (en mètres)';
COMMENT ON COLUMN m_reseau_detection.geo_detec_point.z_gn IS 'Altimétrie Z de la génératrice (supérieure si enterrée, inférieure si aérienne) du réseau en mètre NGF)';
COMMENT ON COLUMN m_reseau_detection.geo_detec_point.z IS 'Altimétrie Z du terrain affleurant en mètre NGF)';
COMMENT ON COLUMN m_reseau_detection.geo_detec_point.p_gn IS 'Profondeur de la génératrice du réseau en mètre';
COMMENT ON COLUMN m_reseau_detection.geo_detec_point.prec_xy IS 'Précision absolue en planimètre (en centimètres)';
COMMENT ON COLUMN m_reseau_detection.geo_detec_point.prec_z_gn IS 'Précision absolue en altimétrie de la génératrice supérieure (en centimètres)';
COMMENT ON COLUMN m_reseau_detection.geo_detec_point.clprecxy IS 'Classe de précision planimétrique (XY)';
COMMENT ON COLUMN m_reseau_detection.geo_detec_point.clprecz IS 'Classe de précision altimétrique (Z)';
COMMENT ON COLUMN m_reseau_detection.geo_detec_point.horodatage IS 'Horodatage détection/géoréfécement du point';
COMMENT ON COLUMN m_reseau_detection.geo_detec_point.date_sai IS 'Horodatage de l''intégration en base de l''objet';
COMMENT ON COLUMN m_reseau_detection.geo_detec_point.date_maj IS 'Horodatage de la mise à jour en base de l''objet';
COMMENT ON COLUMN m_reseau_detection.geo_detec_point.geom IS 'Géométrie 3D de l''objet';

ALTER TABLE m_reseau_detection.geo_detec_point ALTER COLUMN idptdetec SET DEFAULT nextval('m_reseau_detection.geo_detec_point_id_seq'::regclass);


-- #################################################################### CLASSE RESEAU ###############################################


-- Table: m_reseau_detection.an_detec_reseau

-- DROP TABLE m_reseau_detection.an_detec_reseau;

CREATE TABLE m_reseau_detection.an_detec_reseau
(
  idresdetec character varying(254) NOT NULL,
  refope character varying(254) NOT NULL, -- fkey vers classe opedetec
  insee character varying(5) NOT NULL,
  natres character varying(7) NOT NULL,         -- fkey vers domaine de valeur
  clprecxy character varying (1) NOT NULL DEFAULT 'C',  -- voir pour renommer différemment ex : clprecxy
  clprecz character varying (1) NOT NULL DEFAULT 'C', -- voir pour renommer différemment ex : clprecz    
  date_sai timestamp without time zone NOT NULL DEFAULT now(),  
  date_maj timestamp without time zone, 
  CONSTRAINT an_detec_reseau_pkey PRIMARY KEY (idresdetec) 
)
WITH (
  OIDS=FALSE
);

COMMENT ON TABLE m_reseau_detection.an_detec_reseau
  IS 'Noeud de réseau (ouvrage/appareillage) détecté';
COMMENT ON COLUMN m_reseau_detection.an_detec_reseau.idresdetec IS 'Identifiant unique de l''élément de réseau détecté dans la base de données';
COMMENT ON COLUMN m_reseau_detection.an_detec_reseau.refope IS 'Référence de l''opération de détection';
COMMENT ON COLUMN m_reseau_detection.an_detec_reseau.insee IS 'Code INSEE de la commmune';
COMMENT ON COLUMN m_reseau_detection.an_detec_reseau.natres IS 'Nature du réseau détecté';
COMMENT ON COLUMN m_reseau_detection.an_detec_reseau.clprecxy IS 'Classe de précision planimétrique (XY)';
COMMENT ON COLUMN m_reseau_detection.an_detec_reseau.clprecz IS 'Classe de précision altimétrique (Z)';
COMMENT ON COLUMN m_reseau_detection.an_detec_reseau.date_sai IS 'Horodatage de l''intégration en base de l''objet';
COMMENT ON COLUMN m_reseau_detection.an_detec_reseau.date_maj IS 'Horodatage de la mise à jour en base de l''objet';

ALTER TABLE m_reseau_detection.an_detec_reseau ALTER COLUMN idresdetec SET DEFAULT nextval('m_reseau_detection.an_detec_reseau_id_seq'::regclass);



-- #################################################################### SOUS CLASSE NOEUD (OUVRAGE/APPAREILLAGE) ###############################################

-- Table: m_reseau_detection.geo_detec_noeud

-- DROP TABLE m_reseau_detection.geo_detec_noeud;

CREATE TABLE m_reseau_detection.geo_detec_noeud
(
  idresdetec character varying(254) NOT NULL,
  idndope character varying(254) NOT NULL,
  typenoeud character varying(5) NOT NULL,         -- fkey vers domaine de valeur
-- symb
-- symbangle
  geom geometry(PointZ,2154) NOT NULL,
  CONSTRAINT geo_detec_noeud_pkey PRIMARY KEY (idresdetec) 
)
WITH (
  OIDS=FALSE
);

COMMENT ON TABLE m_reseau_detection.geo_detec_noeud
  IS 'Noeud de réseau (ouvrage/appareillage) détecté';
COMMENT ON COLUMN m_reseau_detection.geo_detec_noeud.idresdetec IS 'Identifiant unique de l''élément de réseau détecté dans la base de données';
COMMENT ON COLUMN m_reseau_detection.geo_detec_noeud.idndope IS 'Identifiant du noeud de réseau détecté dans l''opération de détection';
COMMENT ON COLUMN m_reseau_detection.geo_detec_noeud.typenoeud IS 'Type d''ouvrage ou d''appareillage';
COMMENT ON COLUMN m_reseau_detection.geo_detec_noeud.geom IS 'Géométrie 3D de l''objet';

--ALTER TABLE m_reseau_detection.geo_detec_noeud ALTER COLUMN idresdetec SET DEFAULT nextval('m_reseau_detection.an_detec_reseau_id_seq'::regclass);


-- #################################################################### SOUS CLASSE TRONCON ###############################################

-- Table: m_reseau_detection.geo_detec_troncon

-- DROP TABLE m_reseau_detection.geo_detec_troncon;

CREATE TABLE m_reseau_detection.geo_detec_troncon
(
  idresdetec character varying(254) NOT NULL,
  idtrope integer NOT NULL,
  diametre integer,
-- materiau
-- etat (Abandonné / En attente / En fonctionnement / Hors service) voir si domaine de valeur StaR-DT ou RAEPA
  geom geometry(LineStringZ,2154) NOT NULL,
  CONSTRAINT geo_detec_troncon_pkey PRIMARY KEY (idresdetec) 
)
WITH (
  OIDS=FALSE
);

COMMENT ON TABLE m_reseau_detection.geo_detec_troncon
  IS 'Noeud de réseau (ouvrage/appareillage) détecté';
COMMENT ON COLUMN m_reseau_detection.geo_detec_troncon.idresdetec IS 'Identifiant unique de l''élément de réseau détecté dans la base de données';
COMMENT ON COLUMN m_reseau_detection.geo_detec_troncon.idtrope IS 'Identifiant du tronçon de réseau détecté dans l''opération de détection';
COMMENT ON COLUMN m_reseau_detection.geo_detec_troncon.diametre IS 'Diamètre nominal de la canalisation (en millimètres)';
COMMENT ON COLUMN m_reseau_detection.geo_detec_troncon.geom IS 'Géométrie 3D de l''objet';

--ALTER TABLE m_reseau_detection.geo_detec_troncon ALTER COLUMN idtrdetec SET DEFAULT nextval('m_reseau_detection.an_detec_reseau_id_seq'::regclass);


-- #################################################################### CLASSE ENVELOPPE ###############################################

-- Table: m_reseau_detection.geo_detec_enveloppe

-- DROP TABLE m_reseau_detection.geo_detec_enveloppe;

CREATE TABLE m_reseau_detection.geo_detec_enveloppe
(
  idenvdetec character varying(254) NOT NULL,
  refope character varying(254) NOT NULL, -- fkey vers classe opedetec
  idenvope integer NOT NULL,
  insee character varying(5) NOT NULL,
  natres character varying(7) NOT NULL,         -- fkey vers domaine de valeur  
  date_sai timestamp without time zone NOT NULL DEFAULT now(),  
  date_maj timestamp without time zone, 
  geom geometry(LineString,2154),
  CONSTRAINT geo_detec_enveloppe_pkey PRIMARY KEY (idenvdetec) 
)
WITH (
  OIDS=FALSE
);

COMMENT ON TABLE m_reseau_detection.geo_detec_enveloppe
  IS 'Enveloppe de l''affleurant du réseau détecté';
COMMENT ON COLUMN m_reseau_detection.geo_detec_enveloppe.idenvdetec IS 'Identifiant unique de l''enveloppe de réseau détecté dans la base de données';
COMMENT ON COLUMN m_reseau_detection.geo_detec_enveloppe.refope IS 'Référence de l''opération de détection';
COMMENT ON COLUMN m_reseau_detection.geo_detec_enveloppe.idenvope IS 'Identifiant de l''enveloppe de réseau détecté dans l''opération de détection';
COMMENT ON COLUMN m_reseau_detection.geo_detec_enveloppe.insee IS 'Code INSEE de la commmune';
COMMENT ON COLUMN m_reseau_detection.geo_detec_enveloppe.natres IS 'Nature du réseau détecté';
COMMENT ON COLUMN m_reseau_detection.geo_detec_enveloppe.date_sai IS 'Horodatage de l''intégration en base de l''objet';
COMMENT ON COLUMN m_reseau_detection.geo_detec_enveloppe.date_maj IS 'Horodatage de la mise à jour en base de l''objet';
COMMENT ON COLUMN m_reseau_detection.geo_detec_enveloppe.geom IS 'Géométrie de l''objet';

ALTER TABLE m_reseau_detection.geo_detec_enveloppe ALTER COLUMN idenvdetec SET DEFAULT nextval('m_reseau_detection.an_detec_reseau_id_seq'::regclass);

 
  
-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                           FKEY (clé étrangère)                                                               ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################


-- #### domaine de valeur ####

-- ## NATURE DU RESEAU

-- Foreign Key: m_reseau_detection.lt_natres_fkey

-- ALTER TABLE m_reseau_detection.geo_detec_point DROP CONSTRAINT lt_natres_fkey;

ALTER TABLE m_reseau_detection.geo_detec_point
  ADD CONSTRAINT lt_natres_fkey FOREIGN KEY (natres)
      REFERENCES m_reseau_detection.lt_natres (code) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

-- Foreign Key: m_reseau_detection.lt_natres_fkey

-- ALTER TABLE m_reseau_detection.an_detec_reseau DROP CONSTRAINT lt_natres_fkey;   

ALTER TABLE m_reseau_detection.an_detec_reseau               
  ADD CONSTRAINT lt_natres_fkey FOREIGN KEY (natres)
      REFERENCES m_reseau_detection.lt_natres (code) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;
      

-- ## CLASSE GEOLOC DT-DICT      

-- Foreign Key: m_reseau_detection.lt_clprec_xy_fkey

-- ALTER TABLE m_reseau_detection.geo_detec_point DROP CONSTRAINT lt_clprec_xy_fkey;

ALTER TABLE m_reseau_detection.geo_detec_point
  ADD CONSTRAINT lt_clprec_xy_fkey FOREIGN KEY (clprecxy)
      REFERENCES m_reseau_detection.lt_clprec (code) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

-- Foreign Key: m_reseau_detection.lt_clprec_z_fkey

-- ALTER TABLE m_reseau_detection.geo_detec_point DROP CONSTRAINT lt_clprec_z_fkey;   

ALTER TABLE m_reseau_detection.geo_detec_point               
  ADD CONSTRAINT lt_clprec_z_fkey FOREIGN KEY (clprecz)
      REFERENCES m_reseau_detection.lt_clprec (code) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

-- Foreign Key: m_reseau_detection.lt_clprec_xy_fkey

-- ALTER TABLE m_reseau_detection.an_detec_reseau DROP CONSTRAINT lt_clprec_xy_fkey;

ALTER TABLE m_reseau_detection.an_detec_reseau
  ADD CONSTRAINT lt_clprec_xy_fkey FOREIGN KEY (clprecxy)
      REFERENCES m_reseau_detection.lt_clprec (code) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

-- Foreign Key: m_reseau_detection.lt_clprec_z_fkey

-- ALTER TABLE m_reseau_detection.an_detec_reseau DROP CONSTRAINT lt_clprec_z_fkey;   

ALTER TABLE m_reseau_detection.an_detec_reseau               
  ADD CONSTRAINT lt_clprec_z_fkey FOREIGN KEY (clprecz)
      REFERENCES m_reseau_detection.lt_clprec (code) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;


-- #### FKEY ####


-- ## idresdetec

-- Foreign Key: m_reseau_detection.idresdetec_fkey

-- ALTER TABLE m_reseau_detection.geo_detec_noeud DROP CONSTRAINT idresdetec_fkey;   

ALTER TABLE m_reseau_detection.geo_detec_noeud               
  ADD CONSTRAINT idresdetec_fkey FOREIGN KEY (idresdetec)
      REFERENCES m_reseau_detection.an_detec_reseau (idresdetec) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

-- Foreign Key: m_reseau_detection.idresdetec_fkey

-- ALTER TABLE m_reseau_detection.geo_detec_troncon DROP CONSTRAINT idresdetec_fkey;   

ALTER TABLE m_reseau_detection.geo_detec_troncon               
  ADD CONSTRAINT idresdetec_fkey FOREIGN KEY (idresdetec)
      REFERENCES m_reseau_detection.an_detec_reseau (idresdetec) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

      
-- ## refope

-- Foreign Key: m_reseau_detection.refope_fkey

-- ALTER TABLE m_reseau_detection.an_detec_reseau DROP CONSTRAINT refope_fkey;   

ALTER TABLE m_reseau_detection.an_detec_reseau               
  ADD CONSTRAINT refope_fkey FOREIGN KEY (refope)
      REFERENCES m_reseau_detection.geo_detec_operation (refope) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;
      
-- Foreign Key: m_reseau_detection.refope_fkey

-- ALTER TABLE m_reseau_detection.geo_detec_point DROP CONSTRAINT refope_fkey;   

ALTER TABLE m_reseau_detection.geo_detec_point               
  ADD CONSTRAINT refope_fkey FOREIGN KEY (refope)
      REFERENCES m_reseau_detection.geo_detec_operation (refope) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION; 

      

-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                        VUES                                                                  ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################


-- #################################################################### VUE TRONCON RES ###############################################
        
-- View: m_reseau_detection.geo_v_detec_troncon_res

-- DROP VIEW m_reseau_detection.geo_v_detec_troncon_res;

CREATE OR REPLACE VIEW m_reseau_detection.geo_v_detec_troncon_res AS 
 SELECT 
  g.idresdetec,
  a.refope,
  a.insee,
  a.natres,
  g.idtrope,
  g.diametre,
  a.clprecxy,
  a.clprecz, 
  a.date_sai,
  a.date_maj,
  g.geom
  
FROM m_reseau_detection.geo_detec_troncon g
LEFT JOIN m_reseau_detection.an_detec_reseau a ON g.idresdetec = a.idresdetec
ORDER BY g.idresdetec;

COMMENT ON VIEW m_reseau_detection.geo_v_detec_troncon_res
  IS 'Troncon de réseau detecté';
COMMENT ON COLUMN m_reseau_detection.geo_v_detec_troncon_res.idresdetec IS 'Identifiant unique de l''élément de réseau détecté dans la base de données';
COMMENT ON COLUMN m_reseau_detection.geo_v_detec_troncon_res.refope IS 'Référence de l''opération de détection';
COMMENT ON COLUMN m_reseau_detection.geo_v_detec_troncon_res.insee IS 'Code INSEE de la commmune';
COMMENT ON COLUMN m_reseau_detection.geo_v_detec_troncon_res.natres IS 'Nature du réseau détecté';
COMMENT ON COLUMN m_reseau_detection.geo_v_detec_troncon_res.idtrope IS 'Identifiant du troncon de réseau détecté dans l''opération de détection';
COMMENT ON COLUMN m_reseau_detection.geo_v_detec_troncon_res.diametre IS 'Diamètre nominal de la canalisation (en millimètres)';
COMMENT ON COLUMN m_reseau_detection.geo_v_detec_troncon_res.clprecxy IS 'Classe de précision planimétrique (XY)';
COMMENT ON COLUMN m_reseau_detection.geo_v_detec_troncon_res.clprecz IS 'Classe de précision altimétrique (Z)';
COMMENT ON COLUMN m_reseau_detection.geo_v_detec_troncon_res.date_sai IS 'Horodatage de l''intégration en base de l''objet';
COMMENT ON COLUMN m_reseau_detection.geo_v_detec_troncon_res.date_maj IS 'Horodatage de la mise à jour en base de l''objet';
COMMENT ON COLUMN m_reseau_detection.geo_v_detec_troncon_res.geom IS 'Géométrie de l''objet';  

-- #################################################################### VUE NOEUD RES ###############################################
        
-- View: m_reseau_detection.geo_v_detec_noeud_res

-- DROP VIEW m_reseau_detection.geo_v_detec_noeud_res;

CREATE OR REPLACE VIEW m_reseau_detection.geo_v_detec_noeud_res AS 
 SELECT 
  g.idresdetec,
  a.refope,
  a.insee,
  a.natres,
  g.idndope,
  g.typenoeud,
  a.clprecxy,
  a.clprecz, 
  a.date_sai,
  a.date_maj,
  g.geom
  
FROM m_reseau_detection.geo_detec_noeud g
LEFT JOIN m_reseau_detection.an_detec_reseau a ON g.idresdetec = a.idresdetec
ORDER BY g.idresdetec;

COMMENT ON VIEW m_reseau_detection.geo_v_detec_noeud_res
  IS 'Noeud de réseau detecté'; 
COMMENT ON COLUMN m_reseau_detection.geo_v_detec_noeud_res.idresdetec IS 'Identifiant unique de l''élément de réseau détecté dans la base de données';
COMMENT ON COLUMN m_reseau_detection.geo_v_detec_noeud_res.refope IS 'Référence de l''opération de détection';
COMMENT ON COLUMN m_reseau_detection.geo_v_detec_noeud_res.insee IS 'Code INSEE de la commmune';
COMMENT ON COLUMN m_reseau_detection.geo_v_detec_noeud_res.natres IS 'Nature du réseau détecté';
COMMENT ON COLUMN m_reseau_detection.geo_v_detec_noeud_res.idndope IS 'Identifiant du noeud de réseau détecté dans l''opération de détection';
COMMENT ON COLUMN m_reseau_detection.geo_v_detec_noeud_res.typenoeud IS '';
COMMENT ON COLUMN m_reseau_detection.geo_v_detec_noeud_res.clprecxy IS 'Classe de précision planimétrique (XY)';
COMMENT ON COLUMN m_reseau_detection.geo_v_detec_noeud_res.clprecz IS 'Classe de précision altimétrique (Z)';
COMMENT ON COLUMN m_reseau_detection.geo_v_detec_noeud_res.date_sai IS 'Horodatage de l''intégration en base de l''objet';
COMMENT ON COLUMN m_reseau_detection.geo_v_detec_noeud_res.date_maj IS 'Horodatage de la mise à jour en base de l''objet';
COMMENT ON COLUMN m_reseau_detection.geo_v_detec_noeud_res.geom IS 'Géométrie de l''objet';  
  

 
  
-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                      TRIGGER                                                                 ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################



-- #################################################################### FONCTION TRIGGER - GEO_V_TRONCON_RES ###################################################

-- Function: m_reseau_detection.ft_m_geo_v_detec_troncon_res()

-- DROP FUNCTION m_reseau_detection.ft_m_geo_v_detec_troncon_res();

CREATE OR REPLACE FUNCTION m_reseau_detection.ft_m_geo_v_detec_troncon_res()
  RETURNS trigger AS
$BODY$

--déclaration variable pour stocker la séquence des id raepa
DECLARE v_idresdetec character varying(254);

BEGIN

-- INSERT
IF (TG_OP = 'INSERT') THEN

v_idresdetec := nextval('m_reseau_detection.an_detec_reseau_id_seq'::regclass);

-- an_detec_reseau
INSERT INTO m_reseau_detection.an_detec_reseau (idresdetec, refope, insee, natres, clprecxy, clprecz, date_sai, date_maj)
SELECT v_idresdetec,
NEW.refope,
CASE WHEN NEW.insee IS NULL THEN (SELECT insee FROM r_osm.geo_vm_osm_commune_apc WHERE st_intersects(NEW.geom,geom)) ELSE NEW.insee END,
CASE WHEN NEW.natres IS NULL THEN '00' ELSE NEW.natres END,
CASE WHEN NEW.clprecxy IS NULL THEN 'C' ELSE NEW.clprecxy END,
CASE WHEN NEW.clprecz IS NULL THEN 'C' ELSE NEW.clprecz END,
now(),
NULL;

-- geo_detec_troncon
INSERT INTO m_reseau_detection.geo_detec_troncon (idresdetec, idtrope, diametre, geom)
SELECT v_idresdetec,
NEW.idtrope,
NEW.diametre,
CASE WHEN (SELECT geom FROM m_reseau_detection.geo_detec_operation WHERE st_within(NEW.geom,geom)) IS NULL THEN NULL ELSE NEW.geom END;

RETURN NEW;


-- UPDATE
ELSIF (TG_OP = 'UPDATE') THEN

-- an_detec_reseau
UPDATE
m_reseau_detection.an_detec_reseau
SET
idresdetec=OLD.idresdetec,
refope=NEW.refope,
insee=CASE WHEN NEW.insee IS NULL THEN (SELECT insee FROM r_osm.geo_vm_osm_commune_apc WHERE st_intersects(NEW.geom,geom)) ELSE NEW.insee END,
natres=CASE WHEN NEW.natres IS NULL THEN '00' ELSE NEW.natres END,
clprecxy=CASE WHEN NEW.clprecxy IS NULL THEN 'C' ELSE NEW.clprecxy END,
clprecz=CASE WHEN NEW.clprecz IS NULL THEN 'C' ELSE NEW.clprecz END,
date_sai=OLD.date_sai,
date_maj=now()
WHERE m_reseau_detection.an_detec_reseau.idresdetec = OLD.idresdetec;

-- geo_detec_troncon
UPDATE
m_reseau_detection.geo_detec_troncon
SET
idresdetec=OLD.idresdetec,
idtrope=NEW.idtrope,
diametre=NEW.diametre,
geom=CASE WHEN (SELECT geom FROM m_reseau_detection.geo_detec_operation WHERE st_within(NEW.geom,geom)) IS NULL THEN NULL ELSE NEW.geom END
WHERE m_reseau_detection.geo_detec_troncon.idresdetec = OLD.idresdetec;

RETURN NEW;


-- DELETE
ELSIF (TG_OP = 'DELETE') THEN

-- geo_detec_troncon
DELETE FROM m_reseau_detection.geo_detec_troncon
WHERE m_reseau_detection.geo_detec_troncon.idresdetec = OLD.idresdetec;

-- an_detec_reseau
DELETE FROM m_reseau_detection.an_detec_reseau
WHERE m_reseau_detection.an_detec_reseau.idresdetec = OLD.idresdetec;


RETURN NEW;
           
END IF;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

COMMENT ON FUNCTION m_reseau_detection.ft_m_geo_v_detec_troncon_res() IS 'Fonction trigger pour mise à jour des entités depuis la vue de gestion des tronçons de réseau détectés';


-- Trigger: t_t1_geo_v_detec_troncon_res on m_reseau_detection.detec_troncon_res

-- DROP TRIGGER t_t1_detec_troncon_res ON m_reseau_detection.detec_troncon_res;

CREATE TRIGGER t_t1_geo_v_detec_troncon_res
  INSTEAD OF INSERT OR UPDATE OR DELETE
  ON m_reseau_detection.geo_v_detec_troncon_res
  FOR EACH ROW
  EXECUTE PROCEDURE m_reseau_detection.ft_m_geo_v_detec_troncon_res();
  
  

-- #################################################################### FONCTION TRIGGER - GEO_V_NOEUD_RES ###################################################

-- Function: m_reseau_detection.ft_m_geo_v_detec_noeud_res()

-- DROP FUNCTION m_reseau_detection.ft_m_geo_v_detec_noeud_res();

CREATE OR REPLACE FUNCTION m_reseau_detection.ft_m_geo_v_detec_noeud_res()
  RETURNS trigger AS
$BODY$

--déclaration variable pour stocker la séquence des id raepa
DECLARE v_idresdetec character varying(254);

BEGIN

-- INSERT
IF (TG_OP = 'INSERT') THEN

v_idresdetec := nextval('m_reseau_detection.an_detec_reseau_id_seq'::regclass);

-- an_detec_reseau
INSERT INTO m_reseau_detection.an_detec_reseau (idresdetec, refope, insee, natres, clprecxy, clprecz, date_sai, date_maj)
SELECT v_idresdetec,
NEW.refope,
CASE WHEN NEW.insee IS NULL THEN (SELECT insee FROM r_osm.geo_vm_osm_commune_apc WHERE st_intersects(NEW.geom,geom)) ELSE NEW.insee END,
CASE WHEN NEW.natres IS NULL THEN '00' ELSE NEW.natres END,
CASE WHEN NEW.clprecxy IS NULL THEN 'C' ELSE NEW.clprecxy END,
CASE WHEN NEW.clprecz IS NULL THEN 'C' ELSE NEW.clprecz END,
now(),
NULL;

-- geo_detec_noeud
INSERT INTO m_reseau_detection.geo_detec_noeud (idresdetec, idndope, typenoeud, geom)
SELECT v_idresdetec,
NEW.idndope,
NEW.typenoeud,
CASE WHEN (SELECT geom FROM m_reseau_detection.geo_detec_operation WHERE st_within(NEW.geom,geom)) IS NULL THEN NULL ELSE NEW.geom END;

RETURN NEW;


-- UPDATE
ELSIF (TG_OP = 'UPDATE') THEN

-- an_detec_reseau
UPDATE
m_reseau_detection.an_detec_reseau
SET
idresdetec=OLD.idresdetec,
refope=NEW.refope,
insee=CASE WHEN NEW.insee IS NULL THEN (SELECT insee FROM r_osm.geo_vm_osm_commune_apc WHERE st_intersects(NEW.geom,geom)) ELSE NEW.insee END,
natres=CASE WHEN NEW.natres IS NULL THEN '00' ELSE NEW.natres END,
clprecxy=CASE WHEN NEW.clprecxy IS NULL THEN 'C' ELSE NEW.clprecxy END,
clprecz=CASE WHEN NEW.clprecz IS NULL THEN 'C' ELSE NEW.clprecz END,
date_sai=OLD.date_sai,
date_maj=now()
WHERE m_reseau_detection.an_detec_reseau.idresdetec = OLD.idresdetec;

-- geo_detec_noeud
UPDATE
m_reseau_detection.geo_detec_noeud
SET
idresdetec=OLD.idresdetec,
idndope=NEW.idndope,
typenoeud=NEW.typenoeud,
geom=CASE WHEN (SELECT geom FROM m_reseau_detection.geo_detec_operation WHERE st_within(NEW.geom,geom)) IS NULL THEN NULL ELSE NEW.geom END
WHERE m_reseau_detection.geo_detec_noeud.idresdetec = OLD.idresdetec;

RETURN NEW;


-- DELETE
ELSIF (TG_OP = 'DELETE') THEN

-- geo_detec_noeud
DELETE FROM m_reseau_detection.geo_detec_noeud
WHERE m_reseau_detection.geo_detec_noeud.idresdetec = OLD.idresdetec;

-- an_detec_reseau
DELETE FROM m_reseau_detection.an_detec_reseau
WHERE m_reseau_detection.an_detec_reseau.idresdetec = OLD.idresdetec;


RETURN NEW;
           
END IF;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

COMMENT ON FUNCTION m_reseau_detection.ft_m_geo_v_detec_noeud_res() IS 'Fonction trigger pour mise à jour des entités depuis la vue de gestion des noeuds de réseau détectés';


-- Trigger: t_t1_geo_v_detec_noeud_res on m_reseau_detection.detec_noeud_res

-- DROP TRIGGER t_t1_detec_noeud_res ON m_reseau_detection.detec_noeud_res;

CREATE TRIGGER t_t1_geo_v_detec_noeud_res
  INSTEAD OF INSERT OR UPDATE OR DELETE
  ON m_reseau_detection.geo_v_detec_noeud_res
  FOR EACH ROW
  EXECUTE PROCEDURE m_reseau_detection.ft_m_geo_v_detec_noeud_res();                 
