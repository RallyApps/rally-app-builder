## Unit Testing Apps

Writing unit tests for your app is a great idea.  Luckily, it's easy to do with Rally App Builder v1.3.1 and above!

### Writing Tests
There should already be a sample test/AppSpec.js file with which to get started.  Running the tests is simple:

`> rally-app-builder test`

Tests are written using the BDD framework [Jasmine](http://jasmine.github.io/2.2/introduction.html).  They also rely heavily on the [Rally SDK2 Test Utils](https://github.com/RallyApps/sdk2-test-utils) library.  Check out the documentation on both of those for more examples to get started with!

By default tests are run headlessly using PhantomJS.  It's often useful during development to be able to debug them in a local browser:

`> rally-app-builder test --debug`

You can also set up your tests to run automatically as you change code:

`> rally-app-builder watch --ci`

### Continuous Integration

Your app already has a .travis.yml file configured for Travis CI.  If your app is hosted in a public github repository it's super easy to configure it to automatically run tests when you push your code!

[Getting Started with Travis CI](https://docs.travis-ci.com/user/getting-started/)
