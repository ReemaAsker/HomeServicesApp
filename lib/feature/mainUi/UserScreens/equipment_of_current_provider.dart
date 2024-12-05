import 'package:flutter/material.dart';

import 'package:home_services_app/cores/custom_widgets/custom_app_bar.dart';
import 'package:home_services_app/cores/custom_widgets/custom_button.dart';
import 'package:home_services_app/feature/mainUi/UserScreens/homePage.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../cores/custom_widgets/tool_card.dart';
import '../../../cores/logic/firebaseLogic.dart';

class EquipmentOfCurrentProvider extends StatefulWidget {
  final String providerId;
  final String? currentUserEmail;
  final String? providerEmail;
  final double servicePrice;

  const EquipmentOfCurrentProvider({
    Key? key,
    required this.servicePrice,
    required this.providerId,
    this.currentUserEmail,
    this.providerEmail,
  }) : super(key: key);

  @override
  State<EquipmentOfCurrentProvider> createState() =>
      _EquipmentOfCurrentProviderState();
}

class _EquipmentOfCurrentProviderState
    extends State<EquipmentOfCurrentProvider> {
  final auth = FirebaseServices();
  String? toolMessageExtend;
  String subject = 'طلب الحصول على خدمة';
  String body =
      'مرحبا, اريد ان اتقدم بطلب الحصول على خدمتك فمتى يمكنك الوصول الي؟';
  double servicePrice = 0.0;
  // String emailContent = 'subject=$subject&body=$body&reply-to=$fromEmail';
  Future<void> _sendEmail() async {
    if (toolMessageExtend != null) {
      body += '\nمع هذه المعدات:\n$toolMessageExtend';
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentMethodsScreen(
              toolBody: body,
              servicePrice: servicePrice + widget.servicePrice,
              providerId: widget.providerId,
              providerEmail: widget.providerEmail!,
            ),
          ));
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentMethodsScreen(
              toolBody: "",
              providerEmail: widget.providerEmail!,
              servicePrice: servicePrice + widget.servicePrice,
              providerId: widget.providerId,
            ),
          ));
    }

    // final Uri emailLaunchUri = Uri(
    //   scheme: 'mailto',
    //   path: widget.providerEmail,
    //   query: Uri.encodeFull(
    //       'subject=$subject&body=$body&reply-to=${widget.currentUserEmail}' // 'subject=طلب الحصول على خدمة&body=مرحبا , اريد ان اتقدم بطلب الحصول على خدمتك  )(" "مع هذه الا\وات) فمتى يمكنك الوصول الي؟&reply-to=${widget.currentUserEmail}',
    //       ),
    // );

    // try {
    //   if (await canLaunchUrl(emailLaunchUri)) {
    //     await launchUrl(emailLaunchUri);
    //     await _auth.addRequest(widget.providerId);
    //   } else {
    //     throw 'Could not launch $emailLaunchUri';
    //   }
    //   Navigator.pop(context);
    // } catch (e) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Could not launch email client')),
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        child: CustomAppBar(
          title: "تفاصيل الادوات وطلب الخدمة",
          withReturnArrow: true,
        ),
        preferredSize: const Size.fromHeight(80),
      ),
      body: Column(
        children: [
          Expanded(
              child: ToolCard(
            provider_id: widget.providerId,
            buyAviable: true,
            onItemsUpdated: (toolsInfo, total_tools_price) {
              toolMessageExtend = toolsInfo.toString();
              servicePrice = total_tools_price;
              print("Current added items: $toolMessageExtend");
            },
          )),
          Padding(
            padding: const EdgeInsets.all(20),
            child: CustomButton(
              onTap: _sendEmail,
              text: 'طلب الخدمة',
            ),
          )
        ],
      ),
    );
  }
}

// class PaymentMethodsScreen extends StatefulWidget {
//   final String providerId;
//   final String? currentUserEmail;
//   final String? providerEmail;

//   const PaymentMethodsScreen({
//     Key? key,
//     required this.providerId,
//     this.currentUserEmail,
//     this.providerEmail,
//   }) : super(key: key);

//   @override
//   State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
// }

// class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
//   // Payment methods data
//   final List<Map<String, dynamic>> paymentMethods = [
//     {
//       "name": "نقداً",
//       "image": "assets/cash.png",
//       "requiredFields": [] // No required fields for cash
//     },
//     {
//       "name": "بطاقة ائتمان",
//       "image": "assets/credit_card.png",
//       "requiredFields": [
//         {
//           "label": "رقم البطاقة",
//           "hint": "XXXX-XXXX-XXXX-XXXX",
//           "type": TextInputType.number
//         },
//         {
//           "label": "تاريخ الانتهاء",
//           "hint": "MM/YY",
//           "type": TextInputType.datetime
//         },
//       ]
//     },
//     {
//       "name": "تحويل بنكي",
//       "image": "assets/bank_transfer.png",
//       "requiredFields": [
//         {"label": "رقم الحساب", "hint": "XXXXX", "type": TextInputType.number},
//         {
//           "label": "اسم البنك",
//           "hint": "اسم البنك هنا",
//           "type": TextInputType.text
//         },
//       ]
//     },
//   ];

//   // Show dialog with the required fields for the selected payment method
//   void _showPaymentMethodDialog(
//       BuildContext context, Map<String, dynamic> paymentMethod) {
//     final paymentDetails = <String, String>{};
//     final GlobalKey<FormState> _formKey =
//         GlobalKey<FormState>(); // Add form key for validation

//     showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setDialogState) {
//             return AlertDialog(
//               title: Text("متطلبات الدفع: ${paymentMethod['name']}"),
//               content: SingleChildScrollView(
//                 child: Form(
//                   key: _formKey, // Attach form key
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       ...paymentMethod['requiredFields'].map<Widget>((field) {
//                         return Padding(
//                           padding: const EdgeInsets.only(top: 16),
//                           child: TextFormField(
//                             decoration: InputDecoration(
//                               labelText: field['label'],
//                               hintText: field['hint'],
//                               border: const OutlineInputBorder(),
//                             ),
//                             keyboardType: field['type'],
//                             onSaved: (value) {
//                               paymentDetails[field['label']] = value ?? '';
//                             },
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return "يرجى إدخال ${field['label']}";
//                               } else if (field['label'] == "رقم البطاقة" &&
//                                       value.length < 16 ||
//                                   value.length > 17) {
//                                 return "خطأ";
//                               } else if (field['label'] == "رقم الحساب" &&
//                                       value.length < 5 ||
//                                   value.length > 6) {
//                                 return "خطأ";
//                               }
//                               return null;
//                             },
//                           ),
//                         );
//                       }).toList(),
//                     ],
//                   ),
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                   child: const Text("إلغاء"),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     // Validate the form before confirming
//                     if (_formKey.currentState?.validate() ?? false) {
//                       _formKey.currentState?.save(); // Save the form values
//                       // Proceed with the payment
//                       Navigator.pop(context);
//                       _confirmPayment(paymentDetails, paymentMethod);
//                     }
//                   },
//                   child: const Text("تأكيد"),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   // Confirm the payment and show the total price
//   void _confirmPayment(
//       Map<String, String> paymentDetails, Map<String, dynamic> paymentMethod) {
//     // Calculate total price (for example purposes)
//     final totalAmount =
//         100.0; // Replace this with your actual calculation logic

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text("تأكيد الطلب"),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text("طريقة الدفع: ${paymentMethod['name']}"),
//               ...paymentMethod['requiredFields'].map<Widget>((field) {
//                 return Text(
//                     "${field['label']}: ${paymentDetails[field['label']] ?? 'لم يتم إدخال القيمة'}");
//               }).toList(),
//               Text("المبلغ الإجمالي: $totalAmount"),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: const Text("إلغاء"),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 // Proceed to send the email
//                 _sendEmail(paymentDetails, paymentMethod, totalAmount);
//               },
//               child: const Text("تأكيد"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // Send email with payment details
//   Future<void> _sendEmail(Map<String, String> paymentDetails,
//       Map<String, dynamic> paymentMethod, double totalAmount) async {
//     final emailBody = "تفاصيل الطلب:\n"
//         "طريقة الدفع: ${paymentMethod['name']}\n"
//         "${paymentMethod['requiredFields'].map((field) => "${field['label']}: ${paymentDetails[field['label']] ?? 'لم يتم إدخال القيمة'}").join('\n')}\n"
//         "المبلغ الإجمالي: $totalAmount";

//     final Uri emailLaunchUri = Uri(
//       scheme: 'mailto',
//       path: widget.providerEmail,
//       query: Uri.encodeFull(
//         'subject=طلب الحصول على خدمة&body=$emailBody&reply-to=${widget.currentUserEmail}',
//       ),
//     );

//     try {
//       if (await canLaunchUrl(emailLaunchUri)) {
//         await launchUrl(emailLaunchUri);
//       } else {
//         throw 'Could not launch $emailLaunchUri';
//       }
//       Navigator.pop(context);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Could not launch email client')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: PreferredSize(
//         child: CustomAppBar(
//           title: "طرق الدفع",
//           withReturnArrow: true,
//         ),
//         preferredSize: const Size.fromHeight(80),
//       ),
//       body: GridView.builder(
//         padding: const EdgeInsets.all(8.0),
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2, // Number of columns in the grid
//           crossAxisSpacing: 5,
//           mainAxisSpacing: 10,
//           childAspectRatio: 1.0,
//         ),
//         itemCount: paymentMethods.length,
//         itemBuilder: (context, index) {
//           final method = paymentMethods[index];
//           return GestureDetector(
//             onTap: () {
//               _showPaymentMethodDialog(context, method);
//             },
//             child: Card(
//               elevation: 5,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Image.asset(method['image'], width: 50, height: 50),
//                   const SizedBox(height: 8),
//                   Text(
//                     method['name'],
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

class PaymentMethodsScreen extends StatefulWidget {
  final String providerId;
  final String? currentUserEmail;
  final String providerEmail;
  final double? servicePrice;
  final String? toolBody;

  PaymentMethodsScreen({
    Key? key,
    required this.providerId,
    this.currentUserEmail,
    required this.providerEmail,
    this.servicePrice,
    this.toolBody,
  }) : super(key: key);

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final auth = FirebaseServices();

  // Payment methods data
  final List<Map<String, dynamic>> paymentMethods = [
    {
      "name": "نقداً",
      "image": "assets/cash.png",
      "requiredFields": [] // No required fields for cash
    },
    {
      "name": "بطاقة ائتمان",
      "image": "assets/credit_card.png",
      "requiredFields": [
        {
          "label": "رقم البطاقة",
          "hint": "XXXX-XXXX-XXXX-XXXX",
          "type": TextInputType.number
        },
        {
          "label": "تاريخ الانتهاء",
          "hint": "MM/YY",
          "type": TextInputType.datetime,
          "isDate": true
        }, // Added isDate field for DatePicker
      ]
    },
    {
      "name": "تحويل بنكي",
      "image": "assets/bank_transfer.png",
      "requiredFields": [
        {"label": "رقم الحساب", "hint": "XXXXX", "type": TextInputType.number},
        {
          "label": "اسم البنك",
          "hint": "اسم البنك هنا",
          "type": TextInputType.text
        },
      ]
    },
  ];

  // Show dialog with the required fields for the selected payment method
  void _showPaymentMethodDialog(
      BuildContext context, Map<String, dynamic> paymentMethod) {
    final paymentDetails = <String, String>{};
    final GlobalKey<FormState> _formKey =
        GlobalKey<FormState>(); // Add form key for validation

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("متطلبات الدفع: ${paymentMethod['name']}"),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey, // Attach form key
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...paymentMethod['requiredFields'].map<Widget>((field) {
                        if (field['isDate'] == true) {
                          // If it's the date field, show a DatePicker
                          return Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: GestureDetector(
                              onTap: () async {
                                DateTime? selectedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2101),
                                );

                                if (selectedDate != null) {
                                  // Check if the selected date is at least one month after the current date
                                  DateTime currentDate = DateTime.now();
                                  DateTime dateOneMonthLater =
                                      currentDate.add(Duration(days: 30));

                                  if (selectedDate
                                      .isBefore(dateOneMonthLater)) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'تاريخ الانتهاء اقل من شهر لا يمكن اتمام العملية ')),
                                    );
                                  } else {
                                    setDialogState(() {
                                      paymentDetails[field['label']] =
                                          "${selectedDate.toLocal()}"
                                              .split(' ')[0]; // Format the date
                                    });
                                  }
                                }
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: field['label'],
                                  hintText: field['hint'],
                                  border: const OutlineInputBorder(),
                                ),
                                child: Text(
                                  paymentDetails[field['label']] ??
                                      field[
                                          'hint'], // Show selected date or hint
                                  style: TextStyle(
                                      color:
                                          paymentDetails[field['label']] != null
                                              ? Colors.black
                                              : Colors.grey),
                                ),
                              ),
                            ),
                          );
                        } else {
                          // If not a date field, show a TextFormField
                          return Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: field['label'],
                                hintText: field['hint'],
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: field['type'],
                              onSaved: (value) {
                                paymentDetails[field['label']] = value ?? '';
                              },
                              validator: (value) {
                                print(field['label']);
                                if (value == null || value.isEmpty) {
                                  return "يرجى إدخال ${field['label']}";
                                } else if (field['label'] == "رقم البطاقة" &&
                                    value.length != 16) {
                                  return "خطأ";
                                } else if (field['label'] == "رقم الحساب" &&
                                    value.length != 5) {
                                  return "خطأ";
                                }
                                return null;
                              },
                            ),
                          );
                        }
                      }).toList(),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("إلغاء"),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Validate the form before confirming
                    if (_formKey.currentState?.validate() ?? false) {
                      _formKey.currentState?.save(); // Save the form values
                      // Proceed with the payment
                      Navigator.pop(context);
                      _confirmPayment(paymentDetails, paymentMethod);
                    }
                  },
                  child: const Text("تأكيد"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Confirm the payment and show the total price
  void _confirmPayment(
      Map<String, String> paymentDetails, Map<String, dynamic> paymentMethod) {
    // Calculate total price (for example purposes)
    final totalAmount =
        100.0; // Replace this with your actual calculation logic

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("تأكيد الطلب"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("طريقة الدفع: ${paymentMethod['name']}"),
              ...paymentMethod['requiredFields'].map<Widget>((field) {
                return Text(
                    "${field['label']}: ${paymentDetails[field['label']] ?? 'لم يتم إدخال القيمة'}");
              }).toList(),
              Text("المبلغ الإجمالي: ${widget.servicePrice}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("إلغاء"),
            ),
            ElevatedButton(
              onPressed: () {
                // Proceed to send the email
                _sendEmail(paymentDetails, paymentMethod, totalAmount);
              },
              child: const Text("تأكيد"),
            ),
          ],
        );
      },
    );
  }

  // Send email with payment details
  Future<void> _sendEmail(Map<String, String> paymentDetails,
      Map<String, dynamic> paymentMethod, double totalAmount) async {
    final emailBody = "تفاصيل الطلب:\n ${widget.toolBody}\n"
        "طريقة الدفع: ${paymentMethod['name']}\n"
        "${paymentMethod['requiredFields'].map((field) => "${field['label']}: ${paymentDetails[field['label']] ?? 'لم يتم إدخال القيمة'}").join('\n')}\n"
        "المبلغ الإجمالي: ${widget.servicePrice}";

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: widget.providerEmail,
      query: Uri.encodeFull(
        'subject=طلب الحصول على خدمة&body=$emailBody&reply-to=${widget.providerEmail}',
      ),
    );

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ));
        await launchUrl(emailLaunchUri);
        await auth.addRequest(widget.providerId);
      } else {
        throw 'Could not launch $emailLaunchUri';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch email client')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("طرق الدفع")),
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Number of columns in the grid
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.0,
        ),
        itemCount: paymentMethods.length,
        itemBuilder: (context, index) {
          final method = paymentMethods[index];
          return GestureDetector(
            onTap: () {
              _showPaymentMethodDialog(context, method);
            },
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(method['image'], width: 50, height: 50),
                  const SizedBox(height: 8),
                  Text(
                    method['name'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
