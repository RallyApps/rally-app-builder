#rally-app-builder
=================
[![Build Status](https://travis-ci.org/RallyApps/rally-app-builder.png?branch=master)](https://travis-ci.org/RallyApps/rally-app-builder)

## Install 

First Install [Node.js](http://nodejs.org/)

Second Install the Rally App Builder Globally
`npm install -g rally-app-builder`

If you don't have permission to install it globally you can install it locally like this

`npm install rally-app-builder`

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


## Commands

###init
`rally-app-builder init myNewApp`
Creating a new Rally App is as easy as using init. The init command creates you a  After init creates your App it will automatically run the build command on it for you.

The init command takes a few parameters.
*name : The first is the name for your new App.
    *`rally-app-builder init myNewApp`
*sdk_version(optional) : The version of the SDK your App will be created against.
    *`rally-app-builder init myNewApp 2.0p2`
*server(optional) : The server you want the debug file to point to. The command below will create a new App using version 2.0p2 and pointing to the server myownRally.com
    * `rally-app-builder init myNewApp 2.0p2 https://myOwnRally.com`

### build

Use the build command to compile your App into a single HTML page that can be copy and pasted into a Rally customer html [page](http://www.rallydev.com/custom-html)
Run this command before you check your file into source control or whenever you make a change to your config.json file.



### clone
`rally-app-builder clone RallyApps StoryBoard`

Most Rally Apps are created by using an existing App as a template.
By using the rally-app-builder clone command you can get a copy of the existing App without installing the Git CLI.
This command makes some changes to the config file so that we can tell which App you based your work on. As we determine
which apps you are most interested in customizing we take that as input on ways to improve the existing catalog App.


### Unit Testing your new App.

The guide for unit testing your App can be found on this [page](testing.markdown).



### Rally-App-Builder is provided under the MIT license.
