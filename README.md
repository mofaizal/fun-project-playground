# Architecture Patterns 

This Terraform repository provides examples of various architecture patterns using Azure Verified Modules (AVM). These examples can be leveraged in all types of environments, including development, testing, and production.

The examples demonstrate how to provide input parameters, combine multiple AVM modules, and deploy Azure resources. Users should carefully review their specific needs and adjust parameters accordingly to meet their unique requirements.

Below are example deployments using AVM:

- [Deploying VNET, Subnet, NSG, NSG Rules, and associating NSG to a Subnet.](/avm-workload-vnet/README.md)
  ![](/images/vnet.png)
- [Referring to the VNET deployment state and deploying application workloads to an existing VNET.](/avm-workload-apps/README.md)
- [Deploying VNET, Subnet, NSG, NSG Rules, VM Scale Set, and an Internal Load Balancer together.](/avm-workload/README.md)
  ![](/images/vmssandlb.png)