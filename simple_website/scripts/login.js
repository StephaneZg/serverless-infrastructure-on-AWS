var Project = window.Project || {};

(function scopeWrapper($) {
  var poolData = {
    UserPoolId: _config.cognito.userPoolId,
    ClientId: _config.cognito.userPoolClientId,
  };

  var userPool;

  if (
    !(
      _config.cognito.userPoolId &&
      _config.cognito.userPoolClientId &&
      _config.cognito.region
    )
  ) {
    $("#noCognitoMessage").show();
    return;
  }

  userPool = new AmazonCognitoIdentity.CognitoUserPool(poolData);

  if (typeof AWSCognito !== "undefined") {
    AWSCognito.config.region = _config.cognito.region;
  }

  Project.authToken = new Promise(function fetchCurrentAuthToken(
    resolve,
    reject
  ) {
    var cognitoUser = userPool.getCurrentUser();
    var jwtToken = "";

    if (cognitoUser) {
      cognitoUser.getSession(function sessionCallback(err, session) {
        if (err) {
          reject(err);
        } else if (!session.isValid()) {
          resolve(null);
        } else {
          resolve(session.getIdToken().getJwtToken());
          jwtToken = session.getIdToken().getJwtToken();
          localStorage.setItem("jwtToken", jwtToken);
        }
      });
    } else {
      resolve(null);
    }
  });

  $(function onDocReady() {
    $('#signinForm').submit(handleSignin);
  });

  async function handleSignin(event) {
    event.preventDefault();
    console.log("In submitLoginForm");

    // Afficher le loader
    document.getElementById("loader").style.display = "flex";
    document.getElementById("messageErreur").style.display = "none";
    const button = document.getElementById("loginbutton");

    button.disabled = true;

    var email = document.getElementById("email").value;
    var password = document.getElementById("password").value;

    signin(
      email,
      password,
      function signinSuccess() {
        console.log("Successfully Logged In");
        document.getElementById("loader").style.display = "none";
        button.disabled = false;
        window.location.href = "main.html";
      },
      function signinError(err) {
        alert(err);
        document.getElementById("loader").style.display = "none";
        document.getElementById("messageErreur").style.display = "flex";
        button.disabled = false;
      }
    );
  }

  function signin(email, password, onSuccess, onFailure) {
    var authenticationDetails = new AmazonCognitoIdentity.AuthenticationDetails(
      {
        Username: toUsername(email),
        Password: password,
      }
    );

    var cognitoUser = createCognitoUser(email);
    cognitoUser.authenticateUser(authenticationDetails, {
      onSuccess: onSuccess,
      onFailure: onFailure,
    });
  }

  function createCognitoUser(email) {
    return new AmazonCognitoIdentity.CognitoUser({
      Username: toUsername(email),
      Pool: userPool,
    });
  }

  function toUsername(email) {
    return email;
  }
})(jQuery);
