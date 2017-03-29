//
// NOTICE:
// The script require stacktrace.js
//

(function(){

//=====================================================================================
// configuration
//=====================================================================================
    var ERROR_REPORT_URL = "/common/js_error_report";

//=====================================================================================
// global report interface
//=====================================================================================

    //
    // send report to server
    //
    var sendReport = function(msg, stackStringArray, cause){

      var js_error = {
          url: window.location.href,
          error_message: msg,
          stack_trace: stackStringArray ? stackStringArray : ["no stack"]
      };
      if (cause){
        js_error.cause = cause;
      }


      $.ajax({
        type: 'POST',
        url: ERROR_REPORT_URL,
        dataType: 'application/json',
        data: {
          js_error: js_error
        }
      });
    };

    //
    // alert/log error to console
    //
    var logError = function(err, reportNullError){
      var message = err ? err.message : "error object is null";
      if (err || reportNullError) {
        if (console){
          console.log(message);
        } else{
          alert(message);
        }
      }
    };

    //
    // initiative report js error
    //
    window.reportJsError = function(msg){
      StackTrace.get({
        offline: true
      }).then(function(stackframes){
        sendReport(msg, stackframes.map(function(sf) {
          return sf.toString();
        }));
      }).catch(function(err){
        logError(err);
        sendReport("exception in send error report: " + err ? err.message : err + ", original error message: " + msg);
      });
    };

//=====================================================================================
// non angular error
//=====================================================================================

  window.onerror = function(msg, file, line, col, error) {
    // callback is called with an Array[StackFrame]
    if (error) {
      StackTrace.fromError(error).then(function (stackframes) {
        var stringifiedStack = stackframes.map(function (sf) {
          return sf.toString();
        });
        sendReport(msg, stringifiedStack);
      }).catch(function (err) {
        logError(err);
        sendReport("exception in send error report: " + err ? err.message : err + ", original error message: " + msg);
      });
    }else{
      sendReport(msg)
    }
  };

//=====================================================================================
// angular error
//=====================================================================================

//
// article from web:
// http://www.bennadel.com/blog/2542-logging-client-side-errors-with-angularjs-and-stacktrace-js.htm
// By Ben Nadel on October 3, 2013
//
// offical document
// https://docs.angularjs.org/api/ng/service/$exceptionHandler
//
//

// Create an application module
    if (typeof angular !== "undefined") {
        var loggingModule = angular.module("errorReporter", []);
// -------------------------------------------------- //
// -------------------------------------------------- //

      // The "stacktrace" library that we included in the Scripts
      // is now in the Global scope; but, we don't want to reference
      // global objects inside the AngularJS components - that's
      // not how AngularJS rolls; as such, we want to wrap the
      // stacktrace feature in a proper AngularJS service that
      // formally exposes the print method.
      loggingModule.factory( "stackTraceService",[ '$log',
        function ($log) {
          return {
            report: function(exception, cause){
              if (exception){
                if (exception) {
                  var msg = exception && exception.message ? exception.message : exception.toString();
                  StackTrace.fromError(exception).then(function (stackframes) {
                    // callback is called with an Array[StackFrame]
                    sendReport(msg, stackframes.map(function (sf) {
                      return sf.toString();
                    }, cause));
                  }).catch(function (err) {
                    $log.log(err);
                    sendReport("exception in send error report: " + err ? err.message : err + ", original error message: " + msg);
                  });
                }else{
                  sendReport("unknown error in angular, cause: " + cause);
                }
              }
            }
          };
        }]
      );


      loggingModule.factory('$exceptionHandler',
        ['$log', 'stackTraceService',
          function ($log, stackTraceService) {
            return function (exception, cause) {
              // Pass off the error to the default error handler
              // on the AngualrJS logger. This will output the
              // error to the console (and let the application
              // keep running normally for the user).
              $log.error.apply($log, arguments);

              // Now, we need to try and log the error the server.
              try {
                // callback is called with an Array[StackFrame]
                stackTraceService.report(exception, cause);
              } catch (loggingError) {
                // For Developers - log the log-failure.
                $log.error(loggingError);
                sendReport("exception in send error report: " + loggingError ? loggingError : 'unknown error');
              }
            };
          }]);
    }

})();



