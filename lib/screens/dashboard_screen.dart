import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../models/course.dart';
import '../services/supabase_service.dart';
import 'course_detail_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _supabaseService = SupabaseService();
  final _nameController = TextEditingController();
  String _importance = 'Media';
  String _selectedColor = '#6C63FF';
  int _selectedIconCode = Icons.book_rounded.codePoint;

  final List<String> _predefinedColors = [
    '#6C63FF', '#FFA726', '#66BB6A', '#EF5350', '#42A5F5', '#AB47BC', '#26C6DA', '#78909C'
  ];

  final List<IconData> _predefinedIcons = [
    Icons.book_rounded, Icons.computer_rounded, Icons.science_rounded,
    Icons.palette_rounded, Icons.calculate_rounded, Icons.history_edu_rounded,
    Icons.language_rounded, Icons.music_note_rounded
  ];

  Future<void> _confirmDeleteCourse(Course course) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar materia?'),
        content: Text('Esto borrará "${course.name}" y todas su información de forma permanente.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _supabaseService.deleteCourse(course.id);
        setState(() {});
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _addCourse() async {
    if (_nameController.text.isEmpty) return;
    try {
      await _supabaseService.addCourse(
        _nameController.text,
        _importance,
        _selectedColor,
        _selectedIconCode,
      );
      _nameController.clear();
      if (mounted) Navigator.pop(context);
      setState(() {}); // Refresh list
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showAddCourseDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nuevo Curso', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Nombre del curso',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _importance,
                decoration: InputDecoration(
                  hintText: 'Importancia',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                items: ['Baja', 'Media', 'Alta']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setModalState(() => _importance = val);
                },
              ),
              const SizedBox(height: 16),
              Text('Color de Tarjeta', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _predefinedColors.length,
                  itemBuilder: (context, index) {
                    final colorHex = _predefinedColors[index];
                    final color = Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
                    return GestureDetector(
                      onTap: () => setModalState(() => _selectedColor = colorHex),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: _selectedColor == colorHex ? Border.all(color: Colors.black, width: 2) : null,
                        ),
                        child: _selectedColor == colorHex ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text('Icono Representativo', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _predefinedIcons.length,
                  itemBuilder: (context, index) {
                    final icon = _predefinedIcons[index];
                    return GestureDetector(
                      onTap: () => setModalState(() => _selectedIconCode = icon.codePoint),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _selectedIconCode == icon.codePoint ? const Color(0xFF6C63FF).withAlpha(40) : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: _selectedIconCode == icon.codePoint ? Border.all(color: const Color(0xFF6C63FF)) : null,
                        ),
                        child: Icon(icon, color: _selectedIconCode == icon.codePoint ? const Color(0xFF6C63FF) : Colors.grey[600]),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _addCourse,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Crear Curso', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Cursos', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh, color: Color(0xFF6C63FF)),
          ),
          IconButton(
            onPressed: () async {
              await _supabaseService.signOut();
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
            icon: const Icon(Icons.logout_rounded, color: Colors.grey),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _supabaseService.getCoursesWithStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off_rounded, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text('Error de conexión', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 8),
                    Text(
                      'No pudimos cargar tus cursos. Verifica tu internet o el script SQL en Supabase.\n\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => setState(() {}),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    )
                  ],
                ),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.school_outlined, size: 80, color: Colors.grey),
                  const SizedBox(height: 20),
                  Text('¡Tu semestre está vacío!', style: TextStyle(color: Colors.grey[800], fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Añade tu primera materia para empezar.', style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _showAddCourseDialog,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
                    child: const Text('Crear Curso'),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 18,
              mainAxisSpacing: 18,
              childAspectRatio: 0.75, // Un poco más alta para que quepa la información
            ),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final courseData = data[index];
              final course = Course.fromMap(courseData);
              final evaluations = (courseData['evaluations'] as List? ?? []);
              
              // Cálculos para la tarjeta
              double currentScoreSum = 0;
              double totalWeight = 0;
              double difficultySum = 0;
              int gradedCount = 0;

              for (var e in evaluations) {
                final score = (e['score'] ?? 0).toDouble();
                final weight = (e['weight'] ?? 0).toDouble();
                final diff = (e['difficulty'] ?? 3).toDouble();
                
                if (score > 0) {
                  currentScoreSum += (score * (weight / 100));
                  totalWeight += weight;
                  difficultySum += diff;
                  gradedCount++;
                }
              }

              final average = totalWeight > 0 ? (currentScoreSum / (totalWeight / 100)) : 0.0;
              final avgDiff = gradedCount > 0 ? difficultySum / gradedCount : 3.0;

              // Pronóstico Exigente: 
              // Si no hay notas, no hay pronóstico.
              // Si hay notas, predecimos una evaluación de dificultad Alta (4)
              double forecast = 0;
              if (gradedCount > 0) {
                // Factor exigente: si la dificultad sube, la nota baja proporcionalmente
                // Penalizamos 1 punto por cada nivel de dificultad por encima del promedio personal
                forecast = average - (4.0 - avgDiff) * 0.5; 
                // Aseguramos límites
                if (forecast > 20) forecast = 20;
                if (forecast < 0) forecast = 0;
              }

              final Color courseColor = Color(int.parse(course.colorHex.replaceFirst('#', '0xFF')));

              return FadeInUp(
                delay: Duration(milliseconds: index * 60),
                child: Hero(
                  tag: 'course-${course.id}',
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CourseDetailScreen(course: course)),
                    ).then((_) => setState(() {})),
                    onLongPress: () => _confirmDeleteCourse(course),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(color: courseColor.withAlpha(20), blurRadius: 20, offset: const Offset(0, 8)),
                          BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 2)
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Stack(
                          children: [
                            Positioned(
                              top: -20,
                              right: -20,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(colors: [courseColor.withAlpha(50), courseColor.withAlpha(0)]),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(colors: [courseColor.withAlpha(200), courseColor]),
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        child: Icon(IconData(course.iconCode, fontFamily: 'MaterialIcons'), color: Colors.white, size: 20),
                                      ),
                                      Row(
                                        children: [
                                          if (totalWeight > 0)
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  average.toStringAsFixed(2),
                                                  style: TextStyle(fontWeight: FontWeight.bold, color: courseColor, fontSize: 14),
                                                ),
                                                Text('PROM', style: TextStyle(fontSize: 7, color: Colors.grey[500])),
                                              ],
                                            ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.grey, size: 18),
                                            onPressed: () => _confirmDeleteCourse(course),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Text(
                                    course.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D2C3C), fontSize: 16, height: 1.1),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 12),
                                  // PRONÓSTICO
                                  if (gradedCount > 0)
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: Colors.amber.withAlpha(20), borderRadius: BorderRadius.circular(8)),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.psychology_outlined, size: 12, color: Colors.amber),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Pronóstico: ${forecast.toStringAsFixed(2)}',
                                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange),
                                          ),
                                        ],
                                      ),
                                    ),
                                  // Barra de Progreso
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: totalWeight / 100,
                                      minHeight: 4,
                                      backgroundColor: Colors.grey[100],
                                      valueColor: AlwaysStoppedAnimation<Color>(courseColor),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: _getImportanceColor(course.importance).withAlpha(25), borderRadius: BorderRadius.circular(10)),
                                    child: Text(
                                      course.importance.toUpperCase(),
                                      style: TextStyle(fontSize: 9, color: _getImportanceColor(course.importance), fontWeight: FontWeight.w800, letterSpacing: 0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCourseDialog,
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 6,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
      ),
    );
  }

  Color _getImportanceColor(String importance) {
    switch (importance) {
      case 'Alta':
        return const Color(0xFFFF5252);
      case 'Media':
        return const Color(0xFFFFAB40);
      case 'Baja':
        return const Color(0xFF44BD32);
      default:
        return Colors.blueGrey;
    }
  }
}
