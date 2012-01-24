#should = require './client-socket'

WebSocket = require('websocket-client').WebSocket;
io = require '../lib/client-socket.io' 

teacher1 =
  "socket":"http://0.0.0.0:3001"
  "id":1
  "screen_name":"liam"
  "token_1":"67c68104dae86144f5d1b8a1a6bec1e25f3057fa8acb00135852bb45b56684f4"
  "token_2":"f94850a91d4bbb4de689693815b98c4bacec58ee5c7cd6ea38fe3d6d059c160c"
  "options":
    "confusion_timeout":60000
    "enable_decay":false
    "students_can_see_confusion":true
    "enable_notifications":true
    "confusion_threshold":40
    "understanding_threshold":45


describe 'Client Teacher', ->
  it 'asdf', (done) ->
    socket = io.connect teacher1.socket

    console.log socket
    socket.on 'connect', (d) =>
      socket.emit 'start', teacher1
      done()


###
describe 'Client Teacher', ->
  it 'asdf', (done) ->

    cl = client(port)

    cl.handshake (sid) ->
      ws = websocket cl, sid

      ws.on 'data', (data) ->
        console.log data
        

      ws.onmessage = (data) ->
        console.log data
        done()
      event = {'name':'start','args':[{}]}
      ws.send '5:1::' + JSON.stringify(event) 
      
        
###
   