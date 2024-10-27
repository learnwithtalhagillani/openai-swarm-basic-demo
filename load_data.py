
import sqlite3
import os

def create_database():
    # Delete the database file if it exists
    if os.path.exists('donations.db'):
        os.remove('donations.db')
    
    # Connect to database
    conn = sqlite3.connect('donations.db')
    
    try:
        # Read SQL file
        with open('donation_schema.sql', 'r') as sql_file:
            sql_script = sql_file.read()
        
        # Execute SQL script
        conn.executescript(sql_script)
        
        print("Database created successfully!")
        
         # Read SQL file
        with open('donation_insert.sql', 'r') as sql_file:
            sql_script = sql_file.read()
        
        # Execute SQL script
        conn.executescript(sql_script)       
        print("Database populated successfully!")
        
        # Test the database
        cursor = conn.cursor()
        
        print("\nTesting views...")
        print("\nDonor Summary:")
        cursor.execute("SELECT * FROM donor_summary")
        for row in cursor.fetchall():
            print(row)
            
        print("\nCampaign Summary:")
        cursor.execute("SELECT * FROM campaign_summary")
        for row in cursor.fetchall():
            print(row)
            
    except sqlite3.Error as e:
        print(f"An error occurred: {e}")
    finally:
        conn.close()

if __name__ == "__main__":
    create_database()