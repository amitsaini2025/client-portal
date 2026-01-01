import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../../config/theme_config.dart';
import '../../../../models/personal_information/address.dart';
import '../../../../models/personal_information/basic_information_post/country/country_model.dart';
import '../../../../models/personal_information/travel.dart';
import '../../../../services/api_service.dart';

class AddressAndTravelInformationWidget extends StatefulWidget {
  final List<Address> addresses;
  final List<Travel> travels;
  final List<Country> countries;

  const AddressAndTravelInformationWidget({
    super.key,
    required this.addresses,
    required this.travels,
    required this.countries,
  });

  @override
  State<AddressAndTravelInformationWidget> createState() =>
      _AddressAndTravelInformationWidgetState();
}

class _AddressAndTravelInformationWidgetState
    extends State<AddressAndTravelInformationWidget> {
  bool isEditingAddress = false;
  bool isEditingTravel = false;
  final Map<String, TextEditingController> _placeControllers = {};

  //final String googleApiKey = "AIzaSyATpl3gyx8FSoykbCx3otznCIWP_-8hk7c";
  final String googleApiKey = "AIzaSyATpl3gyx8FSoykbCx3otznCIWP_-8hk7c";

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

  Future<void> _saveAddresses() async {
    try {
      final addressesPayload =
          widget.addresses.map((a) {
            return {
              "id": (a.id == null || a.id == 0) ? null : a.id,
              "search_address": a.searchAddress ?? "",
              "address_line_1": a.addressLine1 ?? "",
              "address_line_2": a.addressLine2,
              "suburb": a.suburb ?? "",
              "state": a.state ?? "",
              "postcode": a.postcode?.toString() ?? "",
              "country": a.country ?? "",
              "regional_code": a.regionalCode,
              "start_date": a.startDate ?? "",
              "end_date": a.endDate,
              "is_current": a.isCurrent ?? false,
            };
          }).toList();

      final response = await ApiService.updateClientAddressDetail(
        addressesPayload,
      );

      if (response['success'] == true &&
          response['data'] != null &&
          response['data']['addresses'] != null) {
        final List<dynamic> updated = response['data']['addresses'];

        for (int i = 0; i < updated.length; i++) {
          final api = updated[i];
          if (i >= widget.addresses.length) break;
          final local = widget.addresses[i];

          local.id = api['id'];
          local.searchAddress = api['search_address'];
          local.addressLine1 = api['address_line_1'];
          local.addressLine2 = api['address_line_2'];
          local.suburb = api['suburb'];
          local.state = api['state'];
          try {
            local.postcode = local.postcode;
          } catch (_) {
            // fallback: keep existing
          }
          local.country = api['country'];
          local.regionalCode = api['regional_code'];
          local.startDate = api['start_date'];
          local.endDate = api['end_date'];
          local.isCurrent = api['is_current'] ?? false;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Addresses updated successfully')),
        );
        setState(() => isEditingAddress = false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to update addresses'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _saveTravels() async {
    try {
      final travelsPayload =
          widget.travels.map((t) {
            return {
              "id": (t.id == null || t.id == 0) ? null : t.id,
              "country_visited": t.countryVisited ?? "",
              "arrival_date": t.arrivalDate ?? "",
              "departure_date": t.departureDate ?? "",
              "purpose": t.purpose ?? "",
            };
          }).toList();

      final response = await ApiService.updateClientTravelDetail(
        travelsPayload,
      );

      if (response['success'] == true &&
          response['data'] != null &&
          response['data']['travels'] != null) {
        final List<dynamic> updatedTravels = response['data']['travels'];

        for (int i = 0; i < updatedTravels.length; i++) {
          final api = updatedTravels[i];
          if (i >= widget.travels.length) break;
          final local = widget.travels[i];

          local.id = api['id'];
          local.countryVisited = api['country_visited'];
          local.arrivalDate = api['arrival_date'];
          local.departureDate = api['departure_date'];
          local.purpose = api['purpose'];
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Travels updated successfully')),
        );
        setState(() => isEditingTravel = false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to update travels'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<List<String>> fetchPlaceSuggestions(String input) async {
    if (input.isEmpty) return [];
    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$googleApiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['predictions'] as List)
          .map((p) => p['description'] as String)
          .toList();
    } else {
      throw Exception('Failed to fetch suggestions');
    }
  }

  Future<void> _deleteTravel(Travel t) async {
    if (t.id == 0) {
      setState(() => widget.travels.remove(t));
      return;
    }

    final res = await ApiService.deleteClientTabDetail(
      id: t.id!,
      type: "travel",
    );

    if (res['success'] == true) {
      setState(() => widget.travels.remove(t));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Travel Deleted Successfully!")),
      );
    }
  }

  Future<void> _deleteAddress(Address address) async {
    if (address.id == 0) {
      setState(() => widget.travels.remove(address));
      return;
    }

    final res = await ApiService.deleteClientTabDetail(
      id: address.id!,
      type: "address",
    );

    if (res['success'] == true) {
      setState(() => widget.addresses.remove(address));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Address Deleted Successfully!")),
      );
    }
  }

  void _onAddAddress() {
    setState(() {
      widget.addresses.add(
        Address(
          id: 0,
          searchAddress: "",
          addressLine1: "",
          addressLine2: "",
          suburb: "",
          state: "",
          postcode: "0",
          country: "",
          regionalCode: "",
          startDate: "",
          endDate: "",
          isCurrent: false,
        ),
      );
      isEditingAddress = true;
    });
  }

  void _onAddTravel() {
    setState(() {
      widget.travels.add(
        Travel(
          id: 0,
          countryVisited: "",
          arrivalDate: "",
          departureDate: "",
          purpose: "",
        ),
      );
      isEditingTravel = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            context,
            "Address Information",
            icon: Icons.home_rounded,
            isEditing: isEditingAddress,
            onEdit: () {
              if (isEditingAddress) {
                _saveAddresses();
              } else {
                setState(() => isEditingAddress = !isEditingAddress);
              }
            },
            onAdd: _onAddAddress,
            showAdd: true, // enabled add button
          ),
          const SizedBox(height: 12),
          ...widget.addresses.map(
            (address) => _buildInfoCard(context, [
              if (isEditingAddress)
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: ThemeConfig.errorColor,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (_) => AlertDialog(
                              title: Text(
                                "Delete Address",
                                style: GoogleFonts.spaceGrotesk(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              content: Text(
                                "Are you sure you want to delete this address?",
                                style: GoogleFonts.inter(),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    "Cancel",
                                    style: GoogleFonts.inter(),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _deleteAddress(address);
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: ThemeConfig.errorColor,
                                  ),
                                  child: Text(
                                    "Delete",
                                    style: GoogleFonts.inter(),
                                  ),
                                ),
                              ],
                            ),
                      );
                    },
                  ),
                ),
              _buildGooglePlaceField(
                context,
                "Search Address",
                address.searchAddress,
                isEditingAddress,
                (val) {
                  setState(() {
                    address.searchAddress = val;
                  });
                },
                fetchPlaceSuggestions,
              ),
              _buildEditableRow(
                context,
                "Address Line 1",
                address.addressLine1 ?? "-",
                isEditingAddress,
                (val) => address.addressLine1 = val,
              ),
              _buildEditableRow(
                context,
                "Address Line 2",
                address.addressLine2 ?? "-",
                isEditingAddress,
                (val) => address.addressLine2 = val,
              ),
              _buildEditableRow(
                context,
                "Suburb",
                address.suburb,
                isEditingAddress,
                (val) => address.suburb = val,
              ),
              _buildEditableRow(
                context,
                "State",
                address.state,
                isEditingAddress,
                (val) => address.state = val,
              ),
              _buildEditableRow(
                context,
                "Postcode",
                address.postcode.toString(),
                isEditingAddress,
                (val) => address.postcode = address.postcode,
              ),
              _buildCountryDropdown(
                context,
                label: "Country",
                editable: isEditingAddress,
                selected: address.country,
                onChanged: (val) => setState(() => address.country = val ?? ""),
              ),
              _buildEditableRow(
                context,
                "Regional Code",
                address.regionalCode ?? "-",
                isEditingAddress,
                (val) => address.regionalCode = val,
              ),
              _buildDateRow(
                context,
                "Start Date",
                address.startDate ?? "-",
                isEditingAddress,
                (val) => address.startDate = val,
              ),
              _buildDateRow(
                context,
                "End Date",
                address.endDate ?? "-",
                isEditingAddress,
                (val) => address.endDate = val,
              ),
              _buildEditableRow(
                context,
                "Is Current",
                address.isCurrent ? "Yes" : "No",
                isEditingAddress,
                (val) => address.isCurrent = val.toLowerCase() == "yes",
              ),
            ]),
          ),
          const SizedBox(height: 28),
          _buildSectionTitle(
            context,
            "Travel Information",
            icon: Icons.flight_takeoff_rounded,
            isEditing: isEditingTravel,
            onEdit: () {
              if (isEditingTravel) {
                _saveTravels();
              } else {
                setState(() => isEditingTravel = !isEditingTravel);
              }
            },
            onAdd: _onAddTravel,
            showAdd: true,
          ),
          const SizedBox(height: 12),
          ...widget.travels.map(
            (travel) => _buildInfoCard(context, [
              if (isEditingTravel)
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: ThemeConfig.errorColor,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (_) => AlertDialog(
                              title: Text(
                                "Delete Travel",
                                style: GoogleFonts.spaceGrotesk(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              content: Text(
                                "Are you sure you want to delete this travel record?",
                                style: GoogleFonts.inter(),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    "Cancel",
                                    style: GoogleFonts.inter(),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _deleteTravel(travel);
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: ThemeConfig.errorColor,
                                  ),
                                  child: Text(
                                    "Delete",
                                    style: GoogleFonts.inter(),
                                  ),
                                ),
                              ],
                            ),
                      );
                    },
                  ),
                ),
              _buildCountryDropdown(
                context,
                label: "Country Visited",
                editable: isEditingTravel,
                selected: travel.countryVisited,
                onChanged:
                    (val) => setState(() => travel.countryVisited = val ?? ""),
              ),
              _buildDateRow(
                context,
                "Arrival Date",
                travel.arrivalDate,
                isEditingTravel,
                (val) => travel.arrivalDate = val!,
              ),
              _buildDateRow(
                context,
                "Departure Date",
                travel.departureDate,
                isEditingTravel,
                (val) => travel.departureDate = val!,
              ),
              _buildEditableRow(
                context,
                "Travel Purpose",
                travel.purpose,
                isEditingTravel,
                (val) => travel.purpose = val,
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildGooglePlaceField(
    BuildContext context,
    String label,
    String value,
    bool enabled,
    ValueChanged<String> onChanged,
    Future<List<String>> Function(String) fetchPlaceSuggestions,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
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
              child: TypeAheadField<String>(
                suggestionsCallback: (pattern) async {
                  if (pattern.isEmpty) return [];
                  return await fetchPlaceSuggestions(pattern);
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text(suggestion, style: GoogleFonts.inter()),
                  );
                },
                onSelected: (suggestion) {
                  onChanged(suggestion);
                },
                builder: (context, textEditingController, focusNode) {
                  if (textEditingController.text != value) {
                    textEditingController.text = value;
                    textEditingController
                        .selection = TextSelection.fromPosition(
                      TextPosition(offset: textEditingController.text.length),
                    );
                  }

                  return TextField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    enabled: enabled,
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
                      suffixIcon:
                          enabled && textEditingController.text.isNotEmpty
                              ? IconButton(
                                icon: Icon(
                                  Icons.clear_rounded,
                                  color:
                                      isDark
                                          ? ThemeConfig.textSecondaryDark
                                          : ThemeConfig.textSecondaryLight,
                                ),
                                onPressed: () {
                                  textEditingController.clear();
                                  onChanged("");
                                },
                              )
                              : null,
                    ),
                    onChanged: onChanged,
                  );
                },
                emptyBuilder:
                    (context) => Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        "No results found",
                        style: GoogleFonts.inter(),
                      ),
                    ),
                loadingBuilder:
                    (context) => const Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableRow(
    BuildContext context,
    String label,
    String value,
    bool enabled,
    ValueChanged<String> onChanged,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = TextEditingController(text: value);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
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
                enabled: enabled,
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

  Widget _buildCountryDropdown(
    BuildContext context, {
    required String label,
    required String? selected,
    required bool editable,
    required ValueChanged<String?> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
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
                        value: selected!.isEmpty ? null : selected,
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

  Widget _buildDateRow(
    BuildContext context,
    String label,
    String value,
    bool enabled,
    ValueChanged<String?> onChanged,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = TextEditingController(text: value);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
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
                    enabled
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
                  child: TextFormField(
                    controller: controller,
                    enabled: enabled,
                    readOnly: true,
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
    String title, {
    required bool isEditing,
    required VoidCallback onEdit,
    required VoidCallback onAdd,
    required IconData icon,
    bool showAdd = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? ThemeConfig.textPrimaryDark : ThemeConfig.textPrimaryLight;
    final cardColor = isDark ? ThemeConfig.cardDark : ThemeConfig.cardLight;
    final borderColor =
        isDark ? ThemeConfig.borderDark : ThemeConfig.borderLight;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ThemeConfig.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: ThemeConfig.primaryColor, size: 24),
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
          InkWell(
            onTap: onEdit,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color:
                    isEditing
                        ? ThemeConfig.successColor.withOpacity(0.1)
                        : ThemeConfig.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      isEditing
                          ? ThemeConfig.successColor.withOpacity(0.3)
                          : ThemeConfig.primaryColor.withOpacity(0.3),
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
          if (showAdd) const SizedBox(width: 8),
          if (showAdd)
            InkWell(
              onTap: onAdd,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ThemeConfig.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: ThemeConfig.successColor.withOpacity(0.3),
                  ),
                ),
                child: Icon(
                  Icons.add_rounded,
                  color: ThemeConfig.successColor,
                  size: 20,
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
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
