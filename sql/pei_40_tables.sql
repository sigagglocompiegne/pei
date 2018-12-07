/*PEI V1.0*/
/*Creation des tables  */
/* pei_40_tables.sql */
/*PostGIS*/

/* Propriétaire : GeoCompiegnois - http://geo.compiegnois.fr/ */
/* Auteur : FLorent Vanhoutte */
/* Participant : Grégory Bodet */


DROP TABLE IF EXISTS m_defense_incendie.an_pei_ctr;
DROP TABLE IF EXISTS m_defense_incendie.geo_pei;
DROP TABLE IF EXISTS m_defense_incendie.log_pei;

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
  debit_r_ci real,
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
COMMENT ON COLUMN m_defense_incendie.geo_pei.debit_r_ci IS 'Valeur de débit de remplissage pour les CI en m3/h';
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
  etat_anom character varying(1) NOT NULL,
  lt_anom character varying(254),
  etat_acces character varying(1) NOT NULL,
  etat_sign character varying(1) NOT NULL,
  etat_conf character varying(1) NOT NULL,
  date_mes date,
  date_ct date,
  ope_ct character varying(254),
  date_ro date,
CONSTRAINT an_pei_ctr_pkey PRIMARY KEY (id_pei),
  CONSTRAINT an_pei_ctr_ukey UNIQUE (id_sdis)
)
WITH (
  OIDS=FALSE
);

COMMENT ON TABLE m_defense_incendie.an_pei_ctr
  IS 'Classe décrivant le contrôle d''un point d''eau incendie';
COMMENT ON COLUMN m_defense_incendie.an_pei_ctr.id_pei IS 'Identifiant unique du PEI';
COMMENT ON COLUMN m_defense_incendie.an_pei_ctr.id_sdis IS 'Identifiant unique du PEI du SDIS';
COMMENT ON COLUMN m_defense_incendie.an_pei_ctr.id_contrat IS 'Référence du contrat de prestation pour le contrôle technique du PEI';
COMMENT ON COLUMN m_defense_incendie.an_pei_ctr.press_stat IS 'Pression statique en bar à un débit de 0 m3/h';
COMMENT ON COLUMN m_defense_incendie.an_pei_ctr.press_dyn IS 'Pression dynamique résiduelle en bar à un débit de 60 m3/h';
COMMENT ON COLUMN m_defense_incendie.an_pei_ctr.debit IS 'Valeur de débit mesuré exprimé en m3/h sous une pression de 1 bar';
COMMENT ON COLUMN m_defense_incendie.an_pei_ctr.debit_max IS 'Valeur de débit maximal à gueule bée mesuré exprimé en m3/h';
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

COMMENT ON TABLE m_defense_incendie.log_pei
  IS 'Table d''audit des opérations sur la base de données PEI';
COMMENT ON COLUMN m_defense_incendie.log_pei.id_audit IS 'Identifiant unique de l''opération de base PEI';
COMMENT ON COLUMN m_defense_incendie.log_pei.type_ope IS 'Type d''opération intervenue sur la base PEI';
COMMENT ON COLUMN m_defense_incendie.log_pei.ope_sai IS 'Utilisateur ayant effectuée l''opération sur la base PEI';
COMMENT ON COLUMN m_defense_incendie.log_pei.id_pei IS 'Identifiant du PEI concerné par l''opération sur la base PEI';
COMMENT ON COLUMN m_defense_incendie.log_pei.date_maj IS 'Horodatage de l''opération sur la base PEI';

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

