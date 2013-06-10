# copyright 2013 wiz technologies inc.

require '..'
require './database'
require './server'

wiz.package 'wiz.framework.frontend.stateless'

# node frameworks
coffee = require 'coffee-script'
cluster = require 'cluster'
http = require 'http'
jade = require 'jade'
fs = require 'fs'
os = require 'os'

# server config object
class wiz.framework.frontend.stateless.config extends wiz.framework.frontend.config

# main server class
class wiz.framework.frontend.stateless.server extends wiz.framework.frontend.server

# vim: foldmethod=marker wrap
