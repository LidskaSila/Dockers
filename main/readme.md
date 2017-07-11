## First Run

- Copy `.env.dist` to `.env`, edit `LS_WWW_ROOT` with path to the Main project
- Copy current DB dump to `./mysql/dump.sql`
- `docker-compose build`
- `docker-compose up`

Configure the Main project (`app/config/parameters.neon`):

```
parameters:
	database:
		default:
			host: mysql

	rabbitmq:
		host: rabbit

redis:
	host: redis
```

Change `c:\Windows\System32\drivers\etc\hosts` (or `/etc/hosts`) so that the domain `localhost.lidskasila.cz` points to the IP address of the Docker Machine (`docker-machine ip`). This IP address might change eventually, but if you're using VirtualBox only for Docker, it won't.

## DB to RAM

To speed up DB operations:

- Increase memory limit of the Docker Machine in VirtualBox at least to 5 GB.
- Run `docker-compose exec mysql db-to-ram`

Note that when you stop the container, you'll lose all changed data. When you start the container again, it will use data from the `/db-disk` directory.

## Running Application's CLI Commands

You can call commands using `docker-compose exec`, for example:

```bash
docker-compose exec php php www/index.php mig:mig
#                   |   |                 |
#                   |   |                 Command args
#                   |   Command inside the container
#                   Container name
```

To run a phing command:

```bash
docker-compose exec php vendor/bin/phing fix-branch
```

Or you can open container's Bash and operate from there:

```bash
docker-compose exec php bash
```

## Debugging with Xdebug

- Change `PHP_DEBUGGER` to `xdebug` in `.env` file. 
- Use Xdebug Helper Chrome extension to set the Xdebug cookie.
- When the debugger connects the IDE for the first time, set the path mapping.

## Profiling with Blackfire.io

- Change `PHP_DEBUGGER` to `blackfire` in `.env` file.
- Setup `BLACKFIRE_SERVER_ID` and `BLACKFIRE_SERVER_TOKEN`.

## Performance Tricks

- Use the host system for heavy disk operations (like `composer install` or `git`).
- Use DB in memory.
- Possible solution for slow filesystem sync: Instead of mounting the project's directory from the host, copy the whole project into a container, add an FTP server (eg. [webdevops/vsftp](https://dockerfile.readthedocs.io/en/latest/content/DockerImages/dockerfiles/vsftp.html)) and use your IDE's FTP synchronization.
