#
# lambda.sh
#

# Clean up before starting
rm -rf env/
rm -rf package/
rm function.zip

# Build poppler
#rm -rf poppler_binaries/
#./build_poppler.sh

# Make a virtualenv
virtualenv --python python3 env/
source env/bin/activate

# Creating the package
mkdir -p package
pip3 install Pillow --target package/
#pip3 install pdf2image --target package/

# Moving the poppler libraries in the package
cp -r pdf2image/ package/
cp -r poppler_binaries/ package/

# Moving the function in the package
cp amazon/pdf2image_demo.py package/

# Zipping the package
cd package
zip -r9 ../function.zip *
cd ..

# Deleting package artifacts
rm -rf package/

# Cleaning AWS function
aws lambda delete-function --function-name pdf2image-demo-function --region us-east-1

# Cleaning AWS role
aws iam detach-role-policy --policy-arn arn:aws:iam::aws:policy/AWSLambdaFullAccess --role-name pdf2image-demo-role
aws iam delete-role --role-name pdf2image-demo-role

# Creating AWS role
aws iam create-role --role-name pdf2image-demo-role --assume-role-policy-document file://amazon/role-policy.json
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/AWSLambdaFullAccess --role-name pdf2image-demo-role

# Creating AWS function
# For reference, see: https://docs.aws.amazon.com/cli/latest/reference/lambda/create-function.html
aws lambda create-function --function-name pdf2image-demo-function \
                           --runtime python3.6 \
                           --memory 128 \
                           --handler pdf2image_demo.convert \
                           --description "Convert a PDF file to multiple images" \
                           --timeout 30 \
                           --region us-east-1 \
                           --role arn:aws:iam::230779662357:role/pdf2image-demo-role \
                           --publish \
                           --zip-file fileb://function.zip

# Test it
aws lambda invoke --function-name pdf2image-demo-function \
                  --region us-east-1 \
                  --log-type Tail \
                  --payload '{"pdf_file": "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XQovQ291bnQgMT4+CmVuZG9iagoKMTIgMCBvYmoKPDwvVHlwZS9DYXRhbG9nL1BhZ2VzIDQgMCBSCi9PcGVuQWN0aW9uWzEgMCBSIC9YWVogbnVsbCBudWxsIDBdCi9MYW5nKGVuLUNBKQo+PgplbmRvYmoKCjEzIDAgb2JqCjw8L0NyZWF0b3I8RkVGRjAwNTcwMDcyMDA2OTAwNzQwMDY1MDA3Mj4KL1Byb2R1Y2VyPEZFRkYwMDRDMDA2OTAwNjIwMDcyMDA2NTAwNEYwMDY2MDA2NjAwNjkwMDYzMDA2NTAwMjAwMDM2MDAyRTAwMzA+Ci9DcmVhdGlvbkRhdGUoRDoyMDE4MTIxNjIwMTk0MC0wNScwMCcpPj4KZW5kb2JqCgp4cmVmCjAgMTQKMDAwMDAwMDAwMCA2NTUzNSBmIAowMDAwMDA1MTUzIDAwMDAwIG4gCjAwMDAwMDAwMTkgMDAwMDAgbiAKMDAwMDAwMDE5NCAwMDAwMCBuIAowMDAwMDA1MzIyIDAwMDAwIG4gCjAwMDAwMDAyMTQgMDAwMDAgbiAKMDAwMDAwNDM2NyAwMDAwMCBuIAowMDAwMDA0Mzg4IDAwMDAwIG4gCjAwMDAwMDQ1ODMgMDAwMDAgbiAKMDAwMDAwNDg5MSAwMDAwMCBuIAowMDAwMDA1MDY2IDAwMDAwIG4gCjAwMDAwMDUwOTggMDAwMDAgbiAKMDAwMDAwNTQyMSAwMDAwMCBuIAowMDAwMDA1NTE4IDAwMDAwIG4gCnRyYWlsZXIKPDwvU2l6ZSAxNC9Sb290IDEyIDAgUgovSW5mbyAxMyAwIFIKL0lEIFsgPDg4QjY4QjA2Njk4OEU0QURBMUM0MjkzRkNBN0I4Qzc2Pgo8ODhCNjhCMDY2OTg4RTRBREExQzQyOTNGQ0E3QjhDNzY+IF0KL0RvY0NoZWNrc3VtIC9FRTI1NDNCMDc1NzVCMkRCRkNGRjMwMzEwMkY5OEI2RQo+PgpzdGFydHhyZWYKNTY5MwolJUVPRgo="}' \
                  output.txt