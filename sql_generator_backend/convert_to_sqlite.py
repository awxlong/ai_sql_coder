import pandas as pd
import sqlite3
import argparse
import pdb

def csv_to_sqlite(csv_file_path, sqlite_db_path, table_name):
    """
    Imports a CSV file into an SQLite database.

    Parameters:
    csv_file_path (str): Path to the CSV file.
    sqlite_db_path (str): Path to the SQLite database file.
    table_name (str): Name of the table to create or replace in the database.
    """
    try:
        # Load the CSV file into a pandas DataFrame
        df = pd.read_csv(csv_file_path)
        print(f"CSV file '{csv_file_path}' loaded successfully.")
        
        # Connect to the SQLite database (creates it if it doesn't exist)
        conn = sqlite3.connect(sqlite_db_path)
        print(f"Connected to SQLite database '{sqlite_db_path}'.")
        # pdb.set_trace()
        # Import the DataFrame into the SQLite database
        df.to_sql(f"{table_name}", conn, if_exists='replace', index=False)
        print(f"Data imported successfully into table '{table_name}'.")

    except Exception as e:
        print(f"An error occurred: {e}")

    finally:
        # Close the database connection
        if conn:
            conn.close()
            print("SQLite connection closed.")

def main():
    # Initialize the argument parser
    parser = argparse.ArgumentParser(description='Import a CSV file into an SQLite database.')

    # Define command-line arguments
    parser.add_argument('--csv_file_path', help='Path to the CSV file.')
    parser.add_argument('--sqlite_db_path', default='mimic_iv_demo_admissions.db', help='Path to the SQLite database file.')
    parser.add_argument('--table_name', default='mimic_iv_demo', help='Name of the table to create or replace in the database.')

    # Parse the arguments
    args = parser.parse_args()

    # Call the function with the provided arguments
    csv_to_sqlite(args.csv_file_path, args.sqlite_db_path, args.table_name)

if __name__ == '__main__':
    main() # python convert_to_sqlite.py --csv_file_path "../../mimic-iv-clinical-database-demo-2.2/hosp/admissions.csv"


