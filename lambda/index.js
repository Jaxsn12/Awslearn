const AWS = require('aws-sdk');
const S3 = new AWS.S3();
const sharp = require('sharp');

exports.handler = async (event) => {
    const Bucket = event.Records[0].s3.bucket.name;
    const Key = decodeURIComponent(event.Records[0].s3.object.key.replace(/\+/g, " "));
    const newKey = `resized-${Key}`;
    try {
        // Get image from S3
        const image = await S3.getObject({ Bucket, Key }).promise();

        // Resize the image
        const resizedImage = await sharp(image.Body)
            .resize(300, 300)
            .toBuffer();

        // Upload the resized image to the same S3 bucket
        await S3.putObject({
            Bucket,
            Key: newKey,
            Body: resizedImage,
            ContentType: 'image/jpeg'
        }).promise();

        return {
            statusCode: 200,
            body: `Image resized and uploaded to ${newKey}`
        };
    } catch (err) {
        return {
            statusCode: 500,
            body: JSON.stringify(err)
        };
    }
};
