#!/bin/bash

temp_dir=$(mktemp -d)
pushd ${temp_dir}

pem=rsa_key
priv_der=$pem.der
pub_der=$pem.pub.der
openssl genrsa -out $pem 
openssl rsa -in $pem -outform DER -out $priv_der
openssl rsa -in $priv_der -inform DER -RSAPublicKey_out -outform DER -out $pub_der

tar zcvf rsa.tgz rsa_key*
cat rsa.tgz | base64 | awk '{ print "RSA_CONTENT=" $1 }' | xargs heroku config:set

popd
