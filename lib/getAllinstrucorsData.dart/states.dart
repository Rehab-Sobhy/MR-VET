import 'package:education_app/getAllinstrucorsData.dart/model.dart';
// Import the model

// States
abstract class InstructorState {
  @override
  List<Object?> get props => [];
}

class InstructorInitial extends InstructorState {}

class InstructorLoading extends InstructorState {}

class InstructorSuccess extends InstructorState {
  final List<InstructorModel> instructors;

  InstructorSuccess(this.instructors);

  @override
  List<Object?> get props => [instructors];
}

class InstructorFailure extends InstructorState {
  final String error;

  InstructorFailure(this.error);

  @override
  List<Object?> get props => [error];
}
