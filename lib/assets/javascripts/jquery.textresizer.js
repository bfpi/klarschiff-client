/*
jQuery Text Resizer Plugin v1.1.0
    
Copyright (c) 2009-2013 Mario J Vargas
See the file MIT-LICENSE.txt for copying permission.
    
Website: http://angstrey.com/
Documentation: http://angstrey.com/index.php/projects/jquery-text-resizer-plugin/
*/
;(function ($) {
    "use strict";

    var TextResizerPlugin, debug, stringify;

    stringify = function (value) {
        if ("object" === (typeof window.JSON) && "function" === (typeof window.JSON.stringify)) {
            return JSON.stringify(value);
        }

        // Because of IE7 and below... Need I say more?
        return value;
    };

    debug = function (obj) {
        if (window.console && "function" === (typeof window.console.log)) {
            setTimeout(function () {
                var key,
                    output = [],
                    keyValuePair;

                if ("string" === (typeof obj)) {
                    output.push("jquery.textresizer => " + obj);
                } else {
                    output.push("jquery.textresizer => {");
                    for (key in obj) {
                        if (obj.hasOwnProperty(key)) {
                            keyValuePair = [
                                "    ", key, ": ", stringify(obj[key])
                            ].join("");
                            output.push(keyValuePair);
                        }
                    }
                    output.push("}");
                }

                console.log(output.join("\n"));
            }, 0);
        }
    };

    TextResizerPlugin = function ($elements, options) {
        this.$elements = $elements;
        this.settings = options || TextResizerPlugin.defaults;
    };

    TextResizerPlugin.defaults = {
        debugMode: false,                               // Disable debug mode.
        type: "fontSize",                               // Available options: fontSize, css, cssClass.
        target: "body",                                 // The HTML element to which the new font size will be applied.
        selectedIndex: -1,                              // No font size option selected by default.
        suppressClickThrough: true                      // Disables click-through of font size controls.
    };

    TextResizerPlugin.prototype.buildDefaultFontSizes = function (numElms) {
        if (0 === numElms) {
            return;
        }

        var size0 = 8,                // Initial size, measured in pixels
            mySizes = [],
            i,
            value;

        if (this.settings.debugMode) {
            debug("In buildDefaultFontSizes: numElms = " + numElms);
        }

        if (this.settings.debugMode) {
            for (i = 0; i < numElms; i += 1) {
                // Append elements in increments of 2 units
                value = (size0 + (i * 2)) / 10;
                mySizes.push(value + "em");

                debug("In buildDefaultFontSizes: mySizes[" + i + "] = " + mySizes[i]);
            }
        } else {
            for (i = 0; i < numElms; i += 1) {
                // Append elements in increments of 2 units
                value = (size0 + (i * 2)) / 10;
                mySizes.push(value + "em");
            }
        }

        return mySizes;
    };

    TextResizerPlugin.prototype.serializeHash = function (dictionary) {
        // jQuery's param() function does not replace white space correctly
        return $.param(dictionary).replace(/\+/g, "%20");
    };

    TextResizerPlugin.prototype.deserializeHash = function (serializedValue) {
        var i,
            valueCount,
            keyValuePair,
            dictionary = {},
            separatorPattern = /\&|\|/g,
            dictValues = serializedValue.split(separatorPattern);

        for (i = 0, valueCount = dictValues.length; i < valueCount; i += 1) {
            // Separate key/value pair and assign to dictionary
            keyValuePair = dictValues[i].split("=");
            dictionary[keyValuePair[0]] = window.decodeURIComponent(keyValuePair[1]);
        }

        // Now that the object is finished, return it
        return dictionary;
    };

    TextResizerPlugin.prototype.buildCookieID = function (selector, target, prop) {
        return "JQUERY.TEXTRESIZER[" + selector + "," + target + "]." + prop;
    };

    TextResizerPlugin.prototype.getCookie = function (selector, target, prop) {
        var id = this.buildCookieID(selector, target, prop),
            cookieValue = $.cookie(id);

        if ($.cookie(id + ".valueType") === "dict" && cookieValue) {
            return this.deserializeHash(cookieValue);
        }

        return cookieValue;
    };

    TextResizerPlugin.prototype.setCookie = function (selector, target, prop, value) {
        var id = this.buildCookieID(selector, target, prop),
            // Cookie expires in 1 year (365 days/year)
            cookieOpts = { expires: 365, path: "/" },
            serializedVals;

        // Serialize value if it's an object
        if ("object" === (typeof value)) {
            // Store type of value so we can convert it back 
            // to a dictionary object
            $.cookie(id + ".valueType", "dict", cookieOpts);

            serializedVals = this.serializeHash(value);

            $.cookie(id, serializedVals, cookieOpts);

            if (this.settings.debugMode) {
                debug("In setCookie: Cookie: " + id + ": " + serializedVals);
            }
        } else {
            $.cookie(id, value, cookieOpts);

            if (this.settings.debugMode) {
                debug("In setCookie: Cookie (not hash): " + id + ": " + value);
            }
        }
    };

    TextResizerPlugin.prototype.applyInlineCssProperties = function ($targetElement, cssStyles) {
        $targetElement.css(cssStyles);
    };

    TextResizerPlugin.prototype.applyCssClass = function ($targetElement, newSize, cssClasses) {
        // Remove previously assigned CSS class from
        // target element. Iterating through matched
        // elements ensures the class is removed
        $.each(cssClasses, function () {
            var className = this.toString();
            $targetElement.each(function () {
                var $currentElement = $(this);
                if ($currentElement.hasClass(className)) {
                    $currentElement.removeClass(className);
                }
            });
        });

        // Now apply the new CSS class
        $targetElement.addClass(newSize);
    };

    TextResizerPlugin.prototype.applySpecificFontSize = function ($targetElement, newSize) {
        $targetElement.css("font-size", newSize);
    };

    TextResizerPlugin.prototype.applyFontSize = function (newSize) {
        if (this.settings.debugMode) {
            debug([
                "In applyFontSize(): target: ",
                this.settings.target,
                " | ",
                "newSize: ",
                stringify(newSize),
                " | ",
                "type: ",
                this.settings.type
            ].join(""));
        }

        var $targetElement = $(this.settings.target);
        switch (this.settings.type) {
            case "css":
                this.applyInlineCssProperties($targetElement, newSize);
                break;

            case "cssClass":
                this.applyCssClass($targetElement, newSize, this.settings.sizes);
                break;

            default:
                this.applySpecificFontSize($targetElement, newSize);
                break;
        }
    };

    TextResizerPlugin.prototype.loadPreviousState = function () {
        var settings = this.settings,
            rawSelectedIndex,
            selectedIndex,
            prevSize;

        // Determine if jquery.cookie is installed
        if ($.cookie) {
            if (settings.debugMode) {
                debug("In loadPreviousState(): jquery.cookie: INSTALLED");
            }

            rawSelectedIndex = this.getCookie(settings.selector, settings.target, "selectedIndex");
            selectedIndex = parseInt(rawSelectedIndex, 10);
            prevSize = this.getCookie(settings.selector, settings.target, "size");

            if (!isNaN(selectedIndex)) {
                settings.selectedIndex = selectedIndex;
            }

            if (settings.debugMode) {
                debug("In loadPreviousState: selectedIndex: " + selectedIndex + "; type: " + (typeof selectedIndex));

                debug("In loadPreviousState: prevSize: " + prevSize + "; type: " + (typeof prevSize));
            }

            if (prevSize) {
                this.applyFontSize(prevSize);
            }
        } else {
            if (settings.debugMode) {
                debug("In loadPreviousState(): jquery.cookie: NOT INSTALLED");
            }
        }
    };

    TextResizerPlugin.prototype.markActive = function (sizeButton) {
        // Deactivate previous button
        $(this.settings.selector).removeClass("textresizer-active");

        // Mark this button as active
        $(sizeButton).addClass("textresizer-active");
    };

    TextResizerPlugin.prototype.saveState = function (newSize) {
        // Determine if jquery.cookie is installed
        if ($.cookie) {
            var selector = this.settings.selector,
                target = this.settings.target,
                selectedIndex = this.settings.selectedIndex;

            if (this.settings.debugMode) {
                debug("In saveState(): jquery.cookie: INSTALLED");
            }

            this.setCookie(selector, target, "size", newSize);
            this.setCookie(selector, target, "selectedIndex", selectedIndex);
        } else {
            if (this.settings.debugMode) {
                debug("In saveState(): jquery.cookie: NOT INSTALLED");
            }
        }
    };

    TextResizerPlugin.prototype.attachResizerToElement = function (element, index) {
        var thisPlugin = this,
            settings = thisPlugin.settings,
            $resizeButton = $(element),                // Current resize button
            currSizeValue = settings.sizes[index];     // Size corresponding to this resize button

        // Mark this button as active if necessary
        if (index === settings.selectedIndex) {
            $resizeButton.addClass("textresizer-active");
        }

        // Apply the font size to target element when its 
        // corresponding resize button is clicked
        $resizeButton.on("click", { index: index }, function (e) {
            var currentElement = this;

            if (settings.suppressClickThrough) {
                e.preventDefault();
            }

            settings.selectedIndex = e.data.index;

            thisPlugin.applyFontSize(currSizeValue);
            thisPlugin.saveState(currSizeValue);

            thisPlugin.markActive(currentElement);
        });
    };

    TextResizerPlugin.prototype.init = function () {
        var numberOfElements = this.$elements.size(),
            debugMode = TextResizerPlugin.defaults.debugMode;

        if (debugMode) {
            debug("init() => selection count: " + numberOfElements);
        }

        // Stop plugin execution if no matched elements
        if (0 === numberOfElements) {
            return;
        }

        // Set up main options before element iteration
        this.settings = $.extend(
            {
                selector: this.$elements.selector,
                sizes: this.buildDefaultFontSizes(numberOfElements)     // Default font sizes based on number of resize buttons.
            },
            $.fn.textresizer.defaults,
            this.settings
        );

        debugMode = this.settings.debugMode;

        if (debugMode) {
            debug(this.settings);
        }

        // Ensure that the number of defined sizes is suitable
        // for number of resize buttons.
        if (numberOfElements > this.settings.sizes.length) {
            if (debugMode) {
                debug("ERROR: Number of defined sizes incompatible with number of buttons => elements: " + numberOfElements
                        + "; defined sizes: " + this.settings.sizes.length
                        + "; target: " + this.settings.target);
            }

            return;    // Stop execution of the plugin
        }

        this.loadPreviousState();

        return this;
    };

    $.fn.textresizer = function (options) {
        var plugin = new TextResizerPlugin(this, options).init();

        // Iterate and bind click event function to each element
        return this.each(function (i) {
            plugin.attachResizerToElement(this, i);
        });
    };

    $.fn.textresizer.defaults = TextResizerPlugin.defaults;
})(window.jQuery);