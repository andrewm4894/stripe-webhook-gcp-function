import functions_framework
import os
from dotenv import load_dotenv

import stripe
from flask import Flask, jsonify, request

load_dotenv()

endpoint_secret = os.getenv('stripe_endpoint_secret')

@functions_framework.http
def stripe_webhook(request):

    event = None
    sig_header = request.headers['STRIPE_SIGNATURE']

    print(request)
    print(type(request))
    print(dir(request))
    payload = request.data.decode('utf-8')
    print(payload)
    print(sig_header)
    print(endpoint_secret)
    print('xxxxxxxxxxxxxxx')

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

    print('SUCCESS!!!!!!')
    print(event)

    return jsonify(success=True)
