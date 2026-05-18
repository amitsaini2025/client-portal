import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../config/theme_config.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor =
        isDark ? ThemeConfig.textSecondaryDark : ThemeConfig.textSecondaryLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          context,
          'Basic Information',
          Icons.person_outline_rounded,
          showEdit: true,
          showAdd: false,
          isBasic: true,
        ),
        const SizedBox(height: 16),
        _buildInfoCard(context, [
          _buildTextField(context, 'First Name', firstNameCtrl, isBasic: true),
          _buildTextField(context, 'Last Name', lastNameCtrl, isBasic: true),
          _buildTextField(context, 'Client ID', clientIdCtrl, isBasic: false),
          _buildDOBField(context, 'Date of Birth', dobCtrl),
          _buildDropdownField(
            context,
            'Gender',
            genderValue,
            genderOptions,
            (value) => setState(() => genderValue = value!),
          ),
          _buildDropdownField(
            context,
            'Marital Status',
            maritalStatusValue,
            maritalStatusOptions,
            (value) => setState(() => maritalStatusValue = value!),
          ),
        ]),

        const SizedBox(height: 32),

        _buildSectionTitle(
          context,
          'Phone Numbers',
          Icons.phone_iphone_rounded,
          showEdit: true,
          showAdd: true,
          isBasic: false,
        ),
        const SizedBox(height: 16),

        phoneList.isEmpty
            ? _buildInfoCard(context, [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No phone numbers added',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: secondaryTextColor,
                    ),
                  ),
                ),
              ),
            ])
            : Column(
              children: List.generate(phoneList.length, (index) {
                final phone = phoneList[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildInfoCard(context, [
                    Row(
                      children: [
                        Expanded(
                          child: _buildTypeDropdown(
                            context,
                            phone.type ?? "Other",
                            isEditingPhones,
                            (value) => setState(() => phone.type = value!),
                          ),
                        ),
                        if (isEditingPhones)
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              color: ThemeConfig.errorColor,
                            ),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder:
                                    (_) => AlertDialog(
                                      title: Text(
                                        "Delete Phone",
                                        style: GoogleFonts.spaceGrotesk(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      content: Text(
                                        "Are you sure you want to delete this phone number?",
                                        style: GoogleFonts.inter(),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, false),
                                          child: Text(
                                            "Cancel",
                                            style: GoogleFonts.inter(),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, true),
                                          style: TextButton.styleFrom(
                                            foregroundColor:
                                                ThemeConfig.errorColor,
                                          ),
                                          child: Text(
                                            "Delete",
                                            style: GoogleFonts.inter(),
                                          ),
                                        ),
                                      ],
                                    ),
                              );
                              if (confirm == true) _deletePhone(index);
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildTextFieldPhone(
                      context,
                      phone.type ?? 'Phone Number',
                      phoneControllers[index],
                      type: phone.type ?? 'Other',
                    ),
                  ]),
                );
              }),
            ),

        const SizedBox(height: 32),

        _buildSectionTitle(
          context,
          'Email Addresses',
          Icons.email_outlined,
          showEdit: true,
          showAdd: true,
          isBasic: false,
          isEmail: true,
        ),
        const SizedBox(height: 16),

        emailList.isEmpty
            ? _buildInfoCard(context, [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No email addresses added',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: secondaryTextColor,
                    ),
                  ),
                ),
              ),
            ])
            : Column(
              children: List.generate(emailList.length, (index) {
                final email = emailList[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildInfoCard(context, [
                    Row(
                      children: [
                        Expanded(
                          child: _buildTypeDropdown(
                            context,
                            email.type ?? 'Other',
                            isEditingEmails,
                            (v) => setState(() => email.type = v!),
                          ),
                        ),
                        if (isEditingEmails)
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              color: ThemeConfig.errorColor,
                            ),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder:
                                    (_) => AlertDialog(
                                      title: Text(
                                        "Delete Email",
                                        style: GoogleFonts.spaceGrotesk(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      content: Text(
                                        "Are you sure you want to delete this email address?",
                                        style: GoogleFonts.inter(),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, false),
                                          child: Text(
                                            "Cancel",
                                            style: GoogleFonts.inter(),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, true),
                                          style: TextButton.styleFrom(
                                            foregroundColor:
                                                ThemeConfig.errorColor,
                                          ),
                                          child: Text(
                                            "Delete",
                                            style: GoogleFonts.inter(),
                                          ),
                                        ),
                                      ],
                                    ),
                              );
                              if (confirm == true) _deleteEmail(index);
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildTextFieldEmail(
                      context,
                      email.type ?? 'Email Address',
                      emailControllers[index],
                      type: email.type ?? 'Other',
                    ),
                  ]),
                );
              }),
            ),
      ],
    );
  }

  Widget _buildTypeDropdown(
    BuildContext context,
    String value,
    bool editable,
    ValueChanged<String?> cb,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Type",
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color:
                    isDark
                        ? ThemeConfig.textPrimaryDark
                        : ThemeConfig.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: DropdownButtonFormField<String>(
                value: value,
                items:
                    typeOptions
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e,
                              style: GoogleFonts.inter(fontSize: 14),
                            ),
                          ),
                        )
                        .toList(),
                onChanged: editable ? cb : null,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color:
                      isDark
                          ? ThemeConfig.textPrimaryDark
                          : ThemeConfig.textPrimaryLight,
                ),
                decoration: InputDecoration(
                  hintText: "Choose Type",
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    color:
                        isDark
                            ? ThemeConfig.textSecondaryDark
                            : ThemeConfig.textSecondaryLight,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color:
                          isDark
                              ? ThemeConfig.borderDark
                              : const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color:
                          isDark
                              ? ThemeConfig.borderDark
                              : const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: ThemeConfig.primaryColor,
                      width: 1.5,
                    ),
                  ),
                  filled: true,
                  fillColor: isDark ? ThemeConfig.cardDark : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  suffixIcon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color:
                        isDark
                            ? ThemeConfig.textSecondaryDark
                            : ThemeConfig.textSecondaryLight,
                  ),
                ),
                icon: const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context,
    String label,
    TextEditingController ctrl, {
    required bool isBasic,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    bool editable = isBasic ? isEditingBasic : false;
    if (label == 'Client ID') editable = false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color:
                    isDark
                        ? ThemeConfig.textPrimaryDark
                        : ThemeConfig.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextFormField(
                controller: ctrl,
                readOnly: !editable,
                enabled: editable,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color:
                      isDark
                          ? ThemeConfig.textPrimaryDark
                          : ThemeConfig.textPrimaryLight,
                ),
                decoration: InputDecoration(
                  hintText: label,
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    color:
                        isDark
                            ? ThemeConfig.textSecondaryDark
                            : ThemeConfig.textSecondaryLight,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color:
                          isDark
                              ? ThemeConfig.borderDark
                              : const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color:
                          isDark
                              ? ThemeConfig.borderDark
                              : const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: ThemeConfig.primaryColor,
                      width: 1.5,
                    ),
                  ),
                  filled: true,
                  fillColor: isDark ? ThemeConfig.cardDark : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFieldPhone(
    BuildContext context,
    String label,
    TextEditingController ctrl, {
    required String type,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    bool editable = isEditingPhones;

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color:
                  isDark
                      ? ThemeConfig.textPrimaryDark
                      : ThemeConfig.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextFormField(
              controller: ctrl,
              readOnly: !editable,
              enabled: editable,
              keyboardType: TextInputType.phone,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color:
                    isDark
                        ? ThemeConfig.textPrimaryDark
                        : ThemeConfig.textPrimaryLight,
              ),
              decoration: InputDecoration(
                hintText: label,
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  color:
                      isDark
                          ? ThemeConfig.textSecondaryDark
                          : ThemeConfig.textSecondaryLight,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color:
                        isDark
                            ? ThemeConfig.borderDark
                            : const Color(0xFFE5E7EB),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color:
                        isDark
                            ? ThemeConfig.borderDark
                            : const Color(0xFFE5E7EB),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: ThemeConfig.primaryColor,
                    width: 1.5,
                  ),
                ),
                filled: true,
                fillColor: isDark ? ThemeConfig.cardDark : Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              onChanged: (val) {
                _onPhoneChanged(phoneControllers.indexOf(ctrl), val);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldEmail(
    BuildContext context,
    String label,
    TextEditingController ctrl, {
    required String type,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    bool editable = isEditingEmails;

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color:
                  isDark
                      ? ThemeConfig.textPrimaryDark
                      : ThemeConfig.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextFormField(
              controller: ctrl,
              readOnly: !editable,
              enabled: editable,
              keyboardType: TextInputType.emailAddress,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color:
                    isDark
                        ? ThemeConfig.textPrimaryDark
                        : ThemeConfig.textPrimaryLight,
              ),
              decoration: InputDecoration(
                hintText: label,
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  color:
                      isDark
                          ? ThemeConfig.textSecondaryDark
                          : ThemeConfig.textSecondaryLight,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color:
                        isDark
                            ? ThemeConfig.borderDark
                            : const Color(0xFFE5E7EB),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color:
                        isDark
                            ? ThemeConfig.borderDark
                            : const Color(0xFFE5E7EB),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: ThemeConfig.primaryColor,
                    width: 1.5,
                  ),
                ),
                filled: true,
                fillColor: isDark ? ThemeConfig.cardDark : Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(
    BuildContext context,
    String label,
    String value,
    List<String> options,
    ValueChanged<String?> cb,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color:
                    isDark
                        ? ThemeConfig.textPrimaryDark
                        : ThemeConfig.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: DropdownButtonFormField<String>(
                value: value.isNotEmpty ? value : null,
                items:
                    options
                        .map(
                          (e) => DropdownMenuItem<String>(
                            value: e,
                            child: Text(
                              e,
                              style: GoogleFonts.inter(fontSize: 14),
                            ),
                          ),
                        )
                        .toList(),
                onChanged: isEditingBasic ? cb : null,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color:
                      isDark
                          ? ThemeConfig.textPrimaryDark
                          : ThemeConfig.textPrimaryLight,
                ),
                decoration: InputDecoration(
                  hintText: 'Choose $label',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    color:
                        isDark
                            ? ThemeConfig.textSecondaryDark
                            : ThemeConfig.textSecondaryLight,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color:
                          isDark
                              ? ThemeConfig.borderDark
                              : const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color:
                          isDark
                              ? ThemeConfig.borderDark
                              : const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: ThemeConfig.primaryColor,
                      width: 1.5,
                    ),
                  ),
                  filled: true,
                  fillColor: isDark ? ThemeConfig.cardDark : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  suffixIcon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color:
                        isDark
                            ? ThemeConfig.textSecondaryDark
                            : ThemeConfig.textSecondaryLight,
                  ),
                ),
                icon: const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDOBField(
    BuildContext context,
    String label,
    TextEditingController ctrl,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color:
                    isDark
                        ? ThemeConfig.textPrimaryDark
                        : ThemeConfig.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: isEditingBasic ? _pickDOB : null,
                child: AbsorbPointer(
                  absorbing: true,
                  child: TextFormField(
                    controller: ctrl,
                    readOnly: true,
                    enabled: isEditingBasic,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color:
                          isDark
                              ? ThemeConfig.textPrimaryDark
                              : ThemeConfig.textPrimaryLight,
                    ),
                    decoration: InputDecoration(
                      hintText: label,
                      hintStyle: GoogleFonts.inter(
                        fontSize: 14,
                        color:
                            isDark
                                ? ThemeConfig.textSecondaryDark
                                : ThemeConfig.textSecondaryLight,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color:
                              isDark
                                  ? ThemeConfig.borderDark
                                  : const Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color:
                              isDark
                                  ? ThemeConfig.borderDark
                                  : const Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: ThemeConfig.primaryColor,
                          width: 1.5,
                        ),
                      ),
                      filled: true,
                      fillColor: isDark ? ThemeConfig.cardDark : Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      suffixIcon: Icon(
                        Icons.calendar_today_rounded,
                        size: 20,
                        color:
                            isDark
                                ? ThemeConfig.textSecondaryDark
                                : ThemeConfig.textSecondaryLight,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    IconData icon, {
    bool showEdit = false,
    bool showAdd = true,
    required bool isBasic,
    bool isEmail = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? ThemeConfig.textPrimaryDark : ThemeConfig.textPrimaryLight;
    final cardColor = isDark ? ThemeConfig.cardDark : ThemeConfig.cardLight;
    final borderColor =
        isDark ? ThemeConfig.borderDark : ThemeConfig.borderLight;

    bool editing =
        isBasic
            ? isEditingBasic
            : isEmail
            ? isEditingEmails
            : isEditingPhones;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ThemeConfig.primaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ThemeConfig.primaryColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(icon, color: ThemeConfig.primaryColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          if (showAdd)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (title.contains('Phone')) _addPhoneField();
                  if (title.contains('Email')) _addEmailField();
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ThemeConfig.successColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: ThemeConfig.successColor.withOpacity(0.25),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    color: ThemeConfig.successColor,
                    size: 20,
                  ),
                ),
              ),
            ),
          if (showEdit && showAdd) const SizedBox(width: 8),
          if (showEdit)
            Material(
              color: Colors.transparent,
              child: InkWell(
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
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color:
                        editing
                            ? ThemeConfig.successColor.withOpacity(0.12)
                            : ThemeConfig.primaryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color:
                          editing
                              ? ThemeConfig.successColor.withOpacity(0.25)
                              : ThemeConfig.primaryColor.withOpacity(0.25),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    editing ? Icons.check_rounded : Icons.edit_rounded,
                    color:
                        editing
                            ? ThemeConfig.successColor
                            : ThemeConfig.primaryColor,
                    size: 20,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? ThemeConfig.cardDark : ThemeConfig.cardLight;
    final borderColor =
        isDark ? ThemeConfig.borderDark : ThemeConfig.borderLight;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
