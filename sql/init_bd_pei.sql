/*
  
  dépendances : voir script d'initialisation des dépendances init_bd_pei_dependencies.sql
  
  Liste des dépendances :
  schéma          | table                 | description                                                   | usage
  r_objet         | lt_src_geom           | domaine de valeur générique d'une table géographique          | source du positionnement du PEI
  r_administratif | an_geo                | donnée de référence alphanumérique du découpage administratif | jointure insee commune<>siret epci
  r_osm           | geo_v_osm_commune_apc | vue de la donnée geo_osm_commune restreinte sur le secteur du compiégnois| insee + controle de saisie PEI à l'intérieur de ce périmètre
  --->   r_osm           | geo_osm_commune       | donnée de référence géographique du découpage communal OSM    | 
  r_osm           | geo_osm_epci          | donnée de référence géographique du découpage epci OSM        | nom de l'EPCI   
*/

/*
#################################################################### SUIVI CODE SQL ####################################################################
2018-01-10 : FV / initialisation du code pour la classe PEI avec comme point de départ l'état à cette date des réflexions sur le format d'échanges AFIGEO + besoin interne ARC pour les contrôles
2018-01-10 : FV / initialisation du code pour certains domaines de valeur et fkey liées
2018-01-16 : FV / ajout variable état d'actualité du PEI (projet, existant, supprimé)
2018-01-?? : FV / confirmation interne sur l'absence de besoin d'historisation des info de controles, seul le dernier leur apparait pertinent.
2018-01-25 : FV / modification de terminologie, debit_gb = debit_max, press_resi = pression_dyn
2018-01-25 : FV / séparation PEI volet patrimonial du volet controle
2018-01-26 : FV / fonction trigger et trigger pour les 2 classes d'objet
2018-01-26 : FV / gestion controle de la saisie dans les triggers
2018-01-29 : FV / ajout attributs et modif liées (trigger) pour les etats d'anomalies, d'accès et de signalisation des PEI dans la classe an_pei_ctr
2018-01-30 : FV / modif suite à réunion du GT AFIGEO du 29/01 avec ajout d'une vue pour les échanges selon le format AFIGEO
2018-01-31 : FV / ajout attribut complémentaire sur la source du dernier controle technique (ope_ct)
2018-02-01 : FV / ajout attribut "marque" et "cs_sdis" (centre de secours SDIS) pour la partie patrimoniale et "presta_ct" (nom du prestataire en charge du dernier CT) côté mesures et controle. Confirmation que le débit de remplissage pour les citernes releve des mesures 
2018-02-02 : FV / ajout domaine de valeur pour cs_sdis, changement du nom du schéma pour m_defense_incendie
2018-02-06 : FV / changement des types boolean en texte. Contrainte fonctionnel GEO qui ne permet pas les valeurs NULL pour ce type informatique contrairement à la base postgres. Valeur NULL nécessaire pour traiter les cas de PEI nouveau (projet) n'ayant pas fait l'objet de controle
2018-02-06 : FV / ajout d'une contrainte fonction trigger restreignant la mise à jour dans une même commune (éviter prb d'héritage d'id_sdis, cs_sdis ...)
2018-02-07 : FV / intégration donnée sur les zones de défense de 200m autour des PEI (statut=public, disponible=oui et etat=existant). Fonction trigger insert et update OK, delete NON (réglé le 12/02)
2018-02-07 : FV / test de création d'une table d'audit sur la base de données PEI
2018-02-12 : FV / modif sur zone de défense, attribut geom1 en plus dans la classe geo_pei + vue geo_v_pei_buffer uniquement pour les PEI 'public/existant/disponible'
2018-02-12 : FV / ajout d'un attribut etat_conf dans la classe an_pei_ctr pour gérer la notion statique (info technique datant du controle) pour séparer avec l'attribut disponibilité qui lui gère une approche dynamique (conformité technique + ancienneté du contrôle)'
2018-02-13 : FV / fusion fonction trigger ft_geo_pei et ft_an_pei_ctr en 1 seule fonction trigger + correction fonction trigger d'insert pour la détermination de la disponibilité du PEI pour la DECI
2018-02-19 : FV / stockage v openpei dans le schéma dédié (x_opendata)
2018-02-19 : FV / ajout liste de domaine anomalies, l'attribut correspondant étant une concaténation des anomalies présentes dans la liste
2018-02-20 : FV / gestion des "blancs" dans les triggers comme des valeurs NULL pour plusieurs champs texte 
2018-02-20 : FV / disponibilite et date_dispo calculé directement dans la vue et non sauvegarder dans les classes d'objet source. Ceci est rendu nécessaire l'approche dynamique de la disponibilité du PEI à la DECI (jour J et pas seulement un recalcul en cas d'insert ou d'update d'une entité)
2018-02-22 : FV / ajout variable insee dans la vue de zone de défense incendie pour gérer les droits applicatifs de consultation 
2018-02-23 : FV / test de gestion du controle de la saisie des conformités lorsque l'attribut anomalie est non NULL (variables à déclarer dans le trigger pour pouvoir exploiter les résultats issus des calculs au lieu des saisies formulaires utilisateurs)
2018-02-27 : FV / ajout domaine de valeur ouvert lt_pei_marque, lt_pei_raccord, lt_pei_delegat et quelques changements mineurs (libelle et ordre de champs), 
2018-02-28 : FV / correctifs sur les controles croisés et la remise à 0 de valeur sans logique selon le type de PEI, 
2018-03-01 : FV / correctifs sur les controles croisés
2018-03-27 : FV / correctifs mineurs des commentaires sur les tables
2018-04-03 : FV / evolutions importantes suite à reunion avec le service métier (saisie par le prestataire, validation par le service)
2018-04-03 : FV / modif opendata en vue geo au lieu de alpha, modif classe valeur anomalie pour y intégrer les contraintes à lire par le trigger
2018-04-09 : FV / modifs classe objet suite à diffusion de la version définitive du modèle AFIGEO
2018-04-10 : FV / modifs pour gestion interne : ajout champs "id_contrat", "ct_valid" ; ajout domaine de valeur ouvert "lt_pei_id_contrat"
2018-04-10 : FV / ajout vue applicative pour gestion des données. Cette gestion est différentiée entre celles entrant le patrimoine du service et les autres. Pour ces dernières, le trigger ne permet qu'un changement sur le gestionnaire du PEI (gestion) permettant de faire entrer le PEI dans le patrimoine du service
2018-05-15 : FV / correctif bug maj id_sdis malgré le verrou
2018-05-17 : FV / correctif sur les controles croisés des mesures/contrôles pour déterminer la conformité technique du PEI
2018-06-12 : FV / implémentation des évolutions du modèle suite à réunion AFIGEO du 11/06/2018
2018-08-07 : GB / Intégrationn des nouveaux rôles de connexion et des privilèges associés
2018-11-05 : FV / Améliorations diverses et réorganisation du séquensage du code sql
2018-11-09 : GB / Modification des vues xapps_geo_v_pei_ctr et geo_v_pei_ctr pour optimisation (modification des jointures, suppression du champ geom1 (ne sert à rien ici) et modification du trigger dans la mise à jour de geom1
2018-11-10 : GB / Intégration de la gestion des messages d'erreurs retournée à GEO (création d'une table d'erreur et intégration de contrôles dans le trigger de la vue applicative)
2018-11-19 : GB / Modification table des anomalies (ajout d'une anomalie pour gérer le cas des citernes et point d'aspiration en manque d'eau
             GB / Adaptation du trigger sur l'etat_conf pour prendre en compte cette anomalie qui génère une non-conformité

Généralités sur le domaine métier PEI

GRILLE DES PARAMETRES DE MESURES (ET DE CONTROLE POUR LA CONFORMITE) EN FONCTION DU TYPE DE PEI
type PI/BI ---- param de mesures = debit, pression
type CI ---- param de mesures = volume, debit remplissage
type PA ---- source cour d'eau ---- pas de param de mesures
           ----    autre source   ---- param de mesures = volume, debit remplissage
ToDo
voir pour traiter les controles lors de l'insert
pour domaine de valeur ouvert, voir pour soit faire trigger pour controle de la saisie ou alors gérer la case dans la valeur par défaut
ajout attribut dynamique (vue) qui contient l'ancienneté du contrôle
gérer les cas d'anomalies et de conformité impossible (fct trigger) (diff controle entre PI/BI et CI ou PA)
voir pour générer une table des parcelles bâties (habitat) non couvertes par la DECI. partie éco à charge des entreprises
 
*/



-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                        DROP                                                                  ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################



-- vue
DROP VIEW IF EXISTS m_defense_incendie.geo_v_pei_ctr;
DROP VIEW IF EXISTS m_defense_incendie.geo_v_pei_zonedefense;
DROP VIEW IF EXISTS x_apps.xapps_geo_v_pei_ctr;
DROP VIEW IF EXISTS x_apps.xapps_geo_v_pei_zonedefense;
DROP VIEW IF EXISTS x_opendata.xopendata_geo_v_open_pei;
-- fkey
ALTER TABLE m_defense_incendie.geo_pei DROP CONSTRAINT IF EXISTS lt_pei_type_pei_fkey;
ALTER TABLE m_defense_incendie.geo_pei DROP CONSTRAINT IF EXISTS lt_pei_diam_pei_fkey;
ALTER TABLE m_defense_incendie.geo_pei DROP CONSTRAINT IF EXISTS lt_pei_source_pei_fkey;
ALTER TABLE m_defense_incendie.geo_pei DROP CONSTRAINT IF EXISTS lt_pei_statut_fkey;
ALTER TABLE m_defense_incendie.geo_pei DROP CONSTRAINT IF EXISTS lt_pei_gestion_fkey;
ALTER TABLE m_defense_incendie.geo_pei DROP CONSTRAINT IF EXISTS lt_pei_etat_pei_fkey;
ALTER TABLE m_defense_incendie.geo_pei DROP CONSTRAINT IF EXISTS lt_pei_cs_sdis_fkey;
ALTER TABLE m_defense_incendie.geo_pei DROP CONSTRAINT IF EXISTS lt_pei_marque_fkey;
ALTER TABLE m_defense_incendie.geo_pei DROP CONSTRAINT IF EXISTS lt_pei_raccord_fkey;
ALTER TABLE m_defense_incendie.geo_pei DROP CONSTRAINT IF EXISTS lt_pei_delegat_fkey;
ALTER TABLE m_defense_incendie.geo_pei DROP CONSTRAINT IF EXISTS lt_pei_src_geom_fkey;
ALTER TABLE m_defense_incendie.an_pei_ctr DROP CONSTRAINT IF EXISTS lt_pei_id_contrat_fkey;
ALTER TABLE m_defense_incendie.an_pei_ctr DROP CONSTRAINT lt_pei_etat_anom_fkey;
ALTER TABLE m_defense_incendie.an_pei_ctr DROP CONSTRAINT lt_pei_etat_acces_fkey;
ALTER TABLE m_defense_incendie.an_pei_ctr DROP CONSTRAINT lt_pei_etat_sign_fkey;
ALTER TABLE m_defense_incendie.an_pei_ctr DROP CONSTRAINT lt_pei_etat_conf_fkey; 
-- classe
DROP TABLE IF EXISTS m_defense_incendie.an_pei_ctr;
DROP TABLE IF EXISTS m_defense_incendie.geo_pei;
DROP TABLE IF EXISTS m_defense_incendie.log_pei;
-- domaine de valeur
DROP TABLE IF EXISTS m_defense_incendie.lt_pei_anomalie;
DROP TABLE IF EXISTS m_defense_incendie.lt_pei_cs_sdis;
DROP TABLE IF EXISTS m_defense_incendie.lt_pei_delegat;
DROP TABLE IF EXISTS m_defense_incendie.lt_pei_diam_pei;
DROP TABLE IF EXISTS m_defense_incendie.lt_pei_etat_boolean;
DROP TABLE IF EXISTS m_defense_incendie.lt_pei_etat_pei;
DROP TABLE IF EXISTS m_defense_incendie.lt_pei_gestion;
DROP TABLE IF EXISTS m_defense_incendie.lt_pei_id_contrat;
DROP TABLE IF EXISTS m_defense_incendie.lt_pei_marque;
DROP TABLE IF EXISTS m_defense_incendie.lt_pei_raccord;
DROP TABLE IF EXISTS m_defense_incendie.lt_pei_source_pei;
DROP TABLE IF EXISTS m_defense_incendie.lt_pei_statut;
DROP TABLE IF EXISTS m_defense_incendie.lt_pei_type_pei;
-- sequence
DROP SEQUENCE IF EXISTS m_defense_incendie.geo_pei_id_seq;
DROP SEQUENCE IF EXISTS m_defense_incendie.log_pei_id_seq;
DROP SEQUENCE IF EXISTS m_defense_incendie.lt_pei_delegat_seq;
DROP SEQUENCE IF EXISTS m_defense_incendie.lt_pei_id_contrat_seq;
DROP SEQUENCE IF EXISTS m_defense_incendie.lt_pei_marque_seq;
DROP SEQUENCE IF EXISTS m_defense_incendie.lt_pei_raccord_seq;

/*

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



-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                DOMAINES DE VALEURS                                                           ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################


-- ################################################################# Domaine valeur - type_pei  ###############################################

-- Table: m_defense_incendie.lt_pei_type_pei

-- DROP TABLE m_defense_incendie.lt_pei_type_pei;

CREATE TABLE m_defense_incendie.lt_pei_type_pei
(
  code character varying(2) NOT NULL,
  valeur character varying(80) NOT NULL,
  affich character varying(1) NOT NULL,
  CONSTRAINT lt_pei_type_pei_pkey PRIMARY KEY (code)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE m_defense_incendie.lt_pei_type_pei
  OWNER TO sig_create;
GRANT SELECT ON TABLE m_defense_incendie.lt_pei_type_pei TO read_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_defense_incendie.lt_pei_type_pei TO edit_sig;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_type_pei TO create_sig;

COMMENT ON TABLE m_defense_incendie.lt_pei_type_pei
  IS 'Code permettant de décrire le type de point d''eau incendie';
COMMENT ON COLUMN m_defense_incendie.lt_pei_type_pei.code IS 'Code de la liste énumérée relative au type de PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_type_pei.valeur IS 'Valeur de la liste énumérée relative au type de PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_type_pei.affich IS 'Ordre d''affichage de la liste énumérée relative au type de PEI';

INSERT INTO m_defense_incendie.lt_pei_type_pei(
            code, valeur, affich)
    VALUES
    ('PI','Poteau d''incendie','1'),
    ('BI','Prise d''eau sous pression, notamment bouche d''incendie','2'),
    ('PA','Point d''aspiration aménagé (point de puisage)','3'),
    ('CI','Citerne aérienne ou enterrée','4'),  
    ('NR','Non renseigné','5');



-- ################################################################# Domaine valeur - diam_pei  ###############################################

-- Table: m_defense_incendie.lt_pei_diam_pei

-- DROP TABLE m_defense_incendie.lt_pei_diam_pei;

CREATE TABLE m_defense_incendie.lt_pei_diam_pei
(
  code integer NOT NULL,
  valeur character varying(80) NOT NULL,
  CONSTRAINT lt_pei_diam_pei_pkey PRIMARY KEY (code)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE m_defense_incendie.lt_pei_diam_pei
  OWNER TO sig_create;
GRANT SELECT ON TABLE m_defense_incendie.lt_pei_diam_pei TO read_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_defense_incendie.lt_pei_diam_pei TO edit_sig;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_diam_pei TO create_sig;

COMMENT ON TABLE m_defense_incendie.lt_pei_diam_pei
  IS 'Code permettant de décrire le diamètre intérieur du point d''eau incendie (poteau ou bouche)';
COMMENT ON COLUMN m_defense_incendie.lt_pei_diam_pei.code IS 'Code de la liste énumérée relative au diamètre intérieur du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_diam_pei.valeur IS 'Valeur de la liste énumérée relative au diamètre intérieur du PEI';

INSERT INTO m_defense_incendie.lt_pei_diam_pei(
            code, valeur)
    VALUES
    ('80','80'),
    ('100','100'),
    ('150','150'),  
    ('0','Non renseigné');
    

-- ################################################################# Domaine valeur - source_pei  ###############################################

-- Table: m_defense_incendie.lt_pei_source_pei

-- DROP TABLE m_defense_incendie.lt_pei_source_pei;

CREATE TABLE m_defense_incendie.lt_pei_source_pei
(
  code character varying(3) NOT NULL,
  valeur character varying(80) NOT NULL,
  code_open character varying(30),
  CONSTRAINT lt_pei_source_pei_pkey PRIMARY KEY (code)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE m_defense_incendie.lt_pei_source_pei
  OWNER TO sig_create;
GRANT SELECT ON TABLE m_defense_incendie.lt_pei_source_pei TO read_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_defense_incendie.lt_pei_source_pei TO edit_sig;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_source_pei TO create_sig;

COMMENT ON TABLE m_defense_incendie.lt_pei_source_pei
  IS 'Code permettant de décrire le type de source d''alimentation du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_source_pei.code IS 'Code de la liste énumérée relative au type de source d''alimentation du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_source_pei.valeur IS 'Valeur de la liste énumérée relative au type de source d''alimentation du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_source_pei.code_open IS 'Code pour les exports opendata de la liste énumérée relative au type de source d''alimentation du PEI';

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

-- Table: m_defense_incendie.lt_pei_statut

-- DROP TABLE m_defense_incendie.lt_pei_statut;

CREATE TABLE m_defense_incendie.lt_pei_statut
(
  code character varying(2) NOT NULL,
  valeur character varying(80) NOT NULL,
  code_open character varying(10),
  CONSTRAINT lt_pei_statut_pkey PRIMARY KEY (code)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE m_defense_incendie.lt_pei_statut
  OWNER TO sig_create;
GRANT SELECT ON TABLE m_defense_incendie.lt_pei_statut TO read_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_defense_incendie.lt_pei_statut TO edit_sig;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_statut TO create_sig;

COMMENT ON TABLE m_defense_incendie.lt_pei_statut
  IS 'Code permettant de décrire le statut juridique du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_statut.code IS 'Code de la liste énumérée relative au statut juridique du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_statut.valeur IS 'Valeur de la liste énumérée relative au statut juridique du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_statut.code_open IS 'Code pour les exports opendata de la liste énumérée relative au statut juridique du PEI';

INSERT INTO m_defense_incendie.lt_pei_statut(
            code, valeur, code_open)
    VALUES
    ('01','Public','public'),
    ('02','Privé','prive'),
    ('00','Non renseigné',NULL);
    
    

-- ################################################################# Domaine valeur - gestionnaire  ###############################################

-- Table: m_defense_incendie.lt_pei_gestion

-- DROP TABLE m_defense_incendie.lt_pei_gestion;

CREATE TABLE m_defense_incendie.lt_pei_gestion
(
  code character varying(2) NOT NULL,
  valeur character varying(80) NOT NULL,
  CONSTRAINT lt_pei_gestion_pkey PRIMARY KEY (code)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE m_defense_incendie.lt_pei_gestion
  OWNER TO sig_create;
GRANT SELECT ON TABLE m_defense_incendie.lt_pei_gestion TO read_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_defense_incendie.lt_pei_gestion TO edit_sig;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_gestion TO create_sig;

COMMENT ON TABLE m_defense_incendie.lt_pei_gestion
  IS 'Code permettant de décrire le gestionnaire du point d''eau incendie';
COMMENT ON COLUMN m_defense_incendie.lt_pei_gestion.code IS 'Code de la liste énumérée relative au gestionnaire du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_gestion.valeur IS 'Valeur de la liste énumérée relative au gestionnaire du PEI';

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

-- Table: m_defense_incendie.lt_pei_etat_pei

-- DROP TABLE m_defense_incendie.lt_pei_etat_pei;

CREATE TABLE m_defense_incendie.lt_pei_etat_pei
(
  code character varying(2) NOT NULL,
  valeur character varying(80) NOT NULL,
  CONSTRAINT lt_pei_etat_pei_pkey PRIMARY KEY (code)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE m_defense_incendie.lt_pei_etat_pei
  OWNER TO sig_create;
GRANT SELECT ON TABLE m_defense_incendie.lt_pei_etat_pei TO read_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_defense_incendie.lt_pei_etat_pei TO edit_sig;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_etat_pei TO create_sig;

COMMENT ON TABLE m_defense_incendie.lt_pei_etat_pei
  IS 'Code permettant de décrire l''état d''actualité du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_etat_pei.code IS 'Code de la liste énumérée relative au etat_pei juridique du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_etat_pei.valeur IS 'Valeur de la liste énumérée relative au etat_pei juridique du PEI';

INSERT INTO m_defense_incendie.lt_pei_etat_pei(
            code, valeur)
    VALUES
    ('01','Projet'),
    ('02','Existant'),
    ('03','Supprimé'),
    ('00','Non renseigné');
    
    
-- ################################################################# Domaine valeur - cs_sdis  ###############################################

-- Table: m_defense_incendie.lt_pei_cs_sdis

-- DROP TABLE m_defense_incendie.lt_pei_cs_sdis;

CREATE TABLE m_defense_incendie.lt_pei_cs_sdis
(
  code character varying(5) NOT NULL,
  valeur character varying(80) NOT NULL,
  CONSTRAINT lt_pei_cs_sdis_pkey PRIMARY KEY (code)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE m_defense_incendie.lt_pei_cs_sdis
  OWNER TO sig_create;
GRANT SELECT ON TABLE m_defense_incendie.lt_pei_cs_sdis TO read_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_defense_incendie.lt_pei_cs_sdis TO edit_sig;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_cs_sdis TO create_sig;

COMMENT ON TABLE m_defense_incendie.lt_pei_cs_sdis
  IS 'Code permettant de décrire le nom du centre de secours de 1er appel du SDIS en charge du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_cs_sdis.code IS 'Code de la liste énumérée relative au nom du CS SDIS en charge du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_cs_sdis.valeur IS 'Valeur de la liste énumérée relative au nom du CS SDIS en charge du PEI';

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

-- Table: m_defense_incendie.lt_pei_etat_boolean

-- DROP TABLE m_defense_incendie.lt_pei_etat_boolean;

CREATE TABLE m_defense_incendie.lt_pei_etat_boolean
(
  code character varying(1) NOT NULL,
  valeur character varying(80) NOT NULL,
  code_open character varying(1),
  CONSTRAINT lt_pei_etat_boolean_pkey PRIMARY KEY (code)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE m_defense_incendie.lt_pei_etat_boolean
  OWNER TO sig_create;
GRANT SELECT ON TABLE m_defense_incendie.lt_pei_etat_boolean TO read_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_defense_incendie.lt_pei_etat_boolean TO edit_sig;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_etat_boolean TO create_sig;

COMMENT ON TABLE m_defense_incendie.lt_pei_etat_boolean
  IS 'Code permettant de décrire l''état d''un attribut boolean';
COMMENT ON COLUMN m_defense_incendie.lt_pei_etat_boolean.code IS 'Code de la liste énumérée relative à l''état d''un attribut boolean';
COMMENT ON COLUMN m_defense_incendie.lt_pei_etat_boolean.valeur IS 'Valeur de la liste énumérée relative à l''état d''un attribut boolean';
COMMENT ON COLUMN m_defense_incendie.lt_pei_etat_boolean.code_open IS 'Code pour les exports opendata de la liste énumérée relative à l''état d''un attribut boolean';

INSERT INTO m_defense_incendie.lt_pei_etat_boolean(
            code, valeur, code_open)
    VALUES
    ('0','Non renseigné',NULL),
    ('t','Oui','1'),
    ('f','Non','0');


-- ################################################################# Domaine valeur - anomalie  ###############################################

-- Table: m_defense_incendie.lt_pei_anomalie

-- DROP TABLE m_defense_incendie.lt_pei_anomalie;

CREATE TABLE m_defense_incendie.lt_pei_anomalie
(
  code character varying(2) NOT NULL,
  valeur character varying(80) NOT NULL,
  csq_acces character varying(1) NOT NULL,
  csq_sign character varying(1) NOT NULL,
  csq_conf character varying(1) NOT NULL,  
  CONSTRAINT lt_pei_anomalie_pkey PRIMARY KEY (code)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE m_defense_incendie.lt_pei_anomalie
  OWNER TO sig_create;
GRANT SELECT ON TABLE m_defense_incendie.lt_pei_anomalie TO read_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_defense_incendie.lt_pei_anomalie TO edit_sig;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_anomalie TO create_sig;

COMMENT ON TABLE m_defense_incendie.lt_pei_anomalie
  IS 'Liste des anomalies possibles pour un PEI et de leurs incidences sur la conformité';
COMMENT ON COLUMN m_defense_incendie.lt_pei_anomalie.code IS 'Code de la liste énumérée relative au type d''anomalie d''un PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_anomalie.valeur IS 'Valeur de la liste énumérée relative au type d''anomalie d''un PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_anomalie.csq_acces IS 'Impact de l''anomalie sur l''état de l''accessibilité du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_anomalie.csq_sign IS 'Impact de l''anomalie sur l''état de la signalisation du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_anomalie.csq_conf IS 'Impact de l''anomalie sur l''état de la conformité technique du PEI';

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

-- Table: m_defense_incendie.lt_pei_id_contrat

-- DROP TABLE m_defense_incendie.lt_pei_id_contrat;

CREATE TABLE m_defense_incendie.lt_pei_id_contrat
(
  code character varying(2) NOT NULL,
  valeur character varying(80) NOT NULL,
  definition character varying(254),
  CONSTRAINT lt_pei_id_contrat_pkey PRIMARY KEY (code)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE m_defense_incendie.lt_pei_id_contrat
  OWNER TO sig_create;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_id_contrat TO sig_create;
GRANT SELECT ON TABLE m_defense_incendie.lt_pei_id_contrat TO read_sig;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE m_defense_incendie.lt_pei_id_contrat TO edit_sig;
COMMENT ON TABLE m_defense_incendie.lt_pei_id_contrat
  IS 'Code permettant de décrire un contrat pour l''entretien et de contrôle de PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_id_contrat.code IS 'Code de la liste énumérée relative au numéro de contrat pour l''entretien et de contrôle de PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_id_contrat.valeur IS 'Valeur de la référence du marché du contrat pour l''entretien et de contrôle de PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_id_contrat.definition IS 'Definition du contrat pour l''entretien et de contrôle de PEI';




-- Sequence: m_defense_incendie.lt_pei_id_contrat_seq

-- DROP SEQUENCE m_defense_incendie.lt_pei_id_contrat_seq;

CREATE SEQUENCE m_defense_incendie.lt_pei_id_contrat_seq
  INCREMENT 1
  MINVALUE 0
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;
ALTER TABLE m_defense_incendie.lt_pei_id_contrat_seq
  OWNER TO sig_create;
GRANT ALL ON SEQUENCE m_defense_incendie.lt_pei_id_contrat_seq TO sig_create;
GRANT SELECT, USAGE ON SEQUENCE m_defense_incendie.lt_pei_id_contrat_seq TO public;
ALTER TABLE m_defense_incendie.lt_pei_id_contrat ALTER COLUMN code SET DEFAULT to_char(nextval('m_defense_incendie.lt_pei_id_contrat_seq'::regclass),'FM00');

INSERT INTO m_defense_incendie.lt_pei_id_contrat(
            code, valeur, definition)
    VALUES
    ('00','Non renseigné',NULL),
    ('ZZ','Non concerné',NULL),
    (to_char(nextval('m_defense_incendie.lt_pei_id_contrat_seq'::regclass),'FM00'),'Compiègne n°37/2018','Contrat PEI de la ville de Compiègne'),
    (to_char(nextval('m_defense_incendie.lt_pei_id_contrat_seq'::regclass),'FM00'),'ARC n°30/2018','Contrat PEI de l''Agglomération de Compiègne');


-- ################################################################# Domaine valeur ouvert - marque  ###############################################

-- Table: m_defense_incendie.lt_pei_marque

-- DROP TABLE m_defense_incendie.lt_pei_marque;

CREATE TABLE m_defense_incendie.lt_pei_marque
(
  code character varying(2) NOT NULL,
  valeur character varying(80) NOT NULL,
  CONSTRAINT lt_pei_marque_pkey PRIMARY KEY (code)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE m_defense_incendie.lt_pei_marque
  OWNER TO sig_create;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_marque TO sig_create;
GRANT SELECT ON TABLE m_defense_incendie.lt_pei_marque TO read_sig;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE m_defense_incendie.lt_pei_marque TO edit_sig;
COMMENT ON TABLE m_defense_incendie.lt_pei_marque
  IS 'Code permettant de décrire la marque du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_marque.code IS 'Code de la liste énumérée relative à la marque du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_marque.valeur IS 'Valeur de la liste énumérée relative à la marque du PEI';



-- Sequence: m_defense_incendie.lt_pei_marque_seq

-- DROP SEQUENCE m_defense_incendie.lt_pei_marque_seq;

CREATE SEQUENCE m_defense_incendie.lt_pei_marque_seq
  INCREMENT 1
  MINVALUE 0
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;
ALTER TABLE m_defense_incendie.lt_pei_marque_seq
  OWNER TO sig_create;
GRANT ALL ON SEQUENCE m_defense_incendie.lt_pei_marque_seq TO sig_create;
GRANT SELECT, USAGE ON SEQUENCE m_defense_incendie.lt_pei_marque_seq TO public;
ALTER TABLE m_defense_incendie.lt_pei_marque ALTER COLUMN code SET DEFAULT to_char(nextval('m_defense_incendie.lt_pei_marque_seq'::regclass),'FM00');

INSERT INTO m_defense_incendie.lt_pei_marque(
            code, valeur)
    VALUES
    ('00','Non renseigné' ),
    (to_char(nextval('m_defense_incendie.lt_pei_marque_seq'::regclass),'FM00'),'Bayard'),
    (to_char(nextval('m_defense_incendie.lt_pei_marque_seq'::regclass),'FM00'),'Pont-à-Mousson'),
    (to_char(nextval('m_defense_incendie.lt_pei_marque_seq'::regclass),'FM00'),'AVK');


-- ################################################################# Domaine valeur ouvert - delegataire  ###############################################

-- Table: m_defense_incendie.lt_pei_delegat

-- DROP TABLE m_defense_incendie.lt_pei_delegat;

CREATE TABLE m_defense_incendie.lt_pei_delegat
(
  code character varying(2) NOT NULL,
  valeur character varying(80) NOT NULL,
  CONSTRAINT lt_pei_delegat_pkey PRIMARY KEY (code)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE m_defense_incendie.lt_pei_delegat
  OWNER TO sig_create;
GRANT SELECT ON TABLE m_defense_incendie.lt_pei_delegat TO read_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_defense_incendie.lt_pei_delegat TO edit_sig;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_delegat TO create_sig;

COMMENT ON TABLE m_defense_incendie.lt_pei_delegat
  IS 'Code permettant de décrire le délégataire du réseaux surlequel est lié un PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_delegat.code IS 'Code de la liste énumérée relative au délégataire du réseaux surlequel est lié un PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_delegat.valeur IS 'Valeur de la liste énumérée relative au délégataire du réseaux surlequel est lié un PEI';


-- Sequence: m_defense_incendie.lt_pei_delegat_seq

-- DROP SEQUENCE m_defense_incendie.lt_pei_delegat_seq;

CREATE SEQUENCE m_defense_incendie.lt_pei_delegat_seq
  INCREMENT 1
  MINVALUE 0
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;
ALTER TABLE m_defense_incendie.lt_pei_delegat_seq
  OWNER TO sig_create;
GRANT ALL ON SEQUENCE m_defense_incendie.lt_pei_delegat_seq TO sig_create;
GRANT SELECT, USAGE ON SEQUENCE m_defense_incendie.lt_pei_delegat_seq TO public;
ALTER TABLE m_defense_incendie.lt_pei_delegat ALTER COLUMN code SET DEFAULT to_char(nextval('m_defense_incendie.lt_pei_delegat_seq'::regclass),'FM00');

INSERT INTO m_defense_incendie.lt_pei_delegat(
            code, valeur)
    VALUES
    ('00','Non renseigné' ),
    (to_char(nextval('m_defense_incendie.lt_pei_delegat_seq'::regclass),'FM00'),'Suez'),
    (to_char(nextval('m_defense_incendie.lt_pei_delegat_seq'::regclass),'FM00'),'Saur'),
    (to_char(nextval('m_defense_incendie.lt_pei_delegat_seq'::regclass),'FM00'),'Veolia');


-- ################################################################# Domaine valeur ouvert - raccord  ###############################################

-- Table: m_defense_incendie.lt_pei_raccord

-- DROP TABLE m_defense_incendie.lt_pei_raccord;

CREATE TABLE m_defense_incendie.lt_pei_raccord
(
  code character varying(2) NOT NULL,
  valeur character varying(80) NOT NULL,
  CONSTRAINT lt_pei_raccord_pkey PRIMARY KEY (code)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE m_defense_incendie.lt_pei_raccord
  OWNER TO sig_create;
GRANT SELECT ON TABLE m_defense_incendie.lt_pei_raccord TO read_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_defense_incendie.lt_pei_raccord TO edit_sig;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_raccord TO create_sig;

COMMENT ON TABLE m_defense_incendie.lt_pei_raccord
  IS 'Code permettant de décrire le type de raccord du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_raccord.code IS 'Code de la liste énumérée relative au type de raccord du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_raccord.valeur IS 'Valeur de la liste énumérée relative au type de raccord du PEI';


-- Sequence: m_defense_incendie.lt_pei_raccord_seq

-- DROP SEQUENCE m_defense_incendie.lt_pei_raccord_seq;

CREATE SEQUENCE m_defense_incendie.lt_pei_raccord_seq
  INCREMENT 1
  MINVALUE 0
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;
ALTER TABLE m_defense_incendie.lt_pei_raccord_seq
  OWNER TO sig_create;
GRANT ALL ON SEQUENCE m_defense_incendie.lt_pei_raccord_seq TO sig_create;
GRANT SELECT, USAGE ON SEQUENCE m_defense_incendie.lt_pei_raccord_seq TO public;

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



 
  
-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                      CLASSES                                                                 ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################



-- #################################################################### Point d'eau incendie ####################################################  
  
-- Table: m_defense_incendie.geo_pei

-- DROP TABLE m_defense_incendie.geo_pei;

CREATE TABLE m_defense_incendie.geo_pei
(
  id_pei bigint NOT NULL, 
  id_sdis character varying(254),
  verrou boolean NOT NULL DEFAULT false,
  ref_terr character varying(254), 
  insee character varying(5) NOT NULL, 
  type_pei character varying(2) NOT NULL,
  type_rd character varying(254),
  diam_pei integer,
  raccord character varying(2),
  marque character varying(2),
  source_pei character varying(3),
  volume integer,
  diam_cana integer,
  etat_pei character varying(2),
  statut character varying(2),
  nom_etab character varying(254),
  gestion character varying(2), 
  delegat character varying(2),
  cs_sdis character varying(5),
  situation character varying(254),
  observ character varying(254),
  photo_url character varying(254),
  src_pei character varying(254),
  x_l93 numeric(8,2) NOT NULL,
  y_l93 numeric(9,2) NOT NULL,
  src_geom character varying(2) NOT NULL DEFAULT '00' ::bpchar,
  src_date character varying(4) NOT NULL DEFAULT '0000' ::bpchar,
  prec character varying(5) NOT NULL,
  ope_sai character varying(254),
  date_sai timestamp without time zone NOT NULL DEFAULT now(),  
  date_maj timestamp without time zone,
  geom geometry(Point,2154),
  geom1 geometry(Polygon,2154),

  CONSTRAINT geo_pei_pkey PRIMARY KEY (id_pei),
  CONSTRAINT geo_sdis_ukey UNIQUE (id_sdis)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE m_defense_incendie.geo_pei
  OWNER TO sig_create;
GRANT SELECT ON TABLE m_defense_incendie.geo_pei TO read_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_defense_incendie.geo_pei TO edit_sig;
GRANT ALL ON TABLE m_defense_incendie.geo_pei TO create_sig;

COMMENT ON TABLE m_defense_incendie.geo_pei
  IS 'Classe décrivant un point d''eau incendie';
COMMENT ON COLUMN m_defense_incendie.geo_pei.id_pei IS 'Identifiant unique du PEI';
COMMENT ON COLUMN m_defense_incendie.geo_pei.id_sdis IS 'Identifiant unique du PEI du SDIS';
COMMENT ON COLUMN m_defense_incendie.geo_pei.verrou IS 'Entitée figée en modification';
COMMENT ON COLUMN m_defense_incendie.geo_pei.ref_terr IS 'Référence du PEI sur le terrain';
COMMENT ON COLUMN m_defense_incendie.geo_pei.insee IS 'Code INSEE';
COMMENT ON COLUMN m_defense_incendie.geo_pei.type_pei IS 'Type de PEI';
COMMENT ON COLUMN m_defense_incendie.geo_pei.type_rd IS 'Type de PEI selon la nomenclature du réglement départemental';
COMMENT ON COLUMN m_defense_incendie.geo_pei.diam_pei IS 'Diamètre intérieur du PEI (PI et BI)';
COMMENT ON COLUMN m_defense_incendie.geo_pei.raccord IS 'Descriptif des raccords de sortie du PEI (nombre et diamètres exprimés en mm)';
COMMENT ON COLUMN m_defense_incendie.geo_pei.marque IS 'Marque du fabriquant du PEI';
COMMENT ON COLUMN m_defense_incendie.geo_pei.source_pei IS 'Source du point d''eau';
COMMENT ON COLUMN m_defense_incendie.geo_pei.volume IS 'Capacité volumique utile de la source d''eau en m3/h. Si la source est inépuisable (cour d''eau ou plan d''eau pérenne), l''information est nulle';
COMMENT ON COLUMN m_defense_incendie.geo_pei.diam_cana IS 'Diamètre de la canalisation exprimé en mm pour les PI et BI';
COMMENT ON COLUMN m_defense_incendie.geo_pei.etat_pei IS 'Etat d''actualité du PEI';
COMMENT ON COLUMN m_defense_incendie.geo_pei.statut IS 'Statut juridique';
COMMENT ON COLUMN m_defense_incendie.geo_pei.nom_etab IS 'Dans le cas d''un PEI de statut privé, nom de l''établissement propriétaire';
COMMENT ON COLUMN m_defense_incendie.geo_pei.gestion IS 'Gestionnaire du PEI';
COMMENT ON COLUMN m_defense_incendie.geo_pei.delegat IS 'Délégataire du réseau pour les PI et BI';
COMMENT ON COLUMN m_defense_incendie.geo_pei.cs_sdis IS 'Code INSEE du centre de secours du SDIS en charge du volet opérationnel';
COMMENT ON COLUMN m_defense_incendie.geo_pei.situation IS 'Adresse ou information permettant de faciliter la localisation du PEI sur le terrain';
COMMENT ON COLUMN m_defense_incendie.geo_pei.observ IS 'Observations';
COMMENT ON COLUMN m_defense_incendie.geo_pei.photo_url IS 'Lien vers une photo du PEI';                                                                                                 
COMMENT ON COLUMN m_defense_incendie.geo_pei.src_pei IS 'Organisme source de l''information PEI';
COMMENT ON COLUMN m_defense_incendie.geo_pei.x_l93 IS 'Coordonnée X en mètre';
COMMENT ON COLUMN m_defense_incendie.geo_pei.y_l93 IS 'Coordonnée Y en mètre';
COMMENT ON COLUMN m_defense_incendie.geo_pei.src_geom IS 'Référentiel de saisie';
COMMENT ON COLUMN m_defense_incendie.geo_pei.src_date IS 'Année du millésime du référentiel de saisie';
COMMENT ON COLUMN m_defense_incendie.geo_pei.prec IS 'Précision cartographique exprimée en cm';
COMMENT ON COLUMN m_defense_incendie.geo_pei.ope_sai IS 'Opérateur de la dernière saisie en base de l''objet';
COMMENT ON COLUMN m_defense_incendie.geo_pei.date_sai IS 'Horodatage de l''intégration en base de l''objet';
COMMENT ON COLUMN m_defense_incendie.geo_pei.date_maj IS 'Horodatage de la mise à jour en base de l''objet';
COMMENT ON COLUMN m_defense_incendie.geo_pei.geom IS 'Géomètrie ponctuelle de l''objet';
COMMENT ON COLUMN m_defense_incendie.geo_pei.geom1 IS 'Géomètrie de la zone de defense incendie de l''objet PEI';

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

-- Sequence: m_defense_incendie.geo_pei_id_seq

-- DROP SEQUENCE m_defense_incendie.geo_pei_id_seq;

CREATE SEQUENCE m_defense_incendie.geo_pei_id_seq
  INCREMENT 1
  MINVALUE 0
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;
ALTER TABLE m_defense_incendie.geo_pei_id_seq
  OWNER TO sig_create;
GRANT ALL ON SEQUENCE m_defense_incendie.geo_pei_id_seq TO sig_create;
GRANT SELECT, USAGE ON SEQUENCE m_defense_incendie.geo_pei_id_seq TO public;

ALTER TABLE m_defense_incendie.geo_pei ALTER COLUMN id_pei SET DEFAULT nextval('m_defense_incendie.geo_pei_id_seq'::regclass);




-- ####################################################################  Mesures et controles des points d'eau incendie ####################################################  
  
-- Table: m_defense_incendie.an_pei_ctr

-- DROP TABLE m_defense_incendie.an_pei_ctr;

CREATE TABLE m_defense_incendie.an_pei_ctr
(
  id_pei bigint NOT NULL, 
  id_sdis character varying(254),
  id_contrat character varying(254),
  press_stat real,
  press_dyn real,
  debit real,
  debit_max real,
  debit_r_ci real,
  etat_anom character varying(1) NOT NULL,
  lt_anom character varying(254),
  etat_acces character varying(1) NOT NULL,
  etat_sign character varying(1) NOT NULL,
  etat_conf character varying(1) NOT NULL,
  date_mes date,
  date_ct date,
  ope_ct character varying(254),
  date_ro date
)
WITH (
  OIDS=FALSE
);
ALTER TABLE m_defense_incendie.an_pei_ctr
  OWNER TO sig_create;
GRANT SELECT ON TABLE m_defense_incendie.an_pei_ctr TO read_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_defense_incendie.an_pei_ctr TO edit_sig;
GRANT ALL ON TABLE m_defense_incendie.an_pei_ctr TO create_sig;

COMMENT ON TABLE m_defense_incendie.an_pei_ctr
  IS 'Classe décrivant le contrôle d''un point d''eau incendie';
COMMENT ON COLUMN m_defense_incendie.an_pei_ctr.id_pei IS 'Identifiant unique du PEI';
COMMENT ON COLUMN m_defense_incendie.an_pei_ctr.id_sdis IS 'Identifiant unique du PEI du SDIS';
COMMENT ON COLUMN m_defense_incendie.an_pei_ctr.id_contrat IS 'Référence du contrat de prestation pour le contrôle technique du PEI';
COMMENT ON COLUMN m_defense_incendie.an_pei_ctr.press_stat IS 'Pression statique en bar à un débit de 0 m3/h';
COMMENT ON COLUMN m_defense_incendie.an_pei_ctr.press_dyn IS 'Pression dynamique résiduelle en bar à un débit de 60 m3/h';
COMMENT ON COLUMN m_defense_incendie.an_pei_ctr.debit IS 'Valeur de débit mesuré exprimé en m3/h sous une pression de 1 bar';
COMMENT ON COLUMN m_defense_incendie.an_pei_ctr.debit_max IS 'Valeur de débit maximal à gueule bée mesuré exprimé en m3/h';
COMMENT ON COLUMN m_defense_incendie.an_pei_ctr.debit_r_ci IS 'Valeur de débit de remplissage pour les CI en m3/h';
COMMENT ON COLUMN m_defense_incendie.an_pei_ctr.etat_anom IS 'Etat d''anomalies du PEI';
COMMENT ON COLUMN m_defense_incendie.an_pei_ctr.lt_anom IS 'Liste des anomalies du PEI';
COMMENT ON COLUMN m_defense_incendie.an_pei_ctr.etat_acces IS 'Etat de l''accessibilité du PEI';
COMMENT ON COLUMN m_defense_incendie.an_pei_ctr.etat_sign IS 'Etat de la signalisation du PEI';
COMMENT ON COLUMN m_defense_incendie.an_pei_ctr.etat_conf IS 'Etat de la conformité technique du PEI';
COMMENT ON COLUMN m_defense_incendie.an_pei_ctr.date_mes IS 'Date de mise en service du PEI (correspond à la date du premier contrôle débit-pression effectué sur le terrain)';
COMMENT ON COLUMN m_defense_incendie.an_pei_ctr.date_ct IS 'Date du dernier contrôle';
COMMENT ON COLUMN m_defense_incendie.an_pei_ctr.ope_ct IS 'Opérateur du dernier contrôle';
COMMENT ON COLUMN m_defense_incendie.an_pei_ctr.date_ro IS 'Date de la dernière reconnaissance opérationnelle';                                                                                                   



-- #################################################################### LOG BASE DE DONNEES PEI ####################################################  
  
-- Table: m_defense_incendie.log_pei

-- DROP TABLE m_defense_incendie.log_pei;

CREATE TABLE m_defense_incendie.log_pei
(
  id_audit bigint NOT NULL,
  type_ope text NOT NULL,
  ope_sai character varying(254),
  id_pei bigint NOT NULL,
  date_maj timestamp without time zone NOT NULL,

  CONSTRAINT log_pei_pkey PRIMARY KEY (id_audit)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE m_defense_incendie.log_pei
  OWNER TO sig_create;
GRANT SELECT ON TABLE m_defense_incendie.log_pei TO read_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_defense_incendie.log_pei TO edit_sig;
GRANT ALL ON TABLE m_defense_incendie.log_pei TO create_sig;

COMMENT ON TABLE m_defense_incendie.log_pei
  IS 'Table d''audit des opérations sur la base de données PEI';
COMMENT ON COLUMN m_defense_incendie.log_pei.id_audit IS 'Identifiant unique de l''opération de base PEI';
COMMENT ON COLUMN m_defense_incendie.log_pei.type_ope IS 'Type d''opération intervenue sur la base PEI';
COMMENT ON COLUMN m_defense_incendie.log_pei.ope_sai IS 'Utilisateur ayant effectuée l''opération sur la base PEI';
COMMENT ON COLUMN m_defense_incendie.log_pei.id_pei IS 'Identifiant du PEI concerné par l''opération sur la base PEI';
COMMENT ON COLUMN m_defense_incendie.log_pei.date_maj IS 'Horodatage de l''opération sur la base PEI';

-- Sequence: m_defense_incendie.log_pei_id_seq

-- DROP SEQUENCE m_defense_incendie.log_pei_id_seq;

CREATE SEQUENCE m_defense_incendie.log_pei_id_seq
  INCREMENT 1
  MINVALUE 0
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;
ALTER TABLE m_defense_incendie.log_pei_id_seq
  OWNER TO sig_create;
GRANT ALL ON SEQUENCE m_defense_incendie.log_pei_id_seq TO sig_create;
GRANT SELECT, USAGE ON SEQUENCE m_defense_incendie.log_pei_id_seq TO public;
ALTER TABLE m_defense_incendie.log_pei ALTER COLUMN id_audit SET DEFAULT nextval('m_defense_incendie.log_pei_id_seq'::regclass);


-- #################################################################### ERREUR MESSAGE PEI ####################################################  
  

-- Table: x_apps.xapps_geo_v_pei_ctr_erreur

-- DROP TABLE x_apps.xapps_geo_v_pei_ctr_erreur;

CREATE TABLE x_apps.xapps_geo_v_pei_ctr_erreur
(
  gid integer NOT NULL, -- Identifiant unique
  id_pei integer, -- Identifiant du PEI
  erreur character varying(500), -- Message
  horodatage timestamp without time zone, -- Date (avec heure) de génération du message (ce champ permet de filtrer l'affichage < x seconds dans GEo)
  CONSTRAINT xapps_geo_v_pei_ctr_erreur_pkey PRIMARY KEY (gid)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE x_apps.xapps_geo_v_pei_ctr_erreur
  OWNER TO sig_create;
GRANT ALL ON TABLE x_apps.xapps_geo_v_pei_ctr_erreur TO sig_create;
GRANT ALL ON TABLE x_apps.xapps_geo_v_pei_ctr_erreur TO create_sig;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE x_apps.xapps_geo_v_pei_ctr_erreur TO edit_sig;
GRANT SELECT ON TABLE x_apps.xapps_geo_v_pei_ctr_erreur TO read_sig;
COMMENT ON TABLE x_apps.xapps_geo_v_pei_ctr_erreur
  IS 'Table gérant les messages d''erreurs de sécurité remontés dans GEO suite à des enregistrements de contrôle PEI';
COMMENT ON COLUMN x_apps.xapps_geo_v_pei_ctr_erreur.gid IS 'Identifiant unique';
COMMENT ON COLUMN x_apps.xapps_geo_v_pei_ctr_erreur.id_pei IS 'Identifiant du PEI';
COMMENT ON COLUMN x_apps.xapps_geo_v_pei_ctr_erreur.erreur IS 'Message';
COMMENT ON COLUMN x_apps.xapps_geo_v_pei_ctr_erreur.horodatage IS 'Date (avec heure) de génération du message (ce champ permet de filtrer l''affichage < x seconds dans GEo)';

    

-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                        FKEY                                                                  ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################



-- ************ GEO_PEI ************ 

-- Foreign Key: m_defense_incendie.lt_pei_type_pei_fkey

-- ALTER TABLE m_defense_incendie.geo_pei DROP CONSTRAINT lt_pei_type_pei_fkey;

ALTER TABLE m_defense_incendie.geo_pei
  ADD CONSTRAINT lt_pei_type_pei_fkey FOREIGN KEY (type_pei)
      REFERENCES m_defense_incendie.lt_pei_type_pei (code) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;


-- Foreign Key: m_defense_incendie.lt_pei_diam_pei_fkey

-- ALTER TABLE m_defense_incendie.geo_pei DROP CONSTRAINT lt_pei_diam_pei_fkey;

ALTER TABLE m_defense_incendie.geo_pei
  ADD CONSTRAINT lt_pei_diam_pei_fkey FOREIGN KEY (diam_pei)
      REFERENCES m_defense_incendie.lt_pei_diam_pei (code) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;
      
      
-- Foreign Key: m_defense_incendie.lt_pei_source_pei_fkey

-- ALTER TABLE m_defense_incendie.geo_pei DROP CONSTRAINT lt_pei_source_pei_fkey;

ALTER TABLE m_defense_incendie.geo_pei
  ADD CONSTRAINT lt_pei_source_pei_fkey FOREIGN KEY (source_pei)
      REFERENCES m_defense_incendie.lt_pei_source_pei (code) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;


-- Foreign Key: m_defense_incendie.lt_pei_statut_fkey

-- ALTER TABLE m_defense_incendie.geo_pei DROP CONSTRAINT lt_pei_statut_fkey;

ALTER TABLE m_defense_incendie.geo_pei
  ADD CONSTRAINT lt_pei_statut_fkey FOREIGN KEY (statut)
      REFERENCES m_defense_incendie.lt_pei_statut (code) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;              


-- Foreign Key: m_defense_incendie.lt_pei_gestion_fkey

-- ALTER TABLE m_defense_incendie.geo_pei DROP CONSTRAINT lt_pei_gestion_fkey;

ALTER TABLE m_defense_incendie.geo_pei
  ADD CONSTRAINT lt_pei_gestion_fkey FOREIGN KEY (gestion)
      REFERENCES m_defense_incendie.lt_pei_gestion (code) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;  

-- Foreign Key: m_defense_incendie.lt_pei_etat_pei_fkey

-- ALTER TABLE m_defense_incendie.geo_pei DROP CONSTRAINT lt_pei_etat_pei_fkey;

ALTER TABLE m_defense_incendie.geo_pei
  ADD CONSTRAINT lt_pei_etat_pei_fkey FOREIGN KEY (etat_pei)
      REFERENCES m_defense_incendie.lt_pei_etat_pei (code) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;
      
-- Foreign Key: m_defense_incendie.lt_pei_cs_sdis_fkey

-- ALTER TABLE m_defense_incendie.geo_pei DROP CONSTRAINT lt_pei_cs_sdis_fkey;

ALTER TABLE m_defense_incendie.geo_pei
  ADD CONSTRAINT lt_pei_cs_sdis_fkey FOREIGN KEY (cs_sdis)
      REFERENCES m_defense_incendie.lt_pei_cs_sdis (code) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;
      
-- Foreign Key: m_defense_incendie.lt_pei_marque_fkey

-- ALTER TABLE m_defense_incendie.geo_pei DROP CONSTRAINT lt_pei_marque_fkey;

ALTER TABLE m_defense_incendie.geo_pei
  ADD CONSTRAINT lt_pei_marque_fkey FOREIGN KEY (marque)
      REFERENCES m_defense_incendie.lt_pei_marque (code) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;
      
      
-- Foreign Key: m_defense_incendie.lt_pei_raccord_fkey

-- ALTER TABLE m_defense_incendie.geo_pei DROP CONSTRAINT lt_pei_raccord_fkey;

ALTER TABLE m_defense_incendie.geo_pei
  ADD CONSTRAINT lt_pei_raccord_fkey FOREIGN KEY (raccord)
      REFERENCES m_defense_incendie.lt_pei_raccord (code) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;
      
-- Foreign Key: m_defense_incendie.lt_pei_delegat_fkey

-- ALTER TABLE m_defense_incendie.geo_pei DROP CONSTRAINT lt_pei_delegat_fkey;

ALTER TABLE m_defense_incendie.geo_pei
  ADD CONSTRAINT lt_pei_delegat_fkey FOREIGN KEY (delegat)
      REFERENCES m_defense_incendie.lt_pei_delegat (code) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;            


-- Foreign Key: m_defense_incendie.lt_pei_src_geom_fkey

-- ALTER TABLE m_defense_incendie.geo_pei DROP CONSTRAINT lt_pei_src_geom_fkey;

ALTER TABLE m_defense_incendie.geo_pei
  ADD CONSTRAINT lt_pei_src_geom_fkey FOREIGN KEY (src_geom)
      REFERENCES r_objet.lt_src_geom (code) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;


-- ************ AN_PEI_CTR ************ 


-- Foreign Key: m_defense_incendie.lt_pei_id_contrat_fkey

-- ALTER TABLE m_defense_incendie.an_pei_ctr DROP CONSTRAINT lt_pei_id_contrat_fkey;

ALTER TABLE m_defense_incendie.an_pei_ctr
  ADD CONSTRAINT lt_pei_id_contrat_fkey FOREIGN KEY (id_contrat)
      REFERENCES m_defense_incendie.lt_pei_id_contrat (code) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

-- Foreign Key: m_defense_incendie.lt_pei_etat_anom_fkey

-- ALTER TABLE m_defense_incendie.an_pei_ctr DROP CONSTRAINT lt_pei_etat_anom_fkey;

ALTER TABLE m_defense_incendie.an_pei_ctr
  ADD CONSTRAINT lt_pei_etat_anom_fkey FOREIGN KEY (etat_anom)
      REFERENCES m_defense_incendie.lt_pei_etat_boolean (code) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION; 
      
-- Foreign Key: m_defense_incendie.lt_pei_etat_acces_fkey

-- ALTER TABLE m_defense_incendie.an_pei_ctr DROP CONSTRAINT lt_pei_etat_acces_fkey;

ALTER TABLE m_defense_incendie.an_pei_ctr
  ADD CONSTRAINT lt_pei_etat_acces_fkey FOREIGN KEY (etat_acces)
      REFERENCES m_defense_incendie.lt_pei_etat_boolean (code) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;
      
      
-- Foreign Key: m_defense_incendie.lt_pei_etat_sign_fkey

-- ALTER TABLE m_defense_incendie.an_pei_ctr DROP CONSTRAINT lt_pei_etat_sign_fkey;

ALTER TABLE m_defense_incendie.an_pei_ctr
  ADD CONSTRAINT lt_pei_etat_sign_fkey FOREIGN KEY (etat_sign)
      REFERENCES m_defense_incendie.lt_pei_etat_boolean (code) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;    

-- Foreign Key: m_defense_incendie.lt_pei_etat_conf_fkey

-- ALTER TABLE m_defense_incendie.an_pei_ctr DROP CONSTRAINT lt_pei_etat_conf_fkey;

ALTER TABLE m_defense_incendie.an_pei_ctr
  ADD CONSTRAINT lt_pei_etat_conf_fkey FOREIGN KEY (etat_conf)
      REFERENCES m_defense_incendie.lt_pei_etat_boolean (code) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION; 



-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                        VUES                                                                  ###
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
    a.debit_r_ci,
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
    a.debit_r_ci,
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



-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                      TRIGGER                                                                 ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################


-- #################################################################### FONCTION TRIGGER - GEO_V_PEI_CTR ###################################################

-- Function: m_defense_incendie.ft_geo_v_pei_ctr()

-- DROP FUNCTION m_defense_incendie.ft_geo_v_pei_ctr();

CREATE OR REPLACE FUNCTION m_defense_incendie.ft_geo_v_pei_ctr()
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
INSERT INTO m_defense_incendie.geo_pei (id_pei, id_sdis, verrou, ref_terr, insee, type_pei, type_rd, diam_pei, raccord, marque, source_pei, volume, diam_cana, etat_pei, statut, nom_etab, gestion, delegat, cs_sdis, situation, observ, photo_url, src_pei, x_l93, y_l93, src_geom, src_date, prec, ope_sai, date_sai, date_maj, geom, geom1)
SELECT v_id_pei,
CASE WHEN NEW.id_sdis = '' THEN NULL ELSE NEW.id_sdis END,
NEW.verrou,
CASE WHEN NEW.ref_terr = '' THEN NULL ELSE NEW.ref_terr END,
CASE WHEN NEW.insee IS NULL THEN (SELECT insee FROM r_osm.geo_v_osm_commune_apc WHERE st_intersects(NEW.geom,geom)) ELSE NEW.insee END,
CASE WHEN NEW.type_pei IS NULL THEN 'NR' ELSE NEW.type_pei END,
NEW.type_rd,
CASE WHEN NEW.diam_pei IS NULL THEN 0 ELSE NEW.diam_pei END,
CASE WHEN NEW.raccord IS NULL THEN '00' ELSE NEW.raccord END,
CASE WHEN NEW.marque IS NULL THEN '00' ELSE NEW.marque END,
CASE WHEN NEW.source_pei IS NULL THEN 'NR' ELSE NEW.source_pei END,
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

INSERT INTO m_defense_incendie.an_pei_ctr (id_pei, id_sdis, id_contrat, press_stat, press_dyn, debit, debit_max, debit_r_ci, etat_anom, lt_anom, etat_acces, etat_sign, etat_conf, date_mes, date_ct, ope_ct, date_ro)
SELECT v_id_pei,
NEW.id_sdis,
NEW.id_contrat,
NEW.press_stat,
NEW.press_dyn,
NEW.debit,
NEW.debit_max,
NEW.debit_r_ci,
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
insee=CASE WHEN (SELECT insee FROM r_osm.geo_v_osm_commune_apc WHERE st_intersects(NEW.geom,geom))=OLD.insee THEN OLD.insee ELSE NULL END,
type_pei=CASE WHEN NEW.type_pei IS NULL THEN 'NR' ELSE NEW.type_pei END,
type_rd=NEW.type_rd,
diam_pei=CASE WHEN NEW.diam_pei IS NULL THEN 0 ELSE NEW.diam_pei END,
raccord=CASE WHEN NEW.raccord IS NULL THEN '00' ELSE NEW.raccord END,
marque=CASE WHEN NEW.marque IS NULL THEN '00' ELSE NEW.marque END,
source_pei=CASE WHEN NEW.source_pei IS NULL THEN '00' ELSE NEW.source_pei END,
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
debit_r_ci=CASE WHEN NEW.type_pei IN ('PI','BI') OR (NEW.type_pei = 'PA' AND NEW.source_pei = 'CE') THEN NULL ELSE NEW.debit_r_ci END,
etat_anom=CASE WHEN NEW.etat_anom IS NULL THEN '0' ELSE NEW.etat_anom END,
lt_anom=CASE WHEN NEW.lt_anom = '' OR NEW.etat_anom IN ('0','t') THEN NULL ELSE NEW.lt_anom END,
etat_acces=CASE WHEN NEW.etat_anom = 't' THEN 't' ELSE v_etat_acces END,
etat_sign=CASE WHEN v_lt_anom LIKE '%04%' THEN 'f' ELSE NEW.etat_sign END,
--etat_conf, les pts de controle sont différents selon le type de PEI
etat_conf=CASE WHEN NEW.type_pei IN ('PI','BI') AND (NEW.debit < 60 OR NEW.press_dyn < 1 OR v_lt_anom LIKE '%14%' OR v_lt_anom LIKE '%03%' OR v_lt_anom LIKE '%10%' OR v_etat_acces = 'f') THEN 'f' 
               WHEN NEW.type_pei = 'CI' AND ((NEW.volume BETWEEN 60 AND 120 AND NEW.debit_r_ci < 60) OR NEW.volume < 60 OR v_lt_anom LIKE '%14%' OR v_lt_anom LIKE '%03%' OR v_lt_anom LIKE '%10%' OR v_lt_anom LIKE '%15%' OR v_etat_acces = 'f') THEN 'f' 
               WHEN NEW.type_pei = 'PA' AND NEW.source_pei = 'CE' AND (v_lt_anom LIKE '%14%' OR v_lt_anom LIKE '%03%' OR v_lt_anom LIKE '%10%' OR v_lt_anom LIKE '%15%' OR v_etat_acces = 'f') THEN 'f'
               WHEN NEW.type_pei = 'PA' AND NEW.source_pei != 'CE' AND (v_lt_anom LIKE '%14%' OR v_lt_anom LIKE '%03%' OR v_lt_anom LIKE '%10%' OR v_lt_anom LIKE '%15%' OR v_etat_acces = 'f') THEN 'f'
               WHEN v_gestion = 'IN' AND NEW.type_pei = 'NR' THEN 'f' ELSE 't' END,
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
id_pei=OLD.id_pei,
id_sdis=OLD.id_sdis,
verrou=OLD.verrou,
ref_terr=OLD.ref_terr,
insee=OLD.insee,
type_pei=OLD.type_pei,
type_rd=OLD.type_rd,
diam_pei=OLD.diam_pei,
raccord=OLD.raccord,
marque=OLD.marque,
source_pei=OLD.source_pei,
volume=OLD.volume,
diam_cana=OLD.diam_cana,
etat_pei='03',
statut=OLD.statut,
nom_etab=OLD.nom_etab,
gestion=OLD.gestion,
delegat=OLD.delegat,
cs_sdis=OLD.cs_sdis,
situation=OLD.situation,
observ=OLD.observ,
photo_url=OLD.photo_url,
src_pei=OLD.src_pei,
x_l93=OLD.x_l93,
y_l93=OLD.y_l93,
src_geom=OLD.src_geom,
src_date=OLD.src_date,
prec=OLD.prec,
ope_sai=OLD.ope_sai,
date_sai=OLD.date_sai,
date_maj=now(),
geom=OLD.geom,
geom1=OLD.geom1
WHERE m_defense_incendie.geo_pei.id_pei = OLD.id_pei;

UPDATE
m_defense_incendie.an_pei_ctr
SET
id_pei=OLD.id_pei,
id_sdis=OLD.id_sdis,
id_contrat=NEW.id_contrat,
press_stat=OLD.press_stat,
press_dyn=OLD.press_dyn,
debit=OLD.debit,
debit_max=OLD.debit_max,
debit_r_ci=OLD.debit_r_ci,
etat_anom=OLD.etat_anom,
lt_anom=OLD.lt_anom,
etat_acces=OLD.etat_acces,
etat_sign=OLD.etat_sign,
etat_conf=OLD.etat_conf,
date_mes=OLD.date_mes,
date_ct=OLD.date_ct,
ope_ct=OLD.ope_ct,
date_ro=OLD.date_ro
WHERE m_defense_incendie.an_pei_ctr.id_pei = OLD.id_pei;
RETURN NEW;

END IF;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION m_defense_incendie.ft_geo_v_pei_ctr()
  OWNER TO sig_create;
GRANT EXECUTE ON FUNCTION m_defense_incendie.ft_geo_v_pei_ctr() TO public;
GRANT EXECUTE ON FUNCTION m_defense_incendie.ft_geo_v_pei_ctr() TO sig_create;
GRANT EXECUTE ON FUNCTION m_defense_incendie.ft_geo_v_pei_ctr() TO create_sig;

												    
COMMENT ON FUNCTION  m_defense_incendie.ft_geo_v_pei_ctr() IS 'Fonction trigger pour mise à jour de la vue de gestion des points d''eau incendie et contrôles';



-- Trigger: t_t1_geo_v_pei_ctr on m_defense_incendie.geo_v_pei_ctr

-- DROP TRIGGER t_t1_geo_v_pei_ctr ON m_defense_incendie.geo_v_pei_ctr;

CREATE TRIGGER t_t1_geo_v_pei_ctr
  INSTEAD OF INSERT OR UPDATE OR DELETE
  ON m_defense_incendie.geo_v_pei_ctr
  FOR EACH ROW
  EXECUTE PROCEDURE m_defense_incendie.ft_geo_v_pei_ctr();
  



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

INSERT INTO m_defense_incendie.geo_pei (id_pei, id_sdis, verrou, ref_terr, insee, type_pei, type_rd, diam_pei, raccord, marque, source_pei, volume, diam_cana, etat_pei, statut, nom_etab, gestion, delegat, cs_sdis, situation, observ, photo_url, src_pei, x_l93, y_l93, src_geom, src_date, prec, ope_sai, date_sai, date_maj, geom, geom1)

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

INSERT INTO m_defense_incendie.an_pei_ctr (id_pei, id_sdis, id_contrat, press_stat, press_dyn, debit, debit_max, debit_r_ci, etat_anom, lt_anom, etat_acces, etat_sign, etat_conf, date_mes, date_ct, ope_ct, date_ro)
SELECT v_id_pei,
CASE WHEN NEW.id_sdis = '' THEN NULL ELSE NEW.id_sdis END,
CASE WHEN NEW.id_contrat IS NULL THEN '00' ELSE NEW.id_contrat END,
NEW.press_stat,
NEW.press_dyn,
NEW.debit,
NEW.debit_max,
NEW.debit_r_ci,
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

-- debit_r_ci devient "null" si jamais le type de PEI est PI, BI ou PA pour un cours d'eau (car illimité dans ce cas)
debit_r_ci=	CASE WHEN v_gestion = 'OUT' OR v_verrou IS TRUE THEN OLD.debit_r_ci
		WHEN v_gestion = 'IN' AND (NEW.type_pei IN ('PI','BI') OR (NEW.type_pei = 'PA' AND NEW.source_pei = 'CE')) THEN NULL
		ELSE NEW.debit_r_ci
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
		WHEN v_gestion = 'IN' AND NEW.type_pei = 'CI' AND ((NEW.volume BETWEEN 60 AND 120 AND NEW.debit_r_ci >= 60) OR NEW.volume >= 120) AND (v_lt_anom ='' OR v_lt_anom IS NULL OR (v_lt_anom NOT LIKE '%03%' AND v_lt_anom NOT LIKE '%05%' AND v_lt_anom NOT LIKE '%10%' AND v_lt_anom NOT LIKE '%14%' AND v_lt_anom NOT LIKE '%15%') ) THEN 't' 
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

id_pei=		OLD.id_pei,

id_sdis=	OLD.id_sdis,

verrou=		OLD.verrou,

ref_terr=	OLD.ref_terr,

insee=		OLD.insee,

type_pei=	OLD.type_pei,

type_rd=	OLD.type_rd,

diam_pei=	OLD.diam_pei,

raccord=	OLD.raccord,

marque=		OLD.marque,

source_pei=		OLD.source_pei,

volume=		OLD.volume,

diam_cana=	OLD.diam_cana,

-- dans le cas où la suppression s'applique sur un patrimoine PEI non verouillé et géré par le service, alors l'état du PEI est modifié et passe à "supprimer", dans le cas inverse (verrou ou gestion OUT), alors rien n'est modifié
etat_pei=	CASE WHEN v_gestion = 'OUT' OR v_verrou IS TRUE THEN OLD.etat_pei
		ELSE '03'
		END,

statut=		OLD.statut,

nom_etab= OLD.nom_etab,

gestion=	OLD.gestion,

delegat=	OLD.delegat,

cs_sdis=	OLD.cs_sdis,

situation=	OLD.situation,

observ=		OLD.observ,

photo_url=	OLD.photo_url,

src_pei=	OLD.src_pei,

x_l93=		OLD.x_l93,

y_l93=		OLD.y_l93,

src_geom=	OLD.src_geom,

src_date=	OLD.src_date,

prec=		OLD.prec,

ope_sai=	OLD.ope_sai,

date_sai=	OLD.date_sai,

-- dans le cas où la suppression s'applique sur un patrimoine PEI non verouillé et géré par le service, alors la date de mise à jour du PEI est modifié, dans le cas inverse (verrou ou gestion OUT), non
date_maj=	CASE WHEN v_gestion = 'OUT' OR v_verrou IS TRUE THEN OLD.date_maj
		ELSE now()
		END,

geom=		OLD.geom,

geom1=		OLD.geom1

WHERE m_defense_incendie.geo_pei.id_pei = OLD.id_pei;

UPDATE

m_defense_incendie.an_pei_ctr

SET

id_pei=		OLD.id_pei,
id_sdis=	OLD.id_sdis,
id_contrat=	OLD.id_contrat,
press_stat=	OLD.press_stat,
press_dyn=	OLD.press_dyn,
debit=		OLD.debit,
debit_max=	OLD.debit_max,
debit_r_ci=	OLD.debit_r_ci,
etat_anom=	OLD.etat_anom,
lt_anom=	OLD.lt_anom,
etat_acces=	OLD.etat_acces,
etat_sign=	OLD.etat_sign,
etat_conf=	OLD.etat_conf,
date_mes=	OLD.date_mes,
date_ct=	OLD.date_ct,
ope_ct=		OLD.ope_ct,
date_ro=	OLD.date_ro

WHERE m_defense_incendie.an_pei_ctr.id_pei = OLD.id_pei;

RETURN NEW;


END IF;
END IF;
END IF;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION x_apps.ft_xapps_geo_v_pei_ctr()
  OWNER TO sig_create;
GRANT EXECUTE ON FUNCTION x_apps.ft_xapps_geo_v_pei_ctr() TO public;
GRANT EXECUTE ON FUNCTION x_apps.ft_xapps_geo_v_pei_ctr() TO sig_create;
GRANT EXECUTE ON FUNCTION x_apps.ft_xapps_geo_v_pei_ctr() TO create_sig;
									   
COMMENT ON FUNCTION x_apps.ft_xapps_geo_v_pei_ctr() IS 'Fonction trigger de mise à jour de la vue applicative destinée à la modification des données relatives aux PEI et aux contrôles sur le patrimoine géré par le service mutualisé eau potable et la consultation des autres PEI';


-- Trigger: t_t1_xapps_geo_v_pei_ctr on x_apps.xapps_geo_v_pei_ctr

-- DROP TRIGGER t_t1_xapps_geo_v_pei_ctr ON x_apps.xapps_geo_v_pei_ctr;

CREATE TRIGGER t_t1_xapps_geo_v_pei_ctr
  INSTEAD OF INSERT OR UPDATE OR DELETE
  ON x_apps.xapps_geo_v_pei_ctr
  FOR EACH ROW
  EXECUTE PROCEDURE x_apps.ft_xapps_geo_v_pei_ctr();






-- #################################################################### FONCTION TRIGGER - LOG_PEI ###################################################

-- Function: m_defense_incendie.ft_log_pei()

-- DROP FUNCTION m_defense_incendie.ft_log_pei();

CREATE OR REPLACE FUNCTION m_defense_incendie.ft_log_pei()
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
ALTER FUNCTION m_defense_incendie.ft_log_pei()
  OWNER TO sig_create;
GRANT EXECUTE ON FUNCTION m_defense_incendie.ft_log_pei() TO public;
GRANT EXECUTE ON FUNCTION m_defense_incendie.ft_log_pei() TO sig_create;
GRANT EXECUTE ON FUNCTION m_defense_incendie.ft_log_pei() TO create_sig;
									   
COMMENT ON FUNCTION m_defense_incendie.ft_log_pei() IS 'audit';


-- Trigger: m_defense_incendie.t_log_pei on m_defense_incendie.geo_v_pei_ctr

-- DROP TRIGGER m_defense_incendie.t_log_pei ON m_defense_incendie.geo_v_pei_ctr;

CREATE TRIGGER t_t2_log_pei
  INSTEAD OF INSERT OR UPDATE OR DELETE
  ON m_defense_incendie.geo_v_pei_ctr
  FOR EACH ROW
  EXECUTE PROCEDURE m_defense_incendie.ft_log_pei();
  
  
-- Trigger: x_apps.t_t2_log_pei on x_apps.xapps_geo_v_pei_ctr

-- DROP TRIGGER x_apps.t_t2_log_pei ON x_apps.xapps_geo_v_pei_ctr;

CREATE TRIGGER t_t2_log_pei
  INSTEAD OF INSERT OR UPDATE OR DELETE
  ON x_apps.xapps_geo_v_pei_ctr
  FOR EACH ROW
  EXECUTE PROCEDURE m_defense_incendie.ft_log_pei();  
