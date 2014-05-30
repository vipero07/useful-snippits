(function () {
  //big type is for big numbers i.e. 1234 = 1.2k, 1234567890 = 1.2B
  //bit is for bits/bytes to kb, mb, gb, etc, defaults to bit
  var bigPrefix = ' kMBTPEZYXWVU', bigKilo = 1000,
      bitPrefix = ' KMGTPEZYXWVU', bitKilo = 1024;
  function humanReadable(number, type){
    var prefix = bitPrefix, kilo = bitKilo;
    if(type && type=='big'){
      prefix = bigPrefix;
      kilo = bigKilo;
    }
    var retValue = 0;
    if (typeof number == "number") {
        if (number < kilo) {
            retValue = number.toString();
        } else {
            var e = (Math.log(number) / Math.log(kilo)) | 0;
            retValue = Number((number / Math.pow(kilo, e)).toString().slice(0, 3)) + prefix.charAt(e);
        }
    }
    return retValue;
  }
  window.humanReadable = humanReadable;
})();
