import 'package:socket_io_client/socket_io_client.dart' as IO;

class InstantSocketService {
  static final InstantSocketService _instance = InstantSocketService._internal();
  factory InstantSocketService() => _instance;

  InstantSocketService._internal();

  late IO.Socket socket;

  Function(dynamic data)? _onPaymentSuccess;
  Function(dynamic data)? _onCancelSuccess;
  Function(dynamic data)? _onCancelFailed;
  Function(dynamic data)? _onCurrentHeldSeats;
  Function(dynamic data)? _onSeatHeld;
  Function(dynamic data)? _onSeatReleased;
  Function(dynamic data)? _onHoldFailed;
  Function()? _onConnect;

  // String liveServer = 'https://socket.mahakal.com';
  String liveServer = 'https://socket-bjvu.onrender.com';
  // String testServer = 'https://mandatorily-prettyish-darcel.ngrok-free.dev';

  /// 🔌 INIT SOCKET
  void initSocket() {
    try {
      if (socket != null) {
        _registerListeners(); // Ensure listeners are registered even if already connected
        if (socket.connected) {
          print('✅ Socket already connected');
          return;
        }
      }
    } catch (_) {}

    socket = IO.io(liveServer,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket.connect();
    _registerListeners();
  }

  void _registerListeners() {
    // Remove existing to avoid duplicates if re-registering
    socket.off("payment_success");
    socket.off("cancel_success");
    socket.off("cancel_failed");
    socket.off("current_held_seats");
    socket.off("seat_held");
    socket.off("seat_released");
    socket.off("hold_failed");
    socket.off("connect");
    socket.off("disconnect");
    socket.off("connect_error");

    socket.on("connect", (_) {
      print('✅ Connected to Socket: ${socket.id}');
      if (_onConnect != null) _onConnect!();
    });

    socket.on("disconnect", (_) {
      print('❌ Disconnected');
    });

    socket.on("connect_error", (err) {
      print('⚠️ Connect Error: $err');
    });

    socket.on("payment_success", (data) {
      print("🆕 payment_success: $data");
      if (_onPaymentSuccess != null) _onPaymentSuccess!(data);
    });

    socket.on("cancel_success", (data) {
      print("✅ cancel_success: $data");
      if (_onCancelSuccess != null) _onCancelSuccess!(data);
    });

    socket.on("cancel_failed", (data) {
      print("❌ cancel_failed: $data");
      if (_onCancelFailed != null) _onCancelFailed!(data);
    });

    socket.on("current_held_seats", (data) {
      print("🆕 current_held_seats: $data");
      if (_onCurrentHeldSeats != null) _onCurrentHeldSeats!(data);
    });

    socket.on("seat_held", (data) {
      print("🆕 seat_held: $data");
      if (_onSeatHeld != null) _onSeatHeld!(data);
    });

    socket.on("seat_released", (data) {
      print("🆕 seat_released: $data");
      if (_onSeatReleased != null) _onSeatReleased!(data);
    });

    socket.on("hold_failed", (data) {
      print("🆕 hold_failed: $data");
      if (_onHoldFailed != null) _onHoldFailed!(data);
    });
  }


  /// 💰 SET PAYMENT LISTENER
  void listenPaymentSuccess(String orderId, Function(dynamic data) onPaymentSuccess) {
    _onPaymentSuccess = (data) {
      if (data != null && data['order_id'].toString() == orderId.toString()) {
        onPaymentSuccess(data);
      } else {
        print("Payment Success received but ID did not match: ${data?['order_id']} vs $orderId");
      }
    };
  }

  /// 🚫 REMOVE PAYMENT LISTENER
  void removePaymentSuccessListener() {
    _onPaymentSuccess = null;
  }

  /// 🛑 SET CANCEL LISTENERS
  void listenCancelStatus({
    required Function(dynamic data) onSuccess,
    required Function(dynamic data) onFailed,
  }) {
    _onCancelSuccess = onSuccess;
    _onCancelFailed = onFailed;
  }

  /// 🚫 REMOVE CANCEL LISTENERS
  void removeCancelListeners() {
    _onCancelSuccess = null;
    _onCancelFailed = null;
  }

  /// 🎭 AUDITORIUM LISTENERS
  void listenAuditoriumEvents({
    Function(dynamic data)? onCurrentHeldSeats,
    Function(dynamic data)? onSeatHeld,
    Function(dynamic data)? onSeatReleased,
    Function(dynamic data)? onHoldFailed,
    Function()? onConnect,
  }) {
    _onCurrentHeldSeats = onCurrentHeldSeats;
    _onSeatHeld = onSeatHeld;
    _onSeatReleased = onSeatReleased;
    _onHoldFailed = onHoldFailed;
    _onConnect = onConnect;
  }

  /// 🚫 REMOVE AUDITORIUM LISTENERS
  void removeAuditoriumListeners() {
    _onCurrentHeldSeats = null;
    _onSeatHeld = null;
    _onSeatReleased = null;
    _onHoldFailed = null;
    _onConnect = null;
  }


  /// 🚖 JOIN DRIVER (call once after connect)
  void joinUser({
    required String orderId,
    required String userId,
  }) {
    socket.emit('join_user', {
      'order_id': orderId,
      'userId': userId,
    });

    print('🚖 user Joined: $orderId $userId');
  }

  // add tip amount
  void addTipAmount({
    required String orderId,
    required String price,
  }) {
    socket.emit('update_tip_price', {
      'order_id': orderId,
      'tip_price': price,
    });

    print('add tip amount successfully: $orderId $price');
  }

  // cancel order
  void cancelOrder({
    required String orderId,
    required String userId,
    required String reason,
  }) {
    socket.emit('cancel_order', {
      'order_id': orderId,
      'user_id': userId,
      'reason': reason,
    });

    print('cancel order successfully: $orderId $userId $reason');
  }


  /// 🛒 CREATE ORDER (USER SIDE)
  void sendInstantOrder(Map<String, dynamic> data) {
    socket.emit('create_order', data);

    print('🚀 Order Sent: $data');
  }

  /// 🎭 JOIN AUDITORIUM
  void joinAuditorium({
    required String eventId,
    required String venue,
    required String time,
    String? userId,
  }) {
    socket.emit('join_auditorium', {
      'eventId': eventId,
      'venue': venue,
      'time': time,
      'userId': userId ?? socket.id,
    });
    print('🎭 Joined Auditorium: $eventId $venue $time');
  }

  /// 💺 HOLD SEAT
  void holdSeat({
    required String eventId,
    required String venue,
    required String time,
    required String seatId,
    required String userId,
  }) {
    socket.emit('hold_seat', {
      'eventId': eventId,
      'venue': venue,
      'time': time,
      'seatId': seatId,
      'userId': userId,
    });
    print('💺 Hold Seat: $seatId by $userId');
  }

  /// 🔓 RELEASE SEAT
  void releaseSeat({
    required String eventId,
    required String venue,
    required String time,
    required String seatId,
    required String userId,
  }) {
    socket.emit('release_seat', {
      'eventId': eventId,
      'venue': venue,
      'time': time,
      'seatId': seatId,
      'userId': userId,
    });
    print('🔓 Release Seat: $seatId by $userId');
  }

  /// 💺 HOLD MULTIPLE SEATS
  void holdMultipleSeats({
    required String eventId,
    required String venue,
    required String time,
    required List<String> seatIds,
    required String userId,
  }) {
    for (var seatId in seatIds) {
      holdSeat(
        eventId: eventId,
        venue: venue,
        time: time,
        seatId: seatId,
        userId: userId,
      );
    }
  }

  /// ❌ DISCONNECT
  void disconnect() {
    socket.disconnect();
  }
}
