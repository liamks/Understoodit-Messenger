should = require 'should'
t = require '../teacher'
s = require '../student'

teacher1 =
  id: '234sf9i'
  screen_name: 'Susan'
  options:
    enable_decay: false
    students_can_see_confusion: true

student1 =
  id: '234asdf'
  screen_name: 'Tom'
  teacher: teacher1

student2 =
  id: '234asdfi'
  screen_name: 'Sara'
  teacher: teacher1

disconnect_two = (c1,c2) ->
  c1.disconnect()
  c2.disconnect()

disconnect_three = (c1,c2,c3) ->
  disconnect_two(c1,c2)
  c3.disconnect()


one_teacher_one_student =(time, func) ->
  new t.Teacher teacher1, (t1) ->
    new s.Student student1, (s1) ->
      setTimeout func, time,  t1, s1

one_teacher_two_students = (time, func) ->
  new t.Teacher teacher1, (t1) ->
    new s.Student student1, (s1) ->
      new s.Student student2, (s2) ->
        setTimeout func, time,  t1, s1, s2

describe 'Student', ->


  it 'Must have no lecture id', (done) ->
    new s.Student student1, (s1) ->
      should.not.exist(s1.get_lecture_id())
      s1.disconnect()
      done()

  it 'Must have a lecture id', (done) ->
    should_be_same = (t1, s1) ->
      t1_lecture_id = t1.get_lecture_id()
      s1_lecture_id = s1.get_lecture_id()
      t1_lecture_id.should.equal(s1_lecture_id)
      disconnect_two t1, s1
      done()

    one_teacher_one_student 10, should_be_same


  it 'Must be nearly 100% confused', (done) ->
    add_confusion = (t1, s1) ->
      s1.add_confusion((new Date()).getTime())
      setTimeout get_confusions, 5, t1, s1

    get_confusions = (t1, s1) ->
      confusion = t1.get_percent_confusion()
      confusion.should.be.within 96, 100
      disconnect_two t1, s1
      done()
    
    one_teacher_one_student 10, add_confusion

  it 'Must be nearly 100% understanding',(done) ->
    add_understanding = (t1,s1) ->
      s1.add_understanding (new Date()).getTime()
      setTimeout get_understanding, 5, t1, s1

    get_understanding = (t1, s1) ->
      understanding = t1.get_percent_understanding()
      understanding.should.be.within 96, 100
      disconnect_two t1, s1
      done()

    one_teacher_one_student 10, add_understanding


  it 'Must handle properly formatted confusion from socket', (done) ->
    handle_from_socket = (t1, s1) ->
      value = s1.handle_confusion_from_socket({time:(new Date()).getTime()})
      value.should.be.true
      disconnect_two t1, s1
      done()

    one_teacher_one_student 0, handle_from_socket


  it 'Must return false with not properly formatted confusion from socket', (done) ->
    handle_from_socket = (t1, s1) ->
      value = s1.handle_confusion_from_socket((new Date()).getTime())
      value.should.be.false
      disconnect_two t1, s1
      done()

    one_teacher_one_student 0, handle_from_socket

describe 'Lecture With Two Students', ->
  it 'Must have 2 connected students',(done) ->
    one_teacher_two_students 5, (t1,s1,s2) ->
      t1.get_num_students().should.equal 2
      disconnect_three t1, s1, s2
      done()
  

  it 'Must be nearly 50% confused',(done) ->
    one_teacher_two_students 5, (t1,s1,s2) ->
      get_confusions = ->
        confusion = t1.get_percent_confusion()
        confusion.should.be.within 45, 50
        disconnect_three t1, s1, s2
        done()


      s1.add_confusion((new Date()).getTime())
      setTimeout get_confusions, 10


describe 'Lecture', ->
  it 'Must have zero connected', (done) ->
    new t.Teacher teacher1, (t1) ->
      t1.get_percent_confusion().should.equal 0
      t1.disconnect()
      done()

  it 'Must have 0% confusion', (done) ->
    new t.Teacher teacher1, (t1) ->
      t1.get_num_students().should.equal(0)
      t1.disconnect()
      done()

  it 'Must have 1 connected', (done) ->
     new t.Teacher teacher1, (t1) ->
      new s.Student student1, (s1) ->
        
        should_be_one = ->
          t1.get_num_students().should.equal(1)
          disconnect_two t1, s1
          done()

        setTimeout should_be_one, 10

  it 'Must Disconnect', (done) ->
    new t.Teacher teacher1, (t1) ->
      new s.Student student1, (s1) ->
        disconnect = ->
          t1.get_num_students().should.equal(1)
          s1.disconnect()
          setTimeout should_be_zero, 10

        should_be_zero = ->  
          t1.get_num_students().should.equal(0)
          t1.disconnect()
          done()

        setTimeout disconnect, 10