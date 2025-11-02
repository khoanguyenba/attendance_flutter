class GetPageWorkTimeQuery {
  final int pageIndex;
  final int pageSize;
  final String? name;
  final bool? isActive;

  GetPageWorkTimeQuery({
    this.pageIndex = 1,
    this.pageSize = 20,
    this.name,
    this.isActive,
  });

  Map<String, dynamic> toQueryParams() {
    final map = <String, dynamic>{'pageIndex': pageIndex, 'pageSize': pageSize};
    if (name != null) map['name'] = name;
    if (isActive != null) map['isActive'] = isActive;
    return map;
  }
}
