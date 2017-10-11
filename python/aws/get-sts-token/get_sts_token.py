#!/usr/bin/env python

import argparse
import boto3
import os

def main():

    parser = argparse.ArgumentParser()
    parser.add_argument("--aws-profile",
                        help="AWS profile you'd like to get STS tokens for",
                        default="default")
    parser.add_argument("--mfa-serial",
                        help="ARN of your MFA device",
                        required=True)
    parser.add_argument("--token-code",
                        help="Code from your MFA device",
                        required=True)
    args = parser.parse_args()

    sess = boto3.Session(profile_name=args.aws_profile)
    sts = sess.client('sts')

    response = sts.get_session_token(SerialNumber=args.mfa_serial,
                                     TokenCode=args.token_code)["Credentials"]

    print("export AWS_ACCESS_KEY_ID={}".format(response["AccessKeyId"]))
    print("export AWS_SECRET_ACCESS_KEY={}".format(response["SecretAccessKey"]))
    print("export AWS_SESSION_TOKEN={}".format(response["SessionToken"]))

if __name__ == '__main__':
    main()



