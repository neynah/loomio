class SearchConstants

  WEIGHT_VALUES = [
    ENV.fetch('SEARCH_WEIGHTS_A', 1.0),  # A
    ENV.fetch('SEARCH_WEIGHTS_B', 0.3),  # B
    ENV.fetch('SEARCH_WEIGHTS_C', 0.1),  # C
    ENV.fetch('SEARCH_WEIGHTS_D', 0.03)  # D
  ].reverse.freeze

  WEIGHTED_FIELDS = {
    'discussions.title'        => :A,
    'motion_names'             => :B,
    'discussions.description'  => :C,
    'motion_descriptions'      => :C,
    'comment_bodies'           => :D
  }.freeze

  LOCALES = {
    da: 'danish',
    de: 'german',
    en: 'english',
    es: 'spanish',
    it: 'italian',
    fr: 'french',
    'pt-BR': 'portuguese',
    pt: 'portuguese',
    ro: 'romanian',
    sv: 'swedish',
    tr: 'turkish'
  }.with_indifferent_access.freeze

end
