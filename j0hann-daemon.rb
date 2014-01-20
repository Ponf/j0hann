require 'daemons'

options = {
    :multiple   => false,
    :backtrace  => true,
    :monitor    => true,
    :log_output => true
}

Daemons.run('j0hann.rb', options)
