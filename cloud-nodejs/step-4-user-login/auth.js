module.exports = function(config) {

  var googleapis = require('googleapis');

  function getAuthenticationUrl() {
    var client = new googleapis.auth.OAuth2(
      config.oauth2.clientId,
      config.oauth2.clientSecret,
      config.oauth2.redirectUrl
    );
    // Use 'profile' scope to authorize fetching the user's profile
    return client.generateAuthUrl({ scope: ['profile'] });
  }

  function getUser(authorizationCode, callback) {
    var client = new googleapis.auth.OAuth2(
      config.oauth2.clientId,
      config.oauth2.clientSecret,
      config.oauth2.redirectUrl
    );
    // With the code returned from OAuth flow, get an access token
    client.getToken(authorizationCode, function(err, tokens) {
      if (err) return callback(err);
      // Configure this Google API client to use the access token
      client.setCredentials(tokens);
      // Call the Google+ API to get the profile of the user who authenticated
      googleapis.plus('v1').people.get({ userId: 'me', auth: client }, function(err, profile) {
        if (err) return callback(err);
        var user = {
          id: profile.id,
          name: profile.displayName,
          imageUrl: profile.image.url
        };
        callback(null, user);
      });
    });
  }

  return {
    getAuthenticationUrl: getAuthenticationUrl,
    getUser: getUser
  };
};
