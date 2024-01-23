# RaspberryPi_MC_launcher
Managing several MC Java servers on a RaspberryPi is troublesome. So I write this launcher to make things easier.

All Minecraft instances are stored in ~/Minecraft and

Update logs:
v0.10: The initial version of the project. Its only function is listing the servers and allows the user to choose which to run.
v0.12: Added the lock file. It will no longer ask user to choose a server to run when a server is already running, instead, it will show information about the running server.
v0.14: Now the launcher would handle the situation where Minecraft services go into "failed" state.
v0.15: Now the launcher would handle all situations where Minecraft services malfunction. In this case, a new debug option "show logs" is added, allowing user to check what happened during the last screen session.
v0.16(Undone): Will allow the launcher to upgrade itself when a newer version is detected in ~/Minecraft .