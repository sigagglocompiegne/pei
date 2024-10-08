![GeoCompiegnois](img/Logo_web-GeoCompiegnois.png)

# Documentation technique de la base de données PEI

## Principes
  
### Généralités
  
Courant 2015, le SDIS a signifié l'arrêt de la prise en charge des contrôles techniques des Points d'Eau Incendie (PEI) au profit des collectivités gestionnaires. Dès lors, ces dernières sont tenues d'assurer un contrôle technique (conforme) de chaque PEI tous les 2 ans afin que ceux-ci soient pleinement intégrés à la Défense Extérieure Contre l'Incendie (DECI).

A cet effet, les collectivités se sont engagées dans des approches différentiées pour la gestion des contrôles, soit en régie propre, soit en sous traitance auprès de prestataires, généralement le concessionnaire en charge du réseau d'eau.
 
La conception de la base de données PEI a donc pour objectif, d'une part, de couvrir la logique d'un inventaire et d'une gestion patrimoniale des PEI, d'autre part, de permettre la gestion des contrôles techniques. Elle doit également permettre une gestion directe de l'information dans la base de données (au travers d'une application) ou une intégration de données issues de tiers (SDIS, ...).

La base de données ici développée a été conçue en parrallèle de la démarche menée sous l'égide de l'AFIGEO visant à définir un format d'échange des PEI en opendata, démarche à laquelle l'Agglomération de la Région de Compiègne a contribuée.
 
### Résumé fonctionnel

Pour rappel des grands principes :

* Choix du service de conserver uniquement le dernier contrôle technique du PEI mais maintient d'une séparation en 2 classes d'objet dans la base si souhait d'une évolution de cet ordre
* gestion différentiée entre un patrimoine de données hérité du SDIS, un autre sur lequel on agit en tant que gestionnaire
* implémentation de controleurs de saisie utilisateur permettant de ne pas conserver les saisies incohérentes

## Schéma fonctionnel

![schema_fonctionnel](img/schema_fonctionnel_v2.png)

Dans le détail :

#### Les droits

#####	Le service eau potable ARC/ville peut :

*	Voir, consulter et rechercher les informations des PEI sur les communes de l’ARC
*	Peut modifier les données non verrouillées sur les PEI de son patrimoine ( = PEI de gestion « intercommunale » + PEI de gestion communale sur Compiègne)
*	Peut s’affecter des PEI à son patrimoine sur les communes de l’ARC (en faisant passer la gestion du PEI « commune » hors Compiègne à « intercommunale »)
*	Peut verrouiller ou non la mise à jour des données d’un ou plusieurs PEI
*	Peut créer un nouveau PEI
*	Peut affecter un ou plusieurs PEI à un contrat de prestation

#####	Un prestataire assurant les mesures et contrôle des PEI du patrimoine ARC ou ville peut :

*	Voir les PEI qui sont affectés à son contrat 
*	Ne voit pas les autres PEI
*	Ne peut pas ajouter de nouveau PEI
*	Peut modifier les informations d’un PEI seulement si le PEI est bien déverrouillé par le service (sauf les références locale et sdis des PEI)

#####	Un autre service ou commune du pays compiégnois peut :

*	Voir, consulter et rechercher les informations d’un PEI sans pouvoir les modifier

###	Alimentation de la base de données

*	Sur le patrimoine PEI ARC/ville, les données qui priment sont celles qui sont modifiées via l’application (les entités PEI dans la base de données sont dites « maitre »)
*	Hors du patrimoine de PEI ARC/ville, les données du SDIS sont intégrées ponctuellement et manuellement par le service SIG (les entités PEI dans la base de données sont dites « esclave »)

###	Les contrôles de saisie

De nombreux point de contrôles de la saisie des utilisateurs sont vérifiés. Sans tous les lister, il convient néanmoins de rappeler que :

* Un PEI validé ne peut pas être modifiés (sauf si celui est dévérouillé)
* Un PEI non inclus dans le patrimoine de données ne peut pas être modifié
*	Selon le type de PEI (poteau / bouche ou citerne ou point d’aspiration), les mesures sont différentes
*	Selon les mesures (grandeurs physiques contrôlées) et les anomalies, les conformités d’accès, de signalétique et du contrôle technique peuvent être déterminées
*	Selon la conformité technique et l’ancienneté du contrôle, la disponibilité pour le défense incendie publique est déduite automatiquement.

Toutes ces règles de vérification sont implémentées informatiquement pour éviter les erreurs de saisie (incohérences).

## Dépendances

La base de données PEI s'appuie sur des référentiels préexistants constituant autant de dépendances nécessaires pour l'implémentation de la base PEI.

|schéma | table | description | usage |
|:---|:---|:---|:---|   
|r_objet|lt_contrat|domaine de valeur des références de contrat sur les données gérées par les services|Gestion des accès aux prestataires|
|r_objet|lt_src_geom|domaine de valeur générique d'une table géographique|source du positionnement du PEI|
|r_administratif|an_geo|donnée de référence alphanumérique du découpage administratif |jointure insee commune<>siret epci|
|r_osm|geo_osm_commune|donnée de référence géographique du découpage communal OSM|nom de la commune|
|r_osm|geo_v_osm_commune_apc|vue de la donnée geo_osm_commune restreinte sur le secteur du compiégnois|insee + controle de saisie PEI à l'intérieur de ce périmètre|
|r_osm|geo_osm_epci|donnée de référence géographique du découpage epci OSM|nom de l'EPCI|

---

## Classes d'objets

L'ensemble des classes d'objets unitaires sont stockées dans le schéma m_defense_incendie, celles dérivées et applicatives dans le schéma x_apps, celles dérivées pour les exports opendata dans le schéma x_opendata.

### Classe d'objet géographique et patrimoniale

`geo_pei` : table géographique des attributs patrimoniaux des PEI.

|Nom attribut | Définition | Type  | Valeurs par défaut |
|:---|:---|:---|:---|  
|id_pei|Identifiant interne unique du PEI|bigint|nextval('m_defense_incendie.geo_pei_id_seq'::regclass)|
|id_sdis|Identifiant interne unique du PEI du SDIS|character varying(254)| |
|ref_terr|Référence du PEI sur le terrain|character varying(254)| |
|insee|Code INSEE|character varying(5)| |
|type_pei|Type de PEI|character varying(2)| |
|type_rd|Type de PEI selon la nomenclature du réglement départemental|character varying(254)| |
|diam_pei|Diamètre intérieur du PEI|character varying(3)| |
|raccord|Descriptif des raccords de sortie du PEI (nombre et diamètres exprimés en mm)|character varying(2)| |
|marque|Marque du fabriquant du PEI|character varying(2)| |
|source_pei|Source du point d'eau|character varying(3)| |
|volume|Capacité volumique utile de la source d'eau en m3/h. Si la source est inépuisable (cour d'eau ou plan d'eau pérenne), l'information est nulle|integer| |
|mate_cana|Matériau de la canalisation sur lequel le PEI est connecté (ne concerne que les poteaux incendies et les bouches incendies)I|varchar(2)|'00' |
|diam_cana|Diamètre de la canalisation desservant le PEI exprimé en mm pour les PI et BI|varchar(2)| '00'|
|etat_pei|Etat d'actualité du PEI|character varying(2)| |
|statut|Statut juridique|character varying(2)| |
|nom_etab|Nom de l'établissement propriétaire dans le cas d'un statut privé|character varying(254)| |
|gestion|Gestionnaire du PEI|character varying(2)| |
|delegat|Délégataire du réseau pour les PI et BI|character varying(2)| |
|cs_sdis|Code INSEE du centre de secours du SDIS en charge du volet opérationnel|character varying(5)| |
|situation|Adresse ou information permettant de faciliter la localisation du PEI sur le terrain|character varying(254)| |
|observ|Observations|character varying(254)| |
|photo_url|Lien vers une photo du PEI|character varying(254)| |
|src_pei|Organisme source de l'information PEI|character varying(254)| |
|x_l93|Coordonnée X en mètre|numeric| |
|y_l93|Coordonnée Y en mètre|numeric| |
|src_geom|Référentiel de saisie|character varying(2)|'00'::bpchar|
|src_date|Année du millésime du référentiel de saisie|character varying(4)|'0000'::bpchar|
|prec|Précision cartographique exprimée en cm|character varying(5)| |
|ope_sai|Opérateur de la dernière saisie en base de l'objet|character varying(254)| |
|date_sai|Horodatage de l'intégration en base de l'objet|timestamp without time zone|now()|
|date_maj|Horodatage de la mise à jour en base de l'objet|timestamp without time zone| |
|geom|Géomètrie ponctuelle de l'objet|geometry(Point,2154)| |
|geom1|Géomètrie de la zone de defense incendie de l'objet PEI|geometry(Polygon,2154)| |

### Classe d'objet des mesures et contrôles

`an_pei_ctr` : table des attributs des mesures et contrôles techniques des PEI.

|Nom attribut | Définition | Type  | Valeurs par défaut |
|:---|:---|:---|:---|  
|id_pei|Identifiant unique du PEI|bigint| |
|id_sdis|Identifiant unique du PEI du SDIS|character varying(254)| |
|id_contrat|Référence du contrat de prestation pour le contrôle technique du PEI|character varying(2)| |
|press_stat|Pression statique en bar à un débit de 0 m3/h|real| |
|press_dyn|Pression dynamique résiduelle en bar au débit nominal|real| |
|debit|Valeur de débit mesuré exprimé en m3/h sous une pression de 1 bar|real| |
|debit_max|Valeur de débit maximal à gueule bée mesuré exprimé en m3/h|real| |
|debit_r_ci|Valeur de débit de remplissage pour les CI en m3/h|real| |
|etat_anom|Etat d'anomalies du PEI|character varying(1)| |
|lt_anom|Liste des anomalies du PEI|character varying(254)| |
|etat_acces|Etat de l'accessibilité du PEI|character varying(1)| |
|etat_sign|Etat de la signalisation du PEI|character varying(1)| |
|etat_conf|Etat de la conformité technique du PEI|character varying(1)| |
|date_mes|Date de mise en service du PEI|date| |
|date_ct|Date du dernier contrôle|date| |
|ope_ct|Opérateur du dernier contrôle|character varying(254)| |
|presta_ct|Prestataire du dernier contrôle|character varying(254)| |
|date_co|Date de la dernière reconnaissance opérationnelle|date| |

---

`m_defense_incendie.geo_v_pei_ctr` : Vue éditable de gestion interne au service IG permettant la visualisation des données et son édition

* 2 triggers :
  * `t_t1_geo_v_pei_ctr` : trigger de mise à jour des données PEI
  * `t_t2_log_pei` : trigger intégrant de valeurs dans la table de log 

`m_defense_incendie.geo_v_pei_zonedefense` : Vue simple permettant de visualiser les périmètres de 200m autour des PEI uniquement sur la DECI est vrai

---

### classes d'objets applicatives métiers :
 
`xapps_geo_v_pei_ctr` : Vue éditable depuis l'application permettant la saisie ou la mise à jour des données des PEI
`geo_v_pei_ctr_qgis` : Vue éditable destinée à la modification des données relatives aux PEI et aux contrôles depuis un projet QGIS interne (sans contrôle ici)

  * `t_t1_geo_v_pei_ctr` :trigger gérant la saisie ou la mise à jour des données PEI, intégrant les contrôles de saisies et la génération des messages d'erreur
  * `t_t2_log_pei` : intégration de valeurs dans la table de log 
  
`xapps_geo_v_pei_zonedefense` : Vue applicative affichant les périmètres de 200 mètres autour des PEI pour ceux ayant une DECI disponible

### classes d'objets applicatives grands publics sont classés dans le schéma x_apps_public :

Sans objet

### classes d'objets opendata sont classés :

`xopendata_geo_v_open_pei` : Vue des PEI existants destinée aux échanges de données en opendata selon le format PEI AFIGEO

## Liste de valeurs

La liste de valeurs de contrat n'est pas mentionnée ici pour des raisons de confidentialité.

`lt_pei_type_pei` : Liste des types de PEI

|Nom attribut | Définition | Type  | Valeurs par défaut |
|:---|:---|:---|:---|    
|code|Code de la liste énumérée relative au type de PEI|character varying(2)| |
|valeur|Valeur de la liste énumérée relative au type de PEI|character varying(80)| |
|affich|Ordre d'affichage de la liste énumérée relative au type de PEI|character(1)| |

Particularité(s) à noter :
* Domaine de valeur issu du format d'échange défini par l'AFIGEO

Valeurs possibles :

|code | valeur | affich
|:---|:---|:---|     
|BI|Prise d'eau sous pression, notamment bouche d'incendie|2|
|CI|Citerne aérienne ou enterrée|4|
|NR|Non renseigné|5|
|PA|Point d'aspiration aménagé (point de puisage)|3|
|PI|Poteau d'incendie|1|

---

`lt_pei_diam_pei` : Liste permettant de décrire le diamètre intérieur du point d'eau incendie

|Nom attribut | Définition | Type  | Valeurs par défaut |
|:---|:---|:---|:---|    
|code|Code de la liste énumérée relative au type de PEI|integer| |
|valeur|Valeur de la liste énumérée relative au type de PEI|character varying(80)| |

Particularité(s) à noter :
* Domaine de valeur issu du format d'échange défini par l'AFIGEO


Valeurs possibles :

|code | valeur |
|:---|:---|  
|80|80|
|100|100|
|150|150|
|0|Non renseigné|

---

`lt_pei_source_pei` : Liste permettant de décrire le type de source d'alimentation du PEI

|Nom attribut | Définition | Type  | Valeurs par défaut |
|:---|:---|:---|:---|    
|code|Code de la liste énumérée relative au type de source du PEI|character varying(3)| |
|valeur|Valeur de la liste énumérée relative au type de source du PEI|character varying(80)| |
|code_open|Code pour les exports opendata de la liste énumérée relative au type de source du PEI|character varying(30)| |

Particularité(s) à noter :
* Domaine de valeur (code_open, valeur) issu du format d'échange défini par l'AFIGEO

Valeurs possibles :

|code | valeur | code_open |
|:---|:---|:---|   
|CI|Citerne|citerne|
|PE|Plan d'eau|plan_eau|
|PU|Puit|puits|
|CE|Cours d'eau|cours_eau|
|AEP|Réseau AEP|reseau_aep|
|IRR|Réseau d'irrigation|reseau_irrigation|
|PIS|Piscine|piscine|
|NR|Non renseigné||

---

`lt_pei_statut` : Liste permettant de décrire le statut juridique du PEI

|Nom attribut | Définition | Type  | Valeurs par défaut |
|:---|:---|:---|:---|    
|code|Code de la liste énumérée relative au statut juridique du PEI|character varying(2)| |
|valeur|Valeur de la liste énumérée relative au statut juridique du PEI|character varying(80)| |
|code_open|Code pour les exports opendata de la liste énumérée relative au statut juridique du PEI|character varying(10)| |

Particularité(s) à noter :
* Domaine de valeur (code_open, valeur) issu du format d'échange défini par l'AFIGEO

Valeurs possibles :

|code | valeur | code_open |
|:---|:---|:---|   
|01|Public|public|
|02|Privé|prive|
|00|Non renseigné|

---

`lt_pei_etat_pei` : Liste permettant de décrire l'état d'actualité du PEI

|Nom attribut | Définition | Type  | Valeurs par défaut |
|:---|:---|:---|:---|    
|code|Code de la liste énumérée relative à l'état d'actualité du PEI|character varying(2)| |
|valeur|Valeur de la liste énumérée relative à l'état d'actualité du PEI|character varying(80)| |

Valeurs possibles :

|code | valeur | 
|:---|:---|   
|01|Projet|
|02|Existant|
|03|Supprimé|
|00|Non renseigné|

---

`lt_pei_etat_boolean` : Liste permettant de décrire l'état d'un attribut "booléen" pour un PEI

|Nom attribut | Définition | Type  | Valeurs par défaut |
|:---|:---|:---|:---|    
|code|Code de la liste énumérée relative à l'état d'un attribut boolean|character varying(1)| |
|valeur|Valeur de la liste énumérée relative à l'état d'un attribut boolean|character varying(80)| |
|code_open|Code pour les exports opendata de la liste énumérée relative à l'état d'un attribut boolean|character varying(1)| |

Particularité(s) à noter :
* Domaine de valeur (code_open, valeur) issu du format d'échange défini par l'AFIGEO

Valeurs possibles :

|code | valeur | code_open |
|:---|:---|:---|   
|0|Non renseigné||
|f|Non|0|
|t|Oui|1|

---

`lt_pei_marque` : Liste permettant de décrire la marque du PEI

|Nom attribut | Définition | Type  | Valeurs par défaut |
|:---|:---|:---|:---|    
|code|Code de la liste énumérée relative à la marque du PEI|character varying(2)|to_char(nextval('m_defense_incendie.lt_pei_marque_seq'::regclass), 'FM00'::text)|
|valeur|Valeur de la liste énumérée relative à la marque du PEI|character varying(80)| |


Particularité(s) à noter :
* Domaine de valeur ouvert

Valeurs possibles :

|code | valeur |
|:---|:---|  
|00|Non renseigné|
|01|Bayard|
|02|...|
---

`lt_pei_raccord` : Liste permettant de décrire le type de raccord du PEI

|Nom attribut | Définition | Type  | Valeurs par défaut |
|:---|:---|:---|:---|    
|code|Code de la liste énumérée relative au type de raccord du PEI|character varying(2)|to_char(nextval('m_defense_incendie.lt_pei_raccord_seq'::regclass), 'FM00'::text)|
|valeur|Valeur de la liste énumérée relative au type de raccord du PEI|character varying(80)| |


Particularité(s) à noter :
* Domaine de valeur ouvert

Valeurs possibles :

|code | valeur |
|:---|:---|  
|00|Non renseigné|
|01|1x100|
|02|1x65|
|03|1x100 - 2x65|
|04|2x100 - 1x65|
|05|3x100|
|06|1x65 - 2x40|
|07|...|

---

`lt_pei_gestion` : Liste permettant de décrire le gestionnaire du PEI

|Nom attribut | Définition | Type  | Valeurs par défaut |
|:---|:---|:---|:---|    
|code|Code de la liste énumérée relative au gestionnaire du PEI|character varying(2)| |
|valeur|Valeur de la liste énumérée relative au gestionnaire du PEI|character varying(80)| |

Valeurs possibles :

|code | valeur | 
|:---|:---|   
|01|Etat|
|02|Région|
|03|Département|
|04|Intercommunalité|
|05|Commune|
|06|Office HLM|
|07|Privé|
|99|Autre|
|ZZ|Non concerné|
|00|Non renseigné|

---

`lt_pei_delegat` : Liste permettant de décrire le délégataire du réseau surlequel est lié un PEI

|Nom attribut | Définition | Type  | Valeurs par défaut |
|:---|:---|:---|:---|    
|code|Code de la liste énumérée relative au délégataire du réseau surlequel est lié un PEI|character varying(2)| |
|valeur|Valeur de la liste énumérée relative au délégataire du réseau surlequel est lié un PEI|character varying(80)| |

Particularité(s) à noter :
* Domaine de valeur ouvert

Valeurs possibles :

|code | valeur |
|:---|:---|  
|00|Non renseigné|
|01|Suez|
|02|Saur|
|03|Veolia|
|04|...|
---

`lt_pei_cs_sdis` : Liste permettant de décrire le nom du centre de secours de 1er appel du SDIS en charge du PEI

|Nom attribut | Définition | Type  | Valeurs par défaut |
|:---|:---|:---|:---|    
|code|Code de la liste énumérée relative au nom du CS SDIS en charge du PEI|character varying(5)| |
|valeur|Valeur de la liste énumérée relative au nom du CS SDIS en charge du PEI|character varying(80)| |

Particularité(s) à noter :
* Information connue par héritage de données PEI issues de sources tierces et difficile à maintenir car relevant de la gestion propre du SDIS (ex : présence de cas de découpage infra-communal dans la répartition de la prise en charge par les centres de secours)

Valeurs possibles :

|code | valeur |
|:---|:---|  
|00000|Non renseigné|
|60159|CS de Compiègne|
|60068|CS de Béthisy-Saint-Pierre|
|60636|CS de Thourotte|
|60667|CS de Verberie|
|60025|CS d'Attichy|
|60223|CS d'Estrées-Saint-Denis|
|60509|CS de Pont-Sainte-Maxence|

---

`lt_pei_anomalie` : Liste des anomalies possibles pour un PEI

|Nom attribut | Définition | Type  | Valeurs par défaut |
|:---|:---|:---|:---|    
|code|Code de la liste énumérée relative au type d'anomalie d'un PEI|character varying(2)| |
|valeur|Valeur de la liste énumérée relative au type d'anomalie d'un PEI|character varying(80)| |
|csq_acces|Impact de l'anomalie sur l''état de l''accessibilité du PEI|character varying(1)| |
|csq_sign|Impact de l'anomalie sur l''état de la signalisation du PEI|character varying(1)| |
|csq_conf|Impact de l''anomalie sur l'état de la conformité technique du PEI|character varying(1)| |

Particularité(s) à noter :
* Le fonctionnement du générateur d'application web permet la saisie de choix multiple par la concaténation des différents `code` séparées par un `;`. Il n'y a donc pas de nécessiter à gérer une cardinalité 1-n depuis la classe `an_pei_ctr` et donc pas de clé étrangère depuis cette dernière.

Valeurs possibles :

|code | valeur |csq_acces |csq_sign |csq_conf |
|:---|:---|    
|01|Manque bouchon|0|0|0|
|02|Manque capot ou capot HS|0|0|0|
|03|Manque de débit ou volume|0|0|1|
|04|Manque de signalisation|0|1|0|
|05|Problème d'accès|1|0|1|
|06|Ouverture point d'eau difficile|0|0|0|
|07|Fuite hydrant|0|0|0|
|08|Manque butée sur la vis d'ouverture|0|0|0|
|09|Purge HS|0|0|0|
|10|Pas d'écoulement d'eau|0|0|1|
|11|Végétation génante|0|0|0|
|12|Gêne accès extérieur|1|0|0|
|13|Equipement à remplacer|0|0|0|
|14|Hors service|0|0|1|
|15|Manqued'eau (pour citerne ou point d'aspiration seulement)|0|0|1|

---

`lt_pei_materiau` : Liste permettant de décrire les matériaux des canalisations desservant les PEI

|Nom attribut | Définition | Type  | Valeurs par défaut |
|:---|:---|:---|:---|    
|code|Code du matériau|character varying(2)| |
|valeur|Valeur de la liste du matériau|character varying(80)| |

Valeurs possibles :

|code | valeur | 
|:---|:---|   
|10|Fonte indéterminée|
|11|Acier|
|12|Fonte grise|
|13|Fonte bluetop|
|14|Fonte ductile|
|20|PVC indéterminé|
|21|PVC|
|22|PE noir|
|23|PE bandes bleues|
|00|Non renseigné|
|ZZ|Non concerné|


---

`lt_pei_diam_materiau` : Liste permettant de décrire les diamètres des matériaux des canalisations reliés au PEI

|Nom attribut | Définition | Type  | Valeurs par défaut |
|:---|:---|:---|:---|    
|code|Code du diamètre|character varying(2)| |
|valeur|Valeur de la liste du diamètre|character varying(80)| |

Valeurs possibles :

|code | valeur | typ |
|:---|:---|:---| 
|01|<60|11|
|01|<60|12|
|01|<60|13|
|01|<60|14|
|01|<60|10|
|02|60|11|
|02|60|13|
|02|60|14|
|02|60|12|
|02|60|10|
|03|80|11|
|03|80|12|
|03|80|13|
|03|80|14|
|03|80|10|
|04|100|11|
|04|100|12|
|04|100|13|
|04|100|14|
|04|100|10|
|05|125|11|
|05|125|12|
|05|125|13|
|05|125|14|
|05|125|10|
|06|150|10|
|06|150|11|
|06|150|12|
|06|150|13|
|06|150|14|
|07|200|11|
|07|200|12|
|07|200|13|
|07|200|14|
|07|200|10|
|08|250|11|
|08|250|12|
|08|250|13|
|08|250|14|
|08|250|10|
|09|300|12|
|09|300|13|
|09|300|14|
|10|350|12|
|10|350|13|
|10|350|14|
|11|400|12|
|11|400|13|
|11|400|14|
|12|450|12|
|12|450|13|
|12|450|14|
|13|500|12|
|13|500|13|
|13|500|14|
|14|600|12|
|14|600|13|
|14|600|14|
|15|<63|21|
|15|<63|22|
|15|<63|23|
|16|63|21|
|16|63|22|
|16|63|23|
|17|90|21|
|17|90|22|
|17|90|23|
|18|110|21|
|18|110|22|
|18|110|23|
|19|160|21|
|19|160|22|
|19|160|23|
|20|180|21|
|20|180|22|
|20|180|23|
|21|335|21|
|21|335|22|
|21|335|23|
|15|<63|20|
|16|63|20|
|17|90|20|
|18|110|20|
|19|160|20|
|20|180|20|
|21|335|20|
|ZZ|Non concerné|ZZ|
|00|Non renseigné|00|
|09|300|11|
|10|350|11|
|11|400|11|
|12|450|11|
|13|500|11|
|14|600|11|

## Log

`log_pei` : table des log de la base PEI.

|Nom attribut | Définition | Type  | Valeurs par défaut |
|:---|:---|:---|:---|
|id_audit|Identifiant unique de l'opération de base PEI|bigint|nextval('m_defense_incendie.log_pei_id_seq'::regclass)|
|type_ope|Type d'opération intervenue sur la base PEI|text| |
|ope_sai|Utilisateur ayant effectuée l'opération sur la base PEI|character varying(254)| |
|id_pei|Identifiant du PEI concerné par l'opération sur la base PEI|bigint| |
|date_maj|Horodatage de l'opération sur la base PEI|timestamp without time zone| |

Particularité(s) à noter :
* Table de log liée à la vue de gestion des données PEI

## Erreur

`x_apps.xapps_geo_v_pei_ctr_erreur` : table des messages d'erreurs remontant dans l'application par rapport à la saisie des données via la fiche d'information applicative.

|Nom attribut | Définition | Type  | Valeurs par défaut |
|:---|:---|:---|:---|
|gid|Identifiant unique du message|integer|NOT NULL|
|id_pei|Identifiant du PEI|integer| |
|erreur|Message à afficher dans la fiche d'information|character varying(500)| |
|horodatage|Date d'intégration du message|timestamp without time zone| |

Particularité(s) à noter :
* Cette table est uniquement liée dans GEO à la vue applicative.

---

## Projet QGIS pour la gestion

Un projet QGIS a été réalisé pour la gestion interne des données. Il est stocké ici :
R:\Projets\Metiers\1712ENV-ARC-PointEauIncendie\3-BaseDeDonnees
dans l'attente d'être placé ici Y:\Ressources\4-Partage\3-Procedures\QGIS

## Traitement automatisé mis en place (Workflow de l'ETL FME)

### Initialisation des données - Etat 0

Le fichier a utilisé est placé ici `R:\Projets\Metiers\1712ENV-ARC-PointEauIncendie\3-BaseDeDonnees\2-Production\init_data_PEI_sdis2arc.fmw`.


### Mise à jour régulière des données SDIS

Le processus de traitement est en cours de développement.


## Export Open Data

Le processus de traitement est en cours de développement.


---

## Schéma fonctionnel

### Modèle conceptuel simplifié

(non disponible)

