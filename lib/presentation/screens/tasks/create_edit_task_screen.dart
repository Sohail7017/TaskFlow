import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/entities/project.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/project_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../core/di/injection.dart';
import '../../bloc/tasks/task_bloc.dart';
import '../../bloc/tasks/task_event.dart';
import '../../bloc/tasks/task_state.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_form_field.dart';

/// Form modes supported by [CreateEditTaskScreen]
enum TaskFormMode {
  create,
  edit,
}

/// Premium, production-quality Create and Edit Task Form Screen for TaskFlow
class CreateEditTaskScreen extends StatefulWidget {
  const CreateEditTaskScreen({
    super.key,
    this.mode = TaskFormMode.create,
    this.taskId,
  });

  final TaskFormMode mode;
  final String? taskId;

  @override
  State<CreateEditTaskScreen> createState() => _CreateEditTaskScreenState();
}

class _CreateEditTaskScreenState extends State<CreateEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  Project? _selectedProject;
  TaskStatus _selectedStatus = TaskStatus.todo;
  TaskPriority _selectedPriority = TaskPriority.medium;
  User? _selectedAssignee;
  DateTime? _selectedDueDate;

  List<Project> _projects = [];
  List<User> _teamMembers = [];

  bool get isEdit => widget.mode == TaskFormMode.edit;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final orgId = context.read<AuthBloc>().state.orgId;
    if (orgId != null) {
      _projects = await sl<ProjectRepository>().getProjectsByOrgId(orgId);
      _teamMembers = await sl<UserRepository>().getUsersByOrgId(orgId);
    }

    if (isEdit && widget.taskId != null) {
      final task = context.read<TaskBloc>().state.tasks.where((t) => t.id == widget.taskId).firstOrNull;
      if (task != null) {
        _titleController.text = task.title;
        _descriptionController.text = task.description;
        _selectedProject = _projects.where((p) => p.id == task.projectId).firstOrNull;
        _selectedStatus = task.status;
        _selectedPriority = task.priority;
        _selectedAssignee = _teamMembers.where((u) => u.id == task.assigneeId).firstOrNull;
        _selectedDueDate = task.dueDate;
      }
    } else if (_projects.isNotEmpty) {
      _selectedProject = _projects.first;
    }
    
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _selectedDueDate = picked);
    }
  }

  void _handleSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_selectedProject == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a project.')));
      return;
    }

    if (isEdit) {
       final task = context.read<TaskBloc>().state.tasks.firstWhere((t) => t.id == widget.taskId);
       final updated = Task(
         id: task.id,
         projectId: _selectedProject!.id,
         title: _titleController.text.trim(),
         description: _descriptionController.text.trim(),
         status: _selectedStatus,
         priority: _selectedPriority,
         assigneeId: _selectedAssignee?.id,
         dueDate: _selectedDueDate,
         createdAt: task.createdAt,
       );
       context.read<TaskBloc>().add(UpdateTask(updated));
    } else {
      context.read<TaskBloc>().add(CreateTask(
        projectId: _selectedProject!.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        status: _selectedStatus,
        priority: _selectedPriority,
        assigneeId: _selectedAssignee?.id,
        dueDate: _selectedDueDate,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<TaskBloc, TaskState>(
      listenWhen: (previous, current) => 
        previous.status == TaskStatusEnum.loading && 
        (current.status == TaskStatusEnum.success || current.status == TaskStatusEnum.error),
      listener: (context, state) {
        if (state.status == TaskStatusEnum.success) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Task ${isEdit ? 'updated' : 'created'} successfully!'), backgroundColor: AppColors.success),
          );
          context.pop();
        } else if (state.status == TaskStatusEnum.error) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(state.errorMessage ?? 'Error'), backgroundColor: colorScheme.error),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppDimensions.space20.r),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   _buildHeader(context),
                   SizedBox(height: 20.h),
                   AppTextFormField(
                     controller: _titleController,
                     label: 'Task title',
                     hintText: 'What needs to be done?',
                     validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                   ),
                   SizedBox(height: 16.h),
                   AppTextFormField(
                     controller: _descriptionController,
                     label: 'Description',
                     maxLines: 3,
                     validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                   ),
                   SizedBox(height: 16.h),
                   
                   _buildDropdown<Project>(
                     label: 'Project',
                     value: _selectedProject,
                     items: _projects.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
                     onChanged: (v) => setState(() => _selectedProject = v),
                   ),

                   SizedBox(height: 16.h),
                   Row(
                     children: [
                       Expanded(child: _buildDropdown<TaskStatus>(
                         label: 'Status',
                         value: _selectedStatus,
                         items: TaskStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
                         onChanged: (v) => setState(() => _selectedStatus = v!),
                       )),
                       SizedBox(width: 12.w),
                       Expanded(child: _buildDropdown<TaskPriority>(
                         label: 'Priority',
                         value: _selectedPriority,
                         items: TaskPriority.values.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
                         onChanged: (v) => setState(() => _selectedPriority = v!),
                       )),
                     ],
                   ),

                   SizedBox(height: 16.h),
                   _buildDropdown<User?>(
                     label: 'Assignee',
                     value: _selectedAssignee,
                     items: [
                       const DropdownMenuItem(value: null, child: Text('Unassigned')),
                       ..._teamMembers.map((u) => DropdownMenuItem(value: u, child: Text(u.name))),
                     ],
                     onChanged: (v) => setState(() => _selectedAssignee = v),
                   ),

                   SizedBox(height: 16.h),
                   InkWell(
                     onTap: () => _selectDueDate(context),
                     child: InputDecorator(
                       decoration: const InputDecoration(labelText: 'Due Date'),
                       child: Text(_selectedDueDate == null ? 'Select Date' : '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}'),
                     ),
                   ),

                   SizedBox(height: 32.h),
                   BlocBuilder<TaskBloc, TaskState>(
                     builder: (context, state) {
                       return AppButton(
                         text: isEdit ? 'Save Changes' : 'Create Task',
                         isLoading: state.status == TaskStatusEnum.loading,
                         onPressed: _handleSubmit,
                       );
                     },
                   ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        Text(isEdit ? 'Edit Task' : 'Create Task', style: textTheme.headlineSmall),
      ],
    );
  }

  Widget _buildDropdown<T>({required String label, required T? value, required List<DropdownMenuItem<T>> items, required ValueChanged<T?> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
        ),
      ],
    );
  }
}
