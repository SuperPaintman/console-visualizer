###
-------------------------
Console Visualizer
-------------------------
###

# Constants
###*
 * The maximum characters length in the console
 * @constant
 * @type {Number}
 * @default
###
CONSOLE_MAX_CHARS = 80
###*
 * The reserved characters length in the console. For ' ' and '%'
 * @constant
 * @type {Number}
 * @default
###
TEXT_PERCENT_S_LENGTH = 3
###*
 * The percent characters length in the console. For '0 - 100'
 * @constant
 * @type {Number}
 * @default
###
TEXT_PERCENT_W_FLOOR = 3
###*
 * The percent characters (without flooring) length in the console. For '1.2345678901234567'
 * @constant
 * @type {Number}
 * @default
###
TEXT_PERCENT_WO_FLOOR = 18

###*
 * @class Visual
###
class Visual
    ###*
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
    ###
    constructor: (opts)->
        @._changeOpts opts

    _changeOpts: (opts)->
        # Общие настройки
        @options =
            progress:
                max_chars:      opts?.progress?.max_chars       ? CONSOLE_MAX_CHARS
                arrow:          opts?.progress?.arrow           ? false
                text:
                    draw:       opts?.progress?.text?.draw      ? true
                    floor:      opts?.progress?.text?.floor     ? true
                braces:
                    open:       opts?.progress?.braces?.open    ? "["
                    close:      opts?.progress?.braces?.close   ? "]"
                scale:
                    fill:       opts?.progress?.scale?.fill     ? "="
                    half:       opts?.progress?.scale?.half     ? "-"
                    empty:      opts?.progress?.scale?.empty    ? " "

        # Кэшированные контсанты
        @options.progress.STEPS = @options.progress.max_chars
        if @options.progress.text.draw
            if @options.progress.text.floor
                @options.progress.STEPS -= TEXT_PERCENT_S_LENGTH + TEXT_PERCENT_W_FLOOR
            else
                @options.progress.STEPS -= TEXT_PERCENT_S_LENGTH + TEXT_PERCENT_WO_FLOOR

            if @options.progress.braces.open then @options.progress.STEPS--
            if @options.progress.braces.close then @options.progress.STEPS--

            if @options.progress.arrow then @options.progress.STEPS--

            if @options.progress.scale.half then @options.progress.STEPS--

    ###*
     * Clear console
     * @memberof Visual
     * @todo test it in *nix* OS
    ###
    clear: -> process.stdout.write '\u001B[2J\u001B[0;0f'

    ###*
     * Generate progress bar
     * @memberof Visual
     * 
     * @param  {Integer} min    - start of range
     * @param  {Integer} cur    - current value
     * @param  {Integer} max    - end of range
     * @return {String}         progress bar like this "[=====.....] 50%"
    ###
    getProgress: (min, cur, max)->
        # Высчитывание процента
        percent = cur / (max - min)

        if percent > 1 then percent = 1
        else if percent < 0 then percent = 0

        scale = ""

        # '['
        if @options.progress.braces.open then scale += @options.progress.braces.open

        steps = @options.progress.STEPS
        s = Math.round steps * percent
        # '='
        for i in [0...s]
            scale += @options.progress.scale.fill

        # '-'
        if @options.progress.scale.half and (percent * 100 % 1) > 0.5
            scale += @options.progress.scale.half
        else
            scale += @options.progress.scale.fill

        # '>'
        if @options.progress.arrow then scale += @options.progress.arrow

        # ' '
        for i in [s...steps]
            scale += @options.progress.scale.empty

        # ']'
        if @options.progress.braces.close then scale += @options.progress.braces.close

        if @options.progress.text.draw
            if @options.progress.text.floor
                scale += " #{percent * 100 // 1}%"
            else
                scale += " #{percent * 100}%"

        return scale

    ###*
     * Draw progress bar in console
     * @memberof Visual
     * 
     * @param  {Integer} min    - start of range
     * @param  {Integer} cur    - current value
     * @param  {Integer} max    - end of range
     *
     * @see    {@link getProgress}
    ###
    drawProgress: (min, cur, max)-> console.log @.getProgress min, cur, max

    # Cat
    $getCat: (frame)->
        switch frame
            when 0
                """
                    \/\\___\/\\
                   \/`     '\\
                 === 0 . 0 ===
                   \\  -^-  \/
                  \/         \\
                 \/           \\
                |             |
                 \\  ||   ||  \/   
                  \\_oo___oo_\/#######o
                """
            when 1
                """
                    \/\\___\/\\
                   \/`     '\\
                 ==~ 0 . 0 ~==
                   \\  -^-  \/
                  \/         \\
                 \/           \\
                |             |
                 \\  ||   ||  \/## 
                  \\_oo___oo_\/#  ####o
                """
            when 2
                """
                    \/\\___\/\\
                   \/`     '\\
                 =~= 0 . 0 =~=
                   \\  -^-  \/
                  \/         \\
                 \/           \\
                |             |
                 \\  ||   ||  \/  ## 
                  \\_oo___oo_\/###  ##o
                """
            when 3
                """
                    \/\\___\/\\
                   \/`     "\\
                 ~== 0 . 0 ==~
                   \\  -^-  \/
                  \/         \\
                 \/           \\
                |             |
                 \\  ||   ||  \/    ##
                  \\_oo___oo_\/#####  o
                """
            when 4
                """
                    \/\\___\/\\
                   \/`     '\\
                 === 0 . 0 ===
                   \\  -^-  \/
                  \/         \\
                 \/           \\
                |             |
                 \\  ||   ||  \/      o
                  \\_oo___oo_\/#######
                """
    $drawCat: (frame)-> console.log @.$getCat frame

###
Exports
###
module.exports = Visual