import 'package:flutter/material.dart';
import '../domain/entities/title.dart' as domain_title;
import '../data/datasources/title_remote_datasource.dart';
import 'create_title_screen.dart';
import 'edit_title_screen.dart';

class TitleListScreen extends StatefulWidget {
  const TitleListScreen({super.key});

  @override
  State<TitleListScreen> createState() => _TitleListScreenState();
}

class _TitleListScreenState extends State<TitleListScreen> {
  final TitleRemoteDataSource _dataSource = TitleRemoteDataSourceImpl();
  List<domain_title.Title> titles = [];
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadTitles();
  }

  Future<void> _loadTitles() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final models = await _dataSource.getTitles();
      setState(() {
        titles = models.map((model) => domain_title.Title(
          id: model.id,
          name: model.name,
          description: model.description,
          createdAt: DateTime.now(), // API doesn't return createdAt, use current time
        )).toList();
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        // For demo, add some mock data
        titles = [
          domain_title.Title(id: '1', name: 'Manager', description: 'Management position', createdAt: DateTime.now()),
          domain_title.Title(id: '2', name: 'Developer', description: 'Software developer', createdAt: DateTime.now()),
        ];
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteTitle(domain_title.Title title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa chức vụ "${title.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _dataSource.deleteTitle(title.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Xóa chức vụ thành công')),
          );
          _loadTitles();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách chức vụ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateTitleScreen(),
                ),
              );
              if (result == true) {
                _loadTitles();
              }
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Lỗi: $error'),
            ElevatedButton(
              onPressed: _loadTitles,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (titles.isEmpty) {
      return const Center(
        child: Text('Không có chức vụ nào'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTitles,
      child: ListView.builder(
        itemCount: titles.length,
        itemBuilder: (context, index) {
          final title = titles[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              title: Text(title.name),
              subtitle: title.description != null
                  ? Text(title.description!)
                  : null,
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Chỉnh sửa'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Xóa', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) async {
                  if (value == 'edit') {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditTitleScreen(
                          titleId: title.id,
                        ),
                      ),
                    );
                    if (result == true) {
                      _loadTitles();
                    }
                  } else if (value == 'delete') {
                    _deleteTitle(title);
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
