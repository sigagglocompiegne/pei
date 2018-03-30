![GeoCompiegnois](img/Logo_web-GeoCompiegnois.png)

# Documentation technique de l'application PEI

* Statut
  - [x] à rédiger
  - [ ] relecture
  - [ ] finaliser
  - [ ] révision
  
* Historique des versions

|Date | Auteur | Description
|:---|:---|:---|
|29/03/2018|Florent VANHOUTTE|version initiale|

## Data

### Champs calculés

-- etiquette
`CASE WHEN {type_pei}=NR THEN NULL ELSEE {type_pei} END`
-- texte brut

-- disponible_false
`http://geo.compiegnois.fr/documents/metiers/deci/cc_nonconforme.png`
-- type image

-- disponible_true
`http://geo.compiegnois.fr/documents/metiers/deci/cc_conforme.png`
-- type image

-- disponible_img
`CASE WHEN {disponible} = 't' THEN {disponible_true} 
WHEN {disponible} = 'f' THEN {disponible_false} END`
-- type image

-- style

-- V2 : par disponibilité

`CASE
-- pei statut non renseigné
WHEN {statut}='00' THEN 'Snr'
-- pei statut privé
WHEN {statut}='02' AND {etat_pei} IN ('00','01',02') THEN 'aaa'
-- pei statut privé
WHEN {statut}='02' AND {etat_pei}='03' THEN 'bbb'
-- pei statut public et état projet ou non renseigné
WHEN {statut}='01' AND {etat_pei} IN ('00','01') THEN 'ccc'
-- pei statut public supprimé
WHEN {statut}='01' AND {etat_pei}='03' THEN 'ddd'
-- pei statut public existant et dispo non renseignée
WHEN {statut}='01' AND {etat_pei}='02' AND {disponible}='0' THEN 'eee'
-- pei statut public existant et conforme
WHEN {statut}='01' AND {etat_pei}='02' AND {disponible}='t' THEN 'fff'
-- pei statut public existant et non conforme
WHEN {statut}='01' AND {etat_pei}='02' AND {disponible}='f' THEN 'ggg' 
END`

## Fonctionnel

## Cartothèque

## Application
