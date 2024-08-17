var Project = window.Project || {};

(function scopeWrapper($) {
  const baseUrl = "https://h68lwenui5.execute-api.us-east-1.amazonaws.com/v1/products";

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

  function signOut() {
    var currentUser = userPool.getCurrentUser();
    if (currentUser != null) {
      currentUser.signOut();
      window.location.href = 'index.html';
    } else {
      console.log('No user is currently signed in.');
    }
  };

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

  // Initialize data table
  let tableData = [];
  const columns = [
    {
      data: 'product-id',
      title: 'Product ID'
    },
    {
      data: 'name',
      title: 'Name'
    },
    {
      data: 'color',
      title: 'Color'
    },
    {
      data: 'price',
      title: 'Price'
    }
  ];
  const options = {
    data: tableData,
    columns: columns
  };

  let table = new DataTable('#productTable', options);

  $(function onDocReady() {
    handleSession
    document
      .getElementById("signOutButton")
      .addEventListener("click", handleSignOut);
    document
      .getElementById("callApiButton")
      .addEventListener("click", callApi);
    document
      .getElementById("save__btn")
      .addEventListener("click", handleProductSave);

  });

  function handleSignOut(event) {
    event.preventDefault();

    signOut()

    //print the local storage token
    var token = localStorage.getItem("jwtToken");

  }

  async function callApi(event) {
    event.preventDefault();
    Project.authToken
      .then(function (jwtToken) {
        if (jwtToken) {

          const jwtToken = localStorage.getItem("jwtToken");
          const decoded = jwt_decode(jwtToken);

          // Define the query parameters as an object
          const queryParams = {
            email: decoded.email
          };
          const queryString = new URLSearchParams(queryParams).toString();

          document.getElementById("loader").style.display = "flex";
          const button = document.getElementById("callApiButton");
          button.disabled = true;

          // Make API request with the JWT token
          fetch(
            `${baseUrl + "-by-email"}?${queryString}`,
            {
              method: "POST",
              headers: {
                "Content-Type": "application/json",
                Authorization: jwtToken,
              },
            }
          )
            .then((response) => {
              if (!response.ok) {
                throw new Error("Network response was not ok");
              }
              return response.json();
            })
            .then((data) => {
              console.log(data);
              document.getElementById("loader").style.display = "none";
              const button = document.getElementById("callApiButton");
              button.disabled = false;

              table.clear();
              table.rows.add(data);
              table.draw();
            })
            .catch((error) => {
              document.getElementById("loader").style.display = "none";
              const button = document.getElementById("callApiButton");
              button.disabled = false;

              console.error(
                "There has been a problem with your fetch operation:",
                error
              );
            });
        } else {
          console.log("No valid JWT token found");
          // Handle the absence of a valid token (e.g., redirect to login)
        }
      })
      .catch((error) => {
        console.error("Error getting the JWT token:", error);
      });
  }

  function handleSession(event) {

    const userPool = new AmazonCognitoIdentity.CognitoUserPool({
      UserPoolId: _config.cognito.userPoolId,
      ClientId: _config.cognito.userPoolClientId,
    });

    const cognitoUser = userPool.getCurrentUser();

    if (cognitoUser != null) {
      cognitoUser.getSession(function (err, session) {
        if (err) {
          console.error(err);
          return;
        }

        // Session is valid
        cognitoUser.getUserAttributes(function (err, attributes) {
          if (err) {
            console.error(err);
            return;
          }

          const emailAttribute = attributes.find(
            (attribute) => attribute.getName() === "email"
          );
          if (emailAttribute) {
            document.getElementById("userEmailDisplay").innerText =
              emailAttribute.getValue();
          }
        });
      });
    } else {
      console.log("No user logged in.");
    }
  }

  async function handleProductSave(event) {
    event.preventDefault();
    document
      .getElementById("productForm");

    document.getElementById("loader").style.display = "flex";
    document.getElementById("messageErreur").style.display = "none";
    document.getElementById("messageSuccess").style.display = "none";
    const button = document.getElementById("save__btn");
    button.disabled = true;

    const jwtToken = localStorage.getItem("jwtToken");
    const decoded = jwt_decode(jwtToken);

    const formData = {
      email: decoded.email,
      name: document.getElementById("product-name").value,
      color: document.getElementById("product-color").value,
      price: document.getElementById("product-price").value,
    };

    // Send a POST request to your API endpoint
    fetch(
      baseUrl,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer " + jwtToken,
        },
        body: JSON.stringify(formData),
      }
    )
      .then((response) => response.json())
      .then((data) => {
        console.log("Success:", data);

        document.getElementById("loader").style.display = "none";
        document.getElementById("messageErreur").style.display = "none";
        document.getElementById("messageSuccess").style.display = "flex";
        const button = document.getElementById("save__btn");
        button.disabled = false;

        // Clear the form fields 2 seconds after submission
        setTimeout(() => {
          document.getElementById("product-name").value = "";
          document.getElementById("product-color").value = "";
          document.getElementById("product-price").value = "";
          document.getElementById("messageSuccess").style.display = "none";

        }, 3000); // 2000 milliseconds = 2 seconds
      })
      .catch((error) => {
        console.error("Error:", error);

        document.getElementById("loader").style.display = "none";
        document.getElementById("messageErreur").style.display = "flex";
        const button = document.getElementById("save__btn");
        button.disabled = false;

      });
  }

})(jQuery);


