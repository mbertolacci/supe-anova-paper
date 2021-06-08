CONFIGURATIONS <- c(
  # 'Prior',
  'IS',
  'LN',
  'LG'
)

REGION_NAME_TO_CODE <- c(
  'TransCom 01: North American Boreal' = 'T01',
  'TransCom 02: North American Temperate' = 'T02',
  'TransCom 03a: Northern Tropical South America' = 'T03a',
  'TransCom 03b: Southern Tropical South America' = 'T03b',
  'TransCom 04: South American Temperate' = 'T04',
  'TransCom 05a: Temperate Northern Africa' = 'T05a',
  'TransCom 05b: Northern Tropical Africa' = 'T05b',
  'TransCom 06a: Southern Tropical Africa' = 'T06a',
  'TransCom 06b: Temperate Southern Africa' = 'T06b',
  'TransCom 07: Eurasia Boreal' = 'T07',
  'TransCom 08: Eurasia Temperate' = 'T08',
  'TransCom 09a: Northern Tropical Asia' = 'T09a',
  'TransCom 09b: Southern Tropical Asia' = 'T09b',
  'TransCom 10a: Tropical Australia' = 'T10a',
  'TransCom 10b: Temperate Australia' = 'T10b',
  'TransCom 11: Europe' = 'T11',
  'TransCom 12: North Pacific Temperate' = 'T12',
  'TransCom 13: West Pacific Tropical' = 'T13',
  'TransCom 14: East Pacific Tropical' = 'T14',
  'TransCom 15: South Pacific Temperate' = 'T15',
  'TransCom 16: Northern Ocean' = 'T16',
  'TransCom 17: North Atlantic Temperate' = 'T17',
  'TransCom 18: Atlantic Tropical' = 'T18',
  'TransCom 19: South Atlantic Temperate' = 'T19',
  'TransCom 20: Southern Ocean' = 'T20',
  'TransCom 21: Indian Tropical' = 'T21',
  'TransCom 22: South Indian Temperate' = 'T22'
)

REGION_NAMES <- names(REGION_NAME_TO_CODE)
REGION_CODES <- REGION_NAME_TO_CODE

REGION_CODE_TO_NAME <- REGION_NAMES
names(REGION_CODE_TO_NAME) <- REGION_CODES

OCEAN_REGION_CODES <- tail(REGION_CODES, 11)

MODEL_TO_MODEL_DISPLAY_NAME <- c(
  'TM54DVAR' = 'TM5-4DVAR',
  'OU' = 'OU',
  'CT' = 'CT',
  'CMS' = 'CMS-Flux',
  'Schuh' = 'CSU',
  'Deng' = 'UT',
  'Chevallier' = 'CAMS',
  'Baker_Mean' = 'Baker-mean',
  'UoE' = 'UoE'
)

MODELS <- MODEL_TO_MODEL_DISPLAY_NAME

MODEL_COLOURS <- c(
  '#c086f8',
  '#939ff7',
  '#62b4dd',
  '#83eac5',
  '#bef4a9',
  '#fffa90',
  '#f6c289',
  '#b97270',
  '#f781bf',
  '#999999' # Special weight for climatology
)
MODEL_SCALES <- list(
  fill = scale_fill_manual(values = MODEL_COLOURS),
  colour = scale_colour_manual(values = MODEL_COLOURS),
  colour_darker = scale_colour_manual(values = colorspace::darken(MODEL_COLOURS))
)
