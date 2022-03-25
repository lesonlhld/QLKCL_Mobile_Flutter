import 'package:qlkcl/models/key_value.dart';

enum Permission {
  add,
  edit,
  view,
  delete,
  change_status,
}

List<KeyValue> genderList = [
  KeyValue(id: "MALE", name: "Nam"),
  KeyValue(id: "FEMALE", name: "Nữ")
];

List<KeyValue> testStateList = [
  KeyValue(id: "WAITING", name: "Đang chờ kết quả"),
  KeyValue(id: "DONE", name: "Đã có kết quả")
];

List<KeyValue> testTypeList = [
  KeyValue(id: "QUICK", name: "Test nhanh"),
  KeyValue(id: "RT-PCR", name: "Real time PCR")
];

List<KeyValue> testValueList = [
  KeyValue(id: "NONE", name: "Chưa có kết quả"),
  KeyValue(id: "NEGATIVE", name: "Âm tính"),
  KeyValue(id: "POSITIVE", name: "Dương tính")
];

List<KeyValue> testValueWithBoolList = [
  KeyValue(id: "Null", name: "Chưa có kết quả"),
  KeyValue(id: "False", name: "Âm tính"),
  KeyValue(id: "True", name: "Dương tính")
];

List<KeyValue> medDeclValueList = [
  KeyValue(id: "NORMAL", name: "Bình thường"),
  KeyValue(id: "UNWELL", name: "Có dấu hiệu nghi nhiễm"),
  KeyValue(id: "SERIOUS", name: "Nghi nhiễm")
];

List<KeyValue> roleList = [
  KeyValue(id: "1", name: "ADMINISTRATOR"),
  KeyValue(id: "2", name: "SUPER_MANAGER"),
  KeyValue(id: "3", name: "MANAGER"),
  KeyValue(id: "4", name: "STAFF"),
  KeyValue(id: "5", name: "MEMBER"),
];

List<KeyValue> nationalityList = [
  KeyValue(id: 1, name: 'Việt Nam'),
];

List<KeyValue> backgroundDiseaseList = [
  KeyValue(id: 1, name: "Tiểu đường"),
  KeyValue(id: 2, name: "Ung thư"),
  KeyValue(id: 3, name: "Tăng huyết áp"),
  KeyValue(id: 4, name: "Bệnh hen suyễn"),
  KeyValue(id: 5, name: "Bệnh gan"),
  KeyValue(id: 6, name: "Bệnh thận mãn tính"),
  KeyValue(id: 7, name: "Tim mạch"),
  KeyValue(id: 8, name: "Bệnh lý mạch máu não"),
];

List<KeyValue> quarantineStatusList = [
  KeyValue(id: "RUNNING", name: "Đang hoạt động"),
  KeyValue(id: "LOCKED", name: "Khóa"),
  KeyValue(id: "UNKNOWN", name: "Chưa rõ"),
];

List<KeyValue> quarantineTypeList = [
  KeyValue(id: "CONCENTRATE", name: "Tập trung"),
  KeyValue(id: "PRIVATE", name: "Tư nhân"),
];

List<KeyValue> symptomMainList = [
  KeyValue(id: 1, name: "Ho ra máu"),
  KeyValue(id: 2, name: "Thở dốc, khó thở"),
  KeyValue(id: 3, name: "Đau tức ngực kéo dài"),
  KeyValue(id: 4, name: "Lơ mơ, không tỉnh táo"),
];

List<KeyValue> symptomExtraList = [
  KeyValue(id: 5, name: "Mệt mỏi"),
  KeyValue(id: 6, name: "Ho"),
  KeyValue(id: 7, name: "Ho có đờm"),
  KeyValue(id: 8, name: "Đau họng"),
  KeyValue(id: 9, name: "Đau đầu"),
  KeyValue(id: 10, name: "Chóng mặt"),
  KeyValue(id: 11, name: "Chán ăn"),
  KeyValue(id: 12, name: "Nôn / Buồn nôn"),
  KeyValue(id: 13, name: "Tiêu chảy"),
  KeyValue(id: 14, name: "Xuất huyết ngoài da"),
  KeyValue(id: 15, name: "Nổi ban ngoài da"),
  KeyValue(id: 16, name: "Ớn lạnh / gai rét"),
  KeyValue(id: 17, name: "Viêm kết mạc (mắt đỏ)"),
  KeyValue(id: 18, name: "Mất vị giác, khứu giác"),
  KeyValue(id: 19, name: "Đau nhức cơ"),
];

List<KeyValue> labelList = [
  KeyValue(id: "F0", name: "F0"),
  KeyValue(id: "F1", name: "F1"),
  KeyValue(id: "F2", name: "F2"),
  KeyValue(id: "F3", name: "F3"),
  KeyValue(id: "ABROAD", name: "Nhập cảnh"),
  KeyValue(id: "FROM_EPIDEMIC_AREA", name: "Về từ vùng dịch"),
];

const int PAGE_SIZE = 10;
const int PAGE_SIZE_MAX = 0;
const int ROWS_PER_PAGE = 10;

const String OneSignalId = "3def0255-600c-4376-bece-77202ef908e5";

const double maxMobileSize = 480;
const double maxTabletSize = 768;
const double minDesktopSize = 1200;
