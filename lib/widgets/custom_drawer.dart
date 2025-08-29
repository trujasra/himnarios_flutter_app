import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomDrawer extends StatelessWidget {
  final String nombreUsuario;

  const CustomDrawer({super.key, required this.nombreUsuario});

  // Función para obtener las iniciales del usuario
  String getIniciales(String nombre) {
    if (nombre.isEmpty) return "?";

    List<String> partes = nombre.trim().split(' ');

    if (partes.length == 1) {
      return partes[0].substring(0, partes[0].length >= 2 ? 2 : 1).toUpperCase();
    } else {
      String primera = partes[0][0];
      String segunda = partes[1][0];
      return (primera + segunda).toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // DrawerHeader personalizado
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: AppTheme.mainGradient,
            ),
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar más pequeño
                CircleAvatar(
                  radius: 30, // Aquí sí cambia el tamaño del círculo
                  backgroundColor: Colors.white,
                  child: Text(
                    getIniciales(nombreUsuario),
                    style: const TextStyle(
                      fontSize: 21,
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Nombre de usuario y texto de bienvenida
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombreUsuario,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 1.0,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Bienvenido',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Opciones del Drawer
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Configuración"),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text("Favoritos"),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.list_alt),
            title: const Text("Listas creadas"),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("Créditos"),
            onTap: () => Navigator.pop(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text("Salir"),
            onTap: () {
              Navigator.pop(context);
              // Aquí puedes agregar lógica de logout
            },
          ),
        ],
      ),
    );
  }
}
