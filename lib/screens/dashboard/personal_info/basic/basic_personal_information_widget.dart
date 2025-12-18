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
  late TextEditingController firstNameCtrl;
  late TextEditingController lastNameCtrl;
  late TextEditingController clientIdCtrl;
  late TextEditingController dobCtrl;

  String genderValue = "";
  String maritalStatusValue = "";

  bool isEditingBasic = false;
  bool isEditingPhones = false;
  bool isEditingEmails = false;

  final List<TextEditingController> phoneControllers = [];
  final List<Phone> phoneList = [];

  final List<TextEditingController> emailControllers = [];
  final List<Email> emailList = [];

  final List<String> genderOptions = ["Male", "Female", "Other"];
  final List<String> maritalStatusOptions = [
    "Single",
    "Married",
    "De Facto",
    "Separated",
    "Divorced",
    "Widowed",
  ];

  final List<String> typeOptions = ["Personal", "Work", "Home", "Other"];

  // Full international country codes
  final List<String> countryCodes = [
    '+1',
    '+7',
    '+20',
    '+27',
    '+30',
    '+31',
    '+32',
    '+33',
    '+34',
    '+36',
    '+39',
    '+40',
    '+41',
    '+43',
    '+44',
    '+45',
    '+46',
    '+47',
    '+48',
    '+49',
    '+51',
    '+52',
    '+53',
    '+54',
    '+55',
    '+56',
    '+57',
    '+58',
    '+60',
    '+61',
    '+62',
    '+63',
    '+64',
    '+65',
    '+66',
    '+81',
    '+82',
    '+84',
    '+86',
    '+90',
    '+91',
    '+92',
    '+93',
    '+94',
    '+95',
    '+98',
    '+211',
    '+212',
    '+213',
    '+216',
    '+218',
    '+220',
    '+221',
    '+222',
    '+223',
    '+224',
    '+225',
    '+226',
    '+227',
    '+228',
    '+229',
    '+230',
    '+231',
    '+232',
    '+233',
    '+234',
    '+235',
    '+236',
    '+237',
    '+238',
    '+239',
    '+240',
    '+241',
    '+242',
    '+243',
    '+244',
    '+245',
    '+246',
    '+248',
    '+249',
    '+250',
    '+251',
    '+252',
    '+253',
    '+254',
    '+255',
    '+256',
    '+257',
    '+258',
    '+260',
    '+261',
    '+262',
    '+263',
    '+264',
    '+265',
    '+266',
    '+267',
    '+268',
    '+269',
    '+290',
    '+291',
    '+297',
    '+298',
    '+299',
    '+350',
    '+351',
    '+352',
    '+353',
    '+354',
    '+355',
    '+356',
    '+357',
    '+358',
    '+359',
    '+370',
    '+371',
    '+372',
    '+373',
    '+374',
    '+375',
    '+376',
    '+377',
    '+378',
    '+379',
    '+380',
    '+381',
    '+382',
    '+383',
    '+385',
    '+386',
    '+387',
    '+389',
    '+420',
    '+421',
    '+423',
    '+500',
    '+501',
    '+502',
    '+503',
    '+504',
    '+505',
    '+506',
    '+507',
    '+508',
    '+509',
    '+590',
    '+591',
    '+592',
    '+593',
    '+594',
    '+595',
    '+596',
    '+597',
    '+598',
    '+599',
    '+670',
    '+672',
    '+673',
    '+674',
    '+675',
    '+676',
    '+677',
    '+678',
    '+679',
    '+680',
    '+681',
    '+682',
    '+683',
    '+685',
    '+686',
    '+687',
    '+688',
    '+689',
    '+690',
    '+691',
    '+692',
    '+850',
    '+852',
    '+853',
    '+855',
    '+856',
    '+870',
    '+880',
    '+886',
    '+960',
    '+961',
    '+962',
    '+963',
    '+964',
    '+965',
    '+966',
    '+967',
    '+968',
    '+970',
    '+971',
    '+972',
    '+973',
    '+974',
    '+975',
    '+976',
    '+977',
    '+992',
    '+993',
    '+994',
    '+995',
    '+996',
    '+998',
  ];

  @override
  void initState() {
    super.initState();
    final basic = widget.basicInfo;
    String first = "", last = "";
    if (basic?.fullName != null && basic!.fullName!.isNotEmpty) {
      final parts = basic.fullName!.split(" ");
      first = parts.first;
      last = parts.length > 1 ? parts.sublist(1).join(" ") : "";
    }
    firstNameCtrl = TextEditingController(text: first);
    lastNameCtrl = TextEditingController(text: last);
    clientIdCtrl = TextEditingController(text: basic?.clientId ?? "");
    dobCtrl = TextEditingController(text: basic?.dateOfBirth ?? "");
    genderValue = basic?.gender ?? "";
    maritalStatusValue = basic?.maritalStatus ?? "";

    if (widget.phones != null) {
      phoneList.addAll(widget.phones!);
      for (var p in phoneList) {
        phoneControllers.add(
          TextEditingController(
            text: "${p.countryCode ?? '+'} ${p.phone ?? ''}".trim(),
          ),
        );
      }
    }

    if (widget.emails != null) {
      emailList.addAll(widget.emails!);
      for (var e in emailList) {
        emailControllers.add(TextEditingController(text: e.email ?? ""));
      }
    }
  }

  void _onPhoneChanged(int index, String value) {
    if (value.isEmpty) return;

    String input = value.replaceAll(' ', '');

    if (!input.startsWith('+')) {
      input = '+$input';
    } else {
      input = '+' + input.substring(1).replaceAll('+', '');
    }

    String matchedCode = '+';
    String remaining = input.substring(1);

    for (var code
        in countryCodes..sort((a, b) => b.length.compareTo(a.length))) {
      if (input.startsWith(code)) {
        matchedCode = code;
        remaining = input.substring(code.length);
        break;
      }
    }

    String newText =
        remaining.isNotEmpty ? '$matchedCode $remaining' : matchedCode;

    if (phoneControllers[index].text != newText) {
      phoneControllers[index].value = phoneControllers[index].value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }

    if (index < phoneList.length) {
      phoneList[index].countryCode = matchedCode;
      phoneList[index].phone = remaining;
    }
  }

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

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
        "id": phoneList[i].id == 0 ? null : phoneList[i].id,
        "phone": number,
        "type": phoneList[i].type ?? "Other",
        "country_code": countryCode,
        "extension": phoneList[i].extension,
      });
    }

    if (payload.isNotEmpty) {
      final res = await ApiService.updateClientPhoneDetail(payload);

      if (res["success"] == true &&
          res["data"] != null &&
          res["data"]["phones"] != null) {
        final List<dynamic> updatedData = res["data"]["phones"];

        for (int i = 0; i < updatedData.length; i++) {
          final apiPhone = updatedData[i];
          final localPhone = phoneList[i];

          localPhone.id = apiPhone["id"];
          localPhone.phone = apiPhone["phone"];
          localPhone.type = apiPhone["type"];
          localPhone.countryCode = apiPhone["country_code"];
          localPhone.extension = apiPhone["extension"];
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Phones updated successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res["message"] ?? "Phone update failed")),
        );
      }
    }

    setState(() => isEditingPhones = false);
  }

  Future<void> _saveEmails() async {
    List<Map<String, dynamic>> payload = [];

    for (int i = 0; i < emailList.length; i++) {
      final emailText = emailControllers[i].text.trim();
      if (emailText.isEmpty) continue;

      payload.add({
        "id": emailList[i].id == 0 ? null : emailList[i].id,
        "email": emailText,
        "type": emailList[i].type ?? "Other",
      });
    }

    if (payload.isNotEmpty) {
      final res = await ApiService.updateClientEmailDetail(payload);

      if (res["success"] == true &&
          res["data"] != null &&
          res["data"]["emails"] != null) {
        final List<dynamic> updatedEmails = res["data"]["emails"];

        for (int i = 0; i < updatedEmails.length; i++) {
          final apiEmail = updatedEmails[i];
          final localEmail = emailList[i];

          localEmail.id = apiEmail["id"];
          localEmail.email = apiEmail["email"];
          localEmail.type = apiEmail["type"];
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Emails Updated Successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res["message"] ?? "Email update failed")),
        );
      }
    }

    setState(() => isEditingEmails = false);
  }

  void _addPhoneField() {
    setState(() {
      phoneList.add(
        Phone(
          id: 0,
          phone: "",
          type: "Other",
          countryCode: "+",
          isPrimary: false,
        ),
      );
      phoneControllers.add(TextEditingController(text: "+ "));
      isEditingPhones = true;
    });
  }

  void _addEmailField() {
    setState(() {
      emailList.add(Email(id: 0, email: "", type: "Other", isPrimary: false));
      emailControllers.add(TextEditingController());
      isEditingEmails = true;
    });
  }

  Future<void> _deletePhone(int index) async {
    final phone = phoneList[index];

    final res = await ApiService.deleteClientTabDetail(
      id: phone.id,
      type: "phone",
    );

    if (res["success"] == true) {
      setState(() {
        phoneList.removeAt(index);
        phoneControllers.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Phone Number Deleted Successfully!")),
      );
    }
  }

  Future<void> _deleteEmail(int index) async {
    final email = emailList[index];

    final res = await ApiService.deleteClientTabDetail(
      id: email.id!,
      type: "email",
    );

    if (res["success"] == true) {
      setState(() {
        emailList.removeAt(index);
        emailControllers.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email Deleted Successfully!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Basic Information',
          showEdit: true,
          showAdd: false,
          isBasic: true,
        ),
        const SizedBox(height: 12),
        _buildInfoCard([
          _buildTextField('First Name', firstNameCtrl, isBasic: true),
          _buildTextField('Last Name', lastNameCtrl, isBasic: true),
          _buildTextField('Client ID', clientIdCtrl, isBasic: false),
          _buildDOBField('Date of Birth', dobCtrl),
          _buildDropdownField(
            'Gender',
            genderValue,
            genderOptions,
            (value) => setState(() => genderValue = value!),
          ),
          _buildDropdownField(
            'Marital Status',
            maritalStatusValue,
            maritalStatusOptions,
            (value) => setState(() => maritalStatusValue = value!),
          ),
        ]),

        const SizedBox(height: 24),

        _buildSectionTitle(
          'Phone Numbers',
          showEdit: true,
          showAdd: true,
          isBasic: false,
        ),
        const SizedBox(height: 12),

        _buildInfoCard(
          phoneList.isEmpty
              ? [_buildStaticField('No Phone Records', '')]
              : List.generate(phoneList.length, (index) {
                final phone = phoneList[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildTypeDropdown(
                            phone.type ?? "Other",
                            isEditingPhones,
                            (value) => setState(() => phone.type = value!),
                          ),
                        ),
                        if (isEditingPhones)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder:
                                    (_) => AlertDialog(
                                      title: const Text("Delete Phone"),
                                      content: const Text(
                                        "Are you sure you want to delete this phone number?",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, false),
                                          child: const Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, true),
                                          child: const Text("Delete"),
                                        ),
                                      ],
                                    ),
                              );
                              if (confirm == true) _deletePhone(index);
                            },
                          ),
                      ],
                    ),
                    _buildTextFieldPhone(
                      phone.type ?? 'Phone Number',
                      phoneControllers[index],
                      type: phone.type ?? 'Other',
                    ),
                    const SizedBox(height: 10),
                  ],
                );
              }),
        ),

        const SizedBox(height: 24),

        _buildSectionTitle(
          'Email Addresses',
          showEdit: true,
          showAdd: true,
          isBasic: false,
          isEmail: true,
        ),
        const SizedBox(height: 12),

        _buildInfoCard(
          emailList.isEmpty
              ? [_buildStaticField('No Email Records', '')]
              : List.generate(emailList.length, (index) {
                final email = emailList[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildTypeDropdown(
                            email.type ?? 'Other',
                            isEditingEmails,
                            (v) => setState(() => email.type = v!),
                          ),
                        ),
                        if (isEditingEmails)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder:
                                    (_) => AlertDialog(
                                      title: const Text("Delete Email"),
                                      content: const Text(
                                        "Are you sure you want to delete this email address?",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, false),
                                          child: const Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, true),
                                          child: const Text("Delete"),
                                        ),
                                      ],
                                    ),
                              );
                              if (confirm == true) _deleteEmail(index);
                            },
                          ),
                      ],
                    ),
                    _buildTextFieldEmail(
                      email.type ?? 'Email Address',
                      emailControllers[index],
                      type: email.type ?? 'Other',
                    ),
                    const SizedBox(height: 10),
                  ],
                );
              }),
        ),
      ],
    );
  }

  Widget _buildTypeDropdown(
    String value,
    bool editable,
    ValueChanged<String?> cb,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DropdownButtonFormField<String>(
        value: value,
        items:
            typeOptions
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
        onChanged: editable ? cb : null,
        decoration: const InputDecoration(
          labelText: "TYPE",
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController ctrl, {
    required bool isBasic,
  }) {
    bool editable = isBasic ? isEditingBasic : false;
    if (label == 'Client ID') editable = false;

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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldPhone(
    String label,
    TextEditingController ctrl, {
    required String type,
  }) {
    bool editable = isEditingPhones;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        readOnly: !editable,
        enabled: editable,
        keyboardType: TextInputType.phone,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          labelText: label.toUpperCase(),
          border: const OutlineInputBorder(),
        ),
        onChanged: (val) {
          _onPhoneChanged(phoneControllers.indexOf(ctrl), val);
        },
      ),
    );
  }

  Widget _buildTextFieldEmail(
    String label,
    TextEditingController ctrl, {
    required String type,
  }) {
    bool editable = isEditingEmails;

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
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String value,
    List<String> options,
    ValueChanged<String?> cb,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: value.isNotEmpty ? value : null,
        items:
            options
                .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                .toList(),
        onChanged: isEditingBasic ? cb : null,
        decoration: InputDecoration(
          labelText: label.toUpperCase(),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDOBField(String label, TextEditingController ctrl) {
    return GestureDetector(
      onTap: isEditingBasic ? _pickDOB : null,
      child: AbsorbPointer(
        absorbing: true,
        child: _buildTextField(label, ctrl, isBasic: true),
      ),
    );
  }

  Widget _buildStaticField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text("$label: $value"),
    );
  }

  Widget _buildSectionTitle(
    String title, {
    bool showEdit = false,
    bool showAdd = true,
    required bool isBasic,
    bool isEmail = false,
  }) {
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
        if (showAdd)
          InkWell(
            onTap: () {
              if (title.contains('Phone')) _addPhoneField();
              if (title.contains('Email')) _addEmailField();
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: _buttonDecoration(),
              child: const Icon(Icons.add, color: Colors.green, size: 20),
            ),
          ),
        if (showEdit) const SizedBox(width: 8),
        if (showEdit)
          InkWell(
            onTap: () {
              if (isBasic) {
                if (isEditingBasic) {
                  _saveBasicInfo();
                } else {
                  setState(() => isEditingBasic = true);
                }
              } else if (isEmail) {
                if (isEditingEmails)
                  _saveEmails();
                else
                  setState(() => isEditingEmails = true);
              } else {
                if (isEditingPhones)
                  _savePhones();
                else
                  setState(() => isEditingPhones = true);
              }
            },
            child: _editButton(isBasic: isBasic, isEmail: isEmail),
          ),
      ],
    );
  }

  Widget _editButton({required bool isBasic, bool isEmail = false}) {
    bool editing =
        isBasic
            ? isEditingBasic
            : isEmail
            ? isEditingEmails
            : isEditingPhones;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
