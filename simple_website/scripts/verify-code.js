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
    $('#verifyForm').submit(handleVerify);
  });

  async function handleVerify(event) {
    // Afficher le loader
    document.getElementById("loader").style.display = "flex";
    document.getElementById("messageErreur").style.display = "none";
    const button = document.getElementById("verifybutton");

    button.disabled = true;

    var email = getQueryParameter("data");
    var code = document.getElementById("otp-code").value;

    verify(
      email,
      code,
      function verifySuccess(result) {
        console.log("call result: " + result);
        console.log("Successfully verified");
        alert(
          "Verification successful. You will now be redirected to the login page."
        );
        window.location.href = "index.html";
      },
      function verifyError(err) {
        alert(err);
      }
    );
  }

  function verify(email, code, onSuccess, onFailure) {
    createCognitoUser(email).confirmRegistration(
      code,
      true,
      function confirmCallback(err, result) {
        if (!err) {
          onSuccess(result);
        } else {
          onFailure(err);
        }
      }
    );
  }

  function getQueryParameter(name) {
    const urlParams = new URLSearchParams(window.location.search);
    return urlParams.get(name);
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
