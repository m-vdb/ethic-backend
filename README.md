# ethic-backend

[![Circle CI](https://circleci.com/gh/m-vdb/ethic-backend.svg?style=shield&circle-token=8499ee22b10ad230a99c5892e0b3ba22ddd298ee)](https://circleci.com/gh/m-vdb/ethic-backend/tree/master)

Ethic's backend code.

## Installation

You'll need to be able to access a MongoDB and a Redis server. On Mac OSX, you can run:
```bash
$ brew install mongodb redis
```
After installation, to make sure the servers are booted properly, you can run separately `mongo` and `redis-cli` to connect to them.

You should have node installed. You can use [nvm](https://github.com/creationix/nvm).
Then you can do the following:
```bash
$ npm install .
```

## Developing

To start the server and the worker (which would process async tasks) type the following:
```bash
$ npm start
$ node worker.js
```

## Using the API

- **POST** `/members` : create a member
- **GET** `/members/<address>` : get member object
- **POST** `/members/<id>/accept` : accept member after background check
- **POST** `/members/<id>/deny` : deny member after background check
- **GET** `/members/<address>/policies` : get the list of policies of the member
- **POST** `/members/<address>/policies` : create a policy
- **GET** `/members/<address>/claims` : get the list of previous claims of the member
- **POST** `/members/<address>/claims` : create a claim


## Run the tests

Run `npm test`.
