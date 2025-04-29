
--Check duplicate value
SELECT buyer_dept_name, COUNT(*)
FROM buyer_dept_tbl
GROUP BY buyer_dept_name
HAVING COUNT(*) > 1;

-- Delete duplicate value
DELETE FROM buyer_dept_tbl
WHERE ROWID NOT IN (
  SELECT MIN(ROWID)
  FROM buyer_dept_tbl
  GROUP BY buyer_dept_name
);
