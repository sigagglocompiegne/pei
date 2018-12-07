/*PEI V1.0*/
/*Insertion des valeurs dans les listes*/
/* pei_31_insert.sql */
/*PostGIS*/

/* Propriétaire : GeoCompiegnois - http://geo.compiegnois.fr/ */
/* Auteur : FLorent Vanhoutte */
/* Participant : Grégory Bodet */

-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                DOMAINES DE VALEURS                                                           ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################


-- ################################################################# Domaine valeur - type_pei  ###############################################


INSERT INTO m_defense_incendie.lt_pei_type_pei(
            code, valeur, affich)
    VALUES
    ('PI','Poteau d''incendie','1'),
    ('BI','Prise d''eau sous pression, notamment bouche d''incendie','2'),
    ('PA','Point d''aspiration aménagé (point de puisage)','3'),
    ('CI','Citerne aérienne ou enterrée','4'),  
    ('NR','Non renseigné','5');



-- ################################################################# Domaine valeur - diam_pei  ###############################################

INSERT INTO m_defense_incendie.lt_pei_diam_pei(
            code, valeur)
    VALUES
    ('80','80'),
    ('100','100'),
    ('150','150'),  
    ('0','Non renseigné');
    

-- ################################################################# Domaine valeur - source_pei  ###############################################

INSERT INTO m_defense_incendie.lt_pei_source_pei(
            code, valeur, code_open)
    VALUES
    ('CI','Citerne','citerne'),
    ('PE','Plan d''eau','plan_eau'),
    ('PU','Puit','puits'),
    ('CE','Cours d''eau','cours_eau'),
    ('AEP','Réseau AEP','reseau_aep'),
    ('IRR','Réseau d''irrigation','reseau_irrigation'),
    ('PIS','Piscine','piscine'),      
    ('NR','Non renseigné',NULL);



-- ################################################################# Domaine valeur - statut_pei  ###############################################

INSERT INTO m_defense_incendie.lt_pei_statut(
            code, valeur, code_open)
    VALUES
    ('01','Public','public'),
    ('02','Privé','prive'),
    ('00','Non renseigné',NULL);
    
    

-- ################################################################# Domaine valeur - gestionnaire  ###############################################

INSERT INTO m_defense_incendie.lt_pei_gestion(
            code, valeur)
    VALUES
    ('01','Etat'),
    ('02','Région'),
    ('03','Département'),
    ('04','Intercommunalité'),
    ('05','Commune'),
    ('06','Office HLM'),
    ('07','Privé'),
    ('99','Autre'), 
    ('ZZ','Non concerné'),  
    ('00','Non renseigné');


-- ################################################################# Domaine valeur - etat_pei  ###############################################

INSERT INTO m_defense_incendie.lt_pei_etat_pei(
            code, valeur)
    VALUES
    ('01','Projet'),
    ('02','Existant'),
    ('03','Supprimé'),
    ('00','Non renseigné');
    
    
-- ################################################################# Domaine valeur - cs_sdis  ###############################################

INSERT INTO m_defense_incendie.lt_pei_cs_sdis(
            code, valeur)
    VALUES
    ('00000','Non renseigné'),
    ('60159','CS de Compiègne'),
    ('60068','CS de Béthisy-Saint-Pierre'),
    ('60636','CS de Thourotte'),
    ('60667','CS de Verberie'),
    ('60025','CS d''Attichy'),
    ('60223','CS d''Estrées-Saint-Denis'),
    ('60509','CS de Pont-Sainte-Maxence');


-- ################################################################# Domaine valeur - pei_etat_boolean  ###############################################

INSERT INTO m_defense_incendie.lt_pei_etat_boolean(
            code, valeur, code_open)
    VALUES
    ('0','Non renseigné',NULL),
    ('t','Oui','1'),
    ('f','Non','0');


-- ################################################################# Domaine valeur - anomalie  ###############################################

INSERT INTO m_defense_incendie.lt_pei_anomalie(
            code, valeur, csq_acces, csq_sign, csq_conf)
    VALUES
    ('01','Manque bouchon','0','0','0'),
    ('02','Manque capot ou capot HS','0','0','0'),
    ('03','Manque de débit ou volume','0','0','1'),
    ('04','Manque de signalisation','0','1','0'),
    ('05','Problème d''accès','1','0','1'),
    ('06','Ouverture point d''eau difficile','0','0','0'),
    ('07','Fuite hydrant','0','0','0'),
    ('08','Manque butée sur la vis d''ouverture','0','0','0'),
    ('09','Purge HS','0','0','0'),
    ('10','Pas d''écoulement d''eau','0','0','1'),
    ('11','Végétation génante','0','0','0'),
    ('12','Gêne accès extérieur','1','0','0'),
    ('13','Equipement à remplacer','0','0','0'),   
    ('14','Hors service','0','0','1'),
    ('15','Manque d''eau (uniquement citerne ou point d''aspiration)','0','0','1');



-- ################################################################# Domaine valeur ouvert - id_contrat  ###############################################

ALTER TABLE m_defense_incendie.lt_pei_id_contrat ALTER COLUMN code SET DEFAULT to_char(nextval('m_defense_incendie.lt_pei_id_contrat_seq'::regclass),'FM00');

INSERT INTO m_defense_incendie.lt_pei_id_contrat(
            code, valeur, definition)
    VALUES
    ('00','Non renseigné',NULL),
    ('ZZ','Non concerné',NULL),
    (to_char(nextval('m_defense_incendie.lt_pei_id_contrat_seq'::regclass),'FM00'),'Compiègne n°37/2018','Contrat PEI de la ville de Compiègne'),
    (to_char(nextval('m_defense_incendie.lt_pei_id_contrat_seq'::regclass),'FM00'),'ARC n°30/2018','Contrat PEI de l''Agglomération de Compiègne');


-- ################################################################# Domaine valeur ouvert - marque  ###############################################

ALTER TABLE m_defense_incendie.lt_pei_marque ALTER COLUMN code SET DEFAULT to_char(nextval('m_defense_incendie.lt_pei_marque_seq'::regclass),'FM00');

INSERT INTO m_defense_incendie.lt_pei_marque(
            code, valeur)
    VALUES
    ('00','Non renseigné' ),
    (to_char(nextval('m_defense_incendie.lt_pei_marque_seq'::regclass),'FM00'),'Bayard'),
    (to_char(nextval('m_defense_incendie.lt_pei_marque_seq'::regclass),'FM00'),'Pont-à-Mousson'),
    (to_char(nextval('m_defense_incendie.lt_pei_marque_seq'::regclass),'FM00'),'AVK');


-- ################################################################# Domaine valeur ouvert - delegataire  ###############################################

ALTER TABLE m_defense_incendie.lt_pei_delegat ALTER COLUMN code SET DEFAULT to_char(nextval('m_defense_incendie.lt_pei_delegat_seq'::regclass),'FM00');

INSERT INTO m_defense_incendie.lt_pei_delegat(
            code, valeur)
    VALUES
    ('00','Non renseigné' ),
    (to_char(nextval('m_defense_incendie.lt_pei_delegat_seq'::regclass),'FM00'),'Suez'),
    (to_char(nextval('m_defense_incendie.lt_pei_delegat_seq'::regclass),'FM00'),'Saur'),
    (to_char(nextval('m_defense_incendie.lt_pei_delegat_seq'::regclass),'FM00'),'Veolia');


-- ################################################################# Domaine valeur ouvert - raccord  ###############################################

ALTER TABLE m_defense_incendie.lt_pei_raccord ALTER COLUMN code SET DEFAULT to_char(nextval('m_defense_incendie.lt_pei_raccord_seq'::regclass),'FM00');

INSERT INTO m_defense_incendie.lt_pei_raccord(
            code, valeur)
    VALUES
    ('00','Non renseigné' ),
    (to_char(nextval('m_defense_incendie.lt_pei_raccord_seq'::regclass),'FM00'),'1x100'),
    (to_char(nextval('m_defense_incendie.lt_pei_raccord_seq'::regclass),'FM00'),'1x65'),
    (to_char(nextval('m_defense_incendie.lt_pei_raccord_seq'::regclass),'FM00'),'1x100 - 2x65'),
    (to_char(nextval('m_defense_incendie.lt_pei_raccord_seq'::regclass),'FM00'),'2x100 - 1x65'),
    (to_char(nextval('m_defense_incendie.lt_pei_raccord_seq'::regclass),'FM00'),'3x100'),
    (to_char(nextval('m_defense_incendie.lt_pei_raccord_seq'::regclass),'FM00'),'1x65 - 2x40');

-- ################################################################# Domaine valeur - src_geom  ###############################################

-- Type d'énumération urbanisé et présent dans le schéma r_objet
-- Voir table r_objet.lt_src_geom
