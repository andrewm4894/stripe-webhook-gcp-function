# stripe-webhook-gcp-function
Minimal GCP python function to receive and print events from Stripe.

## Stripe CLI

```bash
# forward events to local endpoint
stripe listen --forward-to localhost:8081
```

```bash
# create a test event
stripe trigger payment_intent.succeeded
```

## GCP Functions Framework

```bash
# run function locally in debug mode
functions-framework --source=./python-functions/stripe_webhook/main.py --target=stripe_webhook --debug --port=8081
```