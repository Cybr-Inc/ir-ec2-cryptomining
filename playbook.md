# IAM credential exposure to EC2 Cryptomining playbook

This playbook is used in Cybr's course [Incident Response with CloudTrail and Athena](https://cybr.com/courses/incident-response-with-cloudtrail-and-athena/) and this repo contains files to download for the course. Please complete steps as outlined in each lesson.

Inspired by: https://github.com/aws-samples/aws-incident-response-playbooks-workshop/blob/main/playbooks/crypto_mining/EC2_crypto_mining.md

## **Incident Classification & Handling**

- **Category**: IAM credential exposure and EC2 Cryptomining
- **Resources**: IAM and EC2
- **Roles Assumed**:
    - **SecurityAnalyst**: provided CloudTrail data access and Athena querying
    - **SecurityDeploy**: deployed CloudFormation stack
    - **SecurityBreakGlass**: contained and eradicate the IAM user, credentials, backdoors, and EC2
    - **SecurityAdmin**: Configuring Athena
- **Tooling**: AWS CLI, AWS CloudTrail, Athena, CloudFormation
- **Indicators**: GuardDuty alert
- **Log Sources**: AWS CloudTrail, Amazon Athena, Amazon GuardDuty
- **Teams Involved**: Security Operations Center (SOC), Forensic Investigators, Cloud Engineering

## Response Steps

1. [**ANALYSIS**] Validate alert by checking ownership of exposed credential
2. [**ANALYSIS**] Identity exposed credential owner/custodian
3. [**ANALYSIS**] Investigate EC2 UserData
4. [**CONTAINMENT**] Disable exposed credential if approved by owner/customer
5. [**ANALYSIS**] Use Athena to look for compromised access keys/users, potential backdoors created, and resources launched or modified
6. [**CONTAINMENT**] Perform containment of backdoor users/access keys or other resources
7. [**CONTAINMENT**] Contain EC2 instances
8. [**ANALYSIS**] Forensics -- if needed
9. [**ANALYSIS**] Determine the impact based on collected evidence
10. [**ERADICATION**] Perform eradication (delete rogue resources, delete rogue EC2s, apply security updates and harden configuration)
11. [**RECOVERY**] Perform recovery as needed
12. [**POST-INCIDENT ACTIVITY**] Perform post-incident activity for preparation enhancement

## Recommendations

- Eliminate all users and access keys from our accounts, and prevent creations of new ones (check out my [blog post](https://cybr.com/cloud-security/ditching-aws-access-keys/) for tips on that)
- Create alerts based on the creation of long-term access keys or users
- Create alerts for the activity we saw in this attack, including launching EC2 instances or instances with spikes in CPU or GPU usage
- Prevent launching EC2 instances in accounts that should never launch them (you can do this using SCPs)
- Save the Athena queries we used in a playbook so that we can quickly retrieve and use them in the future
- Review user policies and access and implement a strategy to get closer to least privilege
- Script automation for containment and eradication via the AWS CLI or SDK

There is also a concept of designing a “clean room” for EC2 forensics in AWS which would include forensics tooling AMIs ready to be used, and other tools or services specialized for this. For more information on this topic, [check out this blog post](https://aws.amazon.com/blogs/security/forensic-investigation-environment-strategies-in-the-aws-cloud/). There’s also more information in the [AWS Security Reference Architecture (SRA)](https://docs.aws.amazon.com/prescriptive-guidance/latest/security-reference-architecture/cyber-forensics.html#forensics-account).

## Primary Athena queries used

Find them in the `queries` directory.