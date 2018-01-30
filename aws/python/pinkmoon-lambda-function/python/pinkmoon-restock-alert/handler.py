#!/usr/bin/env python3

import datetime
import json
import logging
import os
import requests


from base64 import b64encode
from urllib.parse import quote_plus
from twitter_login.get_bearer_token import get_bearer_token

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)
logger.addHandler(logging.StreamHandler())

TWITTER_API_KEY = quote_plus(os.getenv("TWITTER_API_KEY"))
TWITTER_API_SECRET = quote_plus(os.getenv("TWITTER_API_SECRET"))
TWITTER_KEY_HASH = b64encode(
    "{}:{}".format(TWITTER_API_KEY, TWITTER_API_SECRET).encode())
TWITTER_API_ENDPOINT = "https://api.twitter.com/{}"
TWITTER_BEARER_TOKEN = get_bearer_token(TWITTER_KEY_HASH.decode())


def set_login_headers(func):
    headers = {"Authorization": "Bearer {}".format(TWITTER_BEARER_TOKEN)}
    print("In set_login_headers")

    def wrapped_func(*args, **kwargs):
        print(kwargs)
        kwargs['headers'] = headers
        return func(*args, **kwargs)

    return wrapped_func


@set_login_headers
def get_user_id(screen_name, **kwargs):
    user_request_endpoint = "/1.1/users/show.json"
    params = {"screen_name": screen_name}
    user_id = None

    resp = requests.get(TWITTER_API_ENDPOINT.format(user_request_endpoint),
                        headers=kwargs['headers'],
                        params=params)
    if resp.status_code == 200:
        user_id = resp.json()["id_str"]
    return user_id


@set_login_headers
def get_tweets_24_hours(screen_name, **kwargs):
    request_endpoint = "/1.1/search/tweets.json?"

    params = {"since": (datetime.datetime.today() -
                        datetime.timedelta(days=1)).strftime("%Y-%M-%d"),
              "until": datetime.datetime.today().strftime("%Y-%M-%d")}
    resp = requests.get(TWITTER_API_ENDPOINT.format(request_endpoint),
                        headers=kwargs['headers'],
                        params=params)

    if resp.status_code == 200:
        return map(lambda x: x["text"], resp.json())



def main():

    bearer = get_bearer_token(TWITTER_KEY_HASH)
    logger.log(logging.INFO, "Bearer is: {}".format(bearer))

    user_id = get_user_id("pinkmoonlw")
    logger.log(logging.INFO, "User ID is: {}".format(user_id))

    tweets = get_tweets_24_hours("pinkmoonlw")
    print(json.dumps(tweets, indent=2))

    if "restock" in tweets:
        logger.log(logging.INFO, "Restock is in tweets")
    else:
        logger.log(logging.INFO, "Restock is not in tweets")


if __name__ == '__main__':
    main()
