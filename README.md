The Job Collection Service is a 32 bit Node.js application (created by Meteor) and has a runtime dependency on MongoDB for storage of job information.

## Build Machine Setup

[Meteor 1.2.1](https://install.meteor.com/windows)

## Build Application

Since we are targeting a Windows machine and our development machines are also Windows, the default OS architecture should suffice.

eg.
- `meteor build .target`
    - This will create a compressed archive file (jobCollectionService.tar.gz) in a directory called `.target`.
- `meteor build .target --directory`
    - This will create a directory called `.target` with an expanded `bundle` subdirectory.


## Target Machine Setup

### Install Node via Windows installer
**Meteor 1.2.1 is tested with Node v0.10.40 by the meteor.com group.**
- [Node v0.10.40 x86 Windows 32 bit](https://nodejs.org/download/release/v0.10.40/node-v0.10.40-x86.msi)
    - disable Set PATH feature (Node and NPM)
- [Node v0.12.6 x86 Windows 32 bit](https://nodejs.org/download/release/v0.12.6/node-v0.12.6-x86.msi)
    - disable Set PATH feature (Node and NPM)

#### Gotcha's
If you didn't install node then you may need to create the npm directory in your AppData\Roaming directory as per http://stackoverflow.com/questions/25093276/node-js-windows-error-enoent-stat-c-users-rt-appdata-roaming-npm

### Install Visual Studio 2013 Express or Visual Studio 2012

This is required to install/build 'native' node modules.

### Setup IIS and IISNode to manage the Node process

We have chosen to let IIS manage our web application via the IISNode module.  The application can also be [Manually run app from command line](#manually-run-app-from-command-line).

1. IIS Web Config
- copy web.config from project directory `private/config/web.config` to website root directory.
    - `c:\apps\local\transcript\web.config`
- update web.config app.settings with latest from `private/config/settings.json` and tweak with environment specific settings
2. IISNode config
- copy iisnode.yml from project directory `private/config/iisnode.yml` to website root directory.
    - `c:\apps\local\transcript\iisnode.yml`

### Setup Install Scripts

#### Meteor App Install
This powershell script performs the same steps as the manual process [Manual Application Install](#manual-application-install)

1. copy install.ps1 and logInstall.ps1 from project directory `private/config` to application root directory c:\apps\local\transcript

#### Transcript ElasticSearch Config/Index/Re-Index Install
The install.ps1 script configures custom analyzer's for Transcript documents and depending on the $newIndexName variable will auto migrate to the new index without down-time.
1. copy project directory `private/config/elasticsearch to application root directory C:\apps\local\transcript
2. cmd prompt
3. cd c:\apps\local\transcript\elasticsearch
4. npm install elasticsearch-reindex

### Setup ElasticSearch

See [ElasticSearch Setup](https://github.com/EduShareOntario/jobCollectionService/wiki/ElasticSearch-Node-Setup-(windows-server-2012))
## Install Application on Target Machine

### Semi-automated Application Install

Depends on [Setup Install Scripts](#setup-install-scripts)

1. Run the install.ps1 script
- `. install.ps1
- **Important: Some manual steps are required! Read the script output...**

### Manual Application Install
1. Open Developer Command Prompt for VS2012 or plain cmd if Visual Studio is on the path
2. Ensure the 32 bit Node program is found.
- `set path=c:\Program Files (x86)\nodejs;%path%`
3. Ensure the command line is using the correct version of Node as per [Target Machine Setup](#target-machine-setup)
- `node`
- `> process.arch`
- `> process.platform`
- `> process.execPath`
4. Change to application directory. eg. c:\apps\local\transcript
- `cd c:\apps\local\transcript`
5. Copy jobCollectionService.tar.gz from build machine to target target filesystem
6. Uncompress.
- `7z x jobCollectionService.tar.gz`
7. Stop the jobCollectionService and related application pool processes.
- via IIS Manager stop the Application Pool and wait for the worker processes to terminate.
8. Remove existing directories.
- `rd bundle,PaxHeader /q /s`
9. Expand Archive.
- `7z x jobCollectionService.tar`
10. Remove pre-built npm-bcrypt module.
- `rd bundle\programs\server\npm\npm-bcrypt /q /s`
11. Install bcrypt module(**should only need to do this the 1st time**)
- `npm install bcrypt --msvs_version=2012`
12. Install NPM modules.
- `cd bundle\programs\server`
- `npm install --msvs_version=2012` (for Visual Studio 2012)
13. Start Application Pool
- via IIS Manager start the Application Pool (eg. transcript)
14. Verify the app!

## Manually run app from command line

Our goal is to rely on the IIS/IISNode module to manage the lifecycle of our Node application processes.
**The method described below should only be used to debug the root cause of the Node process terminating upon startup.**

### Environment Setup
- `set path=c:\Program Files (x86)\nodejs;%path%`
- `set MONGO_URL=mongodb://localhost:27017/jobs`
  **Depends on a local running MongoDB instance!**
- `set METEOR_SETTINGS={"jobCollections": [{"name": "student-transcript","adminUserIds": [ "adfasdfads", "aFrEmKx5uPxdFdoCk","sm7ia7R9b3RLrTcHt"]}]}`
  **use latest from private/config/settings.json and tweak with environment specific settings**
- `set ROOT_URL=http://localhost:3000`
- `set PORT=3000`

### Run
1. `cd .target\bundle`
2. `node main.js`

