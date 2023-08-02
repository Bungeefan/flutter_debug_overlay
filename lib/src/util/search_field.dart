import 'package:flutter/material.dart';

class SearchField extends StatefulWidget {
  final TextEditingController controller;
  final void Function(String text) onSearch;

  const SearchField({
    super.key,
    required this.controller,
    required this.onSearch,
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      onChanged: (value) => setState(() {
        widget.onSearch(value.trim());
      }),
      decoration: InputDecoration(
        hintText: "Search",
        prefixIcon: const Icon(Icons.search, size: 20),
        prefixIconConstraints: BoxConstraints.tight(const Size.square(40)),
        suffixIcon: widget.controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                splashRadius: 20,
                onPressed: () {
                  widget.controller.clear();
                  widget.onSearch(widget.controller.text);
                },
              )
            : null,
        suffixIconConstraints: BoxConstraints.tight(const Size.square(40)),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
    );
  }
}
