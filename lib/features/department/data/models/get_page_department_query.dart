class GetPageDepartmentQuery {
  final int pageIndex;
  final int pageSize;
  final String? code;
  final String? name;

  GetPageDepartmentQuery({
    this.pageIndex = 1,
    this.pageSize = 20,
    this.code,
    this.name,
  });

  Map<String, dynamic> toQueryParams() => {
    'pageIndex': pageIndex,
    'pageSize': pageSize,
    if (code != null) 'code': code,
    if (name != null) 'name': name,
  };
}
