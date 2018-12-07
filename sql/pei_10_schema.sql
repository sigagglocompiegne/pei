/*PEI V1.0*/
/*Creation du schéma qui va accueillir la structure des données */
/* pei_10_schema.sql */
/*PostGIS*/

/* Propriétaire : GeoCompiegnois - http://geo.compiegnois.fr/ */
/* Auteur : FLorent Vanhoutte */
/* Participant : Grégory Bodet */

-- #################################################################### SCHEMA  ####################################################################

-- Schema: m_defense_incendie

-- DROP SCHEMA m_defense_incendie;

CREATE SCHEMA m_defense_incendie
  AUTHORIZATION sig_create;

GRANT USAGE ON SCHEMA m_defense_incendie TO edit_sig;
GRANT ALL ON SCHEMA m_defense_incendie TO sig_create;
GRANT ALL ON SCHEMA m_defense_incendie TO create_sig;
GRANT USAGE ON SCHEMA m_defense_incendie TO read_sig;
ALTER DEFAULT PRIVILEGES IN SCHEMA m_defense_incendie
GRANT ALL ON TABLES TO create_sig;
ALTER DEFAULT PRIVILEGES IN SCHEMA m_defense_incendie
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLES TO edit_sig;
ALTER DEFAULT PRIVILEGES IN SCHEMA m_defense_incendie
GRANT SELECT ON TABLES TO read_sig;

COMMENT ON SCHEMA m_defense_incendie
  IS 'Données géographiques métiers sur le thème de la défense incendie';


*/
