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
    var ctx = c.getContext("2d");

    var width = 300; //TODO Read this from the element? The options?
    var height = 50; 

    // outer box
    ctx.strokeStyle = "#000";
    ctx.lineWidth = 2;
    ctx.strokeRect(0, 0, width, height);

    // inner fill
    var budget = parseInt(this.element.data("budget"));
    var current = parseInt(this.element.data("current"));
    ctx.fillStyle = "#00F";
    ctx.fillRect(2, 2, (current / budget) * (width-2), (height-2));
    
    // pace line
    var daysAvailable = parseInt(this.element.data("days-available"));
    var daysPast = parseInt(this.element.data("days-past"));
    var paceX = (daysPast / daysAvailable) * (width-2);

    ctx.beginPath();
    ctx.moveTo(paceX, 2);
    ctx.lineTo(paceX, height-2);
    ctx.lineWidth = 4;
    ctx.strokeStyle = "#F99";
    ctx.stroke();
  }
});
