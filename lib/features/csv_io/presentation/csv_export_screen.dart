import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/core/widgets/loading_state.dart';
import 'package:tsiwa_mahber/features/csv_io/data/csv_service.dart';
import 'package:tsiwa_mahber/features/edir/data/edir_repository.dart';
import 'package:tsiwa_mahber/features/edir/domain/edir.dart';
import 'package:tsiwa_mahber/features/tsiwa/data/tsiwa_repository.dart';
import 'package:tsiwa_mahber/features/tsiwa/domain/tsiwa_mahber.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';

class CsvExportScreen extends StatefulWidget {
  final String areaId;

  const CsvExportScreen({super.key, required this.areaId});

  @override
  State<CsvExportScreen> createState() => _CsvExportScreenState();
}

class _CsvExportScreenState extends State<CsvExportScreen> {
  final _csvService = CsvService();
  final _tsiwaRepository = TsiwaRepository();
  final _edirRepository = EdirRepository();

  CsvEntityType _selectedType = CsvEntityType.tsiwaMembers;
  String? _selectedTsiwaId;
  String? _selectedEdirId;
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.csvExportMenu)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 24),
            _buildTypeSelector(),
            const SizedBox(height: 16),
            if (_selectedType == CsvEntityType.tsiwaMembers)
              _buildTsiwaSelector(),
            if (_selectedType == CsvEntityType.edirMembers)
              _buildEdirSelector(),
            const SizedBox(height: 32),
            _buildExportButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.file_upload_outlined,
                color: AppTheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.csvExportMenu,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    S.csvExportDesc,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textMuted,
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

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            S.selectDataType,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textMuted,
            ),
          ),
        ),
        RadioGroup<CsvEntityType>(
          groupValue: _selectedType,
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _selectedType = value;
              _selectedTsiwaId = null;
              _selectedEdirId = null;
            });
          },
          child: Column(
            children: CsvEntityType.values.map((type) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: RadioListTile<CsvEntityType>(
                    title: Text(type.displayName),
                    value: type,
                    activeColor: AppTheme.primary,
                  ),
                )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTsiwaSelector() {
    return StreamBuilder<List<TsiwaMahber>>(
      stream: _tsiwaRepository.watchTsiwas(widget.areaId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingState(message: S.loadingTsiwas);
        }

        final tsiwas = snapshot.data ?? [];
        if (tsiwas.isEmpty) {
          return Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                S.noTsiwaRegistered,
                style: TextStyle(color: AppTheme.textMuted),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                S.selectTsiwa,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMuted,
                ),
              ),
            ),
            RadioGroup<String>(
              groupValue: _selectedTsiwaId,
              onChanged: (value) {
                setState(() => _selectedTsiwaId = value);
              },
              child: Column(
                children: tsiwas.map((tsiwa) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: RadioListTile<String>(
                        title: Text(tsiwa.name),
                        subtitle: tsiwa.churchName.isNotEmpty
                            ? Text(tsiwa.churchName,
                                style: const TextStyle(
                                    fontSize: 12, color: AppTheme.textMuted))
                            : null,
                        value: tsiwa.id,
                        activeColor: AppTheme.primary,
                      ),
                    )).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEdirSelector() {
    return StreamBuilder<List<Edir>>(
      stream: _edirRepository.watchEdirs(widget.areaId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingState(message: S.loadingEdirs);
        }

        final edirs = snapshot.data ?? [];
        if (edirs.isEmpty) {
          return Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                S.noEdirRegistered,
                style: TextStyle(color: AppTheme.textMuted),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                S.selectEdir,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMuted,
                ),
              ),
            ),
            RadioGroup<String>(
              groupValue: _selectedEdirId,
              onChanged: (value) {
                setState(() => _selectedEdirId = value);
              },
              child: Column(
                children: edirs.map((edir) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: RadioListTile<String>(
                        title: Text(edir.name),
                        value: edir.id,
                        activeColor: AppTheme.primary,
                      ),
                    )).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExportButton() {
    final canExport = _selectedType == CsvEntityType.leaders ||
        (_selectedType == CsvEntityType.tsiwaMembers &&
            _selectedTsiwaId != null) ||
        (_selectedType == CsvEntityType.edirMembers &&
            _selectedEdirId != null);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: canExport && !_isExporting ? _doExport : null,
        icon: _isExporting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              )
            : const Icon(Icons.download),
        label: Text(_isExporting ? S.exporting : S.csvExportMenu),
      ),
    );
  }

  Future<void> _doExport() async {
    setState(() => _isExporting = true);

    try {
      String csv;
      String fileName;

      switch (_selectedType) {
        case CsvEntityType.tsiwaMembers:
          csv = await _csvService.exportMembers(
              widget.areaId, _selectedTsiwaId!);
          fileName = CsvEntityType.tsiwaMembers.fileName;
          break;
        case CsvEntityType.leaders:
          csv = await _csvService.exportLeaders(widget.areaId);
          fileName = CsvEntityType.leaders.fileName;
          break;
        case CsvEntityType.edirMembers:
          csv = await _csvService.exportEdirMembers(
              widget.areaId, _selectedEdirId!);
          fileName = CsvEntityType.edirMembers.fileName;
          break;
      }

      final file = await _csvService.writeCsvFile(csv, fileName);
      await _csvService.shareCsvFile(file);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CSV ተልኳል')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ስህተት: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }
}
