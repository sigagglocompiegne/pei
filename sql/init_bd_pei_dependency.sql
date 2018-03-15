-- Schema: r_objet

-- DROP SCHEMA r_objet;

CREATE SCHEMA r_objet
  AUTHORIZATION postgres;

GRANT ALL ON SCHEMA r_objet TO postgres;
GRANT ALL ON SCHEMA r_objet TO groupe_sig WITH GRANT OPTION;
GRANT USAGE ON SCHEMA r_objet TO groupe_eco;
GRANT USAGE ON SCHEMA r_objet TO groupe_sig_stage WITH GRANT OPTION;
GRANT USAGE ON SCHEMA r_objet TO groupe_be;
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
GRANT ALL ON TABLE r_objet.lt_src_geom TO groupe_sig WITH GRANT OPTION;
GRANT SELECT ON TABLE r_objet.lt_src_geom TO groupe_eco;
GRANT SELECT ON TABLE r_objet.lt_src_geom TO groupe_be;
GRANT SELECT ON TABLE r_objet.lt_src_geom TO groupe_sig_stage WITH GRANT OPTION;
COMMENT ON TABLE r_objet.lt_src_geom
  IS 'Code permettant de décrire le type de référentiel géométrique';
COMMENT ON COLUMN r_objet.lt_src_geom.code IS 'Code de la liste énumérée relative au type de référentiel géométrique';
COMMENT ON COLUMN r_objet.lt_src_geom.valeur IS 'Valeur de la liste énumérée relative au type de référentiel géométrique';

INSERT INTO lt_src_geom VALUES ('10', 'Cadastre');
INSERT INTO lt_src_geom VALUES ('11', 'PCI vecteur');
INSERT INTO lt_src_geom VALUES ('12', 'BD Parcellaire');
INSERT INTO lt_src_geom VALUES ('13', 'RPCU');
INSERT INTO lt_src_geom VALUES ('20', 'Ortho-images');
INSERT INTO lt_src_geom VALUES ('21', 'Orthophotoplan IGN');
INSERT INTO lt_src_geom VALUES ('22', 'Orthophotoplan partenaire');
INSERT INTO lt_src_geom VALUES ('23', 'Orthophotoplan local');
INSERT INTO lt_src_geom VALUES ('30', 'Filaire voirie');
INSERT INTO lt_src_geom VALUES ('31', 'Route BDTopo');
INSERT INTO lt_src_geom VALUES ('32', 'Route OSM');
INSERT INTO lt_src_geom VALUES ('40', 'Cartes');
INSERT INTO lt_src_geom VALUES ('41', 'Scan25');
INSERT INTO lt_src_geom VALUES ('50', 'Lever');
INSERT INTO lt_src_geom VALUES ('51', 'Plan topographique');
INSERT INTO lt_src_geom VALUES ('52', 'PCRS');
INSERT INTO lt_src_geom VALUES ('53', 'Trace GPS');
INSERT INTO lt_src_geom VALUES ('60', 'Geocodage');
INSERT INTO lt_src_geom VALUES ('71', 'Plan masse vectoriel');
INSERT INTO lt_src_geom VALUES ('72', 'Plan masse redessiné');
INSERT INTO lt_src_geom VALUES ('80', 'Thématique');
INSERT INTO lt_src_geom VALUES ('81', 'Document d''urbanisme');
INSERT INTO lt_src_geom VALUES ('82', 'Occupation du Sol');
INSERT INTO lt_src_geom VALUES ('83', 'Thèmes BDTopo');
INSERT INTO lt_src_geom VALUES ('99', 'Autre');
INSERT INTO lt_src_geom VALUES ('00', 'Non renseigné');
INSERT INTO lt_src_geom VALUES ('70', 'Plan masse');
INSERT INTO lt_src_geom VALUES ('61', 'Base Adresse Locale');
