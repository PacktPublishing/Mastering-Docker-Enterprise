# PoC Application Containerization Simulation

This exercise runs with Windows contaners.  Also, these images large and take a while to pull down.

## Build database Image

- [Dockerfile for the DB - Click here](../mta-netfx-dev/docker/db/Dockerfile)

Build the database image
```Powershell
mta-netfx-dev:PS> docker image build -t db-image:v1 --file .\docker\db\Dockerfile .
```

Test the database image

```Powershell
mta-netfx-dev:PS> docker container run --name db-test -d -p 5432:5432 db-image:v1

# Execute a new shell process inside of the db container
mta-netfx-dev:PS> docker container exec -it db-test powershell
> PS C:\init> Invoke-SqlCmd -Query 'SELECT TOP 1 1 FROM Countries' `
 -Database SignUpDb
...
> PS C:\init> exit

# Clean up db-test container
mta-netfx-dev:PS> docker container rm -f db-test
```

## Build .Net 3.5 Builder  Image
- [Dockerfile for the .NET 3.5 Builder - Click here](../mta-netfx-dev/docker/web-builder/3.5/Dockerfile)

Create a "builder" we can use to build our .NET 3.5 applications. We will use this in to build our application in the next step.

```Powershell
mta-netfx-dev:PS> docker image build -t mta-sdk-web-builder:3.5 --file .\docker\web-builder\3.5\Dockerfile .

```

_If you get a build error like as shown below, your firewall is probably blocking_

> Invoke-WebRequest : Unable to connect to the remote server
> At line:1 char:76
> Invoke-WebRequest -UseBasicParsing https://download.visua

> Here are some firewall tips: <https://stackoverflow.com/questions/42203488/settings-to-windows-firewall-to-allow-docker-for-windows-to-share-drive/43904051>

## Use our new .NET 3.5 Builder Image to Build the web image 
- [Dockerfile for the .NET 3.5 Builder - Click here](../mta-netfx-dev/docker/web/Dockerfile)

```Powershell
mta-netfx-dev:PS> docker image build -t app-image:v1 --file .\docker\web\Dockerfile 
```

## Local integration test of our new containers

```Powershell
# Start the database container
mta-netfx-dev:PS> docker container run --network nat --name signup-db -d db-image:v1

# Start the application container
mta-netfx-dev:PS> docker container run --network nat -p 8000:80 --name signup-app -d app-image:v1
```

Test using local workstation's IP address (not localhost hostname)
> PS> ipconfig 
> 
> _Look for IPv4 Address of active adapter_

### Open browser to http://xxx.xxx.xxx.xxx:8000 (i.e., http://192.168.1.70:8000/)

### Clean up local integration test containers

```Powershell
mta-netfx-dev:PS> docker container rm -f signup-app signup-db
```

# Tag & Push Images

```Powershell
mta-netfx-dev:PS> docker image tag db-image:v1 dtr.mydomain.com/dev/db-image:v1
mta-netfx-dev:PS> docker image tag app-image:v1 dtr.mydomain.com/dev/app-image:v1
```

# Deploy Test Stack

### Move to the directory where you unzipped the UCP client bundle

```Powershell
cli-admin:PS> Import-Module .\env.ps1

Security warning
Run only scripts that you trust. While scripts from the internet can be useful, this script can potentially harm your
computer. If you trust this script, use the Unblock-File cmdlet to allow the script to run without this warning
message. Do you want to run C:\Users\ntc-dev\ntc-prod\cli-admin\env.ps1?

[D] Do not run  [R] Run once  [S] Suspend  [?] Help (default is "D"): R
Cluster "ucp_ucp.mydomain.com:6443_admin" set.
User "ucp_ucp.mydomain.com:6443_admin" set.
Context "ucp_ucp.mydomain.com:6443_admin" created.

# Test the bundle by listing cluster nodes
cli-admin:PS> docker node ls
ID                            HOSTNAME              STATUS              AVAILABILITY        MANAGER STATUS      ENGINE VERSION
1rqhb4rzj3gk4mdgk8kza53jp     ntc-dtr-1.mydomain.com   Ready               Active                                  18.09.0
x27m3yjlh6b0wczmo0mcahkjv     ntc-dtr-2.mydomain.com   Ready               Active                                  18.09.0
rw2tuw53wl34pv6sfj213845a     ntc-dtr-3.mydomain.com   Ready               Active                                  18.09.0
q5q9u0yr7p8r0mcz4ob24s2kz     ntc-ucp-1.mydomain.com   Ready               Active              Reachable           18.09.0
6ce10w7leu0a9my91w39j5eai     ntc-ucp-2.mydomain.com   Ready               Active              Reachable           18.09.0
bd1bwcbqkpbulhwvm0fllgm55 *   ntc-upc-3.mydomain.com   Ready               Active              Leader              18.09.0
3lw64q2o818xgnberjry410o7     ntc-wrk-1.mydomain.com   Ready               Active                                  18.09.0
zxcosutrxr3rhzkz2h6ld0khj     ntc-wrk-2.mydomain.com   Ready               Active                                  18.09.0
sfuxfiwhf2tpd6q3i7fbmaziv     ntc-wrk-3.mydomain.com   Ready               Active                                  18.09.0
```

### Run the docker stack deploy

```Powershell
# change directory back to mta-netfx-dev, then deploy the stack

mta-netfx-dev:PS> docker stack deploy -c stack.yml test-win-stack
Creating network test-win-stack_app-neto
Creating service test-win-stack_signup-db
Creating service test-win-stack_signup-app
```

# Point your brower at the Windows's nodes public IP on port 8000 to see the site

### If you get an error "Woah!"...

> scale the app to zero and back to 1

```Powershell
docker service scale test_signup-app=0
#...
docker service scale test_signup-app=1
```
