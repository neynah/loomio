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
    en: 'english',
    it: 'italian',
    es: 'spanish',
    fr: 'french'
  }.freeze

end
