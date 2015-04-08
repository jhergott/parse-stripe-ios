Parse.Cloud.define("ChargeWithCard", function(request, response){
    var Stripe = require('stripe');
    Stripe.initialize('sk_test_bCy6U66tLzEShk2IWrXdHyT3');
                   
    Stripe.Charges.create({
        amount: 100 * request.params.price, // expressed in cents
        currency: "usd",
        source: request.params.token,
    },{
        success: function(httpResponse) {
            response.success(httpResponse);
        },
        error: function(httpResponse) {
            response.error(httpResponse);
        }
    });
});