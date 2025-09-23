
class GlucoseProfileConfiguration {
  static List<String> accuCheckAvivaConnect = ['483','484','497','498','499','500','502','685'];
  static List<String> accuCheckPerformaConnect = ['479','501','503','765'];
  static List<String> accuCheckGuide = ['912','922','923','925','926','929','930','932'];
  static List<String> accuCheckInstant = ['958','959','960','961','963','964','965'];
  static List<String> accuCheckGuideMe = ['897','898','901','902','903','904','905'];
  static List<String> accuCheckInstant2 = ['972','973','975','976','977','978','979','980'];
  static List<String> accuCheckInstantS = ['966','967','968','969','970','971'];
  static const Map<String,List<String>> rocheModels = {
    'Accu-Chek Aviva Connect' : ['483','484','497','498','499','500','502','685'],
    'Accu-Chek Performa Connect' : ['479','501','503','765'],
    'Accu-Chek Guide' : ['912','922','923','925','926','929','930','932'],
    'Accu-Chek Instant' : ['958','959','960','961','963','964','965','972','973','975','976','977','978','979','980'],
    'Accu-Chek Guide Me' : ['897','898','901','902','903','904','905'],
    'Accu-Chek Instant S' : ['966','967','968','969','970','971'],
  };
  static List<String> mgPerDLModels = [
    '483',
    '498',
    '502',
    '685',
    '503',
    '765',
    '921',
    '923',
    '925',
    '926',
    '958',
    '960',
    '963',
    '897',
    '901',
    '903',
    '905',
    '975',
    '979',
    '966',
    '968',
    '972'
  ];

  static List<String> mmolPerLModels = [
    '484',
    '497',
    '499',
    '500',
    '479',
    '501',
    '922',
    '929',
    '930',
    '932',
    '959',
    '961',
    '964',
    '965',
    '898',
    '902',
    '904',
    '973',
    '977',
    '978',
    '980',
    '967',
    '969',
    '970',
    '971',
    '976',
  ];

  static int FORMAT_UINT8 = 17;
  static int FORMAT_UINT16 = 18;
  static String GLUCOSE_SERVICE_UUID = '00001808-0000-1000-8000-00805f9b34fb';
  static String ROCHE_SERVICE_UUID = '0000180a-0000-1000-8000-00805f9b34fb';

  static String DEVICE_BATTERY_CHARACTERISTIC_UUID =
      '0000180F-0000-1000-8000-00805f9b34fb';
  static String GLUCOSE_MEASUREMENT_CHARACTERISTIC_UUID =
      '00002a18-0000-1000-8000-00805f9b34fb';
  static String GLUCOSE_FEATURE_CHARACTERISTIC_UUID =
      '00002a51-0000-1000-8000-00805f9b34fb';
  static String GLUCOSE_MEASUREMENT_CONTEXT_CHARACTERISTIC_UUID =
      '00002a34-0000-1000-8000-00805f9b34fb';
  static String RECORD_ACCESS_CONTROL_POINT_CHARACTERISTIC_UUID =
      '00002a52-0000-1000-8000-00805f9b34fb';
  static String CLIENT_CHARACTERISTICS_CONFIGURATION_DESCRIPTOR =
      '00002902-0000-1000-8000-00805f9b34fb';
  static String MODEL_NUMBER_STRING_UUID =
      '00002a24-0000-1000-8000-00805f9b34fb';

  static const OP_CODE_REPORT_STORED_RECORDS = 1;
  static const OP_CODE_DELETE_STORED_RECORDS = 2;
  static const OP_CODE_ABORT_OPERATION = 3;
  static const OP_CODE_REPORT_NUMBER_OF_RECORDS = 4;
  static const OP_CODE_NUMBER_OF_STORED_RECORDS_RESPONSE = 5;
  static const OP_CODE_RESPONSE_CODE = 6;

  static const OPERATOR_NULL = 0;
  static const OPERATOR_ALL_RECORDS = 1;
  static const OPERATOR_LESS_THEN_OR_EQUAL = 2;
  static const OPERATOR_GREATER_THEN_OR_EQUAL = 3;
  static const OPERATOR_WITHING_RANGE = 4;
  static const OPERATOR_FIRST_RECORD = 5;
  static const OPERATOR_LAST_RECORD = 6;

  static const FILTER_TYPE_NULL = 0;
  static const FILTER_TYPE_SEQUENCE_NUMBER = 1;
  static const FILTER_TYPE_USER_FACING_TIME = 2;

  static const RESPONSE_SUCCESS = 1;
  static const RESPONSE_OP_CODE_NOT_SUPPORTED = 2;
  static const RESPONSE_INVALID_OPERATOR = 3;
  static const RESPONSE_OPERATOR_NOT_SUPPORTED = 4;
  static const RESPONSE_INVALID_OPERAND = 5;
  static const RESPONSE_NO_RECORDS_FOUND = 6;
  static const RESPONSE_ABORT_UNSUCCESSFUL = 7;
  static const RESPONSE_PROCEDURE_NOT_COMPLETED = 8;
  static const RESPONSE_OPERAND_NOT_SUPPORTED = 9;
}
