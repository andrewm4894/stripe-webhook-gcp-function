import functions_framework
import os
from dotenv import load_dotenv

import stripe
from flask import Flask, jsonify, request

load_dotenv()

endpoint_secret = os.getenv('stripe_endpoint_secret')

@functions_framework.http
def stripe_webhook(request):

    print(request)
    print(dir(request))
    payload = request.get_data()
    print(payload)
    print('xxxxxxxxxxxxxxx')

    event = None

    sig_header = request.headers['STRIPE_SIGNATURE']

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

    print(event)

    return jsonify(success=True)
