#mocha -R spec

class @Lecture
  constructor: (@pub) ->
    
  init_teacher: (teacher_id) ->
    @teacher_id = teacher_id
    @generate_lecture_id()
    @students = {}
    @student_ids = []
    # 3 minutes
    @CONFUSION_HALF_LIFE = 1000 * 60 * 3
    # 4 minutes
    @confusion_timeout = 1000 * 60 * 4
    @decay_mode = yes

  init_student: (teacher_id, @student_id) ->

  generate_lecture_id: ->
    @id = (new Date()).getTime()
    if @pub?
      @pub.publish "#{@teacher_id}.new_lecture", @id

  get_lecture_id: ->
    @id

  
  add_student: (id) ->
    if not @students[id]?
      @student_ids.push(id)
      @students[id] =
        understanding : 0
        understanding_t : 0
        confusion : 0
        confusion_t : 0
        n: 1
    else if @students[id]?
      @students[id].n += 1

  remove_student: (id) ->
    if @students[id]?
      if @students[id].n is 1
        #only one student with id is connected
        index = @student_ids.indexOf(id)
        @student_ids.splice(index,1)
        delete @students[id]
      else
        @students[id].n -= 1
      true
    else
      false

  add_understanding: (m) ->
    if @students[m.id]? and m.time?
      @students[m.id].understanding = 1
      @students[m.id].confusion = 0
      @students[m.id].understanding_t = Number(m.time) || 0
      true
    else
      false

  add_confusion: (m) ->
    if @students[m.id]? and m.time?
      @students[m.id].confusion = 1
      @students[m.id].understanding = 0
      @students[m.id].confusion_t = Number(m.time) || 0
      true
    else
      false

  reset_understanding_and_confusion: ->
    for id in @student_ids
      @students[id].confusion = 0
      @students[id].understanding = 0

  get_num_students: ->
    @student_ids.length

  decay_function: (value, time_delta) ->
    if @decay_mode
      return 0 if time_delta > (@CONFUSION_HALF_LIFE * 2)
      value * (1 / (Math.pow(2,(time_delta/@CONFUSION_HALF_LIFE))))
    else
      if (time_delta > @confusion_timeout) then 0 else value

  decay: (student_id,conf) ->
    id = student_id
    current_time = (new Date()).getTime()
    if conf
      #confusion
      confusion_delta = current_time - @students[id].confusion_t
      @students[id].confusion = @decay_function(@students[id].confusion, confusion_delta)
    else
      #understanding
      understanding_delta = current_time - @students[id].understanding_t
      @students[id].understanding = @decay_function(@students[id].understanding, understanding_delta)
      
  get_percent_confusion: ->
    n = @get_num_students()
    if n is 0
      0
    else
      sum = 0
      for id in @student_ids
        @decay(id,yes)
        sum += @students[id].confusion
      Math.floor (sum/n) * 100

  get_percent_understanding: ->
    n = @get_num_students()
    if n is 0
      0
    else
      sum = 0
      for id in @student_ids
        @decay(id,no)
        sum += @students[id].understanding
      Math.floor (sum/n) * 100

  set_decay_mode: (mode) ->
    @decay_mode = mode

  set_confusion_timeout: (num) ->
    if typeof num is 'number'
      @confusion_timeout = num

  get_confusion_timeout: ->
    @confusion_timeout
    
  