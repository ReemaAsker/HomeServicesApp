import 'package:flutter/material.dart';
import 'package:home_services_app/cores/app_colors.dart';
import '../logic/firebaseLogic.dart';
import '../models/equipment.dart';

class ToolCard extends StatefulWidget {
  final String provider_id;
  final bool buyAviable;
  final Function(List<String> addedItemsList, double total_tools_price)?
      onItemsUpdated;

  ToolCard({
    Key? key,
    required this.provider_id,
    this.buyAviable = false,
    this.onItemsUpdated,
  }) : super(key: key);

  @override
  State<ToolCard> createState() => _ToolCardState();
}

class _ToolCardState extends State<ToolCard> {
  final Map<String, bool> _addedItems = {};
  final List<String> _addedItemsList = [];
  double _totalPrice = 0.0; // Variable to track the total price

  @override
  Widget build(BuildContext context) {
    final firebaseServices = FirebaseServices();

    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<Equipment>>(
            stream: firebaseServices.getUserEquipmentStream(widget.provider_id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('لا يوجد معدات'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('لا يوجد معدات'));
              }

              final List<Equipment> equipmentList = snapshot.data!;

              return ListView.builder(
                itemCount: equipmentList.length,
                itemBuilder: (context, index) {
                  final equipment = equipmentList[index];
                  final isAdded = _addedItems[equipment.id] ?? false;

                  return Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Card(
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: ListTile(
                          title: Row(
                            children: [
                              Icon(
                                Icons.handyman,
                                color: equipment.isPrimary
                                    ? AppColors.primaryColor
                                    : AppColors.secoundaryColor,
                              ),
                              SizedBox(width: 10),
                              Text(
                                equipment.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            "السعر: ${equipment.price} ريال\n ${equipment.isPrimary ? "أداة أساسية" : "أداة ثانوية"}",
                            style: TextStyle(
                              color: equipment.isPrimary
                                  ? AppColors.primaryColor
                                  : AppColors.secoundaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: !widget.buyAviable
                              ? IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 30,
                                  ),
                                  onPressed: () async {
                                    bool confirmed =
                                        await _showDeleteConfirmationDialog(
                                            context);
                                    if (confirmed) {
                                      firebaseServices
                                          .deleteEquipment(equipment.id!);
                                    }
                                  },
                                )
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isAdded
                                        ? Colors.red
                                        : AppColors.primaryColor,
                                  ),
                                  child: Text(
                                    isAdded ? "الغاء الاضافة" : "اضافة",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      if (isAdded) {
                                        // Remove item from added list and update total price
                                        _addedItems[equipment.id!] = false;
                                        _addedItemsList.remove(equipment.name +
                                            ">>" +
                                            equipment.price.toString());
                                        _totalPrice -= equipment.price;
                                      } else {
                                        // Add item to added list and update total price
                                        _addedItems[equipment.id!] = true;
                                        _addedItemsList.add(equipment.name +
                                            ">>" +
                                            equipment.price.toString());
                                        _totalPrice += equipment.price;
                                      }
                                      widget.onItemsUpdated
                                          ?.call(_addedItemsList, _totalPrice);
                                    });
                                  },
                                ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        // if (widget.buyAviable)
        //   Padding(
        //     padding: const EdgeInsets.all(16.0),
        //     child: ElevatedButton(
        //       onPressed: () {
        //         if (_addedItemsList.isNotEmpty) {
        //           ScaffoldMessenger.of(context).showSnackBar(
        //             SnackBar(
        //               content: Text("الإجمالي: $_totalPrice ريال"),
        //               duration: Duration(seconds: 2),
        //             ),
        //           );
        //         } else {
        //           ScaffoldMessenger.of(context).showSnackBar(
        //             SnackBar(
        //               content: Text("يرجى إضافة أدوات لحساب الإجمالي"),
        //               duration: Duration(seconds: 2),
        //             ),
        //           );
        //         }
        //       },
        //       style: ElevatedButton.styleFrom(
        //         backgroundColor: AppColors.primaryColor,
        //       ),
        //       child: Text("طلب الخدمة"),
        //     ),
        //   ),
      ],
    );
  }

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('تأكيد الحذف'),
          content: Text('هل أنت متأكد من حذف هذه الأداة؟'),
          actions: [
            TextButton(
              child: Text('إلغاء'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('حذف'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }
}
