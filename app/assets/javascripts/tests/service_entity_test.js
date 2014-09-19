(function() {

module('ServiceEntity');
test("errorMessages", function() {
  function ViewModel(id) {
    this.id = id;
    this.name = ko.observable().extend({
      propertyName: 'name',
      required: "Name is required."
    });
    this.children = ko.observableArray().extend({
      propertyName: 'children'
    });
    this.validatedProperties = function() {
      return [ this.name, this.children ];
    };
  }
  ViewModel.prototype = new ServiceEntity();

  var viewModel = new ViewModel('first');
  viewModel.children.push(new ViewModel('second'));
  viewModel.validate(); // The properties won't have error messages until validation has been called

  deepEqual(viewModel.errorMessages(), ["name: Name is required.", "children - name: Name is required."], "The errorMessage property should list each property that is in error.");
});

})();
