angular.module('loomioApp').factory 'DraftRecordsInterface', (BaseRecordsInterface, DraftModel) ->
  class DraftRecordsInterface extends BaseRecordsInterface
    model: DraftModel

    findOrBuildFor: (model) ->
      _.first(@find(draftableType: model.constructor.singular, draftableId: model.id)) or
      @build(draftableType: model.constructor.singular, draftableId: model.id)

    fetchFor: (model) ->
      @fetch
        params:
          draftable_type: model.constructor.singular
          draftable_id: model.id
