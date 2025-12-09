import argparse
import win32service

def check_service(server, service_name):
    try:
        # Connect to the service manager
        scm = win32service.OpenSCManager(
            server,
            None,
            win32service.SC_MANAGER_CONNECT
        )

        # Open the service
        service = win32service.OpenService(
            scm,
            service_name,
            win32service.SERVICE_QUERY_STATUS
        )

        # Query service status
        status = win32service.QueryServiceStatus(service)
        state = status[1]

        states = {
            win32service.SERVICE_STOPPED: "Stopped",
            win32service.SERVICE_START_PENDING: "Start Pending",
            win32service.SERVICE_STOP_PENDING: "Stop Pending",
            win32service.SERVICE_RUNNING: "Running",
            win32service.SERVICE_CONTINUE_PENDING: "Continue Pending",
            win32service.SERVICE_PAUSE_PENDING: "Pause Pending",
            win32service.SERVICE_PAUSED: "Paused",
        }

        print(f"Service '{service_name}' on '{server or 'localhost'}' is: {states.get(state, 'Unknown')}")

        win32service.CloseServiceHandle(service)
        win32service.CloseServiceHandle(scm)

    except Exception as e:
        print(f"Error: {e}")

def main():
    parser = argparse.ArgumentParser(description="Check Windows service status")
    parser.add_argument("-s", "--server", help="Server name (default: local machine)", default=None)
    parser.add_argument("-n", "--service", help="Service name", required=True)

    args = parser.parse_args()

    check_service(args.server, args.service)

if __name__ == "__main__":
    main()

