import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:qlkcl/components/bot_toast.dart';
import 'package:qlkcl/helper/dismiss_keyboard.dart';
import 'package:qlkcl/models/building.dart';
import 'package:qlkcl/models/floor.dart';
import 'package:qlkcl/models/quarantine.dart';
import 'package:qlkcl/networking/response.dart';
import 'package:qlkcl/screens/quarantine_management/component/general_info_building.dart';
import 'package:qlkcl/utils/data_form.dart';
import '../../components/input.dart';

class EditBuildingScreen extends StatefulWidget {
  final Building? currentBuilding;
  final Quarantine? currentQuarantine;
  const EditBuildingScreen({
    Key? key,
    this.currentBuilding,
    this.currentQuarantine,
  }) : super(key: key);
  static const routeName = '/editing-building';

  @override
  _EditBuildingScreenState createState() => _EditBuildingScreenState();
}

class _EditBuildingScreenState extends State<EditBuildingScreen> {
  late Future<int> numOfFloor;
  //Input Controller
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    numOfFloor = fetchNumOfFloor(
        {'quarantine_building_id_list': widget.currentBuilding!.id});
    nameController.text = widget.currentBuilding!.name;
  }

  //Submit
  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final CancelFunc cancel = showLoading();
      final response = await updateBuilding(updateBuildingDataForm(
        name: nameController.text,
        id: widget.currentBuilding!.id,
      ));

      cancel();
      showNotification(response);
      if (response.status == Status.success) {
        if (mounted) {
          Navigator.of(context).pop(response.data);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: const Text('Sửa thông tin tòa'),
      centerTitle: true,
    );
    return DismissKeyboard(
      child: Scaffold(
        appBar: appBar,
        body: SingleChildScrollView(
          child: FutureBuilder<dynamic>(
            future: numOfFloor,
            builder: (context, snapshot) {
              showLoading();
              if (snapshot.connectionState == ConnectionState.done) {
                BotToast.closeAllLoading();
                if (snapshot.hasData) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: (MediaQuery.of(context).size.height -
                                appBar.preferredSize.height -
                                MediaQuery.of(context).padding.top) *
                            0.25,
                        child: GeneralInfoBuilding(
                          currentQuarantine: widget.currentQuarantine!,
                          currentBuilding: widget.currentBuilding!,
                          numberOfFloor: snapshot.data,
                        ),
                      ),
                      SingleChildScrollView(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            constraints: const BoxConstraints(
                                minWidth: 100, maxWidth: 800),
                            child: Form(
                              key: _formKey,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Input(
                                  label: 'Tên tòa mới',
                                  hint: 'Tên tòa mới',
                                  controller: nameController,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Spacer(),
                            ElevatedButton(
                              onPressed: _submit,
                              child: const Text("Xác nhận"),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return const Text('Snapshot has error');
                } else {
                  return const Text(
                    'Không có dữ liệu',
                    textAlign: TextAlign.center,
                  );
                }
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }
}
