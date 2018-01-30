import json
import requests
import logging


def get_bearer_token(twitter_key_hash):

    headers = {"Authorization": "Basic {}".format(twitter_key_hash),
               "Content-Type": "application/x-www-form-url;charset=UTF-8",
               "Accept-Encoding": "gzip"
               }
    resp = requests.post("https://api.twitter.com/oauth2/token",
                         headers=headers,
                         params="grant_type=client_credentials")
    bearer = None
    if resp.status_code == 200:
        token_data = json.loads(resp.content)
        bearer = token_data["access_token"]
    else:
        logging.error("Request faild with error {}".format(resp.status_code))
    return bearer
