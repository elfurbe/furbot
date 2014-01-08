#!/usr/bin/env ruby
require 'rubygems'
require 'daemons'

options = {
    :backtrace => true,
    :log_output => true,
    :monitor => true
}
Daemons.run('furbot.rb',options)
