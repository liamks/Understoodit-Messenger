client = require './client'

class @Student extends client.Client
  constructor: (params, callback) ->
    super(params)
    @teacher_id = params.teacher.id
    @teacher_screen_name = params.teacher.screen_name
    
    @lecture_id = null
    @init(callback)

  init: (callback) ->
    @subscribe(callback)
    @fetch_lecture_id()

  subscribe: (callback) ->
    @sub.on 'message', @handle_message
    @sub.subscribe "#{@teacher_id}.new_lecture"

    @sub.on 'psubscribe', (p,c) =>
      if p is "#{@id}.*"
        callback(@)
    @sub.on 'pmessage', @handle_pmessage
    @sub.psubscribe "#{@id}.*"
   


  send_confusion_to_student: (conf) ->
    if @send_to_client_cb?
      @send_to_client_cb {c: conf}

  send_understanding_to_student: (und) ->
    if @send_to_client_cb?
      @send_to_client_cb {u: und}
      
  send_enable_confusion_to_student: ->
    if @send_to_client_cb?
      @send_to_client_cb {ec:''}

  send_disable_confusion_to_student: ->
    if @send_to_client_cb?
      @send_to_client_cb {dc:''}

  handle_message: (channel, message) =>
    parts = channel.split('.')
    resource = parts[1]
    action = parts[2]

    actions =
      'new_lecture': (m) =>
        @fetch_lecture_id()

    actions[resource] and actions[resource](message)

  handle_pmessage: (pattern, channel, message) =>
    parts = channel.split('.')
    resource = parts[1]
    action = parts[2]

    actions =
      'lecture': (m) =>
        if action is 'id'
          @lecture_id = Number(m)
          @sub.psubscribe "#{@lecture_id}.broadcast.*"
        else if action is 'confusion_enabled'
          if m is 'true'
            @send_enable_confusion_to_student()
          else
            @send_disable_confusion_to_student()

      'broadcast': (m) =>
        if action is 'confusion'
          @send_confusion_to_student m

        else if action is 'understanding'
          @send_understanding_to_student m

        else if action is 'enable_confusion'
          @send_enable_confusion_to_student()

        else if action is 'disable_confusion'
          @send_disable_confusion_to_student()

    actions[resource] and actions[resource](message)

  add_understanding: (time) ->
    if @lecture_id? 
      @pub.publish "#{@teacher_id}.lecture.add_understanding",
        JSON.stringify({'id':@id, 'time':time, 'lecture_id': @lecture_id})

  
  add_confusion: (time) ->
    if @lecture_id?
      @pub.publish "#{@teacher_id}.lecture.add_confusion",
        JSON.stringify({'id':@id, 'time':time, 'lecture_id': @lecture_id})


  fetch_lecture_id: () ->
    @pub.publish "#{@teacher_id}.lecture.get_id", @id
  
  disconnect: ->
    @pub.publish "#{@teacher_id}.disconnect", @id
    super()

  get_lecture_id: ->
    @lecture_id

  handle_confusion_from_socket: (m) =>
    if m.time?
      @add_confusion(m.time)
      true
    else
      false

  handle_understanding_from_socket: (m) =>
    if m.time?
      @add_understanding(m.time)
      true
    else
      false
  
