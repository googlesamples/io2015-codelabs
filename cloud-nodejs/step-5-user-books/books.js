var url = require('url');

module.exports = function(config) {

  var gcloud = require('gcloud');

  var dataset = gcloud.datastore.dataset({
    projectId: config.projectId,
    keyFilename: config.keyFilename
  });

  var storage = gcloud.storage({
    projectId: config.projectId,
    keyFilename: config.keyFilename
  });

  var bucket = storage.bucket(config.bucketName);

  function getAllBooks(callback) {
    var query = dataset.createQuery(['Book']);
    dataset.runQuery(query, callback);
  }

  function getUserBooks(userId, callback) {
    var query = dataset.createQuery(['Book']).filter('userId =', userId);
    dataset.runQuery(query, callback);
  }

  function addBook(title, author, coverImageData, userId, callback) {
    var entity = {
      key: dataset.key('Book'),
      data: {
        title: title,
        author: author,
      }
    };

    if (userId)
      entity.data.userId = userId;

    if (coverImageData)
      uploadCoverImage(coverImageData, function(err, imageUrl) {
        if (err) return callback(err);
        entity.data.imageUrl = imageUrl;
        dataset.save(entity, callback);
      });
    else
      dataset.save(entity, callback);
  }

  function deleteBook(bookId, callback) {
    var key = dataset.key(['Book', bookId]);

    dataset.get(key, function(err, book) {
      if (err) return callback(err);

      if (book.data.imageUrl) {
        var filename = url.parse(book.data.imageUrl).path.replace('/', '')
        var file = bucket.file(filename);
        file.delete(function(err) {
          if (err) return callback(err);
          dataset.delete(key, callback);
        });
      } else {
        dataset.delete(key, callback);
      }
    });
  }

  function uploadCoverImage(coverImageData, callback) {
    // Generate a unique filename for this image
    var filename = '' + new Date().getTime() + "-" + Math.random()
    var file = bucket.file(filename);
    var imageUrl = 'https://' + config.bucketName + '.storage.googleapis.com/' + filename;
    var stream = file.createWriteStream();
    stream.on('error', callback);
    stream.on('complete', function() {
      // Set this file to be publicly readable
      file.makePublic(function(err) {
        if (err) return callback(err);
        callback(null, imageUrl);
      });
    });
    stream.end(coverImageData);
  }

  return {
    getAllBooks: getAllBooks,
    getUserBooks: getUserBooks,
    addBook: addBook,
    deleteBook: deleteBook
  };
};
