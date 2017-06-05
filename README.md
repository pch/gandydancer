# Gandy Dancer

[Gandy Dancer](https://en.wikipedia.org/wiki/Gandy_dancer) is a Ruby on Rails
application template with the defaults & boilerplate I use for my personal
projects.

# Installation

Check out gandydancer:

~~~ shell
$ git clone https://github.com/pch/gandydancer.git ~/Code/gandydancer
~~~

Add `~/Code/gandydancer/bin` (or whatever path you cloned into) to your `$PATH`
for access to the gandydancer command-line utility.

~~~ shell
$ echo 'export PATH="$PATH:$HOME/Code/gandydancer/bin"' >> ~/.bash_profile
~~~

# Usage

Generate a new Rails app using:

~~~ shell
$ gandydancer your-new-app
$ SKIP_AUTH=true gandydancer your-new-app    # skips auth-related boilerplate
$ SKIP_SIDEKIQ=true gandydancer your-new-app # skips sidekiq config
~~~

# Credits

Big part of this template is based on [Suspenders][suspenders] by [thoughtbot][thoughtbot].

[suspenders]: https://github.com/thoughtbot/suspenders
[thoughtbot]: http://thoughtbot.com
