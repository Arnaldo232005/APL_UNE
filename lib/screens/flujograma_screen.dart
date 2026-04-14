import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────
class FlowSubject {
  final String code;
  final String name;
  final int period; // 1..13
  final int credits;
  final bool isElective;

  const FlowSubject({
    required this.code,
    required this.name,
    required this.period,
    required this.credits,
    this.isElective = false,
  });
}

// ─────────────────────────────────────────────
// UNIMET – Ingeniería de Sistemas Flujograma
// ─────────────────────────────────────────────
const List<FlowSubject> _subjects = [
  // ── PERIODO I ──
  FlowSubject(code: 'FBTMM01', name: 'Matemática Básica', period: 1, credits: 4),
  FlowSubject(code: 'FBTSP03', name: 'Introducción a la Ingeniería', period: 1, credits: 4),
  FlowSubject(code: 'FBTSP04', name: 'Pensamiento Computacional', period: 1, credits: 4),
  FlowSubject(code: 'FBTEM01', name: 'Competencias para Emprender', period: 1, credits: 4),
  FlowSubject(code: 'FBPIN03', name: 'Inglés IV', period: 1, credits: 4),

  // ── PERIODO II ──
  FlowSubject(code: 'FBTMM01-II', name: 'Matemáticas I', period: 2, credits: 4),
  FlowSubject(code: 'FBTHE35', name: 'Investigación y Sustentabilidad', period: 2, credits: 4),
  FlowSubject(code: 'BPTQ01', name: 'Diseño Asistido por Computador', period: 2, credits: 4),
  FlowSubject(code: 'BPTQ21', name: 'Química General I', period: 2, credits: 4),
  FlowSubject(code: 'FTIN04', name: 'Inglés V', period: 2, credits: 4),

  // ── PERIODO III ──
  FlowSubject(code: 'BPTM01', name: 'Matemáticas II', period: 3, credits: 4),
  FlowSubject(code: 'BPTF01', name: 'Física I', period: 3, credits: 4),
  FlowSubject(code: 'BPTQ22', name: 'Laboratorio de Química Gral. I', period: 3, credits: 4),
  FlowSubject(code: 'BPTM01-D', name: 'Matemáticas Discretas', period: 3, credits: 4),
  FlowSubject(code: 'BPTSP05', name: 'Algoritmos y Programación', period: 3, credits: 4),
  FlowSubject(code: 'FBTEM03', name: 'Como emprender con datos', period: 3, credits: 4),
  FlowSubject(code: 'FTIN25', name: 'Inglés V (adv)', period: 3, credits: 4),

  // ── PERIODO IV ──
  FlowSubject(code: 'BPTM03', name: 'Matemáticas III', period: 4, credits: 4),
  FlowSubject(code: 'BPTF01-II', name: 'Física II', period: 4, credits: 4),
  FlowSubject(code: 'BPTF02', name: 'Lab. de Física Aplicada', period: 4, credits: 4),
  FlowSubject(code: 'BPTSP06', name: 'Estructuras de Datos', period: 4, credits: 4),
  FlowSubject(code: 'BPTM01-AL', name: 'Álgebra Lineal', period: 4, credits: 4),

  // ── PERIODO V ──
  FlowSubject(code: 'BPTM03-IV', name: 'Matemáticas IV', period: 5, credits: 4),
  FlowSubject(code: 'BPTM06', name: 'Lab. de Estadística para Ing. I', period: 5, credits: 4),
  FlowSubject(code: 'BPTF06', name: 'Lab. Estadística para Física', period: 5, credits: 4),
  FlowSubject(code: 'BPTSP04', name: 'Sistemas de Información', period: 5, credits: 4),
  FlowSubject(code: 'BPTEN12', name: 'Matemáticas para Computador', period: 5, credits: 4),

  // ── PERIODO VI ──
  FlowSubject(code: 'BPTM04-V', name: 'Matemáticas V', period: 6, credits: 4),
  FlowSubject(code: 'BPTM11', name: 'Ecuaciones Diferenciales', period: 6, credits: 4),
  FlowSubject(code: 'BPTM06-II', name: 'Estadística para Ing. II', period: 6, credits: 4),
  FlowSubject(code: 'BPTSP01', name: 'Bases de Datos I', period: 6, credits: 4),
  FlowSubject(code: 'BPTEN12-A', name: 'Arquitectura del Computador', period: 6, credits: 4),
  FlowSubject(code: 'BPTM03-AL', name: 'Álgebra Lineal II', period: 6, credits: 4),

  // ── PERIODO VII ──
  FlowSubject(code: 'BPTM04-VII', name: 'Matemáticas V (cont.)', period: 7, credits: 4),
  FlowSubject(code: 'BPTM05', name: 'Cálculo Numérico', period: 7, credits: 4),
  FlowSubject(code: 'BPTM11-II', name: 'Ecuaciones Diferenciales II', period: 7, credits: 4),
  FlowSubject(code: 'FPTSP26', name: 'Bases de Datos II', period: 7, credits: 4),
  FlowSubject(code: 'BPTM11-A', name: 'Organización del Computador', period: 7, credits: 4),
  FlowSubject(code: 'BPTSP17', name: 'Optimización I', period: 7, credits: 4),

  // ── PERIODO VIII ──
  FlowSubject(code: 'FPTSP01', name: 'Ingeniería de Software', period: 8, credits: 4),
  FlowSubject(code: 'FPTM20', name: 'Simulación', period: 8, credits: 4),
  FlowSubject(code: 'FPTSP18-A', name: 'Optimización II', period: 8, credits: 4),
  FlowSubject(code: 'BPTM11-M', name: 'Modelos Estocásticos', period: 8, credits: 4),
  FlowSubject(code: 'BPTSP03-IV', name: 'Sistemas Operativos', period: 8, credits: 4),
  FlowSubject(code: 'FGE1', name: 'FGE', period: 8, credits: 4, isElective: true),

  // ── PERIODO IX ──
  FlowSubject(code: 'FPTSP17', name: 'Gestión Cadena Suministro I', period: 9, credits: 4),
  FlowSubject(code: 'FPTSP19', name: 'Modelación Sist. en Redes', period: 9, credits: 4),
  FlowSubject(code: 'BPTM06-III', name: 'Modelos Determinísticos', period: 9, credits: 4),
  FlowSubject(code: 'BPTSP07', name: 'Sistemas de Apoyo', period: 9, credits: 4),
  FlowSubject(code: 'FPS-IX', name: 'FPS', period: 9, credits: 2),
  FlowSubject(code: 'FGE2', name: 'FGE', period: 9, credits: 4, isElective: true),

  // ── PERIODO X ──
  FlowSubject(code: 'FPTSP28', name: 'Sistemas Distribuidos', period: 10, credits: 4),
  FlowSubject(code: 'FPTSP21', name: 'Análisis de Datos', period: 10, credits: 4),
  FlowSubject(code: 'FPTM21', name: 'Modelos Estocásticos II', period: 10, credits: 4),
  FlowSubject(code: 'BPTM07', name: 'Computación Energética', period: 10, credits: 4),
  FlowSubject(code: 'FGE3', name: 'FGE', period: 10, credits: 4, isElective: true),

  // ── PERIODO XI ──
  FlowSubject(code: 'FPTEG02', name: 'Sistemas de Redes', period: 11, credits: 4),
  FlowSubject(code: 'FPTSP7-A', name: 'Análisis de Proyectos TIC', period: 11, credits: 4),
  FlowSubject(code: 'FPTSP04', name: 'Gerencia de Proyectos TIC', period: 11, credits: 4),
  FlowSubject(code: 'BPTM37', name: 'Ingeniería Económica', period: 11, credits: 4),
  FlowSubject(code: 'FGE4', name: 'FGE', period: 11, credits: 4, isElective: true),

  // ── PERIODO XII ──
  FlowSubject(code: 'FPTEG23', name: 'Seguridad de Información', period: 12, credits: 4),
  FlowSubject(code: 'FPTEN3', name: 'Gerencia de la Seguridad', period: 12, credits: 4),
  FlowSubject(code: 'FPTSP11', name: 'Ingeniería Económica II', period: 12, credits: 4),
  FlowSubject(code: 'FGE5', name: 'FGE', period: 12, credits: 4, isElective: true),

  // ── PERIODO XIII ──
  FlowSubject(code: '150-BP', name: 'Proyecto de Ingeniería', period: 13, credits: 12),
  FlowSubject(code: 'FPTCS16', name: 'Ingeniería Ambiental', period: 13, credits: 4),
  FlowSubject(code: 'FPTSP15', name: 'Ingeniería Económica III', period: 13, credits: 4),
  FlowSubject(code: 'TALLER-GRADO', name: 'Taller Trabajo de Grado', period: 13, credits: 4),
  FlowSubject(code: 'FGE6', name: 'FGE', period: 13, credits: 4, isElective: true),
  FlowSubject(code: 'FGE7', name: 'FGE', period: 13, credits: 4, isElective: true),
];

// ─────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────
class FlujogramaScreen extends StatefulWidget {
  const FlujogramaScreen({super.key});

  @override
  State<FlujogramaScreen> createState() => _FlujogramaScreenState();
}

class _FlujogramaScreenState extends State<FlujogramaScreen> {
  Set<String> _checked = {};
  static const _prefsKey = 'flujograma_checked';

  static const int totalElectives = 7;

  @override
  void initState() {
    super.initState();
    _loadChecked();
  }

  Future<void> _loadChecked() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_prefsKey) ?? [];
    setState(() => _checked = list.toSet());
  }

  Future<void> _saveChecked() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, _checked.toList());
  }

  void _toggle(String code) {
    setState(() {
      if (_checked.contains(code)) {
        _checked.remove(code);
      } else {
        _checked.add(code);
      }
    });
    _saveChecked();
  }

  // ── Progress helpers ──
  int get _mandatoryTotal =>
      _subjects.where((s) => !s.isElective).length;
  int get _electiveTotal => totalElectives;
  int get _grandTotal => _mandatoryTotal + _electiveTotal;

  int get _mandatoryChecked =>
      _subjects.where((s) => !s.isElective && _checked.contains(s.code)).length;
  int get _electiveChecked {
    final ev = _subjects.where((s) => s.isElective).map((s) => s.code).toSet();
    return _checked.intersection(ev).length.clamp(0, totalElectives);
  }

  int get _totalChecked => _mandatoryChecked + _electiveChecked;
  double get _progress => _grandTotal > 0 ? _totalChecked / _grandTotal : 0;

  // ── Period grouping ──
  List<int> get _periods {
    final p = _subjects.map((s) => s.period).toSet().toList();
    p.sort();
    return p;
  }

  List<FlowSubject> _subjectsForPeriod(int period) =>
      _subjects.where((s) => s.period == period).toList();

  Color _periodColor(int period) {
    const colors = [
      Color(0xFF6C63FF),
      Color(0xFF4DA8DA),
      Color(0xFF44BD32),
      Color(0xFFFFB703),
      Color(0xFFE63946),
      Color(0xFFAB47BC),
      Color(0xFF26C6DA),
      Color(0xFFFF7043),
      Color(0xFF42A5F5),
      Color(0xFF78909C),
      Color(0xFF66BB6A),
      Color(0xFFEC407A),
      Color(0xFFFF6F00),
    ];
    return colors[(period - 1) % colors.length];
  }

  String _romanNumeral(int period) {
    const r = ['I','II','III','IV','V','VI','VII','VIII','IX','X','XI','XII','XIII'];
    return period > 0 && period <= r.length ? r[period - 1] : '$period';
  }

  @override
  Widget build(BuildContext context) {
    final progressPct = (_progress * 100).toStringAsFixed(1);
    final remaining = _grandTotal - _totalChecked;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6FB),
      body: CustomScrollView(
        slivers: [
          // ─── Header ───
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2D2C3C), Color(0xFF6C63FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.account_tree_rounded,
                          color: Colors.white, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'Flujograma – Ing. Sistemas',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'UNIMET  ·  Toca una materia para marcarla como vista',
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                  // Progress card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(20),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _statBox('Vistas', '$_totalChecked', Colors.greenAccent),
                            _statBox('Restantes', '$remaining', Colors.redAccent),
                            _statBox('Total', '$_grandTotal', Colors.white),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: _progress,
                                  minHeight: 10,
                                  backgroundColor: Colors.white24,
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.greenAccent,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '$progressPct%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _miniStat(
                                '📚 Obligatorias',
                                '$_mandatoryChecked / $_mandatoryTotal'),
                            _miniStat(
                                '🎓 Electivas',
                                '$_electiveChecked / $totalElectives'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Legend ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
              child: Row(
                children: [
                  _legendDot(Colors.green, 'Vista'),
                  const SizedBox(width: 16),
                  _legendDot(Colors.amber, 'Electiva'),
                  const SizedBox(width: 16),
                  _legendDot(Colors.grey[300]!, 'Pendiente'),
                ],
              ),
            ),
          ),

          // ─── Periods ───
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final period = _periods[index];
                final subs = _subjectsForPeriod(period);
                final color = _periodColor(period);
                final periodDone = subs.where((s) => _checked.contains(s.code)).length;

                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Period header
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _romanNumeral(period),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Período ${_romanNumeral(period)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF2D2C3C),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: color.withAlpha(20),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$periodDone/${subs.length}',
                              style: TextStyle(
                                color: color,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Subject cards
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: subs
                            .map((s) => _buildSubjectChip(s, color))
                            .toList(),
                      ),
                      if (index < _periods.length - 1)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Divider(color: Colors.grey[200]),
                        ),
                    ],
                  ),
                );
              },
              childCount: _periods.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildSubjectChip(FlowSubject s, Color periodColor) {
    final done = _checked.contains(s.code);
    final isElective = s.isElective;

    Color bg;
    Color textColor;
    Color border;

    if (done) {
      bg = Colors.green.withAlpha(20);
      textColor = Colors.green[800]!;
      border = Colors.green;
    } else if (isElective) {
      bg = Colors.amber.withAlpha(20);
      textColor = Colors.amber[900]!;
      border = Colors.amber;
    } else {
      bg = Colors.white;
      textColor = const Color(0xFF2D2C3C);
      border = Colors.grey[200]!;
    }

    return GestureDetector(
      onTap: () => _toggle(s.code),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: done ? 1.5 : 1),
          boxShadow: done
              ? [
                  BoxShadow(
                    color: Colors.green.withAlpha(30),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(8),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (done)
              const Padding(
                padding: EdgeInsets.only(right: 6),
                child: Icon(Icons.check_circle_rounded,
                    color: Colors.green, size: 16),
              )
            else if (isElective)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child:
                    Icon(Icons.stars_rounded, color: Colors.amber[700], size: 15),
              ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      decoration:
                          done ? TextDecoration.lineThrough : null,
                      decorationColor: Colors.green,
                      decorationThickness: 2,
                    ),
                  ),
                  Text(
                    '${s.code}  ·  ${s.credits} UC',
                    style: TextStyle(
                      fontSize: 9,
                      color: textColor.withAlpha(150),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statBox(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
              color: color, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(label,
            style: const TextStyle(color: Colors.white60, fontSize: 11)),
      ],
    );
  }

  Widget _miniStat(String label, String value) {
    return Text(
      '$label: $value',
      style: const TextStyle(color: Colors.white70, fontSize: 11),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
            width: 12,
            height: 12,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
