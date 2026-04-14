import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/course.dart';
import '../models/evaluation.dart';
import '../services/supabase_service.dart';
import '../services/notification_service.dart';

class CourseDetailScreen extends StatefulWidget {
  final Course course;
  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> with SingleTickerProviderStateMixin {
  final _supabaseService = SupabaseService();
  final _notificationService = NotificationService();
  late TabController _tabController;
  
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _weightController = TextEditingController();
  final _scoreController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descController.dispose();
    _weightController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  int _selectedDifficulty = 3;

  Future<void> _addEvaluation() async {
    if (_titleController.text.isEmpty || _selectedDay == null) return;
    try {
      final weight = double.tryParse(_weightController.text) ?? 0;
      await _supabaseService.addEvaluation(
        widget.course.id,
        _titleController.text,
        _descController.text,
        _selectedDay!,
        weight,
        _selectedDifficulty,
      );
      
      // Programar notificación (Envuelto en try-catch por si falla en Web/Simulador)
      try {
        await _notificationService.scheduleNotification(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          title: 'Evaluación hoy: ${widget.course.name}',
          body: 'No olvides tu evaluación: ${_titleController.text}',
          scheduledDate: _selectedDay!,
        );
      } catch (e) {
        debugPrint('Notificación no programada (posiblemente Web): $e');
      }

      _titleController.clear();
      _descController.clear();
      _weightController.clear();
      _selectedDifficulty = 3;
      if (mounted) Navigator.pop(context);
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _updateScore(String evalId, String scoreText) async {
    final score = double.tryParse(scoreText) ?? 0;
    if (score < 0 || score > 20) return;
    try {
      await _supabaseService.updateEvaluationScore(evalId, score);
      setState(() {});
    } catch (e) {
      debugPrint('Error updating score: $e');
    }
  }

  void _showAddEvaluationDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
              Text('Nueva Evaluación', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Fecha: ${DateFormat('dd MMMM, yyyy').format(_selectedDay ?? DateTime.now())}',
                  style: TextStyle(color: Color(int.parse(widget.course.colorHex.replaceFirst('#', '0xFF'))), fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(hintText: 'Título (Examen, Tarea...)', filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: 'Peso (%) Ej: 20', suffixText: '%', filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descController,
                decoration: InputDecoration(hintText: 'Descripción (opcional)', filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              const Text('Dificultad Estimada', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _selectedDifficulty ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: index < _selectedDifficulty ? Colors.amber : Colors.grey[400],
                      size: 32,
                    ),
                    onPressed: () {
                      setModalState(() => _selectedDifficulty = index + 1);
                      setState(() => _selectedDifficulty = index + 1);
                    },
                  );
                }),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _addEvaluation,
                  style: ElevatedButton.styleFrom(backgroundColor: Color(int.parse(widget.course.colorHex.replaceFirst('#', '0xFF'))), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Programar Alerta', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
    final courseColor = Color(int.parse(widget.course.colorHex.replaceFirst('#', '0xFF')));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Hero(
        tag: 'course-${widget.course.id}',
        child: Material(
          color: Colors.transparent,
          child: DefaultTabController(
            length: 4,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverAppBar(
                  title: Text(widget.course.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  pinned: true,
                  floating: true,
                  bottom: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: courseColor,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: courseColor,
                    tabs: const [
                      Tab(text: '📊 Resumen', height: 40),
                      Tab(text: '📝 Notas', height: 40),
                      Tab(text: '📈 Gráfica', height: 40),
                      Tab(text: '📅 Calendario', height: 40),
                    ],
                  ),
                ),
              ],
              body: FutureBuilder<List<Evaluation>>(
                future: _supabaseService.getEvaluations(widget.course.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  final evaluations = snapshot.data ?? [];
                  
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSummaryTab(evaluations, courseColor),
                      _buildEvaluationsTab(evaluations, courseColor),
                      _buildPerformanceTab(evaluations, courseColor),
                      _buildCalendarTab(evaluations, courseColor),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: _tabController.index == 1 || _tabController.index == 3
          ? FloatingActionButton(
              onPressed: () {
                if (_selectedDay == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, selecciona un día en el calendario')));
                  _tabController.animateTo(3);
                } else {
                  _showAddEvaluationDialog();
                }
              },
              backgroundColor: courseColor,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildSummaryTab(List<Evaluation> evaluations, Color color) {
    double totalWeight = 0;
    double currentScoreSum = 0;
    double totalPossibleWeight = 0;

    for (var e in evaluations) {
      totalPossibleWeight += e.weight;
      if (e.score > 0) {
        currentScoreSum += (e.score * (e.weight / 100));
        totalWeight += e.weight;
      }
    }

    final average20 = totalWeight > 0 ? (currentScoreSum / (totalWeight / 100)) : 0.0;
    final progress = totalPossibleWeight > 0 ? totalWeight / totalPossibleWeight : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            child: Container(
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color, color.withAlpha(150)]),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: color.withAlpha(80), blurRadius: 12, offset: const Offset(0, 6))],
              ),
              child: Column(
                children: [
                  const Text('Promedio Actual', style: TextStyle(color: Colors.white, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(average20.toStringAsFixed(2), style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                  const Text('/ 20 pts', style: TextStyle(color: Colors.white, fontSize: 18)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text('Estado del Curso', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
          const SizedBox(height: 16),
          _buildStatRow('Puntos acumulados', '${currentScoreSum.toStringAsFixed(2)} pts', Icons.stars_rounded, color),
          const SizedBox(height: 12),
          _buildStatRow('Evaluado', '${totalWeight.toStringAsFixed(0)}%', Icons.pie_chart_rounded, color),
          const SizedBox(height: 12),
          _buildStatRow('Pendiente', '${(100 - totalWeight).toStringAsFixed(0)}%', Icons.pending_actions_rounded, color),
          const SizedBox(height: 32),
          Text('Progreso del semestre', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[600])),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(icon, color: color),
              const SizedBox(width: 16),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
        ],
      ),
    );
  }

  Future<void> _deleteEvaluation(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar evaluación?'),
        content: const Text('¿Estás seguro de que quieres borrar esta nota?'),
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
        await _supabaseService.deleteEvaluation(id);
        setState(() {});
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Widget _buildEvaluationsTab(List<Evaluation> evaluations, Color color) {
    if (evaluations.isEmpty) return const Center(child: Text('Aún no tienes evaluaciones programadas'));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: evaluations.length,
      itemBuilder: (context, index) {
        final eval = evaluations[index];
        final scoreController = TextEditingController(text: eval.score > 0 ? eval.score.toString() : '');
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey[200]!)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(eval.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('${eval.weight}% - ${DateFormat('dd MMM').format(eval.date)}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: scoreController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: '0 / 20',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onSubmitted: (val) => _updateScore(eval.id, val),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                  onPressed: () => _deleteEvaluation(eval.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPerformanceTab(List<Evaluation> evaluations, Color color) {
    final gradedEvals = evaluations.where((e) => e.score > 0).toList();
    if (gradedEvals.isEmpty) return const Center(child: Text('Añade notas para ver tu rendimiento'));

    // Cálculo del Pronóstico (Igual que en el Dashboard)
    double currentScoreSum = 0;
    double totalWeight = 0;
    double difficultySum = 0;
    for (var e in gradedEvals) {
      currentScoreSum += (e.score * (e.weight / 100));
      totalWeight += e.weight;
      difficultySum += e.difficulty;
    }
    final average = totalWeight > 0 ? (currentScoreSum / (totalWeight / 100)) : 0.0;
    final avgDiff = gradedEvals.isNotEmpty ? difficultySum / gradedEvals.length : 3.0;
    double forecast = average - (4.0 - avgDiff) * 0.5;
    if (forecast > 20) forecast = 20;
    if (forecast < 0) forecast = 0;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Evolución y ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text('Pronóstico', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.orange[700])),
            ],
          ),
          const SizedBox(height: 48),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  // LÍNEA DE HISTORIAL
                  LineChartBarData(
                    spots: List.generate(gradedEvals.length, (i) => FlSpot(i.toDouble(), gradedEvals[i].score)),
                    isCurved: true,
                    color: color,
                    barWidth: 4,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(show: true, color: color.withAlpha(30)),
                  ),
                  // LÍNEA DE PRONÓSTICO (Dashed)
                  LineChartBarData(
                    spots: [
                      FlSpot((gradedEvals.length - 1).toDouble(), gradedEvals.last.score),
                      FlSpot(gradedEvals.length.toDouble(), forecast),
                    ],
                    isCurved: false,
                    isStepLineChart: false,
                    color: Colors.orange,
                    barWidth: 3,
                    dashArray: [5, 5],
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 6,
                        color: Colors.white,
                        strokeWidth: 3,
                        strokeColor: Colors.orange,
                      ),
                    ),
                  ),
                ],
                minY: 0,
                maxY: 20,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(color, 'Historial'),
              const SizedBox(width: 24),
              _buildLegendItem(Colors.orange, 'Pronóstico: ${forecast.toStringAsFixed(2)}'),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildCalendarTab(List<Evaluation> evaluations, Color color) {
    final events = <DateTime, List<String>>{};
    for (var e in evaluations) {
      final date = DateTime(e.date.year, e.date.month, e.date.day);
      if (events[date] == null) events[date] = [];
      events[date]!.add(e.title);
    }

    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          eventLoader: (day) => events[DateTime(day.year, day.month, day.day)] ?? [],
          calendarStyle: CalendarStyle(
            selectedDecoration: BoxDecoration(color: color, shape: BoxShape.circle),
            todayDecoration: BoxDecoration(color: color.withAlpha(50), shape: BoxShape.circle),
            markerDecoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
          ),
        ),
        const Divider(),
        Expanded(
          child: _selectedDay == null
              ? const Center(child: Text('Toca un día para ver evaluaciones'))
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    Text(DateFormat('dd MMMM').format(_selectedDay!), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 16),
                    ...(events[DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)] ?? ['No hay nada este día'])
                        .map((title) => ListTile(
                              leading: Icon(Icons.event, color: color),
                              title: Text(title),
                              contentPadding: EdgeInsets.zero,
                            )),
                  ],
                ),
        ),
      ],
    );
  }
}
