should = require 'should'
t = require '../teacher'
s = require '../student'
l = require '../lecture'

teacher1 =
  id: '234sf9i'
  screen_name: 'Susan'

student1 =
  id: '234asdf'
  screen_name: 'Tom'
  teacher: teacher1

student2 =
  id: '234asdfi'
  screen_name: 'Sara'
  teacher: teacher1

confusion1 =
  id : student1.id
  time : (new Date()).getTime()
understanding1 =
  id : student1.id
  time : (new Date()).getTime()

confusion_without_time =
  id: student1.id

make_lecture = ->
  lecture = new l.Lecture(null)
  lecture.init_teacher(teacher1.id)
  lecture

describe 'Lecture', ->
  it 'Must a lecture id', (done) ->
    lecture = make_lecture()
    lecture.get_lecture_id().should.be.a('number')
    done()

  it 'Must have 0 students', (done) ->
    lecture = make_lecture()
    lecture.get_num_students().should.equal 0
    done()

  it 'Must have 1 student', (done) ->
    lecture = make_lecture()
    lecture.add_student student1.id
    lecture.get_num_students().should.equal 1
    done()

  it 'Must have 2 students', (done) ->
    lecture = make_lecture()
    lecture.add_student student1.id    
    lecture.add_student student2.id  
    lecture.get_num_students().should.equal 2
    done()

   it 'Must have 1 student after 1 disconnects', (done) ->
    lecture = make_lecture()
    lecture.add_student student1.id    
    lecture.add_student student2.id  
    lecture.remove_student(student1.id).should.be.true
    lecture.get_num_students().should.equal 1
    done()

  it 'Must return false if attempt is made to remove student that is not in lecture', (done) ->
    lecture = make_lecture()
    lecture.add_student student1.id 
    lecture.remove_student('asdfasdf').should.be.false
    done()
  
   it 'Must have a confusion near 100%', (done) ->
    lecture = make_lecture()
    lecture.add_student student1.id
    lecture.add_confusion(confusion1).should.be.true
    lecture.get_percent_confusion().should.be.within 98,100
    done()   
  
  it 'Must have an understanding near 100%', (done) ->
    lecture = make_lecture()
    lecture.add_student student1.id
    lecture.add_understanding(understanding1).should.be.true
    lecture.get_percent_understanding().should.be.within 98,100
    done()   

  it 'Must return false if attempt is made to add confusion without a time', (done) ->
    lecture = make_lecture()
    lecture.add_student student1.id
    lecture.add_confusion(confusion_without_time).should.be.false
    done()

  it 'Must have an n=2 for 1 student id', (done) ->
    lecture = make_lecture()
    lecture.add_student student1.id
    lecture.add_student student1.id
    lecture.get_num_students().should.equal 1
    lecture.students[student1.id].n.should.equal 2
    done()

  it 'Must have an n =0 after both students log off', (done) ->
    lecture = make_lecture()
    lecture.add_student student1.id
    lecture.add_student student1.id
    lecture.remove_student student1.id
    lecture.students[student1.id].n.should.equal 1
    lecture.remove_student student1.id
    lecture.get_num_students().should.equal 0
    done()

  it 'Must have 100% confusion in non-decay mode', (done) ->
    lecture = make_lecture()
    lecture.add_student student1.id
    lecture.set_decay_mode false
    lecture.add_confusion(confusion1)

    must_still_be_hundred = () ->
      lecture.get_percent_confusion().should.equal 100
      done()

    setTimeout must_still_be_hundred, 1050
  