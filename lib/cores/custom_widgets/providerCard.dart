import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:home_services_app/cores/custom_widgets/rating_widget.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:home_services_app/cores/app_colors.dart';

import '../../logic/authLogic.dart';
import '../models/user.dart';

class ProviderCard extends StatefulWidget {
  final AppUser user; //provider / user
  final String currentUserEmail;
  final bool evaluated; // Change to non-nullable boolean
  const ProviderCard({
    Key? key,
    required this.user,
    required this.currentUserEmail,
    this.evaluated = false,
    // this.isSubscriber = false, // Set default value to false
  }) : super(key: key);

  @override
  State<ProviderCard> createState() => _ProviderCardState();
}

class _ProviderCardState extends State<ProviderCard> {
  final _auth = AuthService();
  double _userRating = 1;

  // Method to launch email client
  void _sendEmail(
      String providerEmail, String fromEmail, String providerID) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: providerEmail,
      query: Uri.encodeFull(
        'subject=Inquiry&body=مرحبا , اريد ان اتقدم بطلب  الحصول على خدمتك فمتى يمكنك الوصول الي ؟&reply-to=$fromEmail',
      ),
    );

    try {
      // Attempt to launch the email client
      if (await canLaunch(emailLaunchUri.toString())) {
        await launch(emailLaunchUri.toString());
        _auth.addRequest(providerID);
      } else {
        throw 'Could not launch $emailLaunchUri';
      }
    } catch (e) {
      // Handle error gracefully
      print('Error launching email: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch email client')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
                child: widget.user.gender == true
                    ? widget.user.isProvider
                        ? Image.asset("assets/man_service.png")
                        : Image.asset("assets/man_all.png")
                    : widget.user.isProvider
                        ? Image.asset("assets/housekeeper.png")
                        : Image.asset("assets/women_all.png")),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                widget.user.isYearSubscriber
                    ? Container(
                        color: Colors.amber, // Background color of the banner
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: AppColors.secoundaryColor,
                            ),
                            Text(
                              'مشترك سنوي',
                              style: TextStyle(
                                color: AppColors.primaryColor, // Text color
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Text(''),
                Text(
                  widget.user.username,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "${widget.user.email}: ايميل ",
                  textAlign: TextAlign.right,
                ),
                Text(
                  "${widget.user.age}: العمر  ",
                  textAlign: TextAlign.right,
                ),
                Text(
                  " المنطقة : ${widget.user.area}",
                  textAlign: TextAlign.right,
                ),
                if (widget.user.isProvider) ...[
                  const SizedBox(height: 8),
                  Text("نوع الخدمة: ${widget.user.serviceDescription ?? ''}"),
                  Text(
                      "سعر الخدمة/ساعة: ${widget.user.servicePrice?.toStringAsFixed(2) ?? 'N/A'} ريال"),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      DisplayRating(userId: widget.user.id!),
                      // RatingBarIndicator(
                      //   rating: widget.user.ratingReview ?? 0.0,
                      //   itemBuilder: (context, index) => const Icon(
                      //     Icons.star,
                      //     color: Colors.amber,
                      //   ),
                      //   itemCount: 5,
                      //   itemSize: 24.0,
                      //   direction: Axis.horizontal,
                      // ),
                      const SizedBox(width: 8),
                      const Text(': التقييم '),
                    ],
                  ),
                ],
                SizedBox(height: 8),
                Row(
                  children: [
                    widget.evaluated
                        ? Padding(
                            padding: EdgeInsets.all(8.0),
                            child: StreamBuilder<bool>(
                              stream: _auth.hasUserRated(widget.user.id!),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator(); // Loading indicator
                                }

                                if (snapshot.hasError) {
                                  return Text('Error'); // Handle errors
                                }

                                bool hasRated = snapshot.data ?? false;

                                return ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        hasRated ? Colors.grey : Colors.amber,
                                  ),
                                  onPressed: hasRated
                                      ? null // Disable the button if the user has already rated
                                      : () {
                                          // Show the rating popup
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: Center(
                                                child: Text(
                                                  'أضف تقييمك للخدمة',
                                                  style: TextStyle(
                                                      color: AppColors
                                                          .primaryColor),
                                                ),
                                              ),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  // Text(
                                                  //   ':أضف تفييمك للخدمة',
                                                  //   style: TextStyle(
                                                  //       fontWeight:
                                                  //           FontWeight.bold),
                                                  // ),
                                                  SizedBox(height: 16.0),
                                                  RatingBar.builder(
                                                    initialRating: 0,
                                                    minRating: 1,
                                                    direction: Axis.horizontal,
                                                    allowHalfRating: false,
                                                    itemCount: 5,
                                                    itemPadding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 4.0),
                                                    itemBuilder: (context, _) =>
                                                        Icon(
                                                      Icons.star,
                                                      color: Colors.amber,
                                                    ),
                                                    onRatingUpdate: (rating) {
                                                      _userRating =
                                                          rating.toDouble();
                                                    },
                                                  ),
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(); // Close dialog
                                                  },
                                                  child: Text('اغلاق'),
                                                ),
                                                ElevatedButton(
                                                  style: ButtonStyle(
                                                    foregroundColor:
                                                        WidgetStateProperty.all(
                                                            AppColors
                                                                .primaryColor),
                                                    backgroundColor:
                                                        WidgetStateProperty.all(
                                                            Colors.amber),
                                                  ),
                                                  onPressed: () {
                                                    _auth.evaluatedProvider(
                                                        widget.user.id!,
                                                        _userRating);

                                                    // Close the dialog after submitting the rating
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text('اضاقة التقييم'),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                  child: Text(
                                    hasRated ? 'تم التقييم' : '!اضف تقييمك',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                );
                              },
                            ),
                          )
                        : Text(""),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                      ),
                      onPressed: () {
                        _sendEmail(widget.user.email, widget.currentUserEmail,
                            widget.user.id!); // Pass the provider's email
                      },
                      child: Text(
                        'تواصل الآن',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                widget.evaluated
                    ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Center(
                                child: Text(
                                  'أضف تقييمك للخدمة',
                                  style:
                                      TextStyle(color: AppColors.primaryColor),
                                ),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Text(
                                  //   ':أضف تفييمك للخدمة',
                                  //   style: TextStyle(
                                  //       fontWeight:
                                  //           FontWeight.bold),
                                  // ),
                                  SizedBox(height: 16.0),
                                  RatingBar.builder(
                                    initialRating: 0,
                                    minRating: 1,
                                    direction: Axis.horizontal,
                                    allowHalfRating: false,
                                    itemCount: 5,
                                    itemPadding:
                                        EdgeInsets.symmetric(horizontal: 4.0),
                                    itemBuilder: (context, _) => Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    onRatingUpdate: (rating) {
                                      _userRating = rating.toDouble();
                                    },
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Close dialog
                                  },
                                  child: Text('اغلاق'),
                                ),
                                ElevatedButton(
                                  style: ButtonStyle(
                                    foregroundColor: WidgetStateProperty.all(
                                        AppColors.primaryColor),
                                    backgroundColor:
                                        WidgetStateProperty.all(Colors.amber),
                                  ),
                                  onPressed: () {
                                    _auth.evaluatedProvider(
                                        widget.user.id!, _userRating);
                                    _auth.removeProviderFromCurrentUser(
                                        widget.user.id!);

                                    // Close the dialog after submitting the rating
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('اضاقة التقييم'),
                                ),
                              ],
                            ),
                          );
                        },

                        //  {
                        //   //////////////////////////////
                        //   _auth.removeProviderFromCurrentUser(widget.user.id!);
                        // },
                        child: Text(
                          'انهاء الخدمة',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : Text("")
              ],
            ),
          ],
        ),
      ),
    );
  }
}
