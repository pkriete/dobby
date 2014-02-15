# Dobby

A houself for everyday development tasks.

He can start and stop processes:

    dobby start apache
    dobby start mysql
    dobby restart jekyll

He remembers where your configuration files are:

    dobby edit apache

And he knows what's running at any given time:

    dobby status

This is not meant as a replacement for something heavy like fabric. It provides
only the bare essentials. Starting, stopping, restarting, and configuring.

## Getting Started

Clone the Dobby repo to the location of your choice, then alias dobby.rb as dobby:

    alias dobby=`ruby /path/to/dobby/dobby.rb`

Alternatively you can simply source the Dobby autocomplete script. This will set
you up with the alias and some basic autocompletion (bash only):

    source '/path/to/dobby/etc/dobby-prompt.sh'

## Creating a configuration file

Dobby uses plain ruby as its configuration language. The default path for the
dobby config file is `~/.dobby_config`.

Create this file and as a test add the following configuration:

    config :git do |c|
      c.name = "Gitconfig"
      c.file = "~/.gitconfig"
    end

This makes Dobby aware of your git config file. In your terminal you should now
be able to open your `~/.gitconfig` file with:

    dobby edit git

Let's also add a server. In this case, we will try Jekyll:

    service :jekyll do |s|
      s.name = "Jekyll"
      s.start = "jekyll --auto --server"
      s.process = 'jekyll'
    end

Giving your configuration a start command and a process name (or stop command)
tells Dobby how it can start and stop this service. Let's try that. Jekyll
does not start as a daemon, so we will need two terminal windows:

    dobby start jekyll

In the second terminal window, try some of these:

    dobby status
    dobby restart jekyll
    dobby stop jekyll

Congrats! You have an elf.

## Todo

Documentation is a work in progress. For more complex tasks, please check back later.

For now, here's a full apache example. I will leave you to figure it out:

    service :apache do |s|
      s.name = "Apache"
      s.file = "/private/etc/apache2/httpd.conf"

      s.start   = "apachectl start"
      s.stop    = "apachectl stop"
      s.restart = "apachectl restart"

      s.process = "httpd"
      s.needs_root = true
    end

    config :php => :apache do |c|
      c.name  = "PHP"
      c.file  = "/usr/local/etc/php/5.4/php.ini"
    end

Direct dependencies (as seen here as :php => :apache) will force
the parent process to restart when a dependent child is edited.

## License

Dobby is released under the MIT license:

* http://www.opensource.org/licenses/MIT