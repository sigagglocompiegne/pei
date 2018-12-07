![GeoCompiegnois](doc/img/Logo_web-GeoCompiegnois.png)

# Point d'Eau Incendie

Ensemble des éléments constituant la mise en oeuvre d'une application websig de gestion patrimoniale et des contrôles techniques des Points d'Eau Incendie (PEI) :

- Script d'initialisation de la base de données
  * [Suivi et exécution des scripts sql](sql/pei_00_trace.sql)
  * [Création du schéma](sql/pei_10_schema.sql)
  * [Création des séquences](sql/pei_20_seq.sql)
  * [création des table de liste de valeur](sql/pei_30_listes.sql)
  * [Insertion des valeurs de liste](sql/pei_31_inserts.sql)
  * [Création des tables](sql/pei_40_tables.sql)
  * [Création des index](sql/pei_50_index.sql)
  * [Création des vues de gestion](sql/pei_60_vues_gestion.sql)
  * [Création des vues applicatives](sql/pei_61_vues_xapps.sql)
  * [Création des vues applicatives gd public](sql/pei_62_vues_xapps_public.sql)
  * [Création des vues open data](sql/pei_63_vues_xopendata.sql)
  * [Création des triggers](sql/pei_70_triggers.sql)
  * [Création des privilèges](sql/pei_99_grant.sql)
- [Script d'initialisation des dépendances de la base de données](sql/init_bd_pei_dependencies.sql)
- [Documentation d'administration de la base de données](doc/doc_admin_bd_pei.md)
- [Documentation d'administration de l'application](doc/doc_admin_app_pei.md)
- [Documentation utilisateur de l'application](doc/doc_user_app_pei.md)
