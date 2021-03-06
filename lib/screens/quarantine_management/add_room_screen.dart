import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:qlkcl/components/bot_toast.dart';
import 'package:qlkcl/components/input.dart';
import 'package:qlkcl/helper/dismiss_keyboard.dart';
import 'package:qlkcl/helper/validation.dart';
import 'package:qlkcl/models/building.dart';
import 'package:qlkcl/models/floor.dart';
import 'package:qlkcl/models/quarantine.dart';
import 'package:qlkcl/models/room.dart';
import 'package:qlkcl/utils/data_form.dart';

import 'component/general_info_floor.dart';

class AddRoomScreen extends StatefulWidget {
  static const String routeName = "/add-room";
  final Building? currentBuilding;
  final Quarantine? currentQuarantine;
  final Floor? currentFloor;

  const AddRoomScreen({
    Key? key,
    this.currentBuilding,
    this.currentQuarantine,
    this.currentFloor,
  }) : super(key: key);

  @override
  _AddRoomScreenState createState() => _AddRoomScreenState();
}

class _AddRoomScreenState extends State<AddRoomScreen> {
  late Future<dynamic> futureRoomList;

  @override
  void initState() {
    super.initState();
    futureRoomList =
        fetchNumOfRoom({'quarantine_floor': widget.currentFloor!.id});

    myController.addListener(_updateLatestValue);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    // This also removes the _printLatestValue listener.
    myController.dispose();
    super.dispose();
  }

  //Input Controller
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final capacityController = TextEditingController();

  //Submit
  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (addMultiple == true) {
        nameController.text = nameList.join(",");
        capacityController.text = capacityList.join(",");
      }
      final CancelFunc cancel = showLoading();
      final response = await createRoom(createRoomDataForm(
        name: nameController.text,
        quarantineFloor: widget.currentFloor!.id,
        capacity: capacityController.text,
      ));
      cancel();
      showNotification(response);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  bool addMultiple = false;
  int numOfAddedRoom = 1;
  List<String> nameList = [];
  List<String> capacityList = [];

  final myController = TextEditingController();

  int maxNum = 25;

  void _updateLatestValue() {
    setState(() {
      numOfAddedRoom = min(int.tryParse(myController.text) ?? 1, maxNum);
      nameList = []..length = numOfAddedRoom;
      capacityList = []..length = numOfAddedRoom;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: const Text('Th??m ph??ng'),
      centerTitle: true,
    );

    return DismissKeyboard(
      child: Scaffold(
        appBar: appBar,
        body: SingleChildScrollView(
          child: FutureBuilder<dynamic>(
            future: futureRoomList,
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
                        child: GeneralInfoFloor(
                          currentBuilding: widget.currentBuilding!,
                          currentQuarantine: widget.currentQuarantine!,
                          currentFloor: widget.currentFloor!,
                          numOfRoom: snapshot.data,
                        ),
                      ),
                      SingleChildScrollView(
                        physics: const ScrollPhysics(),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            constraints: const BoxConstraints(
                                minWidth: 100, maxWidth: 800),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Add multiple floors
                                  Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(6, 0, 0, 0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 35,
                                          child: ListTileTheme(
                                            contentPadding: EdgeInsets.zero,
                                            child: CheckboxListTile(
                                              title: const Text(
                                                  "Th??m nhi???u ph??ng"),
                                              controlAffinity:
                                                  ListTileControlAffinity
                                                      .leading,
                                              value: addMultiple,
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  addMultiple = value!;
                                                  nameController.text = "";
                                                  capacityController.text = "";
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                        // insert number of floor
                                        if (addMultiple)
                                          Expanded(
                                            flex: 65,
                                            child: Input(
                                              label: 'S??? ph??ng',
                                              hint: 'S??? ph??ng',
                                              type: TextInputType.number,
                                              required: true,
                                              controller: myController,
                                              validatorFunction:
                                                  (String? value) {
                                                return maxNumberValidator(
                                                    value, maxNum);
                                              },
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: const Text(
                                      'Ch???nh s???a th??ng tin ph??ng',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  if (addMultiple)
                                    ListView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemBuilder: (ctx, index) {
                                        return Row(
                                          children: [
                                            Expanded(
                                              flex: 55,
                                              child: Input(
                                                label: 'T??n ph??ng',
                                                hint: 'T??n ph??ng',
                                                required: true,
                                                onChangedFunction: (text) {
                                                  nameList[index] = text;
                                                },
                                                margin:
                                                    const EdgeInsets.fromLTRB(
                                                        16, 16, 8, 0),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 45,
                                              child: Input(
                                                label: 'S??? ng?????i t???i ??a',
                                                hint: 'S??? ng?????i t???i ??a',
                                                required: true,
                                                type: TextInputType.number,
                                                onChangedFunction: (text) {
                                                  capacityList[index] = text;
                                                },
                                                margin:
                                                    const EdgeInsets.fromLTRB(
                                                        8, 16, 16, 0),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                      itemCount: numOfAddedRoom,
                                    )
                                  else
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 55,
                                          child: Input(
                                            label: 'T??n ph??ng',
                                            hint: 'T??n ph??ng',
                                            required: true,
                                            controller: nameController,
                                            margin: const EdgeInsets.fromLTRB(
                                                16, 16, 8, 0),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 45,
                                          child: Input(
                                            label: 'S??? ng?????i t???i ??a',
                                            hint: 'S??? ng?????i t???i ??a',
                                            required: true,
                                            type: TextInputType.number,
                                            controller: capacityController,
                                            margin: const EdgeInsets.fromLTRB(
                                                8, 16, 16, 0),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
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
                              child: const Text("X??c nh???n"),
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
                    'Kh??ng c?? d??? li???u',
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
