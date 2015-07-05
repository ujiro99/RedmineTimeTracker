timeTracker.factory "BaseEditState", ($window, Message, Resource, DataAdapter) ->

  ###
   base state.
  ###
  class BaseEditState

    @STATUS_CANCEL : 0
    @SHOW: { DEFAULT: 0, NOT: 1, SHOW: 2 }

    currentPage: 1

    ###
     check item was contained in selectableTickets.
    ###
    isContained: (item) ->
      return DataAdapter.tickets.some (e) -> item.equals e


    ###
     on user selected item.
    ###
    onClickItem: (item) ->
      if @isContained(item)
        @removeItem(item)
      else
        @addItem(item)


    ###
     add selected item.
    ###
    addItem: (item) ->
      item.show = BaseEditState.SHOW.SHOW
      DataAdapter.addTicket item
      Message.toast Resource.string("msgAdded").format(item.text)


    ###
     remove selected item.
    ###
    removeItem: (item) ->
      item.show = BaseEditState.SHOW.NOT
      DataAdapter.removeTicket item


    ###
     filter issues by searchField.text.
    ###
    listFilter: (item) =>
      if @$scope.searchField.text.isBlank() then return true
      return (item.id + "").contains(@$scope.searchField.text) or
             item.text.toLowerCase().contains(@$scope.searchField.text.toLowerCase())


    ###
     load data.
    ###
    load: (page) ->


    ###
     open link on other window.
    ###
    openLink: (url) ->
      a = document.createElement('a')
      a.href = url
      a.target='_blank'
      a.click()


    ###
     calculate tooltip position.
    ###
    onMouseMove: (e) =>
      if e.clientY > $window.innerHeight / 2
        @$scope.tooltipPlace = 'top'
      else
        @$scope.tooltipPlace = 'bottom'


  return BaseEditState
