wright
======
[![Gem Version](https://img.shields.io/gem/v/wright.svg?style=flat-square)][gem]
[![Build Status](https://img.shields.io/travis/sometimesfood/wright.svg?style=flat-square)][travis]
[![Code Climate](https://img.shields.io/codeclimate/github/sometimesfood/wright.svg?style=flat-square)][codeclimate]
[![Test Coverage](https://img.shields.io/codeclimate/coverage/github/sometimesfood/wright.svg?style=flat-square)][codeclimate]
[![Gem Dependencies](https://img.shields.io/gemnasium/sometimesfood/wright.svg?style=flat-square)][gemnasium]

[gem]: https://rubygems.org/gems/wright
[travis]: https://travis-ci.org/sometimesfood/wright
[codeclimate]: https://codeclimate.com/github/sometimesfood/wright
[gemnasium]: https://gemnasium.com/sometimesfood/wright

Lightweight configuration management.

Getting Started
---------------
Performing simple administrative tasks with wright is easy.

```ruby
#!/usr/bin/env wright

package 'sudo'

file '/etc/sudoers.d/env_keep-editor' do |f|
  f.content = "Defaults env_keep += EDITOR\n"
  f.owner   = 'root:root'
  f.mode    = '440'
end
```

Scripts can also be run directly from the shell.

    wright -e "package('tmux')"

If you would rather see the effects of running a wright script first,
use the dry-run option:

    wright --dry-run -e "package('tmux')"

For a list of command-line parameters, see
[the manpage](man/wright.1.txt). For a more in-depth list of tasks you
can perform using wright, check the
[resource list](doc/resources.txt).

Installation
------------
Since wright does not have any runtime dependencies apart from Ruby
≥1.9, it can safely be installed system-wide via rubygems:

    sudo gem install wright

Installation on Debian-based systems
------------------------------------
If you use a Debian-based GNU/Linux distribution such as Ubuntu, you
can also install wright via the PPA [sometimesfood/wright][ppa]:

    sudo apt-get install software-properties-common
    sudo add-apt-repository -y ppa:sometimesfood/wright
    sudo apt-get update && sudo apt-get install wright

If you use a Debian-based distribution that is not Ubuntu, you have to
update your apt sources manually before installing wright:

    export DISTRO="$(lsb_release -sc)"
    export PPA_LIST="sometimesfood-wright-${DISTRO}.list"
    sudo sed -i "s/${DISTRO}/trusty/g" /etc/apt/sources.list.d/${PPA_LIST}

[ppa]: http://launchpad.net/~sometimesfood/+archive/ubuntu/wright

Documentation
-------------
As a wright user, the following documents are probably going to be of
interest to you:

- [wright manpage](man/wright.1.txt)
- [list of wright resources](doc/resources.txt)
- [wright is just Ruby](doc/wright-is-ruby.txt)

As a wright developer, you might also be interested in the
[wright developer docs](http://www.rubydoc.info/gems/wright/) which
can also be generated via `bundle exec yard`.

Contributing
------------
Contributions to wright are greatly appreciated. If you would like to
contribute to wright, please have a look at the
[contribution guidelines](CONTRIBUTING.md).

To start hacking on wright, simply install the development
dependencies via bundler:

 - `bundle install --path .bundle`
 - `bundle exec rake test`

All tests should pass.

Copyright
---------
Copyright (c) 2012-2015 Sebastian Boehm. See [LICENSE](LICENSE) for
details.
