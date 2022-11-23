/*PEI V1.0*/
/*Creation des vues de gestion stockées dans le schéma contenant les tables */
/* pei_60_vues_gestion.sql */
/*PostGIS*/

/* Propriétaire : GeoCompiegnois - http://geo.compiegnois.fr/ */
/* Auteur : FLorent Vanhoutte */
/* Participant : Grégory Bodet */

DROP VIEW IF EXISTS m_defense_incendie.geo_v_pei_ctr_qgis;
DROP VIEW IF EXISTS m_defense_incendie.geo_v_pei_zonedefense;

-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                              VUES DE GESTION                                                                 ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################


-- View: m_defense_incendie.geo_v_pei_ctr_qgis

-- DROP VIEW m_defense_incendie.geo_v_pei_ctr_qgis;

CREATE OR REPLACE VIEW m_defense_incendie.geo_v_pei_ctr_qgis AS 
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

COMMENT ON VIEW m_defense_incendie.geo_v_pei_ctr_qgis
  IS 'Vue éditable destinée à la modification des données relatives aux PEI et aux contrôles';


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

								       
COMMENT ON VIEW m_defense_incendie.geo_v_pei_zonedefense
  IS 'Vue des zones indicatives de défense incendie publique';
								       
								       
-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                      TRIGGER                                                                 ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################


-- #################################################################### FONCTION TRIGGER - GEO_V_PEI_CTR ###################################################

-- Function: m_defense_incendie.ft_m_qgis_geo_v_pei_ctr()

-- DROP FUNCTION m_defense_incendie.ft_m_qgis_geo_v_pei_ctr();

CREATE OR REPLACE FUNCTION m_defense_incendie.ft_m_qgis_geo_v_pei_ctr()
  RETURNS trigger AS
$BODY$

DECLARE v_id_pei integer;
--déclaration variable pour stocker la liste des anomalies
DECLARE v_lt_anom character varying(80);
--déclaration variable pour stocker le résultat sur la conformité de l'accès
DECLARE v_etat_acces character varying(1);

BEGIN

-- INSERT
IF (TG_OP = 'INSERT') THEN

v_id_pei := nextval('m_defense_incendie.geo_pei_id_seq'::regclass);
INSERT INTO m_defense_incendie.geo_pei (id_pei, id_sdis, verrou, ref_terr, insee, type_pei, type_rd, diam_pei, raccord, marque, source_pei, debit_r_ci,volume, diam_cana, etat_pei, statut, nom_etab, gestion, delegat, cs_sdis, situation, observ, photo_url, src_pei, x_l93, y_l93, src_geom, src_date, prec, ope_sai, date_sai, date_maj, geom, geom1)
SELECT v_id_pei,
CASE WHEN NEW.id_sdis = '' THEN NULL ELSE NEW.id_sdis END,
NEW.verrou,
CASE WHEN NEW.ref_terr = '' THEN NULL ELSE NEW.ref_terr END,
CASE WHEN NEW.insee IS NULL THEN (SELECT insee FROM r_osm.geo_vm_osm_commune_apc WHERE st_intersects(NEW.geom,geom)) ELSE NEW.insee END,
CASE WHEN NEW.type_pei IS NULL THEN 'NR' ELSE NEW.type_pei END,
NEW.type_rd,
CASE WHEN NEW.diam_pei IS NULL THEN 0 ELSE NEW.diam_pei END,
CASE WHEN NEW.raccord IS NULL THEN '00' ELSE NEW.raccord END,
CASE WHEN NEW.marque IS NULL THEN '00' ELSE NEW.marque END,
CASE WHEN NEW.source_pei IS NULL THEN 'NR' ELSE NEW.source_pei END,
NEW.debit_r_ci,				  
NEW.volume,
NEW.diam_cana,
CASE WHEN NEW.etat_pei IS NULL THEN '00' ELSE NEW.etat_pei END,
CASE WHEN NEW.statut IS NULL THEN '00' ELSE NEW.statut END,
CASE WHEN NEW.nom_etab = '' THEN NULL ELSE LOWER(NEW.nom_etab) END,
CASE WHEN NEW.gestion IS NULL THEN '00' ELSE NEW.gestion END,
CASE WHEN NEW.delegat IS NULL THEN '00' ELSE NEW.delegat END,
CASE WHEN NEW.cs_sdis IS NULL THEN '00000' ELSE NEW.cs_sdis END,
CASE WHEN NEW.situation = '' THEN NULL ELSE LOWER(NEW.situation) END,
CASE WHEN NEW.observ = '' THEN NULL ELSE LOWER(NEW.observ) END,
CASE WHEN NEW.photo_url = '' THEN NULL ELSE NEW.photo_url END,
CASE WHEN NEW.src_pei = '' THEN NULL ELSE NEW.src_pei END,
st_x(NEW.geom),
st_y(NEW.geom),
CASE WHEN NEW.src_geom IS NULL OR NEW.src_geom = '' THEN '00' ELSE NEW.src_geom END,
CASE WHEN NEW.src_date IS NULL OR NEW.src_date = '' THEN '0000' ELSE NEW.src_date END,
CASE WHEN NEW.prec IS NULL OR NEW.prec = '' THEN '000' ELSE NEW.prec END,
CASE WHEN NEW.ope_sai = '' THEN NULL ELSE NEW.ope_sai END,
CASE WHEN NEW.date_sai IS NULL THEN now() ELSE now() END,
NEW.date_maj,
NEW.geom,
ST_Buffer(NEW.geom, 200);

INSERT INTO m_defense_incendie.an_pei_ctr (id_pei, id_sdis, id_contrat, press_stat, press_dyn, debit, debit_max, etat_anom, lt_anom, etat_acces, etat_sign, etat_conf, date_mes, date_ct, ope_ct, date_ro)
SELECT v_id_pei,
NEW.id_sdis,
NEW.id_contrat,
NEW.press_stat,
NEW.press_dyn,
NEW.debit,
NEW.debit_max,
CASE WHEN NEW.etat_anom IS NULL THEN '0' ELSE NEW.etat_anom END,
CASE WHEN NEW.lt_anom = '' THEN NULL ELSE NEW.lt_anom END,
CASE WHEN NEW.etat_acces IS NULL THEN '0' ELSE NEW.etat_acces END,
CASE WHEN NEW.etat_sign IS NULL THEN '0' ELSE NEW.etat_sign END,
CASE WHEN NEW.etat_conf IS NULL THEN '0' ELSE NEW.etat_conf END,
NEW.date_mes,
CASE WHEN NEW.date_ct > CURRENT_DATE THEN NULL ELSE NEW.date_ct END,
NEW.ope_ct,
NEW.date_ro;
RETURN NEW;

-- UPDATE
ELSIF (TG_OP = 'UPDATE') THEN

--déclaration variable pour stocker la liste des anomalies
v_lt_anom := CASE WHEN NEW.etat_anom = 't' THEN NULL ELSE NEW.lt_anom END;
-- déclaration variable pour stocker le résultat sur la conformité de l'accès
v_etat_acces := CASE WHEN v_lt_anom LIKE '%05%' THEN 'f' ELSE NEW.etat_acces END;

UPDATE
m_defense_incendie.geo_pei
SET
id_pei=OLD.id_pei,
id_sdis=CASE WHEN NEW.id_sdis = '' THEN NULL ELSE NEW.id_sdis END,
verrou=NEW.verrou,
-- refus de mise à jour si le point est déplacé dans une autre commune
insee=CASE WHEN (SELECT insee FROM r_osm.geo_vm_osm_commune_apc WHERE st_intersects(NEW.geom,geom))=OLD.insee THEN OLD.insee ELSE NULL END,
type_pei=CASE WHEN NEW.type_pei IS NULL THEN 'NR' ELSE NEW.type_pei END,
type_rd=NEW.type_rd,
diam_pei=CASE WHEN NEW.diam_pei IS NULL THEN 0 ELSE NEW.diam_pei END,
raccord=CASE WHEN NEW.raccord IS NULL THEN '00' ELSE NEW.raccord END,
marque=CASE WHEN NEW.marque IS NULL THEN '00' ELSE NEW.marque END,
source_pei=CASE WHEN NEW.source_pei IS NULL THEN '00' ELSE NEW.source_pei END,
debit_r_ci=CASE WHEN NEW.type_pei IN ('PI','BI') OR (NEW.type_pei = 'PA' AND NEW.source_pei = 'CE') THEN NULL ELSE NEW.debit_r_ci END, 
volume=CASE WHEN NEW.type_pei IN ('PI','BI') OR (NEW.type_pei = 'PA' AND NEW.source_pei = 'CE') THEN NULL ELSE NEW.volume END,
diam_cana=NEW.diam_cana,
etat_pei=CASE WHEN NEW.etat_pei IS NULL THEN '00' ELSE NEW.etat_pei END,
statut=CASE WHEN NEW.statut IS NULL THEN '00' ELSE NEW.statut END,
nom_etab=CASE WHEN NEW.nom_etab = '' THEN NULL ELSE LOWER(NEW.nom_etab) END,
gestion=CASE WHEN NEW.gestion IS NULL THEN '00' ELSE NEW.gestion END,
delegat=CASE WHEN NEW.delegat IS NULL THEN '00' ELSE NEW.delegat END,
cs_sdis=CASE WHEN NEW.cs_sdis IS NULL THEN '00000' ELSE NEW.cs_sdis END,
situation=CASE WHEN NEW.situation = '' THEN NULL ELSE LOWER(NEW.situation) END,
observ=CASE WHEN NEW.observ = '' THEN NULL ELSE LOWER(NEW.observ) END,
photo_url=CASE WHEN NEW.photo_url = '' THEN NULL ELSE NEW.photo_url END,
src_pei=CASE WHEN NEW.src_pei = '' THEN NULL ELSE NEW.src_pei END,
x_l93=st_x(NEW.geom),
y_l93=st_y(NEW.geom),
src_geom=CASE WHEN NEW.src_geom IS NULL OR NEW.src_geom = '' THEN '00' ELSE NEW.src_geom END,
src_date=CASE WHEN NEW.src_date IS NULL OR NEW.src_date = '' OR NEW.src_geom ='00' THEN '0000' ELSE NEW.src_date END,
prec=CASE WHEN NEW.prec IS NULL OR NEW.prec = '' OR NEW.src_geom = '00' THEN '000' ELSE NEW.prec END,
ope_sai=CASE WHEN NEW.ope_sai = '' THEN NULL ELSE NEW.ope_sai END,
date_sai=OLD.date_sai,
date_maj=now(),
geom=NEW.geom,
geom1=ST_Buffer(NEW.geom, 200)
WHERE m_defense_incendie.geo_pei.id_pei = OLD.id_pei;

UPDATE
m_defense_incendie.an_pei_ctr
SET
id_pei=NEW.id_pei,
id_sdis=NEW.id_sdis,
id_contrat=NEW.id_contrat,
press_stat=CASE WHEN NEW.type_pei IN ('CI','PA') THEN NULL ELSE NEW.press_stat END,
press_dyn=CASE WHEN NEW.type_pei IN ('CI','PA') THEN NULL ELSE NEW.press_dyn END,
debit=CASE WHEN NEW.type_pei IN ('CI','PA') THEN NULL ELSE NEW.debit END,
debit_max=CASE WHEN NEW.type_pei IN ('CI','PA') THEN NULL ELSE NEW.debit_max END,
etat_anom=CASE WHEN NEW.etat_anom IS NULL THEN '0' ELSE NEW.etat_anom END,
lt_anom=CASE WHEN NEW.lt_anom = '' OR NEW.etat_anom IN ('0','t') THEN NULL ELSE NEW.lt_anom END,
etat_acces=CASE WHEN NEW.etat_anom = 't' THEN 't' ELSE v_etat_acces END,
etat_sign=CASE WHEN v_lt_anom LIKE '%04%' THEN 'f' ELSE NEW.etat_sign END,
--etat_conf, les pts de controle sont différents selon le type de PEI
etat_conf=CASE WHEN NEW.type_pei IN ('PI','BI') AND (NEW.debit < 60 OR NEW.press_dyn < 1 OR v_lt_anom LIKE '%14%' OR v_lt_anom LIKE '%03%' OR v_lt_anom LIKE '%10%' OR v_etat_acces = 'f') THEN 'f' 
               WHEN NEW.type_pei = 'CI' AND (NEW.volume < 15 OR 
		(
		(CASE WHEN NEW.debit_r_ci is null THEN 0 ELSE NEW.debit_r_ci*2 END) 
		+ NEW.volume) < 120 OR v_lt_anom LIKE '%14%' OR v_lt_anom LIKE '%03%' OR v_lt_anom LIKE '%10%' OR v_lt_anom LIKE '%15%' OR v_etat_acces = 'f') THEN 'f' 
               WHEN NEW.type_pei = 'PA' AND NEW.source_pei = 'CE' AND (v_lt_anom LIKE '%14%' OR v_lt_anom LIKE '%03%' OR v_lt_anom LIKE '%10%' OR v_lt_anom LIKE '%15%' OR v_etat_acces = 'f') THEN 'f'
               WHEN NEW.type_pei = 'PA' AND NEW.source_pei != 'CE' AND (v_lt_anom LIKE '%14%' OR v_lt_anom LIKE '%03%' OR v_lt_anom LIKE '%10%' OR v_lt_anom LIKE '%15%' OR v_etat_acces = 'f') THEN 'f'
               /*WHEN v_gestion = 'IN' AND NEW.type_pei = 'NR' THEN 'f'*/ ELSE 't' END,
date_mes=NEW.date_mes,
date_ct=CASE WHEN NEW.date_ct > CURRENT_DATE THEN NULL ELSE NEW.date_ct END,
ope_ct=NEW.ope_ct,
date_ro=NEW.date_ro
WHERE m_defense_incendie.an_pei_ctr.id_pei = OLD.id_pei;
RETURN NEW;


-- DELETE
ELSIF (TG_OP = 'DELETE') THEN
UPDATE
m_defense_incendie.geo_pei
SET
etat_pei='03'

WHERE m_defense_incendie.geo_pei.id_pei = OLD.id_pei;


RETURN NEW;

END IF;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION m_defense_incendie.ft_m_qgis_geo_v_pei_ctr()
  OWNER TO sig_create;

COMMENT ON FUNCTION m_defense_incendie.ft_m_qgis_geo_v_pei_ctr() IS 'Fonction trigger pour mise à jour de la vue de gestion des points d''eau incendie et contrôles';



-- Trigger: t_t1_geo_v_pei_ctr on m_defense_incendie.geo_v_pei_ctr_qgis

-- DROP TRIGGER t_t1_geo_v_pei_ctr ON m_defense_incendie.geo_v_pei_ctr_qgis;

CREATE TRIGGER t_t1_geo_v_pei_ctr
  INSTEAD OF INSERT OR UPDATE OR DELETE
  ON m_defense_incendie.geo_v_pei_ctr_qgis
  FOR EACH ROW
  EXECUTE PROCEDURE m_defense_incendie.ft_m_qgis_geo_v_pei_ctr();
										   
										   
-- #################################################################### FONCTION TRIGGER - LOG_PEI ###################################################

-- Function: m_defense_incendie.ft_m_log_pei()

-- DROP FUNCTION m_defense_incendie.ft_m_log_pei();

CREATE OR REPLACE FUNCTION m_defense_incendie.ft_m_log_pei()
  RETURNS trigger AS
$BODY$

DECLARE v_id_audit integer;
DECLARE v_id_pei integer;

BEGIN

-- INSERT
IF (TG_OP = 'INSERT') THEN

v_id_audit := nextval('m_defense_incendie.log_pei_id_seq'::regclass);
v_id_pei := currval('m_defense_incendie.geo_pei_id_seq'::regclass);
INSERT INTO m_defense_incendie.log_pei (id_audit, type_ope, ope_sai, id_pei, date_maj)
SELECT
v_id_audit,
'INSERT',
NEW.ope_sai,
v_id_pei,
now();
RETURN NEW;


-- UPDATE
ELSIF (TG_OP = 'UPDATE') THEN

v_id_audit := nextval('m_defense_incendie.log_pei_id_seq'::regclass);
INSERT INTO m_defense_incendie.log_pei (id_audit, type_ope, ope_sai, id_pei, date_maj)
SELECT
v_id_audit,
'UPDATE',
NEW.ope_sai,
NEW.id_pei,
now();
RETURN NEW;


-- DELETE
ELSIF (TG_OP = 'DELETE') THEN

v_id_audit := nextval('m_defense_incendie.log_pei_id_seq'::regclass);
INSERT INTO m_defense_incendie.log_pei (id_audit, type_ope, ope_sai, id_pei, date_maj)
SELECT
v_id_audit,
'DELETE',
NEW.ope_sai,
NEW.id_pei,
now();
RETURN NEW;

END IF;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION m_defense_incendie.ft_m_log_pei()
  OWNER TO sig_create;

COMMENT ON FUNCTION m_defense_incendie.ft_m_log_pei() IS 'audit';



-- Trigger: m_defense_incendie.t_log_pei on m_defense_incendie.geo_v_pei_ctr_qgis

-- DROP TRIGGER m_defense_incendie.t_log_pei ON m_defense_incendie.geo_v_pei_ctr_qgis;

CREATE TRIGGER t_t2_log_pei
  INSTEAD OF INSERT OR UPDATE OR DELETE
  ON m_defense_incendie.geo_v_pei_ctr_qgis
  FOR EACH ROW
  EXECUTE PROCEDURE m_defense_incendie.ft_m_log_pei();
