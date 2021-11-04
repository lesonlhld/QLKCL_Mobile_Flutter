String? Function(String?) phoneValidator = (phone) {
  String patttern = r'(^[0-9]{10}$)';
  RegExp regExp = new RegExp(patttern);
  if (phone == null || phone.isEmpty) {
    return 'Số điện thoại không được để trống';
  } else if (phone.length != 10) {
    return 'Số điện thoại phải là 10 số';
  } else if (!regExp.hasMatch(phone)) {
    return 'Số điện thoại không hợp lệ';
  }

  return null;
};

String? Function(String?) passValidator = (pass) {
  if (pass == null || pass.isEmpty) {
    return 'Mật khẩu không được để trống';
  } else if (pass.length < 6) {
    return 'Mật khẩu chứa tối thiểu 6 ký tự';
  }

  return null;
};

String? Function(String?) emailValidator = (email) {
  String patttern = r'^[a-zA-Z0-9](([.]{1}|[_]{1}|[-]{1}|[+]{1})?[a-zA-Z0-9])*[@]([a-z0-9]+([.]{1}|-)?)*[a-zA-Z0-9]+[.]{1}[a-z]{2,253}$';
  RegExp regExp = new RegExp(patttern);
  if (email == null || email.isEmpty) {
    return 'Email không được để trống';
  } else if (!regExp.hasMatch(email)) {
    return 'Email không hợp lệ';
  }

  return null;
};
