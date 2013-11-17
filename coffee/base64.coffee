timeTracker.factory("Base64", [ () ->

  keyStr = "ABCDEFGHIJKLMNOP" +
           "QRSTUVWXYZabcdef" +
           "ghijklmnopqrstuv" +
           "wxyz0123456789+/" +
           "="

  encode: (input) ->
    output = ""
    chr1 = undefined
    chr2 = undefined
    chr3 = ""
    enc1 = undefined
    enc2 = undefined
    enc3 = undefined
    enc4 = ""
    i = 0
    loop
      chr1 = input.charCodeAt(i++)
      chr2 = input.charCodeAt(i++)
      chr3 = input.charCodeAt(i++)
      enc1 = chr1 >> 2
      enc2 = ((chr1 & 3) << 4) | (chr2 >> 4)
      enc3 = ((chr2 & 15) << 2) | (chr3 >> 6)
      enc4 = chr3 & 63
      if isNaN(chr2)
        enc3 = enc4 = 64
      else enc4 = 64  if isNaN(chr3)
      output = output + keyStr.charAt(enc1) + keyStr.charAt(enc2) + keyStr.charAt(enc3) + keyStr.charAt(enc4)
      chr1 = chr2 = chr3 = ""
      enc1 = enc2 = enc3 = enc4 = ""
      break unless i < input.length
    output

  decode: (input) ->
    output = ""
    chr1 = undefined
    chr2 = undefined
    chr3 = ""
    enc1 = undefined
    enc2 = undefined
    enc3 = undefined
    enc4 = ""
    i = 0

    # remove all characters that are not A-Z, a-z, 0-9, +, /, or =
    base64test = /[^A-Za-z0-9\+\/\=]/g
    if base64test.exec(input)
      alert "There were invalid base64 characters in the input text.\n" +
            "Valid base64 characters are A-Z, a-z, 0-9, '+', '/',and '='\n" +
            "Expect errors in decoding."
    input = input.replace(/[^A-Za-z0-9\+\/\=]/g, "")
    loop
      enc1 = keyStr.indexOf(input.charAt(i++))
      enc2 = keyStr.indexOf(input.charAt(i++))
      enc3 = keyStr.indexOf(input.charAt(i++))
      enc4 = keyStr.indexOf(input.charAt(i++))
      chr1 = (enc1 << 2) | (enc2 >> 4)
      chr2 = ((enc2 & 15) << 4) | (enc3 >> 2)
      chr3 = ((enc3 & 3) << 6) | enc4
      output = output + String.fromCharCode(chr1)
      output = output + String.fromCharCode(chr2)  unless enc3 is 64
      output = output + String.fromCharCode(chr3)  unless enc4 is 64
      chr1 = chr2 = chr3 = ""
      enc1 = enc2 = enc3 = enc4 = ""
      break unless i < input.length
    output
  ]
)
