var grpc = require('grpc');

var booksProto = grpc.load('books.proto');

var BooksServer = grpc.buildServer([booksProto.books.BookService.service]);

var bookStream;

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
      var book = call.request;
      books.push(book);
      if (bookStream)
        bookStream.write(book);
      callback(null, {});
    },
    get: function(call, callback) {
      for (var i = 0; i < books.length; i++)
        if (books[i].id == call.request.id)
          return callback(null, books[i]);
      callback({ code: grpc.status.NOT_FOUND, details: 'Not found' });
    },
    delete: function(call, callback) {
      for (var i = 0; i < books.length; i++) {
        if (books[i].id == call.request.id) {
          books.splice(i, 1);
          return callback(null, {});
        }
      }
      callback({ code: grpc.status.NOT_FOUND, details: 'Not found' });
    },
    watch: function(stream) {
      bookStream = stream;
    }
  }
});

server.bind('0.0.0.0:50051');
server.listen();
