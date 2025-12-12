import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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

  // -------------------------
  // SAVE ADDRESSES (with ID mapping)
  // -------------------------
  Future<void> _saveAddresses() async {
    try {
      // build payload according to backend expectation
      final addressesPayload = widget.addresses.map((a) {
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

        // update local models using returned data (assumes same ordering)
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
          // convert postcode to int if your model expects int; if it's String keep as is
          try {
            local.postcode = int.tryParse(api['postcode']?.toString() ?? '') ?? local.postcode;
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

  // -------------------------
  // SAVE TRAVELS (with ID mapping)
  // -------------------------
  Future<void> _saveTravels() async {
    try {
      final travelsPayload = widget.travels.map((t) {
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

  // -------------------------
  // Add handlers (new items)
  // -------------------------
  void _onAddAddress() {
    setState(() {
      // create a new empty address (use 0 or null for id depending on your model)
      widget.addresses.add(Address(
        id: 0,
        searchAddress: "",
        addressLine1: "",
        addressLine2: "",
        suburb: "",
        state: "",
        postcode: 0,
        country: "",
        regionalCode: "",
        startDate: "",
        endDate: "",
        isCurrent: false,
      ));
      isEditingAddress = true;
    });
  }

  void _onAddTravel() {
    setState(() {
      widget.travels.add(Travel(
        id: 0,
        countryVisited: "",
        arrivalDate: "",
        departureDate: "",
        purpose: "",
      ));
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
                (address) => _buildInfoCard([
              _buildGooglePlaceField(
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
                "Address Line 1",
                address.addressLine1 ?? "-",
                isEditingAddress,
                    (val) => address.addressLine1 = val,
              ),
              _buildEditableRow(
                "Address Line 2",
                address.addressLine2 ?? "-",
                isEditingAddress,
                    (val) => address.addressLine2 = val,
              ),
              _buildEditableRow(
                "Suburb",
                address.suburb,
                isEditingAddress,
                    (val) => address.suburb = val,
              ),
              _buildEditableRow(
                "State",
                address.state,
                isEditingAddress,
                    (val) => address.state = val,
              ),
              _buildEditableRow(
                "Postcode",
                address.postcode.toString(),
                isEditingAddress,
                    (val) =>
                address.postcode = int.tryParse(val) ?? address.postcode,
              ),
              _buildCountryDropdown(
                label: "Country",
                editable: isEditingAddress,
                selected: address.country,
                onChanged: (val) => setState(() => address.country = val ?? ""),
              ),
              _buildEditableRow(
                "Regional Code",
                address.regionalCode ?? "-",
                isEditingAddress,
                    (val) => address.regionalCode = val,
              ),
              _buildDateRow(
                "Start Date",
                address.startDate ?? "-",
                isEditingAddress,
                    (val) => address.startDate = val,
              ),
              _buildDateRow(
                "End Date",
                address.endDate ?? "-",
                isEditingAddress,
                    (val) => address.endDate = val,
              ),
              _buildEditableRow(
                "Is Current",
                address.isCurrent ? "Yes" : "No",
                isEditingAddress,
                    (val) => address.isCurrent = val.toLowerCase() == "yes",
              ),
            ]),
          ),
          const SizedBox(height: 28),
          _buildSectionTitle(
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
            showAdd: true, // enabled add button
          ),
          const SizedBox(height: 12),
          ...widget.travels.map(
                (travel) => _buildInfoCard([
              _buildCountryDropdown(
                label: "Country Visited",
                editable: isEditingTravel,
                selected: travel.countryVisited,
                onChanged:
                    (val) => setState(() => travel.countryVisited = val ?? ""),
              ),
              _buildDateRow(
                "Arrival Date",
                travel.arrivalDate,
                isEditingTravel,
                    (val) => travel.arrivalDate = val!,
              ),
              _buildDateRow(
                "Departure Date",
                travel.departureDate,
                isEditingTravel,
                    (val) => travel.departureDate = val!,
              ),
              _buildEditableRow(
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
      String label,
      String value,
      bool enabled,
      ValueChanged<String> onChanged,
      Future<List<String>> Function(String) fetchPlaceSuggestions,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TypeAheadField<String>(
        suggestionsCallback: (pattern) async {
          if (pattern.isEmpty) return [];
          return await fetchPlaceSuggestions(pattern);
        },

        itemBuilder: (context, suggestion) {
          return ListTile(title: Text(suggestion));
        },

        onSelected: (suggestion) {
          // ✅ onSelected now updates the controller from the builder
          // This ensures the selected value shows
          onChanged(suggestion);
        },

        builder: (context, textEditingController, focusNode) {
          // ✅ Initialize the builder controller with initial value
          if (textEditingController.text != value) {
            textEditingController.text = value;
            textEditingController.selection = TextSelection.fromPosition(
              TextPosition(offset: textEditingController.text.length),
            );
          }

          return TextField(
            controller: textEditingController,
            focusNode: focusNode,
            enabled: enabled,
            decoration: InputDecoration(
              labelText: label.toUpperCase(),
              border: const OutlineInputBorder(),
              suffixIcon: enabled && textEditingController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
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

        emptyBuilder: (context) => const Padding(
          padding: EdgeInsets.all(8),
          child: Text("No results found"),
        ),

        loadingBuilder: (context) => const Padding(
          padding: EdgeInsets.all(8),
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }


  Widget _buildEditableRow(
      String label,
      String value,
      bool enabled,
      ValueChanged<String> onChanged,
      ) {
    final controller = TextEditingController(text: value);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: label.toUpperCase(),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildCountryDropdown({
    required String label,
    required String? selected,
    required bool editable,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label.toUpperCase(),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
        child:
        editable
            ? DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selected!.isEmpty ? null : selected,
            isExpanded: true,
            onChanged: onChanged,
            items:
            widget.countries
                .map(
                  (c) => DropdownMenuItem(
                value: c.name,
                child: Text(c.name),
              ),
            )
                .toList(),
          ),
        )
            : Text(
          selected ?? "",
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDateRow(
      String label,
      String value,
      bool enabled,
      ValueChanged<String?> onChanged,
      ) {
    final controller = TextEditingController(text: value);

    return GestureDetector(
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
        child: Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: TextFormField(
            controller: controller,
            enabled: enabled,
            readOnly: true,
            decoration: InputDecoration(
              labelText: label.toUpperCase(),
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
      String title, {
        required bool isEditing,
        required VoidCallback onEdit,
        required VoidCallback onAdd,
        required IconData icon,
        bool showAdd = false,
      }) {
    return Row(
      children: [
        Icon(icon, color: Colors.white),
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
        InkWell(
          onTap: onEdit,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Icon(
              isEditing ? Icons.check : Icons.edit,
              color: Colors.blue,
              size: 20,
            ),
          ),
        ),
        if (showAdd) const SizedBox(width: 8),
        if (showAdd)
          InkWell(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Icon(Icons.add, color: Colors.blue, size: 20),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 14),
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
