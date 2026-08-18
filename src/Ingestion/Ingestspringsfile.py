
import pandas as pd
from pathlib import Path
import json
from datetime import datetime
import pyodbc as odbc

"""
Script Purpose:
    This piple loads data into the 'bronze' schema from external JSON files. 
    It performs the following actions:
    - Extract data from the json file
    - Adds source and import dats
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from json File to bronze table.

"""


class DataPipeline:
    #Initialize
    def __init__(self, source_file_path : Path, destination):
        self.source = Path(source_file_path)
        self.destination= destination
        self.data = None

     #Extract the data
    def extract_data(self):
        print(f"Data extracting begin...")
        for file_path in self.source.glob("*.json"):
            with open(file_path, "r", encoding="utf-8") as file:
                try:
                    filedata = pd.read_json(file)
                except json.JSONDecodeError:
                    print(f"Error: {file_path.name} is not a valid JSON file.")
        
            self.data = pd.concat([self.data, filedata], ignore_index=True)
        print(f"Number of rows extracted {len(self.data)} ...")    
        return self.data    
    
    
    #transform the data
    def transform_data(self, data):
        print("Transforming data")
        try:
           # data['date'] = pd.to_datetime(data['date'], format='%Y/%m/%d')
            data['created_at'] = datetime.now()
            data['Source'] = str(source_file_path)
            print(f"There was {len(data)} number of row(s) affected...")   
            return self.data
        except Exception as e:
            print(f"An error occurred unable to transform data: {e}")

    
    #Load the data to destination
    def load_data(self, data):
        rows = self.data.astype(object).where(pd.notnull(self.data), None).values.tolist()
        print(f"There was {len(data)} rows to be inserted...") 
        
        DRIVER = 'ODBC Driver 17 for SQL Server'
        SERVER_NAME = r'DESKTOP-DPA6DHE\SQLEXPRESS'
        DATABASE_NAME = 'dbFormula1DE'
        
        def connection_string(driver, server_name, database_name):
            conn_string = f"""
                            DRIVER={{{driver}}};SERVER={server_name};DATABASE={database_name};Trusted_Connection=yes;
                            """
            return conn_string

        
        try:
            conn = odbc.connect(connection_string(DRIVER, SERVER_NAME, DATABASE_NAME))
            print("Successfully connected to MSSQL database!")
            try:
                insert_script = """
                                    INSERT INTO bronze.sprints(
                                                        date,
                                                        raceName,
                                                        round,
                                                        season,
                                                        url,
                                                        constructorId,
                                                        driverId,
                                                        grid,
                                                        laps,
                                                        number,
                                                        points,
                                                        position,
                                                        positionText,
                                                        status,
                                                        import_date,
                                                        source) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"""
                                            
                delete_script = """exec bronze.delete_sprints"""
                cursor = conn.cursor()
                cursor.execute(delete_script)
                cursor.executemany(insert_script, rows)
                print(f"There was {len(rows)} number of row(s) inserted successfully...")  
                conn.commit()
            except Exception as e:
                    print(f"An error occurred unable to insert to the database: {e}")
        except Exception as e:
            print(f"Error occurred unable to connect to the database: {e}")
        finally:
            cursor.close()
            conn.close()
            print("SQL connection closed.")
        
    #Orchestrate Flow
    def run(self):
        data = self.extract_data()
        data = self.transform_data(data)
        self.load_data(data)


source_file_path = Path("C:/Users/Game On/python-formula1-de/data/landing/sprints")
bronze_file_path = r"C:\Users\Game On\python-formula1-de\data\bronze\mydatabase.db"
df_data = pd.DataFrame()


pipeline = DataPipeline(source_file_path,bronze_file_path)
pipeline.run()

