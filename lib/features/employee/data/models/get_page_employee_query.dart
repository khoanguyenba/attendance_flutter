class GetPageEmployeeQuery {
  final int pageIndex;
  final int pageSize;
  final String? code;
  final String? fullName;
  final String? email;
  final String? departmentId;

  GetPageEmployeeQuery({
    this.pageIndex = 1,
    this.pageSize = 20,
    this.code,
    this.fullName,
    this.email,
    this.departmentId,
  });

  Map<String, dynamic> toQueryParams() => {
    'pageIndex': pageIndex,
    'pageSize': pageSize,
    if (code != null) 'code': code,
    if (fullName != null) 'fullName': fullName,
    if (email != null) 'email': email,
    if (departmentId != null) 'departmentId': departmentId,
  };
}
