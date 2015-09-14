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
      if not @isContained(item)
        Message.toast Resource.string("msgAdded").format(item.text)
      DataAdapter.toggleIsTicketShow item


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
