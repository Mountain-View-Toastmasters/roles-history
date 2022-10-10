WITH
  extracted_roles AS (
  SELECT
    PARSE_DATE("%m/%d/%Y", date) AS meeting_date,
    meeting_theme,
    tech_chair,
    zoom_master,
    toastmaster,
    jokemaster,
    general_evaluator,
    recorder,
    timer,
    ah_counter,
    wordmaster_grammarian,
    table_topics_master,
    speaker_1,
    speaker_2,
    speaker_3,
    evaluator_1,
    evaluator_2,
    evaluator_3
  FROM
    mvtm.roles
  WHERE
    toastmaster IS NOT NULL
    AND meeting_theme NOT LIKE "%pecial%"
  ORDER BY
    meeting_date DESC ),
  participation AS (
  SELECT
    meeting_date,
    meeting_theme,
    participant.*
  FROM
    extracted_roles t,
    UNNEST(mvtm.transpose(TO_JSON_STRING((
          SELECT
            AS STRUCT t.* EXCEPT(meeting_date,
              meeting_theme))))) participant
  WHERE
    participant.name IS NOT NULL ),
  clean AS (
  SELECT
    * EXCEPT(name),
    -- gross
  IF
    (name LIKE "David%",
    IF
      (name = "David",
        "David L",
        TRIM(name)),
      SPLIT(name, " ")[
    OFFSET
      (0)]) AS name,
    CASE
      WHEN role LIKE "speaker_%" THEN "speaker"
      WHEN role LIKE "evaluator_%" THEN "evaluator"
    ELSE
    "functionary"
  END
    AS role_category
  FROM
    participation
  WHERE
    meeting_date >= "2020-09-01"
    AND name <> "-"
    AND name NOT LIKE "Round-Robin%" )
SELECT * from clean