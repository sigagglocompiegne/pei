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

*	Selon le type de PEI (poteau / bouche ou citerne ou point d’aspiration), les mesures sont différentes
*	Selon les mesures (grandeurs physiques contrôlées) et les anomalies, les conformités d’accès, de signalétique et du contrôle technique peuvent être déterminées
*	Selon la conformité technique et l’ancienneté du contrôle, la disponibilité pour le défense incendie publique est déduite automatiquement.

Toutes ces règles de vérification sont implémentées informatiquement pour éviter les erreurs de saisie (incohérences).

## Dépendances

La base de données PEI s'appuie sur des référentiels préexistants constituant autant de dépendances nécessaires pour l'implémentation de la base PEI.

|schéma | table | description | usage |
|:---|:---|:---|:---|   
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
|diam_cana|Diamètre de la canalisation exprimé en mm pour les PI et BI|integer| |
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
|precision|Précision cartographique exprimée en cm|character varying(5)| |
|ope_sai|Opérateur de la dernière saisie en base de l'objet|character varying(254)| |
|date_sai|Horodatage de l'intégration en base de l'objet|timestamp without time zone|now()|
|date_maj|Horodatage de la mise à jour en base de l'objet|timestamp without time zone| |
|geom|Géomètrie ponctuelle de l'objet|USER-DEFINED| |
|geom1|Géomètrie de la zone de defense incendie de l'objet PEI|USER-DEFINED| |

### Classe d'objet des mesures et contrôles

`an_pei_ctr` : table des attributs des mesures et contrôles techniques des PEI.

|Nom attribut | Définition | Type  | Valeurs par défaut |
|:---|:---|:---|:---|  
|id_pei|Identifiant unique du PEI|bigint| |
|id_sdis|Identifiant unique du PEI du SDIS|character varying(254)| |
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

## Liste de valeurs


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
|01|...|

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
|01|...|

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
|01|...|

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

Particularité(s) à noter :
* Le fonctionnement du générateur d'application web permet la saisie de choix multiple par la concaténation des différents `code` séparées par un `;`. Il n'y a donc pas de nécessiter à gérer une cardinalité 1-n depuis la classe `an_pei_ctr` et donc pas de clé étrangère depuis cette dernière.

Valeurs possibles :

|code | valeur |
|:---|:---|    
|01|Manque bouchon|
|02|Manque capot ou capot HS|
|03|Manque de débit ou volume|
|04|Manque de signalisation|
|05|Problème d'accès|
|06|Ouverture point d'eau difficile|
|07|Fuite hydrant|
|08|Manque butée sur la vis d'ouverture|
|09|Purge HS|
|10|Pas d'écoulement d'eau|
|11|Végétation génante|
|12|Gêne accès extérieur|
|13|Equipement à remplacer|
|14|Hors service|

---

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

---

## Schéma fonctionnel

### Modèle conceptuel simplifié

![mcd](img/mcd.jpg)

### Schéma fonctionnel

![schema_fonctionnel](img/schema_fonctionnel.jpg)
