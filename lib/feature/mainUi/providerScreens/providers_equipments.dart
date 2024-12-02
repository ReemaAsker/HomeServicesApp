import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:home_services_app/cores/app_colors.dart';
import 'package:home_services_app/cores/custom_widgets/custom_button.dart';
import 'package:home_services_app/cores/custom_widgets/custom_text_feild.dart';
import 'package:home_services_app/cores/logic/firebaseLogic.dart';
import 'package:home_services_app/cores/models/equipment.dart';

import '../../../cores/custom_widgets/custom_app_bar.dart';
import '../../../cores/custom_widgets/tool_card.dart';

class EquipmentsPage extends StatefulWidget {
  const EquipmentsPage({super.key});

  @override
  State<EquipmentsPage> createState() => _EquipmentsPageState();
}

class _EquipmentsPageState extends State<EquipmentsPage> {
  final firebaseService = FirebaseServices();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  bool _isPrimary = false; // Change to non-nullable

  void emptyAllFeilds() {
    _nameController.text = "";
    _priceController.text = "";
    _isPrimary = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: CustomAppBar(title: "أدواتي"),
      ),
      body: Center(
          child: ToolCard(
        provider_id: FirebaseAuth.instance.currentUser!.uid,
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          emptyAllFeilds();
          showModalBottomSheet(
            shape: const RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(25.0))),
            context: context,
            isScrollControlled: true,
            builder: (context) => Padding(
              padding: EdgeInsets.only(
                  top: 20,
                  right: 20,
                  left: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Form(
                // Wrap in a Form widget
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(
                      controller: _nameController,
                      labelText: 'اسم الأداة',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 30.0),
                    CustomTextField(
                      controller: _priceController,
                      labelText: 'السعر',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الحقل مطلوب';
                        }
                        if (double.tryParse(value) == null) {
                          return 'الادخال خاطئ';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.0),
                    // IsPrimary Checkbox
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: CheckboxListTile(
                        title: Text('هل الأداة أساسية فالعمل؟'),
                        value: _isPrimary,
                        onChanged: (value) {
                          setState(() {
                            _isPrimary = value ?? false;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 10),
                    CustomButton(
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          // If the form is valid, create the Equipment object
                          Equipment newEquipment = Equipment(
                            name: _nameController.text,
                            price: double.parse(_priceController.text),
                            isPrimary: _isPrimary,
                          );
                          // Call the onSubmit callback with the new Equipment object
                          firebaseService.addEquipment(newEquipment);
                          // Close the bottom sheet
                          Navigator.pop(context);
                        }
                      },
                      text: 'اضف الأداة',
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: AppColors.primaryColor,
      ),
    );
  }
}
