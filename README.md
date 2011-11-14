Clockbeat Timesheet restyle Chrome extension
============================================

This Chrome extension restyles the clockbeat timesheet system to make it look a bit nicer,
and adds a handy filtering system to find those activity codes easily.

View this on the [Chrome Web Store](https://chrome.google.com/webstore/detail/njmnbiecjddpmnpekdghdmfcjojngagd)

Credits
-------
Big thanks go to [David Johnstone](http://davidjohnstone.net), who did most of the restyling.
Here is his [original scripts](http://www.markitdown.net/view/0d60e424)

Thanks to [Stephen Moore](https://github.com/delfick) for his contributions to this extension.

Development
-----------

You'll need to install node.js and npm (https://github.com/joyent/node/wiki/Installation and http://npmjs.org/)
Then you'll need extra libraries

    sudo npm install coffee-script@1.1.2 stylus -g
    npm install watch jsdom jasmine-node underscore
    git clone https://github.com/fusesource/coffeejade
    cd coffeejade
    # Change commander in package.json to be version 0.3.2
    sudo npm install -g

To do all the transpiling of coffeescript, jade and stylus templates into the extension folder, just run "cake watch" from the root folder.

This will use the files found in bin to run the necessary commands when these files are changed.
