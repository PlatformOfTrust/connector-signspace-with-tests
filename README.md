# Connector

HTTP server to handle Platform of Trust Broker API requests.

## Getting Started

These instructions will get you a copy of the connector up and running.

### Prerequisites

Mandatory environment variables are:
```
TRANSLATOR_DOMAIN=www.example.com
```

Connector generates RSA keys automatically, but keys can be also applied from the environment.
```
PRIVATE_KEY=-----BEGIN PRIVATE KEY-----\nMII...
PUBLIC_KEY=-----BEGIN PUBLIC KEY-----\nMII...
```

Issuing and renewing free Let's Encrypt SSL certificate by Greenlock Express v4 is supported by including the following variable.
```
GREENLOCK_MAINTANER=info@example.com
```

### PoT Public Keys

Pot Public Keys can be configured from

```
config/definitions/pot.js
```

### Passing SignSpace credentials 

Steps required to provide connector with the SignSpace API credentials for obtaining data:

Example for config.json file with mandatory KEYS:
```
{
	"SIGNSPACE_CLIENT_ID": "...",
	"SIGNSPACE_CLIENT_SECRET": "...",
	"SIGNSPACE_AUTH_URL":"https://auth-signspace.beta...",
	"SIGNSPACE_ENDPOINT": "https://signspace.beta..."
}
```

Command used on a config.json file with SignSpace credentials to encrypt it:
```
base64 -i config.json -o test-base
```

Then encrypted credentials string must be added as $CONFIGS env variable and passed to docker container upon starting:
```
docker run -e CONFIGS -p 8080:8080 -d daniilmass/signspace...
```

## Request body examples

Below are few examples of a SignSpace request body and parameters

```
{
	"timestamp": "2020-06-03T11:32:00+03:00",
	"productCode": "denis-signspace",
	"parameters": {
		"filter": [],
		"country": "fi",
		"idOfficial": "3042282-9",
		"offset": 0,
		"limit": 5,
		"queryText": "",
		"startTime": "2019-10-19T13:20:09+03:00",
		"endTime": "2020-10-19T13:20:09+03:00",
		"status": [
			"Canceled",
			"In Progress",
			"Open"
		]
	}
}
```

```
{
	"timestamp": "2020-06-03T11:32:00+03:00",
	"productCode": "denis-signspace",
	"parameters": {
		"filter": [],
		"country": "fi",
		"idOfficial": "3042282-9",
		"offset": 0,
		"limit": 10,
		"queryText": "",
		"startTime": "2019-10-19T13:20:09+03:00",
		"endTime": "2020-06-04T13:20:09+03:00",
		"status": [ "In Progress" ]
	}
}
```

## Tests

See /robottests for tests and description.


