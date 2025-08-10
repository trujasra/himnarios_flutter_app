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
    final chipTitleStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
      color: const Color.fromARGB(255, 239, 213, 252),
    );
    final chipColor = Colors.white70;// const Color.fromARGB(179, 241, 208, 18).withValues(alpha: 0.6); 
    final chipColorSelectedBg  = const Color.fromARGB(220, 253, 216, 7).withValues(alpha: 0.6); 
    final chipUnselectedBg = Color.fromARGB(255, 135, 101, 238);
    final chipBorder = StadiumBorder(
      side: BorderSide(color: Colors.white70, width: 0.8),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Campo de búsqueda unificador
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: TextField(
            controller: _controller,
            style: const TextStyle(fontSize: 15),
            decoration: const InputDecoration(
              hintText: 'Buscar por número o titulo...',
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
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    color:  Colors.white70,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Filtros',
                    style: chipTitleStyle.copyWith(
                      fontSize: 14,
                      color:  Colors.white70,
                    ),
                  ),
                ],
              ),
              collapsedIconColor: Colors.white70,
              iconColor: Colors.white70,
              children: [
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
                          color: selected ? Color.fromARGB(255, 79, 70, 229) : chipColor,
                        ),
                      ),
                      selected: selected,
                      onSelected: (v) {
                        final newList = List<String>.from(
                          widget.chipsSeleccionados,
                        );
                        if (v) {
                          newList.add(chip);
                        } else {
                          newList.remove(chip);
                        }
                        widget.onChipsSeleccionados(newList);
                      },
                      shape: chipBorder,
                      backgroundColor: selected ? chipColorSelectedBg : chipUnselectedBg,
                      selectedColor: chipColorSelectedBg,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity(
                        horizontal: -2,
                        vertical: -2,
                      ),
                      elevation: 1,
                      shadowColor: chipColorSelectedBg,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
