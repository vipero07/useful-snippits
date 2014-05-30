//big type is for big numbers i.e. 1234 = 1.2k, 1234567890 = 1.2B
//bit is for bits/bytes to kb, mb, gb, etc, defaults to bit
function humanReadable(number, type){
  var prefix = ' kMGTPEZYXWVU', kilo = 1024;
  if(type && type=='big'){
    prefix = prefix.replace('G','B');
    kilo = 1000;
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
