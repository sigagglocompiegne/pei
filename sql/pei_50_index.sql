/*PEI V1.0*/
/*Creation des indexs */
/* pei_50_index.sql */
/*PostGIS*/

/* Propriétaire : GeoCompiegnois - http://geo.compiegnois.fr/ */
/* Auteur : FLorent Vanhoutte */
/* Participant : Grégory Bodet */


-- #################################################################### Point d'eau incendie ####################################################  
  
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
