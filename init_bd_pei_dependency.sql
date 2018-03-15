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
