class DataCala {
  static const List<Map<String, dynamic>> canciones = [
    {
      "id_cancion": 1,
      'id_idioma': 2, // Aymara
      'id_tipo_himnario': 3, // Cala
      'numero': '1',
      'titulo': 'TATITUN JUTAÑAPAJJA',
      'orden': 1,
      'estado_registro': 1,
    },
    {
      "id_cancion": 2,
      'id_idioma': 1, // Español
      'id_tipo_himnario': 3, // Cala
      'numero': '1',
      'titulo': 'PARA NUESTRO PADRE CELESTIAL',
      'orden': 2,
      'estado_registro': 1,
    },
    {
      "id_cancion": 3,
      'id_idioma': 1, // Español
      'id_tipo_himnario': 3, // Cala
      'numero': '2',
      'titulo': 'NUEVA CANCION',
      'orden': 3,
      'estado_registro': 1,
    },
  ];

  static const List<Map<String, dynamic>> letras = [
    {
      "id_letra": 1,
      'id_cancion': 1,
      'descripcion': '''Tatitun jutañapajja sinti
Jac'ancapuniwa. Suyañäni Juparu;
Cunja cusisiñänisa Jesusar
Catokañajja jutcan ucapachajja.

CORO
Tatitojj jutcan ucqhajja
Orakes qhatatiniwa
Intisa ch'amact'aniwa
Phajjsisa ch'amact'aniwa,
Cristoquiwa khanani.

Acatjamataw jutani khespiyiri
Jesusasajja Aleluya Diosaru;
Cunja cusisiñänisa Jesusar
Uñcatañajja jank'o kenay taypina.

Khespiyat jakenacasti Cristota
Khananchañäni take acapachana;
Suma k'oma chuymasampi Jesusar
Suyapjjañäni khespiyat jakenaca.

Jesusan khanapaquiwa chuymanacasan
Khanani ¡Cunja sumaquïcani! 
Jachañas tucusiniwa, wiñayaw
Cusisiñäni tatitun jac'apana.

Mario Zeballos Ch.''',
      'estado_registro': 1,
    },
    {
      "id_letra": 2,
      'id_cancion': 2,
      'descripcion': '''Pronto vuelve Jesucristo,
A juzgar a este mundo
Con divina potestad;
Esperemos la llegada,
De aquel hermoso día,
¡Preparaos, cristiandad!

CORO
Cuando venga Jesucristo,
Temblará el mundo entero;
No dará el sol su lumbre,
Ni la luna ni los astros;
Sólo Cristo brillará .

De manera repentina,
Volverá desde la gloria
Nuestro Salvador Jesús;
Con cuán grande alegría,
Le veremos en las nubes
En su refulgente luz.

Los por Cristo redimidos,
Trabajemos en su viña
Proclamando su amor;
Seguiremos con firmeza,
Esperando su venida
De Jesús el Salvador.''',
      'estado_registro': 1,
    },
    {
      "id_letra": 3,
      'id_cancion': 3,
      'descripcion': '''Nueva canción de prueba,
Para nuestro Padre celestial;
Con amor y devoción,
Cantemos su gloria sin igual.

CORO
¡Aleluya, aleluya!
Cantemos al Señor;
¡Aleluya, aleluya!
Por su amor y favor.

En la mañana y en la tarde,
En la noche y en el día;
Siempre recordemos que
Jesús está con nosotros aquí.

Con gratitud en nuestros corazones,
Adoremos al Señor;
Por su gracia y por su amor,
Por su salvación y perdón.''',
      'estado_registro': 1,
    },
  ];
} 