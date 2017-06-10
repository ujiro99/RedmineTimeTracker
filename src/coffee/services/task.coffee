timeTracker.factory("Task", (EventDispatcher) ->

  ###*
   Task data model.
   @class TaskModel
  ###
  class TaskModel extends EventDispatcher

    ###*
     @constructor
     @param {Number} id - ID of this task.
     @param {String} text - Task name.
     @param {String} url - Url of this task's web service.
     @param {Number} projectId - Project ID of this task.
     @param {Number} total - Total spent time.
     @param {Number} type - Task type.
    ###
    constructor: (id, @text, @url, @projectId, @total, @type) ->
      @id = id - 0


    ###*
     Compare object.
     @param {TaskModel} y - Object which will be compared.
     @return {Bool} true: same / false: different
    ###
    equals: (y) ->
      return false if not y?
      return @url is y.url and @id is y.id and @type is y.type


    ###*
     Generate unique string according to properties.
     This method is used for Array.xor | Array.union.
     @return {String} Generated hash value.
    ###
    hash: () -> return @url + @type + @id


  return TaskModel

)
