/*PEI V1.0*/
/*Creation des vues applicatives OpenData stockées dans le schéma x_opendata */
/* pei_63_vues_xopendata.sql */
/*PostGIS*/

/* Propriétaire : GeoCompiegnois - http://geo.compiegnois.fr/ */
/* Auteur : FLorent Vanhoutte */
/* Participant : Grégory Bodet */

DROP VIEW IF EXISTS m_defense_incendie.xopendata_geo_v_open_pei;

-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                              VUES OPENDATA                                                                 ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################


-- View: m_defense_incendie.xopendata_geo_v_open_pei

-- DROP VIEW m_defense_incendie.xopendata_geo_v_open_pei;

CREATE OR REPLACE VIEW m_defense_incendie.xopendata_geo_v_open_pei AS 
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

COMMENT ON VIEW x_opendata.xopendata_geo_v_open_pei
  IS 'Vue des PEI existants destinée aux échanges de données en opendata selon le format PEI AFIGEO';

