# Upsun Command Index

Quick alphabetical reference for all 130+ Upsun CLI commands. For workflow-based navigation, see the main [SKILL.md](../SKILL.md).

## Global Options

All commands support these global options:

- `--help, -h` - Display help message
- `--verbose, -v|vv|vvv` - Increase verbosity
- `--version, -V` - Display CLI version
- `--yes, -y` - Answer "yes" to prompts; accept defaults
- `--no-interaction` - Non-interactive mode (use `UPSUN_CLI_NO_INTERACTION=1`)
- `--ansi` / `--no-ansi` - Force/disable ANSI output
- `--no, -n` - Answer "no" to prompts
- `--quiet, -q` - Suppress output

## Command Reference

### A

**activity:cancel**
- **Description**: Cancel a running activity
- **Usage**: `upsun activity:cancel [ACTIVITY_ID]`
- **Reference**: [deployments.md](deployments.md#monitoring-activities)

**activity:get**
- **Description**: View detailed information on a single activity
- **Usage**: `upsun activity:get [ACTIVITY_ID]`
- **Reference**: [deployments.md](deployments.md#monitoring-activities)

**activity:list** (aliases: `activities`, `act`)
- **Description**: Get a list of activities for an environment or project
- **Usage**: `upsun activity:list [-p PROJECT] [-e ENVIRONMENT]`
- **Common Options**: `--incomplete, -i`, `--limit`, `--start`
- **Reference**: [deployments.md](deployments.md#monitoring-activities)

**activity:log**
- **Description**: Display the log for an activity
- **Usage**: `upsun activity:log [ACTIVITY_ID]`
- **Reference**: [deployments.md](deployments.md#monitoring-activities)

**app:config-get**
- **Description**: View the configuration of an app
- **Usage**: `upsun app:config-get [-p PROJECT] [-e ENVIRONMENT] [--app APP]`
- **Reference**: [projects-organizations.md](projects-organizations.md)

**app:config-validate** (aliases: `validate`, `lint`)
- **Description**: Validate the config files of a project
- **Usage**: `upsun app:config-validate`
- **Reference**: [projects-organizations.md](projects-organizations.md)

**app:list** (alias: `apps`)
- **Description**: List apps in the project
- **Usage**: `upsun app:list [-p PROJECT] [-e ENVIRONMENT]`
- **Reference**: [projects-organizations.md](projects-organizations.md)

**auth:api-token-login**
- **Description**: Log in to Upsun using an API token
- **Usage**: `upsun auth:api-token-login`
- **Reference**: [access-security.md](access-security.md#authentication)

**auth:browser-login** (alias: `login`)
- **Description**: Log in to Upsun via a browser
- **Usage**: `upsun auth:browser-login`
- **Reference**: [access-security.md](access-security.md#authentication)

**auth:info**
- **Description**: Display your account information
- **Usage**: `upsun auth:info`
- **Reference**: [access-security.md](access-security.md#authentication)

**auth:logout** (alias: `logout`)
- **Description**: Log out of Upsun
- **Usage**: `upsun auth:logout`
- **Reference**: [access-security.md](access-security.md#authentication)

**auth:verify-phone-number**
- **Description**: Verify your phone number interactively
- **Usage**: `upsun auth:verify-phone-number`
- **Reference**: [access-security.md](access-security.md#authentication)

**autoscaling:get** (alias: `autoscaling`)
- **Description**: View the autoscaling configuration of apps and workers
- **Usage**: `upsun autoscaling:get [-p PROJECT] [-e ENVIRONMENT]`
- **Reference**: [resources-scaling.md](resources-scaling.md#autoscaling)

**autoscaling:set**
- **Description**: Set the autoscaling configuration of apps or workers
- **Usage**: `upsun autoscaling:set [-p PROJECT] [-e ENVIRONMENT]`
- **Reference**: [resources-scaling.md](resources-scaling.md#autoscaling)

### B

**backup:create** (alias: `backup`)
- **Description**: Make a backup of an environment
- **Usage**: `upsun backup:create [-p PROJECT] [-e ENVIRONMENT] [--live]`
- **Common Options**: `--live` (backup without downtime)
- **Reference**: [backups.md](backups.md#creating-backups)

**backup:delete**
- **Description**: Delete an environment backup
- **Usage**: `upsun backup:delete [BACKUP_ID] [-p PROJECT] [-e ENVIRONMENT]`
- **Reference**: [backups.md](backups.md#managing-backups)

**backup:get**
- **Description**: View an environment backup
- **Usage**: `upsun backup:get [BACKUP_ID] [-p PROJECT] [-e ENVIRONMENT]`
- **Reference**: [backups.md](backups.md#viewing-backups)

**backup:list** (alias: `backups`)
- **Description**: List available backups of an environment
- **Usage**: `upsun backup:list [-p PROJECT] [-e ENVIRONMENT]`
- **Reference**: [backups.md](backups.md#viewing-backups)

**backup:restore**
- **Description**: Restore an environment backup
- **Usage**: `upsun backup:restore [BACKUP_ID] [-p PROJECT] [-e ENVIRONMENT]`
- **Common Options**: `--target`, `--no-code`, `--no-resources`, `--resources-init`
- **Reference**: [backups.md](backups.md#restoring-backups)

### C

**certificate:add**
- **Description**: Add an SSL certificate to the project
- **Usage**: `upsun certificate:add [CERTIFICATE_FILE] [-p PROJECT]`
- **Reference**: [access-security.md](access-security.md#ssl-certificates)

**certificate:delete**
- **Description**: Delete a certificate from the project
- **Usage**: `upsun certificate:delete [CERTIFICATE_ID] [-p PROJECT]`
- **Reference**: [access-security.md](access-security.md#ssl-certificates)

**certificate:get**
- **Description**: View a certificate
- **Usage**: `upsun certificate:get [CERTIFICATE_ID] [-p PROJECT]`
- **Reference**: [access-security.md](access-security.md#ssl-certificates)

**certificate:list** (aliases: `certificates`, `certs`)
- **Description**: List project certificates
- **Usage**: `upsun certificate:list [-p PROJECT]`
- **Reference**: [access-security.md](access-security.md#ssl-certificates)

**clear-cache** (alias: `cc`)
- **Description**: Clear the CLI cache
- **Usage**: `upsun clear-cache`

**commit:get**
- **Description**: Show commit details
- **Usage**: `upsun commit:get [COMMIT] [-p PROJECT]`
- **Reference**: [development-tools.md](development-tools.md)

**commit:list** (alias: `commits`)
- **Description**: List commits
- **Usage**: `upsun commit:list [-p PROJECT] [-e ENVIRONMENT]`
- **Reference**: [development-tools.md](development-tools.md)

**console** (alias: `web`)
- **Description**: Open the project in the Console
- **Usage**: `upsun console [-p PROJECT] [-e ENVIRONMENT]`

### D

**db:dump**
- **Description**: Create a local dump of the remote database
- **Usage**: `upsun db:dump [-p PROJECT] [-e ENVIRONMENT] [--relationship RELATIONSHIP]`
- **Common Options**: `--gzip`, `--file`, `--relationship`
- **Reference**: [services-databases.md](services-databases.md#database-dumps)

**db:sql** (alias: `sql`)
- **Description**: Run SQL on the remote database
- **Usage**: `upsun db:sql [-p PROJECT] [-e ENVIRONMENT] [--relationship RELATIONSHIP]`
- **Reference**: [services-databases.md](services-databases.md#database-operations)

**decode**
- **Description**: Decode an encoded string such as PLATFORM_VARIABLES
- **Usage**: `upsun decode [STRING]`

**docs**
- **Description**: Open the online documentation
- **Usage**: `upsun docs [SEARCH]`

**domain:add**
- **Description**: Add a new domain to the project
- **Usage**: `upsun domain:add [DOMAIN] [-p PROJECT]`
- **Reference**: [integration-variables.md](integration-variables.md#domains)

**domain:delete**
- **Description**: Delete a domain from the project
- **Usage**: `upsun domain:delete [DOMAIN] [-p PROJECT]`
- **Reference**: [integration-variables.md](integration-variables.md#domains)

**domain:get**
- **Description**: Show detailed information for a domain
- **Usage**: `upsun domain:get [DOMAIN] [-p PROJECT]`
- **Reference**: [integration-variables.md](integration-variables.md#domains)

**domain:list** (alias: `domains`)
- **Description**: Get a list of all domains
- **Usage**: `upsun domain:list [-p PROJECT]`
- **Reference**: [integration-variables.md](integration-variables.md#domains)

**domain:update**
- **Description**: Update a domain
- **Usage**: `upsun domain:update [DOMAIN] [-p PROJECT]`
- **Reference**: [integration-variables.md](integration-variables.md#domains)

### E

**environment:activate**
- **Description**: Activate an environment
- **Usage**: `upsun environment:activate [-p PROJECT] [-e ENVIRONMENT]`
- **Reference**: [environments.md](environments.md#activation)

**environment:branch** (alias: `branch`)
- **Description**: Branch an environment
- **Usage**: `upsun environment:branch [NEW_NAME] [-p PROJECT] [--parent PARENT]`
- **Common Options**: `--parent`, `--title`, `--force`
- **Reference**: [environments.md](environments.md#branching)

**environment:checkout** (alias: `checkout`)
- **Description**: Check out an environment
- **Usage**: `upsun environment:checkout [ENVIRONMENT] [-p PROJECT]`
- **Reference**: [environments.md](environments.md)

**environment:delete**
- **Description**: Delete one or more environments
- **Usage**: `upsun environment:delete [-p PROJECT] [-e ENVIRONMENT]`
- **Common Options**: `--delete-branch`, `--no-delete-branch`
- **Reference**: [environments.md](environments.md#deletion)

**environment:deploy** (aliases: `deploy`, `e:deploy`, `env:deploy`)
- **Description**: Deploy an environment's staged changes
- **Usage**: `upsun environment:deploy [-p PROJECT] [-e ENVIRONMENT]`
- **Common Options**: `--strategy [stopstart|rolling]`
- **Reference**: [deployments.md](deployments.md#deploying)

**environment:deploy:type**
- **Description**: Show or set the environment deployment type
- **Usage**: `upsun environment:deploy:type [-p PROJECT] [-e ENVIRONMENT]`
- **Reference**: [deployments.md](deployments.md)

**environment:drush** (alias: `drush`)
- **Description**: Run a drush command on the remote environment
- **Usage**: `upsun environment:drush [COMMAND] [-p PROJECT] [-e ENVIRONMENT]`
- **Reference**: [development-tools.md](development-tools.md)

**environment:http-access** (alias: `httpaccess`)
- **Description**: Update HTTP access settings for an environment
- **Usage**: `upsun environment:http-access [-p PROJECT] [-e ENVIRONMENT]`
- **Reference**: [environments.md](environments.md#http-access)

**environment:info**
- **Description**: Read or set properties for an environment
- **Usage**: `upsun environment:info [-p PROJECT] [-e ENVIRONMENT] [PROPERTY]`
- **Reference**: [environments.md](environments.md#information)

**environment:init**
- **Description**: Initialize an environment from a public Git repository
- **Usage**: `upsun environment:init [REPOSITORY] [-p PROJECT] [-e ENVIRONMENT]`
- **Reference**: [environments.md](environments.md)

**environment:list** (aliases: `environments`, `env`)
- **Description**: Get a list of environments
- **Usage**: `upsun environment:list [-p PROJECT]`
- **Common Options**: `--no-inactive`, `--pipe`
- **Reference**: [environments.md](environments.md#listing)

**environment:logs** (alias: `log`)
- **Description**: Read an environment's logs
- **Usage**: `upsun environment:logs [-p PROJECT] [-e ENVIRONMENT]`
- **Common Options**: `--tail`, `--lines`, `--app`, `--service`
- **Reference**: [development-tools.md](development-tools.md#logs)

**environment:merge** (alias: `merge`)
- **Description**: Merge an environment
- **Usage**: `upsun environment:merge [-p PROJECT] [-e ENVIRONMENT]`
- **Common Options**: `--parent`
- **Reference**: [environments.md](environments.md#merging)

**environment:pause**
- **Description**: Pause an environment
- **Usage**: `upsun environment:pause [-p PROJECT] [-e ENVIRONMENT]`
- **Reference**: [environments.md](environments.md#pause-resume)

**environment:push** (alias: `push`)
- **Description**: Push code to an environment
- **Usage**: `upsun environment:push [-p PROJECT] [-e ENVIRONMENT] [SOURCE]`
- **Common Options**: `--force`, `--no-wait`, `--activate`, `--parent`
- **Reference**: [deployments.md](deployments.md#pushing-code)

**environment:redeploy** (alias: `redeploy`)
- **Description**: Redeploy an environment
- **Usage**: `upsun environment:redeploy [-p PROJECT] [-e ENVIRONMENT]`
- **Reference**: [deployments.md](deployments.md#redeploying)

**environment:relationships** (aliases: `relationships`, `rel`)
- **Description**: Show an environment's relationships
- **Usage**: `upsun environment:relationships [-p PROJECT] [-e ENVIRONMENT]`
- **Reference**: [services-databases.md](services-databases.md#relationships)

**environment:resume**
- **Description**: Resume a paused environment
- **Usage**: `upsun environment:resume [-p PROJECT] [-e ENVIRONMENT]`
- **Reference**: [environments.md](environments.md#pause-resume)

**environment:scp** (alias: `scp`)
- **Description**: Copy files to and from an environment using scp
- **Usage**: `upsun environment:scp [SOURCE] [DESTINATION]`
- **Reference**: [development-tools.md](development-tools.md#file-transfer)

**environment:ssh** (alias: `ssh`)
- **Description**: SSH to the current environment
- **Usage**: `upsun environment:ssh [-p PROJECT] [-e ENVIRONMENT]`
- **Common Options**: `--app`, `--worker`
- **Reference**: [development-tools.md](development-tools.md#ssh-access)

**environment:synchronize** (alias: `sync`)
- **Description**: Synchronize an environment's code, data and/or resources from its parent
- **Usage**: `upsun environment:synchronize [-p PROJECT] [-e ENVIRONMENT]`
- **Common Options**: `--code`, `--data`, `--resources`
- **Reference**: [environments.md](environments.md#synchronization)

**environment:url** (alias: `url`)
- **Description**: Get the public URLs of an environment
- **Usage**: `upsun environment:url [-p PROJECT] [-e ENVIRONMENT]`
- **Common Options**: `--primary`, `--browser`
- **Reference**: [environments.md](environments.md#urls)

**environment:xdebug** (alias: `xdebug`)
- **Description**: Open a tunnel to Xdebug on the environment
- **Usage**: `upsun environment:xdebug [-p PROJECT] [-e ENVIRONMENT]`
- **Reference**: [development-tools.md](development-tools.md)

### H

**help**
- **Description**: Displays help for a command
- **Usage**: `upsun help [COMMAND]`

### I

**integration:activity:get**
- **Description**: View detailed information on a single integration activity
- **Usage**: `upsun integration:activity:get [ACTIVITY_ID] [-p PROJECT]`
- **Reference**: [integration-variables.md](integration-variables.md#integrations)

**integration:activity:list** (alias: `integration:activities`)
- **Description**: Get a list of activities for an integration
- **Usage**: `upsun integration:activity:list [-p PROJECT]`
- **Reference**: [integration-variables.md](integration-variables.md#integrations)

**integration:activity:log**
- **Description**: Display the log for an integration activity
- **Usage**: `upsun integration:activity:log [ACTIVITY_ID] [-p PROJECT]`
- **Reference**: [integration-variables.md](integration-variables.md#integrations)

**integration:add**
- **Description**: Add an integration to the project
- **Usage**: `upsun integration:add [--type TYPE]`
- **Common Options**: `--type [github|gitlab|bitbucket|webhook]`
- **Reference**: [integration-variables.md](integration-variables.md#integrations)

**integration:delete**
- **Description**: Delete an integration from a project
- **Usage**: `upsun integration:delete [INTEGRATION_ID] [-p PROJECT]`
- **Reference**: [integration-variables.md](integration-variables.md#integrations)

**integration:get**
- **Description**: View details of an integration
- **Usage**: `upsun integration:get [INTEGRATION_ID] [-p PROJECT]`
- **Reference**: [integration-variables.md](integration-variables.md#integrations)

**integration:list** (alias: `integrations`)
- **Description**: View a list of project integration(s)
- **Usage**: `upsun integration:list [-p PROJECT]`
- **Reference**: [integration-variables.md](integration-variables.md#integrations)

**integration:update**
- **Description**: Update an integration
- **Usage**: `upsun integration:update [INTEGRATION_ID] [-p PROJECT]`
- **Reference**: [integration-variables.md](integration-variables.md#integrations)

**integration:validate**
- **Description**: Validate an existing integration
- **Usage**: `upsun integration:validate [INTEGRATION_ID] [-p PROJECT]`
- **Reference**: [integration-variables.md](integration-variables.md#integrations)

### L

**list**
- **Description**: Lists commands
- **Usage**: `upsun list`

**local:dir** (alias: `dir`)
- **Description**: Find the local project root
- **Usage**: `upsun local:dir`
- **Reference**: [development-tools.md](development-tools.md)

### M

**metrics:all** (aliases: `metrics`, `met`)
- **Description**: Show CPU, disk and memory metrics for an environment
- **Usage**: `upsun metrics:all [-p PROJECT] [-e ENVIRONMENT]`
- **Reference**: [resources-scaling.md](resources-scaling.md#metrics)

**metrics:cpu** (alias: `cpu`)
- **Description**: Show CPU usage of an environment
- **Usage**: `upsun metrics:cpu [-p PROJECT] [-e ENVIRONMENT]`
- **Reference**: [resources-scaling.md](resources-scaling.md#metrics)

**metrics:disk-usage** (alias: `disk`)
- **Description**: Show disk usage of an environment
- **Usage**: `upsun metrics:disk-usage [-p PROJECT] [-e ENVIRONMENT]`
- **Reference**: [resources-scaling.md](resources-scaling.md#metrics)

**metrics:memory** (aliases: `mem`, `memory`)
- **Description**: Show memory usage of an environment
- **Usage**: `upsun metrics:memory [-p PROJECT] [-e ENVIRONMENT]`
- **Reference**: [resources-scaling.md](resources-scaling.md#metrics)

**mount:download**
- **Description**: Download files from a mount, using rsync
- **Usage**: `upsun mount:download [--mount MOUNT] [--target TARGET]`
- **Reference**: [development-tools.md](development-tools.md)

**mount:list** (alias: `mounts`)
- **Description**: Get a list of mounts
- **Usage**: `upsun mount:list [-p PROJECT] [-e ENVIRONMENT]`
- **Reference**: [development-tools.md](development-tools.md)

**mount:upload**
- **Description**: Upload files to a mount, using rsync
- **Usage**: `upsun mount:upload [--mount MOUNT] [--source SOURCE]`
- **Reference**: [development-tools.md](development-tools.md)

**multi**
- **Description**: Execute a command on multiple projects
- **Usage**: `upsun multi [COMMAND]`
- **Reference**: [projects-organizations.md](projects-organizations.md)

### O

**operation:list** (alias: `ops`)
- **Description**: List runtime operations on an environment
- **Usage**: `upsun operation:list [-p PROJECT] [-e ENVIRONMENT]`
- **Reference**: [development-tools.md](development-tools.md)

**operation:run**
- **Description**: Run an operation on the environment
- **Usage**: `upsun operation:run [OPERATION] [-p PROJECT] [-e ENVIRONMENT]`
- **Reference**: [development-tools.md](development-tools.md)

**organization:billing:address**
- **Description**: View or change an organization's billing address
- **Usage**: `upsun organization:billing:address [ORG]`
- **Reference**: [projects-organizations.md](projects-organizations.md#organizations)

**organization:billing:profile**
- **Description**: View or change an organization's billing profile
- **Usage**: `upsun organization:billing:profile [ORG]`
- **Reference**: [projects-organizations.md](projects-organizations.md#organizations)

**organization:create**
- **Description**: Create a new organization
- **Usage**: `upsun organization:create`
- **Reference**: [projects-organizations.md](projects-organizations.md#organizations)

**organization:delete**
- **Description**: Delete an organization
- **Usage**: `upsun organization:delete [ORG]`
- **Reference**: [projects-organizations.md](projects-organizations.md#organizations)

**organization:info**
- **Description**: View or change organization details
- **Usage**: `upsun organization:info [ORG]`
- **Reference**: [projects-organizations.md](projects-organizations.md#organizations)

**organization:list** (aliases: `orgs`, `organizations`)
- **Description**: List organizations
- **Usage**: `upsun organization:list`
- **Reference**: [projects-organizations.md](projects-organizations.md#organizations)

**organization:subscription:list** (alias: `org:subs`)
- **Description**: List subscriptions within an organization
- **Usage**: `upsun organization:subscription:list [ORG]`
- **Reference**: [projects-organizations.md](projects-organizations.md#organizations)

**organization:user:add**
- **Description**: Invite a user to an organization
- **Usage**: `upsun organization:user:add [--org ORG]`
- **Reference**: [access-security.md](access-security.md#organization-users)

**organization:user:delete**
- **Description**: Remove a user from an organization
- **Usage**: `upsun organization:user:delete [USER] [--org ORG]`
- **Reference**: [access-security.md](access-security.md#organization-users)

**organization:user:get**
- **Description**: View an organization user
- **Usage**: `upsun organization:user:get [USER] [--org ORG]`
- **Reference**: [access-security.md](access-security.md#organization-users)

**organization:user:list** (alias: `org:users`)
- **Description**: List organization users
- **Usage**: `upsun organization:user:list [--org ORG]`
- **Reference**: [access-security.md](access-security.md#organization-users)

**organization:user:projects** (alias: `oups`)
- **Description**: List the projects a user can access
- **Usage**: `upsun organization:user:projects [USER] [--org ORG]`
- **Reference**: [access-security.md](access-security.md#organization-users)

**organization:user:update**
- **Description**: Update an organization user
- **Usage**: `upsun organization:user:update [USER] [--org ORG]`
- **Reference**: [access-security.md](access-security.md#organization-users)

### P

**project:clear-build-cache**
- **Description**: Clear a project's build cache
- **Usage**: `upsun project:clear-build-cache [-p PROJECT]`
- **Reference**: [projects-organizations.md](projects-organizations.md#project-management)

**project:convert** (alias: `convert`)
- **Description**: Generate an Upsun compatible configuration based on the configuration from another provider
- **Usage**: `upsun project:convert [--from PROVIDER]`
- **Reference**: [projects-organizations.md](projects-organizations.md#project-management)

**project:create** (alias: `create`)
- **Description**: Create a new project
- **Usage**: `upsun project:create [--title TITLE] [--region REGION] [--org ORG]`
- **Reference**: [projects-organizations.md](projects-organizations.md#project-creation)

**project:delete**
- **Description**: Delete a project
- **Usage**: `upsun project:delete [-p PROJECT]`
- **Reference**: [projects-organizations.md](projects-organizations.md#project-management)

**project:get** (alias: `get`)
- **Description**: Clone a project locally
- **Usage**: `upsun project:get [PROJECT_ID] [DIRECTORY]`
- **Reference**: [projects-organizations.md](projects-organizations.md#project-cloning)

**project:info**
- **Description**: Read or set properties for a project
- **Usage**: `upsun project:info [-p PROJECT] [PROPERTY]`
- **Reference**: [projects-organizations.md](projects-organizations.md#project-management)

**project:init** (aliases: `init`, `ify`)
- **Description**: Initialize a project
- **Usage**: `upsun project:init`
- **Reference**: [projects-organizations.md](projects-organizations.md#project-initialization)

**project:list** (aliases: `projects`, `pro`)
- **Description**: Get a list of all active projects
- **Usage**: `upsun project:list [--org ORG]`
- **Common Options**: `--org`, `--my`, `--pipe`
- **Reference**: [projects-organizations.md](projects-organizations.md#project-listing)

**project:set-remote** (alias: `set-remote`)
- **Description**: Set the remote project for the current Git repository
- **Usage**: `upsun project:set-remote [PROJECT]`
- **Reference**: [projects-organizations.md](projects-organizations.md#project-management)

### R

**repo:cat**
- **Description**: Read a file in the project repository
- **Usage**: `upsun repo:cat [FILE] [-p PROJECT] [-e ENVIRONMENT]`
- **Reference**: [development-tools.md](development-tools.md#repository)

**repo:ls**
- **Description**: List files in the project repository
- **Usage**: `upsun repo:ls [PATH] [-p PROJECT] [-e ENVIRONMENT]`
- **Reference**: [development-tools.md](development-tools.md#repository)

**repo:read** (alias: `read`)
- **Description**: Read a directory or file in the project repository
- **Usage**: `upsun repo:read [PATH] [-p PROJECT] [-e ENVIRONMENT]`
- **Reference**: [development-tools.md](development-tools.md#repository)

**resources:build:get** (aliases: `build-resources:get`, `build-resources`)
- **Description**: View the build resources of a project
- **Usage**: `upsun resources:build:get [-p PROJECT]`
- **Reference**: [resources-scaling.md](resources-scaling.md#build-resources)

**resources:build:set** (alias: `build-resources:set`)
- **Description**: Set the build resources of a project
- **Usage**: `upsun resources:build:set [-p PROJECT]`
- **Reference**: [resources-scaling.md](resources-scaling.md#build-resources)

**resources:get** (aliases: `resources`, `res`)
- **Description**: View the resources of apps and services on an environment
- **Usage**: `upsun resources:get [-p PROJECT] [-e ENVIRONMENT]`
- **Reference**: [resources-scaling.md](resources-scaling.md#viewing-resources)

**resources:set**
- **Description**: Set the resources of apps and services on an environment
- **Usage**: `upsun resources:set [-p PROJECT] [-e ENVIRONMENT]`
- **Reference**: [resources-scaling.md](resources-scaling.md#setting-resources)

**resources:size:list** (alias: `resources:sizes`)
- **Description**: List container profile sizes
- **Usage**: `upsun resources:size:list`
- **Reference**: [resources-scaling.md](resources-scaling.md#container-sizes)

**route:get**
- **Description**: View detailed information about a route
- **Usage**: `upsun route:get [ROUTE] [-p PROJECT] [-e ENVIRONMENT]`
- **Reference**: [integration-variables.md](integration-variables.md#routes)

**route:list** (alias: `routes`)
- **Description**: List all routes for an environment
- **Usage**: `upsun route:list [-p PROJECT] [-e ENVIRONMENT]`
- **Reference**: [integration-variables.md](integration-variables.md#routes)

### S

**service:list** (alias: `services`)
- **Description**: List services in the project
- **Usage**: `upsun service:list [-p PROJECT] [-e ENVIRONMENT]`
- **Reference**: [services-databases.md](services-databases.md#service-listing)

**service:mongo:dump** (alias: `mongodump`)
- **Description**: Create a binary archive dump of data from MongoDB
- **Usage**: `upsun service:mongo:dump [-p PROJECT] [-e ENVIRONMENT]`
- **Reference**: [services-databases.md](services-databases.md#mongodb)

**service:mongo:export** (alias: `mongoexport`)
- **Description**: Export data from MongoDB
- **Usage**: `upsun service:mongo:export [-p PROJECT] [-e ENVIRONMENT]`
- **Reference**: [services-databases.md](services-databases.md#mongodb)

**service:mongo:restore** (alias: `mongorestore`)
- **Description**: Restore a binary archive dump of data into MongoDB
- **Usage**: `upsun service:mongo:restore [-p PROJECT] [-e ENVIRONMENT]`
- **Reference**: [services-databases.md](services-databases.md#mongodb)

**service:mongo:shell** (alias: `mongo`)
- **Description**: Use the MongoDB shell
- **Usage**: `upsun service:mongo:shell [-p PROJECT] [-e ENVIRONMENT]`
- **Reference**: [services-databases.md](services-databases.md#mongodb)

**service:redis-cli** (alias: `redis`)
- **Description**: Access the Redis CLI
- **Usage**: `upsun service:redis-cli [-p PROJECT] [-e ENVIRONMENT]`
- **Reference**: [services-databases.md](services-databases.md#redis)

**service:valkey-cli** (alias: `valkey`)
- **Description**: Access the Valkey CLI
- **Usage**: `upsun service:valkey-cli [-p PROJECT] [-e ENVIRONMENT]`
- **Reference**: [services-databases.md](services-databases.md#valkey)

**source-operation:list** (alias: `source-ops`)
- **Description**: List source operations on an environment
- **Usage**: `upsun source-operation:list [-p PROJECT] [-e ENVIRONMENT]`
- **Reference**: [integration-variables.md](integration-variables.md#source-operations)

**source-operation:run**
- **Description**: Run a source operation
- **Usage**: `upsun source-operation:run [OPERATION] [-p PROJECT] [-e ENVIRONMENT]`
- **Reference**: [integration-variables.md](integration-variables.md#source-operations)

**ssh-cert:load**
- **Description**: Generate an SSH certificate
- **Usage**: `upsun ssh-cert:load`
- **Reference**: [access-security.md](access-security.md#ssh-certificates)

**ssh-key:add**
- **Description**: Add a new SSH key
- **Usage**: `upsun ssh-key:add [PATH]`
- **Reference**: [access-security.md](access-security.md#ssh-keys)

**ssh-key:delete**
- **Description**: Delete an SSH key
- **Usage**: `upsun ssh-key:delete [ID]`
- **Reference**: [access-security.md](access-security.md#ssh-keys)

**ssh-key:list** (alias: `ssh-keys`)
- **Description**: Get a list of SSH keys in your account
- **Usage**: `upsun ssh-key:list`
- **Reference**: [access-security.md](access-security.md#ssh-keys)

**subscription:info**
- **Description**: Read or modify subscription properties
- **Usage**: `upsun subscription:info [-p PROJECT]`
- **Reference**: [projects-organizations.md](projects-organizations.md#subscriptions)

### T

**team:create**
- **Description**: Create a new team
- **Usage**: `upsun team:create [--org ORG]`
- **Reference**: [access-security.md](access-security.md#teams)

**team:delete**
- **Description**: Delete a team
- **Usage**: `upsun team:delete [TEAM] [--org ORG]`
- **Reference**: [access-security.md](access-security.md#teams)

**team:get**
- **Description**: View a team
- **Usage**: `upsun team:get [TEAM] [--org ORG]`
- **Reference**: [access-security.md](access-security.md#teams)

**team:list** (alias: `teams`)
- **Description**: List teams
- **Usage**: `upsun team:list [--org ORG]`
- **Reference**: [access-security.md](access-security.md#teams)

**team:project:add**
- **Description**: Add project(s) to a team
- **Usage**: `upsun team:project:add [TEAM] [--org ORG]`
- **Reference**: [access-security.md](access-security.md#teams)

**team:project:delete**
- **Description**: Remove a project from a team
- **Usage**: `upsun team:project:delete [PROJECT] [TEAM] [--org ORG]`
- **Reference**: [access-security.md](access-security.md#teams)

**team:project:list** (aliases: `team:projects`, `team:pro`)
- **Description**: List projects in a team
- **Usage**: `upsun team:project:list [TEAM] [--org ORG]`
- **Reference**: [access-security.md](access-security.md#teams)

**team:update**
- **Description**: Update a team
- **Usage**: `upsun team:update [TEAM] [--org ORG]`
- **Reference**: [access-security.md](access-security.md#teams)

**team:user:add**
- **Description**: Add a user to a team
- **Usage**: `upsun team:user:add [TEAM] [--org ORG]`
- **Reference**: [access-security.md](access-security.md#teams)

**team:user:delete**
- **Description**: Remove a user from a team
- **Usage**: `upsun team:user:delete [USER] [TEAM] [--org ORG]`
- **Reference**: [access-security.md](access-security.md#teams)

**team:user:list** (alias: `team:users`)
- **Description**: List users in a team
- **Usage**: `upsun team:user:list [TEAM] [--org ORG]`
- **Reference**: [access-security.md](access-security.md#teams)

**tunnel:close**
- **Description**: Close SSH tunnels
- **Usage**: `upsun tunnel:close [-p PROJECT] [-e ENVIRONMENT]`
- **Reference**: [development-tools.md](development-tools.md#tunnels)

**tunnel:info**
- **Description**: View relationship info for SSH tunnels
- **Usage**: `upsun tunnel:info [-p PROJECT] [-e ENVIRONMENT]`
- **Reference**: [development-tools.md](development-tools.md#tunnels)

**tunnel:list** (alias: `tunnels`)
- **Description**: List SSH tunnels
- **Usage**: `upsun tunnel:list [-p PROJECT] [-e ENVIRONMENT]`
- **Reference**: [development-tools.md](development-tools.md#tunnels)

**tunnel:open**
- **Description**: Open SSH tunnels to an app's relationships
- **Usage**: `upsun tunnel:open [-p PROJECT] [-e ENVIRONMENT]`
- **Reference**: [development-tools.md](development-tools.md#tunnels)

**tunnel:single**
- **Description**: Open a single SSH tunnel to an app relationship
- **Usage**: `upsun tunnel:single [RELATIONSHIP] [-p PROJECT] [-e ENVIRONMENT]`
- **Reference**: [development-tools.md](development-tools.md#tunnels)

### U

**user:add**
- **Description**: Add a user to the project
- **Usage**: `upsun user:add [EMAIL] [-p PROJECT]`
- **Reference**: [access-security.md](access-security.md#project-users)

**user:delete**
- **Description**: Delete a user from the project
- **Usage**: `upsun user:delete [EMAIL] [-p PROJECT]`
- **Reference**: [access-security.md](access-security.md#project-users)

**user:get**
- **Description**: View a user's role(s)
- **Usage**: `upsun user:get [EMAIL] [-p PROJECT]`
- **Reference**: [access-security.md](access-security.md#project-users)

**user:list** (alias: `users`)
- **Description**: List project users
- **Usage**: `upsun user:list [-p PROJECT]`
- **Reference**: [access-security.md](access-security.md#project-users)

**user:update**
- **Description**: Update user role(s) on a project
- **Usage**: `upsun user:update [EMAIL] [-p PROJECT]`
- **Reference**: [access-security.md](access-security.md#project-users)

### V

**variable:create**
- **Description**: Create a variable
- **Usage**: `upsun variable:create [-p PROJECT] [-e ENVIRONMENT]`
- **Common Options**: `--name`, `--value`, `--json`, `--sensitive`, `--visible-build`, `--visible-runtime`
- **Reference**: [integration-variables.md](integration-variables.md#variables)

**variable:delete**
- **Description**: Delete a variable
- **Usage**: `upsun variable:delete [NAME] [-p PROJECT] [-e ENVIRONMENT]`
- **Reference**: [integration-variables.md](integration-variables.md#variables)

**variable:get** (alias: `vget`)
- **Description**: View a variable
- **Usage**: `upsun variable:get [NAME] [-p PROJECT] [-e ENVIRONMENT]`
- **Reference**: [integration-variables.md](integration-variables.md#variables)

**variable:list** (aliases: `variables`, `var`)
- **Description**: List variables
- **Usage**: `upsun variable:list [-p PROJECT] [-e ENVIRONMENT]`
- **Reference**: [integration-variables.md](integration-variables.md#variables)

**variable:update**
- **Description**: Update a variable
- **Usage**: `upsun variable:update [NAME] [-p PROJECT] [-e ENVIRONMENT]`
- **Reference**: [integration-variables.md](integration-variables.md#variables)

### W

**worker:list** (alias: `workers`)
- **Description**: Get a list of all deployed workers
- **Usage**: `upsun worker:list [-p PROJECT] [-e ENVIRONMENT]`
- **Reference**: [resources-scaling.md](resources-scaling.md#workers)

## Quick Reference by Workflow

For workflow-based navigation, see the following reference files:

- **Deployment workflows**: [deployments.md](deployments.md)
- **Environment management**: [environments.md](environments.md)
- **Backup/restore**: [backups.md](backups.md)
- **Resource configuration**: [resources-scaling.md](resources-scaling.md)
- **Database operations**: [services-databases.md](services-databases.md)
- **Access control**: [access-security.md](access-security.md)
- **Configuration**: [integration-variables.md](integration-variables.md)
- **Development tools**: [development-tools.md](development-tools.md)
