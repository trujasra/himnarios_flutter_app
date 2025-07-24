import '../models/himnario.dart';

final List<Himnario> himnarios = [
  const Himnario(
    id: 1,
    nombre: "Poder del Evangelio",
    color: "emerald",
    colorSecundario: "emerald50",
    colorTexto: "emerald700",
    canciones: 450,
    descripcion: "Himnario tradicional evangélico multilingüe",
    idiomas: ["Español", "Inglés", "Francés", "Alemán", "Portugués", "Italiano"],
  ),
  const Himnario(
    id: 2,
    nombre: "Cala",
    color: "violet",
    colorSecundario: "violet50",
    colorTexto: "violet700",
    canciones: 320,
    descripcion: "Himnario contemporáneo multilingüe",
    idiomas: ["Español", "Aymara", "Inglés", "Francés"],
  ),
  const Himnario(
    id: 3,
    nombre: "Lluvias de Bendición",
    color: "amber",
    colorSecundario: "amber50",
    colorTexto: "amber700",
    canciones: 280,
    descripcion: "Himnario de avivamiento",
    idiomas: ["Español"],
  ),
]; 