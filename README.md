![GeoCompiegnois](doc/img/Logo_web-GeoCompiegnois.png)

# Point d'Eau Incendie

Ensemble des éléments constituant la mise en oeuvre d'une application websig de gestion patrimoniale et des contrôles techniques des Points d'Eau Incendie (PEI) :

- Script d'initialisation de la base de données
  * [Suivi des modifications](sql/pei_00_trace.sql)
  * [Création  de la structure initiale](sql/pei_10_squelette.sql)
  * [Création des vues de gestion](sql/pei_20_vues_gestion.sql)
  * [Création des vues applicatives](sql/pei_21_vues_xapps.sql)
  * [Création des vues applicatives gd public](sql/pei_22_vues_xapps_public.sql)
  * [Création des vues open data](sql/pei_23_vues_xopendata.sql)
  * [Création des privilèges](sql/pei_99_grant.sql)
- [Script d'initialisation des dépendances de la base de données](sql/init_bd_pei_dependencies.sql)
- [Documentation d'administration de la base de données](doc/doc_admin_bd_pei.md)
- [Documentation d'administration de l'application](doc/doc_admin_app_pei.md)
- [Documentation utilisateur de l'application](doc/doc_user_app_pei.md)
