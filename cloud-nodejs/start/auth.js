module.exports = function(config) {

  function getAuthenticationUrl() {
    return "/oauth2callback";
  }

  function getUser(authorizationCode, callback) {
    var error = null;
    var fakeUser = { id: 123, name: 'Fake User' };
    callback(error, fakeUser);
  }

  return {
    getAuthenticationUrl: getAuthenticationUrl,
    getUser: getUser
  };
};
