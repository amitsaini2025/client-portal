import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/personal_information/basic_information.dart';
import '../../../../models/personal_information/email.dart';
import '../../../../models/personal_information/phone.dart';
import '../../../../services/api_service.dart';

class BasicPersonalInformationWidget extends StatefulWidget {
  final BasicInformation? basicInfo;
  final List<Phone>? phones;
  final List<Email>? emails;

  const BasicPersonalInformationWidget({
    super.key,
    this.basicInfo,
    this.phones,
    this.emails,
  });

  @override
  State<BasicPersonalInformationWidget> createState() =>
      _BasicPersonalInformationWidgetState();
}

class _BasicPersonalInformationWidgetState
    extends State<BasicPersonalInformationWidget> {
  // Basic info controllers
  late TextEditingController firstNameCtrl;
  late TextEditingController lastNameCtrl;
  late TextEditingController dobCtrl;

  String genderValue = "";
  String maritalStatusValue = "";

  bool isEditingBasic = false;
  bool isEditingPhones = false;

  // Phone list & controllers
  final List<TextEditingController> phoneControllers = [];
  final List<Phone> phoneList = [];

  // Dropdown options
  final List<String> genderOptions = ["Male", "Female", "Other"];
  final List<String> maritalStatusOptions = [
    "Single",
    "Married",
    "De Facto",
    "Separated",
    "Divorced",
    "Widowed"
  ];

  @override
  void initState() {
    super.initState();
    final basic = widget.basicInfo;
    String first = "", last = "";
    if (basic?.fullName != null) {
      final parts = basic!.fullName!.split(" ");
      first = parts.first;
      last = parts.length > 1 ? parts.sublist(1).join(" ") : "";
    }
    firstNameCtrl = TextEditingController(text: first);
    lastNameCtrl = TextEditingController(text: last);
    dobCtrl = TextEditingController(text: basic?.dateOfBirth ?? "");
    genderValue = basic?.gender ?? "";
    maritalStatusValue = basic?.maritalStatus ?? "";

    if (widget.phones != null) {
      phoneList.addAll(widget.phones!);
      for (var p in phoneList) {
        phoneControllers.add(TextEditingController(
            text: "${p.countryCode ?? ''} ${p.phone ?? ''}"));
      }
    }
  }

  // ======== DOB Picker ========
  Future<void> _pickDOB() async {
    DateTime initial;
    try {
      final parts = dobCtrl.text.split('/');
      initial = DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
    } catch (_) {
      initial = DateTime.now().subtract(const Duration(days: 365 * 20));
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      dobCtrl.text = DateFormat("dd/MM/yyyy").format(picked);
    }
  }

  // ======== Save Basic Info ========
  Future<void> _saveBasicInfo() async {
    try {
      final res = await ApiService.updateClientBasicDetail(
        firstName: firstNameCtrl.text,
        lastName: lastNameCtrl.text,
        dob: dobCtrl.text,
        gender: genderValue,
        maritalStatus: maritalStatusValue,
      );

      if (res["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Basic Info Updated Successfully!")),
        );
        setState(() => isEditingBasic = false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res["message"] ?? "Update failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // ======== Save Phone Numbers ========
  Future<void> _savePhones() async {
    List<Map<String, dynamic>> payload = [];
    for (int i = 0; i < phoneList.length; i++) {
      final text = phoneControllers[i].text.trim();
      if (text.isEmpty) continue;

      String countryCode = "";
      String number = text;

      if (text.contains(' ')) {
        final parts = text.split(' ');
        countryCode = parts.first;
        number = parts.sublist(1).join(' ');
      }

      payload.add({
        "id": phoneList[i].id,
        "phone": number,
        "type": phoneList[i].type ?? "Other",
        "country_code": countryCode,
      });
    }

    final res = await ApiService.updateClientPhoneDetail(payload);

    if (res["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Phones Updated Successfully!")),
      );
      setState(() => isEditingPhones = false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res["message"] ?? "Phone update failed")),
      );
    }
  }

  // ======== Add Phone Field ========
  void _addPhoneField() {
    setState(() {
      phoneList.add(
          Phone(id: 0, phone: "", type: "Other", countryCode: "+", isPrimary: false));
      phoneControllers.add(TextEditingController(text: "+ "));
    });
  }

  @override
  Widget build(BuildContext context) {
    final emails = widget.emails ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===== BASIC INFO =====
        _buildSectionTitle('Basic Information', showEdit: true, isBasic: true),
        const SizedBox(height: 12),
        _buildInfoCard([
          _buildTextField('First Name', firstNameCtrl, isBasic: true),
          _buildTextField('Last Name', lastNameCtrl, isBasic: true),
          _buildDOBField('Date of Birth', dobCtrl),
          _buildDropdownField('Gender', genderValue, genderOptions,
                  (value) => setState(() => genderValue = value)),
          _buildDropdownField('Marital Status', maritalStatusValue, maritalStatusOptions,
                  (value) => setState(() => maritalStatusValue = value)),
        ]),

        const SizedBox(height: 24),

        // ===== PHONE NUMBERS =====
        _buildSectionTitle('Phone Numbers', showEdit: true, showAdd: true, isBasic: false),
        const SizedBox(height: 12),
        _buildInfoCard(
          phoneList.isEmpty
              ? [_buildStaticField('No Phone Records', '')]
              : List.generate(phoneList.length, (index) {
            return _buildTextField(
                phoneList[index].type ?? 'Phone Number', phoneControllers[index],
                isBasic: false);
          }),
        ),

        const SizedBox(height: 24),

        // ===== EMAILS =====
        _buildSectionTitle('Email Addresses', showEdit: false, showAdd: false, isBasic: false),
        const SizedBox(height: 12),
        _buildInfoCard(
          emails.isEmpty
              ? [_buildStaticField('No Email Records', '')]
              : emails.map((e) {
            final emailCtrl = TextEditingController(text: e.email ?? "");
            return _buildTextField(e.type ?? 'Email Address', emailCtrl, isBasic: false);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl, {required bool isBasic}) {
    bool editable = isBasic ? isEditingBasic : isEditingPhones;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        readOnly: !editable,
        enabled: editable,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          labelText: label.toUpperCase(),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
      String label,
      String value,
      List<String> options,
      ValueChanged<String> onChangedNonNull,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: value.isNotEmpty ? value : null,
        items: options
            .map((e) => DropdownMenuItem<String>(
          value: e,
          child: Text(e),
        ))
            .toList(),
        onChanged: isEditingBasic
            ? (val) {
          if (val != null) onChangedNonNull(val);
        }
            : null,
        decoration: InputDecoration(
          labelText: label.toUpperCase(),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }


  Widget _buildDOBField(String label, TextEditingController ctrl) {
    return GestureDetector(
      onTap: isEditingBasic ? _pickDOB : null,
      child: _buildTextField(label, ctrl, isBasic: true),
    );
  }

  Widget _buildStaticField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text("$label: $value"),
    );
  }

  Widget _buildSectionTitle(String title,
      {bool showEdit = false, bool showAdd = false, required bool isBasic}) {
    return Row(
      children: [
        Icon(
          title.contains('Phone')
              ? Icons.phone_iphone
              : title.contains('Email')
              ? Icons.email
              : Icons.person,
          color: Colors.white,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const Spacer(),
        if (showEdit)
          InkWell(
            onTap: () {
              if (isBasic) {
                if (isEditingBasic) {
                  _saveBasicInfo();
                } else {
                  setState(() => isEditingBasic = true);
                }
              } else {
                if (isEditingPhones) {
                  _savePhones();
                } else {
                  setState(() => isEditingPhones = true);
                }
              }
            },
            child: _editButton(isBasic: isBasic),
          ),
        if (showAdd && !isBasic)
          InkWell(
            onTap: _addPhoneField,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: _buttonDecoration(),
              child: const Icon(Icons.add, color: Colors.blue, size: 20),
            ),
          ),
      ],
    );
  }

  Widget _editButton({required bool isBasic}) {
    bool editing = isBasic ? isEditingBasic : isEditingPhones;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: _buttonDecoration(),
      child: Icon(
        editing ? Icons.check : Icons.edit,
        color: Colors.blue,
        size: 20,
      ),
    );
  }

  BoxDecoration _buttonDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey.shade300),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}
