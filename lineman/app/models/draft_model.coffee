angular.module('loomioApp').factory 'DraftModel', (BaseModel, AppConfig) ->
  class DraftModel extends BaseModel
    @singular: 'draft'
    @plural: 'drafts'
    @uniqueIndices: ['id']
    @serializableAttributes: AppConfig.permittedParams.draft

    defaultValues: =>
      payload: {}
