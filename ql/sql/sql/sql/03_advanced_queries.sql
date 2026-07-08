-- ============================================
-- Advanced Queries — 2026 World Cup Matches
-- Self-joins, window functions, CASE logic, subqueries
-- ============================================

-- 1. Self-join: Group stage vs Knockout performance per team
WITH group_stage AS (
  SELECT team_home AS team, score_home AS scored, score_away AS conceded
  FROM `worldcup2026-analytics.wc2026_dq_project.matches`
  WHERE stage = 'Group'
  UNION ALL
  SELECT team_away AS team, score_away AS scored, score_home AS conceded
  FROM `worldcup2026-analytics.wc2026_dq_project.matches`
  WHERE stage = 'Group'
),
knockout AS (
  SELECT team_home AS team, score_home AS scored, score_away AS conceded
  FROM `worldcup2026-analytics.wc2026_dq_project.matches`
  WHERE stage != 'Group'
  UNION ALL
  SELECT team_away AS team, score_away AS scored, score_home AS conceded
  FROM `worldcup2026-analytics.wc2026_dq_project.matches`
  WHERE stage != 'Group'
)
SELECT
  g.team,
  SUM(g.scored) AS group_stage_goals,
  SUM(k.scored) AS knockout_goals,
  ROUND(AVG(g.scored),1) AS avg_group_goals_per_match,
  ROUND(AVG(k.scored),1) AS avg_knockout_goals_per_match
FROM group_stage g
JOIN knockout k ON g.team = k.team
GROUP BY g.team
ORDER BY knockout_goals DESC
LIMIT 10;

-- 2. LAG window function: Goal-scoring trend across a team's matches
WITH team_matches AS (
  SELECT team_home AS team, match_date, score_home AS goals
  FROM `worldcup2026-analytics.wc2026_dq_project.matches`
  UNION ALL
  SELECT team_away AS team, match_date, score_away AS goals
  FROM `worldcup2026-analytics.wc2026_dq_project.matches`
)
SELECT
  team,
  match_date,
  goals,
  LAG(goals) OVER (PARTITION BY team ORDER BY match_date) AS previous_match_goals,
  goals - LAG(goals) OVER (PARTITION BY team ORDER BY match_date) AS goal_change
FROM team_matches
ORDER BY team, match_date;

-- 3. CASE WHEN: Match drama classifier
SELECT
  match_id, team_home, team_away, score_home, score_away, stage,
  CASE
    WHEN ABS(score_home - score_away) >= 3 THEN 'Blowout'
    WHEN ABS(score_home - score_away) = 1 THEN 'Nail-biter'
    WHEN score_home = score_away AND decided_by_pens = true THEN 'Penalty Drama'
    ELSE 'Comfortable Win'
  END AS match_category
FROM `worldcup2026-analytics.wc2026_dq_project.matches`
ORDER BY match_date;

-- 3b. Match drama summary (% breakdown)
SELECT match_category, COUNT(*) AS num_matches,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS pct_of_matches
FROM (
  SELECT
    CASE
      WHEN ABS(score_home - score_away) >= 3 THEN 'Blowout'
      WHEN ABS(score_home - score_away) = 1 THEN 'Nail-biter'
      WHEN score_home = score_away AND decided_by_pens = true THEN 'Penalty Drama'
      ELSE 'Comfortable Win'
    END AS match_category
  FROM `worldcup2026-analytics.wc2026_dq_project.matches`
)
GROUP BY match_category
ORDER BY num_matches DESC;

-- 4. Subquery: Teams outperforming tournament average
WITH team_totals AS (
  SELECT team, SUM(goals) AS total_goals
  FROM (
    SELECT team_home AS team, score_home AS goals FROM `worldcup2026-analytics.wc2026_dq_project.matches`
    UNION ALL
    SELECT team_away AS team, score_away AS goals FROM `worldcup2026-analytics.wc2026_dq_project.matches`
  )
  GROUP BY team
)
SELECT
  team,
  total_goals,
  (SELECT ROUND(AVG(total_goals),1) FROM team_totals) AS tournament_avg,
  total_goals - (SELECT ROUND(AVG(total_goals),1) FROM team_totals) AS goals_above_avg
FROM team_totals
ORDER BY goals_above_avg DESC
LIMIT 10;
