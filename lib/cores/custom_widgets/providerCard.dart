import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:home_services_app/cores/custom_widgets/rating_widget.dart';
import 'package:home_services_app/cores/app_colors.dart';
import '../../feature/mainUi/UserScreens/equipment_of_current_provider.dart';
import '../logic/firebaseLogic.dart';
import '../models/user.dart';

class ProviderCard extends StatefulWidget {
  final AppUser user;
  final String currentUserEmail;
  final bool evaluated;

  const ProviderCard({
    Key? key,
    required this.user,
    required this.currentUserEmail,
    this.evaluated = false,
  }) : super(key: key);

  @override
  _ProviderCardState createState() => _ProviderCardState();
}

class _ProviderCardState extends State<ProviderCard> {
  final _auth = FirebaseServices();
  double _userRating = 1;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            _buildProviderImage(),
            const SizedBox(width: 16),
            _buildProviderDetails(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderImage() {
    final isMale = widget.user.gender == true;
    final isProvider = widget.user.isProvider;
    final assetPath = isMale
        ? (isProvider ? "assets/man_service.png" : "assets/man_all.png")
        : (isProvider ? "assets/housekeeper.png" : "assets/women_all.png");
    return Expanded(child: Image.asset(assetPath));
  }

  Widget _buildProviderDetails(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (widget.user.isYearSubscriber) _buildSubscriptionBanner(),
          Text(
            widget.user.username,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text("${widget.user.email}: ايميل"),
          Text("${widget.user.age}: العمر"),
          Text("المنطقة: ${widget.user.area}"),
          if (widget.user.isProvider) ..._buildServiceDetails(),
          const SizedBox(height: 8),
          widget.evaluated
              ? _buildRatingButton(context)
              : !widget.user.isProvider
                  ? Text("")
                  : _buildContactButton(),
        ],
      ),
    );
  }

  Widget _buildSubscriptionBanner() {
    return Container(
      color: Colors.amber,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star, color: AppColors.secoundaryColor),
          const SizedBox(width: 4),
          Text(
            'مشترك سنوي',
            style: TextStyle(
              color: AppColors.primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildServiceDetails() {
    return [
      Text("نوع الخدمة: ${widget.user.serviceDescription ?? ''}"),
      Text(
          "سعر الخدمة/ساعة: ${widget.user.servicePrice?.toStringAsFixed(2) ?? 'N/A'} ريال"),
      Row(
        children: [
          DisplayRating(userId: widget.user.id!),
          const SizedBox(width: 8),
          const Text(': التقييم'),
        ],
      ),
    ];
  }

  Widget _buildRatingButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
      onPressed: () => _showRatingDialog(context),
      child: const Text(
        'انهاء وتقييم الخدمة',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  void _showRatingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(
          child: Text('أضف تقييمك للخدمة',
              style: TextStyle(color: AppColors.primaryColor)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            RatingBar.builder(
              initialRating: 0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4),
              itemBuilder: (context, _) =>
                  const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (rating) => _userRating = rating.toDouble(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('اغلاق'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            onPressed: () {
              _auth.evaluateProvider(widget.user.id!, _userRating);
              _auth.removeProviderFromCurrentUser(widget.user.id!);
              Navigator.of(context).pop();
            },
            child: const Text('اضافة التقييم'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton() {
    return Column(
      children: [
        ElevatedButton(
          style:
              ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EquipmentOfCurrentProvider(
                    servicePrice: widget.user.servicePrice!,
                    providerId: widget.user.id!,
                    providerEmail: widget.user.email,
                    currentUserEmail: widget.currentUserEmail),
              )),
          child: const Text('تفاصيل الادوات وطلب الخدمة',
              style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
