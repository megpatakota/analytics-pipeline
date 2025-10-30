Action,Command,Purpose
Start/Restart,docker compose up -d,"The main command. Starts the service, reuses the old container, and keeps data."
Stop,docker compose stop db,Stops the running container without removing it.
Clean Restart,docker compose restart db,Quickly stops and starts the specified service.
Cleanup (Keep Data),docker compose down,"Stops and removes containers and networks, but leaves your critical data volume (postgres_data) intact."