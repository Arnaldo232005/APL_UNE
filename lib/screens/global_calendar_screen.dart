import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../services/supabase_service.dart';

class GlobalCalendarScreen extends StatefulWidget {
  const GlobalCalendarScreen({super.key});

  @override
  State<GlobalCalendarScreen> createState() => _GlobalCalendarScreenState();
}

class _GlobalCalendarScreenState extends State<GlobalCalendarScreen> {
  final _supabaseService = SupabaseService();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Map<String, dynamic>> _allEvals = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEvals();
  }

  Future<void> _loadEvals() async {
    setState(() => _loading = true);
    try {
      final data = await _supabaseService.getAllEvaluationsWithCourse();
      setState(() {
        _allEvals = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Map<DateTime, List<Map<String, dynamic>>> get _events {
    final map = <DateTime, List<Map<String, dynamic>>>{};
    for (final e in _allEvals) {
      final rawDate = e['evaluation_date'] as String;
      final date = DateTime.parse(rawDate);
      final key = DateTime(date.year, date.month, date.day);
      map.putIfAbsent(key, () => []).add(e);
    }
    return map;
  }

  List<Map<String, dynamic>> _eventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  Color _courseColor(Map<String, dynamic> eval) {
    try {
      final hex = (eval['courses']?['color_hex'] ?? '#6C63FF') as String;
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return const Color(0xFF6C63FF);
    }
  }

  String _courseName(Map<String, dynamic> eval) {
    return (eval['courses']?['name'] ?? 'Sin materia') as String;
  }

  int _difficulty(Map<String, dynamic> eval) {
    return (eval['difficulty'] ?? 3) as int;
  }

  void _showEditEvalDialog(Map<String, dynamic> eval) {
    final titleCtrl = TextEditingController(text: eval['title'] ?? '');
    final descCtrl = TextEditingController(text: eval['description'] ?? '');
    final weightCtrl = TextEditingController(
        text: (eval['weight'] ?? 0).toStringAsFixed(0));
    int difficulty = _difficulty(eval);
    final courseColor = _courseColor(eval);
    final courseName = _courseName(eval);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Course badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: courseColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.school_rounded, color: courseColor, size: 16),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          courseName,
                          style: TextStyle(
                            color: courseColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Editar Evaluación',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 20),
                _buildField(titleCtrl, 'Título', Icons.edit_note_rounded),
                const SizedBox(height: 12),
                _buildField(descCtrl, 'Descripción (opcional)', Icons.notes_rounded, maxLines: 2),
                const SizedBox(height: 12),
                _buildField(
                  weightCtrl,
                  'Peso (%)',
                  Icons.percent_rounded,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(Icons.bolt_rounded, color: Colors.amber, size: 20),
                    const SizedBox(width: 6),
                    const Text(
                      'Dificultad',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    return IconButton(
                      icon: Icon(
                        i < difficulty ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: i < difficulty ? Colors.amber : Colors.grey[300],
                        size: 34,
                      ),
                      onPressed: () => setModalState(() => difficulty = i + 1),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save_rounded, color: Colors.white),
                    label: const Text(
                      'Guardar Cambios',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: courseColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () async {
                      // Capture references before async gaps
                      final nav = Navigator.of(context);
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        await _supabaseService.updateEvaluation(
                          eval['id'] as String,
                          title: titleCtrl.text,
                          description: descCtrl.text.isEmpty ? null : descCtrl.text,
                          weight: double.tryParse(weightCtrl.text) ?? 0,
                          difficulty: difficulty,
                        );
                        nav.pop();
                        await _loadEvals();
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('✅ Evaluación actualizada'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } catch (e) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: Colors.grey[500]),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildEvalCard(Map<String, dynamic> eval) {
    final color = _courseColor(eval);
    final courseName = _courseName(eval);
    final title = eval['title'] ?? 'Sin título';
    final weight = (eval['weight'] ?? 0).toDouble();
    final score = (eval['score'] ?? 0).toDouble();
    final difficulty = _difficulty(eval);
    final desc = eval['description'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(20),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Course name
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          courseName,
                          style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF1E1E2C),
                        ),
                      ),
                    ],
                  ),
                ),
                // Edit button
                GestureDetector(
                  onTap: () => _showEditEvalDialog(eval),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.edit_rounded, color: color, size: 18),
                  ),
                ),
              ],
            ),
            if (desc != null && desc.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                desc as String,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                // Weight
                _infoChip(Icons.percent_rounded, '${weight.toStringAsFixed(0)}%', Colors.blue),
                const SizedBox(width: 8),
                // Score
                if (score > 0)
                  _infoChip(Icons.grade_rounded, score.toStringAsFixed(1), Colors.green)
                else
                  _infoChip(Icons.grade_outlined, 'Sin nota', Colors.grey),
                const Spacer(),
                // Difficulty stars
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < difficulty ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: i < difficulty ? Colors.amber : Colors.grey[300],
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadEvals,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        // Header with gradient
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF6C63FF), Color(0xFF9B59B6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(28),
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.calendar_month_rounded,
                                      color: Colors.white, size: 22),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Calendario de Evaluaciones',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.refresh_rounded,
                                        color: Colors.white70),
                                    onPressed: _loadEvals,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '${_allEvals.length} evaluaciones registradas',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TableCalendar(
                                firstDay: DateTime.utc(2020, 1, 1),
                                lastDay: DateTime.utc(2030, 12, 31),
                                focusedDay: _focusedDay,
                                calendarFormat: _calendarFormat,
                                selectedDayPredicate: (day) =>
                                    isSameDay(_selectedDay, day),
                                onDaySelected: (selectedDay, focusedDay) {
                                  setState(() {
                                    _selectedDay = selectedDay;
                                    _focusedDay = focusedDay;
                                  });
                                },
                                onFormatChanged: (format) {
                                  setState(() => _calendarFormat = format);
                                },
                                eventLoader: _eventsForDay,
                                calendarStyle: const CalendarStyle(
                                  defaultTextStyle:
                                      TextStyle(color: Colors.white),
                                  weekendTextStyle:
                                      TextStyle(color: Colors.white70),
                                  outsideTextStyle:
                                      TextStyle(color: Colors.white38),
                                  selectedDecoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  selectedTextStyle:
                                      TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.bold),
                                  todayDecoration: BoxDecoration(
                                    color: Colors.white24,
                                    shape: BoxShape.circle,
                                  ),
                                  todayTextStyle: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                  markerDecoration: BoxDecoration(
                                    color: Colors.amber,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                headerStyle: const HeaderStyle(
                                  titleTextStyle: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  leftChevronIcon: Icon(Icons.chevron_left,
                                      color: Colors.white),
                                  rightChevronIcon: Icon(Icons.chevron_right,
                                      color: Colors.white),
                                  formatButtonDecoration: BoxDecoration(
                                    border:
                                        Border.fromBorderSide(BorderSide(color: Colors.white38)),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                  ),
                                  formatButtonTextStyle:
                                      TextStyle(color: Colors.white),
                                ),
                                daysOfWeekStyle: const DaysOfWeekStyle(
                                  weekdayStyle:
                                      TextStyle(color: Colors.white70, fontSize: 12),
                                  weekendStyle:
                                      TextStyle(color: Colors.white38, fontSize: 12),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Section title
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              const Icon(Icons.event_note_rounded,
                                  color: Color(0xFF6C63FF), size: 20),
                              const SizedBox(width: 8),
                              Text(
                                _selectedDay == null
                                    ? 'Todas las evaluaciones'
                                    : 'Evaluaciones del ${DateFormat('dd MMMM', 'es').format(_selectedDay!)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF1E1E2C),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    sliver: _buildEvalsList(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildEvalsList() {
    final list = _selectedDay == null
        ? _allEvals
        : _eventsForDay(_selectedDay!);

    if (list.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Column(
            children: [
              Icon(Icons.event_busy_rounded, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                _selectedDay == null
                    ? 'No hay evaluaciones aún'
                    : 'No hay evaluaciones este día',
                style: TextStyle(color: Colors.grey[500], fontSize: 15),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildEvalCard(list[index]),
        childCount: list.length,
      ),
    );
  }
}
