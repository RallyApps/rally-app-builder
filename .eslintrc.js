module.exports = {
    "extends": "airbnb-base",
    "env": {
        "browser": true,
        "node": true
    },
    "plugins": [
        "import"
    ],
    rules: {
        "no-unused-vars": [1, { "vars": "local", "args": "none" }],
        "no-debugger": 'warn',
        "indent": ["error", 4],
        "linebreak-style": 0,
        "comma-dangle": 0,
        "no-throw-literal": 0,
        "prefer-const": 0,
        "prefer-rest-params": 'warn',
        "default-case": 'warn',
        "no-undef": 'warn',
        "no-shadow": 'warn',
        "no-lonely-if": 0,
        "no-use-before-define": 'warn',
        "no-return-assign": 'warn',
        "no-plusplus": 0,
        "no-param-reassign": 0,
        "max-len": 0,
        "no-trailing-spaces": 0,
        "no-console": 0,
        "no-confusing-arrow": 0,
        "class-methods-use-this": 0,
        "no-underscore-dangle": 0,
        "one-var-declaration-per-line": ["error", "initializations"],
        "one-var": ["error", { "initialized": "never", "uninitialized": "always" }]
    },
    "globals": {
    }
};