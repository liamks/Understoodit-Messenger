should = require 'should'
t = require '../teacher'
s = require '../student'

teacher1 =
  id: '234sf9i'
  screen_name: 'Susan'
  options:
    enable_decay: false
    students_can_see_confusion: true

teacher2 =
  id: '234sf9i'
  screen_name: 'Sally'
  options:
    enable_decay: false
    students_can_see_confusion: true
    
student1 =
  id: '234asdf'
  screen_name: 'Tom'
  teacher: teacher1

describe 'Teacher', ->
  it 'Must have a lecture id',(done) ->
    new t.Teacher teacher1, (t1) ->
      t1.get_lecture_id().should.be.a('number')
      t1.disconnect()
      done()

  it 'Must have the same lecture id', (done) ->
    new t.Teacher teacher1, (t1) ->
        new t.Teacher teacher2, (t2) ->
          should_be_same = ->
            t1_lecture_id = t1.get_lecture_id()
            t2_lecture_id = t2.get_lecture_id()
            t1_lecture_id.should.equal(t2_lecture_id)
            t1.disconnect()
            t2.disconnect()
            done()
          #give pub/sub some time
          setTimeout should_be_same, 10

describe 'Teacher Connects Second', ->
  it 'Must have the same lecture id', (done) ->
    new s.Student student1, (s1) ->
      new t.Teacher teacher1, (t1) ->      
        should_be_same = ->
          s1_lecture_id = s1.get_lecture_id()
          t1_lecture_id = t1.get_lecture_id()
          t1_lecture_id.should.equal(s1_lecture_id)
          s1.disconnect()
          t1.disconnect()
          done()

        setTimeout should_be_same, 10

