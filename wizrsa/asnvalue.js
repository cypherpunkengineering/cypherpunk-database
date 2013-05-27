function ASNValue(tag) {
	this.tag = tag;
}

function setIntBuffer(value) {
	if (value.length > 1) {
		var firstbyte = value[0];
		if (firstbyte & 0x80) {
			// First bit is set but it needs to be 0
			var zerobit = new Buffer('00', 'hex');
			value = Buffer.concat([zerobit, value]);
		}
	}
	this.value = value;
}

function setSequence(value) {
	var result = value[0].encode();
	for(i=1; i<value.length; i++) {
		result = Buffer.concat([result, value[i].encode()]);
	}
	this.value = result;
}



function encode() {
	var result = this.tag;
	var size = this.value.length;
	// Calculate how many bytes are needed to store the value of size
	if (size < 127) {
		sizehex = new Buffer("0"+size.toString(16), 'hex');
		result = Buffer.concat([result,sizehex]);
	} else {
		var hexstring = size.toString(16);
		// When making a buffer from hex, must be made on byte boundary
		if (hexstring.length % 2 == 1) {
			hexstring = "0" + hexstring;
		}
		var sizeBuf = new Buffer(hexstring, 'hex');
		var firstByte = 0x80 + sizeBuf.length;
		var fb = new Buffer(firstByte.toString(16), 'hex');
		result = Buffer.concat([result,fb,sizeBuf]);
	}
	result = Buffer.concat([result,this.value]);
	return result;
}


exports.ASNValue = ASNValue;
ASNValue.prototype.setIntBuffer = setIntBuffer;
ASNValue.prototype.setSequence = setSequence;
ASNValue.prototype.encode = encode;
exports.setIntBuffer = setIntBuffer;
