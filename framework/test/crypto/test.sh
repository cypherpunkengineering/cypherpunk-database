#!/usr/local/bin/zsh

bits=2048
digest=sha256

infile=in
outfile=out
outfile2=out2
hashfile=hash1
hashfile2=hash2

OPENSSL=/usr/local/bin/openssl

clean()
{
	echo "+++++++++++++++++++++++++++++ cleaning temp files"
	rm -f private.${bits}.pem public.${bits} ${infile} ${infile} ${outfile} ${outfile2} ${hashfile} ${hashfile2} || exit 1
}

keypair()
{
	echo "+++++++++++++++++++++++++++++ generat${infile}g new keypair"
	coffee generate.coffee || exit 1
}

data()
{
	echo "+++++++++++++++++++++++++++++ get random data"
	x=0
	until [ $x = 30 ];do
		echo -n $RANDOM >> ${infile}
		((x++))
	done
}

wizEncrypt()
{
	echo "+++++++++++++++++++++++++++++ encrypt with wizrsa"
	coffee encrypt.coffee || exit 1
}

wizDecrypt()
{
	echo "+++++++++++++++++++++++++++++ decrypt with wizrsa"
	coffee decrypt.coffee || exit 1
}

wizSign()
{
	echo "+++++++++++++++++++++++++++++ sign with wizrsa"
	coffee sign.coffee || exit 1
}

wizVerify()
{
	echo "+++++++++++++++++++++++++++++ verify with wizrsa"
	coffee verify.coffee || exit 1
}

opensslEncrypt()
{
	echo "+++++++++++++++++++++++++++++ encrypt with ${OPENSSL}"
	${OPENSSL} rsautl -encrypt -inkey public.${bits}.pem -pubin -in ${infile} -out ${outfile} || exit 1
	echo 'openssl encrypt OK'
}

opensslDecrypt()
{
	echo "+++++++++++++++++++++++++++++ decrypt with ${OPENSSL}"
	${OPENSSL} rsautl -inkey private.${bits}.pem -decrypt -in ${outfile} -out ${outfile2} || exit 1
	if diff ${infile} ${outfile2} >/dev/null;then
		echo 'openssl decrypt OK'
	else
		echo 'openssl decrypt FAIL'
		exit 1
	fi
}

opensslSign()
{
	echo "+++++++++++++++++++++++++++++ sign with ${OPENSSL}"
	${OPENSSL} dgst -${digest} -binary -out ${hashfile} ${infile} || exit 1
	${OPENSSL} pkeyutl -sign -in ${hashfile} -inkey private.${bits}.pem -pkeyopt digest:${digest} -out ${outfile} || exit 1
	echo 'openssl sign OK'
}

opensslVerify()
{
	echo "+++++++++++++++++++++++++++++ verify with ${OPENSSL}"
	${OPENSSL} dgst -${digest} -binary -out ${hashfile} ${infile} || exit 1
	${OPENSSL} dgst -${digest} -sign private.${bits}.pem < in > ${hashfile2}
	if diff ${hashfile} ${hashfile2} >/dev/null;then
		echo 'openssl verify OK'
	else
		echo 'openssl verify FAIL'
		exit 1
	fi
}

testEncrypting()
{
	wizEncrypt
	wizDecrypt

	opensslEncrypt
	wizDecrypt

	wizEncrypt
	opensslDecrypt
}

testSigning()
{
	wizSign
	wizVerify

	opensslSign
	wizVerify

	wizSign
	opensslVerify
}

clean
keypair
data
testEncrypting
testSigning

