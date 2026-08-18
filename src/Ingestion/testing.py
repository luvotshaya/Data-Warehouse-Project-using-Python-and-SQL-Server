import json
import pandas as pd
from pathlib import Path
import pyodbc as odbc

# Define the path to your folder
folder_path = Path("./my_json_folder")
source_file_path = Path("C:/Users/Game On/python-formula1-de/data/landing/sprints")
#source_file_path = Path("C:\Users\Game On\python-formula1-de\data\landing\results")

# Store all extracted data
all_data = None
line_data =  []

# Loop through all .json files in the directory

#for file_path in source_file_path.glob("*.json"):
#    with open(file_path, "r", encoding="utf-8") as file:
#        try:
#            #for line in file:
#               # if line.strip():
#               #     line_data.append(json.loads(line))
#               data = pd.read_json(file)
##               print(data)
#        except json.JSONDecodeError:
#            print(f"Error: {file_path.name} is not a valid JSON file.")
#    all_data = pd.concat([all_data,data], ignore_index=True)
#print(all_data)

#for file_path in source_file_path.glob("*.json"):
#    with open(file_path, "r", encoding="utf-8") as file:
#        try:
#            data = pd.read_json(file)
#        except json.JSONDecodeError:
#            print(f"Error: {file_path.name} is not a valid JSON file.")
#    all_data = pd.concat([all_data,data], ignore_index=True)
#print(all_data)


#with open("data.jsonl", "r") as file:
#    for line in file:
#        if line.strip():
#            all_data.append(json.loads(line))

#print(all_data)


DRIVER = 'SQL Server'
SERVER_NAME = r'DESKTOP-DPA6DHE\SQLEXPRESS'
DATABASE_NAME = 'dbFormula1DE'

def connection_string(driver, server_name, database_name):
    conn_string = f"""
        DRIVER={{{driver}}};SERVER={server_name};DATABASE={database_name};Trusted_Connection=yes;
    """
    return conn_string


#connection_string(DRIVER, SERVER_NAME, DATABASE_NAME)

sql_insert = """
    INSER INTO 
"""

try:
    conn = odbc.connect(connection_string(DRIVER, SERVER_NAME, DATABASE_NAME))
    print('Connection was successfully')
except odbc.DatabaseError as e:
    print('Database Error:')
    print(str(e))

try:
    cursor = conn
except Exception as e:
    print(str(e[1]))
# print(odbc.drivers())



#connection = odbc.connect(driver = '{ODBC Driver 17 for SQL Server}',
#                           host = 'DESKTOP-NAKP5E5',
#                           database = "Test",
#                           trusted_connection = 'yes')

        DRIVER = 'ODBC Driver 17 for SQL Server'
        SERVER_NAME = r'DESKTOP-DPA6DHE\SQLEXPRESS'
        DATABASE_NAME = 'dbFormula1DE'

        def connection_string(driver, server_name, database_name):
            conn_string = f"""
                DRIVER={{{driver}}};SERVER={server_name};DATABASE={database_name};Trusted_Connection=yes;
            """
            return conn_string


        #conn_str = r"Server=DESKTOP-DPA6DHE\SQLEXPRESS;Database=dbFormula1DE;Trusted_Connection=yes;TrustServerCertificate=yes;"
        print(f"loading{len(data)} records to {self.destination}")
        try:
            sql_script = """INSERT INTO bronze.circuits (
                                                circuitID,
                                                url,
                                                circuitName,
                                                lat,
                                                long,
                                                locality,
                                                country,
                                                import_date,
                                                source) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)"""
            with odbc.connect(connection_string(DRIVER, SERVER_NAME, DATABASE_NAME)) as conn:
                print("Successfully connected to MSSQL database!")
                cursor = conn.cursor()
                cursor.executemany(sql_script, rows)
                conn.commit()
        except Exception as e:
            print(f"An error occurred unable to load data: {e}")
        finally:
            cursor.close()
            conn.close()