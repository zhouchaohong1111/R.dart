


import 'dart:io';

import 'generator_utils.dart';

void main() async {
  runImageServer(preview_server_port);
}

void runImageServer(int port) async {
  var ser;
  try {
    ser = await HttpServer.bind('127.0.0.1', port);
    print('成功启动图片预览服务器于本机<$preview_server_port>端口');
    ser.listen(
          (req) {
        var index = req.uri.path.lastIndexOf('.');
        var subType = req.uri.path.substring(index);
        var contentType = new ContentType('image', subType);
        req.response
          ..headers.contentType = contentType
          ..add(new File('./${req.uri.path}').readAsBytesSync())
          ..close();
      },
    );
  } catch (e) {
    print('图片预览服务器已启动或端口被占用');
  }
}