import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/core/widgets/loading_state.dart';
import 'package:tsiwa_mahber/features/csv_io/data/csv_service.dart';
import 'package:tsiwa_mahber/features/edir/data/edir_repository.dart';
import 'package:tsiwa_mahber/features/edir/domain/edir.dart';
import 'package:tsiwa_mahber/features/edir/domain/edir_member.dart';
import 'package:tsiwa_mahber/features/leadership/domain/leader.dart';
import 'package:tsiwa_mahber/features/members/domain/member.dart';
import 'package:tsiwa_mahber/features/tsiwa/data/tsiwa_repository.dart';
import 'package:tsiwa_mahber/features/tsiwa/domain/tsiwa_mahber.dart';

class CsvImportScreen extends StatefulWidget {
  final String areaId;

  const CsvImportScreen({super.key, required this.areaId});

  @override
  State<CsvImportScreen> createState() => _CsvImportScreenState();
}

class _CsvImportScreenState extends State<CsvImportScreen> {
  final _csvService = CsvService();
  final _tsiwaRepository = TsiwaRepository();
  final _edirRepository = EdirRepository();

  CsvEntityType _selectedType = CsvEntityType.tsiwaMembers;
  String? _selectedTsiwaId;
  String? _selectedEdirId;

  bool _isPicking = false;
  bool _isImporting = false;
  String? _csvContent;

  List<Member> _parsedMembers = [];
  List<Leader> _parsedLeaders = [];
  List<EdirMember> _parsedEdirMembers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CSV ከውጭ አስገባ')),
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
            const SizedBox(height: 16),
            _buildPickFileButton(),
            if (_csvContent != null) ...[
              const SizedBox(height: 24),
              _buildPreview(),
              const SizedBox(height: 24),
              _buildImportButton(),
            ],
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
                color: Colors.green.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.file_download_outlined,
                color: Colors.green,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CSV ከውጭ አስገባ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'CSV ፋይል መርጠው መረጃ ያስገቡ',
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
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'የመረጃ ዓይነት ይምረጡ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textMuted,
            ),
          ),
        ),
        ...CsvEntityType.values.map((type) => Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: RadioListTile<CsvEntityType>(
                title: Text(type.displayName),
                value: type,
                groupValue: _selectedType,
                activeColor: AppTheme.primary,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _selectedType = value;
                    _selectedTsiwaId = null;
                    _selectedEdirId = null;
                    _csvContent = null;
                    _parsedMembers = [];
                    _parsedLeaders = [];
                    _parsedEdirMembers = [];
                  });
                },
              ),
            )),
      ],
    );
  }

  Widget _buildTsiwaSelector() {
    return StreamBuilder<List<TsiwaMahber>>(
      stream: _tsiwaRepository.watchTsiwas(widget.areaId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingState(message: 'ፅዋ ማህበሮችን በመጫን ላይ...');
        }

        final tsiwas = snapshot.data ?? [];
        if (tsiwas.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'ምንም ፅዋ ማህበር አልተመዘገበም',
                style: TextStyle(color: AppTheme.textMuted),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'ፅዋ ማህበር ይምረጡ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMuted,
                ),
              ),
            ),
            ...tsiwas.map((tsiwa) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: RadioListTile<String>(
                    title: Text(tsiwa.name),
                    subtitle: tsiwa.churchName.isNotEmpty
                        ? Text(tsiwa.churchName,
                            style: const TextStyle(
                                fontSize: 12, color: AppTheme.textMuted))
                        : null,
                    value: tsiwa.id,
                    groupValue: _selectedTsiwaId,
                    activeColor: AppTheme.primary,
                    onChanged: (value) {
                      setState(() => _selectedTsiwaId = value);
                    },
                  ),
                )),
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
          return const LoadingState(message: 'እድሮችን በመጫን ላይ...');
        }

        final edirs = snapshot.data ?? [];
        if (edirs.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'ምንም እድር አልተመዘገበም',
                style: TextStyle(color: AppTheme.textMuted),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'እድር ይምረጡ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMuted,
                ),
              ),
            ),
            ...edirs.map((edir) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: RadioListTile<String>(
                    title: Text(edir.name),
                    value: edir.id,
                    groupValue: _selectedEdirId,
                    activeColor: AppTheme.primary,
                    onChanged: (value) {
                      setState(() => _selectedEdirId = value);
                    },
                  ),
                )),
          ],
        );
      },
    );
  }

  Widget _buildPickFileButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _isPicking ? null : _pickFile,
        icon: _isPicking
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.attach_file),
        label: Text(_csvContent != null ? 'ሌላ ፋይል ምረጥ' : 'CSV ፋይል ምረጥ'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: AppTheme.primary),
        ),
      ),
    );
  }

  Widget _buildPreview() {
    final int count;
    final List<String> headers;
    final List<List<String>> previewRows;

    switch (_selectedType) {
      case CsvEntityType.tsiwaMembers:
        count = _parsedMembers.length;
        headers = CsvService.memberHeaders;
        previewRows = _parsedMembers.take(5).map((m) => [
              m.fullName,
              m.christianName,
              m.phone,
              m.role.displayName,
            ]).toList();
        break;
      case CsvEntityType.leaders:
        count = _parsedLeaders.length;
        headers = CsvService.leaderHeaders;
        previewRows = _parsedLeaders.take(5).map((l) => [
              l.fullName,
              l.christianName,
              l.phone,
              l.role.displayName,
            ]).toList();
        break;
      case CsvEntityType.edirMembers:
        count = _parsedEdirMembers.length;
        headers = CsvService.edirMemberHeaders;
        previewRows = _parsedEdirMembers.take(5).map((m) => [
              m.fullName,
              m.christianName,
              m.phone,
              m.status.displayName,
            ]).toList();
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            '$count መረጃዎች ተገኝተዋል',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  AppTheme.primary.withValues(alpha: 0.1),
                ),
                columns: headers
                    .take(4)
                    .map((h) => DataColumn(
                          label: Text(h,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12)),
                        ))
                    .toList(),
                rows: previewRows
                    .map((row) => DataRow(
                          cells: row
                              .map((cell) => DataCell(
                                    Text(cell,
                                        style: const TextStyle(fontSize: 12)),
                                  ))
                              .toList(),
                        ))
                    .toList(),
              ),
            ),
          ),
        ),
        if (count > 5)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 4),
            child: Text(
              '... እና ${count - 5} ተጨማሪ',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textMuted,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImportButton() {
    final int count;
    switch (_selectedType) {
      case CsvEntityType.tsiwaMembers:
        count = _parsedMembers.length;
        break;
      case CsvEntityType.leaders:
        count = _parsedLeaders.length;
        break;
      case CsvEntityType.edirMembers:
        count = _parsedEdirMembers.length;
        break;
    }

    final canImport = count > 0 &&
        (_selectedType == CsvEntityType.leaders ||
            (_selectedType == CsvEntityType.tsiwaMembers &&
                _selectedTsiwaId != null) ||
            (_selectedType == CsvEntityType.edirMembers &&
                _selectedEdirId != null));

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: canImport && !_isImporting ? _doImport : null,
        icon: _isImporting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              )
            : const Icon(Icons.upload),
        label: Text(_isImporting ? 'በማስገባት ላይ...' : '$count መረጃ አስገባ'),
      ),
    );
  }

  Future<void> _pickFile() async {
    setState(() => _isPicking = true);

    try {
      final content = await _csvService.pickCsvFile();
      if (content == null) {
        setState(() => _isPicking = false);
        return;
      }

      setState(() => _csvContent = content);

      switch (_selectedType) {
        case CsvEntityType.tsiwaMembers:
          final members = await _csvService.parseMembersCsv(content);
          setState(() => _parsedMembers = members);
          break;
        case CsvEntityType.leaders:
          final leaders = await _csvService.parseLeadersCsv(content);
          setState(() => _parsedLeaders = leaders);
          break;
        case CsvEntityType.edirMembers:
          final edirMembers =
              await _csvService.parseEdirMembersCsv(content);
          setState(() => _parsedEdirMembers = edirMembers);
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ፋይሉን ማንበብ አልተቻለም: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  Future<void> _doImport() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ማረጋገጫ'),
        content: Text(
          'መረጃዎቹን ወደ ውስጥ ማስገባት ይፈልጋሉ?\n'
          'ነባር መረጃዎች አይቀየሩም — አዲስ ብቻ ይጨመራሉ።',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ተው'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('አስገባ'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isImporting = true);

    try {
      int imported = 0;

      switch (_selectedType) {
        case CsvEntityType.tsiwaMembers:
          imported = await _csvService.importMembers(
            widget.areaId,
            _selectedTsiwaId!,
            _parsedMembers,
          );
          break;
        case CsvEntityType.leaders:
          imported = await _csvService.importLeaders(
            widget.areaId,
            _parsedLeaders,
          );
          break;
        case CsvEntityType.edirMembers:
          imported = await _csvService.importEdirMembers(
            widget.areaId,
            _selectedEdirId!,
            _parsedEdirMembers,
          );
          break;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$imported መረጃዎች ተጨምረዋል')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ስህተት: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }
}
