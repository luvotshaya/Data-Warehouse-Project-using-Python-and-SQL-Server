
import pandas as pd
from datetime import datetime
import pyodbc as odbc

"""
Script Purpose:
    This piple loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Extract data from the csv file
    - Adds source and import dats
    - Truncates the bronze tables before loading data.
    - Uses the `SINGLE ROW INSERT` command to load data from csv File to bronze table.

"""



class CircuitDataPipeline:
    #Initialize
    def __init__(self, source, destination):
        self.source= source
        self.destination= destination
        self.data = None

     #Extract the data
    def extract_data(self):
        try:
            print(f"Extracting data from {self.source}")
            circuits_schema = {
                "circuitId": "string",
                "url": "string",
                "circuitName": "string",
                "lat": "float64",
                "long": "float64",
                "locality": "string",
                "country":"string"
            }
            self.data = pd.read_csv(self.source, dtype=circuits_schema)
            return self.data
        except Exception as e:
            print(f"An error occurred: {e}")
    
    #transform the data
    def transform_data(self, data):
        print("Transforming data")
        try:
            data['created_at'] = datetime.now()
            data['Source'] = source_file_path
            return self.data
        except Exception as e:
            print(f"An error occurred unable to transform data: {e}")

    
    #Load the data to destination
    def load_data(self, data):
        self.data = self.data.astype(object).where(pd.notnull(self.data), None)
        rows = self.data.values.tolist()
        
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
                                    INSERT INTO bronze.circuits (
                                                                                                   circuitID,
                                                                                                   url,
                                                                                                   circuitName,
                                                                                                   lat,
                                                                                                   long,
                                                                                                   locality,
                                                                                                   country,
                                                                                                   import_date,
                                                                                                   source) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)"""
                                                   
                delete_script = """bronze.delete_circuits"""
                cursor = conn.cursor()
                cursor.execute(delete_script)
                cursor.executemany(insert_script, rows)
                print(f"There was {len(rows)} rows inserted...")  
                conn.commit()
            except Exception as e:
                            print(f"An error occurred unable to insert to the database: {e}")
        except Exception as e:
            print(f"Error occurred unable to connect to the database: {e}")
        finally:
             cursor.close()
             conn.close()
        

                

    
    #Orchestrate Flow
    def run(self):
        data = self.extract_data()
        data = self.transform_data(data)
        self.load_data(data)


source_file_path = r"C:\Users\Game On\python-formula1-de\data\landing\circuits.csv"
bronze_file_path = r"C:\Users\Game On\python-formula1-de\data\bronze\mydatabase.db"


pipeline = CircuitDataPipeline(source_file_path,bronze_file_path)
pipeline.run()

