import mysql.connector
import csv

cnx = mysql.connector.connect(user='root', password='Blank@3121', host='localhost', database='test_db')
query = ( "select distinct coachid, sum(w) from test_db.coaches group by coachid" )

cursor = cnx.cursor()
cursor.execute(query)

rows = cursor.fetchall()
print rows
with open("D:/Work/Learning/Python/hockey/output.csv",'wb') as resultFile:
    wr = csv.writer(resultFile)
    wr.writerows(rows)
