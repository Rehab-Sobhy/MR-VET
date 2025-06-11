abstract class MaterialsState {}

class MaterialsInitial extends MaterialsState {}

class MaterialsLoading extends MaterialsState {}

class MaterialsFailure extends MaterialsState {
  final String error;
  MaterialsFailure(this.error);
}

class MaterialsSuccess extends MaterialsState {
  final List<dynamic> materials; // Changed to List<dynamic>
  final Map<String, double> downloadProgress;

  MaterialsSuccess(this.materials, {Map<String, double>? downloadProgress})
      : downloadProgress = downloadProgress ?? {};

  MaterialsSuccess copyWith({
    List<dynamic>? materials,
    Map<String, double>? downloadProgress,
  }) {
    return MaterialsSuccess(
      materials ?? this.materials,
      downloadProgress: downloadProgress ?? this.downloadProgress,
    );
  }
}

class FileUploadInitial extends MaterialsState {}

class FileUploadLoading extends MaterialsState {
  final double progress;
  FileUploadLoading(this.progress);
}

class FileUploadSuccess extends MaterialsState {
  final dynamic response;
  FileUploadSuccess(this.response);
}

class FileUploadFailure extends MaterialsState {
  final String error;
  FileUploadFailure(this.error);
}

class DeleteMaterialLoading extends MaterialsState {}

class DeleteMaterialSuccess extends MaterialsState {}

class DeleteMaterialfiled extends MaterialsState {
  DeleteMaterialfiled();
}
