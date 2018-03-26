# Documentation technique de la base de données PEI

## Principes
  
* **généralités**
  
Courant 2015, le SDIS a signifié l'arrêt de la prise en charge des contrôles techniques des Points d'Eau Incendie (PEI) au profit des collectivités gestionnaires. Dès lors, ces dernières sont tenues d'assurer un contrôle technique (conforme) de chaque PEI tous les 2 ans afin que ceux-ci soient intégrés dans la Défense Extérieure Contre l'Incendie (DECI).

A cet effet, les collectivités se sont engagées dans des approches différentiées pour la gestion des contrôles, soit en régie propre, soit en sous traitance auprès de prestataires, généralement le concessionnaire en charge de l'eau potable.
 
La conception de la base de données PEI a donc pour objectif d'une part, de couvrir la logique d'un inventaire et d'une gestion patrimoniale des PEI, d'autre part, de permettre la gestion des contrôles techniques. La base de données ici développée a été conçue en parrallèle des démarches menées sous l'égide de l'AFIGEO et visant à définir un format d'échange des PEI en opendata, démarche à laquelle l'Agglomération de la Région de Compiègne a contribuée.
 
* **résumé fonctionnel** :

Choix du service de conservation de l'unique dernier contrôle technique du PEI mais maintient d'une séparation en 2 classes d'objet dans la base

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

### classe d'objet des contrôles :

`an_pei_ctr` : table des attributs des contrôles techniques des points d'eau incendie.

|Nom attribut | Définition | Type  | Valeurs par défaut |
|:---|:---|:---|:---|  
|id_pei|Identifiant unique du PEI|bigint| |
|id_sdis|Identifiant unique du PEI du SDIS|character varying(254)| |
|press_stat|Pression statique en bar à un débit de 0 m3/h|real| |
|press_dyn|Pression dynamique résiduelle en bar à un débit de 60 m3/h|real| |
|debit|Valeur de débit mesuré exprimé en m3/h sous une pression de 1 bar|real| |
|debit_max|Valeur de débit maximal à gueule bée mesuré exprimé en m3/h|real| |
|debit_r_ci|Valeur de débit de remplissage pour les CI en m3/h|real| |
|etat_anom|Etat d'anomalies du PEI|character varying(1)| |
|lt_anom|Liste des anomalies du PEI|character varying(254)| |
|etat_acces|Etat de l'accessibilité du PEI|character varying(1)| |
|etat_sign|Etat de la signalisation du PEI|character varying(1)| |
|etat_conf|Etat de la conformité technique du PEI|character varying(1)| |
|date_mes|Date de mise en service du PEI (correspond à la date du premier contrôle débit-pression effectué sur le terrain)|date| |
|date_ct|Date du dernier contrôle|date| |
|ope_ct|Opérateur du dernier contrôle|character varying(254)| |
|presta_ct|Prestataire du dernier contrôle|character varying(254)| |
|date_co|Date de la dernière reconnaissance opérationnelle|date| |

Particularité(s) à noter :

---

## Liste de valeurs


---

## Schéma fonctionnel

### Modèle conceptuel simplifié

![mcd](../img/MCD.jpg)

### Schéma fonctionnel

![schema_fonctionnel](../img/schema_fonctionnel.jpg)
