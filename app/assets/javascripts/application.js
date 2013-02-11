// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require_tree .
$(function() {
    // Create a new Faye client after the DOM is loaded.
    // To test this client, use the following on the command line:
    //  curl http://localhost:9292/faye -d 'message={ "channel":"/messages/new", "data":"hola" }'.
    var fayeClient = new Faye.Client('http://localhost:9292/faye');
    var subscription = fayeClient.subscribe("/messages/new", function(data) {
        alert(data.message === undefined ? data : data.message);
    });
    subscription.callback(function() {
        alert("Subscription active!");
    });

    subscription.errback(function(ex) {
        alert(ex.message);
    });

    $('#clientTest').on('click', function() {
        var publication = fayeClient.publish('/messages/new', { message : "This is a test from the button!", auth_token : "something" } );

        publication.callback(function() { alert("Message sent!"); });
        publication.errback(function(ex) { alert(ex.message); });
    });
});
