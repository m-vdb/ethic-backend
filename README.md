# ethic-backend
Ethic's backend code.

## Installation

You should have node installed. You can use [nvm](https://github.com/creationix/nvm).
Then you can do the following:
```bash
$ npm install .
```

## Developing

To start the test server type:
```bash
$ npm start
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
