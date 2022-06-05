class ChartMap{
  var chartDate;
  final int chartQty;
  final String chartColor;

  ChartMap(this.chartDate, this.chartQty, this.chartColor);

  ChartMap.fromMap(Map<String,dynamic> map):
        assert(map['date']!=null),
        assert(map['qty']!=null),
        assert(map['color']!=null),
        chartDate = map['date'],
        chartQty = map['qty'],
        chartColor = map['color'];

  @override
  String toString() => "Record<$chartDate:$chartQty:$chartColor>";

}