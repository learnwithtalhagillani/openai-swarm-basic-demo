from swarm import Agent
from typing import Any, List, Tuple
from tabulate import tabulate
import json
from datetime import datetime
import sqlite3
from dotenv import load_dotenv
from swarm.repl import run_demo_loop
import os

load_dotenv()

# Executes SQL

class SQLExecutor:
    def __init__(self, db_path: str = 'donations.db'):
        """
        Initialize SQLExecutor with database path
        
        Args:
            db_path (str): Path to SQLite database file
        """
        self.db_path = db_path

    def _get_column_names(self, cursor: sqlite3.Cursor) -> List[str]:
        """Get column names from cursor description"""
        return [description[0] for description in cursor.description]

    def _format_value(self, value: Any) -> str:
        """Format individual values for better readability"""
        if value is None:
            return "NULL"
        elif isinstance(value, (int, float)):
            return str(value)
        elif isinstance(value, datetime):
            return value.strftime("%Y-%m-%d %H:%M:%S")
        else:
            return str(value)

    def execute_query(self, query: str, output_format: str = 'table') -> str:
        """
        Execute SQL query and return formatted results
        
        Args:
            query (str): SQL query to execute
            output_format (str): Output format ('table', 'json', 'csv')
        
        Returns:
            str: Formatted query results
        """
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            # Execute the query
            cursor.execute(query)
            
            # Get results and column names
            results = cursor.fetchall()
            columns = self._get_column_names(cursor)
            
            # Handle empty results
            if not results:
                return "Query executed successfully. No results to display."
            
            # Format the results based on output_format
            if output_format.lower() == 'json':
                # Convert to list of dictionaries
                json_data = [
                    {col: self._format_value(val) for col, val in zip(columns, row)}
                    for row in results
                ]
                return json.dumps(json_data, indent=2)
            
            elif output_format.lower() == 'csv':
                # Create CSV string
                csv_rows = [','.join(columns)]
                csv_rows.extend([
                    ','.join(self._format_value(val) for val in row)
                    for row in results
                ])
                return '\n'.join(csv_rows)
            
            else:  # default to table format
                # Use tabulate for pretty table formatting
                return tabulate(
                    results,
                    headers=columns,
                    tablefmt='pretty',
                    numalign='right',
                    stralign='left'
                )
                
        except sqlite3.Error as e:
            return f"SQLite Error: {str(e)}"
        except Exception as e:
            return f"Error: {str(e)}"
        finally:
            conn.close()
            
            
executor = SQLExecutor()

# Tools

def send_email_to_donor(donor_email: str, donor_name: str, subject: str, message: str):
    """Send an email to a donor with the specified subject and message."""
    print(f"[mock] Sending email to {donor_name} ({donor_email})")
    print(f"Subject: {subject}")
    print(f"Message: {message}")
    return f"Email sent successfully to {donor_email}"



def run_sql_select_statement(sql_statement: str):
    """Executes a SQL SELECT statement and returns the results of running the SELECT. Make sure you have a full SQL SELECT query created before calling this function."""
    print(f"Executing SQL statement: {sql_statement}")
    return executor.execute_query(sql_statement)




# Instructions
def get_email_agent_instructions():
    return """You are an email communication expert who crafts and sends personalized emails to donors.
    When asked to send an email, you will:
    1. Use the donor information from the previous SQL query result
    2. Craft a professional and appropriate message
    3. Send the email using the send_email_to_donor function
    
    Always maintain a professional and grateful tone in donor communications.
    If there's no previous SQL query result with donor information, ask the user to first retrieve the donor information.
    """


with open('donation_schema.sql', 'r') as sql_file:
    table_schema_info = sql_file.read()
    
def get_donation_agent_instructions():
    return f"""You are a SQL expert with 15 years of experience, who takes in a request from a user for information
    they want to retrieve from the DB, creates a SELECT statement to retrieve the
    necessary information, and then invoke the function to run the query and
    get the results back to then report to the user the information they wanted to know.
    
    Here are the table schemas for the DB you can query:
    
    {table_schema_info}

    Write all of your SQL SELECT statements to work 100% with these schemas and nothing else.
    You are always willing to create and execute the SQL statements to answer the user's question.
    """


# Agents

orchestrator_agent = Agent(
    name="Orchestrator Agent",
    instructions="Determine which agent is best suited to handle the user's request, and transfer the conversation to that agent.",
)



donation_agent = Agent(
    name="Donation Agent",
    instructions=get_donation_agent_instructions(),
    functions=[run_sql_select_statement]
)


email_agent = Agent(
    name="Email Agent",
    instructions=get_email_agent_instructions(),
    functions=[send_email_to_donor]
)

# Handoffs

def transfer_to_email():
    return email_agent

def transfer_back_to_orchestrator():
    """Call this function if a user is asking about a topic that is not handled by the current agent."""
    return orchestrator_agent


def transfer_to_donation():
    return donation_agent


orchestrator_agent.functions = [
    transfer_to_donation,
    transfer_to_email
]
donation_agent.functions.append(transfer_back_to_orchestrator)
email_agent.functions.append(transfer_back_to_orchestrator)

if __name__ == "__main__":
    run_demo_loop(orchestrator_agent)