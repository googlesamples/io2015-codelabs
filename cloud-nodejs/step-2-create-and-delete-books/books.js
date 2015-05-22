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
      return callback(new Error("books.addBook image saving Not Yet Implemented"));

    var entity = {
      key: dataset.key('Book'),
      data: {
        title: title,
        author: author
      }
    };

    dataset.save(entity, callback);
  }

  function deleteBook(bookId, callback) {
    var key = dataset.key(['Book', bookId]);
    dataset.delete(key, callback);
  }

  return {
    getAllBooks: getAllBooks,
    getUserBooks: getUserBooks,
    addBook: addBook,
    deleteBook: deleteBook
  };
};
