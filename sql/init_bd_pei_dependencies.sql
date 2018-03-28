/*
  
  objet : Script d'initialisation des dépendances au script init_bd_pei.sql
  
  Historique des versions :
  date        |  auteur              |  description
  28/03/2018  |  Florent VANHOUTTE   |  version initiale
  
  Attention, hormis pour le domaine de valeur du référentiel géographique source, ce script ne contient 
  que le modèle des données nécessaire à l'exécution du script d'initialisation de la base métier init_bd_pei.sql
  
*/

-- Schema: r_objet

-- DROP SCHEMA r_objet;

CREATE SCHEMA r_objet
  AUTHORIZATION postgres;

GRANT ALL ON SCHEMA r_objet TO postgres;
COMMENT ON SCHEMA r_objet
  IS 'Schéma contenant les objets géographiques virtuels métiers (zonages, lots, entités administratives, ...). Les données métiers (alphanumériques) sont stockées dans le schéma correspondant, et le lien s''effectue via la référence géographique. Une donnée géographique spécifique à un seul métier, reste dans le schéma du métier.';

-- ################################################################# Domaine valeur - source du référentiel geom  ###############################################

-- Table: r_objet.lt_src_geom

-- DROP TABLE r_objet.lt_src_geom;

CREATE TABLE r_objet.lt_src_geom
(
  code character varying(2) NOT NULL, -- Code de la liste énumérée relative au type de référentiel géométrique
  valeur character varying(254) NOT NULL, -- Valeur de la liste énumérée relative au type de référentiel géométrique
  CONSTRAINT lt_src_geom_pkey PRIMARY KEY (code)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE r_objet.lt_src_geom
  OWNER TO postgres;
GRANT ALL ON TABLE r_objet.lt_src_geom TO postgres;
COMMENT ON TABLE r_objet.lt_src_geom
  IS 'Code permettant de décrire le type de référentiel géométrique';
COMMENT ON COLUMN r_objet.lt_src_geom.code IS 'Code de la liste énumérée relative au type de référentiel géométrique';
COMMENT ON COLUMN r_objet.lt_src_geom.valeur IS 'Valeur de la liste énumérée relative au type de référentiel géométrique';

INSERT INTO r_objet.lt_src_geom(
            code, valeur)
    VALUES
    ('10', 'Cadastre'),
    ('11', 'PCI vecteur'),
    ('12', 'BD Parcellaire'),
    ('13', 'RPCU'),
    ('20', 'Ortho-images'),
    ('21', 'Orthophotoplan IGN'),
    ('22', 'Orthophotoplan partenaire'),
    ('23', 'Orthophotoplan local'),
    ('30', 'Filaire voirie'),
    ('31', 'Route BDTopo'),
    ('32', 'Route OSM'),
    ('40', 'Cartes'),
    ('41', 'Scan25'),
    ('50', 'Lever'),
    ('51', 'Plan topographique'),
    ('52', 'PCRS'),
    ('53', 'Trace GPS'),
    ('60', 'Geocodage'),
    ('61', 'Base Adresse Locale'),
    ('70', 'Plan masse'),
    ('71', 'Plan masse vectoriel'),
    ('72', 'Plan masse redessiné'),
    ('80', 'Thématique'),
    ('81', 'Document d''urbanisme'),
    ('82', 'Occupation du Sol'),
    ('83', 'Thèmes BDTopo'),
    ('99', 'Autre'),
    ('00', 'Non renseigné');

-- ################################################################# Administratif  ###############################################

-- Schema: r_administratif

-- DROP SCHEMA r_administratif;

CREATE SCHEMA r_administratif
  AUTHORIZATION postgres;

GRANT ALL ON SCHEMA r_administratif TO postgres;
COMMENT ON SCHEMA r_administratif
  IS 'Référentiels géographiques administratifs (en attente de voir comment ce schéma doit évoluer ==> à supprimer par rapport aux schémas contenant les référentiels administratifs)';




-- Table: r_administratif.an_geo

-- DROP TABLE r_administratif.an_geo;

CREATE TABLE r_administratif.an_geo
(
  insee character varying(5) NOT NULL, -- Code géographique de la commune (code insee)
  libgeo character varying(255), -- Libellé géographique de la commune
  dep smallint, -- Code géographique du département
  reg smallint, -- Code géographique de la région jusqu'au 31 décembre 2015
  reg2016 smallint, -- Code géographique de la région 2016
  epci character varying(9), -- Code géographique de l'établissement public à fiscalité propre  (EPCI)
  nature_epci character varying(2), -- Nature d'établissement public
  arr character varying(4), -- Code géographique de l'arrondissement
  cv character varying(5), -- Code géographique du canton ville
  ze2010 smallint, -- Code géographique de la zone d'emploi 2010
  uu2010 character varying(5), -- Code géographique de l'unité urbaine 2010
  tuu2010 smallint, -- Tranche d'unité urbaine 2010
  tduu2010 smallint, -- Tranche détaillée d'unité urbaine 2010
  au2010 character varying(3), -- Code géographique de l'aire urbaine 2010
  tau2010 smallint, -- Tranche d'aire urbaine 2010
  cataeu2010 smallint, -- Catégorie de la commune dans le zonage en aires urbaines 2010
  bv2012 character varying(5), -- Code géographique du bassin de vie 2012
  lib_epci character varying(255), -- Libellé des EPCI
  nomreg2016 character varying(100), -- Nom des régions au 1er janvier 2016
  dept character varying(2), -- Code du département
  CONSTRAINT an_geo_pkey PRIMARY KEY (insee)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE r_administratif.an_geo
  OWNER TO postgres;
GRANT ALL ON TABLE r_administratif.an_geo TO postgres;
COMMENT ON TABLE r_administratif.an_geo
  IS 'Table attributaire contenant les codes adminsitratifs de découpage des différents périmètres officiels de l''Insee (commune, EPCI, zone d''emploi, ...)';
COMMENT ON COLUMN r_administratif.an_geo.insee IS 'Code géographique de la commune (code insee)';
COMMENT ON COLUMN r_administratif.an_geo.libgeo IS 'Libellé géographique de la commune';
COMMENT ON COLUMN r_administratif.an_geo.dep IS 'Code géographique du département';
COMMENT ON COLUMN r_administratif.an_geo.reg IS 'Code géographique de la région jusqu''au 31 décembre 2015';
COMMENT ON COLUMN r_administratif.an_geo.reg2016 IS 'Code géographique de la région 2016';
COMMENT ON COLUMN r_administratif.an_geo.epci IS 'Code géographique de l''établissement public à fiscalité propre  (EPCI)';
COMMENT ON COLUMN r_administratif.an_geo.nature_epci IS 'Nature d''établissement public';
COMMENT ON COLUMN r_administratif.an_geo.arr IS 'Code géographique de l''arrondissement';
COMMENT ON COLUMN r_administratif.an_geo.cv IS 'Code géographique du canton ville';
COMMENT ON COLUMN r_administratif.an_geo.ze2010 IS 'Code géographique de la zone d''emploi 2010';
COMMENT ON COLUMN r_administratif.an_geo.uu2010 IS 'Code géographique de l''unité urbaine 2010';
COMMENT ON COLUMN r_administratif.an_geo.tuu2010 IS 'Tranche d''unité urbaine 2010';
COMMENT ON COLUMN r_administratif.an_geo.tduu2010 IS 'Tranche détaillée d''unité urbaine 2010';
COMMENT ON COLUMN r_administratif.an_geo.au2010 IS 'Code géographique de l''aire urbaine 2010';
COMMENT ON COLUMN r_administratif.an_geo.tau2010 IS 'Tranche d''aire urbaine 2010';
COMMENT ON COLUMN r_administratif.an_geo.cataeu2010 IS 'Catégorie de la commune dans le zonage en aires urbaines 2010';
COMMENT ON COLUMN r_administratif.an_geo.bv2012 IS 'Code géographique du bassin de vie 2012';
COMMENT ON COLUMN r_administratif.an_geo.lib_epci IS 'Libellé des EPCI';
COMMENT ON COLUMN r_administratif.an_geo.nomreg2016 IS 'Nom des régions au 1er janvier 2016';
COMMENT ON COLUMN r_administratif.an_geo.dept IS 'Code du département';



-- ################################################################# OSM  ###############################################

-- Schema: r_osm

-- DROP SCHEMA r_osm;

CREATE SCHEMA r_osm
  AUTHORIZATION postgres;

GRANT ALL ON SCHEMA r_osm TO postgres;
COMMENT ON SCHEMA r_osm
  IS 'Référentiel Géographique Open Street Map';

-- Table: r_osm.geo_osm_commune

-- DROP TABLE r_osm.geo_osm_commune;

CREATE TABLE r_osm.geo_osm_commune
(
  commune_m character varying(255), -- Libellé des communes (en majuscule)
  insee character varying(5) NOT NULL, -- Code Insee de la commune
  gid serial NOT NULL, -- Identifiant incrémenté de 1 à n
  geom geometry(MultiPolygon,2154), -- Champ contenant la géométrie des communes (polygone)
  geom1 geometry(Point,2154), -- Champ contenant le centroïd des communes (point forcé dans le polygone)
  commune character varying(80), -- Libellé des communes en minusucle (avec la 1ere lettre en Majuscule)
  CONSTRAINT geo_osm_commune_pkey PRIMARY KEY (insee)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE r_osm.geo_osm_commune
  OWNER TO postgres;
GRANT ALL ON TABLE r_osm.geo_osm_commune TO groupe_sig WITH GRANT OPTION;
GRANT ALL ON TABLE r_osm.geo_osm_commune TO postgres;
GRANT SELECT ON TABLE r_osm.geo_osm_commune TO groupe_apc;
GRANT SELECT ON TABLE r_osm.geo_osm_commune TO groupe_sig_stage WITH GRANT OPTION;
GRANT SELECT ON TABLE r_osm.geo_osm_commune TO groupe_eco;
GRANT SELECT ON TABLE r_osm.geo_osm_commune TO groupe_be;
COMMENT ON TABLE r_osm.geo_osm_commune
  IS 'Limites des communes de la Région Picardie , Haute-Normandie et Ile-de-France issues d''Open Street Map';
COMMENT ON COLUMN r_osm.geo_osm_commune.commune_m IS 'Libellé des communes (en majuscule)';
COMMENT ON COLUMN r_osm.geo_osm_commune.insee IS 'Code Insee de la commune';
COMMENT ON COLUMN r_osm.geo_osm_commune.gid IS 'Identifiant incrémenté de 1 à n';
COMMENT ON COLUMN r_osm.geo_osm_commune.geom IS 'Champ contenant la géométrie des communes (polygone)';
COMMENT ON COLUMN r_osm.geo_osm_commune.geom1 IS 'Champ contenant le centroïd des communes (point forcé dans le polygone)';
COMMENT ON COLUMN r_osm.geo_osm_commune.commune IS 'Libellé des communes en minusucle (avec la 1ere lettre en Majuscule)';


-- Index: r_osm.geo_osm_commune_geom_idx

-- DROP INDEX r_osm.geo_osm_commune_geom_idx;

CREATE INDEX geo_osm_commune_geom_idx
  ON r_osm.geo_osm_commune
  USING gist
  (geom);

-- Index: r_osm.geo_osm_commune_insee_idx

-- DROP INDEX r_osm.geo_osm_commune_insee_idx;

CREATE INDEX geo_osm_commune_insee_idx
  ON r_osm.geo_osm_commune
  USING btree
  (insee COLLATE pg_catalog."default");

-- Table: r_osm.geo_osm_epci

-- DROP TABLE r_osm.geo_osm_epci;

CREATE TABLE r_osm.geo_osm_epci
(
  cepci character varying(9) NOT NULL,
  lib_epci character varying(255),
  geom geometry(MultiPolygon,2154),
  CONSTRAINT geo_osm_epci_pkey PRIMARY KEY (cepci)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE r_osm.geo_osm_epci
  OWNER TO postgres;
GRANT ALL ON TABLE r_osm.geo_osm_epci TO postgres;
GRANT ALL ON TABLE r_osm.geo_osm_epci TO groupe_sig WITH GRANT OPTION;
GRANT SELECT ON TABLE r_osm.geo_osm_epci TO groupe_sig_stage WITH GRANT OPTION;
COMMENT ON TABLE r_osm.geo_osm_epci
  IS 'Table des EPCI de l''Oise au 1er janvier 2018 issu de la vue matérialisée geo_vm_osm_epci';

-- Index: r_osm.geo_osm_epci_geom_idx

-- DROP INDEX r_osm.geo_osm_epci_geom_idx;

CREATE INDEX geo_osm_epci_geom_idx
  ON r_osm.geo_osm_epci
  USING gist
  (geom);




