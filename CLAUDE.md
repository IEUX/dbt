# CLAUDE.md — Projet dbt (my_new_project)

Contexte pour assistant IA travaillant sur ce projet dbt. Pipeline analytics
sur **BigQuery** (projet `fivetran-494712`, région **EU**), couvrant un dataset
e-commerce interne et deux sources externes, plus un pipeline Spotify séparé.

---

## 1. Architecture des couches

```
staging      → sources brutes nettoyées (1 modèle par table source)
intermediate → premières transformations + jointures par source
mart         → tables finales reliant les sources, exposées aux dashboards
```

Convention de nommage :
- `stg_<source>__<table>`
- `int_<source>__<objet>`
- `mrt_<objet>` ou `mrt_<source>__<objet>`

---

## 2. Sources (`sources.yml`)

| name (dbt)          | schema (dataset BQ)   | tables |
|---------------------|-----------------------|--------|
| `sales_database`    | `sales_database`      | feedback, payment, product, order, order_item, seller, user |
| `google_analytics_4`| `google_analytics_4`  | events_20210131 |
| `google_sheets`     | `google_sheets`       | account_manager_region_mapping |
| `spotify`           | `spotify`             | songs, listening_data |

> Le `schema:` doit correspondre **exactement** au nom du dataset BigQuery.
> Fivetran renomme parfois les datasets — vérifier via
> `INFORMATION_SCHEMA.TABLES` en cas de `404 not found`.

---

## 3. Décisions de schéma importantes (sales_database)

Particularités du dataset à **garder en mémoire** (sources de la plupart des bugs) :

- **Pas de `user_id`** → l'identifiant utilisateur est `user_name`
  (PK de `user`, FK dans `order`).
- **Pas de `order_item_id`** → PK de `order_item` reconstruite :
  `concat(order_id, '-', product_id, '-', seller_id)`.
- **`payment`** : PK reconstruite `concat(order_id, '-', payment_sequential)`.
- **Codes postaux** (`seller_zip_code`, `customer_zip_code`) : INTEGER en source,
  castés en **STRING** (identifiants, pas des nombres).
- **`product`** : noms de colonnes corrigés `lenght → length` ; les compteurs
  (`name_length`, `description_length`, `photos_qty`) castés FLOAT → INT64 ;
  les dimensions (`_cm`, `_g`) restent FLOAT.
- **`user`** : colonnes `customer_*` renommées `user_*` ; colonne technique
  `row_num` supprimée.
- **Champs Fivetran ignorés** partout : `ctid_fivetran_id`, `_fivetran_synced`,
  `_row` (artefacts d'ingestion, pas de données métier).
- La plupart des dates sont déjà typées TIMESTAMP par Fivetran → peu de casts
  nécessaires côté sales_database (contrairement aux premiers TD où tout
  arrivait en STRING).

---

## 4. Inventaire des modèles

### Staging
- `stg_sales_database__{feedback,order,order_item,payment,product,seller,user}`
  — sélection explicite, renommage, cast si besoin, PK (native ou construite),
  `select distinct`.
- `stg_google_analytics__event` — aplatissement GA4 ; 3 champs unnestés depuis
  `event_params` (ga_session_id, page_title, page_location) ;
  `event_timestamp` converti via `TIMESTAMP_MICROS` ;
  `event_date` via `PARSE_DATE('%Y%m%d', ...)`.
- `stg_google_sheets__account_manager_region_mapping` — garde `state` +
  `account_manager` ; PK = `state`.
- `stg_spotify__songs` — artist/title en UPPER, genre NULL → 'Unknown'.
- `stg_spotify__listening_data` — listen_date cast en DATE,
  minutes_listened NULL → 0.

### Intermediate
- `int_sales_database__order` — order enrichi : location user, feedback moyen,
  montant total, total_items, total_distinct_items (joins user/order_item/feedback).
- `int_sales_database__user` — agrégat par user (total_order, total_amount_order),
  construit **au-dessus** de `int_sales_database__order` (DRY).
- `int_google_analytics__session` — agrégation event → session
  (durée, browser, traffic, event_count, pages_viewed) ;
  `unique_session_id = concat(user_pseudo_id, ga_session_id)`.
- `int_spotify__song_listening` — join songs/listening, filtré sur 2 ans.

### Mart
- `mrt_order_daily_report` — `materialized='table'`. Métriques par jour /
  account_manager / user_state. **Jointure clé : `user_state = state`** de la
  Google Sheet (l'« état de la commande » de l'énoncé = état géographique du
  client, pas `order_status`).
- `mrt_spotify__top_artists` — `materialized='table'`. Top 20 artistes par
  minutes écoutées (desc).

---

## 5. Tests & documentation (TD9)

- **Descriptions en anglais** (exigence de l'énoncé).
- **Staging** : descriptions inline dans `schema.yml` (PK, FK, colonnes calculées).
- **Intermediate / mart** : un `.yml` + un `.md` par modèle, même nom que le
  modèle, même dossier. Description longue via `{% docs %}` + `{{ doc("...") }}`.
- **Tests génériques** (staging) :
  - PK : `unique` + `not_null`.
  - `accepted_values` sur `order_status`, `payment_type`
    (⚠️ valider les listes via `select distinct`).
  - `relationships` sur les FK → vérifie l'intégrité référentielle
    (aucune FK orpheline). Tests nommés via `name:`.
- **Tests singuliers** (`tests/*.sql`, passent si 0 ligne) :
  - `assert_order_item_amount_not_negative` — montant de ligne ≥ 0.
  - `assert_order_dates_chronology` — approbation/livraison ≥ création.

---

## 6. Gotchas opérationnels

- **Erreur `404 not found in location EU`** : soit le `schema:` ne matche pas le
  vrai nom de dataset, soit la table est en **US** (cas de l'échantillon GA4
  public). Cross-région interdit pour `bq cp` / `CREATE TABLE AS`.
  → Recopier via **BigQuery Data Transfer Service** (préserve le nested), ou
  export **Avro/Parquet** (jamais CSV avec des STRUCT/ARRAY) puis `bq load` en EU.
- **`Unrecognized name`** : le fichier sur disque ne correspond pas au schéma
  réel de la table (souvent un vieux template). Vérifier les colonnes exactes.
- Toujours partir des **vrais noms de colonnes** (INFORMATION_SCHEMA), ne jamais
  les inventer — l'énoncé impose d'expliciter chaque colonne (pas de `SELECT *`).

---

## 7. Commandes utiles

```bash
dbt run                              # tout
dbt run -s <model>                   # un modèle (dépendances via ref())
dbt run -s stg_sales_database__order_item
dbt test                             # tous les tests
dbt debug                            # vérifier la connexion BigQuery
```
