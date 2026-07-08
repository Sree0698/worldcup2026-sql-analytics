-- ============================================
-- Data Quality Checks — 2026 World Cup Matches
-- All checks below return 0 rows on clean data
-- ============================================

-- 1. Duplicate match_id check
SELECT match_id, COUNT(*) AS occurrences
FROM `worldcup2026-analytics.wc2026_dq_project.matches`
GROUP BY match_id
HAVING COUNT(*) > 1;

-- 2. Null / missing critical fields check
SELECT match_id, team_home, team_away, score_home, score_away
FROM `worldcup2026-analytics.wc2026_dq_project.matches`
WHERE team_home IS NULL OR team_away IS NULL
   OR score_home IS NULL OR score_away IS NULL
   OR match_date IS NULL;

-- 3. Referential integrity: every team in matches must exist in teams table
SELECT DISTINCT team_home AS unmatched_team
FROM `worldcup2026-analytics.wc2026_dq_project.matches`
WHERE team_home NOT IN (SELECT team_name FROM `worldcup2026-analytics.wc2026_dq_project.teams`)
UNION DISTINCT
SELECT DISTINCT team_away
FROM `worldcup2026-analytics.wc2026_dq_project.matches`
WHERE team_away NOT IN (SELECT team_name FROM `worldcup2026-analytics.wc2026_dq_project.teams`);

-- 4. Invalid score check (negative scores, or knockout draws with no pens winner)
SELECT match_id, team_home, team_away, score_home, score_away, stage, decided_by_pens, pens_winner
FROM `worldcup2026-analytics.wc2026_dq_project.matches`
WHERE score_home < 0 OR score_away < 0
   OR (stage != 'Group' AND score_home = score_away AND decided_by_pens = false);

-- 5. Date logic check: no match should be dated before the tournament started (2026-06-11)
SELECT match_id, match_date
FROM `worldcup2026-analytics.wc2026_dq_project.matches`
WHERE match_date < '2026-06-11';
