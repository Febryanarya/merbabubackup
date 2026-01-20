import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:merbabuaccess_app/models/cart_item_model.dart';
import 'package:merbabuaccess_app/services/cart_service.dart';
import 'package:merbabuaccess_app/core/routes/app_routes.dart';
import 'package:merbabuaccess_app/core/theme/app_theme.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();
  late Future<List<CartItem>> _cartFuture;
  double _totalPrice = 0;
  double _discount = 0;
  final TextEditingController _voucherController = TextEditingController();
  bool _isApplyingVoucher = false;
  bool _voucherApplied = false;

  @override
  void initState() {
    super.initState();
    _cartFuture = _cartService.getCartItems();
    _calculateTotal();
  }

  Future<void> _calculateTotal() async {
    final total = await _cartService.getTotalPrice();
    setState(() {
      _totalPrice = total;
    });
  }

  Future<void> _refreshCart() async {
    setState(() {
      _cartFuture = _cartService.getCartItems();
    });
    await _calculateTotal();
  }

  Future<void> _removeItem(CartItem item) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Item'),
        content: Text('Hapus ${item.paketName} dari keranjang?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _cartService.removeFromCart(
                item.paketId,
                item.tanggalBooking,
              );
              await _refreshCart();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${item.paketName} dihapus dari keranjang'),
                  backgroundColor: AppTheme.successColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateQuantity(CartItem item, int newQuantity) async {
    if (newQuantity < 1) return;

    await _cartService.updateQuantity(
      item.paketId,
      item.tanggalBooking,
      newQuantity,
    );
    await _refreshCart();
  }

  Future<void> _applyVoucher() async {
    if (_voucherController.text.isEmpty) return;

    setState(() => _isApplyingVoucher = true);
    await Future.delayed(const Duration(seconds: 1));

    // Simulasi voucher validation
    final voucher = _voucherController.text.trim().toLowerCase();
    if (voucher == 'merbabu10' || voucher == 'gunung10') {
      setState(() {
        _discount = _totalPrice * 0.1; // 10% discount
        _voucherApplied = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Voucher berhasil diterapkan!'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Kode voucher tidak valid'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    setState(() => _isApplyingVoucher = false);
  }

  void _removeVoucher() {
    setState(() {
      _discount = 0;
      _voucherApplied = false;
      _voucherController.clear();
    });
  }

  void _clearCart() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kosongkan Keranjang'),
        content: const Text('Hapus semua item dari keranjang?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _cartService.clearCart();
              await _refreshCart();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Keranjang berhasil dikosongkan'),
                  backgroundColor: AppTheme.successColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text(
              'Kosongkan',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _proceedToCheckout() {
    if (_totalPrice == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Keranjang kosong'),
          backgroundColor: AppTheme.warningColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.pushNamed(context, AppRoutes.checkout, arguments: {
      'total': _totalPrice - _discount,
      'discount': _discount,
    });
  }

  double get _finalPrice => _totalPrice - _discount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Booking'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshCart,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ PROMO BANNER
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryLight, AppTheme.primaryColor],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.local_offer, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Gunakan kode "MERBABU10" untuk diskon 10%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: FutureBuilder<List<CartItem>>(
              future: _cartFuture,
              builder: (context, snapshot) {
                // ✅ LOADING STATE
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: AppTheme.primaryColor,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Memuat keranjang...',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                // ✅ ERROR STATE
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppTheme.errorColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.error_outline,
                              size: 40,
                              color: AppTheme.errorColor,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Gagal memuat keranjang',
                            style: AppTheme.titleMedium.copyWith(
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Terjadi kesalahan saat mengambil data',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _refreshCart,
                            icon: const Icon(Icons.refresh, size: 20),
                            label: const Text('Coba Lagi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final cartItems = snapshot.data ?? [];

                // ✅ EMPTY STATE
                if (cartItems.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.shopping_cart_outlined,
                              size: 60,
                              color: AppTheme.primaryColor.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Keranjang Kosong',
                            style: AppTheme.titleLarge.copyWith(
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              'Tambahkan paket pendakian ke keranjang untuk memulai petualanganmu',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.explore_outlined),
                            label: const Text('Jelajahi Paket'),
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // ✅ CART ITEMS LIST
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    final dateFormat = DateFormat('dd MMM yyyy');

                    return Dismissible(
                      key: ValueKey(item.paketId + item.tanggalBooking.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.delete_outline,
                          color: AppTheme.errorColor,
                          size: 30,
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Hapus Item'),
                            content: Text(
                                'Hapus ${item.paketName} dari keranjang?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: const Text('Batal'),
                              ),
                              ElevatedButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.errorColor,
                                ),
                                child: const Text('Hapus'),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (direction) => _removeItem(item),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ✅ PACKAGE IMAGE
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: item.imageUrl.isNotEmpty
                                      ? Image.network(
                                          item.imageUrl,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        )
                                      : Icon(
                                          Icons.terrain,
                                          size: 40,
                                          color: AppTheme.primaryColor,
                                        ),
                                ),
                              ),
                              const SizedBox(width: 16),

                              // ✅ PACKAGE DETAILS
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.paketName,
                                      style: AppTheme.labelLarge.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textPrimary,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.route,
                                          size: 14,
                                          color: AppTheme.textSecondary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          item.paketRoute,
                                          style: AppTheme.bodySmall.copyWith(
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 14,
                                          color: AppTheme.textSecondary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          dateFormat.format(item.tanggalBooking),
                                          style: AppTheme.bodySmall.copyWith(
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // ✅ QUANTITY CONTROLS
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: AppTheme.borderColor,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  Icons.remove,
                                                  size: 18,
                                                  color: item.jumlahOrang > 1
                                                      ? AppTheme.primaryColor
                                                      : AppTheme.textDisabled,
                                                ),
                                                onPressed: item.jumlahOrang > 1
                                                    ? () => _updateQuantity(
                                                        item,
                                                        item.jumlahOrang - 1)
                                                    : null,
                                                padding: const EdgeInsets.all(4),
                                              ),
                                              Container(
                                                width: 40,
                                                alignment: Alignment.center,
                                                child: Text(
                                                  '${item.jumlahOrang}',
                                                  style:
                                                      AppTheme.labelLarge.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.add,
                                                  size: 18,
                                                  color: AppTheme.primaryColor,
                                                ),
                                                onPressed: () =>
                                                    _updateQuantity(
                                                        item,
                                                        item.jumlahOrang + 1),
                                                padding: const EdgeInsets.all(4),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          'Rp ${_formatPrice(item.totalHarga)}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // ✅ CART SUMMARY & CHECKOUT
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: AppTheme.borderColor, width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                // ✅ VOUCHER INPUT
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _voucherController,
                        decoration: InputDecoration(
                          hintText: _voucherApplied
                              ? 'Voucher diterapkan'
                              : 'Masukkan kode voucher',
                          prefixIcon: Icon(
                            Icons.local_offer_outlined,
                            color: AppTheme.textSecondary,
                          ),
                          suffixIcon: _voucherApplied
                              ? IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: _removeVoucher,
                                  color: AppTheme.errorColor,
                                )
                              : null,
                          filled: true,
                          fillColor: AppTheme.backgroundColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        enabled: !_voucherApplied,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _voucherApplied || _isApplyingVoucher
                          ? null
                          : _applyVoucher,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      child: _isApplyingVoucher
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _voucherApplied ? '✓' : 'Terapkan',
                              style: const TextStyle(fontSize: 14),
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ✅ PRICE BREAKDOWN
                Column(
                  children: [
                    _buildPriceRow(
                      label: 'Subtotal',
                      value: _totalPrice,
                      isBold: false,
                    ),
                    if (_discount > 0) ...[
                      const SizedBox(height: 8),
                      _buildPriceRow(
                        label: 'Diskon Voucher',
                        value: -_discount,
                        isBold: false,
                        isDiscount: true,
                      ),
                    ],
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    _buildPriceRow(
                      label: 'Total Pembayaran',
                      value: _finalPrice,
                      isBold: true,
                      isTotal: true,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ✅ CHECKOUT BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _proceedToCheckout,
                    icon: const Icon(Icons.shopping_cart_checkout, size: 24),
                    label: const Text(
                      'LANJUT KE PEMBAYARAN',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      shadowColor: AppTheme.primaryColor.withOpacity(0.3),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _clearCart,
                  child: Text(
                    'Kosongkan Keranjang',
                    style: AppTheme.labelMedium.copyWith(
                      color: AppTheme.errorColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ HELPER: BUILD PRICE ROW
  Widget _buildPriceRow({
    required String label,
    required double value,
    bool isBold = false,
    bool isDiscount = false,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? AppTheme.titleSmall.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                )
              : AppTheme.bodyMedium.copyWith(
                  color: isDiscount
                      ? AppTheme.successColor
                      : AppTheme.textSecondary,
                  fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
                ),
        ),
        Text(
          'Rp ${_formatPrice(value.abs())}',
          style: isTotal
              ? TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                )
              : AppTheme.bodyMedium.copyWith(
                  color: isDiscount
                      ? AppTheme.successColor
                      : AppTheme.textPrimary,
                  fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
                ),
        ),
      ],
    );
  }

  // ✅ HELPER: FORMAT PRICE
  String _formatPrice(double price) {
    return NumberFormat('#,##0', 'id_ID').format(price);
  }
}