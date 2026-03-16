import Stripe from "https://esm.sh/stripe@14.0.0";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!);

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (req) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { action, ...payload } = await req.json();

    switch (action) {
      // ── Create Payment Intent ──────────────────────────────────────────────
      case "create_payment_intent": {
        const {
          amount,
          currency = "mad",
          reservationId,
          payerId,
          platformFee,
          ownerPayout,
        } = payload;

        const paymentIntent = await stripe.paymentIntents.create({
          amount: Math.round(amount * 100), // centimes
          currency,
          metadata: {
            reservation_id: String(reservationId),
            payer_id: String(payerId),
            platform_fee: String(platformFee),
            owner_payout: String(ownerPayout),
          },
        });

        return Response.json(
          {
            clientSecret: paymentIntent.client_secret,
            paymentIntentId: paymentIntent.id,
          },
          { headers: corsHeaders },
        );
      }

      // ── Confirm Payment (fetch charge id after sheet completes) ───────────
      case "confirm_payment": {
        const { paymentIntentId } = payload;

        const paymentIntent = await stripe.paymentIntents.retrieve(
          paymentIntentId,
          { expand: ["latest_charge"] },
        );

        const charge = paymentIntent.latest_charge as Stripe.Charge | null;

        return Response.json(
          {
            status: paymentIntent.status,
            chargeId: charge?.id ?? null,
            receiptUrl: charge?.receipt_url ?? null,
          },
          { headers: corsHeaders },
        );
      }

      // ── Refund ─────────────────────────────────────────────────────────────
      case "refund": {
        const { chargeId, amount, reservationId } = payload;

        const refund = await stripe.refunds.create({
          charge: chargeId,
          ...(amount ? { amount: Math.round(amount * 100) } : {}), // partial or full
          metadata: { reservation_id: String(reservationId) },
        });

        return Response.json(
          {
            refundId: refund.id,
            refundAmount: refund.amount / 100,
            status: refund.status,
          },
          { headers: corsHeaders },
        );
      }

      default:
        return Response.json(
          { error: `Unknown action: ${action}` },
          { status: 400, headers: corsHeaders },
        );
    }
  } catch (err) {
    console.error(err);
    return Response.json(
      { error: err instanceof Error ? err.message : "Internal error" },
      { status: 500, headers: corsHeaders },
    );
  }
});
