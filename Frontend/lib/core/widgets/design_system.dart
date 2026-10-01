import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supervisacampo/core/models/app_models.dart';
import 'package:supervisacampo/core/theme/app_theme.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.fullWidth = true,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool fullWidth;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final button = FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.papel,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        elevation: 0,
      ),
      child: isLoading
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Procesando'),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  minHeight: 2,
                  backgroundColor: AppColors.primarySoft,
                  color: AppColors.papel,
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
    );

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.tinta, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon),
              const SizedBox(width: AppSpacing.sm),
            ],
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DangerButton extends StatelessWidget {
  const DangerButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        backgroundColor: AppColors.rojo,
        foregroundColor: AppColors.papel,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[Icon(icon), const SizedBox(width: 8)],
          Text(label),
        ],
      ),
    ),
  );
}

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.papel,
      elevation: 0,
      shadowColor: AppColors.tinta,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(padding: padding, child: child),
    );
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.background,
  });

  final String label;
  final Color color;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Estado: $label',
      child: AnimatedContainer(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : AppMotion.fast,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: background ?? color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_statusIcon(label), size: 14, color: color),
            const SizedBox(width: 4),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 160),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.tinta,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _statusIcon(String value) {
    final label = value.toLowerCase();
    if (label.contains('error') ||
        label.contains('fuera') ||
        label.contains('no cumple')) {
      return Icons.close_rounded;
    }
    if (label.contains('cumple') ||
        label.contains('sincronizado') ||
        label.contains('cerrad') ||
        label.contains('realizada')) {
      return Icons.check_rounded;
    }
    if (label.contains('pendiente') ||
        label.contains('abierta') ||
        label.contains('revisión')) {
      return Icons.schedule_rounded;
    }
    return Icons.info_outline_rounded;
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.background,
  });

  final String label;
  final Color color;
  final Color? background;
  final IconData? icon;

  @override
  Widget build(BuildContext context) =>
      StatusBadge(label: label, color: color, background: background);
}

class HazardTag extends StatelessWidget {
  const HazardTag({super.key, required this.priority, this.label});

  final String priority;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final highPriority = priority.toLowerCase() == 'alta';
    return CustomPaint(
      foregroundPainter: highPriority ? _HazardStripePainter() : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.precaucion,
          border: Border.all(color: AppColors.tinta, width: 1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.tinta,
              size: 17,
            ),
            const SizedBox(width: 5),
            Text(
              label ?? priority,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.tinta,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SuthonWordmark extends StatelessWidget {
  const SuthonWordmark({super.key, this.fontSize = 44, this.color});

  final double fontSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontFamily: 'BigShouldersDisplay',
      fontSize: fontSize,
      height: 1,
      fontWeight: FontWeight.w800,
      color: color ?? AppColors.tinta,
    );
    return Semantics(
      label: 'Suthon',
      child: ExcludeSemantics(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Suth', style: style),
              SizedBox(
                width: fontSize * 0.48,
                height: fontSize * 0.58,
                child: CustomPaint(
                  painter: _BrandPinPainter(color: color ?? AppColors.dotacion),
                ),
              ),
              Text('n', style: style),
            ],
          ),
        ),
      ),
    );
  }
}

class VisitTicket extends StatelessWidget {
  const VisitTicket({
    super.key,
    required this.visit,
    required this.onTap,
    this.centerName,
  });

  final Visit visit;
  final String? centerName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = _visitStatus(visit);
    final scheduled = visit.scheduledAt ?? visit.startTime;
    return CustomPaint(
      painter: const _TicketPainter(),
      child: Material(
        color: AppColors.papel,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: AppColors.linea),
        ),
        child: InkWell(
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(width: 6, color: status.color),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 14, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          centerName ?? visit.title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          visit.location,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              '${scheduled.hour.toString().padLeft(2, '0')}:${scheduled.minute.toString().padLeft(2, '0')}',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                            ),
                            StatusPill(
                              label: status.label,
                              color: status.color,
                              background: status.background,
                            ),
                            Text(
                              'Prioridad ${visit.priority.toLowerCase()}',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ({String label, Color color, Color background}) _visitStatus(Visit visit) {
    if (visit.inRange == false) {
      return (
        label: 'Fuera de rango',
        color: AppColors.rojo,
        background: AppColors.dangerSoft,
      );
    }
    return switch (visit.status) {
      VisitStatus.planned => (
        label: 'Pendiente',
        color: AppColors.dotacion,
        background: AppColors.primarySoft,
      ),
      VisitStatus.inProgress => (
        label: 'En curso',
        color: AppColors.tinta,
        background: AppColors.baldosa,
      ),
      VisitStatus.completed => (
        label: 'Completada',
        color: AppColors.verde,
        background: AppColors.successSoft,
      ),
      VisitStatus.blocked => (
        label: 'Bloqueada',
        color: AppColors.rojo,
        background: AppColors.dangerSoft,
      ),
    };
  }
}

class InspectionSheet extends StatelessWidget {
  const InspectionSheet({
    super.key,
    required this.items,
    required this.onResult,
    required this.onObservationChanged,
    required this.onAddPhoto,
  });

  final List<ChecklistItem> items;
  final void Function(ChecklistItem item, ChecklistResult result) onResult;
  final void Function(ChecklistItem item, String observation)
  onObservationChanged;
  final Future<void> Function(ChecklistItem item) onAddPhoto;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.papel,
      border: Border.all(color: AppColors.linea),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Column(
      children: [
        for (var index = 0; index < items.length; index++) ...[
          _InspectionRow(
            item: items[index],
            onResult: (result) => onResult(items[index], result),
            onObservationChanged: (value) =>
                onObservationChanged(items[index], value),
            onAddPhoto: () => onAddPhoto(items[index]),
          ),
          if (index != items.length - 1)
            const Divider(height: 1, thickness: 1, color: AppColors.linea),
        ],
      ],
    ),
  );
}

class _InspectionRow extends StatefulWidget {
  const _InspectionRow({
    required this.item,
    required this.onResult,
    required this.onObservationChanged,
    required this.onAddPhoto,
  });

  final ChecklistItem item;
  final ValueChanged<ChecklistResult> onResult;
  final ValueChanged<String> onObservationChanged;
  final VoidCallback onAddPhoto;

  @override
  State<_InspectionRow> createState() => _InspectionRowState();
}

class _InspectionRowState extends State<_InspectionRow> {
  late final TextEditingController _observationController;

  @override
  void initState() {
    super.initState();
    _observationController = TextEditingController(
      text: widget.item.observation,
    );
  }

  @override
  void didUpdateWidget(covariant _InspectionRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _observationController.text = widget.item.observation;
    }
  }

  @override
  void dispose() {
    _observationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final issue = widget.item.result == ChecklistResult.noCumple;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 30,
                height: 30,
                child: CustomPaint(
                  painter: _ChecklistBoxPainter(widget.item.result),
                  child: widget.item.result == ChecklistResult.cumple
                      ? TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: MediaQuery.disableAnimationsOf(context)
                              ? Duration.zero
                              : const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, _) =>
                              CustomPaint(painter: _CheckStrokePainter(value)),
                        )
                      : issue
                      ? const CustomPaint(painter: _CrossPainter())
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    widget.item.title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: [
              _resultChoice(
                context,
                'Cumple',
                widget.item.result == ChecklistResult.cumple,
                AppColors.verde,
                () => widget.onResult(ChecklistResult.cumple),
              ),
              _resultChoice(context, 'No cumple', issue, AppColors.rojo, () {
                HapticFeedback.selectionClick();
                widget.onResult(ChecklistResult.noCumple);
              }),
            ],
          ),
          if (issue) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _observationController,
              minLines: 1,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Observación'),
              onChanged: widget.onObservationChanged,
            ),
            TextButton.icon(
              onPressed: widget.onAddPhoto,
              icon: const Icon(Icons.add_a_photo_outlined),
              label: Text(
                widget.item.photoPath == null
                    ? 'Adjuntar foto'
                    : 'Cambiar foto',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _resultChoice(
    BuildContext context,
    String label,
    bool selected,
    Color color,
    VoidCallback onTap,
  ) => Semantics(
    button: true,
    selected: selected,
    label: label,
    child: SizedBox(
      height: 44,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: selected ? color : AppColors.tinta,
          side: BorderSide(
            color: selected ? color : AppColors.linea,
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              Icon(
                label == 'Cumple' ? Icons.check_rounded : Icons.close_rounded,
                size: 17,
              ),
              const SizedBox(width: 4),
            ],
            Text(label),
          ],
        ),
      ),
    ),
  );
}

class _TicketPainter extends CustomPainter {
  const _TicketPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = AppColors.linea
      ..strokeWidth = 1;
    const dashY = 8.0;
    for (var y = 12.0; y < size.height - 8; y += dashY) {
      canvas.drawLine(Offset(24, y), Offset(24, y + 3), line);
    }
    final notchPaint = Paint()..color = AppColors.baldosa;
    canvas
      ..drawCircle(Offset(0, size.height * 0.28), 7, notchPaint)
      ..drawCircle(Offset(0, size.height * 0.72), 7, notchPaint);
  }

  @override
  bool shouldRepaint(covariant _TicketPainter oldDelegate) => false;
}

class _HazardStripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.tinta.withValues(alpha: 0.12)
      ..strokeWidth = 3;
    for (var x = 0.0; x < size.width; x += 10) {
      canvas.drawLine(Offset(x, size.height), Offset(x + 8, 0), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _HazardStripePainter oldDelegate) => false;
}

class _BrandPinPainter extends CustomPainter {
  const _BrandPinPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final center = Offset(size.width / 2, size.height * 0.42);
    canvas.drawCircle(center, size.width * 0.34, stroke);
    final tail = Path()
      ..moveTo(center.dx - size.width * 0.23, center.dy + size.height * 0.18)
      ..lineTo(center.dx, size.height * 0.96)
      ..lineTo(center.dx + size.width * 0.23, center.dy + size.height * 0.18);
    canvas.drawPath(tail, stroke);
    final check = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(
      Path()
        ..moveTo(center.dx - size.width * 0.15, center.dy)
        ..lineTo(center.dx - size.width * 0.03, center.dy + size.width * 0.12)
        ..lineTo(center.dx + size.width * 0.17, center.dy - size.width * 0.13),
      check,
    );
  }

  @override
  bool shouldRepaint(covariant _BrandPinPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _ChecklistBoxPainter extends CustomPainter {
  const _ChecklistBoxPainter(this.result);

  final ChecklistResult result;

  @override
  void paint(Canvas canvas, Size size) {
    final fill = result == ChecklistResult.cumple
        ? AppColors.successSoft
        : result == ChecklistResult.noCumple
        ? AppColors.dangerSoft
        : AppColors.papel;
    final color = result == ChecklistResult.cumple
        ? AppColors.verde
        : result == ChecklistResult.noCumple
        ? AppColors.rojo
        : AppColors.linea;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(4)),
      Paint()..color = fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(4)),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _ChecklistBoxPainter oldDelegate) =>
      oldDelegate.result != result;
}

class _CheckStrokePainter extends CustomPainter {
  const _CheckStrokePainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.52)
      ..lineTo(size.width * 0.42, size.height * 0.72)
      ..lineTo(size.width * 0.82, size.height * 0.26);
    final metrics = path.computeMetrics().first;
    canvas.drawPath(
      metrics.extractPath(0, metrics.length * progress),
      Paint()
        ..color = AppColors.verde
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _CheckStrokePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _CrossPainter extends CustomPainter {
  const _CrossPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.rojo
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawLine(
        Offset(size.width * 0.28, size.height * 0.28),
        Offset(size.width * 0.72, size.height * 0.72),
        paint,
      )
      ..drawLine(
        Offset(size.width * 0.72, size.height * 0.28),
        Offset(size.width * 0.28, size.height * 0.72),
        paint,
      );
  }

  @override
  bool shouldRepaint(covariant _CrossPainter oldDelegate) => false;
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.maxLines = 1,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.errorText,
    this.validator,
    this.onChanged,
    this.onSubmitted,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final int maxLines;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? errorText;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge
              ?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.tinta.withValues(alpha: 0.78),
              ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          minLines: maxLines == 1 ? 1 : null,
          decoration: InputDecoration(
            errorText: errorText,
            hintText: hint,
            prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
          ),
        ),
      ],
    );
  }
}

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, this.visible = false});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.warningSoft,
      child: Row(
        children: [
          const Icon(Icons.signal_wifi_off_rounded, color: AppColors.tinta, size: 18),
          const SizedBox(width: 8),
          Text(
            'Sin conexión temporal',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: AppColors.tinta),
          ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.inbox_outlined,
                size: 32,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.rojo),
        borderRadius: BorderRadius.circular(6),
        color: AppColors.dangerSoft,
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.danger),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedPageContainer extends StatelessWidget {
  const AnimatedPageContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onItemTapped,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onItemTapped;
  final List<({IconData icon, String label})> items;

  @override
  Widget build(BuildContext context) {
    final selectedIndex = currentIndex.clamp(0, items.length - 1);
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.papel,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: [
              for (var index = 0; index < items.length; index++)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: selectedIndex == index,
                    label: items[index].label,
                    child: InkWell(
                      onTap: () => onItemTapped(index),
                      child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              AnimatedContainer(
                                duration: MediaQuery.disableAnimationsOf(context)
                                    ? Duration.zero
                                    : AppMotion.fast,
                                height: 3,
                                width: selectedIndex == index ? 30 : 0,
                                color: AppColors.dotacion,
                              ),
                              const SizedBox(height: 4),
                            Icon(
                              items[index].icon,
                              size: 22,
                              color: selectedIndex == index
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              items[index].label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: selectedIndex == index
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                    fontWeight: selectedIndex == index
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
