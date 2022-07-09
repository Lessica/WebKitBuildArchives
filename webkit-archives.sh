#!/bin/sh

s3url=https://s3-us-west-2.amazonaws.com/minified-archives.webkit.org/
s3ns=http://s3.amazonaws.com/doc/2006-03-01/

i=0
s3get=$s3url

while :; do
    curl -s $s3get > "listing$i.xml"
    nextkey=$(xml sel -T -N "w=$s3ns" -t \
        --if '/w:ListBucketResult/w:IsTruncated="true"' \
        -v 'str:encode-uri(/w:ListBucketResult/w:Contents[last()]/w:Key, true())' \
        -b -n "listing$i.xml")
    # -b -n adds a newline to the result unconditionally, 
    # this avoids the "no XPaths matched" message; $() drops newlines.

    if [ -n "$nextkey" ] ; then
        s3get=$s3url"?marker=$nextkey"
        i=$((i+1))
    else
        break
    fi
done