Clockbeat Timesheet restyle Chrome extension
============================================

This Chrome extension restyles the clockbeat timesheet system to make it look a bit nicer,
and adds a handy filtering system to find those activity codes easily.


Credits
-------
Big thanks go to [David Johnstone](http://davidjohnstone.net), who did most of the restyling.
Here is his [original scripts](http://www.markitdown.net/view/0d60e424)

Development
-----------

You'll need to install node.js and npm (https://github.com/joyent/node/wiki/Installation and http://npmjs.org/)
Then you'll need coffeescript and coffeejade:

    sudo npm install coffeescript -g
    git clone https://github.com/fusesource/coffeejade
    cd coffeejade
    # Change commander in package.json to be version 0.3.2
    sudo npm install -g

Compiling the coffeescript is done by executing coffee.sh. This will make coffee watch the src folder and compile any changes into the extension folder.

Compiling the Jade templates is done by executing jade.sh, which will compile all the templates in the templates folder into a single javascript file in the extension folder.

Alternatively, you can just execute "cake watch" from the root and when any of these files are changed, they are automatically transpiled for you.
