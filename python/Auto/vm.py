from googleapiclient.discovery import build
from google.oauth2.service_account import Credentials
from googleapiclient.errors import HttpError
from googleapiclient import discovery
import google.auth

# Set up Google Sheets API credentials and service
SHEET_ID = "1lZDvanGE8q1X48ONI4JZGotQnwW2vTX-rc65zLFvL-A"  # Replace with your Google Sheet ID
RANGE_NAME = "Sheet1!A2:D"  # Adjust range as needed (columns: VM instance, IP, Type, Status)
CREDENTIALS_FILE = r"C:\Users\Coditas\Documents\cas\hardy-clover-447804-t3-c8f59f0137cf.json"  # Replace with your service account JSON file

# Load credentials for authentication
credentials = Credentials.from_service_account_file(CREDENTIALS_FILE)
sheets_service = build("sheets", "v4", credentials=credentials)

# Fetch current data from the Google Sheet
def fetch_sheet_data():
    try:
        sheet = sheets_service.spreadsheets()
        result = sheet.values().get(spreadsheetId=SHEET_ID, range=RANGE_NAME).execute()
        return result.get('values', [])
    except HttpError as e:
        print(f"An error occurred: {e}")
        return []

# Fetch VM instances from Google Cloud
def fetch_vm_instances():
    compute_service = discovery.build('compute', 'v1', credentials=credentials)
    project = "hardy-clover-447804-t3"  # Replace with your Google Cloud Project ID
    zone = "us-central1-c"  # Replace with the appropriate zone
    request = compute_service.instances().list(project=project, zone=zone)
    vm_instances = {}

    while request is not None:
        response = request.execute()
        for instance in response.get('items', []):
            vm_instances[instance['name']] = {
                'ip': instance['networkInterfaces'][0]['networkIP'],
                'machine_type': instance['machineType'].split('/')[-1],
                'status': instance['status']
            }
        request = compute_service.instances().list_next(previous_request=request, previous_response=response)

    return vm_instances

# Compare data and update the Google Sheet
def compare_and_update(sheet_data, vm_instances):
    updates = []
    for row in sheet_data:
        vm_name, ip, machine_type, status = row
        if vm_name in vm_instances:
            vm_data = vm_instances[vm_name]
            if vm_data['ip'] != ip or vm_data['machine_type'] != machine_type or vm_data['status'] != status:
                updates.append([
                    vm_name, vm_data['ip'], vm_data['machine_type'], vm_data['status']
                ])
        else:
            print(f"VM {vm_name} not found in Google Cloud.")

    if not updates:
        print("No changes detected.")
    else:
        try:
            body = {
                "values": updates
            }
            sheets_service.spreadsheets().values().update(
                spreadsheetId=SHEET_ID,
                range=RANGE_NAME,
                valueInputOption="RAW",
                body=body
            ).execute()
            print(f"Updates made: {updates}")
        except HttpError as e:
            print(f"An error occurred while updating: {e}")

if __name__ == "__main__":
    sheet_data = fetch_sheet_data()
    vm_instances = fetch_vm_instances()
    compare_and_update(sheet_data, vm_instances)
