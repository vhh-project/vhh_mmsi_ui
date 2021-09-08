module.exports =
  ca_occurrences:
    event_publication:
      icon: 'calendar'
      label: 'label.event_publication'
      preferredLabelKeys: [ 'name' ]
      createAttrs: [
        'preferredLabelName'
        'eventName'
        'dateEvent'
      ]
      groups: [
        {
          label: 'tab.summary'
          tab: 'summary'
          type: 'summary'
        }
        {
          label: 'tab.basic'
          tab: 'basic'
          type: 'data'
          attrGroups: [
            'idno'
            'preferredLabelName'
            'eventName'
            'externalId'
            'dateEvent'
            'publicationTypeEvent'
            'accessStatus'
            'description'
            'url'
            'note'
          ]
        }
        {
          label: 'tab.relations'
          tab: 'relations'
          type: 'relations'
          attrGroups: [
            'relatedObjects'
            'relatedEntities'
            'relatedEvents'
            'relatedPlaces'
            'relatedCollections'
          ]
        }
      ]
    event_decision:
      icon: 'calendar'
      label: 'label.event_decision'
      preferredLabelKeys: [ 'name' ]
      createAttrs: [
        'preferredLabelName'
        'dateEvent'
      ]
      groups: [
        {
          label: 'tab.summary'
          tab: 'summary'
          type: 'summary'
        }
        {
          label: 'tab.basic'
          tab: 'basic'
          type: 'data'
          attrGroups: [
            'idno'
            'preferredLabelName'
            'externalId'
            'dateEvent'
            'decisionType'
            'regionalScope'
            'certificateNumber'
            'verdict'
            'description'
            'url'
            'note'
          ]
        }
        {
          label: 'tab.relations'
          tab: 'relations'
          type: 'relations'
          attrGroups: [
            'relatedObjects'
            'relatedEntities'
            'relatedEvents'
            'relatedPlaces'
            'relatedCollections'
          ]
        }
      ]
    event_historic:
      icon: 'calendar'
      label: 'label.event_historic'
      preferredLabelKeys: [ 'name' ]
      createAttrs: [
        'preferredLabelName'
        'eventName'
        'dateEvent'
      ]
      groups: [
        {
          label: 'tab.summary'
          tab: 'summary'
          type: 'summary'
        }
        {
          label: 'tab.basic'
          tab: 'basic'
          type: 'data'
          attrGroups: [
            'idno'
            'preferredLabelName'
            'eventName'
            'externalId'
            'dateEvent'
            'description'
            'url'
            'note'
          ]
        }
        {
          label: 'tab.relations'
          tab: 'relations'
          type: 'relations'
          attrGroups: [
            'relatedObjects'
            'relatedEntities'
            'relatedEvents'
            'relatedPlaces'
            'relatedCollections'
          ]
        }
        {
          label: 'tab.workflow'
          tab: 'workflow'
          type: 'data'
          attrGroups: [
            'citaviCategory'
            'wikidataEntry'
            'workflowNote'
          ]
        }
      ]
    event_award:
      icon: 'calendar'
      label: 'label.event_award'
      preferredLabelKeys: [ 'name' ]
      createAttrs: [
        'preferredLabelName'
        'dateEvent'
        'awardName'
      ]
      groups: [
        {
          label: 'tab.summary'
          tab: 'summary'
          type: 'summary'
        }
        {
          label: 'tab.basic'
          tab: 'basic'
          type: 'data'
          attrGroups: [
            'idno'
            'preferredLabelName'
            'awardName'
            'externalId'
            'dateEvent'
            'awardType'
            'description'
            'url'
            'note'
          ]
        }
        {
          label: 'tab.relations'
          tab: 'relations'
          type: 'relations'
          attrGroups: [
            'relatedObjects'
            'relatedEntities'
            'relatedEvents'
            'relatedPlaces'
            'relatedCollections'
          ]
        }
        {
          label: 'tab.workflow'
          tab: 'workflow'
          type: 'data'
          attrGroups: [
            'wikidataEntry'
            'workflowNote'
          ]
        }
      ]
    event_production:
      icon: 'home'
      label: 'label.event_production'
      preferredLabelKeys: [ 'name' ]
      createAttrs: [
        'preferredLabelName'
        'dateEvent'
      ]
      groups: [
        {
          label: 'tab.summary'
          tab: 'summary'
          type: 'summary'
        }
        {
          label: 'tab.basic'
          tab: 'basic'
          type: 'data'
          attrGroups: [
            'idno'
            'preferredLabelName'
            'externalId'
            'dateEvent'
            'productionEventType'
            'regionalScope'
            'description'
            'url'
            'note'
          ]
        }
        {
          label: 'tab.relations'
          tab: 'relations'
          type: 'relations'
          attrGroups: [
            'relatedObjects'
            'relatedEntities'
            'relatedEvents'
            'relatedPlaces'
            'relatedCollections'
          ]
        }
      ]
    event_preservation:
      icon: 'home'
      label: 'label.event_preservation'
      preferredLabelKeys: [ 'name' ]
      createAttrs: [
        'preferredLabelName'
        'dateEvent'
      ]
      groups: [
        {
          label: 'tab.summary'
          tab: 'summary'
          type: 'summary'
        }
        {
          label: 'tab.basic'
          tab: 'basic'
          type: 'data'
          attrGroups: [
            'idno'
            'preferredLabelName'
            'externalId'
            'dateEvent'
            'preservationType'
            'description'
            'url'
            'note'
          ]
        }
        {
          label: 'tab.relations'
          tab: 'relations'
          type: 'relations'
          attrGroups: [
            'relatedObjects'
            'relatedEntities'
            'relatedEvents'
            'relatedPlaces'
            'relatedCollections'
          ]
        }
      ]
  ca_entities:
    person:
      icon: 'user'
      label: 'label.person'
      preferredLabelKeys: [ 'displayname' ]
      createAttrs: [
        'preferredLabelEntity'
      ]
      summaries: [
        {
          label: 'label.person'
          showThumbnail: true
          attrs: [
            {
              key: 'idno'
              label: 'attr.idno'
            }
            {
              key: 'preferredLabelEntity'
              label: 'attr.preferred_label'
            }
            'personName'
            {
              key: 'externalId'
              inline: true
            }
            'date'
            'sex'
            'activityType'
            'description'
            'url'
            'note'
            'relatedObjects'
            'relatedEntities'
            'relatedEvents'
            'relatedPlaces'
            'relatedCollections'
          ]
        }
      ]
      groups: [
        {
          label: 'tab.summary'
          tab: 'summary'
          type: 'summary'
        }
        {
          label: 'tab.basic'
          tab: 'basic'
          type: 'data'
          attrGroups: [
            'idno'
            'preferredLabelEntity'
            'personName'
            'externalId'
            'date'
            'sex'
            'activityType'
            'description'
            'url'
            'note'
          ]
        }
        {
          label: 'tab.relations'
          tab: 'relations'
          type: 'relations'
          attrGroups: [
            'relatedObjects'
            'relatedEntities'
            'relatedEvents'
            'relatedPlaces'
            'relatedCollections'
          ]
        }
        { 
          label: 'tab.thumbnail'
          tab: 'thumbnail'
          type: 'thumb'
        }
        {
          label: 'tab.workflow'
          tab: 'workflow'
          type: 'data'
          attrGroups: [
            'citaviCategory'
            'wikidataEntry'
            'workflowNote'
          ]
        }
      ]
    organization:
      icon: 'user'
      label: 'label.corporate_body'
      preferredLabelKeys: [ 'displayname' ]
      createAttrs: [
        'preferredLabelCorporate'
      ]
      summaries: [
        {
          label: 'label.corporate_body'
          showThumbnail: true
          attrs: [
            {
              key: 'idno'
              label: 'attr.idno'
            }
            {
              key: 'preferredLabelCorporate'
              label: 'attr.preferred_label'
            }
            'groupName'
            {
              key: 'externalId'
              inline: true
            }
            'date'
            'activityType'
            'description'
            'url'
            'note'
            'relatedObjects'
            'relatedEntities'
            'relatedEvents'
            'relatedPlaces'
            'relatedCollections'
          ]
        }
      ]
      groups: [
        {
          label: 'tab.summary'
          tab: 'summary'
          type: 'summary'
        }
        {
          label: 'tab.basic'
          tab: 'basic'
          type: 'data'
          attrGroups: [
            'idno'
            'preferredLabelCorporate'
            'groupName'
            'externalId'
            'date'
            'activityType'
            'description'
            'url'
            'note'
          ]
        }
        { 
          label: 'tab.thumbnail'
          tab: 'thumbnail'
          type: 'thumb'
        }
        {
          label: 'tab.relations'
          tab: 'relations'
          type: 'relations'
          attrGroups: [
            'relatedObjects'
            'relatedEntities'
            'relatedEvents'
            'relatedPlaces'
            'relatedCollections'
          ]
        }
        {
          label: 'tab.workflow'
          tab: 'workflow'
          type: 'data'
          attrGroups: [
            'citaviCategory'
            'wikidataEntry'
            'workflowNote'
          ]
        }
      ]
    group:
      icon: 'user'
      label: 'label.group'
      preferredLabelKeys: [ 'surname' ]
      createAttrs: [
        'preferredLabelGroup'
      ]
      summaries: [
        {
          label: 'label.corporate_body'
          showThumbnail: true
          attrs: [
            {
              key: 'idno'
              label: 'attr.idno'
            }
            {
              key: 'preferredLabelGroup'
              label: 'attr.preferred_label'
            }
            'groupName'
            {
              key: 'externalId'
              inline: true
            }
            'date'
            'activityType'
            'description'
            'url'
            'note'
            'relatedObjects'
            'relatedEntities'
            'relatedEvents'
            'relatedPlaces'
            'relatedCollections'
          ]
        }
      ]
      groups: [
        {
          label: 'tab.summary'
          tab: 'summary'
          type: 'summary'
        }
        {
          label: 'tab.basic'
          tab: 'basic'
          type: 'data'
          attrGroups: [
            'idno'
            'preferredLabelGroup'
            'groupName'
            'externalId'
            'date'
            'activityType'
            'description'
            'url'
            'note'
          ]
        }
        {
          label: 'tab.relations'
          tab: 'relations'
          type: 'relations'
          attrGroups: [
            'relatedObjects'
            'relatedEntities'
            'relatedEvents'
            'relatedPlaces'
            'relatedCollections'
          ]
        }
        { 
          label: 'tab.thumbnail'
          tab: 'thumbnail'
          type: 'thumb'
        }
        {
          label: 'tab.workflow'
          tab: 'workflow'
          type: 'data'
          attrGroups: [
            'citaviCategory'
            'wikidataEntry'
            'workflowNote'
          ]
        }
      ]
  ca_places:
    unspecified:
      icon: 'map-marker-alt'
      label: 'label.place_unspecified'
      preferredLabelKeys: [ 'name' ]
      createAttrs: [
        'preferredLabelName'
        'titlePlace'
      ]
      groups: [
        {
          label: 'tab.summary'
          tab: 'summary'
          type: 'summary'
        }
        {
          label: 'tab.basic'
          tab: 'basic'
          type: 'data'
          attrGroups: [
            'idno'
            'preferredLabelName'
            'placeType'
            'titlePlace'
            'externalId'
            'date'
            'georeference'
            'address'
            'useOfSpace'
            'description'
            'url'
            'note'
          ]
        }
        {
          label: 'tab.relations'
          tab: 'relations'
          type: 'relations'
          attrGroups: [
            'relatedObjects'
            'relatedEntities'
            'relatedEvents'
            'relatedPlaces'
            'relatedCollections'
          ]
        }
        {
          label: 'tab.workflow'
          tab: 'workflow'
          type: 'data'
          attrGroups: [
            'citaviCategory'
            'wikidataEntry'
            'filmedByAllies'
            'photographedByAllies'
            'workflowNote'
          ]
        }
      ]

  ca_collections:
    generic:
      icon: 'layer-group'
      label: 'label.collection_generic'
      preferredLabelKeys: [ 'name' ]
      createAttrs: [
        'preferredLabelName'
      ]
      groups: [
        {
          label: 'tab.summary'
          tab: 'summary'
          type: 'summary'
        }
        {
          label: 'tab.basic'
          tab: 'basic'
          type: 'data'
          attrGroups: [
            'idno'
            'preferredLabelName'
            'titleCollection'
            'externalId'
            'descriptionLevelCollection'
            'extent'
            'storage'
            'description'
            'url'
            'note'
          ]
        }
        {
          label: 'tab.groups'
          tab: 'groups'
          type: 'data'
          attrGroups: [
            'origin'
            'carrierTypeAV'
            'mediaType'
            'mediaTypeTech'
            'accessStatus'
            'onlineStatus'
          ]
        }
        {
          label: 'tab.rights'
          tab: 'rights'
          type: 'data'
          attrGroups: [
            'provenance'
            'controllingEntity'
            'creditWording'
            'rightsNote'
          ]
        }
        {
          label: 'tab.relations'
          tab: 'relations'
          type: 'relations'
          attrGroups: [
            'relatedObjects'
            'relatedEntities'
            'relatedEvents'
            'relatedPlaces'
            'relatedCollections'
          ]
        }
      ]

  ca_objects:
    av_creation:
      icon: 'video'
      label: 'label.av_creation'
      preferredLabelKeys: [ 'name' ]
      rowClass: 'object-creation'
      createAttrs: [
        'preferredLabelName'
        'title'
      ]
      summaries: [
        {
          label: 'label.av_creation'
          showThumbnail: true
          attrs: [
            {
              key: 'idno'
              label: 'attr.idno'
            }
            {
              key: 'preferredLabelName'
              label: 'attr.preferred_label'
            }
            'title'
            {
              key: 'externalId'
              #attrs: [ 'IdentifierValue' ]
              inline: true
            }
            'creationTypeAV'
            'descriptionLevel'
            'countryOfReference'
            'date'
            'description'
            'url'
            'note'
            'relatedObjects'
            'relatedEntities'
            'relatedEvents'
            'relatedPlaces'
            'relatedCollections'
            'publicationStatus'
            'sourceType'
            'mediaType'
            'genreAV'
            'realityStatus'
            'productionMode'
            'rightsStatus'
            'licenseType'
            'controllingEntity'
            'creditWording'
            'rightsNote'
          ]
        }
        {
          label: 'label.researchers_display'
          showThumbnail: true
          attrs: [
            {
              key: 'idno'
              label: 'attr.idno'
            }
            {
              key: 'preferredLabelName'
              label: 'attr.preferred_label'
            }
            'relatedEntities'
          ]
        }
      ]
      groups: [
        {
          label: 'tab.summary'
          tab: 'summary'
          type: 'summary'
          subType: 'object'
        }
        {
          label: 'tab.basic'
          tab: 'basic'
          type: 'data'
          attrGroups: [
            'idno'
            'preferredLabelName'
            'title'
            'externalId'
            'creationTypeAV'
            'descriptionLevel'
            'countryOfReference'
            'date'
            'description'
            'url'
            'note'
          ]
        }
        {
          label: 'tab.groups'
          tab: 'groups'
          type: 'data'
          attrGroups: [
            'creationTypeAV'
            'publicationStatus'
            'sourceType'
            'mediaType'
            'genreAV'
            'realityStatus'
            'productionMode'
          ]
        }
        {
          label: 'tab.rights'
          tab: 'rights'
          type: 'data'
          attrGroups: [
            'rightsStatus'
            'licenseType'
            'controllingEntity'
            'creditWording'
            'rightsNote'
          ]
        }
        { 
          label: 'tab.thumbnail'
          tab: 'thumbnail'
          type: 'thumb'
        }
        {
          label: 'tab.relations'
          tab: 'relations'
          type: 'relations'
          attrGroups: [
            'relatedObjects'
            'relatedEntities'
            'relatedEvents'
            'relatedPlaces'
            'relatedCollections'
          ]
        }
      ]
    av_manifestation:
      icon: 'video'
      label: 'label.av_manifestation'
      preferredLabelKeys: [ 'name' ]
      rowClass: 'object-manifestation'
      createAttrs: [
        'preferredLabelName'
        'title'
      ]
      summaries: [
        {
          label: 'label.av_manifestation'
          showThumbnail: true
          attrs: [
            {
              key: 'idno'
              label: 'attr.idno'
            }
            {
              key: 'preferredLabelName'
              label: 'attr.preferred_label'
            }
            'title'
            {
              key: 'externalId'
              inline: true
            }
            'date'
            'language'
            'extent'
            'duration'
            'description'
            'url'
            'note'
            'relatedObjects'
            'relatedEntities'
            'relatedEvents'
            'relatedPlaces'
            'relatedCollections'
            'digitalFormatAV'
            'framerate'
            'resolution'
            'gauge'
            'aspectRatio'
            'pixelAspectRatio'
            'sound'
            'colorAV'
            'rightsStatus'
            'licenseType'
            'provenance'
            'controllingEntity'
            'creditWording'
            'rightsNote'
            'origin'
            'carrierTypeAV'
            'variantType'
            'mediaTypeTech'
            'productionStatus'
            'publicationType'
            'accessStatus'
            'onlineStatus'
            'derivativeStatus'
          ]
        }
        {
          label: 'label.researchers_display'
          showThumbnail: true
          attrs: [
            {
              key: 'idno'
              label: 'attr.idno'
            }
            {
              key: 'preferredLabelName'
              label: 'attr.preferred_label'
            }
            'relatedEntities'
          ]
        }
      ]
      groups: [
        {
          label: 'tab.summary'
          tab: 'summary'
          type: 'summary'
          subType: 'object'
        }
        {
          label: 'tab.basic'
          tab: 'basic'
          type: 'data'
          attrGroups: [
            'idno'
            'preferredLabelName'
            'title'
            'externalId'
            'variantType'
            'mediaTypeTech'
            'language'
            'date'
            'extent'
            'duration'
            'description'
            'url'
            'note'
          ]
        }
        {
          label: 'tab.groups'
          tab: 'groups'
          type: 'data'
          attrGroups: [
            'origin'
            'carrierTypeAV'
            'mediaTypeTech'
            'publicationType'
            'productionStatus'
            'accessStatus'
            'onlineStatus'
            'derivativeStatus'
            'digiStatus'
            'generationStatus'
          ]
        }
        {
          label: 'tab.format'
          tab: 'format'
          type: 'data'
          attrGroups: [
            'digitalFormatAV'
            'framerate'
            'resolution'
            'aspectRatio'
            'pixelAspectRatio'
            'carrierTypeAV'
            'gauge'
            'sound'
            'colorAV'
          ]
        }
        {
          label: 'tab.rights'
          tab: 'rights'
          type: 'data'
          attrGroups: [
            'rightsStatus'
            'licenseType'
            'provenance'
            'creditWording'
            'controllingEntity'
          ]
        }
        {
          label: 'tab.relations'
          tab: 'relations'
          type: 'relations'
          attrGroups: [
            'relatedObjects'
            'relatedEntities'
            'relatedEvents'
            'relatedPlaces'
            'relatedCollections'
          ]
        }
        { 
          label: 'tab.thumbnail'
          tab: 'thumbnail'
          type: 'thumb'
        }
        {
          label: 'tab.workflow'
          tab: 'workflow'
          type: 'data'
          attrGroups: [
            'workflowTodo'
            'workflowNote'
          ]
        }
      ]
    nonav_creation:
      icon: 'file'
      label: 'label.nonav_creation'
      preferredLabelKeys: [ 'name' ]
      rowClass: 'object-creation'
      createAttrs: [
        'preferredLabelName'
        'title'
      ]
      summaries: [
        {
          label: 'label.nonav_creation'
          showThumbnail: true
          attrs: [
            {
              key: 'idno'
              label: 'attr.idno'
            }
            {
              key: 'preferredLabelName'
              label: 'attr.preferred_label'
            }
            'title'
            {
              key: 'externalId'
              inline: true
            }
            'date'
            'language'
            'viewPoint'
            'description'
            'url'
            'note'
            'relatedObjects'
            'relatedEntities'
            'relatedEvents'
            'relatedPlaces'
            'relatedCollections'
            'publicationStatus'
            'sourceType'
            'mediaType'
            'genreNonAV'
            'realityStatus'
            'productionMode'
          ]
        }
        {
          label: 'label.researchers_display'
          showThumbnail: true
          attrs: [
            {
              key: 'idno'
              label: 'attr.idno'
            }
            {
              key: 'preferredLabelName'
              label: 'attr.preferred_label'
            }
            'relatedEntities'
          ]
        }
      ]
      groups: [
        {
          label: 'tab.summary'
          tab: 'summary'
          type: 'summary'
          subType: 'object'
        }
        {
          label: 'tab.basic'
          tab: 'basic'
          type: 'data'
          attrGroups: [
            'idno'
            'preferredLabelName'
            'title'
            'externalId'
            'date'
            'language2'
            'viewPoint'
            'description'
            'url'
            'note'
          ]
        }
        {
          label: 'tab.groups'
          tab: 'groups'
          type: 'data'
          attrGroups: [
            'publicationStatus'
            'sourceType'
            'mediaType'
            'genreNonAV'
            'realityStatus'
            'productionMode'
          ]
        }
        {
          label: 'tab.rights'
          tab: 'rights'
          type: 'data'
          attrGroups: [
            'rightsStatus'
            'licenseType'
            'controllingEntity'
            'creditWording'
            'rightsNote'
          ]
        }
        {
          label: 'tab.relations'
          tab: 'relations'
          type: 'relations'
          attrGroups: [
            'relatedObjects'
            'relatedEntities'
            'relatedEvents'
            'relatedPlaces'
            'relatedCollections'
          ]
        }
        { 
          label: 'tab.thumbnail'
          tab: 'thumbnail'
          type: 'thumb'
        }
      ]
    nonav_manifestation:
      icon: 'file'
      label: 'label.nonav_manifestation'
      preferredLabelKeys: [ 'name' ]
      rowClass: 'object-manifestation'
      createAttrs: [
        'preferredLabelName'
        'title'
      ]
      summaries: [
        {
          label: 'label.nonav_manifestation'
          showThumbnail: true
          attrs: [
            {
              key: 'idno'
              label: 'attr.idno'
            }
            {
              key: 'preferredLabelName'
              label: 'attr.preferred_label'
            }
            'title'
            {
              key: 'externalId'
              inline: true
            }
            'date'
            'language'
            'extent'
            'description'
            'url'
            'note'
            'relatedObjects'
            'relatedEntities'
            'relatedEvents'
            'relatedPlaces'
            'relatedCollections'
            'origin'
            'carrierTypeAV'
            'variantType'
            'mediaTypeTech'
            'productionStatus'
            'publicationType'
            'accessStatus'
            'onlineStatus'
            'derivativeStatus'
            'genreNonAV'
            'digitalFormatNonAV'
            'resolution'
            'resolutionDpi'
            'physicalFormat'
            'colorNonAV'
            'rightsStatus'
            'licenseType'
            'provenance'
            'controllingEntity'
            'creditWording'
            'rightsNote'
          ]
        }
        {
          label: 'label.researchers_display'
          showThumbnail: true
          attrs: [
            {
              key: 'idno'
              label: 'attr.idno'
            }
            {
              key: 'preferredLabelName'
              label: 'attr.preferred_label'
            }
            'relatedEntities'
          ]
        }
      ]
      groups: [
        {
          label: 'tab.summary'
          tab: 'summary'
          type: 'summary'
          subType: 'object'
        }
        {
          label: 'tab.basic'
          tab: 'basic'
          type: 'data'
          attrGroups: [
            'idno'
            'preferredLabelName'
            'title'
            'externalId'
            'variantType'
            'mediaTypeTech'
            'date'
            'language2'
            'extent'
            'description'
            'url'
            'note'
          ]
        }
        {
          label: 'tab.groups'
          tab: 'groups'
          type: 'data'
          attrGroups: [
            'origin'
            'carrierTypeAV'
            'mediaTypeTech'
            'productionStatus'
            'publicationType'
            'accessStatus'
            'onlineStatus'
            'derivativeStatus'
            'digiStatus'
            'digiObstacle'
          ]
        }
        {
          label: 'tab.format'
          tab: 'format'
          type: 'data'
          attrGroups: [
            'digitalFormatNonAV'
            'resolution'
            'resolutionDpi'
            'physicalFormat'
            'colorNonAV'
          ]
        }
        {
          label: 'tab.rights'
          tab: 'rights'
          type: 'data'
          attrGroups: [
            'rightsStatus'
            'licenseType'
            'provenance'
            'controllingEntity'
          ]
        }
        {
          label: 'tab.relations'
          tab: 'relations'
          type: 'relations'
          attrGroups: [
            'relatedObjects'
            'relatedEntities'
            'relatedEvents'
            'relatedPlaces'
            'relatedCollections'
          ]
        }
        { 
          label: 'tab.thumbnail'
          tab: 'thumbnail'
          type: 'thumb'
        }
        {
          label: 'tab.workflow'
          tab: 'workflow'
          type: 'data'
          attrGroups: [
            'workflowTodo'
            'workflowNote'
          ]
        }
      ]
    item:
      icon: 'file'
      label: 'label.item'
      preferredLabelKeys: [ 'name' ]
      rowClass: 'object-item'
      createAttrs: [
        'preferredLabelName'
        'title'
      ]
      summaries: [
        {
          label: 'label.item'
          showThumbnail: true
          attrs: [
            {
              key: 'idno'
              label: 'attr.idno'
            }
            {
              key: 'preferredLabelName'
              label: 'attr.preferred_label'
            }
            'titleItem'
            {
              key: 'externalId'
              inline: true
            }
            'holdingInstitution'
            'extent'
            'accessStatus'
            'note'
            'relatedObjects'
            'relatedEntities'
            'relatedEvents'
            'relatedPlaces'
            'relatedCollections'
            'digitalFormatAV'
            'digitalFormatNonAV'
            'duration'
            'framerate'
            'resolutionDisplay'
            'resolution'
            'resolutionDpi'
            'aspectRatio'
            'pixelAspectRatio'
            'controllingEntity'
          ]
        }
        {
          label: 'label.researchers_display'
          showThumbnail: true
          attrs: [
            {
              key: 'idno'
              label: 'attr.idno'
            }
            {
              key: 'preferredLabelName'
              label: 'attr.preferred_label'
            }
            'relatedEntities'
          ]
        }
      ]
      groups: [
        {
          label: 'tab.summary'
          tab: 'summary'
          type: 'summary'
          subType: 'object'
        }
        {
          label: 'tab.basic'
          tab: 'basic'
          type: 'data'
          attrGroups: [
            'idno'
            'preferredLabelName'
            'titleItem'
            'externalId'
            'itemSpecifics'
            'accessStatus'
            'extent'
            'url'
            'note'
          ]
        }
        {
          label: 'tab.format'
          tab: 'format'
          type: 'data'
          attrGroups: [
            'digitalFormatAV'
            'digitalFormatNonAV'
            'duration'
            'framerate'
            'resolution'
            'resolutionDisplay'
            'resolutionDpi'
            'overscanMask'
            'aspectRatio'
            'pixelAspectRatio'
          ]
        }
        {
          label: 'tab.rights'
          tab: 'rights'
          type: 'data'
          attrGroups: [
            'provenance'
            'controllingEntity'
          ]
        }
        {
          label: 'tab.relations'
          tab: 'relations'
          type: 'relations'
          attrGroups: [
            'relatedObjects'
            'relatedEntities'
            'relatedEvents'
            'relatedPlaces'
            'relatedCollections'
          ]
        }
        { 
          label: 'tab.media'
          tab: 'media'
          type: 'media'
        }
        { 
          label: 'tab.shots'
          tab: 'shots'
          type: 'shots'
        }
      ]