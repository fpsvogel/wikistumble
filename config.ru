require_relative "config/boot"

run -> (env) { Router.call(env) }
