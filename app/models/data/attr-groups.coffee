module.exports =
  idno:
    label: false
    canEdit: false
    key: 'intrinsic_fields'
    single: true
    items: [
      { key: 'idno', cols: 12, strong: true }
    ]
  preferredLabelName:
    labelCode: 'header.preferred_label'
    key: 'preferred_labels'
    single: true
    minItems: 1
    items: [
      { key: 'name', labelCode: 'attr.name', required: true, type: 'textarea', rows: 3, cols: 12, strong: true, asLabel: true }
    ]
  preferredLabelCorporate:
    labelCode: 'header.preferred_label'
    key: 'preferred_labels'
    single: true
    minItems: 1
    items: [
      { key: 'displayname', labelCode: 'attr.displayname', required: true, cols: 9, strong: true, asLabel: true }
      { key: 'suffix', labelCode: 'attr.suffix', cols: 3, strong: true }
    ]
  preferredLabelEntity:
    labelCode: 'header.preferred_label'
    key: 'preferred_labels'
    single: true
    minItems: 1
    items: [
      { key: 'prefix', labelCode: 'attr.prefix', cols: 2, strong: true }
      { key: 'forename', labelCode: 'attr.forename', cols: 3, strong: true }
      { key: 'middlename', labelCode: 'attr.middlename', cols: 3, strong: true }
      { key: 'surname', labelCode: 'attr.surname', required: true, cols: 3, strong: true }
      { key: 'suffix', labelCode: 'attr.suffix', cols: 1, strong: true }
      { key: 'other_forenames', labelCode: 'attr.other_forenames', cols: 3, offset: 2, strong: true }
      { key: 'displayname', labelCode: 'attr.displayname', cols: 6, strong: true, asLabel: true }
    ]
  preferredLabelGroup:
    labelCode: 'header.preferred_label'
    key: 'preferred_labels'
    single: true
    minItems: 1
    items: [
      { key: 'surname', labelCode: 'attr.name', required: true, cols: 9, strong: true, asLabel: true }
      { key: 'suffix', labelCode: 'attr.suffix', cols: 3, strong: true }
    ]
  title:
    key: 'vhh_Title'
    idKeys: ['TitleText']
    minItems: 1
    items:
      [
        { key: 'Language', cols: 3 }
        { key: 'TitleText', cols: 6, strong: true }
        { key: 'TitleType', cols: 3 }
        { key: 'Unit', cols: 3 }
        { key: 'Value', cols: 3 }
        { key: 'TitlePart', cols: 6 }
        { key: 'TitleTemporalScope', cols: 3 }
        { key: 'GeographicScopePlace', cols: 3 }
        { key: 'GeographicScopeText', cols: 3 }
        { key: 'TitleRemarks2', cols: 12 }
        { key: 'TitleUID', cols: 12 }
      ]
  titleItem:
    key: 'vhh_TitleItem'
    idKeys: ['TitleTextI']
    minItems: 1
    items:
      [
        { key: 'LanguageI', cols: 3 }
        { key: 'TitleTextI', cols: 6, strong: true }
        { key: 'TitleTypeI', cols: 3 }
        { key: 'TitleUIDI', cols: 12 }
      ]
  titlePlace:
    key: 'vhh_TitlePlace'
    idKeys: ['PT_Name']
    minItems: 1
    items:
      [
        { key: 'TP_Language', cols: 3 }
        { key: 'TP_Name', cols: 6, strong: true }
        { key: 'TP_Type', cols: 3 }
        { key: 'TP_TempScope', cols: 3 }
      ]
  titleCollection:
    key: 'vhh_TitleCollection'
    idKeys: ['TitleTextC']
    minItems: 1
    items:
      [
        { key: 'LanguageC', cols: 3 }
        { key: 'TitleTextC', cols: 6, strong: true }
        { key: 'TitleTypeC', cols: 3 }
      ]
  externalId:
    key: 'vhh_Identifier'
    idKeys: ['IdentifierValue']
    minItems: 1
    items:
      [
        { key: 'IdentifierScheme', cols: 3, lookup: true, lookupMinLength: 1 }
        {
          key: 'IdentifierValue',
          cols: 3,
          strong: true,
          type: 'urlWithTest',
          testAttr: 'IdentifierScheme',
          linkPatterns: [
            { key: 'wikidata', pattern: 'https://www.wikidata.org/wiki/%s' }
          ]
        }
      ]
  language:
    key: 'vhh_Language'
    idKeys: ['lang_Name']
    items: [
      { key: 'lang_Name', cols: 3, strong: true }
      { key: 'lang_Usage', cols: 3  }
    ]
  language2:
    key: 'vhh_Language2'
    idKeys: ['vhh_Language2']
    single: true
    items: [
      { key: 'vhh_Language2', cols: 3, strong: true }
    ]
  date:
    key: 'vhh_Date'
    idKeys: ['date_Date']
    items: [
      { key: 'date_Date', label: 'attr.date', cols: 3, strong: true }
      { key: 'date_Type', cols: 3 }
    ]
  dateEvent:
    key: 'vhh_DateEvent'
    idKeys: ['vhh_DateEvent']
    single: true
    items: [
      { key: 'vhh_DateEvent', cols: 3 }
    ]
  awardName:
    key: 'vhh_AwardName'
    idKeys: ['AwardNameList']
    minItems: 1
    items: [
      { key: 'AN_NameType', cols: 3 }
      { key: 'AN_Text', cols: 9 }
      { key: 'AN_TempScope', cols: 3 }
      { key: 'AN_Language', cols: 3 }
    ]
  awardType:
    key: 'vhh_AwardType'
    items: [
      { key: 'AT_List', cols: 3 }
      { key: 'AT_Text', cols: 9 }
    ]
  eventName:
    key: 'vhh_EventName'
    items: [
      { key: 'LanguageE', cols: 3 }
      { key: 'TitleTextE', cols: 9 }
    ]
  url:
    key: 'vhh_URL'
    idKeys: ['vhh_URL']
    items: [
      { key: 'vhh_URL', cols: 12 }
    ]
  extent:
    key: 'vhh_Extent'
    idKeys: ['ext_Value', 'ext_Unit']
    items: [
      { key: 'ext_Value', cols: 3 }
      { key: 'ext_Unit', cols: 3 }
      { key: 'ext_Ref', cols: 6 }
    ]
  framerate:
    key: 'vhh_FrameRate'
    idKeys: ['vhh_FrameRate']
    items: [
      { key: 'fps_list', cols: 3 }
      { key: 'fps_reference', cols: 3 }
    ]
  duration:
    single: true
    key: 'vhh_Duration'
    idKeys: ['vhh_Duration']
    items: [
      { key: 'vhh_Duration', cols: 3 }
    ]
  description:
    key: 'vhh_Description'
    idKeys: ['DescriptionText']
    items: [
      { key: 'DescriptionText', cols: 12, type: 'textarea', rows: 6 }
      { key: 'DescriptionType', cols: 3 }
      { key: 'DescriptionLang', cols: 3 }
    ]
  note:
    key: 'vhh_Note'
    items: [
      { key: 'vhh_NoteText', cols: 12, type: 'textarea', rows: 6 }
      { key: 'vhh_NoteReference', cols: 12 }
    ]
  digitalFormatNonAV:
    key: 'vhh_DigitalFormat'
    single: true
    idKeys: ['digi_MIME']
    items: [
      { key: 'digi_MIME', cols: 3, strong: true }
    ]
  digitalFormatAV:
    key: 'vhh_DigitalFormatAV'
    single: true
    items: [
      { key: 'digi_Coding', cols: 3 }
      { key: 'digi_CodingAudio', cols: 3 }
      { key: 'digi_MIME2', cols: 3 }
    ]
  physicalFormat:
    single: true
    key: 'vhh_PhysicalFormat'
    idKeys: ['PF_SizeList']
    items: [
      { key: 'PF_SizeList', cols: 3 }
      { key: 'PF_SizeText', cols: 3 }
    ]
  resolution:
    key: 'vhh_ResolutionPixel'
    single: true
    items: [
      { key: 'res_width', cols: 1 }
      { key: 'res_height', cols: 1 }
      { key: 'res_standard', cols: 3 }
    ]
  resolutionDpi:
    key: 'vhh_ResolutionDPI'
    single: true
    items: [
      { key: 'RD_list', cols: 3 }
      { key: 'RD_text', cols: 3 }
    ]
  resolutionDisplay:
    key: 'vhh_ResolutionPixelDisplay'
    single: true
    items: [
      { key: 'resD_width', cols: 3 }
      { key: 'resD_height', cols: 3 }
      { key: 'resD_standard', cols: 3 }
    ]
  carrierTypeAV:
    key: 'vhh_CarrierType2'
    idKeys: ['CarrierTypeList']
    single: true
    items: [
      { key: 'CarrierTypeList', cols: 3 }
      { key: 'CarrierTypeText', cols: 3 }
    ]
  gauge:
    key: 'vhh_Gauge'
    single: true
    items: [
      { key: 'Gauge_List', cols: 3 }
      { key: 'Gauge_Text', cols: 9 }
    ]
  aspectRatio:
    key: 'vhh_AspectRatio'
    idKeys: ['vhh_AspectRatio']
    single: true
    items: [
      { key: 'vhh_AspectRatio', cols: 3 }
    ]
  pixelAspectRatio:
    key: 'vhh_PixelAspectRatio'
    single: true
    items: [
      { key: 'vhh_PixelAspectRatio', cols: 3 }
    ]
  overscanMask:
    key: 'vhh_OverscanMask'
    single: true
    items: [
      { key: 'OM_left', cols: 2 }
      { key: 'OM_top', cols: 2 }
      { key: 'OM_right', cols: 2 }
      { key: 'OM_bottom', cols: 2 }
    ]
  sound:
    single: true
    key: 'vhh_Sound'
    items: [
      { key: 'snd_SystemName', cols: 3 }
      { key: 'snd_HasSound', cols: 1 }
      { key: 'snd_Method', cols: 3, break: true }
      { key: 'snd_Text', cols: 6 }
    ]
  colorAV:
    single: true
    key: 'vhh_ColorAV'
    items: [
      { key: 'colAV_HasColor', cols: 1 }
      { key: 'colAV_ColorDetail', cols: 2 }
      { key: 'colAV_ColorFilmProcess', cols: 3 }
      { key: 'colAV_Text', cols: 4, break: true }
      { key: 'colAV_ColorSpace', cols: 3 }
      { key: 'colAV_Depth', cols: 3 }
    ]
  colorNonAV:
    single: true
    key: 'vhh_ColorNonAV'
    items: [
      { key: 'colNAV_HasColor', cols: 1 }
      { key: 'colNAV_ColorDetail', cols: 2 }
      { key: 'colNAV_ColorSpace', cols: 3, break: true }
      { key: 'colNAV_Text', cols: 3 }
      { key: 'colNAV_Depth', cols: 3 }
    ]
  rightsStatus:
    key: 'vhh_RightsStatus2'
    idKeys: ['vhh_RightsStatusList']
    single: true
    items: [
      { key: 'vhh_RightsStatusList', cols: 3, break: true }
      { key: 'vhh_RightsStatusRemarks', cols: 12, type: 'textarea', rows: 4 }
    ]
  licenseType:
    key: 'vhh_LicenseType'
    idKeys: ['vhh_LT_Type']
    items: [
      { key: 'vhh_LT_Type', cols: 3 }
      { key: 'vhh_LT_Other', cols: 3 }
    ]
  provenance:
    key: 'vhh_Provenance'
    single: true
    items: [
      { key: 'vhh_Provenance', cols: 12, type: 'textarea', rows: 4 }
    ]
  controllingEntity:
    key: 'vhh_ControllingEntity'
    idKeys: ['CE_Type']
    items: [
      { key: 'CE_Type', cols: 3 }
      { key: 'CE_TemporalScope', cols: 3 }
      { key: 'CE_GeographicScope', cols: 3, break: true }
      { key: 'CE_Remarks', cols: 12, type: 'textarea', rows: 4 }
      { key: 'CE_Agent', cols: 3}
    ]
  relatedObjects:
    labelCode: 'header.related_objects'
    key: 'related'
    controllerPath: 'details#object'
    relationKey: 'ca_objects'
    attrKeys: [ 'name' ]
    idKey: 'object_id'
  relatedEntities:
    labelCode: 'header.related_entities'
    key: 'related'
    controllerPath: 'details#agent'
    relationKey: 'ca_entities'
    attrKeys: [ 'displayname' ]
    idKey: 'entity_id'
  relatedEvents:
    labelCode: 'header.related_events'
    key: 'related'
    controllerPath: 'details#event'
    relationKey: 'ca_occurrences'
    attrKeys: [ 'name' ]
    relatedAttrs: [
      {
        key: 'vhh_DateEvent.vhh_DateEvent'
        labelKey: 'attr.date'
      }
    ]
    idKey: 'occurrence_id'
  relatedPlaces:
    labelCode: 'header.related_places'
    key: 'related'
    controllerPath: 'details#place'
    relationKey: 'ca_places'
    attrKeys: [ 'name' ]
    idKey: 'place_id'
  relatedCollections:
    labelCode: 'header.related_collections'
    key: 'related'
    controllerPath: 'details#collection'
    relationKey: 'ca_collections'
    attrKeys: [ 'name' ]
    idKey: 'collection_id'
  descriptionLevel:
    single: true
    key: 'vhh_DescriptionLevel'
    idKeys: ['vhh_DescriptionLevel']
    items: [
      { key: 'vhh_DescriptionLevel', cols: 3 }
    ]
  descriptionLevelCollection:
    single: true
    key: 'vhh_DescriptionLevelC'
    idKeys: ['vhh_DescriptionLevelC']
    items: [
      { key: 'vhh_DescriptionLevelC', cols: 3 }
    ]
  creationTypeAV:
    single: true
    minItems: 1
    key: 'vhh_AVType'
    idKeys: ['vhh_AVType']
    items: [
      { key: 'vhh_AVType', cols: 3}
    ]
  countryOfReference:
    key: 'vhh_CountryOfReference'
    idKeys: ['Country']
    items: [
      { key: 'CountryPlace', cols: 3 }
      { key: 'Reference', cols: 3, break: true }
      { key: 'CountryText', cols: 6 }
    ]
  mediaType:
    key: 'vhh_MediaType'
    single: true
    idKeys: ['MT_List']
    items: [
      { key: 'MT_List', cols: 3 }
      { key: 'MT_Text', cols: 3 }
    ]
  mediaTypeTech:
    key: 'vhh_MediaTypeTech'
    single: true
    idKeys: ['MTT_List']
    items: [
      { key: 'MTT_List', cols: 3, strong: true }
      { key: 'MTT_Text', cols: 3 }
    ]
  variantType:
    key: 'vhh_VariantType'
    single: true
    items: [
      { key: 'VT_List', cols: 3, strong: true }
      { key: 'VT_Text', cols: 3 }
    ]
  publicationStatus:
    key: 'vhh_PublicationStatus'
    idKeys: ['vhh_PublicationStatus']
    single: true
    items: [
      { key: 'vhh_PublicationStatus', cols: 3}
    ]
  publicationType:
    key: 'vhh_PublicationType2'
    idKeys: ['PublicationTypeList']
    single: true
    items: [
      { key: 'PublicationTypeList', cols: 3}
      { key: 'PublicationTypeText', cols: 3}
    ]
  sourceType:
    key: 'vhh_SourceType'
    idKeys: ['vhh_SourceType']
    single: true
    items: [
      { key: 'vhh_SourceType', cols: 3}
    ]
  genreAV:
    key: 'vhh_GenreAV'
    items: [
      { key: 'GenreAV_List', cols: 3}
      { key: 'GenreAV_Text', cols: 3}
    ]
  genreNonAV:
    key: 'vhh_GenreNonAV'
    items: [
      { key: 'GenreNonAV_List', cols: 3}
      { key: 'GenreNonAV_Text', cols: 3}
    ]
  realityStatus:
    key: 'vhh_RealityStatus'
    idKeys: ['vhh_RealityStatus']
    single: true
    items: [
      { key: 'vhh_RealityStatus', cols: 3}
    ]
  productionMode:
    key: 'vhh_ProductionMode'
    idKeys: ['vhh_ProductionMode']
    single: true
    items: [
      { key: 'vhh_ProductionMode', cols: 3}
    ]
  personName:
    key: 'vhh_PersonName'
    idKeys: ['GN_Name']
    items: [
      { key: 'PN_Prefix', cols: 2}
      { key: 'PN_Forename', cols: 2}
      { key: 'PN_MiddleName', cols: 2}
      { key: 'PN_FamilyName', cols: 3}
      { key: 'PN_NobiliaryParticle', cols: 1}
      { key: 'PN_Suffix', cols: 1, break: true}
      { key: 'PN_OtherForenames', cols: 4, offset: 2}
      { key: 'PN_DisplayName', cols: 6}
      { key: 'PN_Type', cols: 3}
      { key: 'PN_TempScope', cols: 3, break: true}
      { key: 'PN_GeoScope', cols: 3}
      { key: 'PN_Language', cols: 3}
    ]
  groupName:
    key: 'vhh_GroupName'
    idKeys: ['GN_Name']
    items: [
      { key: 'GN_Name', cols: 8}
      { key: 'GN_Suffix', cols: 2}
      { key: 'GN_Abbreviation', cols: 2}
      { key: 'GN_Type', cols: 3}
      { key: 'GN_TempScope', cols: 3}
      { key: 'GN_GeoScope', cols: 3, break: true}
      { key: 'GN_Language', cols: 3}
    ]
  sex:
    key: 'vhh_Sex'
    idKeys: ['vhh_Sex']
    single: true
    items: [
      { key: 'vhh_Sex', cols: 3}
    ]
  activityType:
    key: 'vhh_TypeOfActivity2'
    idKeys: ['ActivityList']
    items: [
      { key: 'ActivityList', cols: 3}
      { key: 'ActivityText', cols: 3, break: true}
      { key: 'TOA_TempScope', cols: 3}
      { key: 'ActivityCredit', cols: 3 }
    ]
  placeAgent:
    key: 'vhh_Place'
    idKeys: ['place_Place']
    items: [
      { key: 'place_Place', cols: 6}
      { key: 'place_Type', cols: 3}
    ]
  origin:
    key: 'vhh_Origin'
    single: true
    items: [
      { key: 'vhh_Origin', cols: 3 }
    ]
  productionStatus:
    key: 'vhh_ProductionStatus'
    single: true
    items: [
      { key: 'vhh_ProductionStatus', cols: 3 }
    ]
  accessStatus:
    key: 'vhh_AccessStatus2'
    single: true
    items: [
      { key: 'AS_List', cols: 3 }
      { key: 'AS_Text', cols: 6 }
    ]
  onlineStatus:
    key: 'vhh_OnlineStatus'
    single: true
    items: [
      { key: 'vhh_OnlineStatus', cols: 3 }
    ]
  derivativeStatus:
    key: 'vhh_DerivativeStatus'
    single: true
    items: [
      { key: 'vhh_DerivativeStatus', cols: 3 }
    ]
  holdingInstitution:
    key: 'vhh_HoldingInstitution'
    items: [
      { key: 'vhh_HoldingInstitution', cols: 3 } # TODO: Relation of type 'Entity'
    ]
  itemSpecifics:
    key: 'vhh_ItemSpecifics'
    items: [
      { key: 'vhh_ItemSpecifics', cols: 12, type: 'textarea', rows: 6 }
    ]
  accessConditions:
    key: 'vhh_AccessConditions2'
    items: [
      { key: 'vhh_AccessConditions2', cols: 3, type: 'textarea', rows: 6 }
    ]
  decisionType:
    key: 'vhh_DecisionType'
    items: [
      { key: 'DecisionTypeList', cols: 3 }
      { key: 'DecisionTypeText', cols: 9 }
    ]
  regionalScope:
    key: 'cws_RegionalScope'
    items: [
      { key: 'RegionalScopePlace', cols: 6 }
      { key: 'RegionalScopeText', cols: 6 }
    ]
  certificateNumber:
    key: 'vhh_CertificateNumber'
    single: true
    items: [
      { key: 'vhh_CertificateNumber', cols: 6 }
    ]
  verdict:
    key: 'cws_Verdict'
    single: true
    items: [
      { key: 'cws_Verdict', cols: 6 }
    ]
  registrationAgency:
    key: 'cws_RegistrationAgency'
    single: true
    items: [
      { key: 'cws_RegistrationAgency', cols: 3 }
    ]
  applicantName:
    key: 'cws_NameOfApplicant'
    items: [
      { key: 'cws_NameOfApplicant', cols: 3 }
    ]
  preservationType:
    key: 'cws_PreservationType'
    single: true
    items: [
      { key: 'cws_PreservationType', cols: 3 }
    ]
  productionEventType:
    key: 'cws_ProductionEventType'
    single: true
    items: [
      { key: 'cws_ProductionEventType', cols: 3 }
    ]
  publicationTypeEvent:
    key: 'vhh_PublicationEventType'
    single: true
    idKeys: [ 'PublicationEventTypeList' ]
    items: [
      { key: 'PublicationEventTypeList', cols: 3 }
      { key: 'PublicationEventTypeText', cols: 9 }
    ]
  georeference:
    key: 'georeference'
    items: [
      { key: 'georeference', cols: 6 }
    ]
  viewPoint:
    key: 'vhh_Viewpoint'
    items: [
      { key: 'vhh_Viewpoint', cols: 6 }
    ]

  creditWording:
    key: 'vhh_CreditWording'
    items: [
      { key: 'vhh_CreditWording', required: true, type: 'textarea', rows: 3, cols: 12}
    ]
  useOfSpace:
    key: 'vhh_UseOfSpace'
    items: [
      { key: 'UOS_TypeList', cols: 3 }
      { key: 'UOS_TypeText', cols: 3, break: true }
      { key: 'UOS_TempScope', cols: 3 }
    ]
  storage:
    key: 'vhh_Storage'
    items: [
      { key: 'SL_Label', cols: 3 }
      { key: 'SL_Type', cols: 3 }
    ]
  address:
    key: 'vhh_Address'
    items: [
      { key: 'A_Street', cols: 4 }
      { key: 'A_StreetNo', cols: 3, break: true }
      { key: 'A_Zipcode', cols: 2 }
      { key: 'A_City', cols: 2 }
      { key: 'A_Country', cols: 3, break: true }
      { key: 'A_TempScope', cols: 3 }
    ]
  rightsNote:
    key: 'vhh_RightsNote'
    items: [
      { key: 'RN_Text', required: true, type: 'textarea', rows: 3, cols: 12, strong: true, asLabel: true }
      { key: 'RN_Reference', cols: 12 }
    ]
  digiObstacle:
    key: 'vhh_DigitizationObstacle'
    items: [
      { key: 'DO_List', cols: 3}
      { key: 'DO_Text', cols: 9}
    ]
  digiStatus:
    key: 'vhh_DigitizationStatus'
    items: [
      { key: 'DS_List', cols: 3}
      { key: 'DS_Text', cols: 9}
    ]
  generationStatus:
    key: 'vhh_GenerationStatus'
    items: [
      { key: 'GS_list', cols: 3}
      { key: 'GS_text', cols: 9}
    ]
  citaviCategory:
    key: 'vhh_WF_CitaviCategory'
    single: true
    items: [
      { key: 'vhh_WF_CitaviCategory', cols: 3 }
    ]
  wikidataEntry:
    key: 'vhh_WF_WikidataEntry'
    single: true
    items: [
      { key: 'vhh_WF_WikidataEntry', cols: 3 }
    ]
  filmedByAllies:
    key: 'vhh_WF_FilmedByAllies'
    single: true
    items: [
      { key: 'vhh_WF_FilmedByAllies', cols: 3 }
    ]
  photographedByAllies:
    key: 'vhh_WF_PhotographedByAllies'
    single: true
    items: [
      { key: 'vhh_WF_PhotographedByAllies', cols: 3 }
    ]
  workflowTodo:
    key: 'vhh_WF_Todo'
    single: true
    items: [
      { key: 'vhh_WF_Todo', cols: 3 }
    ]
  workflowNote:
    key: 'vhh_WF_Note'
    items: [
      { key: 'vhh_WF_NoteText', cols: 12, type: 'textarea', rows: 6 }
      { key: 'vhh_WF_NoteReference', cols: 12 }
    ]
  placeType:
    key: 'vhh_PlaceType'
    single: true
    items: [
      { key: 'PT_Type', cols: 3}
      { key: 'PT_Text', cols: 9}
    ]