# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(() ->
  $("#distributor_method").on("change", () ->
    showSelectedMethod();
  );
  showSelectedMethod();
);

showSelectedMethod = () ->
  $("#distributor_method option").each(() ->
    showMethod(this.value, this.selected)
  );

showMethod = (method, visible) ->
  console.log("showMethod " + method + ", " + visible)
  if (visible)
    $("div.method_" + method).show()
  else
    $("div.method_" + method).hide()
