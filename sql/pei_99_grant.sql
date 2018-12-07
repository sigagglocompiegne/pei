/*PEI V1.0*/
/*Creation des droits sur l'ensemble des objets */
/* pei_99_grant.sql */
/*PostGIS*/

/* Propriétaire : GeoCompiegnois - http://geo.compiegnois.fr/ */
/* Auteur : FLorent Vanhoutte */
/* Participant : Grégory Bodet */



-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                        GRANT                                                                  ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################



-- #################################################################### SCHEMA  ####################################################################

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

-- #################################################################### DOMAINE DE VALEUR  ####################################################################

ALTER TABLE m_defense_incendie.lt_pei_type_pei
  OWNER TO sig_create;
GRANT SELECT ON TABLE m_defense_incendie.lt_pei_type_pei TO read_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_defense_incendie.lt_pei_type_pei TO edit_sig;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_type_pei TO create_sig;

ALTER TABLE m_defense_incendie.lt_pei_diam_pei
  OWNER TO sig_create;
GRANT SELECT ON TABLE m_defense_incendie.lt_pei_diam_pei TO read_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_defense_incendie.lt_pei_diam_pei TO edit_sig;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_diam_pei TO create_sig;

ALTER TABLE m_defense_incendie.lt_pei_source_pei
  OWNER TO sig_create;
GRANT SELECT ON TABLE m_defense_incendie.lt_pei_source_pei TO read_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_defense_incendie.lt_pei_source_pei TO edit_sig;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_source_pei TO create_sig;

ALTER TABLE m_defense_incendie.lt_pei_statut
  OWNER TO sig_create;
GRANT SELECT ON TABLE m_defense_incendie.lt_pei_statut TO read_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_defense_incendie.lt_pei_statut TO edit_sig;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_statut TO create_sig;

ALTER TABLE m_defense_incendie.lt_pei_gestion
  OWNER TO sig_create;
GRANT SELECT ON TABLE m_defense_incendie.lt_pei_gestion TO read_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_defense_incendie.lt_pei_gestion TO edit_sig;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_gestion TO create_sig;

ALTER TABLE m_defense_incendie.lt_pei_etat_pei
  OWNER TO sig_create;
GRANT SELECT ON TABLE m_defense_incendie.lt_pei_etat_pei TO read_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_defense_incendie.lt_pei_etat_pei TO edit_sig;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_etat_pei TO create_sig;

ALTER TABLE m_defense_incendie.lt_pei_cs_sdis
  OWNER TO sig_create;
GRANT SELECT ON TABLE m_defense_incendie.lt_pei_cs_sdis TO read_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_defense_incendie.lt_pei_cs_sdis TO edit_sig;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_cs_sdis TO create_sig;

ALTER TABLE m_defense_incendie.lt_pei_etat_boolean
  OWNER TO sig_create;
GRANT SELECT ON TABLE m_defense_incendie.lt_pei_etat_boolean TO read_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_defense_incendie.lt_pei_etat_boolean TO edit_sig;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_etat_boolean TO create_sig;

ALTER TABLE m_defense_incendie.lt_pei_anomalie
  OWNER TO sig_create;
GRANT SELECT ON TABLE m_defense_incendie.lt_pei_anomalie TO read_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_defense_incendie.lt_pei_anomalie TO edit_sig;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_anomalie TO create_sig;

ALTER TABLE m_defense_incendie.lt_pei_id_contrat
  OWNER TO sig_create;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_id_contrat TO sig_create;
GRANT SELECT ON TABLE m_defense_incendie.lt_pei_id_contrat TO read_sig;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE m_defense_incendie.lt_pei_id_contrat TO edit_sig;

ALTER TABLE m_defense_incendie.lt_pei_marque
  OWNER TO sig_create;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_marque TO sig_create;
GRANT SELECT ON TABLE m_defense_incendie.lt_pei_marque TO read_sig;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE m_defense_incendie.lt_pei_marque TO edit_sig;

ALTER TABLE m_defense_incendie.lt_pei_delegat
  OWNER TO sig_create;
GRANT SELECT ON TABLE m_defense_incendie.lt_pei_delegat TO read_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_defense_incendie.lt_pei_delegat TO edit_sig;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_delegat TO create_sig;

ALTER TABLE m_defense_incendie.lt_pei_raccord
  OWNER TO sig_create;
GRANT SELECT ON TABLE m_defense_incendie.lt_pei_raccord TO read_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_defense_incendie.lt_pei_raccord TO edit_sig;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_raccord TO create_sig;




-- #################################################################### SEQUENCE  ####################################################################

ALTER TABLE m_defense_incendie.lt_pei_id_contrat_seq
  OWNER TO sig_create;
GRANT ALL ON SEQUENCE m_defense_incendie.lt_pei_id_contrat_seq TO sig_create;
GRANT SELECT, USAGE ON SEQUENCE m_defense_incendie.lt_pei_id_contrat_seq TO public;

ALTER TABLE m_defense_incendie.lt_pei_marque_seq
  OWNER TO sig_create;
GRANT ALL ON SEQUENCE m_defense_incendie.lt_pei_marque_seq TO sig_create;
GRANT SELECT, USAGE ON SEQUENCE m_defense_incendie.lt_pei_marque_seq TO public;

ALTER TABLE m_defense_incendie.lt_pei_delegat_seq
  OWNER TO sig_create;
GRANT ALL ON SEQUENCE m_defense_incendie.lt_pei_delegat_seq TO sig_create;
GRANT SELECT, USAGE ON SEQUENCE m_defense_incendie.lt_pei_delegat_seq TO public;

ALTER TABLE m_defense_incendie.lt_pei_raccord_seq
  OWNER TO sig_create;
GRANT ALL ON SEQUENCE m_defense_incendie.lt_pei_raccord_seq TO sig_create;
GRANT SELECT, USAGE ON SEQUENCE m_defense_incendie.lt_pei_raccord_seq TO public;

ALTER TABLE m_defense_incendie.geo_pei_id_seq
  OWNER TO sig_create;
GRANT ALL ON SEQUENCE m_defense_incendie.geo_pei_id_seq TO sig_create;
GRANT SELECT, USAGE ON SEQUENCE m_defense_incendie.geo_pei_id_seq TO public;

ALTER TABLE m_defense_incendie.log_pei_id_seq
  OWNER TO sig_create;
GRANT ALL ON SEQUENCE m_defense_incendie.log_pei_id_seq TO sig_create;
GRANT SELECT, USAGE ON SEQUENCE m_defense_incendie.log_pei_id_seq TO public;


-- #################################################################### TABLE  ####################################################################

ALTER TABLE m_defense_incendie.geo_pei
  OWNER TO sig_create;
GRANT SELECT ON TABLE m_defense_incendie.geo_pei TO read_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_defense_incendie.geo_pei TO edit_sig;
GRANT ALL ON TABLE m_defense_incendie.geo_pei TO create_sig;


ALTER TABLE m_defense_incendie.an_pei_ctr
  OWNER TO sig_create;
GRANT SELECT ON TABLE m_defense_incendie.an_pei_ctr TO read_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_defense_incendie.an_pei_ctr TO edit_sig;
GRANT ALL ON TABLE m_defense_incendie.an_pei_ctr TO create_sig;

ALTER TABLE m_defense_incendie.log_pei
  OWNER TO sig_create;
GRANT SELECT ON TABLE m_defense_incendie.log_pei TO read_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_defense_incendie.log_pei TO edit_sig;
GRANT ALL ON TABLE m_defense_incendie.log_pei TO create_sig;


ALTER TABLE x_apps.xapps_geo_v_pei_ctr_erreur
  OWNER TO sig_create;
GRANT ALL ON TABLE x_apps.xapps_geo_v_pei_ctr_erreur TO sig_create;
GRANT ALL ON TABLE x_apps.xapps_geo_v_pei_ctr_erreur TO create_sig;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE x_apps.xapps_geo_v_pei_ctr_erreur TO edit_sig;
GRANT SELECT ON TABLE x_apps.xapps_geo_v_pei_ctr_erreur TO read_sig;


-- #################################################################### VUE DE GESTION  ####################################################################


ALTER TABLE m_defense_incendie.geo_v_pei_ctr
  OWNER TO sig_create;
GRANT ALL ON TABLE m_defense_incendie.geo_v_pei_ctr TO sig_create;
GRANT ALL ON TABLE m_defense_incendie.geo_v_pei_ctr TO create_sig;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE m_defense_incendie.geo_v_pei_ctr TO edit_sig;
GRANT SELECT ON TABLE m_defense_incendie.geo_v_pei_ctr TO read_sig;


ALTER TABLE m_defense_incendie.geo_v_pei_zonedefense
  OWNER TO sig_create;
GRANT SELECT ON TABLE m_defense_incendie.geo_v_pei_zonedefense TO read_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_defense_incendie.geo_v_pei_zonedefense TO edit_sig;
GRANT ALL ON TABLE m_defense_incendie.geo_v_pei_zonedefense TO create_sig;


-- #################################################################### VUE APPLICATIVE  ####################################################################

ALTER TABLE x_apps.xapps_geo_v_pei_ctr
  OWNER TO sig_create;
GRANT ALL ON TABLE x_apps.xapps_geo_v_pei_ctr TO sig_create;
GRANT ALL ON TABLE x_apps.xapps_geo_v_pei_ctr TO create_sig;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE x_apps.xapps_geo_v_pei_ctr TO edit_sig;
GRANT SELECT ON TABLE x_apps.xapps_geo_v_pei_ctr TO read_sig;

ALTER TABLE x_apps.xapps_geo_v_pei_zonedefense
  OWNER TO sig_create;
GRANT SELECT ON TABLE x_apps.xapps_geo_v_pei_zonedefense TO read_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE x_apps.xapps_geo_v_pei_zonedefense TO edit_sig;
GRANT ALL ON TABLE x_apps.xapps_geo_v_pei_zonedefense TO create_sig;

-- #################################################################### VUE OPENDATA  ####################################################################


ALTER TABLE x_opendata.xopendata_geo_v_open_pei
  OWNER TO sig_create;
GRANT SELECT ON TABLE x_opendata.xopendata_geo_v_open_pei TO read_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE x_opendata.xopendata_geo_v_open_pei TO edit_sig;
GRANT ALL ON TABLE x_opendata.xopendata_geo_v_open_pei TO create_sig;

-- #################################################################### FUNCTION TRIGGER  ####################################################################


ALTER FUNCTION m_defense_incendie.ft_geo_v_pei_ctr()
  OWNER TO sig_create;
GRANT EXECUTE ON FUNCTION m_defense_incendie.ft_geo_v_pei_ctr() TO public;
GRANT EXECUTE ON FUNCTION m_defense_incendie.ft_geo_v_pei_ctr() TO sig_create;
GRANT EXECUTE ON FUNCTION m_defense_incendie.ft_geo_v_pei_ctr() TO create_sig;

ALTER FUNCTION x_apps.ft_xapps_geo_v_pei_ctr()
  OWNER TO sig_create;
GRANT EXECUTE ON FUNCTION x_apps.ft_xapps_geo_v_pei_ctr() TO public;
GRANT EXECUTE ON FUNCTION x_apps.ft_xapps_geo_v_pei_ctr() TO sig_create;
GRANT EXECUTE ON FUNCTION x_apps.ft_xapps_geo_v_pei_ctr() TO create_sig;
		
ALTER FUNCTION m_defense_incendie.ft_log_pei()
  OWNER TO sig_create;
GRANT EXECUTE ON FUNCTION m_defense_incendie.ft_log_pei() TO public;
GRANT EXECUTE ON FUNCTION m_defense_incendie.ft_log_pei() TO sig_create;
GRANT EXECUTE ON FUNCTION m_defense_incendie.ft_log_pei() TO create_sig;

