client = require './client'
lecture = require './lecture'

class @Teacher extends client.Client
  constructor: (params, callback) ->
    super(params)
    @lecture = new lecture.Lecture(@pub)
    @confusion_value = 0
    @understanding_value = 0
    @num_students = 0
    @students_can_see_confusion = yes
    @init(callback)
      
  init: (callback) ->
    @subscribe(callback)
    @lecture.init_teacher(@id)
    setInterval @poll_confusion, 1000
    setInterval @poll_num_students, 990
    setInterval @poll_understanding, 1010

    setTimeout @send_conf_to_students, 500, 0
    setTimeout @send_und_to_students, 600, 0


  send_conf_to_students: (conf) =>
    if @students_can_see_confusion
      @pub.publish "#{@lecture.id}.broadcast.confusion", conf

  send_und_to_students: (und) =>
    if @students_can_see_confusion
      @pub.publish "#{@lecture.id}.broadcast.understanding", und

  poll_confusion: =>
    if @send_to_client_cb?
      new_confusion = @lecture.get_percent_confusion()
      #only send confusion value if it is actually
      #different
      if not (new_confusion is @confusion_value)
        @confusion_value = new_confusion
        @send_to_client_cb {c:@confusion_value}
        @send_conf_to_students @confusion_value

  poll_understanding: =>
    if @send_to_client_cb?
      new_understanding = @get_percent_understanding()
      if not (new_understanding is @understanding_value)
        @understanding_value = new_understanding
        @send_to_client_cb {u:@understanding_value}
        @send_und_to_students @understanding_value

  poll_num_students: =>
    if @send_to_client_cb?
      new_num_students = @lecture.get_num_students()
      if not (new_num_students is @num_students)
        @num_students = new_num_students
        @send_to_client_cb {n:@num_students}


  subscribe: (callback) ->
    @sub.on 'psubscribe', (p,c) =>
      callback(@)
    @sub.on 'pmessage', @handle_pmessage
    @sub.psubscribe "#{@id}.*"

  get_percent_confusion: ->
    @lecture.get_percent_confusion()
  
  get_percent_understanding: ->
    @lecture.get_percent_understanding()

  handle_lecture: (action,m) ->


    sub_actions =
      'add_confusion': (m) =>
        @lecture.add_confusion(JSON.parse(m))
      'add_understanding': (m) =>
        @lecture.add_understanding(JSON.parse(m))

      'get_id': (student_id) =>
        @pub.publish "#{student_id}.lecture.id", @lecture.id
        @pub.publish "#{student_id}.lecture.confusion_enabled", "#{@students_can_see_confusion}"
        @lecture.add_student(student_id)


    sub_actions[action]? and sub_actions[action](m)

  handle_pmessage: (pattern, channel, message) =>
    parts = channel.split('.')
    resource = parts[1] #lecture
    action = parts[2] #


    actions =
      'new_lecture': (m) =>
        @lecture.id = Number(m)
      'lecture': (m) =>
        @handle_lecture(action,m)
      'disconnect': (m) =>
        #@remove_student(m)
        @lecture.remove_student(m)

    actions[resource]? and actions[resource](message)

  handle_enable_confusion_from_socket: ->
    @students_can_see_confusion = yes
    @pub.publish "#{@lecture.id}.broadcast.enable_confusion",''

  handle_disable_confusion_from_socket: ->
    @students_can_see_confusion = no
    @pub.publish  "#{@lecture.id}.broadcast.disable_confusion",''

  handle_message_from_socket: (message) ->
    console.log message

  get_lecture_id: ->
    @lecture.id

  get_num_students: ->
    @lecture.get_num_students()

