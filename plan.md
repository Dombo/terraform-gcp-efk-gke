Pre-reqs
---
~Terraform state management~ + ci/cd model
~GKE Cluster~
~EFK deployed into GKE~

Thoughts
---
* Test run an upgrade of the GKE cluster?
* Test run an upgrade of the ECK installation?
* Persist data across cluster changes with a volume claim.
* Add a managed SSL certificate.
* Integrate with Google oAuth/Reverse Proxy gateway
* 

Pricing
---
VPC network ingest - free
VPN network ingest - free

Single-zone does not incur the $0.10 p/h management fee
Single-zone seems fairly reliable - check GKE https://status.cloud.google.com/summary

Roughly $48.54/$14.6 per month depending on pre-emptible or on-demand