furbot
======

Furbot - A simple cinch-based IRC bot that no one but me would use.

Cinch is awesome. But since it's more of a framework than a full on
bot, this is a basic implementation. As of right now it requires a
bunch of plugins you'll have to install by hand. I'm working on
that.

* furbot.rb - The actual bot implementation
* furbot_config.rb.DIST - An example config file
* furbot_control.rb - Simple ruby daemon controller to launch furbot
* plugins - local plugins that aren't gems


I stole plugins from davidcelis' snap bot cause they already worked. Check out snap:
https://github.com/davidcelis/snap
