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
    $('#registrationForm').submit(handleRegister);
  });

  async function handleRegister(event) {
    event.preventDefault();
    console.log("In submitregisterform");

    // Afficher le loader
    document.getElementById("loader").style.display = "flex";
    document.getElementById("messageErreur").style.display = "none";
    document.getElementById("messageSuccess").style.display = "none";
    const button = document.getElementById("registerbutton");
    const formulaire = document.getElementById("registerform");

    button.disabled = true;

    var username = document.getElementById("username").value;
    var password = document.getElementById("password").value;
    var email = document.getElementById("email").value;

    var onSuccess = function registerSuccess(result) {
      var cognitoUser = result.user;
      console.log("user name is " + cognitoUser.getUsername());
      var confirmation =
        "Registration successful. Please check your email inbox or spam folder for your verification code.";
      if (confirmation) {
        email_encode = encodeURIComponent(email);
        window.location.href = `verify-code.html?data=${email_encode}`;
      }

      document.getElementById("loader").style.display = "none";
      document.getElementById("messageSuccess").style.display = "flex";
      //formulaire.reset();
      button.disabled = false;
    };
    var onFailure = function registerFailure(err) {
      alert(err);
      document.getElementById("loader").style.display = "none";
      document.getElementById("messageErreur").style.display = "flex";
      button.disabled = false;
    };

    register(email, password, onSuccess, onFailure);
  }

  function register(email, password, onSuccess, onFailure) {
    var dataEmail = {
      Name: "email",
      Value: email,
    };
    var attributeEmail = new AmazonCognitoIdentity.CognitoUserAttribute(
      dataEmail
    );

    userPool.signUp(
      toUsername(email),
      password,
      [attributeEmail],
      null,
      function signUpCallback(err, result) {
        if (!err) {
          onSuccess(result);
        } else {
          onFailure(err);
        }
      }
    );
  }

  function toUsername(email) {
    return email;
  }
})(jQuery);
