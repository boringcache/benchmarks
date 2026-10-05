# Source publication rehearsal

Question: does the source publisher conditionally advance an isolated branch,
retain intent before dispatch, request both declared Mastodon rolling variants
with the exact canary, and reconcile their returned run IDs without modifying
main?

The input is the Mastodon proposal verified by source-check run 37321566845.
Use branch cadence-rehearsal-publication and CLI vcli-canary-7a5b27146ebe.
Request server and streaming once each, with their declared GitHub Actions and
BoringCache providers. Use the branch's default rolling cache cohort. These are
bootstrap observations, not evidence of changed-source cache reuse. The separate
cadence-rolling seed and advancement series test cache reuse.

Verify the published file diff, commit verification, exact returned run IDs,
retained intent and final receipts, reconciliation outcome, and unchanged main
head and activation setting. Retain failures and uncertain requests. Do not retry
an uncertain dispatch automatically.
