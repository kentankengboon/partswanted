
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_chart_json/chartmap.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'chartmap.dart';


class Chart extends StatefulWidget {

  //final theSupplier;
  //Chart({this.theYear, this.theRev, this.theColor});

  //@override
  //_ChartState createState() => _ChartState(year:theYear, rev:theRev, color:theColor);
  _ChartState createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  //String groupId;
  //String userName;
  //String userEmail;
  //final year;
  //final int rev;
  //String color;


  //_ChartState({this.year, this.rev, this.color});
  List<charts.Series<ChartMap, String>> _seriesBarData = [];
  List <ChartMap> myData = [];
  _generateData (myData) {
    _seriesBarData.add(charts.Series(
      domainFn: (ChartMap chartValue, _) => chartValue.chartDate.toString(),
      measureFn: (ChartMap chartValue, _) => chartValue.chartQty,
      colorFn: (ChartMap chartValue, _) => charts.ColorUtil.fromDartColor(Color(int.parse(chartValue.chartColor))),
      id: 'ChartMap',
      data: myData,
        labelAccessorFn: (ChartMap row, _) => "${row.chartDate}"
    ));
  }

  Widget build(BuildContext context){
    return Scaffold(appBar: AppBar(title: Text('Chart Value'),),
    body: _buildBody (context),);
  }

  Widget _buildBody (context){
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection ('charts').document('toQuote').collection('toQuote').snapshots(),
      builder: (context,snapshot){
        if(!snapshot.hasData){
          //print("here no");
          return LinearProgressIndicator();
      }
        else{
          //print("here yes ");
          List<ChartMap> chartValue = snapshot.data.documents.map((documentSnapshot) => ChartMap.fromMap(documentSnapshot.data())).toList();
          //print (chartValue);
          return _buildChart(context, chartValue);
        }
      }
    );
  }

  Widget _buildChart (BuildContext context, List<ChartMap> chartValue){
    myData = chartValue;
    _generateData(myData);
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Container(
        child: Center(
          child: Column(
            children: <Widget>[
              Text('Pending',
              style: TextStyle(fontSize:24.0, fontWeight: FontWeight.bold),),
              SizedBox(height: 10.0),

              Expanded(
                child: charts.BarChart(_seriesBarData,
                  animate: true,
                  animationDuration: Duration(milliseconds: 200),
                  //behaviors: [charts.DatumLegend(entryTextStyle: charts.TextStyleSpec(
                  //      color: charts.MaterialPalette.purple.shadeDefault,
                  //      fontFamily: 'Georgia',
                  //      fontSize: 18),)]
                )
              ),
            ]
          )
        )
      )

    );

  }




}


