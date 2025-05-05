import 'package:rxdart/rxdart.dart';
import '../../../common/base_bloc.dart';

class ChatbotService extends BaseBloc {
  static final ChatbotService _instance = ChatbotService._internal();

  factory ChatbotService() => _instance;

  ChatbotService._internal();

  final BehaviorSubject<bool> _isActiveChatbot = BehaviorSubject.seeded(false);
  final BehaviorSubject<String?> _roomId = BehaviorSubject<String?>();

  Stream<bool> get isActiveChatbotStream => _isActiveChatbot.stream;
  bool get currentStatus => _isActiveChatbot.value;
  void setStatus(int value) => _isActiveChatbot.add(value == 1 ? true : false);

  Stream<String?> get roomIdStream => _roomId.stream;
  String? get currentRoomId => _roomId.value;
  void setRoomId(String id) => _roomId.add(id);

  @override
  void dispose() {
    super.dispose();
    _isActiveChatbot.close();
    _roomId.close();
  }
}
