import 'package:client/models/personal_information/basic_information_post/visa_types/visa_type.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../config/theme_config.dart';
import '../../../../models/personal_information/basic_information_post/country/country_model.dart';
import '../../../../models/personal_information/passport.dart';
import '../../../../models/personal_information/visa.dart';
import '../../../../services/api_service.dart';

class TravelDocumentsWidget extends StatefulWidget {
  final List<Passport> passports;
  final List<Visa> visas;
  final List<Country> countries;
  final List<VisaType> visaTypes;

  const TravelDocumentsWidget({
    super.key,
    required this.passports,
    required this.visas,
    required this.countries,
    required this.visaTypes,
  });

  @override
  State<TravelDocumentsWidget> createState() => _TravelDocumentsWidgetState();
}

class _TravelDocumentsWidgetState extends State<TravelDocumentsWidget> {
  bool isPassportEditing = false;
  bool isVisaEditing = false;

  final Map<Passport, TextEditingController> _passportNumberControllers = {};
  final Map<Passport, TextEditingController> _passportIssueControllers = {};
  final Map<Passport, TextEditingController> _passportExpiryControllers = {};

  final Map<Visa, TextEditingController> _visaDescriptionControllers = {};
  final Map<Visa, TextEditingController> _visaGrantControllers = {};
  final Map<Visa, TextEditingController> _visaExpiryControllers = {};

  Future<String?> _pickDate(String current) async {
    DateTime initial;
    try {
      final parts = current.split('/');
      initial = DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
    } catch (_) {
      initial = DateTime.now();
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      return DateFormat("dd/MM/yyyy").format(picked);
    }
    return null;
  }

  Future<void> _savePassports() async {
    final payload =
        widget.passports.map((p) {
          return {
            "id": p.id == 0 ? null : p.id,
            "passport_number": p.passportNumber,
            "country": p.country,
            "issue_date": p.issueDate,
            "expiry_date": p.expiryDate,
          };
        }).toList();

    final res = await ApiService.updateClientPassportDetail(payload);

    if (res["success"] == true &&
        res["data"] != null &&
        res["data"]["passports"] != null) {
      final List<dynamic> updatedData = res["data"]["passports"];

      // Update local IDs and other fields from API response
      for (int i = 0; i < updatedData.length; i++) {
        final apiPassport = updatedData[i];
        final localPassport = widget.passports[i];
        localPassport.id = apiPassport["id"];
        localPassport.passportNumber = apiPassport["passport_number"];
        localPassport.country = apiPassport["country"];
        localPassport.issueDate = apiPassport["issue_date"];
        localPassport.expiryDate = apiPassport["expiry_date"];
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passports updated successfully")),
      );
      setState(() => isPassportEditing = false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res["message"] ?? "Passport update failed")),
      );
    }
  }

  Future<void> _saveVisas() async {
    final payload =
        widget.visas.map((v) {
          return {
            "id": v.id == 0 ? null : v.id,
            "visa_country": v.visaCountry,
            "visa_type": v.visaType,
            "visa_description": v.visaDescription,
            "visa_grant_date": v.visaGrantDate,
            "visa_expiry_date": v.visaExpiryDate,
          };
        }).toList();

    final res = await ApiService.updateClientVisaDetail(payload);

    if (res["success"] == true &&
        res["data"] != null &&
        res["data"]["visas"] != null) {
      final List<dynamic> updatedData = res["data"]["visas"];

      for (int i = 0; i < updatedData.length; i++) {
        final apiVisa = updatedData[i];
        final localVisa = widget.visas[i];

        localVisa.id = apiVisa["id"];
        localVisa.visaCountry = apiVisa["visa_country"];
        localVisa.visaType = apiVisa["visa_type"];
        localVisa.visaDescription = apiVisa["visa_description"];
        localVisa.visaGrantDate = apiVisa["visa_grant_date"];
        localVisa.visaExpiryDate = apiVisa["visa_expiry_date"];
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Visas updated successfully")),
      );
      setState(() => isVisaEditing = false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res["message"] ?? "Visa update failed")),
      );
    }
  }

  Future<void> _deletePassport(Passport passport) async {
    if (passport.id == 0) {
      // If it is a new passport not yet saved to API
      setState(() {
        widget.passports.remove(passport);
        _passportNumberControllers.remove(passport);
        _passportIssueControllers.remove(passport);
        _passportExpiryControllers.remove(passport);
      });
      return;
    }

    final res = await ApiService.deleteClientTabDetail(
      id: passport.id!,
      type: "passport",
    );

    if (res["success"] == true) {
      setState(() {
        widget.passports.remove(passport);
        _passportNumberControllers.remove(passport);
        _passportIssueControllers.remove(passport);
        _passportExpiryControllers.remove(passport);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passport Deleted Successfully!")),
      );
    }
  }

  Future<void> _deleteVisa(Visa visa) async {
    if (visa.id == 0) {
      // If it is a new visa not yet saved to API
      setState(() {
        widget.visas.remove(visa);
        _visaDescriptionControllers.remove(visa);
        _visaGrantControllers.remove(visa);
        _visaExpiryControllers.remove(visa);
      });
      return;
    }

    final res = await ApiService.deleteClientTabDetail(
      id: visa.id,
      type: "visa",
    );

    if (res["success"] == true) {
      setState(() {
        widget.visas.remove(visa);
        _visaDescriptionControllers.remove(visa);
        _visaGrantControllers.remove(visa);
        _visaExpiryControllers.remove(visa);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Visa Deleted Successfully!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          context,
          "Passport Information",
          Icons.credit_card_rounded,
          showEdit: true,
          showAdd: true,
          isEditing: isPassportEditing,
          onEdit: () {
            if (isPassportEditing) {
              _savePassports();
            } else {
              setState(() => isPassportEditing = true);
            }
          },
          onAdd: () {
            setState(() {
              final p = Passport(
                id: 0,
                passportNumber: "",
                country: "",
                issueDate: "",
                expiryDate: "",
              );
              widget.passports.add(p);
              isPassportEditing = true;
            });
          },
        ),
        const SizedBox(height: 16),
        ...widget.passports.map(
          (p) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildPassportCard(context, p),
          ),
        ),

        const SizedBox(height: 32),

        _buildSectionTitle(
          context,
          "Visa Information",
          Icons.airplane_ticket_rounded,
          showEdit: true,
          showAdd: true,
          isEditing: isVisaEditing,
          onEdit: () {
            if (isVisaEditing) {
              _saveVisas();
            } else {
              setState(() => isVisaEditing = true);
            }
          },
          onAdd: () {
            setState(() {
              final v = Visa(
                id: 0,
                visaCountry: "",
                visaType: "",
                visaDescription: "",
                visaGrantDate: "",
                visaExpiryDate: "",
              );
              widget.visas.add(v);
              isVisaEditing = true;
            });
          },
        ),
        const SizedBox(height: 16),
        ...widget.visas.map(
          (v) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildVisaCard(context, v),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    IconData icon, {
    required bool showEdit,
    required bool showAdd,
    required bool isEditing,
    required VoidCallback onEdit,
    required VoidCallback onAdd,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? ThemeConfig.textPrimaryDark : ThemeConfig.textPrimaryLight;
    final cardColor = isDark ? ThemeConfig.cardDark : ThemeConfig.cardLight;
    final borderColor =
        isDark ? ThemeConfig.borderDark : ThemeConfig.borderLight;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha:0.04),
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
              color: ThemeConfig.primaryColor.withValues(alpha:0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ThemeConfig.primaryColor.withValues(alpha:0.2),
                width: 1,
              ),
            ),
            child: Icon(icon, color: ThemeConfig.primaryColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          if (showAdd)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onAdd,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ThemeConfig.successColor.withValues(alpha:0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: ThemeConfig.successColor.withValues(alpha:0.25),
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
          if (showAdd) const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color:
                      isEditing
                          ? ThemeConfig.successColor.withValues(alpha:0.12)
                          : ThemeConfig.primaryColor.withValues(alpha:0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color:
                        isEditing
                            ? ThemeConfig.successColor.withValues(alpha:0.25)
                            : ThemeConfig.primaryColor.withValues(alpha:0.25),
                    width: 1,
                  ),
                ),
                child: Icon(
                  isEditing ? Icons.check_rounded : Icons.edit_rounded,
                  color:
                      isEditing
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

  Widget _buildPassportCard(BuildContext context, Passport p) {
    final numberController = _passportNumberControllers.putIfAbsent(
      p,
      () => TextEditingController(text: p.passportNumber),
    );
    final issueController = _passportIssueControllers.putIfAbsent(
      p,
      () => TextEditingController(text: p.issueDate),
    );
    final expiryController = _passportExpiryControllers.putIfAbsent(
      p,
      () => TextEditingController(text: p.expiryDate),
    );

    return _buildInfoCard(context, [
      Row(
        children: [
          Expanded(
            child: _buildEditableRow(
              context,
              "Passport Number",
              numberController,
              (val) => p.passportNumber = val,
              isPassportEditing,
            ),
          ),
          if (isPassportEditing)
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
                          "Delete Passport",
                          style: GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        content: Text(
                          "Are you sure you want to delete this passport?",
                          style: GoogleFonts.inter(),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text("Cancel", style: GoogleFonts.inter()),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(
                              foregroundColor: ThemeConfig.errorColor,
                            ),
                            child: Text("Delete", style: GoogleFonts.inter()),
                          ),
                        ],
                      ),
                );

                if (confirm == true) {
                  await _deletePassport(p);
                  setState(() {
                    widget.passports.remove(p);
                    _passportNumberControllers.remove(p);
                    _passportIssueControllers.remove(p);
                    _passportExpiryControllers.remove(p);
                  });
                }
              },
            ),
        ],
      ),
      const SizedBox(height: 8),
      _buildCountryDropdown(
        context,
        label: "Country",
        selected: p.country,
        editable: isPassportEditing,
        onChanged: (val) => setState(() => p.country = val ?? ""),
      ),
      _buildDateRow(
        context,
        "Issued Date",
        issueController,
        (val) => p.issueDate = val ?? "",
        isPassportEditing,
      ),
      _buildDateRow(
        context,
        "Expiry Date",
        expiryController,
        (val) => p.expiryDate = val ?? "",
        isPassportEditing,
      ),
    ]);
  }

  Widget _buildVisaCard(BuildContext context, Visa v) {
    final descriptionController = _visaDescriptionControllers.putIfAbsent(
      v,
      () => TextEditingController(text: v.visaDescription),
    );
    final grantController = _visaGrantControllers.putIfAbsent(
      v,
      () => TextEditingController(text: v.visaGrantDate),
    );
    final expiryController = _visaExpiryControllers.putIfAbsent(
      v,
      () => TextEditingController(text: v.visaExpiryDate),
    );

    return _buildInfoCard(context, [
      Row(
        children: [
          Expanded(
            child: _buildCountryDropdown(
              context,
              label: "Visa Country",
              selected: v.visaCountry,
              editable: isVisaEditing,
              onChanged: (val) => setState(() => v.visaCountry = val ?? ""),
            ),
          ),
          if (isVisaEditing)
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
                          "Delete Visa",
                          style: GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        content: Text(
                          "Are you sure you want to delete this visa?",
                          style: GoogleFonts.inter(),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text("Cancel", style: GoogleFonts.inter()),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(
                              foregroundColor: ThemeConfig.errorColor,
                            ),
                            child: Text("Delete", style: GoogleFonts.inter()),
                          ),
                        ],
                      ),
                );

                if (confirm == true) {
                  await _deleteVisa(v);
                  setState(() {
                    widget.visas.remove(v);
                    _visaDescriptionControllers.remove(v);
                    _visaGrantControllers.remove(v);
                    _visaExpiryControllers.remove(v);
                  });
                }
              },
            ),
        ],
      ),
      const SizedBox(height: 8),
      _buildVisaTypeDropdown(
        context,
        label: "Visa Type",
        selectedId: int.tryParse(v.visaType),
        editable: isVisaEditing,
        onChanged: (id) => setState(() => v.visaType = id?.toString() ?? ""),
      ),
      _buildEditableRow(
        context,
        "Description",
        descriptionController,
        (val) => v.visaDescription = val,
        isVisaEditing,
      ),
      _buildDateRow(
        context,
        "Grant Date",
        grantController,
        (val) => v.visaGrantDate = val ?? "",
        isVisaEditing,
      ),
      _buildDateRow(
        context,
        "Expiry Date",
        expiryController,
        (val) => v.visaExpiryDate = val ?? "",
        isVisaEditing,
      ),
    ]);
  }

  Widget _buildInfoCard(BuildContext context, List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? ThemeConfig.cardDark : ThemeConfig.cardLight;
    final borderColor =
        isDark ? ThemeConfig.borderDark : ThemeConfig.borderLight;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha:0.04),
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

  Widget _buildEditableRow(
    BuildContext context,
    String label,
    TextEditingController controller,
    ValueChanged<String> onChanged,
    bool editable,
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
              child: TextFormField(
                controller: controller,
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
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRow(
    BuildContext context,
    String label,
    TextEditingController controller,
    ValueChanged<String?> onChanged,
    bool editable,
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
                onTap:
                    editable
                        ? () async {
                          final newDate = await _pickDate(controller.text);
                          if (newDate != null) {
                            controller.text = newDate;
                            onChanged(newDate);
                            setState(() {});
                          }
                        }
                        : null,
                child: AbsorbPointer(
                  absorbing: true,
                  child: TextFormField(
                    controller: controller,
                    readOnly: true,
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

  Widget _buildCountryDropdown(
    BuildContext context, {
    required String label,
    required String? selected,
    required bool editable,
    required ValueChanged<String?> onChanged,
  }) {
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
              child:
                  editable
                      ? DropdownButtonFormField<String>(
                        value: selected?.isEmpty ?? true ? null : selected,
                        isExpanded: true,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color:
                              isDark
                                  ? ThemeConfig.textPrimaryDark
                                  : ThemeConfig.textPrimaryLight,
                        ),
                        onChanged: onChanged,
                        items:
                            widget.countries
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c.name,
                                    child: Text(
                                      c.name,
                                      style: GoogleFonts.inter(fontSize: 14),
                                    ),
                                  ),
                                )
                                .toList(),
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
                          fillColor:
                              isDark ? ThemeConfig.cardDark : Colors.white,
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
                      )
                      : Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? ThemeConfig.cardDark : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                isDark
                                    ? ThemeConfig.borderDark
                                    : const Color(0xFFE5E7EB),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          selected ?? "",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color:
                                isDark
                                    ? ThemeConfig.textPrimaryDark
                                    : ThemeConfig.textPrimaryLight,
                          ),
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisaTypeDropdown(
    BuildContext context, {
    required String label,
    required int? selectedId,
    required bool editable,
    required ValueChanged<int?> onChanged,
  }) {
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
              child:
                  editable
                      ? DropdownButtonFormField<int>(
                        value:
                            widget.visaTypes.any((v) => v.id == selectedId)
                                ? selectedId
                                : null,
                        isExpanded: true,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color:
                              isDark
                                  ? ThemeConfig.textPrimaryDark
                                  : ThemeConfig.textPrimaryLight,
                        ),
                        onChanged: onChanged,
                        items:
                            widget.visaTypes
                                .map(
                                  (v) => DropdownMenuItem<int>(
                                    value: v.id,
                                    child: Text(
                                      v.title,
                                      style: GoogleFonts.inter(fontSize: 14),
                                    ),
                                  ),
                                )
                                .toList(),
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
                          fillColor:
                              isDark ? ThemeConfig.cardDark : Colors.white,
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
                      )
                      : Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? ThemeConfig.cardDark : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                isDark
                                    ? ThemeConfig.borderDark
                                    : const Color(0xFFE5E7EB),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          selectedId != null
                              ? (widget.visaTypes
                                  .firstWhere(
                                    (vt) => vt.id == selectedId,
                                    orElse:
                                        () => VisaType(
                                          id: 0,
                                          title: "",
                                          nickName: '',
                                        ),
                                  )
                                  .title)
                              : "",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color:
                                isDark
                                    ? ThemeConfig.textPrimaryDark
                                    : ThemeConfig.textPrimaryLight,
                          ),
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
