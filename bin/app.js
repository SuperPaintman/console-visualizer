
/*
-------------------------
Console Visualizer
-------------------------
 */

/**
 * The maximum characters length in the console
 * @constant
 * @type {Number}
 * @default
 */
var CONSOLE_MAX_CHARS, TEXT_PERCENT_S_LENGTH, TEXT_PERCENT_WO_FLOOR, TEXT_PERCENT_W_FLOOR, Visual;

CONSOLE_MAX_CHARS = 80;


/**
 * The reserved characters length in the console. For ' ' and '%'
 * @constant
 * @type {Number}
 * @default
 */

TEXT_PERCENT_S_LENGTH = 3;


/**
 * The percent characters length in the console. For '0 - 100'
 * @constant
 * @type {Number}
 * @default
 */

TEXT_PERCENT_W_FLOOR = 3;


/**
 * The percent characters (without flooring) length in the console. For '1.2345678901234567'
 * @constant
 * @type {Number}
 * @default
 */

TEXT_PERCENT_WO_FLOOR = 18;


/**
 * @class Visual
 */

Visual = (function() {

  /**
   * @memberof Visual
   * 
   * @param  {Object}             [opts]
   *
   * @param  {Object}             [opts.progress] - Progress bar
   * @param  {Integer}            [opts.progress.max_chars=CONSOLE_MAX_CHARS]
   * @param  {Boolean|Char}       [opts.progress.arrow=false]
   * 
   * @param  {Object}             [opts.progress.text]
   * @param  {Boolean}            [opts.progress.text.draw=true]
   * @param  {Boolean}            [opts.progress.text.floor=true]
   * 
   * @param  {Object}             [opts.progress.braces]
   * @param  {Boolean|Char}       [opts.progress.braces.open="["]
   * @param  {Boolean|Char}       [opts.progress.braces.close="]"]
   * 
   * @param  {Object}             [opts.progress.scale]
   * @param  {Char}               [opts.progress.scale.fill="="]
   * @param  {Boolean|Char}       [opts.progress.scale.half="-"]
   * @param  {Char}               [opts.progress.scale.empty=" "]
   */
  function Visual(opts) {
    this._changeOpts(opts);
  }

  Visual.prototype._changeOpts = function(opts) {
    var ref, ref1, ref10, ref11, ref12, ref13, ref14, ref15, ref16, ref17, ref18, ref19, ref2, ref20, ref21, ref22, ref23, ref24, ref3, ref4, ref5, ref6, ref7, ref8, ref9;
    this.options = {
      progress: {
        max_chars: (ref = opts != null ? (ref1 = opts.progress) != null ? ref1.max_chars : void 0 : void 0) != null ? ref : CONSOLE_MAX_CHARS,
        arrow: (ref2 = opts != null ? (ref3 = opts.progress) != null ? ref3.arrow : void 0 : void 0) != null ? ref2 : false,
        text: {
          draw: (ref4 = opts != null ? (ref5 = opts.progress) != null ? (ref6 = ref5.text) != null ? ref6.draw : void 0 : void 0 : void 0) != null ? ref4 : true,
          floor: (ref7 = opts != null ? (ref8 = opts.progress) != null ? (ref9 = ref8.text) != null ? ref9.floor : void 0 : void 0 : void 0) != null ? ref7 : true
        },
        braces: {
          open: (ref10 = opts != null ? (ref11 = opts.progress) != null ? (ref12 = ref11.braces) != null ? ref12.open : void 0 : void 0 : void 0) != null ? ref10 : "[",
          close: (ref13 = opts != null ? (ref14 = opts.progress) != null ? (ref15 = ref14.braces) != null ? ref15.close : void 0 : void 0 : void 0) != null ? ref13 : "]"
        },
        scale: {
          fill: (ref16 = opts != null ? (ref17 = opts.progress) != null ? (ref18 = ref17.scale) != null ? ref18.fill : void 0 : void 0 : void 0) != null ? ref16 : "=",
          half: (ref19 = opts != null ? (ref20 = opts.progress) != null ? (ref21 = ref20.scale) != null ? ref21.half : void 0 : void 0 : void 0) != null ? ref19 : "-",
          empty: (ref22 = opts != null ? (ref23 = opts.progress) != null ? (ref24 = ref23.scale) != null ? ref24.empty : void 0 : void 0 : void 0) != null ? ref22 : " "
        }
      }
    };
    this.options.progress.STEPS = this.options.progress.max_chars;
    if (this.options.progress.text.draw) {
      if (this.options.progress.text.floor) {
        this.options.progress.STEPS -= TEXT_PERCENT_S_LENGTH + TEXT_PERCENT_W_FLOOR;
      } else {
        this.options.progress.STEPS -= TEXT_PERCENT_S_LENGTH + TEXT_PERCENT_WO_FLOOR;
      }
      if (this.options.progress.braces.open) {
        this.options.progress.STEPS--;
      }
      if (this.options.progress.braces.close) {
        this.options.progress.STEPS--;
      }
      if (this.options.progress.arrow) {
        this.options.progress.STEPS--;
      }
      if (this.options.progress.scale.half) {
        return this.options.progress.STEPS--;
      }
    }
  };


  /**
   * Clear console
   * @memberof Visual
   * @todo test it in *nix* OS
   */

  Visual.prototype.clear = function() {
    return process.stdout.write('\u001B[2J\u001B[0;0f');
  };


  /**
   * Generate progress bar
   * @memberof Visual
   * 
   * @param  {Integer} min    - start of range
   * @param  {Integer} cur    - current value
   * @param  {Integer} max    - end of range
   * @return {String}         progress bar like this "[=====.....] 50%"
   */

  Visual.prototype.getProgress = function(min, cur, max) {
    var i, j, k, percent, ref, ref1, ref2, s, scale, steps;
    percent = cur / (max - min);
    if (percent > 1) {
      percent = 1;
    } else if (percent < 0) {
      percent = 0;
    }
    scale = "";
    if (this.options.progress.braces.open) {
      scale += this.options.progress.braces.open;
    }
    steps = this.options.progress.STEPS;
    s = Math.round(steps * percent);
    for (i = j = 0, ref = s; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
      scale += this.options.progress.scale.fill;
    }
    if (this.options.progress.scale.half && (percent * 100 % 1) > 0.5) {
      scale += this.options.progress.scale.half;
    } else {
      scale += this.options.progress.scale.fill;
    }
    if (this.options.progress.arrow) {
      scale += this.options.progress.arrow;
    }
    for (i = k = ref1 = s, ref2 = steps; ref1 <= ref2 ? k < ref2 : k > ref2; i = ref1 <= ref2 ? ++k : --k) {
      scale += this.options.progress.scale.empty;
    }
    if (this.options.progress.braces.close) {
      scale += this.options.progress.braces.close;
    }
    if (this.options.progress.text.draw) {
      if (this.options.progress.text.floor) {
        scale += " " + (Math.floor(percent * 100 / 1)) + "%";
      } else {
        scale += " " + (percent * 100) + "%";
      }
    }
    return scale;
  };


  /**
   * Draw progress bar in console
   * @memberof Visual
   * 
   * @param  {Integer} min    - start of range
   * @param  {Integer} cur    - current value
   * @param  {Integer} max    - end of range
   *
   * @see    {@link getProgress}
   */

  Visual.prototype.drawProgress = function(min, cur, max) {
    return console.log(this.getProgress(min, cur, max));
  };

  Visual.prototype.$getCat = function(frame) {
    switch (frame) {
      case 0:
        return "    \/\\___\/\\\n   \/`     '\\\n === 0 . 0 ===\n   \\  -^-  \/\n  \/         \\\n \/           \\\n|             |\n \\  ||   ||  \/   \n  \\_oo___oo_\/#######o";
      case 1:
        return "    \/\\___\/\\\n   \/`     '\\\n ==~ 0 . 0 ~==\n   \\  -^-  \/\n  \/         \\\n \/           \\\n|             |\n \\  ||   ||  \/## \n  \\_oo___oo_\/#  ####o";
      case 2:
        return "    \/\\___\/\\\n   \/`     '\\\n =~= 0 . 0 =~=\n   \\  -^-  \/\n  \/         \\\n \/           \\\n|             |\n \\  ||   ||  \/  ## \n  \\_oo___oo_\/###  ##o";
      case 3:
        return "    \/\\___\/\\\n   \/`     \"\\\n ~== 0 . 0 ==~\n   \\  -^-  \/\n  \/         \\\n \/           \\\n|             |\n \\  ||   ||  \/    ##\n  \\_oo___oo_\/#####  o";
      case 4:
        return "    \/\\___\/\\\n   \/`     '\\\n === 0 . 0 ===\n   \\  -^-  \/\n  \/         \\\n \/           \\\n|             |\n \\  ||   ||  \/      o\n  \\_oo___oo_\/#######";
    }
  };

  Visual.prototype.$drawCat = function(frame) {
    return console.log(this.$getCat(frame));
  };

  return Visual;

})();


/*
Exports
 */

module.exports = Visual;
