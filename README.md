# 2026 World Cup - BigQuery SQL Analytics Pipeline

A data quality and analytics project built on 2026 FIFA World Cup match data using Google BigQuery and SQL.

## What this project does
- Designed a two-table schema (`teams`, `matches`) in BigQuery
- Ran 5 automated data quality checks - 100% pass rate (zero duplicates, nulls, referential integrity issues, invalid scores, or date errors)
- Built analytics queries covering team performance, goal trends, and knockout drama
- Applied advanced SQL: self-joins, window functions (`RANK`, `LAG`), `CASE WHEN` classification, and correlated subqueries

## Tech stack
Google BigQuery, SQL

## Key findings
- England and Argentina led the tournament with 9 goals each - nearly 3x the tournament average of 3.2 goals/team
- Belgium's knockout-stage scoring average (3.5 goals/match) was more than 3x their group-stage average (1.0)
- Argentina showed the most consistent scoring - steady goal output across consecutive matches with zero drop-off
- A significant share of group-stage matches were decided by a single goal, classified via a custom "match drama" query

## Repository structure
