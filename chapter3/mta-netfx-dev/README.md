# PoC Application Containerization Simulation

This exercise runs with Windows contaners.  Also, these images large and take a while to pull down.

## Build database Image

- [Dockerfile for the DB - Click here](../master/chapter3/mta-netfx-dev/docker/db/Dockerfile)

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
- [Dockerfile for the .NET 3.5 Builder - Click here](../master/chapter3/mta-netfx-dev/docker/web-builder/3.5/Dockerfile)

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
- [Dockerfile for the .NET 3.5 Builder - Click here](../master/chapter3/mta-netfx-dev/docker/web/Dockerfile)

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