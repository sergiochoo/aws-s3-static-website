// GET API REQUEST
async function get_visitors() {
    try {
      let response = await fetch(
        "https://11q3uvuks7.execute-api.us-east-1.amazonaws.com/default/terraform_lambda_func", // API Gateway URL
        {
          method: "GET",
        }
      );
      let data = await response.json();
      document.getElementById("visitors").innerHTML = data?.count;
    } catch (err) {
      console.error(err);
    }
  }

  get_visitors();
