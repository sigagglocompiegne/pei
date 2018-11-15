![GeoCompiegnois](img/Logo_web-GeoCompiegnois.png)

# Documentation technique de l'application PEI

* Statut
  - [ ] à rédiger
  - [x] en cours de rédaction
  - [ ] relecture
  - [ ] finaliser
  - [ ] révision
  
* Historique des versions

|Date | Auteur | Description
|:---|:---|:---|
|29/03/2018|Florent VANHOUTTE|version initiale|
|15/11/2018|Grégory Bodet|version initiale remaniée dans le modèle des autres documentations|


# Généralité

|Représentation| Nom de l'application |Résumé|
|:---|:---|:---|
|![picto](/doc/img/pei_bleu.png)|Défense Extérieure Contre l'Incendie (DECI)|Cette application est dédiée à la gestion et la consultation des PEI (Points d'Eau Incendie) déterminant leur niveau de DECI.|

# Accès

|Public|Métier|Accès restreint|
|:-:|:-:|:---|
||X|Accès réservé aux personnels gestionnaires des données des EPCI ayant les droits d'accès.|

# Droit par profil de connexion

* **Prestataires**

|Fonctionnalités|Lecture|Ecriture|Précisions|
|:---|:-:|:-:|:---|
|Recherches|x||Uniquement recherche par adresse, voie et PEI (sauf par contrat pour ce dernier).|
|Cartographie|x||Visibilité uniquement sur les PEI définis pouyr chaque contrat.|
|Fiche d'information PEI|x|x|Peut modifier uniquement les données accessibles.|

* **Personnes du service métier**

|Fonctionnalités|Lecture|Ecriture|Précisions|
|:---|:-:|:-:|:---|
|Toutes|x||L'ensemble des fonctionnalités (recherches, cartographie, fiches d'informations, ...) sont accessibles par tous les utilisateurs connectés.|
|Fiche d'infromation PEI|x|x|Peut modifier les données PEI.|
|Modification géométrique - Ajouter ou déplacer un PEI|x||Cette fonctionnalité est uniquement visible par les utilisateurs inclus dans les groupes ADMIN et PEI_EDIT. Attention, un PEI déjà saisie sur une commune ne peut pas être déplacé sur une autre commune.|

* **Autres profils**

Sans objet

# Les données

Sont décrites ici les Géotables et/ou Tables intégrées dans GEO pour les besoins de l'application. Les autres données servant d'habillage (pour la cartographie ou les recherches) sont listées dans les autres parties ci-après. Le tableau ci-dessous présente uniquement les changements (type de champ, formatage du résultat, ...) ou les ajouts (champs calculés, filtre, ...) non présents dans la donnée source. 

## GeoTable : `xapps_geo_v_pei_ctr`

|Attributs| Champ calculé | Formatage |Renommage|Particularité/Usage|Utilisation|Exemple|
|:---|:-:|:-:|:---|:---|:---|:---|
|affiche_info_bulle|x|x||Définit le contenu de l'info bulle affichée au survol d'un PEI|Cartographie|`CASE WHEN {id_sdis} is null or {id_sdis} ='' THEN 'N° SDIS : non renseigné' ELSE 'N° SDIS : ' {id_sdis} END`|
|cs_sdis ||x|Centre de secours de 1er appel|Liste de domaine  lt_pei_cs_sdis liée|Fiche d'information PEI||
|date_ct  |||Date du dernier contrôle technique||Fiche d'information PEI||
|date_maj ||x|Date de mise à jour|Prédéfini dd/mm/aaaa|Fiche d'information PEI||
|date_mes   ||x|Date de mise en service|Prédéfini dd/mm/aaaa|Fiche d'information PEI||
|date_sai   ||x|Date de saisie|Prédéfini dd/mm/aaaa|Fiche d'information PEI||
|debit   |||Débit||Fiche d'information PEI||
|debit_max ||Débit Max|||Fiche d'information PEI||
|debit_r_ci  ||Débit de remplissage|||Fiche d'information PEI||
|delegat   ||x|Délégataire|Liste de domaine   lt_pei_delegat liée|Fiche d'information PEI||
|diam_cana    |||Diamètre de canalisation||Fiche d'information PEI||
|diam_pei     |||Diamètre intérieur||Fiche d'information PEI||
|disponible     ||x|Disponible pour la DECI|Liste de domaine lt_pei_etat_boolean liée|Fiche d'information PEI||
|disponible_false      |x|x||Lien http du picto NON DISPONIBLE|Champ calculé `{disponible_img}` ||
|disponible_img       |x|x|Disponible|Champ IMAGE gérant l'affichage du picto selon la disponiblité DECI|Fiche d'information PEI|`CASE WHEN {disponible} = 't' THEN {disponible_true} WHEN {disponible} = 'f' THEN {disponible_false} END `|
|disponible_recherche      |x|x||Format HTML gérant l'affichage des pictos selon la disponiblité DECI des résultats après recherche|résultat recherche|`CASE WHEN {disponible} = 't' THEN '<img src="http://...." width=100 alt="" >' WHEN {disponible} = 'f' THEN '<img src="http://...." width=100 alt="">' END `|
|disponible_false      |x|x||Lien http du picto DISPONIBLE|Champ calculé `{disponible_img}` ||
|epci     |||Nom de l'EPCI||Fiche d'information PEI||
|etat_acces     ||x|Accès conforme|Liste de domaine lt_pei_etat_boolean liée|Fiche d'information PEI||
|etat_anom      ||x|Absence d'anomalie|Liste de domaine lt_pei_etat_boolean liée|Fiche d'information PEI||
|etat_conf      ||x|Conformité technique|Liste de domaine lt_pei_etat_boolean liée|Fiche d'information PEI||
|etat_pei      ||x|Etat|Liste de domaine lt_pei_etat_pei liée|Fiche d'information PEI||
|etat_sign      ||x|Signalisation conforme|Liste de domaine lt_pei_etat_boolean liée|Fiche d'information PEI||
|etiquette      |x|x||Gestion affichage étiquette sur la cartographie au niveau des pictos représentant les PEI|Cartographie |`CASE WHEN {type_pei}='NR' OR {etat_pei}='03' THEN NULL ELSE {type_pei} END`|
|gestion       ||x|Gestionnaire|Liste de domaine lt_pei_gestion liée|Fiche d'information PEI||
|id_contrat       ||x|Référence du contrat de sous traitance|Liste de domaine lt_pei_id_contrat liée|Fiche d'information PEI||
|id_pei       |||Identifiant||Fiche d'information PEI||
|id_sdis        |||n° SDIS||Fiche d'information PEI||
|lt_anom        |||Anomalie(s)||Fiche d'information PEI||
|marque        ||x||Liste de domaine lt_pei_marque liée|Fiche d'information PEI||
|nom_etab        |||Nom de l'établissement||Fiche d'information PEI||
|observ        |||Observations||Fiche d'information PEI||
|ope_ct         |||Opérateur du contrôle||Fiche d'information PEI||
|ope_sai         |||Opérateur de saisie||Fiche d'information PEI||
|photo_url         ||x|Photo|Lien avec texte de remplacement (Cliquez ici pour visualiser le PEI)|Fiche d'information PEI||
|prec         |||Précision||Fiche d'information PEI||
|press_dyn         |||Pression dynamique||Fiche d'information PEI||
|ref_terr          |||Référence sur le terrain||Fiche d'information PEI||
|resultat          |x|x|Résultat|Formatage du contenu informatif du résultat d'une recherche|Résultat de recherches|`CASE WHEN {id_sdis} IS NULL THEN CONCAT('PEI n°',{id_pei}) ELSE CONCAT('PEI n°',{id_pei},' - SDIS n°',{id_sdis}) END`|
|source_pei         |||Source||Fiche d'information PEI||
|src_date         |||Date du référentiel||Fiche d'information PEI||
|src_pei         |||Source de la donnée||Fiche d'information PEI||
|style          |x|x||Création d'un attribut style pour la réprésentation des PEI selon le statut, l'état ou la disponibilité du PEI |Cartographies|`CASE -- pei statut non renseigné WHEN {statut}='00' THEN 'Snr' -- pei statut privé WHEN {statut}='02' AND {etat_pei} IN ('00','01','02') THEN 'Spri_Enr-proj-exi' -- pei statut privé WHEN {statut}='02' AND {etat_pei}='03' THEN 'Spri_Esup' -- pei statut public et état projet ou non renseigné WHEN {statut}='01' AND {etat_pei} IN ('00','01') THEN 'Spub_Enr-proj' -- pei statut public supprimé WHEN {statut}='01' AND {etat_pei}='03' THEN 'Spub_Esup' -- pei statut public existant et dispo non renseignée WHEN {statut}='01' AND {etat_pei}='02' AND {disponible}='0' THEN 'Spub_Eexi_Dnr' -- pei statut public existant et conforme WHEN {statut}='01' AND {etat_pei}='02' AND {disponible}='t' THEN 'Spub_Eexi_Dt' -- pei statut public existant et non conforme WHEN {statut}='01' AND {etat_pei}='02' AND {disponible}='f' THEN 'Spub_Eexi_Df' END `|
|type_pei         |||Type||Fiche d'information PEI||
|type_rd         |||Type dans le règlement départemental||Fiche d'information PEI||
|verrou         ||x||Booléen Oui pour vrai et Non pour faux|Fiche d'information PEI||
|x_l93         |||Coordonnée X (L93)||Fiche d'information PEI||
|y_l93         |||Coordonnée Y (L93)||Fiche d'information PEI||


   * filtres :

|Nom|Attribut| Au chargement | Type | Condition |Valeur|Description|
|:---|:---|:-:|:---:|:---:|:---|:---|
|PEI_SECU_PRESTA|id_contrat|x|Alphanumérique|est égale à une valeur de contaxte|id_presta|Permet de filtrer l'affichage des PEI en fonction des contrats affectés au profil de connexion du ou des prestataires|
|DECI_SECU|insee|x|Alphanumérique|est égale à une valeur de contaxte|ccocom|Permet de filtrer l'affichage des PEI en fonction des communes autorisées pour chaque profil de connexion EPCI|
   
   * relations :

|Géotables ou Tables| Champs de jointure | Type |
|:---|:---|:---|
| xapps_geo_v_pei_ctr_erreur |id_pei| 0..1 (égal) |

   * particularité(s) : aucune

## GeoTable : `xapps_geo_v_pei_zonedefense`

|Attributs| Champ calculé | Formatage |Renommage|Particularité/Usage|Utilisation|Exemple|
|:---|:-:|:-:|:---|:---|:---|:---|

Sans objet

   * filtres :

|Nom|Attribut| Au chargement | Type | Condition |Valeur|Description|
|:---|:---|:-:|:---:|:---:|:---|:---|
|PEI_SECU_PRESTA|id_contrat|x|Alphanumérique|est égale à une valeur de contaxte|id_presta|Permet de filtrer l'affichage des PEI en fonction des contrats affectés au profil de connexion du ou des prestataires|
|DECI_SECU|insee|x|Alphanumérique|est égale à une valeur de contaxte|ccocom|Permet de filtrer l'affichage des PEI en fonction des communes autorisées pour chaque profil de connexion EPCI|

   * relations : aucune

   * particularité(s) : aucune
   
  
## Table : `xapps_geo_v_pei_ctr_erreur`

|Attributs| Champ calculé | Formatage |Renommage|Particularité/Usage|Utilisation|Exemple|
|:---|:-:|:-:|:---|:---|:---|:---|
|affiche_message    |x|x|null|Formate en HTML le message à afficher dans la fiche d'information en cas d'erreur selon un temps définit (évite un affichage permanent du message)|Fiche d'information PEI|`CASE WHEN extract(epoch from  now()::timestamp) - extract(epoch from {horodatage}::timestamp) <= 3 then '<table width=100%><td bgcolor="#FF000"> <font size=4 color="#ffffff"><center><b>' {erreur} '</b></center></font></td></table>' ELSE '' END`|


   * filtres : aucun
   * relations : aucune
   * particularité(s) : aucune
   


# Les fonctionnalités

Sont présentées ici uniquement les fonctionnalités spécifiques à l'application.

## Recherche globale : `Recherche dans la Base Adresse Locale`

Cette recherche permet à l'utilisateur de faire une recherche libre sur une adresse.

Cette recherche a été créée pour l'application RVA. Le détail de celle-ci est donc à visualiser dans le répertoire GitHub rva au niveau de la documentation applicative.

## Recherche globale : `Recherche d'une voie`

Cette recherche permet à l'utilisateur de faire une recherche libre sur le libellé d'une voie.

Cette recherche a été créée pour l'application RVA. Le détail de celle-ci est donc à visualiser dans le répertoire GitHub rva au niveau de la documentation applicative.
 

## Recherche (clic sur la carte) : `PEI par référence`

Cette recherche permet à l'utilisateur de cliquer sur la carte et de remonter les informations du PEI.

  * Configuration :

Source : `xapps_geo_v_pei_ctr`

|Attribut|Afficher|Rechercher|Suggestion|Attribut de géométrie|Tri des résultats|
|:---|:-:|:-:|:-:|:-:|:-:|
|Résultat|x|||||
|Type|x|||||
|Commune|x|||||
|disponible_recherche|x|||||
|geom||||x||
|id_pei|||||x|

(la détection des doublons n'est pas activée ici)

 * Filtres :

|Groupe|Jointure|Filtres liés|
|:---|:-:|:-:|
|Groupe de filtres par défaut|`OU`||

|Nom|Obligatoire|Attribut|Condition|Valeur|Champ d'affichage (1)|Champ de valeurs (1)|Champ de tri (1)|Ajout autorisé (1)|Particularités|
|:---|:-:|:---|:---|:---|:---|:---|:---|:-:|:---|
|PEI identifiant||id_pei|Prédéfinis - Filtre à valeur saisie||||||Titre : Numéro de PEI|
|PEI identifiant||id_sdis|Prédéfinis - Filtre à valeur saisie||||||Titre : Référence SDIS|

(1) si liste de domaine

 * Fiches d'information active : Fiche d'information PEI
 
## Recherche : `Toutes les recherches cadastrales`

L'ensemble des recherches cadastrales ont été formatées et intégrées par l'éditeur via son module GeoCadastre.
Seul le nom des certaines recherches a été modifié par l'ARC pour plus de compréhension des utilisateurs.

Cette recherche est détaillée dans le répertoire GitHub `docurba`.


## Recherche : `PEI public par disponibilité pour la DECI`

Cette recherche permet à l'utilisateur de faire une recherche guidée sur un PEI public en fonction de sa disponibilité pour la DECI.

  * Configuration :

Source : `xapps_geo_v_pei_ctr`

|Attribut|Afficher|Rechercher|Suggestion|Attribut de géométrie|Tri des résultats|
|:---|:-:|:-:|:-:|:-:|:-:|
|Résultat|x|||||
|Type|x|||||
|Commune|x|||||
|disponible_recherche|x|||||
|geom||||x||
|id_pei|||||x|

(la détection des doublons n'est pas activée ici)

 * Filtres :

|Groupe|Jointure|Filtres liés|
|:---|:-:|:-:|
|Groupe de filtres par défaut|`ET`||

|Groupe|Jointure|Filtres liés|
|:---|:-:|:-:|
|Groupe de filtres par défaut|`ET`|x|

|Nom|Obligatoire|Attribut|Condition|Valeur|Champ d'affichage (1)|Champ de valeurs (1)|Champ de tri (1)|Ajout autorisé (1)|Particularités|
|:---|:-:|:---|:---|:---|:---|:---|:---|:-:|:---|
|PEI disponible|x|disponible|Prédéfinis - Filtre à liste de choix||||||Titre : PEI disponible pour la DECI|
|PEI public||statut|Alphanumérique la valeur est égale à une valeur par défaut|00,01||||||

|Groupe|Jointure|Filtres liés|
|:---|:-:|:-:|
|Groupe de filtres par défaut|`ET`|x|

|Nom|Obligatoire|Attribut|Condition|Valeur|Champ d'affichage (1)|Champ de valeurs (1)|Champ de tri (1)|Ajout autorisé (1)|Particularités|
|:---|:-:|:---|:---|:---|:---|:---|:---|:-:|:---|
|PEI par EPCI||epci|Prédéfinis - Filtre à liste de choix||||||Titre : Nom de l'EPCI|
|PEI par commune||commune|Prédéfinis - Filtre à liste de choix||||||Titre : Nom de la commune|

(1) si liste de domaine

 * Fiches d'information active : Fiche d'information PEI
 
## Recherche : `PEI par date de contrôle`

Cette recherche permet à l'utilisateur de faire une recherche guidée sur un PEI en fonction d'une période de contrôle et d'un découpage administratif ou par rapport au gestionnaire ou d'un contrat.

  * Configuration :

Source : `xapps_geo_v_pei_ctr`

|Attribut|Afficher|Rechercher|Suggestion|Attribut de géométrie|Tri des résultats|
|:---|:-:|:-:|:-:|:-:|:-:|
|Résultat|x|||||
|Type|x|||||
|Commune|x|||||
|disponible_recherche|x|||||
|geom||||x||
|id_pei|||||x|

(la détection des doublons n'est pas activée ici)

 * Filtres :

|Groupe|Jointure|Filtres liés|
|:---|:-:|:-:|
|Groupe de filtres par défaut|`ET`||

|Groupe|Jointure|Filtres liés|
|:---|:-:|:-:|
|Groupe de filtres par défaut|`ET`|x|

|Nom|Obligatoire|Attribut|Condition|Valeur|Champ d'affichage (1)|Champ de valeurs (1)|Champ de tri (1)|Ajout autorisé (1)|Particularités|
|:---|:-:|:---|:---|:---|:---|:---|:---|:-:|:---|
|PEI par date de contrôle|x|date_ct|Alphanumérique la valeur est comprise entre une valeur 1 saisie||||||Titre invite 1 : Dernier controle effectué entre et Titre invite 2 : et|


|Groupe|Jointure|Filtres liés|
|:---|:-:|:-:|
|Groupe de filtres par défaut|`ET`|x|

|Nom|Obligatoire|Attribut|Condition|Valeur|Champ d'affichage (1)|Champ de valeurs (1)|Champ de tri (1)|Ajout autorisé (1)|Particularités|
|:---|:-:|:---|:---|:---|:---|:---|:---|:-:|:---|
|PEI par EPCI||epci|Prédéfinis - Filtre à liste de choix||||||Titre : Nom de l'EPCI|
|PEI par commune||commune|Prédéfinis - Filtre à liste de choix||||||Titre : Nom de la commune|

|Groupe|Jointure|Filtres liés|
|:---|:-:|:-:|
|Groupe de filtres par défaut|`ET`||

|Nom|Obligatoire|Attribut|Condition|Valeur|Champ d'affichage (1)|Champ de valeurs (1)|Champ de tri (1)|Ajout autorisé (1)|Particularités|
|:---|:-:|:---|:---|:---|:---|:---|:---|:-:|:---|
|PEI gestionnaire||gestion|Prédéfinis à liste de choix||||||Titre : Gestionnaire du PEI|

|Groupe|Jointure|Filtres liés|
|:---|:-:|:-:|
|Groupe de filtres par défaut|`ET`||

|Nom|Obligatoire|Attribut|Condition|Valeur|Champ d'affichage (1)|Champ de valeurs (1)|Champ de tri (1)|Ajout autorisé (1)|Particularités|
|:---|:-:|:---|:---|:---|:---|:---|:---|:-:|:---|
|PEI Contrat||id_contrat|Alphanumérique la valeur est égale à une valeur de liste de choix |lt_pei_id_contrat|valeur|code|valeur|x|Titre : N° de contrat et filtre non utilisable par le ou les prestataire(s)|

(1) si liste de domaine

 * Fiches d'information active : Fiche d'information PEI

## Recherche : `PEI par gestionnaire`

Cette recherche permet à l'utilisateur de faire une recherche guidée sur un PEI en fonciton du gestionnaire et du découpage administratif.

  * Configuration :

Source : `xapps_geo_v_pei_ctr`

|Attribut|Afficher|Rechercher|Suggestion|Attribut de géométrie|Tri des résultats|
|:---|:-:|:-:|:-:|:-:|:-:|
|Résultat|x|||||
|Type|x|||||
|Commune|x|||||
|disponible_recherche|x|||||
|geom||||x||
|id_pei|||||x|

(la détection des doublons n'est pas activée ici)

 * Filtres :

|Groupe|Jointure|Filtres liés|
|:---|:-:|:-:|
|Groupe de filtres par défaut|`ET`|x|

|Groupe|Jointure|Filtres liés|
|:---|:-:|:-:|
|Groupe de filtres par défaut|`ET`|x|

|Nom|Obligatoire|Attribut|Condition|Valeur|Champ d'affichage (1)|Champ de valeurs (1)|Champ de tri (1)|Ajout autorisé (1)|Particularités|
|:---|:-:|:---|:---|:---|:---|:---|:---|:-:|:---|
|PEI par EPCI|x|epci|Prédéfinis - Filtre à liste de choix||||||Titre : Nom de l'EPCI|
|PEI par commune||commune|Prédéfinis - Filtre à liste de choix||||||Titre : Nom de la commune|

|Groupe|Jointure|Filtres liés|
|:---|:-:|:-:|
|Groupe de filtres par défaut|`ET`||

|Nom|Obligatoire|Attribut|Condition|Valeur|Champ d'affichage (1)|Champ de valeurs (1)|Champ de tri (1)|Ajout autorisé (1)|Particularités|
|:---|:-:|:---|:---|:---|:---|:---|:---|:-:|:---|
|PEI gestionnaire|x|gestion|Prédéfinis à liste de choix||||||Titre : Gestionnaire du PEI|

(1) si liste de domaine

 * Fiches d'information active : Fiche d'information PEI
 
 ## Recherche : `PEI par état d'actualité`

Cette recherche permet à l'utilisateur de faire une recherche guidée sur un PEI par son état d'actualité et un découpage adminsitratif.

  * Configuration :

Source : `xapps_geo_v_pei_ctr`

|Attribut|Afficher|Rechercher|Suggestion|Attribut de géométrie|Tri des résultats|
|:---|:-:|:-:|:-:|:-:|:-:|
|Résultat|x|||||
|Type|x|||||
|Commune|x|||||
|disponible_recherche|x|||||
|geom||||x||
|id_pei|||||x|

(la détection des doublons n'est pas activée ici)

 * Filtres :

|Groupe|Jointure|Filtres liés|
|:---|:-:|:-:|
|Groupe de filtres par défaut|`ET`||


|Groupe|Jointure|Filtres liés|
|:---|:-:|:-:|
|Groupe de filtres par défaut|`ET`|x|

|Nom|Obligatoire|Attribut|Condition|Valeur|Champ d'affichage (1)|Champ de valeurs (1)|Champ de tri (1)|Ajout autorisé (1)|Particularités|
|:---|:-:|:---|:---|:---|:---|:---|:---|:-:|:---|
|PEI par état d'actualité|x|etat_pei|Prédéfinis à liste de choix||||||Titre : Etat d'actualité du PEI|

|Groupe|Jointure|Filtres liés|
|:---|:-:|:-:|
|Groupe de filtres par défaut|`ET`|x|

|Nom|Obligatoire|Attribut|Condition|Valeur|Champ d'affichage (1)|Champ de valeurs (1)|Champ de tri (1)|Ajout autorisé (1)|Particularités|
|:---|:-:|:---|:---|:---|:---|:---|:---|:-:|:---|
|PEI par EPCI||epci|Prédéfinis - Filtre à liste de choix||||||Titre : Nom de l'EPCI|
|PEI par commune||commune|Prédéfinis - Filtre à liste de choix||||||Titre : Nom de la commune|


(1) si liste de domaine

 * Fiches d'information active : Fiche d'information PEI
 
## Recherche : `PEI par caractéristiques techniques`

Cette recherche permet à l'utilisateur de faire une recherche guidée sur un PEI par ses caractéristiques techniques et un découpage adminsitratif.

  * Configuration :

Source : `xapps_geo_v_pei_ctr`

|Attribut|Afficher|Rechercher|Suggestion|Attribut de géométrie|Tri des résultats|
|:---|:-:|:-:|:-:|:-:|:-:|
|Résultat|x|||||
|Type|x|||||
|Commune|x|||||
|disponible_recherche|x|||||
|geom||||x||
|id_pei|||||x|

(la détection des doublons n'est pas activée ici)

 * Filtres :

|Groupe|Jointure|Filtres liés|
|:---|:-:|:-:|
|Groupe de filtres par défaut|`ET`||


|Groupe|Jointure|Filtres liés|
|:---|:-:|:-:|
|Groupe de filtres par défaut|`ET`||

|Nom|Obligatoire|Attribut|Condition|Valeur|Champ d'affichage (1)|Champ de valeurs (1)|Champ de tri (1)|Ajout autorisé (1)|Particularités|
|:---|:-:|:---|:---|:---|:---|:---|:---|:-:|:---|
|PEI par type||type_pei|Prédéfinis à liste de choix||||||Titre : Type de PEI|
|PEI par diam_pei||diam_pei|Prédéfinis à liste de choix||||||Titre : Diamètre intérieur|
|PEI par source||source|Prédéfinis à liste de choix||||||Titre : Source du point d'eau|
|PEI par raccord||raccord|Prédéfinis à liste de choix||||||Titre : Raccords de sortie|
|PEI par marque||marque|Prédéfinis à liste de choix||||||Titre : Marque du matériel|

|Groupe|Jointure|Filtres liés|
|:---|:-:|:-:|
|Groupe de filtres par défaut|`ET`|x|

|Nom|Obligatoire|Attribut|Condition|Valeur|Champ d'affichage (1)|Champ de valeurs (1)|Champ de tri (1)|Ajout autorisé (1)|Particularités|
|:---|:-:|:---|:---|:---|:---|:---|:---|:-:|:---|
|PEI par EPCI||epci|Prédéfinis - Filtre à liste de choix||||||Titre : Nom de l'EPCI|
|PEI par commune||commune|Prédéfinis - Filtre à liste de choix||||||Titre : Nom de la commune|

|Groupe|Jointure|Filtres liés|
|:---|:-:|:-:|
|Groupe de filtres par défaut|`ET`|x|

|Nom|Obligatoire|Attribut|Condition|Valeur|Champ d'affichage (1)|Champ de valeurs (1)|Champ de tri (1)|Ajout autorisé (1)|Particularités|
|:---|:-:|:---|:---|:---|:---|:---|:---|:-:|:---|
|PEI gestionnaire||gestion|Prédéfinis à liste de choix||||||Titre : Gestionnaire du PEI|

|Groupe|Jointure|Filtres liés|
|:---|:-:|:-:|
|Groupe de filtres par défaut|`ET`|x|

|Nom|Obligatoire|Attribut|Condition|Valeur|Champ d'affichage (1)|Champ de valeurs (1)|Champ de tri (1)|Ajout autorisé (1)|Particularités|
|:---|:-:|:---|:---|:---|:---|:---|:---|:-:|:---|
|PEI Contrat||id_contrat|Alphanumérique la valeur est égale à une valeur de liste de choix |lt_pei_id_contrat|valeur|code|valeur|x|Titre : N° de contrat et filtre non utilisable par le ou les prestataire(s)|

(1) si liste de domaine

 * Fiches d'information active : Fiche d'information PEI
 
## Recherche : `PEI par commune`

Cette recherche permet à l'utilisateur de faire une recherche guidée sur un PEI par sa commune de positionnement.

  * Configuration :

Source : `xapps_geo_v_pei_ctr`

|Attribut|Afficher|Rechercher|Suggestion|Attribut de géométrie|Tri des résultats|
|:---|:-:|:-:|:-:|:-:|:-:|
|Résultat|x|||||
|Type|x|||||
|Commune|x|||||
|disponible_recherche|x|||||
|geom||||x||
|id_pei|||||x|

(la détection des doublons n'est pas activée ici)

 * Filtres :

|Groupe|Jointure|Filtres liés|
|:---|:-:|:-:|
|Groupe de filtres par défaut|`ET`|x|


|Groupe|Jointure|Filtres liés|
|:---|:-:|:-:|
|Groupe de filtres par défaut|`ET`|x|

|Nom|Obligatoire|Attribut|Condition|Valeur|Champ d'affichage (1)|Champ de valeurs (1)|Champ de tri (1)|Ajout autorisé (1)|Particularités|
|:---|:-:|:---|:---|:---|:---|:---|:---|:-:|:---|
|PEI par EPCI||epci|Prédéfinis - Filtre à liste de choix||||||Titre : Nom de l'EPCI|
|PEI par commune||commune|Prédéfinis - Filtre à liste de choix||||||Titre : Nom de la commune|

(1) si liste de domaine

 * Fiches d'information active : Fiche d'information PEI
 
 ## Recherche : `PEI par contrat`

Cette recherche permet à l'utilisateur de faire une recherche guidée sur un PEI par son contrat de contrôle.
Ce filtre n'est pas accessible au(x) prestataire(s).

  * Configuration :

Source : `xapps_geo_v_pei_ctr`

|Attribut|Afficher|Rechercher|Suggestion|Attribut de géométrie|Tri des résultats|
|:---|:-:|:-:|:-:|:-:|:-:|
|Résultat|x|||||
|Type|x|||||
|Commune|x|||||
|disponible_recherche|x|||||
|geom||||x||
|id_pei|||||x|

(la détection des doublons n'est pas activée ici)

 * Filtres :

|Nom|Obligatoire|Attribut|Condition|Valeur|Champ d'affichage (1)|Champ de valeurs (1)|Champ de tri (1)|Ajout autorisé (1)|Particularités|
|:---|:-:|:---|:---|:---|:---|:---|:---|:-:|:---|
|PEI Contrat|x|id_contrat|Alphanumérique la valeur est égale à une valeur de liste de choix |lt_pei_id_contrat|valeur|code|valeur|x|Titre : N° de contrat et filtre non utilisable par le ou les prestataire(s)|

(1) si liste de domaine

 * Fiches d'information active : Fiche d'information PEI

## Fiche d'information : `Fiche d'information PEI`

Source : `xapps_geo_v_pei_ctr`

* Statistique : aucune
 
 * Représentation :
 
|Mode d'ouverture|Taille|Agencement des sections|
|:---|:---|:---|
|dans le gabarit|530x650|Accordéon|

|Nom de la section|Attributs|Position label|Agencement attribut|Visibilité conditionnelle|Fichie liée|Ajout de données autorisé|
|:---|:---|:---|:---|:---|:---|:---|
|Général|affiche_message|masqué|Vertical||||

|Nom de la sous-section|Attributs|Position label|Agencement attribut|Visibilité conditionnelle|Fichie liée|Ajout de données autorisé|
|:---|:---|:---|:---|:---|:---|:---|
|(vide)|n° SDIS (id_sdis),Identifiant(id_pei),Verrou (verrou),Référence sur le terrain (ref_terr),Nom de l'EPCI (epci),Insee (insee),Commune (commune),Type (type_pei),Type dans le règlement départemental (type_rd),Situation (situation),Disponible (disponible_img),Etat (etat_pei)|à gauche|Vertical||||



 * Saisie : aucune

 * Modèle d'impression : Fiche standard + carte

 
## Analyse :

Aucune

## Statistique :

Aucune

## Modification géométrique : `Ajouter ou déplacer un PEI`

Cette recherche permet à l'utilisateur de saisir ou modifier l'emplacement d'un PEI.
Cette fonctionnalité n'est accessible au(x) prestataire(s).

  * Configuration :
  
Source : `xapps_geo_v_pei_ctr`

 * Filtres : aucun
 * Accrochage : aucun
 * Fiches d'information active : Fiche d'informationPEI
 * Topologie : aucune 
 
 # La cartothèque

|Groupe|Sous-groupe|Visible dans la légende|Visible au démarrage|Détails visibles|Déplié par défaut|Geotable|Renommée|Issue d'une autre carte|Visible dans la légende|Visible au démarrage|Déplié par défaut|Couche sélectionnable|Couche accrochable|Catégorisation|Seuil de visibilité|Symbologie|Autres|
|:---|:---|:-:|:-:|:-:|:-:|:---|:---|:-:|:-:|:-:|:-:|:-:|:---|:---|:---|:---|:---|
|||||||geo_rva_signal|Suivi des signalements||x|x|x||x|traite_sig||Symbole signalement_rouge.svg pour Nvlle demande et signalement_orange.svg pour Prise en compte,taille 25|Interactivité avec le champ infobulle|
|||||||geo_v_osm_commune_apc|Limite communale|||x||||||Contour marron épais||
|Adresse||x|x|x|x|xapps_geo_vmr_adresse|Conformité||x|x|x|||affiche_qual_adr|0 à 1999è|Couleur par conformité|Interactivité avec le champ infobulle|
|Adresse||x|x|x|x|xapps_geo_vmr_adresse|Points d'adresse||x|x|||||1999 à 10000è|Carré bleu de taille 5|Interactivité avec le champ infobulle (avec seuil de zoom de 1999 à 5000è)|
|Voie||x|x|x|x|xapps_geo_v_voie|Voie (agrégée pour clic carte)|||x|||||0 à 100 000è|aucune symbologie||
|Voie||x|x|x|x|xapps_geo_v_troncon_voirie|Tronçon (pour clic carte)|||x|||||0 à 100 000è|aucune symbologie||
|Voie|Tronçons|x||||geo_objet_noeud|Noeuds||x|x|||x||0 à 50 000è|Point gris de taille 3||
|Voie|Tronçons|x||||xapps_geo_v_troncon_voirie|Tronçons||x|x|||x||0 à 50 000è|trait de 0.5 noir||
|Voie||x|x|x|x|xapps_geo_v_troncon_voirie|Statut juridique des voies||x|||||statut_jur|0 à 50000è|Couleur par statut|Interactivité avec le champ voie_info_bulle (avec seuil de zoom de 0 à 25000è)|
|Voie||x|x|x|x|xapps_geo_v_troncon_voirie|Gestionnaire des voies||x|x|x|||gestion|0 à 50000è|Couleur par gestionnaire|Interactivité avec le champ voie_info_bulle (avec seuil de zoom de 0 à 25000è)|
|Voie||x|x|x|x|xapps_geo_v_troncon_voirie|Domanialité||x|||||doman|0 à 50000è|Couleur par domanialité|Interactivité avec le champ voie_info_bulle (avec seuil de zoom de 0 à 25000è)|

# L'application

* Généralités :

|Gabarit|Thème|Modules spé|Impression|Résultats|
|:---|:---|:---|:---|:---|
|Pro|Thème GeoCompiegnois 1.0.7|StreetView,GeoCadastre (V3),Google Analytics,Page de connexion perso, Export Fonctionnalités (Adresse),Multimédia (signalement Voie/Adresse),javascript|8 Modèles standards A4 et A3||

* Particularité de certains modules :
  * Module introduction : ce menu s'ouvre automatiquement à l'ouverture de l'application grâce un code dans le module javascript. Ce module contient une introduction sur l'application, et des liens vers des fiches d'aide.
  * Module javacript : 
  `var injector = angular.element('body').injector();
var acfApplicationService = injector.get('acfApplicationService');
acfApplicationService.whenLoaded(setTimeout(function(){
$(".sidepanel-item.launcher-application").click();
}, 100));`
  * Module Google Analytics : le n° ID est disponible sur le site de Google Analytics
  * Module Export Fonctionnalité : ce module permet l'export des données issues de recherche

|Type d'export|
|:---|
|D'après la liste|

|Fonctionnalités exportables|
|:---|
|Recherche, export des adresses par nombre de logements à la commune|
|Recherche, export des adresses par qualité, diagnostic à la commune|
|Tronçon de voie par statut juridique|
|Exporter la synthèse communale selon le gestionnaire|
|Exporter la synthèse communale selon la domanialité|
|Exporter la synthèse communale selon le statut juridique|
|Exporter la base de données des tronçons|
|Recherche, export de la base Adresses (par commune et voie)|

* Recherche globale :

|Noms|Tri|Nb de sugggestion|Texte d'invite|
|:---|:---|:---|:---|
|Recherche dans la Base Adresse Locale,Recherche d'une voie, Localiser un équipement|alpha|15|Rechercher une adresse, une voie,  un équipement, ...|

* Carte : `RVA`

Comportement au clic : (dés)active uniquement l'item cliqué
Liste des recherches : Recherche dans la Base Adresse Locale, Recherche tronçon, Signalement voie/adresse, Recherche avancée d'une voie, Parcelle(s) sélectionnée(s) (description : GeoCadastre V3)

* Fonds de plan :

|Nom|Au démarrage|opacité|
|:---|:---|:---|
|Cadastre|x|80%|
|Plan de ville|x|60%|
|Photographie aérienne 2013|x|80%|

* Fonctionnalités

|Groupe|Nom|
|:---|:---|
|Recherche cadastrale (V3)||
||Parcelles par référence|
||Parcelles par adresse fiscale (V3)|
||Parcelles par nom du propriétaire (V3) (non disponible pour l'application URBANISME)|
||Parcelles multicritères (V3)|
||Parcelles par nom du propriétaire d'un local (V3) (non disponible pour l'application URBANISME)|
||Parcelles par surface (V3)|
|Signalement||
||Faire un signalement d'adresses ou de voies|
||Recherche un signalement par commune|
|Adresse (recherche avancée et export)||
||Recherche avancée d'une adresse|
||Recherche d'une ancienne adresse|
||Recherche, export de la base adresses (par commune et voie)|
||Recherche, export des adresses par qualité, diagnostic à la commune|
||Recherche, export des adresses par nombre de logements à la commune|
|Voie (recherche avancée et export)||
||Recherche avancée d'une voie|
|Recherche par statut juridique (par tronçon)||
||Tronçon de voie par statut juridique|
||Exporter la synthèse communale selon le statut juridique|
|Recherche par domanialité (par tronçon)||
||Tronçon de voie par domanialité|
||Exporter la synthèse communale selon la domanialité|
|Recherche par gestionnaire (par tronçon)||
||Tronçon de voie par gestionnaire|
||Exporter la synthèse communale selon la gestionnaire|
|Recherche par restrictions de circulation||
||Vitesse maximum autorisée|
||Autres restrictions de circulation|
|(pas dans un groupe)|Exporter les données des tronçons|
|(pas dans un groupe)|Exporter la liste des voies (avec linéaire)|

