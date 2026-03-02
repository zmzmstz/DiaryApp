import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math';
import '../../logic/blocs/backlog_bloc.dart';
import '../../models/backlog_item.dart';

class AddEditItemPage extends StatefulWidget {
  final BacklogItem? item;
  const AddEditItemPage({super.key, this.item});

  @override
  State<AddEditItemPage> createState() => _AddEditItemPageState();
}

class _AddEditItemPageState extends State<AddEditItemPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _reviewController;
  late BacklogType _selectedType;
  late BacklogStatus _selectedStatus;
  double _rating = 0;
  bool _isRatingEnabled = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item?.title ?? '');
    _reviewController = TextEditingController(text: widget.item?.review ?? '');
    _selectedType = widget.item?.type ?? BacklogType.movie;
    _selectedStatus = widget.item?.status ?? BacklogStatus.planned;
    _rating = widget.item?.rating ?? 0;
    _isRatingEnabled = widget.item?.rating != null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final newItem = BacklogItem(
        id: widget.item?.id ?? Random().nextInt(100000).toString(),
        title: _titleController.text,
        type: _selectedType,
        status: _selectedStatus,
        rating: _isRatingEnabled ? _rating : null,
        review: _reviewController.text.isNotEmpty ? _reviewController.text : null,
        createdAt: widget.item?.createdAt ?? DateTime.now(),
        dateCompleted: _selectedStatus == BacklogStatus.completed ? DateTime.now() : null,
      );

      if (widget.item != null) {
        context.read<BacklogBloc>().add(UpdateBacklogItem(newItem));
      } else {
        context.read<BacklogBloc>().add(AddBacklogItem(newItem));
      }
      
      // Delay pop slightly to allow event to process if needed, though bloc is async 
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.item != null ? 'Item updated!' : 'Item added!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item != null ? 'Edit Item' : 'Add New Item'),
        actions: [
          IconButton(
            onPressed: _save,
            icon: const FaIcon(FontAwesomeIcons.check),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<BacklogType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: BacklogType.values.map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: Text(e.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedType = val!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<BacklogStatus>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.info),
                ),
                items: BacklogStatus.values.map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: Text(e.name.toUpperCase().replaceAll('INPROGRESS', 'IN PROGRESS')),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedStatus = val!),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _isRatingEnabled, 
                    onChanged: (val) => setState(() => _isRatingEnabled = val!),
                  ),
                  const Text("Add Rating?"),
                ],
              ),
              if (_isRatingEnabled)
                Column(
                  children: [
                    Slider(
                      value: _rating,
                      min: 0,
                      max: 5,
                      divisions: 10,
                      label: _rating.toString(),
                      onChanged: (val) => setState(() => _rating = val),
                    ),
                    Text("Rating: $_rating / 5.0", style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reviewController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Review / Notes',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: const Text("Save Item"),
                  style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
