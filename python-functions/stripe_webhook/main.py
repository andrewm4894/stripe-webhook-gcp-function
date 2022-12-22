import os
import json

from flask import jsonify
from dotenv import load_dotenv
import functions_framework
import stripe

# used to read .env file to make local execution easy
load_dotenv()

endpoint_secret = os.getenv('stripe_endpoint_secret')


@functions_framework.http
def stripe_webhook(request):

    event = None
    sig_header = request.headers['STRIPE_SIGNATURE']
    payload = request.data.decode('utf-8')

    try:
        event = stripe.Webhook.construct_event(
            payload, sig_header, endpoint_secret
        )
    except ValueError as e:
        # Invalid payload
        raise e
    except stripe.error.SignatureVerificationError as e:
        # Invalid signature
        raise e

    # print event as a big string
    print(json.dumps(event))

    return jsonify(success=True)
