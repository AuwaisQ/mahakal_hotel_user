import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

Widget couponBox({
  required BuildContext context,
  required bool isApplied,
  required bool hasCoupons,
  required VoidCallback onApply,
  required VoidCallback onRemove,
}) {
  const orange = Colors.orange;
  const green = Colors.green;

  return InkWell(
    onTap: () {
      if (isApplied) {
        onApply();
      } else {
        hasCoupons
            ? onApply()
            : ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('No coupons available!'),
                backgroundColor: Colors.red,
              ));
      }
    },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: isApplied
            ? LinearGradient(
                colors: [green.shade600, green],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [orange.withOpacity(.12), Colors.transparent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        border: Border.all(
          color: isApplied ? green : orange,
          width: 1.6,
        ),
      ),
      child: Row(
        children: [
          Text(
            isApplied ? 'Coupon Applied' : 'Apply Coupon',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isApplied ? Colors.white : orange,
            ),
          ),
          const Spacer(),
          isApplied
              ? GestureDetector(
                  onTap: onRemove,
                  child:
                      const Icon(Icons.delete, color: Colors.white, size: 22),
                )
              : const Row(
                  children: [
                    Text('Add', style: TextStyle(color: orange, fontSize: 16)),
                    SizedBox(width: 4),
                    Icon(Icons.add, color: orange, size: 22),
                  ],
                ),
        ],
      ),
    ),
  );
}

void showCouponBottomSheet({
  required BuildContext context,
  required TextEditingController couponController,
  required List<dynamic> couponModelList,
  required Function(dynamic couponCode, dynamic amount) onApplyCoupon,
  required String selectedCabTotalAmount,
  required Function(String code, String couponType) onCouponTap,
}) {
  showMaterialModalBottomSheet(
    backgroundColor: Colors.transparent,
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, modalSetter) {
        return Container(
          height: 700,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(color: Colors.grey, blurRadius: 4, spreadRadius: 2),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(height: 4, width: 40, color: Colors.grey[300]),
              const SizedBox(height: 16),
              TextField(
                controller: couponController,
                decoration: InputDecoration(
                  hintText: 'Enter Coupon',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.local_offer, color: Colors.grey),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 5.0),
                    child: ElevatedButton(
                      onPressed: () {
                        modalSetter(() {
                          onApplyCoupon(
                            couponController.text,
                            selectedCabTotalAmount,
                          );
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Apply',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(height: 20, width: 2, color: Colors.orange),
                  const SizedBox(width: 8),
                  const Text(
                    'Available Promo',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: couponModelList.length,
                  itemBuilder: (context, index) {
                    final coupon = couponModelList[index];
                    final isAmount = coupon.discountType == "amount";
                    final discountValue = isAmount
                        ? "₹${coupon.discount}.00"
                        : "${coupon.discount} %";

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            Column(
                              children: [
                                Image.network(
                                  isAmount
                                      ? "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRkplYL67jiq1MrlCAi-DVdpv77KBfNXtjFJg&s"
                                      : "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT5QKzLihvt9Q_wH8nmDI59oiPiVaeScYHBuQ&s",
                                  height: 30,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  discountValue,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "On All Shop",
                                  style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(width: 20),
                            Container(
                              height: 80,
                              width: 2,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      couponController.text = coupon.code;
                                      Clipboard.setData(
                                          ClipboardData(text: coupon.code));
                                      onCouponTap(
                                          coupon.code, coupon.couponType);

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Copied "${coupon.code}" to clipboard'),
                                          duration: const Duration(seconds: 2),
                                          behavior: SnackBarBehavior.floating,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 10),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      height: 36,
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade50,
                                        border:
                                            Border.all(color: Colors.orange),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            coupon.code,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(width: 10),
                                          const Icon(Icons.copy,
                                              size: 18, color: Colors.orange),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Available from minimum purchase\n₹${coupon.minPurchase}.00",
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 14),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    ),
  ).whenComplete(() {
    couponController.clear(); // Reset controller on close
  });
}
