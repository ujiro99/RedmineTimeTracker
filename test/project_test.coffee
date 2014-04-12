expect = chai.expect

describe 'project.coffee', ->

  Project = null

  beforeEach () ->
    angular.mock.module('timeTracker')
    inject (_Project_) ->
      Project = _Project_   # underscores are a trick for resolving references.

  it 'shoud have working Project service', () ->
    expect(Project.add).not.to.equal null



