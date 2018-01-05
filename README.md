# BASH scripts as plugins
A repository of shell/bash scripts, arranged as plugins.

Each plugin provides commonly used functionalities; the
```pragma.sh``` script sets up a set of functions providing the 
infrastructure that allows plugins not to be imported (that is: 
sourced) more than once. Plugins can each make use of others' 
functionalities by importing them via pragma instructions.

Each plugin is a shell script with some pragma instructions added 
at the top and at the bottom. They are located in a common directory:
if ```$PLUGINSLIB``` is specified, they are fetched from there, otherwise 
if a directory named ```.plugins``` exists under the user's home directory
or under the current directory, the pragma loader will look there.

Each plugin has a backing script whose name must follow a simple 
convention: for plugin "foo" the script must be named ```_foo.sh```.

In order to start working:
1. export ```PLUGINSLIB```, or copy/create ```.plugins``` under your home
directory or under the current directory;
2. source ```pragma.sh``` into the current shell (```. ./pragma.sh```)
3. to create the stub of a new plugin "foo", use ```pragma stub foo```,
then proceed to editing the ```_foo.sh``` file in your plugin directory.

Enjoy!
