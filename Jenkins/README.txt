ZvitPlus CI/CD

Working folder: D:\ZvitPlus-CICD
Jenkins: http://127.0.0.1:8090/
Job: zvitplus-local-ci

Start after restarting Windows:
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "D:\ZvitPlus-CICD\Start-Jenkins.ps1"

Copy the admin password to the clipboard:
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "D:\ZvitPlus-CICD\Copy-JenkinsPassword.ps1"
Clear the clipboard after login. The stored credential uses Windows DPAPI.

jenkins\     Jenkins, Java, configuration, build history and encrypted credential
scripts\     Build, deployment and launch scripts, Jenkinsfile
tools\      Portable Node.js 22 and .NET 10 SDK
cache\       NuGet cache
source\      Local source checkout
artifacts\   Initial build artifacts
reports\     Word report

Do not delete jenkins\home\secrets or the encrypted credential.
Jenkins is not configured to start automatically with Windows.
Tailscale must be connected for Ubuntu deployment.
The original chat folder is no longer needed for Jenkins execution.