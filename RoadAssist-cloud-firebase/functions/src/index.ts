import * as functions from 'firebase-functions';
import * as Express from 'express';
require('dotenv').config();
import * as nodemailer from 'nodemailer';
import Mail = require('nodemailer/lib/mailer');
const app = Express();
import * as cors from 'cors';
import * as tf from '@tensorflow/tfjs';
import * as Jimp from 'jimp';
const path = require('path');
const os = require('os');
const admin = require('firebase-admin');


admin.initializeApp(functions.config().firebase);

let cloudBucket = admin.storage().bucket();


app.use(Express.json());
app.use(cors({ origin: true }));


app.post("/sendmail/", async (req, res) => {
    try {
        let email = req.body["email"];
        let messageText = req.body["message"];
        let subject = req.body["subject"];
        console.log(`${typeof email} ${messageText} ${subject}`);
        await sendEmail(email, subject, messageText);
        res.json({ "error": false });
    } catch (err) {
        res.json({ "error": true });
    }
})

export const predictDamage = functions.firestore.document("/complaints/{docID}/").onCreate((snapshot, context) => {
    let docID = context.params.docID;
    let fileName = snapshot.data.fileName;

    let cloudFilePath = `roadimages/${fileName}`;
    const tempFilePath = path.join(os.tmpdir(), fileName);
    
    console.log(path.join(__dirname, "model.json"));
    await cloudBucket.file(cloudFilePath).download({ destination: tempFilePath });
    let newFileName = (Math.random()*100).valueOf() + fileName;
    await new Promise((res, rej) => {
        Jimp.read(tempFilePath, (err, lenna) => {
            if (err) throw err;
            lenna
                .resize(150, 150) // resize
                .quality(100) // set JPEG quality
                .write(newFileName); // save
        })
    });
    let newFilePath = path.join(__dirname, newFileName) 
    const model = await tf.loadLayersModel('https://firebasestorage.googleapis.com/v0/b/roadassist-7a908.appspot.com/o/model.json?alt=media&token=bd51eecc-0d6b-4461-8cf7-5b59b45ba91b');
    const prediction = model.predict(newFilePath);
    console.log(prediction);
    res.send("done");
    console.log(`${snapshot.data} ${docID}`);
})

export const api = functions.https.onRequest(app);


function sendEmail(email: string, subject: string, messageText: string) {
    try {
        let transporter = nodemailer.createTransport({
            service: 'gmail',
            auth: {
                user: 'teamroadassist@gmail.com',
                pass: process.env.PASSWORD,
            }
        });
        const mailOptions: Mail.Options = {
            from: 'Team Road Assist<teamroadassist@gmail.com>',
            to: email,
            subject: subject,
            html: messageText
        };

        return new Promise((res, rej) => {
            transporter.sendMail(mailOptions, (erro: any, info: any) => {
                console.log(info);
                if (erro) {
                    console.log(erro);
                    console.log(`ERROR: ${erro}`);
                    rej(info);
                } else {
                    res(info);
                    console.log("MAIL SENT");
                }
            });
        })
    } catch (err) {
        console.log(err);
        return err;
    }
}