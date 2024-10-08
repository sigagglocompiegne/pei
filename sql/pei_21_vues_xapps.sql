/*PEI V1.0*/
/*Creation des vues applicatives stockées dans le schéma x_apps */
/* pei_61_vues_xapps.sql */
/*PostGIS*/

/* Propriétaire : GeoCompiegnois - http://geo.compiegnois.fr/ */
/* Auteur : FLorent Vanhoutte */
/* Participant : Grégory Bodet */


DROP VIEW IF EXISTS m_defense_incendie.xapps_geo_v_pei_ctr;
DROP VIEW IF EXISTS m_defense_incendie.xapps_geo_v_pei_zonedefense;


-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                              VUES APPLICATIVES                                                                ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################

-- #################################################################### xapps_an_v_deci_tb_patrimoine ###################################################

-- m_defense_incendie.xapps_an_v_deci_tb_patrimoine source

CREATE OR REPLACE VIEW m_defense_incendie.xapps_an_v_deci_tb_patrimoine
AS WITH req_pei_tot AS (
         SELECT 1 AS gid,
            count(*) AS nb
           FROM m_defense_incendie.xapps_geo_v_pei_ctr
          WHERE xapps_geo_v_pei_ctr.id_contrat::text = '01'::text OR xapps_geo_v_pei_ctr.id_contrat::text = '02'::text
        ), req_deci_dispo AS (
         SELECT 1 AS gid,
            count(*) AS nb
           FROM m_defense_incendie.xapps_geo_v_pei_ctr
          WHERE (xapps_geo_v_pei_ctr.id_contrat::text = '01'::text OR xapps_geo_v_pei_ctr.id_contrat::text = '02'::text) AND xapps_geo_v_pei_ctr.disponible = 't'::text
        ), req_deci_nondispo AS (
         SELECT 1 AS gid,
            count(*) AS nb
           FROM m_defense_incendie.xapps_geo_v_pei_ctr
          WHERE (xapps_geo_v_pei_ctr.id_contrat::text = '01'::text OR xapps_geo_v_pei_ctr.id_contrat::text = '02'::text) AND xapps_geo_v_pei_ctr.disponible = 'f'::text
        )
 SELECT 1 AS gid,
    req_pei_tot.nb AS pei_tot,
    req_deci_dispo.nb AS pei_dispo,
    round(req_deci_dispo.nb::numeric / req_pei_tot.nb::numeric * 100::numeric, 1) AS pei_dispo_part,
    req_deci_nondispo.nb AS pei_ndispo
   FROM req_pei_tot,
    req_deci_dispo,
    req_deci_nondispo
  WHERE req_pei_tot.gid = req_deci_dispo.gid AND req_pei_tot.gid = req_deci_nondispo.gid;

COMMENT ON VIEW m_defense_incendie.xapps_an_v_deci_tb_patrimoine IS 'Données nécessaire à la réalisation du tableau de bord dans l''application DECI (indicateur chiffré)';


-- #################################################################### xapps_geo_v_pei_zonedefense ###################################################


-- View: m_defense_incendie.xapps_geo_v_pei_zonedefense

-- DROP VIEW m_defense_incendie.xapps_geo_v_pei_zonedefense;

CREATE OR REPLACE VIEW m_defense_incendie.xapps_geo_v_pei_zonedefense AS 
 SELECT 
  g.id_pei,
  g.insee,
  g.gestion,
  a.id_contrat,
  g.geom1

   FROM m_defense_incendie.geo_pei g
   LEFT JOIN m_defense_incendie.an_pei_ctr a ON a.id_pei = g.id_pei
   WHERE g.statut='01' AND a.etat_conf = 't' AND DATE_PART('year',(AGE(CURRENT_DATE,a.date_ct))) < 2 AND g.etat_pei ='02';

								       
COMMENT ON VIEW m_defense_incendie.xapps_geo_v_pei_zonedefense
  IS 'Vue applicative des zones indicatives de défense incendie publique';

-- #################################################################### geo_v_pei_contr_2023 ###################################################

-- m_defense_incendie.geo_v_pei_contr_2023 source

CREATE OR REPLACE VIEW m_defense_incendie.geo_v_pei_contr_2023
AS SELECT c.id_pei,
    c2023.date_ct,
    c2023.geom
   FROM m_defense_incendie.an_pei_ctr c,
    m_defense_incendie.geo_vmr_pei_contr_2023 c2023
  WHERE c.id_pei = c2023.id_pei AND (c.date_ct = c2023.date_ct OR c2023.date_ct IS NULL);

COMMENT ON VIEW m_defense_incendie.geo_v_pei_contr_2023 IS 'Vue d''affichage pour GEO permettant de visualiser les PEI devant faire l''objet d''un contrôle en 2023. A l''enregistrement du nouveau contrôle le PEI disparait de la vue et ne s''affiche plus.';
						       

