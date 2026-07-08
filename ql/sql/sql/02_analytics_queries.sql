-- ============================================
-- Analytics Queries — 2026 World Cup Matches
-- Core performance insights
-- ============================================

-- 1. Top scoring teams (goals scored across all matches)
SELECT team, SUM(goals) AS total_goals
FROM (
  SELECT team_home AS team, score_home AS goals FROM `worldcup2026-analytics.wc2026_dq_project.matches`
  UNION ALL
  SELECT team_away AS team, score_away AS goals FROM `worldcup2026-analytics.wc2026_dq_project.matches`
)
GROUP BY team
ORDER BY total_goals DESC
LIMIT 10;

-- 2. Biggest comebacks / most dramatic knockout matches
WITH knockout_matches AS (
  SELECT match_id, team_home, team_away, score_home, score_away, stage,
         ABS(score_home - score_away) AS goal_margin,
         decided_by_pens
  FROM `worldcup2026-analytics.wc2026_dq_project.matches`
  WHERE stage != 'Group'
)
SELECT * FROM knockout_matches
ORDER BY decided_by_pens DESC, goal_margin ASC
LIMIT 10;

-- 3. Team performance ranking using window functions
WITH team_goals AS (
  SELECT team_home AS team, score_home AS scored, score_away AS conceded FROM `worldcup2026-analytics.wc2026_dq_project.matches`
  UNION ALL
  SELECT team_away AS team, score_away AS scored, score_home AS conceded FROM `worldcup2026-analytics.wc2026_dq_project.matches`
)
SELECT team,
       SUM(scored) AS goals_scored,
       SUM(conceded) AS goals_conceded,
       SUM(scored) - SUM(conceded) AS goal_difference,
       RANK() OVER (ORDER BY SUM(scored) - SUM(conceded) DESC) AS performance_rank
FROM team_goals
GROUP BY team
ORDER BY performance_rank
LIMIT 10;

-- 4. Penalty shootout survival rate
SELECT
  COUNT(*) AS total_knockout_matches,
  COUNTIF(decided_by_pens = true) AS decided_by_penalties,
  ROUND(COUNTIF(decided_by_pens = true) / COUNT(*) * 100, 1) AS pct_decided_by_pens
FROM `worldcup2026-analytics.wc2026_dq_project.matches`
WHERE stage != 'Group';
