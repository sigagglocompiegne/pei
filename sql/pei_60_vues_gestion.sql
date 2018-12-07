/*PEI V1.0*/
/*Creation des vues de gestion stockées dans le schéma contenant les tables */
/* pei_60_vues_gestion.sql */
/*PostGIS*/

/* Propriétaire : GeoCompiegnois - http://geo.compiegnois.fr/ */
/* Auteur : FLorent Vanhoutte */
/* Participant : Grégory Bodet */

DROP VIEW IF EXISTS m_defense_incendie.geo_v_pei_ctr;
DROP VIEW IF EXISTS m_defense_incendie.geo_v_pei_zonedefense;

-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                              VUES DE GESTION                                                                 ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################


-- View: m_defense_incendie.geo_v_pei_ctr

-- DROP VIEW m_defense_incendie.geo_v_pei_ctr;

CREATE OR REPLACE VIEW m_defense_incendie.geo_v_pei_ctr AS 
 SELECT g.id_pei,
    g.id_sdis,
    g.verrou,
    g.ref_terr,
    lk.lib_epci AS epci,
    g.insee,
    lk.libgeo as commune,
    g.type_pei,
    g.type_rd,
    g.diam_pei,
    g.raccord,
    g.marque,
    g.source_pei,
    g.volume,
    g.diam_cana,
    g.etat_pei,
    a.id_contrat,
    a.press_stat,
    a.press_dyn,
    a.debit,
    a.debit_max,
    g.debit_r_ci,
    a.etat_anom,
    a.lt_anom,
    a.etat_acces,
    a.etat_sign,
    a.etat_conf,
        CASE
            WHEN a.etat_conf::text = 't'::text AND date_part('year'::text, age('now'::text::date::timestamp with time zone, a.date_ct::timestamp with time zone)) < 2::double precision AND g.etat_pei::text = '02'::text THEN 't'::text
            ELSE 'f'::text
        END AS disponible,
    'now'::text::date AS date_dispo,
    a.date_mes,
    a.date_ct,
    a.ope_ct,
    a.date_ro,
    g.statut,
    g.nom_etab,
    g.gestion,
    g.delegat,
    g.cs_sdis,
    g.situation,
    g.observ,
    g.photo_url,
    g.src_pei,
    g.x_l93,
    g.y_l93,
    g.src_geom,
    g.src_date,
    g.prec,
    g.ope_sai,
    g.date_sai,
    g.date_maj,
    g.geom
   FROM m_defense_incendie.geo_pei g
     JOIN m_defense_incendie.an_pei_ctr a ON g.id_pei = a.id_pei
     INNER JOIN r_administratif.an_geo lk ON lk.insee::text = g.insee::text;

ALTER TABLE m_defense_incendie.geo_v_pei_ctr
  OWNER TO sig_create;
GRANT ALL ON TABLE m_defense_incendie.geo_v_pei_ctr TO sig_create;
GRANT ALL ON TABLE m_defense_incendie.geo_v_pei_ctr TO create_sig;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE m_defense_incendie.geo_v_pei_ctr TO edit_sig;
GRANT SELECT ON TABLE m_defense_incendie.geo_v_pei_ctr TO read_sig;
COMMENT ON VIEW m_defense_incendie.geo_v_pei_ctr
  IS 'Vue éditable destinée à la modification des données relatives aux PEI et aux contrôles';



-- View: x_apps.xapps_geo_v_pei_ctr

-- DROP VIEW x_apps.xapps_geo_v_pei_ctr;

CREATE OR REPLACE VIEW x_apps.xapps_geo_v_pei_ctr AS 
 SELECT g.id_pei,
    g.id_sdis,
    g.verrou,
    g.ref_terr,
    lk.lib_epci AS epci,
    g.insee,
    lk.libgeo as commune,
    g.type_pei,
    g.type_rd,
    g.diam_pei,
    g.raccord,
    g.marque,
    g.source_pei,
    g.volume,
    g.diam_cana,
    g.etat_pei,
    a.id_contrat,
    a.press_stat,
    a.press_dyn,
    a.debit,
    a.debit_max,
    g.debit_r_ci,
    a.etat_anom,
    a.lt_anom,
    a.etat_acces,
    a.etat_sign,
    a.etat_conf,
       CASE
            WHEN a.etat_conf::text = 't'::text AND date_part('year'::text, age('now'::text::date::timestamp with time zone, a.date_ct::timestamp with time zone)) < 2::double precision AND g.etat_pei::text = '02'::text THEN 't'::text
            ELSE 'f'::text
        END AS disponible,
    'now'::text::date AS date_dispo,
    a.date_mes,
    a.date_ct,
    a.ope_ct,
    a.date_ro,
    g.statut,
    g.nom_etab,
    g.gestion,
    g.delegat,
    g.cs_sdis,
    g.situation,
    g.observ,
    g.photo_url,
    g.src_pei,
    g.x_l93,
    g.y_l93,
    g.src_geom,
    g.src_date,
    g.prec,
    g.ope_sai,
    g.date_sai,
    g.date_maj,
    g.geom

   FROM m_defense_incendie.geo_pei g
     JOIN m_defense_incendie.an_pei_ctr a ON a.id_pei = g.id_pei
     INNER JOIN r_administratif.an_geo lk ON lk.insee::text = g.insee::text;


ALTER TABLE x_apps.xapps_geo_v_pei_ctr
  OWNER TO sig_create;
GRANT ALL ON TABLE x_apps.xapps_geo_v_pei_ctr TO sig_create;
GRANT ALL ON TABLE x_apps.xapps_geo_v_pei_ctr TO create_sig;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE x_apps.xapps_geo_v_pei_ctr TO edit_sig;
GRANT SELECT ON TABLE x_apps.xapps_geo_v_pei_ctr TO read_sig;
COMMENT ON VIEW x_apps.xapps_geo_v_pei_ctr
  IS 'Vue applicative destinée à la modification des données PEI sur le patrimoine géré par le service mutualisé eau potable et la consultation des autres PEI';



-- View: x_opendata.xopendata_geo_v_open_pei

-- DROP VIEW x_opendata.xopendata_geo_v_open_pei;

CREATE OR REPLACE VIEW x_opendata.xopendata_geo_v_open_pei AS 
 SELECT g.insee,
    g.id_sdis,
    g.id_pei::text AS id_gestion,
	CASE
            WHEN g.gestion = '00' THEN NULL
            ELSE lt_gest.valeur
        END AS nom_gest,
    g.ref_terr,
        CASE
            WHEN g.type_pei::text = 'NR'::text THEN NULL::character varying
            ELSE g.type_pei
        END AS type_pei,
    g.type_rd,
        CASE
            WHEN g.diam_pei = 0 THEN NULL::integer
            ELSE g.diam_pei
        END AS diam_pei,
        CASE
            WHEN g.diam_cana = 0 THEN NULL::integer
            ELSE g.diam_cana
        END AS diam_cana,
    lt_src.code_open AS source_pei,
    lt_stat.code_open AS statut,
    g.nom_etab,
    g.situation,
    a.press_dyn,
    a.press_stat,
    a.debit,
    g.volume,
        CASE
            WHEN a.etat_conf::text = 't'::text AND date_part('year'::text, age('now'::text::date::timestamp with time zone, a.date_ct::timestamp with time zone)) < 2::double precision AND g.etat_pei::text = '02'::text THEN '1'::text
            ELSE '0'::text
        END AS disponible,
    'now'::text::date AS date_dispo,
    a.date_mes,
        CASE
            WHEN g.date_maj IS NULL THEN date(g.date_sai)
            ELSE date(g.date_maj)
        END AS date_maj,
    a.date_ct,
    a.date_ro,
        CASE
            WHEN g.prec::text = '000'::text OR g.prec IS NULL OR g.prec::text = ''::text THEN NULL::text
            WHEN (g.prec::integer / 100) <= 1 THEN '01'::text
            WHEN (g.prec::integer / 100) > 1 AND (g.prec::real / 100::double precision) <= 5::double precision THEN '05'::text
            WHEN (g.prec::integer / 100) > 5 AND (g.prec::real / 100::double precision) <= 10::double precision THEN '10'::text
            WHEN (g.prec::integer / 100) > 10 THEN '99'::text
            ELSE NULL::text
        END AS prec,
    g.x_l93 AS x,
    g.y_l93 AS y,
    st_x(st_transform(g.geom, 4326)) AS long,
    st_y(st_transform(g.geom, 4326)) AS lat,
    g.geom
   FROM m_defense_incendie.geo_pei g
     LEFT JOIN m_defense_incendie.an_pei_ctr a ON a.id_pei = g.id_pei
     LEFT JOIN m_defense_incendie.lt_pei_statut lt_stat ON lt_stat.code::text = g.statut::text
     LEFT JOIN m_defense_incendie.lt_pei_source_pei lt_src ON lt_src.code::text = g.source_pei::text
     LEFT JOIN m_defense_incendie.lt_pei_gestion lt_gest ON lt_gest.code::text = g.gestion::text
  WHERE g.etat_pei::text = '02'::text
  ORDER BY g.insee, g.id_sdis;

ALTER TABLE x_opendata.xopendata_geo_v_open_pei
  OWNER TO sig_create;
GRANT SELECT ON TABLE x_opendata.xopendata_geo_v_open_pei TO read_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE x_opendata.xopendata_geo_v_open_pei TO edit_sig;
GRANT ALL ON TABLE x_opendata.xopendata_geo_v_open_pei TO create_sig;
COMMENT ON VIEW x_opendata.xopendata_geo_v_open_pei
  IS 'Vue des PEI existants destinée aux échanges de données en opendata selon le format PEI AFIGEO';


-- View: m_defense_incendie.geo_v_pei_zonedefense

-- DROP VIEW m_defense_incendie.geo_v_pei_zonedefense;

CREATE OR REPLACE VIEW m_defense_incendie.geo_v_pei_zonedefense AS 
 SELECT 
  g.id_pei,
  g.insee,
  g.geom1

   FROM m_defense_incendie.geo_pei g
   LEFT JOIN m_defense_incendie.an_pei_ctr a ON a.id_pei = g.id_pei
   WHERE g.statut='01' AND a.etat_conf = 't' AND DATE_PART('year',(AGE(CURRENT_DATE,a.date_ct))) < 2 AND g.etat_pei ='02';

ALTER TABLE m_defense_incendie.geo_v_pei_zonedefense
  OWNER TO sig_create;
GRANT SELECT ON TABLE m_defense_incendie.geo_v_pei_zonedefense TO read_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_defense_incendie.geo_v_pei_zonedefense TO edit_sig;
GRANT ALL ON TABLE m_defense_incendie.geo_v_pei_zonedefense TO create_sig;
								       
COMMENT ON VIEW m_defense_incendie.geo_v_pei_zonedefense
  IS 'Vue des zones indicatives de défense incendie publique';


-- View: x_apps.xapps_geo_v_pei_zonedefense

-- DROP VIEW x_apps.xapps_geo_v_pei_zonedefense;

CREATE OR REPLACE VIEW x_apps.xapps_geo_v_pei_zonedefense AS 
 SELECT 
  g.id_pei,
  g.insee,
  g.gestion,
  a.id_contrat,
  g.geom1

   FROM m_defense_incendie.geo_pei g
   LEFT JOIN m_defense_incendie.an_pei_ctr a ON a.id_pei = g.id_pei
   WHERE g.statut='01' AND a.etat_conf = 't' AND DATE_PART('year',(AGE(CURRENT_DATE,a.date_ct))) < 2 AND g.etat_pei ='02';

ALTER TABLE x_apps.xapps_geo_v_pei_zonedefense
  OWNER TO sig_create;
GRANT SELECT ON TABLE x_apps.xapps_geo_v_pei_zonedefense TO read_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE x_apps.xapps_geo_v_pei_zonedefense TO edit_sig;
GRANT ALL ON TABLE x_apps.xapps_geo_v_pei_zonedefense TO create_sig;
								       
COMMENT ON VIEW x_apps.xapps_geo_v_pei_zonedefense
  IS 'Vue applicative des zones indicatives de défense incendie publique';
