# AWS Hosting Notes

This folder now includes an AWS scaffold for hosting Willow House Photography on `willowhousephotography.com`.

What the scaffold covers:

- S3 bucket for the website files
- Separate S3 bucket for image assets
- CloudFront distribution with HTTPS
- Route 53 apex and `www` aliases
- Lambda + HTTP API backend for the contact form
- SES-based email delivery to one or more recipient addresses
- A placeholder parameter for the ACM certificate ARN

Important notes:

- The ACM certificate is not configured in HTML. It belongs in CloudFront and should be created in `us-east-1`.
- Images are served from the same domain through CloudFront at `/images/*`, so the HTML can keep using relative image paths.
- Google Workspace email setup is not required to create the ACM certificate itself. If you want the form to send from Google Workspace later, that is a mail-delivery configuration step, not an SSL step.
- The Lambda contact form uses SES, so the `ContactFromEmail` sender address must be verified in SES before the form can send mail.
- The contact form now posts to `/api/contact` on the same domain, so once the stack is deployed it can send the message to one or more recipient emails.
- The deployment scripts in this folder assume you will run `bash deploy-aws.sh` first and then `bash upload-site.sh` after the stack finishes.

Suggested next steps:

1. Create the ACM certificate in `us-east-1` for `willowhousephotography.com` and `www.willowhousephotography.com`.
2. Deploy the CloudFormation stack with your Route 53 hosted zone ID.
3. Set the SES verified sender address and the recipient email list in the stack parameters.
4. Upload the site files to the website bucket and image files to the images bucket.
5. When the stack is up, the contact form will post to the Lambda-backed API route automatically.
