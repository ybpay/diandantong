//======================================================
// utils copy from angular js
//======================================================
WebposModules.add_service('wp_ng_utils')
angular.module('webpos.services.wp_ng_utils', [])
  .factory('WpNgUtils', [
    function () {

      var jqLite = $
      var isString = angular.isString
      var isArray = angular.isArray
      var isObject = angular.isObject
      var forEach = angular.forEach

      function safeAddClass($element, className) {
        try {
          $element.addClass(className);
        } catch (e) {
          // ignore, since it means that we are trying to set class on
          // SVG element, where class name is read-only.
        }
      }


      /**
       * @description
       *
       * This object provides a utility for producing rich Error messages within
       * Angular. It can be called as follows:
       *
       * var exampleMinErr = minErr('example');
       * throw exampleMinErr('one', 'This {0} is {1}', foo, bar);
       *
       * The above creates an instance of minErr in the example namespace. The
       * resulting error will have a namespaced error code of example.one.  The
       * resulting error will replace {0} with the value of foo, and {1} with the
       * value of bar. The object is not restricted in the number of arguments it can
       * take.
       *
       * If fewer arguments are specified than necessary for interpolation, the extra
       * interpolation markers will be preserved in the final string.
       *
       * Since data will be parsed statically during a build step, some restrictions
       * are applied with respect to how minErr instances are created and called.
       * Instances should have names of the form namespaceMinErr for a minErr created
       * using minErr('namespace') . Error codes, namespaces and template strings
       * should all be static strings, not variables or general expressions.
       *
       * @param {string} module The namespace to use for the new minErr instance.
       * @param {function} ErrorConstructor Custom error constructor to be instantiated when returning
       *   error from returned function, for cases when a particular type of error is useful.
       * @returns {function(code:string, template:string, ...templateArgs): Error} minErr instance
       */

      function minErr(module, ErrorConstructor) {
        ErrorConstructor = ErrorConstructor || Error;
        return function() {
          var code = arguments[0],
            prefix = '[' + (module ? module + ':' : '') + code + '] ',
            template = arguments[1],
            templateArgs = arguments,

            message, i;

          message = prefix + template.replace(/\{\d+\}/g, function(match) {
              var index = +match.slice(1, -1), arg;

              if (index + 2 < templateArgs.length) {
                return toDebugString(templateArgs[index + 2]);
              }
              return match;
            });

          for (i = 2; i < arguments.length; i++) {
            message = message + (i == 2 ? '?' : '&') + 'p' + (i - 2) + '=' +
              encodeURIComponent(toDebugString(arguments[i]));
          }
          return new ErrorConstructor(message);
        };
      }

      /* global: toDebugString: true */

      function serializeObject(obj) {
        var seen = [];

        return JSON.stringify(obj, function(key, val) {
          val = toJsonReplacer(key, val);
          if (isObject(val)) {

            if (seen.indexOf(val) >= 0) return '<<already seen>>';

            seen.push(val);
          }
          return val;
        });
      }

      function toDebugString(obj) {
        if (typeof obj === 'function') {
          return obj.toString().replace(/ \{[\s\S]*$/, '');
        } else if (typeof obj === 'undefined') {
          return 'undefined';
        } else if (typeof obj !== 'string') {
          return serializeObject(obj);
        }
        return obj;
      }

      function toJsonReplacer(key, value) {
        var val = value;

        if (typeof key === 'string' && key.charAt(0) === '$' && key.charAt(1) === '$') {
          val = undefined;
        } else if (isWindow(value)) {
          val = '$WINDOW';
        } else if (value &&  document === value) {
          val = '$DOCUMENT';
        } else if (isScope(value)) {
          val = '$SCOPE';
        }

        return val;
      }

      var uid = 0;
      function nextUid(){
        return 'NgWp' + (++uid);
      }

      /**
       * Computes a hash of an 'obj'.
       * Hash of a:
       *  string is string
       *  number is number as string
       *  object is either result of calling $$hashKey function on the object or uniquely generated id,
       *         that is also assigned to the $$hashKey property of the object.
       *
       * @param obj
       * @returns {string} hash string such that the same input will have the same hash string.
       *         The resulting string key is in 'type:hashKey' format.
       */
      function hashKey(obj, nextUidFn) {
        var key = obj && obj.$$hashKey;

        if (key) {
          if (typeof key === 'function') {
            key = obj.$$hashKey();
          }
          return key;
        }

        var objType = typeof obj;
        if (objType == 'function' || (objType == 'object' && obj !== null)) {
          key = obj.$$hashKey = objType + ':' + (nextUidFn || nextUid)();
        } else {
          key = objType + ':' + obj;
        }

        return key;
      }

      /**
       * Creates a new object without a prototype. This object is useful for lookup without having to
       * guard against prototypically inherited properties via hasOwnProperty.
       *
       * Related micro-benchmarks:
       * - http://jsperf.com/object-create2
       * - http://jsperf.com/proto-map-lookup/2
       * - http://jsperf.com/for-in-vs-object-keys2
       *
       * @returns {Object}
       */
      function createMap() {
        return Object.create(null);
      }

      var NODE_TYPE_ELEMENT = 1;
      var NODE_TYPE_TEXT = 3;
      var NODE_TYPE_COMMENT = 8;
      var NODE_TYPE_DOCUMENT = 9;
      var NODE_TYPE_DOCUMENT_FRAGMENT = 11;

      /**
       * @private
       * @param {*} obj
       * @return {boolean} Returns true if `obj` is an array or array-like object (NodeList, Arguments,
       *                   String ...)
       */
      function isArrayLike(obj) {
        if (obj == null || isWindow(obj)) {
          return false;
        }

        var length = obj.length;

        if (obj.nodeType === NODE_TYPE_ELEMENT && length) {
          return true;
        }

        return isString(obj) || isArray(obj) || length === 0 ||
          typeof length === 'number' && length > 0 && (length - 1) in obj;
      }



      /**
       * Checks if `obj` is a window object.
       *
       * @private
       * @param {*} obj Object to check
       * @returns {boolean} True if `obj` is a window obj.
       */
      function isWindow(obj) {
        return obj && obj.window === obj;
      }


      function isScope(obj) {
        return obj && obj.$evalAsync && obj.$watch;
      }




      /**
       * Return the DOM siblings between the first and last node in the given array.
       * @param {Array} array like object
       * @returns {jqLite} jqLite collection containing the nodes
       */
      function getBlockNodes(nodes) {
        // TODO(perf): just check if all items in `nodes` are siblings and if they are return the original
        //             collection, otherwise update the original collection.
        var node = nodes[0];
        var endNode = nodes[nodes.length - 1];
        var blockNodes = [node];

        do {
          node = node.nextSibling;
          if (!node) break;
          blockNodes.push(node);
        } while (node !== endNode);

        return jqLite(blockNodes);
      }

      return {
        minErr: minErr,
        getBlockNodes: getBlockNodes,
        hashKey: hashKey,
        createMap: createMap,
        isArrayLike: isArrayLike,
        jqLite: jqLite
      }
    }])
