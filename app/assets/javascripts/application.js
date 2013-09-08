// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require turbolinks
//= require_tree .

url = 'https://www.weloveapis.com/push'
websitePushID = 'web.com.example.app'
userInfo = {}

var checkRemotePermission = function (permissionData) {
    if (permissionData.permission === 'default') {
        // This is a new web service URL and its validity is unknown.
        window.safari.pushNotification.requestPermission(
            url, // The web service URL.
            websitePushID,     // The Website Push ID.
            {user: "1"}, // Data that you choose to send to your server to help you identify the user.
            checkRemotePermission         // The callback function.
        );
    }
    else if (permissionData.permission === 'denied') {
      console.log('permission denied', permissionData) ;
        // The user said no.
    }
    else if (permissionData.permission === 'granted') {
      console.log('permission granted', permissionData) ;
    }
};

var notify = function() {
  var permissionData = window.safari.pushNotification.permission(websitePushID);
  checkRemotePermission(permissionData);
}
