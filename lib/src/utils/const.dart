class Const {
  static const String ENVIRONMENT_DEFAULT = "staging"; //product or staging or dev

  static const String IS_DOMAIN = "is.diab.com.vn";
  static const String IS_DOMAIN_STAGING = "is.staging.diab.com.vn";
  static const String IS_DOMAIN_DEV = "is.dev.diab.vn";

  // static const String DOMAIN = "api.preprod.diab.com.vn";
  static const String DOMAIN = "api.diab.com.vn";
  static const String DOMAIN_STAGING = "api.staging.diab.com.vn";
  static const String DOMAIN_DEV = "api.dev.diab.vn";

  static const String HOST_URL = "https://$DOMAIN/";
  static const String HOST_URL_STAGING = "https://$DOMAIN_STAGING/";
  static const String HOST_URL_DEV = "https://$DOMAIN_DEV/";

  static const String DOCOSAN_DOMAIN = "api.docosan.com";
  static const String DOCOSAN_DOMAIN_STAGING = "api.staging.docosan.com";

  static const String HOST_DOCOSAN_URL = "https://$DOCOSAN_DOMAIN/";
  static const String HOST_DOCOSAN_URL_STAGING = "https://$DOCOSAN_DOMAIN_STAGING/";

  // ignore: non_constant_identifier_names
  static String API_URL = "${HOST_URL}api/";

  static double mmollToMgdlFactor = 18.018;

  static const String HOST_GOOGLE_MAP_URL =
      "https://maps.googleapis.com/maps/api/";
  static const String ANDROID_KEY = "AIzaSyAVRrZKBfIphjlPiua9y5Pk4CJ3oaddGp0";
  static const String IOS_KEY = "AIzaSyB6P1Tq9lnnZPjkUJmAlTjUE1uqMVfTLFA";
  static const String PLACE_KEY = "AIzaSyC7tPpmwviNXdX0_krWw5QdxOVGOJgdFmo";

  static const String CLIENT_ID = "4A293E78-4513-4DAF-958E-A04F93978332";
  static const String CLIENT_SECRET =
      "oTxBinRm9NpNen3rs++jN9sWXvOkya60nuffhv6x304=";

  static const String DEFAULT_BG_COACH =
      "https://img.freepik.com/free-photo/beautiful-young-female-doctor-looking-camera-office_1301-7807.jpg";
  static const String ID = "ID";
  static const String CODE = "Code";
  static const String NAME = "Name";
  static const String FULL_NAME = "Full Name";
  static const String LAST_NAME = "Last Name";
  static const String ADDRESS = "Address";
  static const String CITY = "City";
  static const String DISTRICT = "District";
  static const String PACKAGE_CODE = "package_code";
  static const String EMAIL = "Email";
  static const String AVATAR = "Avatar";
  static const String POINT = "POINT";
  static const String INTRODUCE = "INTRODUCE";
  static const String URL = "Url";
  static const String REFRESH = "Refresh";
  static const String REFRESH_TOKEN = "refresh_token";
  static const String TOKEN = "token";
  static const String ENVIRONMENT = "environment";
  static const String PHONE = "Phone";
  static const String CITY_ID = "CITY_ID";
  static const String CITY_NAME = "CITY_NAME";
  static const String DISTRICT_ID = "DISTRICT_ID";
  static const String DISTRICT_NAME = "DISTRICT_NAME";
  static const String WARD_ID = "WARD_ID";
  static const String WARD_NAME = "WARD_NAME";
  static const String SHIPPING_NAME = "SHIPPING_NAME";
  static const String SHIPPING_PHONE = "SHIPPING_PHONE";
  static const String SHIPPING_ADDRESS = "SHIPPING_ADDRESS";
  static const String SHIPPING_ADDRESS_2 = "SHIPPING_ADDRESS_2";
  static const String REFERENCE_CODE = "REFERENCE_CODE";
  static const String DEVICE_TOKEN = "Device Token";
  static const String LOCALE = "LOCALE";
  static const String DATE_TIME_FORMAT = "dd/MM/yyyy HH:mm:ss";
  static const String DATE_TIME_SV_FORMAT = "MM/dd/yyyy HH:mm:ss";
  static const String DATE_TIME_CREATE_SV_FORMAT = "yyyy-MM-dd HH:mm:ss";
  static const String DATE_REQUEST_FORMAT = "MM-dd-yyyy";
  static const String DATE_FORMAT = "dd/MM/yyyy";
  static const String FULL_DATE_FORMAT = "EEEE, dd/MM/yyyy";
  static const String DATE_FORMAT_TASK = "yyyy-MM-dd";
  static const String DATE_FORMAT_POST = "HH:mm dd/MM/yyyy";
  static const String DATE = "EEE";
  static const String DAY = "dd";
  static const String YEAR = "yyyy";
  static const String HOUR_MIN = "hh:mm";
  static const String TIME = "hh:mm aa";
  static const String NIPRO_DEVICES = "nipro_devices";

  static const String key_app_language = "AppLanguage";

  static const String HIDE_OVERLAY_KEY = "HideOverlayKey";

  static const int TYPE_WEB = 0;
  static const int TYPE_EMAIL = 1;
  static const int TYPE_PHONE = 2;
  static const int TYPE_SMS = 3;

  static const int SPLASH_SCREEN = 0;
  static const int AUTHENTICATION_SCREEN = 1;
  static const int LOGIN_SCREEN = 2;
  static const int SIGN_UP_SCREEN = 3;
  static const int MAIN_SCREEN = 3;

  static const int HOME_SCREEN = 0;
  static const int PLAN_SCREEN = 1;
  static const int COURSE_SCREEN = 2;
  static const int ACCOUNT_SCREEN = 3;

  static const int DEFAULT_SIZE = 10;

  static const int maxMedia = 5;

  static const int LESSON_NOT_LEARN = 0;
  static const int LESSON_LEARNT = 1;
  static const int LESSON_LEARNING = 2;
  static const int LESSON_LOCKED = 3;
  static const int LESSON_CAN_NOT_LEARN = 4;

  static const int JOB_TYPE = 12;
  static const int EDUCATION_LEVEL_TYPE = 13;
  static const int LEVEL_OF_DIABETES_TYPE = 10;
  static const int PERSONALITY_TYPE = 1;
  static const int CONSCIOUSNESS_PRATICE_TYPE = 4;
  static const int VEGETERIAN_TYPE = 8;
  static const int WORKING_HOURS_TYPE = 9;
  static const int INTERESTS_TYPE = 2;
  static const int LESSON_TAG_TYPE = 0;

  static const int LESSON_SECTION_TYPE_VIDEO = 1;
  static const int LESSON_SECTION_TYPE_AUDIO = 2;
  static const int LESSON_SECTION_TYPE_TEXT = 3;
  static const int LESSON_SECTION_TYPE_QUIZ = 4;

  static const String EN = "en";
  static const String VI = "vi";

  static const String STUDENT_ID = 'Student ID';

  static const String MALE = 'male';
  static const String FEMALE = 'female';
  static const List<String> GENDER = [MALE, FEMALE];

  static const String VIETNAM = 'Việt Nam';
  static const String HANOI = 'Hà Nội';

  static const String PARENT = 'parent';
  static const String GUARDIAN = 'guardian';

  static const String TEMPLATE_NONE = 'NONE';
  static const String TEMPLATE_D = 'D';
  static const String TEMPLATE_OP = 'OP';
  static const String TEMPLATE_A1 = 'A1';
  static const String TEMPLATE_A2 = 'A2';
  static const String TEMPLATE_B = 'B';
  static const String TEMPLATE_K = 'K';
  static const String TEMPLATE_FGHI = 'FGHI';

  static const String BREAKFAST = 'Sáng';
  static const String LUNCH = 'Trưa';
  static const String DINNER = 'Tối';
  static const String SUBMEAL = 'Nhẹ';

  static const String NAVIGATE_HOME_TAB = 'Navigate_to_home_tab';
  static const String NAVIGATE_TO_MY_PLAN_TAB = 'Navigate_to_my_plan_tab';
  static const String NAVIGATE_TO_ACTIVITY_TAB = 'Navigate_to_activity_tab';
  static const String NAVIGATE_TO_LESSON_TAB = 'Navigate_to_lesson_tab';
  static const String NAVIGATE_TO_EXERCISE_TAB = 'Navigate_to_exercise_tab';
  static const String NAVIGATE_TO_PROFILE_TAB = 'Navigate_to_profile_tab';
  static const String NAVIGATE_TO_LESSON_DETAIL = 'Navigate_to_lesson_detail';
  static const String NAVIGATE_TO_REGISTER = 'Navigate_to_register';
  static const String NAVIGATE_TO_ACTIVITY_DETAIL =
      'Navigate_to_activity_detail';
  static const String LANGUAGE_CHANGED = 'language_changed';

  static const List<int> hourList = [
    0,
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    16,
    17,
    18,
    19,
    20,
    21,
    22,
  ];
  static const List<int> minuteList = [0, 15, 30, 45];
  static const String HOTLINE_NUMBER = '0931888832';
  static const String ZALO_OA_TECHNICAL_SUPPORT_LINK =
      'https://zalo.me/4592543430802584018';
  static const int MAX_DAY_RANGE_PRIMARY_SCREENING = 14;
  static const DOCOSAN_TOKEN = 'docosan_token';
  static const int MAX_DAY_RANGE_DSMES_BOOKING = 30;
  static const String CLICKED_BRANCH_LINK = 'clicked_branch_link';
  static const String ORGANIZATION_API_KEY = 'organization_api_key';
}
