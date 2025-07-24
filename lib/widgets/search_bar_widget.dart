import 'package:flutter/material.dart';

// Cambiar a selección múltiple de chips
class SearchBarWidget extends StatefulWidget {
  final String busqueda;
  final Function(String) onBusquedaChanged;
  final List<String> chips;
  final List<String> chipsSeleccionados;
  final Function(List<String>) onChipsSeleccionados;

  const SearchBarWidget({
    super.key,
    required this.busqueda,
    required this.onBusquedaChanged,
    required this.chips,
    required this.chipsSeleccionados,
    required this.onChipsSeleccionados,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.busqueda);
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant SearchBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.busqueda != _controller.text) {
      _controller.text = widget.busqueda;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
  }

  void _onTextChanged() {
    if (_controller.text != widget.busqueda) {
      widget.onBusquedaChanged(_controller.text);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chipTitleStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.grey[900]);
    final chipColor = Colors.green;
    final chipUnselectedBg = Colors.green[50]!;
    final chipBorder = StadiumBorder(side: BorderSide(color: Colors.green[700]!, width: 1.2));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Campo de búsqueda unificado
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: TextField(
            controller: _controller,
            style: const TextStyle(fontSize: 15),
            decoration: const InputDecoration(
              hintText: 'Buscar por número o texto...',
              hintStyle: TextStyle(color: Colors.grey),
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        if (widget.chips.isNotEmpty) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(bottom: 4, left: 2),
            child: Text('Filtrar', style: chipTitleStyle),
          ),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: widget.chips.map((chip) {
              final selected = widget.chipsSeleccionados.contains(chip);
              return FilterChip(
                label: Text(
                  chip,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: selected ? Colors.white : chipColor,
                  ),
                ),
                selected: selected,
                onSelected: (v) {
                  final newList = List<String>.from(widget.chipsSeleccionados);
                  if (v) {
                    newList.add(chip);
                  } else {
                    newList.remove(chip);
                  }
                  widget.onChipsSeleccionados(newList);
                },
                shape: chipBorder,
                backgroundColor: selected ? chipColor : chipUnselectedBg,
                selectedColor: chipColor,
                labelPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity(horizontal: -2, vertical: -2),
                elevation: 1,
                shadowColor: Colors.black12,
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
