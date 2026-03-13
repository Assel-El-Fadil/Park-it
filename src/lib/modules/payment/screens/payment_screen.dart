// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';
// import 'package:src/modules/payment/models/payment_model.dart';
// import 'package:src/modules/payment/widgets/add_payment_method_bottom_sheet.dart';
// import 'package:src/modules/payment/widgets/payment_method_tile.dart';
// import 'package:src/modules/payment/widgets/price_breakdown.dart';
// import 'package:src/shared/widgets/custom_appbar.dart';

// class PaymentScreen extends ConsumerStatefulWidget {
//   final ParkingBooking booking;

//   const PaymentScreen({super.key, required this.booking});

//   @override
//   ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
// }

// class _PaymentScreenState extends ConsumerState<PaymentScreen> {
//   PaymentMethod? _selectedPaymentMethod;
//   bool _isProcessing = false;
//   bool _savePaymentMethod = false;

//   // Mock payment methods - replace with actual data from your backend
//   final List<PaymentMethod> _paymentMethods = [
//     PaymentMethod(
//       id: '1',
//       type: 'Visa',
//       last4: '4242',
//       expiryDate: '12/25',
//       cardHolderName: 'John Doe',
//       isDefault: true,
//     ),
//     PaymentMethod(
//       id: '2',
//       type: 'Mastercard',
//       last4: '8888',
//       expiryDate: '08/24',
//       cardHolderName: 'John Doe',
//       isDefault: false,
//     ),
//     PaymentMethod(
//       id: '3',
//       type: 'PayPal',
//       last4: 'user@email.com',
//       expiryDate: '',
//       cardHolderName: 'John Doe',
//       isDefault: false,
//     ),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     // Select default payment method
//     _selectedPaymentMethod = _paymentMethods.firstWhere(
//       (method) => method.isDefault,
//       orElse: () => _paymentMethods.first,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final formatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       appBar: CustomAppBar(
//         title: 'Payment',
//         automaticallyImplyLeading: true,
//         centerTitle: true,
//         showBottomBorder: false,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.help_outline),
//             onPressed: _showHelpDialog,
//           ),
//         ],
//       ),
//       body: _isProcessing
//           ? _buildProcessingView()
//           : _buildPaymentContent(theme, formatter),
//       bottomNavigationBar: _buildBottomBar(theme, formatter),
//     );
//   }

//   Widget _buildPaymentContent(ThemeData theme, NumberFormat formatter) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Parking Summary Card
//           _buildParkingSummaryCard(theme),

//           const SizedBox(height: 24),

//           // Booking Details
//           _buildBookingDetails(theme),

//           const SizedBox(height: 24),

//           // Payment Methods Section
//           _buildPaymentMethodsSection(theme),

//           const SizedBox(height: 24),

//           // Price Breakdown
//           PriceBreakdown(
//             subtotal: widget.booking.subtotal,
//             serviceFee: widget.booking.serviceFee,
//             total: widget.booking.total,
//             formatter: formatter,
//           ),

//           const SizedBox(height: 24),

//           // Save Payment Method Toggle
//           _buildSavePaymentMethodToggle(theme),

//           const SizedBox(height: 24),

//           // Secure Payment Note
//           _buildSecurePaymentNote(theme),
//         ],
//       ),
//     );
//   }

//   Widget _buildParkingSummaryCard(ThemeData theme) {
//     return Container(
//       decoration: BoxDecoration(
//         color: theme.cardColor,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(20),
//         child: Row(
//           children: [
//             // Parking Image
//             Container(
//               width: 100,
//               height: 100,
//               decoration: BoxDecoration(
//                 image: DecorationImage(
//                   image: widget.booking.parkingImage != null
//                       ? NetworkImage(widget.booking.parkingImage!)
//                       : const AssetImage(
//                               'assets/images/parking_placeholder.jpg',
//                             )
//                             as ImageProvider,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//             // Parking Info
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.all(12),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       widget.booking.parkingName,
//                       style: theme.textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 4),
//                     Row(
//                       children: [
//                         Icon(
//                           Icons.location_on_rounded,
//                           size: 14,
//                           color: Colors.grey[600],
//                         ),
//                         const SizedBox(width: 4),
//                         Expanded(
//                           child: Text(
//                             widget.booking.location,
//                             style: theme.textTheme.bodySmall?.copyWith(
//                               color: Colors.grey[600],
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       children: [
//                         CircleAvatar(
//                           radius: 12,
//                           backgroundImage: NetworkImage(
//                             'https://via.placeholder.com/50', // Host image
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 widget.booking.hostName,
//                                 style: theme.textTheme.bodySmall?.copyWith(
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                               Row(
//                                 children: [
//                                   Icon(
//                                     Icons.star_rounded,
//                                     size: 12,
//                                     color: Colors.amber,
//                                   ),
//                                   const SizedBox(width: 2),
//                                   Text(
//                                     widget.booking.hostRating.toString(),
//                                     style: theme.textTheme.bodySmall,
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBookingDetails(ThemeData theme) {
//     final dateFormat = DateFormat('MMM dd, yyyy');
//     final timeFormat = DateFormat('h:mm a');

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: theme.cardColor,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.withOpacity(0.2)),
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: _buildDetailItem(
//                   theme,
//                   'Start Time',
//                   '${dateFormat.format(widget.booking.startTime)}\n${timeFormat.format(widget.booking.startTime)}',
//                   Icons.login_rounded,
//                 ),
//               ),
//               Container(
//                 width: 40,
//                 child: Icon(
//                   Icons.arrow_forward_rounded,
//                   color: Colors.grey[400],
//                 ),
//               ),
//               Expanded(
//                 child: _buildDetailItem(
//                   theme,
//                   'End Time',
//                   '${dateFormat.format(widget.booking.endTime)}\n${timeFormat.format(widget.booking.endTime)}',
//                   Icons.logout_rounded,
//                 ),
//               ),
//             ],
//           ),
//           const Divider(height: 24),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text('Total Duration', style: theme.textTheme.bodyMedium),
//               Text(
//                 '${widget.booking.totalHours.toStringAsFixed(1)} hours',
//                 style: theme.textTheme.bodyMedium?.copyWith(
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailItem(
//     ThemeData theme,
//     String label,
//     String value,
//     IconData icon,
//   ) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Icon(icon, size: 14, color: Colors.grey[600]),
//             const SizedBox(width: 4),
//             Text(
//               label,
//               style: theme.textTheme.bodySmall?.copyWith(
//                 color: Colors.grey[600],
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 4),
//         Text(
//           value,
//           style: theme.textTheme.bodyMedium?.copyWith(
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildPaymentMethodsSection(ThemeData theme) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               'Payment Method',
//               style: theme.textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             TextButton.icon(
//               onPressed: _showAddPaymentMethodSheet,
//               icon: const Icon(Icons.add_circle_outline, size: 18),
//               label: const Text('Add New'),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         ListView.separated(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: _paymentMethods.length,
//           separatorBuilder: (_, __) => const SizedBox(height: 12),
//           itemBuilder: (context, index) {
//             final method = _paymentMethods[index];
//             return PaymentMethodTile(
//               paymentMethod: method,
//               isSelected: _selectedPaymentMethod?.id == method.id,
//               onTap: () {
//                 setState(() {
//                   _selectedPaymentMethod = method;
//                 });
//               },
//             );
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildSavePaymentMethodToggle(ThemeData theme) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         color: theme.cardColor,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.withOpacity(0.2)),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.lock_outline_rounded, size: 20, color: Colors.grey[600]),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Save payment method',
//                   style: theme.textTheme.bodyMedium?.copyWith(
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 Text(
//                   'Securely save for faster checkout',
//                   style: theme.textTheme.bodySmall?.copyWith(
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Switch(
//             value: _savePaymentMethod,
//             onChanged: (value) {
//               setState(() {
//                 _savePaymentMethod = value;
//               });
//             },
//             activeColor: theme.primaryColor,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSecurePaymentNote(ThemeData theme) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: theme.primaryColor.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.security_rounded, color: theme.primaryColor, size: 24),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Secure Payment',
//                   style: theme.textTheme.bodyMedium?.copyWith(
//                     fontWeight: FontWeight.w600,
//                     color: theme.primaryColor,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   'Your payment information is encrypted and secure',
//                   style: theme.textTheme.bodySmall?.copyWith(
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProcessingView() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 80,
//             height: 80,
//             decoration: BoxDecoration(
//               color: Theme.of(context).primaryColor.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: const Center(child: CircularProgressIndicator()),
//           ),
//           const SizedBox(height: 24),
//           Text(
//             'Processing Payment...',
//             style: Theme.of(
//               context,
//             ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Please do not close the app',
//             style: Theme.of(
//               context,
//             ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBottomBar(ThemeData theme, NumberFormat formatter) {
//     return Container(
//       padding: const EdgeInsets.all(
//         20,
//       ).copyWith(bottom: 20 + MediaQuery.of(context).padding.bottom),
//       decoration: BoxDecoration(
//         color: theme.cardColor,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, -5),
//           ),
//         ],
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(30),
//           topRight: Radius.circular(30),
//         ),
//       ),
//       child: SafeArea(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Total',
//                       style: theme.textTheme.bodySmall?.copyWith(
//                         color: Colors.grey[600],
//                       ),
//                     ),
//                     Text(
//                       formatter.format(widget.booking.total),
//                       style: theme.textTheme.headlineSmall?.copyWith(
//                         fontWeight: FontWeight.bold,
//                         color: theme.primaryColor,
//                       ),
//                     ),
//                   ],
//                 ),
//                 ElevatedButton(
//                   onPressed: _selectedPaymentMethod == null
//                       ? null
//                       : _processPayment,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: theme.primaryColor,
//                     foregroundColor: Colors.white,
//                     minimumSize: const Size(180, 55),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     elevation: 0,
//                   ),
//                   child: const Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(
//                         'Pay Now',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       SizedBox(width: 8),
//                       Icon(Icons.arrow_forward_rounded),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showHelpDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Payment Help'),
//         content: const Text(
//           'Need help with your payment? Contact our support team:\n\n'
//           '• Email: support@parkshare.com\n'
//           '• Phone: +1 (555) 123-4567\n'
//           '• Live Chat: Available 24/7',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Got it'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showAddPaymentMethodSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => const AddPaymentMethodBottomSheet(),
//     );
//   }

//   void _processPayment() async {
//     setState(() => _isProcessing = true);

//     // Simulate payment processing
//     await Future.delayed(const Duration(seconds: 2));

//     if (mounted) {
//       setState(() => _isProcessing = false);

//       // Show success dialog
//       _showSuccessDialog();
//     }
//   }

//   void _showSuccessDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(
//                 color: Colors.green.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.check_circle_rounded,
//                 color: Colors.green,
//                 size: 50,
//               ),
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               'Payment Successful!',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Your booking has been confirmed',
//               style: TextStyle(color: Colors.grey[600]),
//             ),
//           ],
//         ),
//         actions: [
//           Center(
//             child: TextButton(
//               onPressed: () {
//                 // Navigator.pop(context); // Close dialog
//                 // context.go('/bookings'); // Go to bookings page
//               },
//               child: const Text('View My Bookings'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
