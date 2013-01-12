rally-app-builder
=================
[![Build Status](https://travis-ci.org/ferentchak/rally-app-builder.png?branch=master)](https://travis-ci.org/ferentchak/rally-app-builder)

## Install 

First Install [Node.js](http://nodejs.org/)

Second Install the Rally App Builder Globally
`npm install -g rally-app-builder`

If you don't have permission to install it globally you can install it locally like this

`npm install -g rally-app-builder`

## API

  Usage: rally-app-builder [options] [command]

  Commands:

    init [name] [sdk_version] [server]
    Creates a new Rally App project
    
    build 
    Builds the current App
    
    clone [organization] [repo]
    Creates a new Rally App project from an existing GitHub project. 

  Options:

    -h, --help     output usage information
    -V, --version  output the version number


## Run Tests

To run the tests:
npm test
