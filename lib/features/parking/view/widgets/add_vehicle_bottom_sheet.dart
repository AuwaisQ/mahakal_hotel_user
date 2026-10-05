import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mahakal/features/parking/controller/parking_controller.dart';
import 'package:mahakal/features/parking/model/vehicle_type_model.dart';
import 'package:provider/provider.dart';

class AddVehicleBottomSheet extends StatefulWidget {
  const AddVehicleBottomSheet({super.key});

  @override
  State<AddVehicleBottomSheet> createState() => _AddVehicleBottomSheetState();
}

class _AddVehicleBottomSheetState extends State<AddVehicleBottomSheet> {
  int _currentStep = 0;
  VehicleType? _selectedType;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Consumer<ParkingController>(
        builder: (context, controller, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  if (_currentStep > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => setState(() => _currentStep--),
                    ),
                  Text(
                    _currentStep == 0 ? "Select Vehicle Type" : "Enter Vehicle Details",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_currentStep == 0) _buildTypeSelection(controller),
              if (_currentStep == 1) _buildDetailsForm(controller),
              const SizedBox(height: 30),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTypeSelection(ParkingController controller) {
    if (controller.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(color: Colors.blue),
        ),
      );
    }
    
    if (controller.vehicleTypeList.isEmpty) {
      return Center(
        child: Column(
          children: [
            const Text("No vehicle types available"),
            TextButton(
              onPressed: () => controller.getVehicleTypeList(),
              child: const Text("Retry"),
            )
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.2,
      ),
      itemCount: controller.vehicleTypeList.length,
      itemBuilder: (context, index) {
        final type = controller.vehicleTypeList[index];
        bool isSelected = _selectedType?.id == type.id;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedType = type;
              _nameController.text = type.nameEn ?? "";
              _currentStep = 1;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue.withOpacity(0.05) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey.shade200,
                width: 1.5,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ] : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (type.image != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.grey.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Image.network(
                      type.image!, 
                      height: 50, 
                      width: 50,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        type.nameEn?.toLowerCase() == 'bike' ? Icons.pedal_bike : Icons.directions_car,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  type.nameEn?.toUpperCase() ?? "",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isSelected ? Colors.blue : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailsForm(ParkingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(_nameController, "Vehicle Type", Icons.category_outlined, readOnly: true),
        const SizedBox(height: 15),
        _buildTextField(
          _numberController, 
          "Vehicle Registration Number (e.g. MP13JH4372)", 
          Icons.directions_car_rounded,
          textCapitalization: TextCapitalization.characters,
        ),
        const SizedBox(height: 25),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: controller.isLoading
                ? null
                : () async {
                    final regNo = _numberController.text.trim().replaceAll(' ', '').toUpperCase();
                    if (regNo.isEmpty) {
                      Fluttertoast.showToast(
                        msg: "Please enter vehicle registration number",
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                      );
                      return;
                    }

                    // Indian Vehicle Registration Number pattern (e.g. MP13JH4372, DL01AB1234)
                    final vehicleRegex = RegExp(r'^[A-Z]{2}[0-9]{1,2}[A-Z]{1,3}[0-9]{4}$');
                    if (!vehicleRegex.hasMatch(regNo)) {
                      Fluttertoast.showToast(
                        msg: "Please enter a valid vehicle number (e.g. MP13JH4372)",
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                      );
                      return;
                    }
                    
                    bool success = await controller.addVehicle(
                      vehicleId: _selectedType?.id,
                      cabName: _nameController.text.trim(),
                      cabRegisterNumber: regNo,
                      color: "",
                      aadhar: "",
                    );
                    
                    if (success) {
                      if (context.mounted) Navigator.pop(context);
                      Fluttertoast.showToast(
                        msg: "Vehicle added successfully", 
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                      );
                    } else {
                      Fluttertoast.showToast(
                        msg: "Failed to add vehicle. Please try again.", 
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: controller.isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text("Add Vehicle", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller, 
    String label, 
    IconData icon, {
    TextInputType? keyboardType, 
    int? maxLength, 
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      maxLength: maxLength,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: Colors.blue.shade300),
        counterText: "",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.blue, width: 1.5)),
        filled: true,
        fillColor: readOnly ? Colors.grey.shade100 : Colors.grey.shade50,
      ),
    );
  }
}
