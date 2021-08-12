# Rally App Builder

[![Build Status](https://travis-ci.org/RallyApps/rally-app-builder.png?branch=master)](https://travis-ci.org/RallyApps/rally-app-builder)

Rally App Builder is a [Node.js](http://nodejs.org/) command line utility for building apps using the [Rally App SDK](https://help.rallydev.com/apps/2.1/doc/).

## Installation

Rally App Builder is most easily used when installed globally:

`npm install -g rally-app-builder`

However, if that does't work (permission errors, etc.) it can be installed locally as well:

`npm install rally-app-builder`

## API

  Usage: rally-app-builder [command] [options]

  Commands:

    init [--name] [--sdk] [--server]
    Creates a new Rally App project

    build [--templates]
    Builds the current App

    run [--port]
    Starts a local server and launches the App in the default browser

    watch [--templates] [--ci]
    Automatically builds the App when files are changed

    test [--debug] [--spec]
    Runs the App tests

  Options:

    -h, --help     output usage information
    -v, --version  output the version number


## Commands

### init
`rally-app-builder init --name=myNewApp`
Creating a new Rally App is as easy as using init. The init command creates you a  After init creates your App it will automatically run the build command on it for you.

The init command takes a few parameters.  
*  name : The first is the name for your new App.
    *  `rally-app-builder init --name=myNewApp`
*  sdk(optional) : The version of the SDK your App will be created against.
    *  `rally-app-builder init --name=myNewApp --sdk=2.1`
*  server(optional) : The server you want the debug file to point to. The command below will create a new App using version 2.0 and pointing to the server myownRally.com
    *  `rally-app-builder init --name=myNewApp --sdk=2.1 --server=https://myOwnRally.com`

### build

Use the build command to compile your App into a single HTML page that can be copy and pasted into a Rally customer html [page](http://www.rallydev.com/custom-html)
Run this command before you check your file into source control or whenever you make a change to your config.json file.

The build command can optionally take a templates parameter to use custom html output templates.  Note this is an advanced usage and is generally not necessary unless you are trying to tweak the structure of the generated html output.

`rally-app-builder build --templates=./templates`

Also note this parameter can be specified in the config.json file as well.

#### Custom build steps

You can define pre and post build commands to be executed by adding them to your config.json. These can be used to extend and support the rally app build/concatenation steps. An example using grunt (which by default will run your tests):
```
{
   "scripts": {
      "prebuild": "./node_modules/.bin/grunt"
      "postbuild": "echo 'build completed'"
   }
}
```


### run
`rally-app-builder run`

The run command starts a local http server and launches your App-debug.html file in the default browser for quick an easy development.
By default the server listens on port 1337.  This can be changed as follows:

`rally-app-builder run --port=9999`

### watch
`rally-app-builder watch [--templates] [--ci]`

The watch command listens for changes to app files and automatically rebuilds the app.
If the optional `--ci` flag is passed the tests will also be run.

### test
`rally-app-builder test [--debug] [--spec]`

The test command runs the tests.  By default all tests will be run headlessly.
If the `--debug` flag is specified the tests will be run in the default browser instead.
If the `--spec` flag is specified only the test(s) matching the specified file pattern will be run.

The [Testing Apps](https://help.rallydev.com/apps/2.1/doc/#!/guide/testing_apps) guide in the App SDK help documentation is a great resource to learn how to get started writing tests for your apps.
