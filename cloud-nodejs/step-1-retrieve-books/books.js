var url = require('url');

module.exports = function(config) {

  var gcloud = require('gcloud');

  var dataset = gcloud.datastore.dataset({
    projectId: config.projectId,
    keyFilename: config.keyFilename
  });

  function getAllBooks(callback) {
    var query = dataset.createQuery(['Book']);
    dataset.runQuery(query, callback);
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
