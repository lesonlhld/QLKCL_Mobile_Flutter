class Api {
  static const String baseUrl = 'https://qlkcl.herokuapp.com';

  static const String login = '/api/token';
  static const String register = '/api/user/member/register';

  static const String getMember = '/api/user/member/get';
  static const String getMemberByPhone = '/api/user/member/get_by_phone_number';
  static const String getListMembers = '/api/user/member/filter';
  static const String createMember = '/api/user/member/create';
  static const String updateMember = '/api/user/member/update';
  static const String denyMember = '/api/user/member/refuse';
  static const String acceptOneMember = '/api/user/member/accept_one';
  static const String acceptManyMember = '/api/user/member/accept_many';
  static const String finishMember = '/api/user/member/finish_quarantine';
  static const String changeRoomMember =
      '/api/user/member/change_quarantine_ward_and_room';
  static const String getSuitableRoom = '/api/user/member/get_suitable_room';
  static const String getMemberTimeline = '/api/user/member/get_timeline';

  static const String homeManager = '/api/user/home/manager';
  static const String homeMember = '/api/user/home/member';
  static const String getAddressWithMembersPassBy =
      '/api/user/home/filter_address_with_num_of_members_pass_by';

  static const String getListTests = '/api/form/test/filter';
  static const String createTest = '/api/form/test/create';
  static const String updateTest = '/api/form/test/update';
  static const String getTest = '/api/form/test/get';
  static const String createManyTests = '/api/form/test/create_many';

  static const String getListCountry = '/api/address/country/filter';
  static const String getListCity = '/api/address/city/filter';
  static const String getListDistrict = '/api/address/district/filter';
  static const String getListWard = '/api/address/ward/filter';

  static const String requestOtp = '/api/oauth/reset_password/set';
  static const String sendOtp = '/api/oauth/reset_password/otp';
  static const String createPass = '/api/oauth/reset_password/confirm';
  static const String changePass = '/api/oauth/change_password/confirm';
  static const String resetPass =
      '/api/oauth/reset_password/manager_reset_member';

  static const String getQuarantine = '/api/quarantine_ward/ward/get';
  static const String createQuarantine = '/api/quarantine_ward/ward/create';
  static const String updateQuarantine = '/api/quarantine_ward/ward/update';
  static const String getListQuarantine = '/api/quarantine_ward/ward/filter';
  static const String getListQuarantineNoToken =
      '/api/quarantine_ward/ward/filter_register';

  static const String getBuilding = '/api/quarantine_ward/building/get';
  static const String createBuilding = '/api/quarantine_ward/building/create';
  static const String updateBuilding = '/api/quarantine_ward/building/update';
  static const String deleteBuilding = '/api/quarantine_ward/building/delete';
  static const String getListBuilding = '/api/quarantine_ward/building/filter';

  static const String getFloor = '/api/quarantine_ward/floor/get';
  static const String createFloor = '/api/quarantine_ward/floor/create';
  static const String updateFloor = '/api/quarantine_ward/floor/update';
  static const String deleteFloor = '/api/quarantine_ward/floor/delete';
  static const String getListFloor = '/api/quarantine_ward/floor/filter';

  static const String getRoom = '/api/quarantine_ward/room/get';
  static const String createRoom = '/api/quarantine_ward/room/create';
  static const String updateRoom = '/api/quarantine_ward/room/update';
  static const String deleteRoom = '/api/quarantine_ward/room/delete';
  static const String getListRoom = '/api/quarantine_ward/room/filter';

  static const String filterMedDecl = '/api/form/medical-declaration/filter';
  static const String getMedDecl = '/api/form/medical-declaration/get';
  static const String createMedDecl = '/api/form/medical-declaration/create';
  static const String getHealthInfo =
      '/api/form/medical-declaration/get_health_info_of_user';

  static const String getListNotMem = '/api/user/member/not_member_filter';

  static const String filterUserNotification =
      '/api/notification/user_notification/filter';
  static const String getUserNotification =
      '/api/notification/user_notification/get';
  static const String changeStateUserNotification =
      '/api/notification/user_notification/change_status';
  static const String deleteUserNotification =
      '/api/notification/user_notification/delete';
  static const String createNotification =
      '/api/notification/notification/create_all';

  static const String getVaccineDose = '/api/form/vaccine_dose/get';
  static const String filterVaccineDose = '/api/form/vaccine_dose/filter';
  static const String createVaccineDose = '/api/form/vaccine_dose/create';
  static const String filterVaccine = '/api/form/vaccine/filter';

  static const String filterDestiantionHistory =
      '/api/user/destination_history/filter';
  static const String getDestiantionHistory =
      '/api/user/destination_history/get';
  static const String createDestiantionHistory =
      '/api/user/destination_history/create';
  static const String updateDestiantionHistory =
      '/api/user/destination_history/update';

  static const String filterQuarantineHistory =
      '/api/user/quarantine_history/filter';

  static const String createManager = '/api/user/manager/create';
  static const String updateManager = '/api/user/manager/update';

  static const String createStaff = '/api/user/staff/create';
  static const String updateStaff = '/api/user/staff/update';

  static const String filterStaff = '/api/user/staff/filter';
  static const String filterManager = '/api/user/manager/filter';

  static const String filterPandemic = '/api/form/pandemic/filter';

  static const String importMember = '/api/user/member/create_by_file';

  static const String memberCallRequarantine =
      '/api/user/member/member_call_requarantine';
  static const String managerCallRequarantine =
      '/api/user/member/manager_call_requarantine';

  static const String importTest = '/api/form/test/create_by_file';

  static const String filterProfessional = '/api/user/professional/filter';

  static const String hospitalize = '/api/user/member/hospitalize';
}
