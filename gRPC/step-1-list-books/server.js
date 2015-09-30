var grpc = require('grpc');

var booksProto = grpc.load('books.proto');

// In-memory array of book objects
var books = [
  { id: 123, title: 'A Tale of Two Cities', author: 'Charles Dickens' }
];

var server = new grpc.Server();
  server.addProtoService(booksProto.books.BookService.service,
  {
    list: function(call, callback) {
      callback(null, books);
    }
  });

server.bind('127.0.0.1:50051', grpc.ServerCredentials.createInsecure());
server.start();
