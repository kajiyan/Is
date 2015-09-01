// ============================================================
// Socket Controller
module.exports = function(socket){

  console.log("Socket Controller");

  socket.on('connection', function (socket) {
    console.log('connection');

    room = 'testRoom' + Date.now();

    socket.join(room);
    console.log('コネクション数', socket.client.conn.server.clientsCount);

    // ソケット通信が切断された時
    socket.on('disconnect', function() {
      console.log('disconnected');
    });
  });
};