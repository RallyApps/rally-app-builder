#rally-app-builder
=================
[![Build Status](https://travis-ci.org/RallyApps/rally-app-builder.png?branch=master)](https://travis-ci.org/RallyApps/rally-app-builder)

## Usage

1. Install [Node.js](http://nodejs.org/)

2. Create a folder for your new app and change directories into it

3. Install the Rally App Builder:

  * Install globally:
    >`npm install -g rally-app-builder`

  * If you don't have permission to install it globally you can install it locally: 
    >`npm install rally-app-builder`

4. Create your app with `rally-app-builder init [name]`

5. Run `npm install`

* Run `grunt` to compile and build everything
* Run `grunt test` to run jasmine tests
* Run `grunt build` to build the deployable HTML file for running inside Rally
* Run `grunt deploy` to test and deploy your app to Rally

## API

  Usage: rally-app-builder [options] [command]

  Commands:

    init [name] [sdk_version] [server]
    Creates a new Rally App project in the working directory
    
    clone [organization] [repo]
    Creates a new Rally App project in the working directory from an existing GitHub project. 

  Options:

    -h, --help     output usage information
    -V, --version  output the version number

## Commands

### init
`rally-app-builder init myNewApp`
Creating a new Rally App is as easy as using init. The init command creates you an App for use inside of Rally.

The init command takes a few parameters.
*name : The first is the name for your new App.
    *`rally-app-builder init myNewApp`
*sdk_version(optional) : The version of the SDK your App will be created against.
    *`rally-app-builder init myNewApp 2.0p2`
*server(optional) : The server you want the debug file to point to. The command below will create a new App using version 2.0p2 and pointing to the server myownRally.com
    * `rally-app-builder init myNewApp 2.0p2 https://myOwnRally.com`


### clone
`rally-app-builder clone RallyApps StoryBoard`
The first pararmeter, in this case "RallyApps", is the name of the GitHub organization.
The second parameter, "StoryBoard", is the name of the repository.

Most Rally Apps are created by using an existing App as a template.
By using the rally-app-builder clone command you can get a copy of the existing App without installing the Git CLI.
This command makes some changes to the config file so that we can tell which App you based your work on. As we determine
which apps you are most interested in customizing we take that as input on ways to improve the existing catalog App.

## Rally Deploy Grunt Task

```shell
npm install rally-app-builder
```

```js
grunt.loadNpmTasks('rally-app-builder');
```

### Options

#### server
Type: `string`
Default "rally1.rallydev.com"

#### projectOid
Type: `integer`

This needs to be any valid Project Object ID.  You can find this in the URI when logged into Rally

#### deployFile
Type: `string`

Default: "deploy.json"

This file stores the Rally generated Page and App IDs when deploying a new app

#### credentialsFile
Type: `string`

Default: "credentials.json"

This file is by default not checked into source respository and contains the username and password IN CLEAR TEXT to be used in the deploy task


#### tab
Type: `string`

Valid Options: `myhome`, `backlogandschedules`

Default: "myhome"

This is the Rally tab that the newly created app will be placed

#### pageName
Type: `string`

Default: "App Name"

This is the name of the Page on the tab that will be created

#### shared
Type: `string` or `boolean`

Default: "off"

This option will make a newly created page shared on the Workspace.  You must be a Workspace Admin to use the `on` option

