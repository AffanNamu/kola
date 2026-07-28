# Edge Function Response Contract

All verification edge functions must return:

## Success
{
  "success": true,
  "status": "success",
  "amount": <number>,
  "currency": "<string>",
  "raw": <any>
}

## Failure
{
  "success": false,
  "status": "failed",
  "message": "<string?>",
  "raw": <any>
}

The app uses:
- success (bool)
- status (string)
- raw (stored to payment.gatewayResponse)
