import 'package:education_app/getAllinstrucorsData.dart/model.dart';
import 'package:education_app/getAllinstrucorsData.dart/states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dio/dio.dart';

class InstructorCubit extends Cubit<InstructorState> {
  InstructorCubit() : super(InstructorInitial());

  final Dio _dio = Dio();

  Future<void> fetchInstructors() async {
    emit(InstructorLoading());
    try {
      final response = await _dio.get(
        'https://mrvet-production.up.railway.app/api/users/instructors-with-courses',
      );

      final data = response.data['instructors'] as List;
      final instructors =
          data.map((json) => InstructorModel.fromJson(json)).toList();

      emit(InstructorSuccess(instructors));
    } catch (e) {
      emit(InstructorFailure(e.toString()));
    }
  }
}
