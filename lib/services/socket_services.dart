import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';

enum ServerStatus{
  Online,
  Offline,
  Connecting
}

class SocketServices with ChangeNotifier{

  ServerStatus _serverStatus = ServerStatus.Connecting;
  late IO.Socket _socket;

  ServerStatus get serverStatus => this._serverStatus;

  IO.Socket get socket => this._socket;
  Function get emit => this._socket.emit;

  SocketServices(){
    this._initConfig();
  }

  void _initConfig(){
    // Dart client
    this._socket = IO.io('http://192.168.1.14:3000/',{
      'transports':['websocket'],
      'autoConnect': true
    });

    this._socket.onConnect((_) {
      print('connect');
      this._serverStatus = ServerStatus.Online;
      //Notificamos al resto de la aplicadion mediante el change notifier
      notifyListeners();
    });

    this._socket.onDisconnect((_) {
      this._serverStatus = ServerStatus.Offline;
      notifyListeners();
    });
/*
    socket.on('nuevo-mensaje', (payload)  {
      print('nuevo-menssaje:');
      print('nombre:' + payload['nombre']);
      print('mensaje:' + payload['mensaje']);
    });
    */
  }

}