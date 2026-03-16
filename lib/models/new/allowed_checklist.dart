class AllowedChecklist {
  final int id;
  final String checklistName;
  final String documentType;
  final String description;
  final String type;
  final int typeId;
  final String typeName;
  final bool isMandatory;
  final String? dueDate;
  final String? dueTime;

  final bool isUpload;
  final String fileName;
  final String fileUrl;
  final int docStatus;
  final String docStatusText;
  final int uploadedDocId;
  final String uploadDocDate;

  AllowedChecklist({
    required this.id,
    required this.checklistName,
    required this.documentType,
    required this.description,
    required this.type,
    required this.typeId,
    required this.typeName,
    required this.isMandatory,
    this.dueDate,
    this.dueTime,
    required this.isUpload,
    required this.fileName,
    required this.fileUrl,
    required this.docStatus,
    required this.docStatusText,
    required this.uploadedDocId,
    required this.uploadDocDate,
  });

  factory AllowedChecklist.fromJson(Map<String, dynamic> json) {
    return AllowedChecklist(
      id: json['id'] ?? 0,
      checklistName: json['checklist_name'] ?? '',
      documentType: json['document_type'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      typeId: json['type_id'] ?? 0,
      typeName: json['type_name'] ?? '',
      isMandatory: json['is_mandatory'] ?? false,
      dueDate: json['due_date'],
      dueTime: json['due_time'],
      isUpload: json['is_upload'] ?? false,
      fileName: json['file_name'] ?? '',
      fileUrl: json['file_url'] ?? '',
      docStatus: json['doc_status'] ?? 0,
      docStatusText: json['doc_status_text'] ?? '',
      uploadedDocId: json['uploaded_doc_id'] ?? 0,
      uploadDocDate: json['upload_doc_date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "checklist_name": checklistName,
      "document_type": documentType,
      "description": description,
      "type": type,
      "type_id": typeId,
      "type_name": typeName,
      "is_mandatory": isMandatory,
      "due_date": dueDate,
      "due_time": dueTime,
      "is_upload": isUpload,
      "file_name": fileName,
      "file_url": fileUrl,
      "doc_status": docStatus,
      "doc_status_text": docStatusText,
      "uploaded_doc_id": uploadedDocId,
      "upload_doc_date": uploadDocDate,
    };
  }
}