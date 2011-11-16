#!/bin/sh
jade -o {node:false} < templates/layout.jade > extension/app.html
coffeejade --amdout extension/templates.js.1 templates
echo "
(function() {
var exports;
var define = function(f) {
    if (typeof exports !== \"undefined\" && exports !== null) {
        exports;
    } else {
        exports = window;
    };
    var templates = exports.templates = f();
    exports.partial = templates.partial = function(str, locals) { return templates['templates/' + str + '.jade'](locals);}
};
" > extension/templates.js
cat extension/templates.js.1 >> extension/templates.js
echo "
})();" >> extension/templates.js
rm extension/templates.js.1

