abstract class EnrollmentState {}

class EnrollmentInitial extends EnrollmentState {}

class EnrollmentLoading extends EnrollmentState {}

class EnrollmentSuccess extends EnrollmentState {}

class EnrollmentForbidden extends EnrollmentState {
  final String message;
  EnrollmentForbidden(this.message);
}

class EnrollmentError extends EnrollmentState {
  final String message;
  EnrollmentError(this.message);
}
