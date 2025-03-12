# example_task.py
import datetime
import os

# Get current time
current_time = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

# Log file path
log_file = os.path.join(os.path.dirname(os.path.abspath(__file__)), "task_log.txt")

# Write to log file
with open(log_file, "a") as f:
    f.write(f"Task ran at: {current_time}\n")

print(f"Task executed at {current_time}")