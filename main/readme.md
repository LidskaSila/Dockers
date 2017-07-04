Quickstart:

- Copy `.env.dist` to `.env`, edit `LS_WWW_ROOT` with path to the Main project
- Copy current DB dump to `./mysql/dump.sql`
- `docker-compose build mysql`
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
