var fs = require('fs');
var cmdr = require('commander');

require('iced-coffee-script');
var version = JSON.parse(fs.readFileSync("package.json")).version;
cmdr
    .version(version)
    .option('-s', '--server <server>', 'server: Specifies the server to connect to [rally1]')
    .option('-a', '--package <package>', 'new: Specifies the app package [app]')
    .option('-l', '--language <language>', 'new: Specifies the default language for the app [javascript]');
//	.option('-u', '--username <username>', 'server: Specifies the username')
//	.option('-p', '--password <password>', 'server: Specifies the password')
//	.option('-o', '--offline', 'server: Sets the server to offline mode.  All queries will return cached values')
//	.option('-r', '--port <port>', 'server: Specifies the port [3000]', Number)


cmdr
	.command('new [project]')
	.description("Creates a new Rabt project")
	.action(function() {
		require('./rabt-new').run();
	});

cmdr
    .command('clone [project]')
	.description("Creates a new Rabt project from an existing GitHub project")
	.action(function() {
		//require('./github-adapter').run();
	});

cmdr
	.command('server')
	.description("Starts a web server to host your App.  Also caches requests for offline development")
	.action(function() {
		require('./rabt-server').run();
	});

cmdr.parse(process.argv);
