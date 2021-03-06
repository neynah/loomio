angular.module('loomioApp').factory 'BootService', ($location, Records, IntercomService, MessageChannelService, ModalService, GroupForm) ->
  new class BootService

    boot: ->
      IntercomService.boot()
      MessageChannelService.subscribeToUser()
      if $location.search().start_group?
        ModalService.open GroupForm, group: -> Records.groups.build()
