Date:   05 February 2021
Author: Stéphane ROKKANEN
-------------------------

# DEPLOYMENT PROCEDURE

Requirements
- Users must be logged as Administrator or run cmd/hta as administrator
- WebDeploy Agent must be installed on server (with webdeploy_amd64_en-us.msi / custom installation with Agent checked)
- IIS Site must be created with the pool
- The name site is defined by "IIS Web Application" variable in _config/SetParameters-XXX.xml file, where XXX is environment to be deployed

Process

- Overview build.cmd(call->_config.cmd->buildpackage01-msbuild.cmd->buildpackage02-copy.cmd) 
                > delivery.cmd 
                    > _setup.hta(call-> deploy.cmd)
## Developer
1. Check your environnement in _config.cmd and environments.xml
2. Build WebDeploy packages with build.cmd
3. Copy WebDeploy packages to binaries repository (delivery.cmd)
4. Alert operators about new setup avalaibility for the app

## Operator
1. Goto binaryRepository repository 
2. Copy [repository]/[app_name]/[version]/app to a local folder
3. Launch setup _setup.hta or deploy command as follow:

```deploy.cmd [hostname] Set-Parameter-[ENV].xml``` (see environments.xml for the hostname)
