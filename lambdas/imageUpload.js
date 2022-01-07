import Responses from './API_Responses';
import * as fileType from 'file-type';
import { v4 as uuid } from 'uuid';
import * as AWS from 'aws-sdk';

const s3 = new AWS.S3();

// list of mimes allowed
const allowedMimes = ['image/jpeg', 'image/png', 'image/jpg'];

exports.handler = async event => {
    try {
        const body = JSON.parse(event.body);
        // check if the body exists, mime is the type of image
        if (!body || !body.image || !body.mime) {
            // return message
            return Responses._400({ message: 'incorrect body on request' });
        }
        // check the mimes
        if (!allowedMimes.includes(body.mime)) {
            return Responses._400({ message: 'mime is not allowed ' });
        }
        // get the image data of the body
        let imageData = body.image;

        // checking the 1st 7 characters of image
        if (body.image.substr(0, 7) === 'base64,') {
            imageData = body.image.substr(7, body.image.length);
        }
        // convert to buffer to be stored in s3
        const buffer = Buffer.from(imageData, 'base64');
        // convert to file format npm install --save file-type
        const fileInfo = await fileType.fromBuffer(buffer);
        // get the extention, make sure that the values of data matches mime ext of file uploaded
        const detectedExt = fileInfo.ext;
        const detectedMime = fileInfo.mime;

        // if the data not match uploaded file
        if (detectedMime !== body.mime) {
            return Responses._400({ message: 'mime types dont match' });
        }

        // give file a name in s3 > npm install --save uuid
        const name = uuid();
        const key = `${name}.${detectedExt}`;

        console.log(`writing image to bucket called ${key}`);

        // creating s3 
        await s3
            .putObject({
                Body: buffer,
                Key: key,
                ContentType: body.mime,
                Bucket: process.env.imageUploadBucket,
                ACL: 'public-read',
            })
            .promise();

        const url = `https://${process.env.imageUploadBucket}.s3-${process.env.region}.amazonaws.com/${key}`;
        return Responses._200({
            imageURL: url,
        });
    } catch (error) {
        console.log('error', error);

        return Responses._400({ message: error.message || 'failed to upload image' });
    }
};