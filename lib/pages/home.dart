import 'dart:io';

import 'package:band_names/models/band.dart';
import 'package:band_names/services/socket_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [];

  @override
  void initState() {

    final socketService = Provider.of<SocketServices>(context, listen: false);

    socketService.socket.on('active-bands', _handleActiveBands);
    super.initState();
  }

  _handleActiveBands( dynamic payload ){
    this.bands = (payload as List)
        .map((band) => Band.fromMap(band))
        .toList();

    setState(() {

    });
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketServices>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final socketService = Provider.of<SocketServices>(context);

    return Scaffold(
        appBar: AppBar(
          elevation: 1,
          actions: [
            Container(
              margin: EdgeInsets.only(right: 10),
              child: (socketService.serverStatus == ServerStatus.Online)
                ? Icon(Icons.check_circle, color: Colors.blue[300],)
                  : Icon(Icons.offline_bolt, color: Colors.red,),
            )
          ],
          title: Text(
            'BandNames',
            style:
                TextStyle(color: Colors.black87),
          ),
            backgroundColor: Colors.white,
        ),

        body: Column(
          children: [
            _showGraph(),
            Expanded(
                child: ListView.builder(
                    itemCount: bands.length,
                    itemBuilder: (BuildContext context, int index) =>
                        _bandTile(bands[index])
                ),
            )
          ],
        ),

      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        elevation: 1,
        onPressed: addNewBand
      ),

    );
  }

  Widget _bandTile(Band band) {

    final socketService = Provider.of<SocketServices>(context, listen: false);

    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: ( DismissDirection direction ){
        socketService.emit('delete-band', {'id' : band.id});
      },
      background: Container(
        padding: EdgeInsets.only(left: 8.0),
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerLeft,
            child: Text('Delete Band', style: TextStyle(color: Colors.white),)
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name.substring(0, 2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name),
        trailing: Text(
          '${band.votes}',
          style: TextStyle(fontSize: 20),
        ),
        onTap: () {
          socketService.socket.emit('vote-band', {
            'id': band.id
          });
        },
      ),
    );
  }

  addNewBand(){

    final textController = new TextEditingController();

    if(Platform.isAndroid){

      return showDialog(
        context: context,
        builder: (context){
          return  AlertDialog(
            title: Text('New band name:'),
            content: TextField(
              controller: textController,
            ),
            actions: <Widget>[
              MaterialButton(
                  child: Text('Add'),
                  elevation: 5,
                  textColor: Colors.blue,
                  onPressed: () => addBandToList(textController.text))
            ],
          );
        },
      );
    }

    //Esto es para iOS
    showCupertinoDialog(
        context: context,
        builder: (_) {
          return CupertinoAlertDialog(
            title: Text('New band name:'),
            content: CupertinoTextField(
              controller: textController,
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                  child: Text('Add'),
                onPressed: () => addBandToList(textController.text),
              ),

              CupertinoDialogAction(
                isDestructiveAction: true,
                child: Text('Dismiss'),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        }
    );
  }


  void addBandToList(String name){
    if(name.length > 1){
      //Podemos agregar
      final socketService = Provider.of<SocketServices>(context, listen: false);
      socketService.emit('add-band', {'name' : name});
    }

    Navigator.pop(context);
  }

  //Mostrar gráfica
  Widget _showGraph(){

    Map<String, double> dataMap = new Map();

    bands.forEach((band) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });


    final List<Color> colorList = [
      Colors.blue,
      Colors.pink,
      Colors.yellow,
      Colors.greenAccent,
      Colors.indigo
    ];


    return dataMap.isNotEmpty ? Container(
      padding: EdgeInsets.only(top: 10),
      width: double.infinity,
      height: 200,
      child: PieChart(
        dataMap: dataMap,
        animationDuration: Duration(milliseconds: 800),
        colorList: colorList,
        initialAngleInDegree: 0,
        chartType: ChartType.disc,
        ringStrokeWidth: 32,
        centerText: "Bands",
        legendOptions: LegendOptions(
          showLegendsInRow: false,
          legendPosition: LegendPosition.right,
          showLegends: true,
          legendTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        chartValuesOptions: ChartValuesOptions(
          showChartValueBackground: true,
          showChartValues: true,
          showChartValuesInPercentage: false,
          showChartValuesOutside: false,
          decimalPlaces: 1,
        ),
      ),
    )
    :
    LinearProgressIndicator();
  }

}
