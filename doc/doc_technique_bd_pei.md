# Documentation technique de la base de données PEI

## Principes
  * **généralité** :
 Le SDIS a arrêté les contrôles techniques des poteaux incendie en 2015, laissant cette obligations aux collectivités. Celles-ci ont des approches différentiées dans la gestion des contrôles techniques, soit en régie soit en sous traitance auprès du concessionnaire en charge de l'eau potable ou auprès d'autres prestataires.
 inventaire issu mlashup de donénes commune, osm, sdis, base de données structurée en parrallèle de la détermination du format d'échange des PEI sous l'égide de l'AFIGEO.
 
 * **résumé fonctionnel** :
 les .

## Classes d'objets

L'ensemble des classes d'objets unitaires sont stockées dans le schéma m_defense_incendie, celles dérivées et applicatives dans le schéma x_apps, celles dérivées pour les exports opendata dans le schéma x_opendata.

 ### classe d'objet géographique et patrimoniale :

   `geo_pei` : table géographique des attributs patrimoniaux des points d'eau incendie.

|Nom attribut | Définition | Type  | Valeurs par défaut |
|:---|:---|:---|:---|  
|id_pei|Identifiant unique du PEI|bigint|nextval('m_defense_incendie.geo_pei_id_seq'::regclass)|
|id_sdis|Identifiant unique du PEI du SDIS|character varying(254)| |
|insee|Code INSEE|character varying(5)| |
|type_pei|Type de PEI|character varying(2)| |
|type_rd|***** |character varying(254)| |
|diam_pei|Diamètre intérieur du PEI|character varying(3)| |
|raccord|Descriptif des raccords de sortie du PEI (nombre et diamètres exprimés en mm)|character varying(2)| |
|marque|Marque du fabriquant du PEI|character varying(2)| |
|source|Source du point d'eau|character varying(3)| |
|volume|Capacité volumique utile de la source d'eau en m3/h. Si la source est inépuisable (cour d'eau ou plan d'eau pérenne), l'information est nulle|integer| |
|diam_cana|Diamètre de la canalisation exprimé en mm pour les PI et BI|integer| |
|etat_pei|Etat d'actualité du PEI|character varying(2)| |
|statut|Statut juridique|character varying(2)| |
|gestion|Gestionnaire du PEI|character varying(2)| |
|delegat|Délégataire du réseau pour les PI et BI|character varying(2)| |
|cs_sdis|Code INSEE du centre de secours du SDIS en charge du volet opérationnel|character varying(5)| |
|position|Adresse ou information permettant de faciliter la localisation du PEI sur le terrain|character varying(254)| |
|observ|Observations|character varying(254)| |
|photo_url|Lien vers une photo du PEI|character varying(254)| |
|src_pei|Organisme source de l'information PEI|character varying(254)| |
|x_l93|Coordonnée X en mètre|numeric| |
|y_l93|Coordonnée Y en mètre|numeric| |
|src_geom|Référentiel de saisie|character varying(2)|'00'::bpchar|
|src_date|Année du millésime du référentiel de saisie|character varying(4)|'0000'::bpchar|
|precision|Précision cartographique exprimée en cm|character varying(5)| |
|ope_sai|Opérateur de la dernière saisie en base de l'objet|character varying(254)| |
|date_sai|Horodatage de l'intégration en base de l'objet|timestamp without time zone|now()|
|date_maj|Horodatage de la mise à jour en base de l'objet|timestamp without time zone| |
|geom|Géomètrie ponctuelle de l'objet|USER-DEFINED| |
|geom1|Géomètrie de la zone de defense incendie de l'objet PEI|USER-DEFINED| |
