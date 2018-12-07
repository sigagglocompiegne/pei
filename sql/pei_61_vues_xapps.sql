/*PEI V1.0*/
/*Creation des vues applicatives stockées dans le schéma x_apps */
/* pei_61_vues_xapps.sql */
/*PostGIS*/

/* Propriétaire : GeoCompiegnois - http://geo.compiegnois.fr/ */
/* Auteur : FLorent Vanhoutte */
/* Participant : Grégory Bodet */

-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                              VUES APPLICATIVES                                                                ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################


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


COMMENT ON VIEW x_apps.xapps_geo_v_pei_ctr
  IS 'Vue applicative destinée à la modification des données PEI sur le patrimoine géré par le service mutualisé eau potable et la consultation des autres PEI';


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

								       
COMMENT ON VIEW x_apps.xapps_geo_v_pei_zonedefense
  IS 'Vue applicative des zones indicatives de défense incendie publique';
