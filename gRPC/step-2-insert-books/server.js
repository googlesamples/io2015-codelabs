var grpc = require('grpc');

var booksProto = grpc.load('books.proto');

var BooksServer = grpc.buildServer([booksProto.books.BookService.service]);

// In-memory array of book objects
var books = [
  { id: 123, title: 'A Tale of Two Cities', author: 'Charles Dickens' }
];

var server = new BooksServer({
  'books.BookService': {
    list: function(call, callback) {
      callback(null, books);
    },
    insert: function(call, callback) {
      books.push(call.request);
      callback(null, {});
    }
  }
});

server.bind('127.0.0.1:50051');
server.listen();
