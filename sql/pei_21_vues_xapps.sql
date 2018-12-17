/*PEI V1.0*/
/*Creation des vues applicatives stockées dans le schéma x_apps */
/* pei_61_vues_xapps.sql */
/*PostGIS*/

/* Propriétaire : GeoCompiegnois - http://geo.compiegnois.fr/ */
/* Auteur : FLorent Vanhoutte */
/* Participant : Grégory Bodet */


DROP VIEW IF EXISTS x_apps.xapps_geo_v_pei_ctr;
DROP VIEW IF EXISTS x_apps.xapps_geo_v_pei_zonedefense;


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
								       
								       
-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                              TRIGGERS                                                               ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################

								       
-- #################################################################### FONCTION TRIGGER - XAPPS_GEO_V_PEI_CTR ###################################################

/*
cette fonction a pour but de traiter des différents cas de gestion des données PEI pour le service eau potable mutualisé de l'ARC et de la ville de Compiègne
Le service est gestionnaire d'un patrimoine PEI correspondant à une partie des entités de la base PEI, ce patrimoine étant lui même décomposé en plusieurs contrats pour de l'entretien et des controles auprès de sociétés prestataires
La fonction trigger doit donc refleter la capacité du service a faire entrée ou sortir de son patrimoine des PEI, et agir sur celui-ci en verouillant ou non la saisie pour lui même et les sous-traitants
1- insert
ras, l'insertion doit être possible
2- update
2a- patrimoine arc
	2a1- avant et après oui
		2a1a- verrou avant oui et après oui => maj non
		2a1b- verrou avant non et après non => maj oui
		2a1c- verrou avant non et après oui => maj oui
		2a1d- verrou avant oui et après non => maj oui
	2a2- avant non (de fait verrou non) mais après oui = entrée de patrimoine pei => maj oui
2b- patrimoine non arc
	2b1- avant et après non arc => maj non
	2b2- avant oui arc mais après non arc = sortie du patrimoine pei => maj ok avec des cas particuliers pour id_contrat='ZZ', verrou IS FALSE  
3-delete
3a- patrimoine arc
	3a1- > update avec etat_pei à "supprimé"
	3a2- > 
3b- patrimoine non arc = interdiction > ni delete ni update
*/
-- Function: x_apps.ft_xapps_geo_v_pei_ctr()

-- DROP FUNCTION x_apps.ft_xapps_geo_v_pei_ctr();

CREATE OR REPLACE FUNCTION x_apps.ft_xapps_geo_v_pei_ctr()
  RETURNS trigger AS
$BODY$

--déclaration variable pour la séquence de l'id de la base
DECLARE v_id_pei integer;
--déclaration variable pour stocker la liste des anomalies
DECLARE v_lt_anom character varying(254);
--déclaration variable pour stocker le résultat sur la conformité de l'accès
DECLARE v_etat_acces character varying(1);
--variable qui stocke l'état du verrou du PEI
DECLARE v_verrou boolean;
--variable qui stocke l'état d'appartenance du PEI au patrimoine en gestion du service mutualisé de l'eau potable
DECLARE v_gestion character varying(3);

BEGIN


-- ############ INSERT ###########

IF (TG_OP = 'INSERT') THEN

v_id_pei := nextval('m_defense_incendie.geo_pei_id_seq'::regclass);

INSERT INTO m_defense_incendie.geo_pei (id_pei, id_sdis, verrou, ref_terr, insee, type_pei, type_rd, diam_pei, raccord, marque, source_pei,debit_r_ci, volume, diam_cana, etat_pei, statut, nom_etab, gestion, delegat, cs_sdis, situation, observ, photo_url, src_pei, x_l93, y_l93, src_geom, src_date, prec, ope_sai, date_sai, date_maj, geom, geom1)

SELECT v_id_pei,

CASE WHEN NEW.id_sdis = ''
THEN NULL
ELSE NEW.id_sdis
END,

false,

CASE WHEN NEW.ref_terr = '' THEN NULL
ELSE NEW.ref_terr
END,

CASE WHEN NEW.insee IS NULL THEN (SELECT insee FROM r_osm.geo_v_osm_commune_apc WHERE st_intersects(NEW.geom,geom))
ELSE NEW.insee
END,

CASE WHEN NEW.type_pei IS NULL THEN 'NR'
ELSE NEW.type_pei
END,

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
CASE WHEN NEW.id_sdis = '' THEN NULL ELSE NEW.id_sdis END,
CASE WHEN NEW.id_contrat IS NULL THEN '00' ELSE NEW.id_contrat END,
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


-- ############ UPDATE ############


-- MODIFICATIONS AUTORISEES < cas d'un PEI appartenant au patrimoine du service ou entrant dans celui-ci et non verrouillé

ELSIF (TG_OP = 'UPDATE') THEN

-- si il y a un verrou avant (OLD) et après (NEW), alors il y a un état de verrou permanent empechant les modifications, sinon les modif sont autorisées puisqu'au moins à un moment, il n'y avait pas de verrou 
v_verrou := CASE WHEN OLD.verrou IS TRUE AND NEW.verrou IS TRUE THEN TRUE ELSE FALSE END;

-- si le PEI a une gestion intercommunale (04) ou une gestion communale (05) sur Compiègne, alors le PEI rentre dans le patrimoine de gestion du service 
v_gestion := CASE WHEN NEW.gestion = '04' OR (NEW.gestion ='05' AND NEW.insee ='60159') THEN 'IN' ELSE 'OUT' END;

-- si absence d'anomalie est vraie alors la liste des anomalies est "null"
v_lt_anom := CASE WHEN NEW.etat_anom IN ('t','0') THEN NULL ELSE NEW.lt_anom END;

-- si la liste des anomalies fait état d'un problème d'accessibilité (05), alors l'accessibilité du PEI est non conforme
v_etat_acces := CASE WHEN v_lt_anom LIKE '%05%' THEN 'f' ELSE NEW.etat_acces END;


-- si le contrôle est validé (donc vérouillé) aucune modification possible, remonté d'un message d'erreur
IF v_verrou is true THEN

-- gestion d'écriture d'un message d'erreur dans une table qui remonte dans GEO avec un horodatage pour gére le temps d'affichage (de remonter du message)
DELETE FROM x_apps.xapps_geo_v_pei_ctr_erreur WHERE id_pei = old.id_pei;
INSERT INTO x_apps.xapps_geo_v_pei_ctr_erreur VALUES
(
nextval('x_apps.xapps_geo_v_pei_ctr_erreur_gid_seq'::regclass),
old.id_pei,
'Vous ne pouvez pas modifier un contrôle validé.<br> Modifications non prises en compte.',
now()
);


-- si non on peut poursuivre
ELSE

-- on ne peut pas modifier un contrôle en dehors de Compiègne et Zone de gestion ARC si celui-ci n'est pas de compétence ARC
IF v_gestion = 'OUT' THEN

-- gestion d'écriture d'un message d'erreur dans une table qui remonte dans GEO avec un horodatage pour gére le temps d'affichage (de remonter du message)
DELETE FROM x_apps.xapps_geo_v_pei_ctr_erreur WHERE id_pei = old.id_pei;
INSERT INTO x_apps.xapps_geo_v_pei_ctr_erreur VALUES
(
nextval('x_apps.xapps_geo_v_pei_ctr_erreur_gid_seq'::regclass),
old.id_pei,
'Vous ne pouvez pas modifier un PEI en dehors des zones de gestion ARC et ville de Compiègne.<br> Modifications non prises en compte.',
now()
);


-- si non on peut poursuivre
ELSE

UPDATE

m_defense_incendie.geo_pei

SET

id_pei=		OLD.id_pei,

id_sdis= CASE WHEN v_gestion = 'OUT' OR v_verrou IS TRUE THEN OLD.id_sdis
    WHEN v_gestion = 'IN' AND NEW.id_sdis = '' THEN NULL
		ELSE NEW.id_sdis
		END,

-- en cas de sortie du patrimoine géré par le service alors par défaut il n'y a pas de verrou
verrou=		CASE WHEN v_gestion = 'OUT' THEN false
		ELSE NEW.verrou
		END,
		
ref_terr=	CASE WHEN v_gestion = 'OUT' OR v_verrou IS TRUE THEN OLD.ref_terr
		WHEN v_gestion = 'IN' AND NEW.ref_terr = '' THEN NULL
		ELSE NEW.ref_terr
		END,

-- refus de mise à jour si le point est déplacé dans une autre commune
insee=		CASE WHEN (SELECT insee FROM r_osm.geo_v_osm_commune_apc WHERE st_intersects(NEW.geom,geom))=OLD.insee THEN OLD.insee ELSE NULL END,

type_pei=	CASE WHEN v_gestion = 'OUT' OR v_verrou IS TRUE THEN OLD.type_pei
		WHEN v_gestion = 'IN' AND NEW.type_pei IS NULL THEN 'NR'
		ELSE NEW.type_pei
		END,

type_rd=	CASE WHEN v_gestion = 'OUT' OR v_verrou IS TRUE THEN OLD.type_rd
		WHEN v_gestion = 'IN' AND NEW.type_rd = '' THEN NULL
		ELSE NEW.type_rd
		END,
		
diam_pei=	CASE WHEN v_gestion = 'OUT' OR v_verrou IS TRUE THEN OLD.diam_pei
		WHEN v_gestion = 'IN' AND NEW.diam_pei IS NULL THEN 0
		ELSE NEW.diam_pei
		END,
		
raccord=	CASE WHEN v_gestion = 'OUT' OR v_verrou IS TRUE THEN OLD.raccord
		WHEN v_gestion = 'IN' AND NEW.raccord IS NULL THEN '00'
		ELSE NEW.raccord
		END,
		
marque=		CASE WHEN v_gestion = 'OUT' OR v_verrou IS TRUE THEN OLD.marque
		WHEN v_gestion = 'IN' AND NEW.marque IS NULL THEN '00'
		ELSE NEW.marque
		END,
		
source_pei=		CASE WHEN v_gestion = 'OUT' OR v_verrou IS TRUE THEN OLD.source_pei
		WHEN v_gestion = 'IN' AND NEW.source_pei IS NULL THEN '00'
		ELSE NEW.source_pei
		END,


-- debit_r_ci devient "null" si jamais le type de PEI est PI, BI ou PA pour un cours d'eau (car illimité dans ce cas)
debit_r_ci=	CASE WHEN v_gestion = 'OUT' OR v_verrou IS TRUE THEN OLD.debit_r_ci
		WHEN v_gestion = 'IN' AND (NEW.type_pei IN ('PI','BI') OR (NEW.type_pei = 'PA' AND NEW.source_pei = 'CE')) THEN NULL
		ELSE NEW.debit_r_ci
		END,
											     
-- volume devient "null" si jamais le type de PEI est PI, BI ou PA pour un cours d'eau (car illimité dans ce cas)		
volume=		CASE WHEN v_gestion = 'OUT' OR v_verrou IS TRUE THEN OLD.volume
		WHEN v_gestion = 'IN' AND (NEW.type_pei IN ('PI','BI') OR (NEW.type_pei = 'PA' AND NEW.source_pei = 'CE')) THEN NULL
		ELSE NEW.volume
		END,
		
diam_cana=	CASE WHEN v_gestion = 'OUT' OR v_verrou IS TRUE THEN OLD.diam_cana
		WHEN v_gestion = 'IN' THEN NEW.diam_cana
		END,
		
etat_pei=	CASE WHEN v_gestion = 'OUT' OR v_verrou IS TRUE THEN OLD.etat_pei
		WHEN v_gestion = 'IN' AND NEW.etat_pei IS NULL THEN '00'
		ELSE NEW.etat_pei
		END,
		
statut=		CASE WHEN v_gestion = 'OUT' OR v_verrou IS TRUE THEN OLD.statut
		WHEN v_gestion = 'IN' AND NEW.statut IS NULL THEN '00'
		ELSE NEW.statut
		END,
		
nom_etab= CASE WHEN v_gestion = 'OUT' OR v_verrou IS TRUE THEN OLD.nom_etab
    WHEN v_gestion = 'IN' AND NEW.nom_etab = '' THEN NULL
    ELSE LOWER(NEW.nom_etab)
    END,		

-- le gestionnaire est modifiable par le service afin de pouvoir faire entrer ou sortir du patrimoine PEI de sa gestion. la modification reste néanmoins interdite en cas de verrou maintenu lors de la mise à jour.		
gestion=	CASE WHEN v_verrou IS TRUE THEN OLD.gestion
		WHEN NEW.gestion IS NULL THEN '00'
		ELSE NEW.gestion
		END,

delegat=	CASE WHEN v_gestion = 'OUT' OR v_verrou IS TRUE THEN OLD.statut
		WHEN v_gestion = 'IN' AND NEW.delegat IS NULL THEN '00'
		ELSE NEW.delegat
		END,
		
cs_sdis=	CASE WHEN v_gestion = 'OUT' OR v_verrou IS TRUE THEN OLD.cs_sdis
		WHEN v_gestion = 'IN' AND NEW.cs_sdis IS NULL THEN '00000'
		ELSE NEW.cs_sdis
		END,
		
situation=	CASE WHEN v_gestion = 'OUT' OR v_verrou IS TRUE THEN OLD.situation
		WHEN v_gestion = 'IN' AND NEW.situation = '' THEN NULL
		ELSE LOWER(NEW.situation)
		END,

observ=		CASE WHEN v_gestion = 'OUT' OR v_verrou IS TRUE THEN OLD.observ
		WHEN v_gestion = 'IN' AND NEW.observ = '' THEN NULL
		ELSE LOWER(NEW.observ)
		END,
		
photo_url=	CASE WHEN v_gestion = 'OUT' OR v_verrou IS TRUE THEN OLD.photo_url
		WHEN v_gestion = 'IN' AND NEW.photo_url = '' THEN NULL
		ELSE NEW.photo_url
		END,
		
src_pei=	CASE WHEN v_gestion = 'OUT' OR v_verrou IS TRUE THEN OLD.src_pei
		WHEN v_gestion = 'IN' AND NEW.src_pei = '' THEN NULL
		ELSE NEW.src_pei
		END,
		
x_l93=		CASE WHEN v_gestion = 'OUT' OR v_verrou IS TRUE THEN OLD.x_l93
		WHEN v_gestion = 'IN' THEN st_x(NEW.geom)
		END,

y_l93=		CASE WHEN v_gestion = 'OUT' OR v_verrou IS TRUE THEN OLD.y_l93
		WHEN v_gestion = 'IN' THEN st_y(NEW.geom)
		END,

src_geom=	CASE WHEN v_gestion = 'OUT' OR v_verrou IS TRUE THEN OLD.src_geom
		WHEN v_gestion = 'IN' AND (NEW.src_geom IS NULL OR NEW.src_geom = '') THEN '00'
		ELSE NEW.src_geom
		END,
		
src_date=	CASE WHEN v_gestion = 'OUT' OR v_verrou IS TRUE THEN OLD.src_date
		WHEN v_gestion = 'IN' AND (NEW.src_date IS NULL OR NEW.src_date = '' OR NEW.src_geom ='00') THEN '0000'
		ELSE NEW.src_date
		END,
		
prec=		CASE WHEN v_gestion = 'OUT' OR v_verrou IS TRUE THEN OLD.prec
		WHEN v_gestion = 'IN' AND (NEW.prec IS NULL OR NEW.prec = '' OR NEW.src_geom = '00') THEN '000'
		ELSE NEW.prec
		END,
		
ope_sai=	CASE WHEN v_gestion = 'OUT' OR v_verrou IS TRUE THEN OLD.ope_sai
		WHEN v_gestion = 'IN' AND NEW.ope_sai = '' THEN NULL
		ELSE NEW.ope_sai
		END,
		
date_sai=	OLD.date_sai,

date_maj=	now(),

geom=		CASE WHEN v_gestion = 'OUT' OR v_verrou IS TRUE THEN OLD.geom
		WHEN v_gestion = 'IN' THEN NEW.geom
		END,
		
geom1=		CASE WHEN v_gestion = 'OUT' OR v_verrou IS TRUE THEN ST_Buffer(OLD.geom, 200)
		WHEN v_gestion = 'IN' THEN ST_Buffer(NEW.geom, 200)
		END
		
WHERE m_defense_incendie.geo_pei.id_pei = OLD.id_pei;

UPDATE

m_defense_incendie.an_pei_ctr

SET

id_pei=		NEW.id_pei,

id_sdis= CASE WHEN v_gestion = 'OUT' OR v_verrou IS TRUE THEN OLD.id_sdis
    WHEN v_gestion = 'IN' AND NEW.id_sdis = '' THEN NULL
		ELSE NEW.id_sdis
		END,

-- en cas de sortie du patrimoine, le contrat est mis par défaut à non concerné (id_contrat = 'ZZ') afin de ne pas laisser la capacité au prestataire d'intervenir si oubli
id_contrat=	CASE WHEN v_gestion = 'OUT' THEN 'ZZ'
		WHEN v_verrou IS TRUE THEN OLD.id_contrat
		WHEN v_gestion = 'IN' THEN NEW.id_contrat
		END,

-- press_stat devient "null" si jamais le type de PEI est CI ou PA	 
press_stat=	CASE WHEN v_gestion = 'OUT' OR v_verrou IS TRUE THEN OLD.press_stat
		WHEN v_gestion = 'IN' AND NEW.type_pei IN ('CI','PA') THEN NULL 
		ELSE NEW.press_stat
		END,

-- press_dyn devient "null" si jamais le type de PEI est CI ou PA
press_dyn=	CASE WHEN v_gestion = 'OUT' OR v_verrou IS TRUE THEN OLD.press_dyn 
		WHEN v_gestion = 'IN' AND NEW.type_pei IN ('CI','PA') THEN NULL
		ELSE NEW.press_dyn
		END,

-- debit devient "null" si jamais le type de PEI est CI ou PA
debit=		CASE WHEN v_gestion = 'OUT' OR v_verrou IS TRUE THEN OLD.debit
		WHEN v_gestion = 'IN' AND NEW.type_pei IN ('CI','PA') THEN NULL
		ELSE NEW.debit
		END,

-- debit_max devient "null" si jamais le type de PEI est CI ou PA
debit_max=	CASE WHEN v_gestion = 'OUT' OR v_verrou IS TRUE THEN OLD.debit_max
		WHEN v_gestion = 'IN' AND NEW.type_pei IN ('CI','PA') THEN NULL
		ELSE NEW.debit_max
		END,


etat_anom=	CASE WHEN v_gestion = 'OUT' OR v_verrou IS TRUE THEN OLD.etat_anom
		WHEN v_gestion = 'IN' AND NEW.etat_anom IS NULL THEN '0'
		ELSE NEW.etat_anom
		END,

lt_anom=	v_lt_anom,

etat_acces=	CASE WHEN v_gestion = 'OUT' OR v_verrou IS TRUE THEN OLD.etat_acces
		WHEN v_gestion = 'IN' AND NEW.etat_anom = 't' THEN 't'
		ELSE v_etat_acces
		END,

etat_sign=	CASE WHEN v_gestion = 'OUT' OR v_verrou IS TRUE THEN OLD.etat_sign
		WHEN v_gestion = 'IN' AND v_lt_anom LIKE '%04%' THEN 'f'
		ELSE NEW.etat_sign
		END,

-- ######## contrôle des mesures et anomalies pour la conformité technique ########

-- etat_conf, les pts de controle sont différents selon le type de PEI
etat_conf=	CASE WHEN v_gestion = 'OUT' OR v_verrou IS TRUE THEN OLD.etat_conf
		-- pour un type PI ou BI, CT ok dans le cas où : débit > 60 m3/h ou pression dynamique > 1 bar et certains types d'anomalies ne sont pas présentes
		WHEN v_gestion = 'IN' AND NEW.type_pei IN ('PI','BI') AND (NEW.debit >= 60 OR NEW.press_dyn >= 1) AND (v_lt_anom ='' OR v_lt_anom IS NULL OR (v_lt_anom NOT LIKE '%03%' AND v_lt_anom NOT LIKE '%05%' AND v_lt_anom NOT LIKE '%10%' AND v_lt_anom NOT LIKE '%14%') ) THEN 't' 
		-- pour un type CI ok dans le cas où : volume > 120 m" ou si volume est entre 60 et 120 avec un débit de remplissage de 60 m3/h et certains types d'anomalies ne sont pas présentes
		WHEN v_gestion = 'IN' AND NEW.type_pei = 'CI' AND NEW.volume >=15 AND (NEW.debit_r_ci*2 + NEW.volume) >= 120 AND (v_lt_anom ='' OR v_lt_anom IS NULL OR (v_lt_anom NOT LIKE '%03%' AND v_lt_anom NOT LIKE '%05%' AND v_lt_anom NOT LIKE '%10%' AND v_lt_anom NOT LIKE '%14%' AND v_lt_anom NOT LIKE '%15%') ) THEN 't' 
		-- pour un type PA ok dans le cas où : certains types d'anomalies ne sont pas présentes
		WHEN v_gestion = 'IN' AND NEW.type_pei = 'PA' AND (v_lt_anom ='' OR v_lt_anom IS NULL OR (v_lt_anom NOT LIKE '%03%' AND v_lt_anom NOT LIKE '%05%' AND v_lt_anom NOT LIKE '%10%' AND v_lt_anom NOT LIKE '%14%' AND v_lt_anom NOT LIKE '%15%') ) THEN 't'
		-- autre cas correspondent à une NON conformité technique 		
		ELSE 'f'
		END,
		
               
date_mes=	CASE WHEN v_gestion = 'OUT' OR v_verrou IS TRUE THEN OLD.date_mes
		WHEN v_gestion = 'IN' THEN NEW.date_mes
		END,

date_ct=	CASE WHEN v_gestion = 'OUT' OR v_verrou IS TRUE THEN OLD.date_ct
		WHEN v_gestion = 'IN' AND NEW.date_ct > CURRENT_DATE THEN NULL
		ELSE NEW.date_ct
		END,

ope_ct=		CASE WHEN v_gestion = 'OUT' OR v_verrou IS TRUE THEN OLD.ope_ct
		WHEN v_gestion = 'IN' THEN NEW.ope_ct
		END,

date_ro=	CASE WHEN v_gestion = 'OUT' OR v_verrou IS TRUE THEN OLD.date_ro
		WHEN v_gestion = 'IN' THEN NEW.date_ro
		END

WHERE m_defense_incendie.an_pei_ctr.id_pei = OLD.id_pei;

END IF;
END IF;
									   
RETURN NEW;


-- ############ DELETE ############


ELSIF (TG_OP = 'DELETE') THEN


v_verrou := CASE WHEN OLD.verrou IS TRUE THEN TRUE ELSE FALSE END;

v_gestion := CASE WHEN OLD.gestion = '04' OR (OLD.gestion ='05' AND OLD.insee ='60159') THEN 'IN' ELSE 'OUT' END;

-- si le contrôle est validé (donc vérouillé) aucune modification possible, remonté d'un message d'erreur
IF v_verrou is true THEN

-- gestion d'écriture d'un message d'erreur dans une table qui remonte dans GEO avec un horodatage pour gére le temps d'affichage (de remonter du message)
DELETE FROM x_apps.xapps_geo_v_pei_ctr_erreur WHERE id_pei = old.id_pei;
INSERT INTO x_apps.xapps_geo_v_pei_ctr_erreur VALUES
(
nextval('x_apps.xapps_geo_v_pei_ctr_erreur_gid_seq'::regclass),
old.id_pei,
'Vous ne pouvez pas modifier un dossier validé.<br> Modifications non prises en compte.',
now()
);

-- si non on peut poursuivre et modifier les informations
ELSE

-- on ne peut pas modifier un contrôle en dehors de Compiègne et Zone de gestion ARC
IF v_gestion = 'OUT' THEN

-- gestion d'écriture d'un message d'erreur dans une table qui remonte dans GEO avec un horodatage pour gére le temps d'affichage (de remonter du message)
DELETE FROM x_apps.xapps_geo_v_pei_ctr_erreur WHERE id_pei = old.id_pei;
INSERT INTO x_apps.xapps_geo_v_pei_ctr_erreur VALUES
(
nextval('x_apps.xapps_geo_v_pei_ctr_erreur_gid_seq'::regclass),
old.id_pei,
'Vous ne pouvez pas modifier un PEI en dehors des zones de gestion ARC et ville de Compiègne.<br> Modifications non prises en compte.',
now()
);


-- si non on peut poursuivre
ELSE

UPDATE

m_defense_incendie.geo_pei

SET

-- dans le cas où la suppression s'applique sur un patrimoine PEI non verouillé et géré par le service, alors l'état du PEI est modifié et passe à "supprimer", dans le cas inverse (verrou ou gestion OUT), alors rien n'est modifié
etat_pei=	CASE WHEN v_gestion = 'OUT' OR v_verrou IS TRUE THEN OLD.etat_pei
		ELSE '03'
		END,

-- dans le cas où la suppression s'applique sur un patrimoine PEI non verouillé et géré par le service, alors la date de mise à jour du PEI est modifié, dans le cas inverse (verrou ou gestion OUT), non
date_maj=	CASE WHEN v_gestion = 'OUT' OR v_verrou IS TRUE THEN OLD.date_maj
		ELSE now()
		END,

WHERE m_defense_incendie.geo_pei.id_pei = OLD.id_pei;

RETURN NEW;


END IF;
END IF;
END IF;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

									   
COMMENT ON FUNCTION x_apps.ft_xapps_geo_v_pei_ctr() IS 'Fonction trigger de mise à jour de la vue applicative destinée à la modification des données relatives aux PEI et aux contrôles sur le patrimoine géré par le service mutualisé eau potable et la consultation des autres PEI';


-- Trigger: t_t1_xapps_geo_v_pei_ctr on x_apps.xapps_geo_v_pei_ctr

-- DROP TRIGGER t_t1_xapps_geo_v_pei_ctr ON x_apps.xapps_geo_v_pei_ctr;

CREATE TRIGGER t_t1_xapps_geo_v_pei_ctr
  INSTEAD OF INSERT OR UPDATE OR DELETE
  ON x_apps.xapps_geo_v_pei_ctr
  FOR EACH ROW
  EXECUTE PROCEDURE x_apps.ft_xapps_geo_v_pei_ctr();
