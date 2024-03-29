import mysql.connector

def export_report_to_txt(filename):
    query = "SELECT * FROM Ucionica"

    try:
        with mysql.connector.connect(
            host="",
            user="",
            password="",
            database="",
            port=) as connection:

            cursor = connection.cursor()
            cursor.execute(query)

            with open(filename, 'w') as file:
                for row in cursor:
                    file.write(str(row) + '\n')

        print(f"Report exported successfully to {filename}")
    except Exception as e:
        print(f"Error: {e}")

export_report_to_txt("report.txt")
