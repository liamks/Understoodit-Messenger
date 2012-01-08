redis = require 'redis'

class @Client
  constructor: (params) ->
    @sub = redis.createClient()
    @pub = redis.createClient()
    @id = params.id
    @screen_name = params.screen_name

  disconnect: ->
    @sub.punsubscribe()
    @sub.unsubscribe()
    @sub.end()
    @pub.end()
    
  add_send_to_client: (send_to_client_cb) ->
    @send_to_client_cb = send_to_client_cb

  send_to_client: (message) ->
    @send_to_client_cb message
    
  get_pub: ->
    @pub

  get_sub: ->
    @sub