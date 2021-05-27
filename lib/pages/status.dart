import 'package:band_names/services/socket_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatusPage extends StatelessWidget{

  @override
  Widget build(BuildContext context) {

    final socketService = Provider.of<SocketServices>(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('ServerStatus: ${ socketService.serverStatus}')
          ],
        )
      ),

      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.message),
        onPressed: (){
          print("Lanzando emision");
          socketService.emit('emitir-mensaje', {
            'nombre' : 'Flutter',
            'mensaje': 'Hola desde Flutter'
          });
        },
      ),
    );
  }

}