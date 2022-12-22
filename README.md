# stripe-webhook-gcp-function

Minimal GCP python function to receive and print events from Stripe.

## GCP Functions Framework

### Run function locally in debug mode

```bash
# run function locally in debug mode on port 8081
functions-framework --source=./python-functions/stripe_webhook/main.py --target=stripe_webhook --debug --port=8081
```

You should see output like this to show function is running locally on port 8081 (you can use whatever port you want):

```bash
(venv) PS C:\Users\andre\Documents\repos\stripe-webhook-gcp-function> functions-framework --source=./python-functions/stripe_webhook/main.py --target=stripe_webhook --debug --port=8081
 * Serving Flask app 'stripe_webhook'
 * Debug mode: on
WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:8081
Press CTRL+C to quit
 * Restarting with watchdog (windowsapi)
 * Debugger is active!
 * Debugger PIN: XXX-XXX
```

## Stripe CLI

### 1. Local forwarding on stripe events

```bash
# once function is running locally you can forward events to local endpoint
stripe listen --forward-to localhost:8081
```

You should see something like this when local forwarding is set up:

```powershell
PS C:\Users\andre> stripe listen --forward-to localhost:8081
> Ready! You are using Stripe API Version [2022-11-15]. Your webhook signing secret is xxx_xxxxxx (^C to quit)
```

### 2. Create some test events

```bash
# create a test event
stripe trigger payment_intent.succeeded
```

You should see something like this for a successful test event creation:

```
PS C:\Users\andre> stripe trigger payment_intent.succeeded
Setting up fixture for: payment_intent
Running fixture for: payment_intent
Trigger succeeded! Check dashboard for event details.
```

If the function as been invoked successfully then in the window from step 1 above you should see something like this:

```powershell
PS C:\Users\andre> stripe listen --forward-to localhost:8081
> Ready! You are using Stripe API Version [2022-11-15]. Your webhook signing secret is xxx_xxxxxx (^C to quit)
2022-12-22 12:31:10   --> charge.succeeded [evt_3MHnvQFE3Qfj39xW1UE7UhT6]
2022-12-22 12:31:10   --> payment_intent.succeeded [evt_3MHnvQFE3Qfj39xW1vzt9gAn]
2022-12-22 12:31:10   --> payment_intent.created [evt_3MHnvQFE3Qfj39xW1KR01wQ8]
2022-12-22 12:31:10  <--  [200] POST http://localhost:8081 [evt_3MHnvQFE3Qfj39xW1UE7UhT6]
2022-12-22 12:31:11  <--  [200] POST http://localhost:8081 [evt_3MHnvQFE3Qfj39xW1vzt9gAn]
2022-12-22 12:31:11  <--  [200] POST http://localhost:8081 [evt_3MHnvQFE3Qfj39xW1KR01wQ8]
```

Finally in the window where you triggered the functions framework to run you should just see the a json string with all the event info itself.

```poweshell
(venv) PS C:\Users\andre\Documents\repos\stripe-webhook-gcp-function> functions-framework --source=./python-functions/stripe_webhook/main.py --target=stripe_webhook --debug --port=8081
 * Serving Flask app 'stripe_webhook'
 * Debug mode: on
WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:8081
 * Running on http://192.168.86.31:8081
Press CTRL+C to quit
 * Restarting with watchdog (windowsapi)
 * Debugger is active!
 * Debugger PIN: 107-679-323
{"id": "evt_3MHnvQFE3Qfj39xW1UE7UhT6", "object": "event", "api_version": "2022-11-15", "created": 1671712265, "data": {"object": {"id": "ch_3MHnvQFE3Qfj39xW1ljeXQ0U", "object": "charge", "amount": 2000, "amount_captured": 2000, "amount_refunded": 0, 
...
"name": "Jenny Rosen", "phone": null, "tracking_number": null}, "source": null, "statement_descriptor": null, "statement_descriptor_suffix": null, "status": "requires_payment_method", "transfer_data": null, "transfer_group": null}}, "livemode": false, "pending_webhooks": 4, "request": {"id": "req_BsagVXD6LQwqjH", "idempotency_key": "e36a0855-a9e6-441a-b9ca-181632fd43ad"}, "type": "payment_intent.created"}
127.0.0.1 - - [22/Dec/2022 12:31:11] "POST / HTTP/1.1" 200 -
```
