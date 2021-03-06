angular.module('loomioApp').factory 'PrivacyString', ($translate) ->
  new class PrivacyString
    groupPrivacyStatement: (group) ->
      if group.isSubgroup() && group.parent().privacyIsSecret()
        if group.privacyIsClosed()
          $translate.instant('group_form.privacy_statement.private_to_parent_members',
                             {parent: group.parentName()})
        else
          $translate.instant("group_form.privacy_statement.private_to_group")
      else
        key = switch group.groupPrivacy
              when 'open' then 'public_on_web'
              when 'closed' then 'public_on_web'
              when 'secret' then 'private_to_group'
        $translate.instant("group_form.privacy_statement.#{key}")

    confirmGroupPrivacyChange: (group) ->
      key = if group.attributeIsModified('groupPrivacy')
        if group.privacyIsSecret()
          if group.isParent()
            'group_form.confirm_change_to_secret'
          else
            'group_form.confirm_change_to_secret_subgroup'
        else if group.privacyIsOpen()
          'group_form.confirm_change_to_public'
      else if group.attributeIsModified('discussionPrivacyOptions')
        if group.discussionPrivacyOptions == 'private_only'
          'group_form.confirm_change_to_private_discussions_only'

      if _.isString(key)
        $translate.instant(key)
      else
        false

    discussion: (discussion, is_private = null) ->
      key = if is_private == false
        'privacy_public'
      else if discussion.group().parentMembersCanSeeDiscussions
        'privacy_organisation'
      else
        'privacy_private'

      $translate.instant("discussion_form.#{key}", group: discussion.group().name, parent: discussion.group().parentName())

    group: (group, state = null) ->
      if state == null
        state = group.groupPrivacy

      key = if group.isParent()
        switch state
          when 'open'   then 'group_privacy_open_description'
          when 'secret' then 'group_privacy_secret_description'
          when 'closed'
            if group.allowPublicDiscussions()
              'group_privacy_closed_public_threads_description'
            else
              'group_privacy_closed_description'
      else
        switch state
          when 'open'   then 'subgroup_privacy_open_description'
          when 'secret' then 'subgroup_privacy_secret_description'
          when 'closed'
            if group.allowPublicDiscussions()
              'subgroup_privacy_closed_public_threads_description'
            else if group.isSubgroupOfHiddenParent
              'subgroup_privacy_closed_secret_parent_description'
            else
              'subgroup_privacy_closed_description'

      $translate.instant("group_form.#{key}", parent: group.parentName())
