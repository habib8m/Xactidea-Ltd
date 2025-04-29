SELECT id,
       TITLE_NAME,
       'TRAINEE' TRAINEE
FROM HRM_TRAINING_TITLE tt
WHERE NOT EXISTS (
    SELECT 1
    FROM ASS_RECOMMEND r
    WHERE REGEXP_LIKE(r.training_id, '(^|:)' || tt.id || '(:|$)')
)