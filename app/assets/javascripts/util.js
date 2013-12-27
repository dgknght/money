window.util = {
  inspect: function(obj, message) {
    console.log("*** start inspection" + (message ? (": " + message) : "") + " ***");
    if (obj) {
      for (var key in obj) {
        console.log(key + "=" + obj[key]);
      }
    }
    console.log("*** end inspection ***");
  }
};
