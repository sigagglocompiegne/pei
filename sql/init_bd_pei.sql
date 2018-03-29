/*
  
  dépendances : voir script d'initialisation des dépendances init_bd_pei_dependencies.sql
  
  Liste des dépendances :
  schéma          | table                 | description                                                   | usage
  r_objet         | lt_src_geom           | domaine de valeur générique d'une table géographique          | source du positionnement du PEI
  r_administratif | an_geo                | donnée de référence alphanumérique du découpage administratif | jointure insee commune<>siret epci
  r_osm           | geo_osm_commune       | donnée de référence géographique du découpage communal OSM    | nom de la commune
  r_osm           | geo_v_osm_commune_apc | vue de la donnée geo_osm_commune restreinte sur le secteur du compiégnois| insee + controle de saisie PEI à l'intérieur de ce périmètre
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
2018-03-29 : FV / 

GRILLE DES PARAMETRES DE MESURES (ET DE CONTROLE POUR LA CONFORMITE) EN FONCTION DU TYPE DE PEI
type PI/BI ---- param de mesures = debit, pression
type CI ---- param de mesures = volume, debit remplissage
type PA ---- source cour d'eau ---- pas de param de mesures
           ----    autre source   ---- param de mesures = volume, debit remplissage

ToDo

voir pour traiter les controles lors de l'insert
pour domaine de valeur ouvert, voir pour soit faire trigger pour controle de la saisie ou alors gérer la case dans la valeur par défaut
ajout attribut dynamique (vue) qui contient l'ancienneté du contrôle
voir pour faire des listes de domaine ouverte pour ope_ctr / prestataire_ctr / source données ...
gérer les cas d'anomalies et de conformité impossible (fct trigger) (diff controle entre PI/BI et CI ou PA)
voir pour générer une table des parcelles bâties (habitat) non couvertes par la DECI. partie éco à charge des entreprises
 
*/

-- #################################################################### SCHEMA  ####################################################################

-- Schema: m_defense_incendie

-- DROP SCHEMA m_defense_incendie;

CREATE SCHEMA m_defense_incendie
  AUTHORIZATION postgres;

GRANT ALL ON SCHEMA r_objet TO postgres;
GRANT ALL ON SCHEMA r_objet TO groupe_sig WITH GRANT OPTION;
COMMENT ON SCHEMA m_defense_incendie
  IS 'Données géographiques métiers sur le thème de la défense incendie';
 
  
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
  insee character varying(5) NOT NULL, 
  type_pei character varying(2) NOT NULL,
  type_rd character varying(254),
  diam_pei character varying(3),
  raccord character varying(2),
  marque character varying(2),
  source character varying(3),
  volume integer,
  diam_cana integer,
  etat_pei character varying(2),
  statut character varying(2),
  gestion character varying(2),
  delegat character varying(2),
  cs_sdis character varying(5),
  position character varying(254),
  observ character varying(254),
  photo_url character varying(254),
  src_pei character varying(254),
  x_l93 numeric(8,2) NOT NULL,
  y_l93 numeric(9,2) NOT NULL,
  src_geom character varying(2) NOT NULL DEFAULT '00' ::bpchar,
  src_date character varying(4) NOT NULL DEFAULT '0000' ::bpchar,
  "precision" character varying(5) NOT NULL,
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
  OWNER TO postgres;
GRANT ALL ON TABLE m_defense_incendie.geo_pei TO postgres;
GRANT ALL ON TABLE m_defense_incendie.geo_pei TO groupe_sig WITH GRANT OPTION;
COMMENT ON TABLE m_defense_incendie.geo_pei
  IS 'Classe décrivant un point d''eau incendie';
COMMENT ON COLUMN m_defense_incendie.geo_pei.id_pei IS 'Identifiant unique du PEI';
COMMENT ON COLUMN m_defense_incendie.geo_pei.id_sdis IS 'Identifiant unique du PEI du SDIS';
COMMENT ON COLUMN m_defense_incendie.geo_pei.insee IS 'Code INSEE';
COMMENT ON COLUMN m_defense_incendie.geo_pei.type_pei IS 'Type de PEI';
COMMENT ON COLUMN m_defense_incendie.geo_pei.type_rd IS '***** ';
COMMENT ON COLUMN m_defense_incendie.geo_pei.diam_pei IS 'Diamètre intérieur du PEI';
COMMENT ON COLUMN m_defense_incendie.geo_pei.raccord IS 'Descriptif des raccords de sortie du PEI (nombre et diamètres exprimés en mm)';
COMMENT ON COLUMN m_defense_incendie.geo_pei.marque IS 'Marque du fabriquant du PEI';
COMMENT ON COLUMN m_defense_incendie.geo_pei.source IS 'Source du point d''eau';
COMMENT ON COLUMN m_defense_incendie.geo_pei.volume IS 'Capacité volumique utile de la source d''eau en m3/h. Si la source est inépuisable (cour d''eau ou plan d''eau pérenne), l''information est nulle';
COMMENT ON COLUMN m_defense_incendie.geo_pei.diam_cana IS 'Diamètre de la canalisation exprimé en mm pour les PI et BI';
COMMENT ON COLUMN m_defense_incendie.geo_pei.etat_pei IS 'Etat d''actualité du PEI';
COMMENT ON COLUMN m_defense_incendie.geo_pei.statut IS 'Statut juridique';
COMMENT ON COLUMN m_defense_incendie.geo_pei.gestion IS 'Gestionnaire du PEI';
COMMENT ON COLUMN m_defense_incendie.geo_pei.delegat IS 'Délégataire du réseau pour les PI et BI';
COMMENT ON COLUMN m_defense_incendie.geo_pei.cs_sdis IS 'Code INSEE du centre de secours du SDIS en charge du volet opérationnel';
COMMENT ON COLUMN m_defense_incendie.geo_pei.position IS 'Adresse ou information permettant de faciliter la localisation du PEI sur le terrain';
COMMENT ON COLUMN m_defense_incendie.geo_pei.observ IS 'Observations';
COMMENT ON COLUMN m_defense_incendie.geo_pei.photo_url IS 'Lien vers une photo du PEI';                                                                                                 
COMMENT ON COLUMN m_defense_incendie.geo_pei.src_pei IS 'Organisme source de l''information PEI';
COMMENT ON COLUMN m_defense_incendie.geo_pei.x_l93 IS 'Coordonnée X en mètre';
COMMENT ON COLUMN m_defense_incendie.geo_pei.y_l93 IS 'Coordonnée Y en mètre';
COMMENT ON COLUMN m_defense_incendie.geo_pei.src_geom IS 'Référentiel de saisie';
COMMENT ON COLUMN m_defense_incendie.geo_pei.src_date IS 'Année du millésime du référentiel de saisie';
COMMENT ON COLUMN m_defense_incendie.geo_pei."precision" IS 'Précision cartographique exprimée en cm';
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
  OWNER TO postgres;
GRANT ALL ON SEQUENCE m_defense_incendie.geo_pei_id_seq TO postgres;
GRANT ALL ON SEQUENCE m_defense_incendie.geo_pei_id_seq TO groupe_sig WITH GRANT OPTION;
ALTER TABLE m_defense_incendie.geo_pei ALTER COLUMN id_pei SET DEFAULT nextval('m_defense_incendie.geo_pei_id_seq'::regclass);




-- ####################################################################  Mesures et controles des points d'eau incendie ####################################################  
  
-- Table: m_defense_incendie.an_pei_ctr

-- DROP TABLE m_defense_incendie.an_pei_ctr;

CREATE TABLE m_defense_incendie.an_pei_ctr
(
  id_pei bigint NOT NULL, 
  id_sdis character varying(254),
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
  presta_ct character varying(254),
  date_co date
)
WITH (
  OIDS=FALSE
);
ALTER TABLE m_defense_incendie.an_pei_ctr
  OWNER TO postgres;
GRANT ALL ON TABLE m_defense_incendie.an_pei_ctr TO postgres;
GRANT ALL ON TABLE m_defense_incendie.an_pei_ctr TO groupe_sig WITH GRANT OPTION;
COMMENT ON TABLE m_defense_incendie.an_pei_ctr
  IS 'Classe décrivant le contrôle d''un point d''eau incendie';
COMMENT ON COLUMN m_defense_incendie.an_pei_ctr.id_pei IS 'Identifiant unique du PEI';
COMMENT ON COLUMN m_defense_incendie.an_pei_ctr.id_sdis IS 'Identifiant unique du PEI du SDIS';
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
COMMENT ON COLUMN m_defense_incendie.an_pei_ctr.presta_ct IS 'Prestataire du dernier contrôle';
COMMENT ON COLUMN m_defense_incendie.an_pei_ctr.date_co IS 'Date de la dernière reconnaissance opérationnelle';                                                                                                   



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
  OWNER TO postgres;
GRANT ALL ON TABLE m_defense_incendie.log_pei TO postgres;
GRANT ALL ON TABLE m_defense_incendie.log_pei TO groupe_sig WITH GRANT OPTION;
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
  OWNER TO postgres;
GRANT ALL ON SEQUENCE m_defense_incendie.log_pei_id_seq TO postgres;
GRANT ALL ON SEQUENCE m_defense_incendie.log_pei_id_seq TO groupe_sig WITH GRANT OPTION;
ALTER TABLE m_defense_incendie.log_pei ALTER COLUMN id_audit SET DEFAULT nextval('m_defense_incendie.log_pei_id_seq'::regclass);




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
  OWNER TO postgres;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_type_pei TO postgres;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_type_pei TO groupe_sig WITH GRANT OPTION;
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
  code character varying(3) NOT NULL,
  valeur character varying(80) NOT NULL,
  CONSTRAINT lt_pei_diam_pei_pkey PRIMARY KEY (code)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE m_defense_incendie.lt_pei_diam_pei
  OWNER TO postgres;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_diam_pei TO postgres;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_diam_pei TO groupe_sig WITH GRANT OPTION;
COMMENT ON TABLE m_defense_incendie.lt_pei_diam_pei
  IS 'Code permettant de décrire le diamètre intérieur du point d''eau incendie';
COMMENT ON COLUMN m_defense_incendie.lt_pei_diam_pei.code IS 'Code de la liste énumérée relative au diamètre intérieur du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_diam_pei.valeur IS 'Valeur de la liste énumérée relative au diamètre intérieur du PEI';

INSERT INTO m_defense_incendie.lt_pei_diam_pei(
            code, valeur)
    VALUES
    ('80','80'),
    ('100','100'),
    ('150','150'),  
    ('NR','Non renseigné');
    

-- ################################################################# Domaine valeur - source  ###############################################

-- Table: m_defense_incendie.lt_pei_source

-- DROP TABLE m_defense_incendie.lt_pei_source;

CREATE TABLE m_defense_incendie.lt_pei_source
(
  code character varying(3) NOT NULL,
  valeur character varying(80) NOT NULL,
  code_open character varying(30),
  CONSTRAINT lt_pei_source_pkey PRIMARY KEY (code)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE m_defense_incendie.lt_pei_source
  OWNER TO postgres;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_source TO postgres;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_source TO groupe_sig WITH GRANT OPTION;
COMMENT ON TABLE m_defense_incendie.lt_pei_source
  IS 'Code permettant de décrire le type de source d''alimentation du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_source.code IS 'Code de la liste énumérée relative au type de source d''alimentation du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_source.valeur IS 'Valeur de la liste énumérée relative au type de source d''alimentation du PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_source.code_open IS 'Code pour les exports opendata de la liste énumérée relative au type de source d''alimentation du PEI';

INSERT INTO m_defense_incendie.lt_pei_source(
            code, valeur, code_open)
    VALUES
    ('CI','Citerne','citerne'),
    ('PE','Plan d''eau','plan_eau'),
    ('PU','Puit','puits'),
    ('CE','Cours d''eau','cours_eau'),
    ('AEP','Réseau AEP','reseau_aep'),
    ('IRR','Réseau d''irrigation','reseau_irrigation'),      
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
  OWNER TO postgres;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_statut TO postgres;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_statut TO groupe_sig WITH GRANT OPTION;
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
  OWNER TO postgres;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_gestion TO postgres;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_gestion TO groupe_sig WITH GRANT OPTION;
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
  OWNER TO postgres;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_etat_pei TO postgres;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_etat_pei TO groupe_sig WITH GRANT OPTION;
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
  OWNER TO postgres;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_cs_sdis TO postgres;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_cs_sdis TO groupe_sig WITH GRANT OPTION;
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


-- ################################################################# Domaine valeur - pei_etat  ###############################################

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
  OWNER TO postgres;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_etat_boolean TO postgres;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_etat_boolean TO groupe_sig WITH GRANT OPTION;
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
  CONSTRAINT lt_pei_anomalie_pkey PRIMARY KEY (code)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE m_defense_incendie.lt_pei_anomalie
  OWNER TO postgres;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_anomalie TO postgres;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_anomalie TO groupe_sig WITH GRANT OPTION;
COMMENT ON TABLE m_defense_incendie.lt_pei_anomalie
  IS 'Liste des anomalies possibles pour un PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_anomalie.code IS 'Code de la liste énumérée relative au type d''anomalie d''un PEI';
COMMENT ON COLUMN m_defense_incendie.lt_pei_anomalie.valeur IS 'Valeur de la liste énumérée relative au type d''anomalie d''un PEI';

INSERT INTO m_defense_incendie.lt_pei_anomalie(
            code, valeur)
    VALUES
    ('01','Manque bouchon'),
    ('02','Manque capot ou capot HS'),
    ('03','Manque de débit ou volume'),
    ('04','Manque de signalisation'),
    ('05','Problème d''accès'),
    ('06','Ouverture point d''eau difficile'),
    ('07','Fuite hydrant'),
    ('08','Manque butée sur la vis d''ouverture'),
    ('09','Purge HS'),
    ('10','Pas d''écoulement d''eau'),
    ('11','Végétation génante'),
    ('12','Gêne accès extérieur'),
    ('13','Equipement à remplacer'),   
    ('14','Hors service');


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
  OWNER TO postgres;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_marque TO postgres;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_marque TO groupe_sig WITH GRANT OPTION;
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
  OWNER TO postgres;
GRANT ALL ON SEQUENCE m_defense_incendie.lt_pei_marque_seq TO postgres;
GRANT ALL ON SEQUENCE m_defense_incendie.lt_pei_marque_seq TO groupe_sig WITH GRANT OPTION;
ALTER TABLE m_defense_incendie.lt_pei_marque ALTER COLUMN code SET DEFAULT to_char(nextval('m_defense_incendie.lt_pei_marque_seq'::regclass),'FM00');

INSERT INTO m_defense_incendie.lt_pei_marque(
            code, valeur)
    VALUES
    ('00','Non renseigné' ),
    (to_char(nextval('m_defense_incendie.lt_pei_marque_seq'::regclass),'FM00'),'Bayard');


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
  OWNER TO postgres;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_delegat TO postgres;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_delegat TO groupe_sig WITH GRANT OPTION;
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
  OWNER TO postgres;
GRANT ALL ON SEQUENCE m_defense_incendie.lt_pei_delegat_seq TO postgres;
GRANT ALL ON SEQUENCE m_defense_incendie.lt_pei_delegat_seq TO groupe_sig WITH GRANT OPTION;
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
  OWNER TO postgres;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_raccord TO postgres;
GRANT ALL ON TABLE m_defense_incendie.lt_pei_raccord TO groupe_sig WITH GRANT OPTION;
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
  OWNER TO postgres;
GRANT ALL ON SEQUENCE m_defense_incendie.lt_pei_raccord_seq TO postgres;
GRANT ALL ON SEQUENCE m_defense_incendie.lt_pei_raccord_seq TO groupe_sig WITH GRANT OPTION;
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
      
      
-- Foreign Key: m_defense_incendie.lt_pei_source_fkey

-- ALTER TABLE m_defense_incendie.geo_pei DROP CONSTRAINT lt_pei_source_fkey;

ALTER TABLE m_defense_incendie.geo_pei
  ADD CONSTRAINT lt_pei_source_fkey FOREIGN KEY (source)
      REFERENCES m_defense_incendie.lt_pei_source (code) MATCH SIMPLE
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
 SELECT 
  g.id_pei,
  g.id_sdis,
  e.lib_epci AS epci,
  g.insee,
  c.commune,
  g.type_pei,
  g.type_rd,
  g.diam_pei,
  g.raccord,
  g.marque,
  g.source,
  g.volume,
  g.diam_cana,
  g.etat_pei,
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
  WHEN a.etat_conf = 't' AND DATE_PART('year',(AGE(CURRENT_DATE,a.date_ct))) < 2 AND g.etat_pei ='02' THEN 't' -- cas ok pour la dispo (etat existant, conformité ok, controle < 2ans)
  ELSE 'f'
  END AS disponible,
  CURRENT_DATE AS date_dispo,
  a.date_mes,
  a.date_ct,
  a.ope_ct,
  a.presta_ct,
  a.date_co,
  g.statut,
  g.gestion,
  g.delegat,
  g.cs_sdis,
  g.position,
  g.observ,
  g.photo_url,
  g.src_pei,
  g.x_l93,
  g.y_l93,
  g.src_geom,
  g.src_date,
  g."precision",
  g.ope_sai,
  g.date_sai,  
  g.date_maj,
  g.geom,
  g.geom1

   FROM m_defense_incendie.geo_pei g
   LEFT JOIN m_defense_incendie.an_pei_ctr a ON a.id_pei = g.id_pei
   LEFT JOIN r_osm.geo_osm_commune as c ON g.insee = c.insee
-- jointure à 2 niveaux pour récupération du nom de l'EPCI
   LEFT JOIN r_administratif.an_geo as lk ON lk.insee = g.insee
   LEFT JOIN r_osm.geo_osm_epci as e ON e.cepci = lk.epci;


ALTER TABLE m_defense_incendie.geo_v_pei_ctr
  OWNER TO postgres;
COMMENT ON VIEW m_defense_incendie.geo_v_pei_ctr
  IS 'Vue éditable destinée à la modification des données relatives aux PEI et aux contrôles';



-- View: x_opendata.xopendata_an_v_open_pei

-- DROP VIEW x_opendata.xopendata_an_v_open_pei;

CREATE OR REPLACE VIEW x_opendata.xopendata_an_v_open_pei AS 
 SELECT 
  g.insee,
  g.id_sdis,
  CAST(g.id_pei AS TEXT) AS id_gestion,
  CASE WHEN g.type_pei = 'NR' THEN NULL ELSE g.type_pei END,
  g.type_rd,
  CASE WHEN g.diam_pei = 'NR' THEN NULL ELSE g.diam_pei END,
  lt_src.code_open AS source,
  lt_stat.code_open AS statut,
  g.position,
  a.press_stat AS pression,
  a.debit,
  g.volume,
  CASE 
  WHEN a.etat_conf = 't' AND DATE_PART('year',(AGE(CURRENT_DATE,a.date_ct))) < 2 AND g.etat_pei ='02' THEN 't' -- cas ok pour la dispo (etat existant, conformité ok, controle < 2ans)
  ELSE 'f'
  END AS disponible,
  CURRENT_DATE AS date_dispo,
  CASE WHEN g.date_maj IS NULL THEN DATE(g.date_sai) ELSE DATE(g.date_maj) END AS date_maj,
  a.date_ct,  
  a.date_co,
  CASE WHEN CAST(g."precision" AS INTEGER)/100 = 0 OR g."precision" IS NULL OR g."precision"=''  THEN NULL
       WHEN CAST(g."precision" AS INTEGER)/100 <= 1 THEN '01'
       WHEN CAST(g."precision" AS INTEGER)/100 > 1 AND CAST(g."precision" AS REAL)/100 <= 5 THEN '05'
       WHEN CAST(g."precision" AS INTEGER)/100 > 5 AND CAST(g."precision" AS REAL)/100 <= 10 THEN '10'
       WHEN CAST(g."precision" AS INTEGER)/100 > 10 THEN '99' END as "precision",      
  g.x_l93 as x,
  g.y_l93 as y,
  st_x(st_transform(g.geom,4326)) AS long,
  st_y(st_transform(g.geom,4326)) AS lat

   FROM m_defense_incendie.geo_pei g
   LEFT JOIN m_defense_incendie.an_pei_ctr a ON a.id_pei = g.id_pei
   LEFT JOIN m_defense_incendie.lt_pei_statut lt_stat ON lt_stat.code = g.statut
   LEFT JOIN m_defense_incendie.lt_pei_source lt_src ON lt_src.code = g.source
   WHERE g.etat_pei = '02'
   ORDER BY g.insee, g.id_sdis;  

ALTER TABLE x_opendata.xopendata_an_v_open_pei
  OWNER TO postgres;
COMMENT ON VIEW x_opendata.xopendata_an_v_open_pei
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
  OWNER TO postgres;
COMMENT ON VIEW m_defense_incendie.geo_v_pei_zonedefense
  IS 'Vue des zones indicatives de défense incendie publique';




-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                      TRIGGER                                                                 ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################


-- #################################################################### FONCTION TRIGGER - GEO_PEI ###################################################

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
INSERT INTO m_defense_incendie.geo_pei (id_pei, id_sdis, insee, type_pei, type_rd, diam_pei, raccord, marque, source, volume, diam_cana, etat_pei, statut, gestion, delegat, cs_sdis, position, observ, photo_url, src_pei, x_l93, y_l93, src_geom, src_date, precision, ope_sai, date_sai, date_maj, geom, geom1)
SELECT v_id_pei,
CASE WHEN NEW.id_sdis = '' THEN NULL ELSE NEW.id_sdis END,
CASE WHEN NEW.insee IS NULL THEN (SELECT insee FROM r_osm.geo_v_osm_commune_apc WHERE st_intersects(NEW.geom,geom)) ELSE NEW.insee END,
CASE WHEN NEW.type_pei IS NULL THEN 'NR' ELSE NEW.type_pei END,
NEW.type_rd,
CASE WHEN NEW.diam_pei IS NULL THEN 'NR' ELSE NEW.diam_pei END,
CASE WHEN NEW.raccord IS NULL THEN '00' ELSE NEW.raccord END,
CASE WHEN NEW.marque IS NULL THEN '00' ELSE NEW.marque END,
CASE WHEN NEW.source IS NULL THEN 'NR' ELSE NEW.source END,
NEW.volume,
NEW.diam_cana,
CASE WHEN NEW.etat_pei IS NULL THEN '00' ELSE NEW.etat_pei END,
CASE WHEN NEW.statut IS NULL THEN '00' ELSE NEW.statut END,
CASE WHEN NEW.gestion IS NULL THEN '00' ELSE NEW.gestion END,
CASE WHEN NEW.delegat IS NULL THEN '00' ELSE NEW.delegat END,
CASE WHEN NEW.cs_sdis IS NULL THEN '00000' ELSE NEW.cs_sdis END,
CASE WHEN NEW.position = '' THEN NULL ELSE LOWER(NEW.position) END,
CASE WHEN NEW.observ = '' THEN NULL ELSE LOWER(NEW.observ) END,
CASE WHEN NEW.photo_url = '' THEN NULL ELSE NEW.photo_url END,
CASE WHEN NEW.src_pei = '' THEN NULL ELSE NEW.src_pei END,
st_x(NEW.geom),
st_y(NEW.geom),
CASE WHEN NEW.src_geom IS NULL OR NEW.src_geom = '' THEN '00' ELSE NEW.src_geom END,
CASE WHEN NEW.src_date IS NULL OR NEW.src_date = '' THEN '0000' ELSE NEW.src_date END,
CASE WHEN NEW.precision IS NULL OR NEW.precision = '' THEN '000' ELSE NEW.precision END,
CASE WHEN NEW.ope_sai = '' THEN NULL ELSE NEW.ope_sai END,
CASE WHEN NEW.date_sai IS NULL THEN now() ELSE now() END,
NEW.date_maj,
NEW.geom,
ST_Buffer(NEW.geom, 200);

INSERT INTO m_defense_incendie.an_pei_ctr (id_pei, id_sdis, press_stat, press_dyn, debit, debit_max, debit_r_ci, etat_anom, lt_anom, etat_acces, etat_sign, etat_conf, date_mes, date_ct, ope_ct, presta_ct, date_co)
SELECT v_id_pei,
NEW.id_sdis,
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
NEW.presta_ct,
NEW.date_co;
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
-- refus de mise à jour si le point est déplacé dans une autre commune
insee=CASE WHEN (SELECT insee FROM r_osm.geo_v_osm_commune_apc WHERE st_intersects(NEW.geom,geom))=OLD.insee THEN OLD.insee ELSE NULL END,
type_pei=CASE WHEN NEW.type_pei IS NULL THEN 'NR' ELSE NEW.type_pei END,
type_rd=NEW.type_rd,
diam_pei=CASE WHEN NEW.diam_pei IS NULL THEN '00' ELSE NEW.diam_pei END,
raccord=CASE WHEN NEW.raccord IS NULL THEN '00' ELSE NEW.raccord END,
marque=CASE WHEN NEW.marque IS NULL THEN '00' ELSE NEW.marque END,
source=CASE WHEN NEW.source IS NULL THEN '00' ELSE NEW.source END,
volume=CASE WHEN NEW.type_pei IN ('PI','BI') OR (NEW.type_pei = 'PA' AND NEW.source = 'CE') THEN NULL ELSE NEW.volume END,
diam_cana=NEW.diam_cana,
etat_pei=CASE WHEN NEW.etat_pei IS NULL THEN '00' ELSE NEW.etat_pei END,
statut=CASE WHEN NEW.statut IS NULL THEN '00' ELSE NEW.statut END,
gestion=CASE WHEN NEW.gestion IS NULL THEN '00' ELSE NEW.gestion END,
delegat=CASE WHEN NEW.delegat IS NULL THEN '00' ELSE NEW.delegat END,
cs_sdis=CASE WHEN NEW.cs_sdis IS NULL THEN '00000' ELSE NEW.cs_sdis END,
position=CASE WHEN NEW.position = '' THEN NULL ELSE LOWER(NEW.position) END,
observ=CASE WHEN NEW.observ = '' THEN NULL ELSE LOWER(NEW.observ) END,
photo_url=CASE WHEN NEW.photo_url = '' THEN NULL ELSE NEW.photo_url END,
src_pei=CASE WHEN NEW.src_pei = '' THEN NULL ELSE NEW.src_pei END,
x_l93=st_x(NEW.geom),
y_l93=st_y(NEW.geom),
src_geom=CASE WHEN NEW.src_geom IS NULL OR NEW.src_geom = '' THEN '00' ELSE NEW.src_geom END,
src_date=CASE WHEN NEW.src_date IS NULL OR NEW.src_date = '' OR NEW.src_geom ='00' THEN '0000' ELSE NEW.src_date END,
precision=CASE WHEN NEW.precision IS NULL OR NEW.precision = '' OR NEW.src_geom = '00' THEN '000' ELSE NEW.precision END,
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
press_stat=CASE WHEN NEW.type_pei IN ('CI','PA') THEN NULL ELSE NEW.press_stat END,
press_dyn=CASE WHEN NEW.type_pei IN ('CI','PA') THEN NULL ELSE NEW.press_dyn END,
debit=CASE WHEN NEW.type_pei IN ('CI','PA') THEN NULL ELSE NEW.debit END,
debit_max=CASE WHEN NEW.type_pei IN ('CI','PA') THEN NULL ELSE NEW.debit_max END,
debit_r_ci=CASE WHEN NEW.type_pei IN ('PI','BI') OR (NEW.type_pei = 'PA' AND NEW.source = 'CE') THEN NULL ELSE NEW.debit_r_ci END,
etat_anom=CASE WHEN NEW.etat_anom IS NULL THEN '0' ELSE NEW.etat_anom END,
lt_anom=CASE WHEN NEW.lt_anom = '' OR NEW.etat_anom IN ('0','t') THEN NULL ELSE NEW.lt_anom END,
etat_acces=CASE WHEN NEW.etat_anom = 't' THEN 't' ELSE v_etat_acces END,
etat_sign=CASE WHEN v_lt_anom LIKE '%04%' THEN 'f' ELSE NEW.etat_sign END,
--etat_conf, les pts de controle sont différents selon le type de PEI
etat_conf=CASE WHEN NEW.type_pei IN ('PI','BI') AND (NEW.debit < 60 OR NEW.press_dyn < 1 OR v_lt_anom LIKE '%14%' OR v_lt_anom LIKE '%03%' OR v_lt_anom LIKE '%10%' OR v_etat_acces = 'f') THEN 'f' 
               WHEN NEW.type_pei = 'CI' AND ((NEW.volume BETWEEN 60 AND 120 AND NEW.debit_r_ci < 60) OR NEW.volume < 60 OR v_lt_anom LIKE '%14%' OR v_lt_anom LIKE '%03%' OR v_lt_anom LIKE '%10%' OR v_etat_acces = 'f') THEN 'f' 
               WHEN NEW.type_pei = 'PA' AND NEW.source = 'CE' AND (v_lt_anom LIKE '%14%' OR v_lt_anom LIKE '%03%' OR v_lt_anom LIKE '%10%' OR v_etat_acces = 'f') THEN 'f'
               WHEN NEW.type_pei = 'PA' AND NEW.source != 'CE' AND (v_lt_anom LIKE '%14%' OR v_lt_anom LIKE '%03%' OR v_lt_anom LIKE '%10%' OR v_etat_acces = 'f') THEN 'f' ELSE 't' END,
date_mes=NEW.date_mes,
date_ct=CASE WHEN NEW.date_ct > CURRENT_DATE THEN NULL ELSE NEW.date_ct END,
ope_ct=NEW.ope_ct,
presta_ct=NEW.presta_ct,
date_co=NEW.date_co
WHERE m_defense_incendie.an_pei_ctr.id_pei = OLD.id_pei;
RETURN NEW;



RETURN NEW;


-- DELETE
ELSIF (TG_OP = 'DELETE') THEN
UPDATE
m_defense_incendie.geo_pei
SET
id_pei=OLD.id_pei,
id_sdis=OLD.id_sdis,
insee=OLD.insee,
type_pei=OLD.type_pei,
type_rd=OLD.type_rd,
diam_pei=OLD.diam_pei,
raccord=OLD.raccord,
marque=OLD.marque,
source=OLD.source,
volume=OLD.volume,
diam_cana=OLD.diam_cana,
etat_pei='03',
statut=OLD.statut,
gestion=OLD.gestion,
delegat=OLD.delegat,
cs_sdis=OLD.cs_sdis,
position=OLD.position,
observ=OLD.observ,
photo_url=OLD.photo_url,
src_pei=OLD.src_pei,
x_l93=OLD.x_l93,
y_l93=OLD.y_l93,
src_geom=OLD.src_geom,
src_date=OLD.src_date,
precision=OLD.precision,
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
presta_ct=OLD.presta_ct,
date_co=OLD.date_co
WHERE m_defense_incendie.an_pei_ctr.id_pei = OLD.id_pei;
RETURN NEW;

END IF;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION m_defense_incendie.ft_geo_v_pei_ctr()
  OWNER TO postgres;
COMMENT ON FUNCTION  m_defense_incendie.ft_geo_v_pei_ctr() IS 'Fonction trigger pour mise à jour de la vue de gestion des points d''eau incendie et contrôles';



-- Trigger: t_t1_geo_v_pei_ctr on m_defense_incendie.geo_v_pei_ctr

-- DROP TRIGGER t_t1_geo_v_pei_ctr ON m_defense_incendie.geo_v_pei_ctr;

CREATE TRIGGER t_t1_geo_v_pei_ctr
  INSTEAD OF INSERT OR UPDATE OR DELETE
  ON m_defense_incendie.geo_v_pei_ctr
  FOR EACH ROW
  EXECUTE PROCEDURE m_defense_incendie.ft_geo_v_pei_ctr();
  



-- #################################################################### FONCTION TRIGGER - log_pei ###################################################

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
  OWNER TO postgres;
COMMENT ON FUNCTION m_defense_incendie.ft_log_pei() IS 'audit';


-- Trigger: m_defense_incendie.t_log_pei on m_defense_incendie.geo_v_pei_ctr

-- DROP TRIGGER m_defense_incendie.t_log_pei ON m_defense_incendie.geo_v_pei_ctr;

CREATE TRIGGER t_t2_log_pei
  INSTEAD OF INSERT OR UPDATE OR DELETE
  ON m_defense_incendie.geo_v_pei_ctr
  FOR EACH ROW
  EXECUTE PROCEDURE m_defense_incendie.ft_log_pei();
 



