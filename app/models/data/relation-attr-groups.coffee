module.exports =
  note:
    key: 'vhh_Note'
    labelKey: 'label.vhh_Note'
    items: [
      { key: 'vhh_NoteText', cols: 12, type: 'textarea', rows: 6, required: true }
      { key: 'vhh_NoteReference', cols: 6 }
    ]
  temporalScope:
    key: 'vhh_TemporalScope'
    labelKey: 'attr.vhh_TemporalScope'
    items: [
      { key: 'vhh_TemporalScope', cols: 3, required: true }
    ]
  hasAgent:
    key: 'vhh_HasAgent'
    labelKey: 'label.vhh_HasAgent'
    items: [
      { key: 'HA_CreditText', cols: 4 }
      { key: 'HA_ActivityDetail', cols: 4 }
      { key: 'HA_Character', cols: 4 }
      { key: 'HA_NameUsed', cols: 4 }
      { key: 'HA_CreditRank', cols: 4 }
    ]