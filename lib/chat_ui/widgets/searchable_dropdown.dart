// import 'package:flutter/material.dart';
//
// class SearchableDropdown extends StatefulWidget {
//   final List<String> items;
//   final String hintText;
//   final ValueChanged<String>? onChanged;
//
//   const SearchableDropdown({
//     super.key,
//     required this.items,
//     this.hintText = 'Chọn một mục...',
//     this.onChanged,
//   });
//
//   @override
//   State<SearchableDropdown> createState() => _SearchableDropdownState();
// }
//
// class _SearchableDropdownState extends State<SearchableDropdown> {
//   final LayerLink _layerLink = LayerLink();
//   OverlayEntry? _overlayEntry;
//   final TextEditingController _searchController = TextEditingController();
//
//   List<String> _filteredItems = [];
//   String? _selectedValue;
//   bool _isDropdownOpen = false;
//   bool _isDisposed = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _filteredItems = widget.items;
//     _searchController.addListener(_filterItems);
//   }
//
//   void _filterItems() {
//     if (_isDisposed || !mounted) return;
//     setState(() {
//       final query = _searchController.text.toLowerCase();
//       _filteredItems = widget.items
//           .where((item) => item.toLowerCase().contains(query))
//           .toList();
//     });
//   }
//
//   void _showDropdown() {
//     if (_isDisposed || !mounted) return;
//
//     _filteredItems = widget.items;
//     _overlayEntry = _createOverlayEntry();
//     final overlay = Overlay.of(context);
//     if (!_isDisposed && overlay.mounted) {
//       overlay.insert(_overlayEntry!);
//     }
//     _isDropdownOpen = true;
//   }
//
//   void _hideDropdown() {
//     if (_overlayEntry != null) {
//       _overlayEntry!.remove();
//       _overlayEntry = null;
//       _isDropdownOpen = false;
//
//       if (!_isDisposed && mounted) {
//         final finalValue = _searchController.text.trim();
//         if (finalValue.isNotEmpty) {
//           setState(() {
//             _selectedValue = finalValue;
//           });
//           widget.onChanged?.call(finalValue);
//         }
//       }
//     }
//   }
//
//   OverlayEntry _createOverlayEntry() {
//     RenderBox renderBox = context.findRenderObject() as RenderBox;
//     final size = renderBox.size;
//
//     return OverlayEntry(
//       builder: (context) => Positioned(
//         width: size.width,
//         child: CompositedTransformFollower(
//           offset: Offset(0.0, size.height + 5),
//           link: _layerLink,
//           showWhenUnlinked: false,
//           child: Material(
//             elevation: 4,
//             borderRadius: BorderRadius.circular(8),
//             child: Container(
//               constraints: const BoxConstraints(maxHeight: 250),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: TextField(
//                       controller: _searchController,
//                       autofocus: true,
//                       decoration: InputDecoration(
//                         hintText: "Nhập để tìm hoặc thêm...",
//                         contentPadding:
//                             const EdgeInsets.symmetric(horizontal: 12),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const Divider(height: 0),
//                   Expanded(
//                     child: _filteredItems.isEmpty
//                         ? const Padding(
//                             padding: EdgeInsets.all(12),
//                             child: Text("Không tìm thấy"),
//                           )
//                         : ListView.builder(
//                             itemCount: _filteredItems.length,
//                             itemBuilder: (_, index) {
//                               final item = _filteredItems[index];
//                               return ListTile(
//                                 title: Text(item),
//                                 onTap: () {
//                                   if (!_isDisposed && mounted) {
//                                     setState(() {
//                                       _searchController.text = item;
//                                       _selectedValue = item;
//                                     });
//                                     widget.onChanged?.call(item);
//                                   }
//                                   _hideDropdown();
//                                 },
//                               );
//                             },
//                           ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _isDisposed = true;
//     _overlayEntry?.remove();
//     _overlayEntry = null;
//     _searchController.removeListener(_filterItems);
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return CompositedTransformTarget(
//       link: _layerLink,
//       child: GestureDetector(
//         onTap: () {
//           if (_isDropdownOpen) {
//             _hideDropdown();
//           } else {
//             _showDropdown();
//           }
//         },
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey.shade400),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: Text(
//                   _selectedValue ?? widget.hintText,
//                   style: TextStyle(
//                     color: _selectedValue == null ? Colors.grey : Colors.black,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//               const Icon(Icons.arrow_drop_down),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

class SearchableDropdown extends StatefulWidget {
  final List<String> items;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted; // Callback để lưu dữ liệu mới

  const SearchableDropdown({
    super.key,
    required this.items,
    this.hintText = 'Chọn một mục...',
    this.onChanged,
    this.onSubmitted,
  });

  @override
  State<SearchableDropdown> createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<SearchableDropdown> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final TextEditingController _searchController = TextEditingController();

  List<String> _filteredItems = [];
  String? _selectedValue;
  bool _isDropdownOpen = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.addListener(_filterItems);
  }

  void _filterItems() {
    if (_isDisposed || !mounted) return;
    setState(() {
      final query = _searchController.text.toLowerCase();
      _filteredItems = widget.items
          .where((item) => item.toLowerCase().contains(query))
          .toList();
    });
  }

  void _showDropdown() {
    if (_isDisposed || !mounted) return;

    _filteredItems = widget.items;
    _overlayEntry = _createOverlayEntry();
    final overlay = Overlay.of(context);
    if (!_isDisposed && overlay.mounted) {
      overlay.insert(_overlayEntry!);
    }
    _isDropdownOpen = true;
  }

  void _hideDropdown() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      _isDropdownOpen = false;

      if (!_isDisposed && mounted) {
        final finalValue = _searchController.text.trim();
        if (finalValue.isNotEmpty) {
          setState(() {
            _selectedValue = finalValue;
          });
          widget.onChanged?.call(finalValue);
        }
      }
    }
  }

  // Hàm xử lý khi submit
  void _submitItem() {
    if (_isDisposed || !mounted) return;
    final newItem = _searchController.text.trim();
    if (newItem.isNotEmpty && !widget.items.contains(newItem)) {
      // Gọi callback để thông báo dữ liệu mới
      widget.onSubmitted?.call(newItem);
      setState(() {
        _selectedValue = newItem;
        _filteredItems = widget.items;
      });
      _searchController.clear(); // Xóa TextField sau khi submit
      widget.onChanged?.call(newItem);
    }
    _hideDropdown();
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          offset: Offset(0.0, size.height + 5),
          link: _layerLink,
          showWhenUnlinked: false,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 250),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: "Nhập để tìm hoặc thêm...",
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onSubmitted: (_) =>
                                _submitItem(), // Submit khi nhấn Enter
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _submitItem, // Submit khi nhấn nút
                          tooltip: 'Thêm mục',
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 0),
                  Expanded(
                    child: _filteredItems.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: Text("Không tìm thấy"),
                          )
                        : ListView.builder(
                            itemCount: _filteredItems.length,
                            itemBuilder: (_, index) {
                              final item = _filteredItems[index];
                              return ListTile(
                                title: Text(item),
                                onTap: () {
                                  if (!_isDisposed && mounted) {
                                    setState(() {
                                      _searchController.text = item;
                                      _selectedValue = item;
                                    });
                                    widget.onChanged?.call(item);
                                  }
                                  _hideDropdown();
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _overlayEntry?.remove();
    _overlayEntry = null;
    _searchController.removeListener(_filterItems);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: () {
          if (_isDropdownOpen) {
            _hideDropdown();
          } else {
            _showDropdown();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _selectedValue ?? widget.hintText,
                  style: TextStyle(
                    color: _selectedValue == null ? Colors.grey : Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }
}
