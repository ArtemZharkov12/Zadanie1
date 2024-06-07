from flask import Flask, request
import datetime

# Initialize the Flask application
app = Flask(__name__)

# Define the route for the home page
@app.route('/')
def home():
    # Get the client's IP address
    client_ip = request.remote_addr
    
    # Get the current time
    current_time = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    # Create a log message with the client's IP and access time
    log_message = f"Client IP: {client_ip}, Access Time: {current_time}\n"
    
    # Append the log message to the server.log file
    with open("server.log", "a") as log_file:
        log_file.write(log_message)
    
    # Return an HTML response with the client's IP and the current time
    return f"<h1>Client IP: {client_ip}</h1><p>Current Time: {current_time}</p>"

# Run the application if this file is executed as the main script
if __name__ == '__main__':
    # The server will listen on all IP addresses (0.0.0.0) and port 3000
    app.run(host='0.0.0.0', port=3000)
