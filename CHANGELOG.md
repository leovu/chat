## 2.1.11

### Refactoring
- Split ChatConnection god class (1318 lines) into 10 focused service files:
  - AuthService: authentication, token, socket lifecycle
  - RoomService: room CRUD, contacts, favorites
  - MessageService: send, update, recall, pin, forward, listen
  - MediaService: image/file upload
  - NotificationService: notification list/count, overlay notification
  - ChatHubService: chatbot, sessions, summary, block, clear chat
  - CustomerService: CRM detect, link, unlink, search
  - TagService: tag CRUD
  - NotesService: note CRUD
  - GroupService: group member management, Zalo Personal, WhatsApp
- ChatConnection retained as thin facade — zero breaking changes for callers
- Added lib/services/ directory with barrel export (services.dart)

### Bug Fixes
- Fix wrong user name in AppBar for non-ChatHub 1-on-1 chat
- Fix reply message missing lastName in display
- Fix competing ParentDataWidgets error in conversation_file_screen
- Fix message alignment for consecutive messages from same sender
- Fix non-ChatHub WebSocket not receiving realtime messages (re-authenticate after checkUserToken)

## 0.0.1

* Initial release.
