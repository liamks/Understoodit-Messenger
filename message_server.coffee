http = require 'http'
io = require 'socket.io'
crypto = require 'crypto'

student = require './student'
teacher = require './teacher'


t1 = 'df3e6b0bb66ceaadca4f84cbc371fd66e04d20fe51fc414da8d1b84d31d178de'
secret = 'd8cc7aed3851ac3338fcc15df3b6807b89125837f77a75b9ecb13ed2afe3b49f'
ans = 'a4a28cd4d16d591fd70a71fa269bd6963f0059b3ca90f7caf91bbbb2b414e837'

class SocketClient
  constructor: (@socket) ->
    
    @socket.on 'start', @start
    @socket.on 'u', @understanding_from_client
    @socket.on 'c', @confusion_from_client
    @socket.on 'disconnect', @disconnect

  valid_tokens: (data) ->
    empty_tokens = (data.token is '') and (data.token is '')
    client_has_token = data.token_1? and data.token_2?
    return unless client_has_token and not empty_tokens

    crypto.createHash('sha256').update(data.token_1 + secret).digest('hex') is data.token_2

  start: (data) =>
    
    return unless data.id? and data.screen_name?

    if data.teacher?
      return unless data.teacher.id? and data.teacher.screen_name?
      
      new student.Student data, (c) =>
        @client = c
        @client.add_send_to_client @send_to_client
    else

      unless @valid_tokens data
        @socket.disconnect()
        return

      new teacher.Teacher data, (c) =>
        @socket.on 'ec', @enable_confusion
        @socket.on 'dc', @disable_confusion
        @socket.on 'rs', @reset_confusion_and_understanding

        @socket.on 'dmt', @decay_mode_true
        @socket.on 'dmf', @decay_mode_false

        @socket.on 'cto', (c) =>
          @decay_mode_timeout c

        @socket.on 'options', (opt) =>
          @handle_options opt

        @client = c
        @client.add_send_to_client @send_to_client


  send_to_client: (message) =>
    @socket.emit 'm', message

  reset_confusion_and_understanding: =>
    @client.handle_confusion_and_understanding_reset_from_socket() if @client?

  enable_confusion: () =>
    @client.handle_enable_confusion_from_socket() if @client?

  disable_confusion: () =>
    @client.handle_disable_confusion_from_socket() if @client?

  understanding_from_client: (data) =>
    data.time = (new Date()).getTime()
    @client.handle_understanding_from_socket data if @client?

  confusion_from_client: (data) =>
    data.time = (new Date()).getTime()
    @client.handle_confusion_from_socket data if @client?

  decay_mode_true: () =>
    @client.handle_decay_mode_true_from_socket() if @client?

  decay_mode_false: () =>
    @client.handle_decay_mode_false_from_socket() if @client?

  decay_mode_timeout: (t) =>
    @client.handle_new_confusion_timeout_from_socket(t) if @client?

  handle_options: (options) =>
    @client.handle_options_from_socket(options) if @client?

  disconnect: =>
    @client.disconnect() if @client?
      

class Server
  constructor: (@port) ->
    @app = http.createServer @handler
    @io = io.listen @app

    @io.configure 'production', () =>
      @io.set 'log level', 1
      @io.enable 'browser client minification'
      @io.enable 'browser client gzip'
      @io.enable 'browser client etag'

    @io.configure 'development', () =>
      @io.set 'log level', 1


  start: ->
    @app.listen @port
    @io.sockets.on 'connection', @connection
  
  handler: (req, res) ->

  connection: (socket) ->
    console.log 'HERERERERERERERE'
    new SocketClient socket


server = new Server(3001)
server.start()
