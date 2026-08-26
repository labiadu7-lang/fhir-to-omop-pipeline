SELECT * FROM read_csv_auto('C:/Users/labia/Desktop/concepts/CONCEPT.csv', delim='\t', header=true)

UNION ALL

SELECT * FROM read_csv_auto('C:/Users/labia/Desktop/concepts/CONCEPT_cvx.csv', delim='\t', header=true)
