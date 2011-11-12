#!/bin/sh
coffeejade --amdout extension/templates.js.1 templates
echo "var define = function(f) {window.templates = f();};" > extension/templates.js
cat extension/templates.js.1 >> extension/templates.js
rm extension/templates.js.1

