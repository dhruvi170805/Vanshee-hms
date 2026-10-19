@echo off
rem ====================================================
rem HMS System Backend Run Script
rem ----------------------------------------------------
rem This script starts the Express API server used by the
rem HMS Flutter frontend. It assumes Node.js is installed
rem and the required npm packages have been installed
rem via "npm install" in the backend directory.
rem ====================================================

rem Change to the backend directory (just in case)
cd "%~dp0"

rem Install dependencies if needed (optional)
if not exist "node_modules" (
    echo Installing npm dependencies...
    npm install
)

rem Start the server. The script will keep running and
rem log output to the console. Press Ctrl+C to stop.
node src\server.js
