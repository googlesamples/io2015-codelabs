var url = require('url');

module.exports = function(config) {

  function getAllBooks(callback) {
    var error = null;
    var books = [
      {
        key: { path: ['Book', 12345] },
        data: { title: 'Fake Book', author: 'Fake Author' }
      }
    ];
    callback(error, books);
  }

  function getUserBooks(userId, callback) {
    callback(new Error('books.getUserBooks [Not Yet Implemented]'));
  }

  function addBook(title, author, coverImageData, userId, callback) {
    if (coverImageData)
      return callback(new Error('books.addBook with image [Not Yet Implemented]'));

    return callback(new Error('books.addBook [Not Yet Implemented]'));
  }

  function deleteBook(bookId, callback) {
    callback(new Error('books.deleteBook [Not Yet Implemented]'));
  }

  return {
    getAllBooks: getAllBooks,
    getUserBooks: getUserBooks,
    addBook: addBook,
    deleteBook: deleteBook
  };
};
