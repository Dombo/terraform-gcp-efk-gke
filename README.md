# Setting up

## Find your org and billing account ID
gcloud organizations list
gcloud beta billing accounts list

export TF_VAR_org_id=501932283318 (differs for you)
export TF_VAR_billing_account=01374E-2C7D2C-D5FF05 (differs for you)
export TF_ADMIN=efk-terraform-admin
export TF_CREDS=~/.config/gcloud/efk-terraform-admin.json

## Create a terraform management project
gcloud projects create ${TF_ADMIN} \
  --organization ${TF_VAR_org_id} \
  --set-as-default

gcloud beta billing projects link ${TF_ADMIN} \
  --billing-account ${TF_VAR_billing_account}

## Create a terraform management service account
gcloud iam service-accounts create terraform \
  --display-name "Terraform admin account"

gcloud iam service-accounts keys create ${TF_CREDS} \
  --iam-account terraform@${TF_ADMIN}.iam.gserviceaccount.com

## Grant it permissions necessary to run the terraform actions in this module
gcloud projects add-iam-policy-binding ${TF_ADMIN} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/viewer

gcloud projects add-iam-policy-binding ${TF_ADMIN} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/storage.admin

gcloud projects add-iam-policy-binding ${TF_ADMIN} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/container.admin

gcloud projects add-iam-policy-binding ${TF_ADMIN} \
    --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
    --role roles/iam.serviceAccountUser


## Enable APIs terraform needs for this module
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable cloudbilling.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable serviceusage.googleapis.com
gcloud services enable container.googleapis.com

## Grant the service account the ability to create projects
gcloud organizations add-iam-policy-binding ${TF_VAR_org_id} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/resourcemanager.projectCreator

gcloud organizations add-iam-policy-binding ${TF_VAR_org_id} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/billing.user

## Create a terraform state storage bucket
gsutil mb -p ${TF_ADMIN} gs://${TF_ADMIN}

cat > backend.tf << EOF
terraform {
 backend "gcs" {
   bucket  = "${TF_ADMIN}"
   prefix  = "terraform/state"
 }
}
EOF

gsutil versioning set on gs://${TF_ADMIN}

## Configure terraform specific variables such that it uses the service account created for future operations
export GOOGLE_APPLICATION_CREDENTIALS=${TF_CREDS}
export GOOGLE_PROJECT=${TF_ADMIN}

## Deploy the ES Operator & included templates for es cluster and kibana instance 
### Points your kubectl to the cluster
gcloud container clusters get-credentials gke-cluster --zone europe-west4-c --project ${TF_ADMIN}
kubectl apply -f https://download.elastic.co/downloads/eck/1.1.2/all-in-one.yaml
kubectl apply -f ./es-cluster.yaml
kubectl apply -f ./kibana-instance.yaml

# Tearing Down

terraform destroy

gcloud projects delete ${TF_ADMIN}

gcloud organizations remove-iam-policy-binding ${TF_VAR_org_id} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/resourcemanager.projectCreator

gcloud organizations remove-iam-policy-binding ${TF_VAR_org_id} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/billing.user