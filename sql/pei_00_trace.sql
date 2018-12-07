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
2018-11-19 : GB / Modification de la structure, le champ debit_r_ci passe de la table an_pei_ctr à la table geo_pei car il s'agit d'une caractéristique technique. Modification dans les vues et trigger au besoin.
2018-11-22 : GB / Modification triggres des vues concernant le état de conformité sur les caractéristiques techniques des citernes
2018-11-26 : GB / Modification des triggers pour le DELETE (seules les valeurs modifiées sont conservées, les variables = old.variable sont inutiles car un update est utilisé
2018-12-07 : GB / Réorganisation du code SQL en éclatant par fichier de procédure

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
