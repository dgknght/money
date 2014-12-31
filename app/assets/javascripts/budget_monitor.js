/*
 * A JQuery UI widget that accepts a container element, inserts a <canvas /> element
 * and draws a budget monitor progress bar
 *
 * --------------------------------------
 * |###########      |                  |
 * |###########      |                  |
 * --------------------------------------
 */
$.widget("dgknght.budget_monitor", {
  _create: function() {
    var c = document.createElement("canvas");
    this.element.append(c);
    c.width = 256;
    c.height = 32;
    var ctx = c.getContext("2d");
    var padding = 4;

    var width = c.width - (2 * padding);
    var height = c.height - (2 * padding);
    var lineWidth = 4;

    var budget = parseInt(this.element.data("budget"));
    var current = parseInt(this.element.data("current"));
    var percentOfBudgetSpent = current / budget;
    if (percentOfBudgetSpent > 1) percentOfBudgetSpent = 1;

    var daysAvailable = this._daysAvailable();
    var daysPast = this._daysPast();

    var percentOfTimePast = (daysPast / daysAvailable);
    var paceAmount = percentOfTimePast * budget;

    // inner fill
    ctx.fillStyle = paceAmount >= current ? this._safeFillColor() : this._dangerFillColor();
    ctx.fillRect(padding, padding, percentOfBudgetSpent * width, height);

    // outer box
    ctx.strokeStyle = "#000";
    ctx.lineWidth = 2;
    ctx.strokeRect(padding, padding, width, height);
    
    // pace line
    var paceX = (daysPast / daysAvailable) * width;

    ctx.beginPath();
    ctx.moveTo(paceX, 0);
    ctx.lineTo(paceX, c.height);
    ctx.lineWidth = lineWidth;
    ctx.strokeStyle = "#33F";
    ctx.stroke();
  },

  _daysAvailable: function() {
    if (this.options.daysAvailable)
      return parseInt(this.options.daysAvailable);

    var now = new Date();
    year = now.getFullYear();
    month = now.getMonth() + 1;
    return new Date(year, month, 0);
  },

  _daysPast: function() {
    if (this.options.daysPast)
      return parseInt(this.options.daysPast);
    return new Date().getDate();
  },

  _safeFillColor: function() {
    return this.options.safeFillColor || "#3F3";
  },

  _dangerFillColor: function() {
    return this.options.dangerFillColor || "#F33";
  }
});
